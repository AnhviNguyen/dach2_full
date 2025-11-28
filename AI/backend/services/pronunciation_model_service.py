"""
Pronunciation Model Service - Sử dụng Wav2Vec2 + Conformer model để check phát âm tiếng Hàn
Tích hợp model pronunciation check từ notebook
"""
import logging
import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import librosa
import soundfile as sf
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
import json
import tempfile
import os

logger = logging.getLogger(__name__)

# ===== KOREAN G2P (Grapheme-to-Phoneme) =====
# Từ notebook: hangul_g2p function

KOREAN_TO_IPA = {
    "ㄱ": "k", "ㄲ": "kk", "ㄴ": "n", "ㄷ": "t", "ㄸ": "tt",
    "ㄹ": "r/l", "ㅁ": "m", "ㅂ": "p", "ㅃ": "pp", "ㅅ": "s",
    "ㅆ": "ss", "ㅇ": "ŋ", "ㅈ": "tɕ", "ㅉ": "ttɕ", "ㅊ": "tɕʰ",
    "ㅋ": "kʰ", "ㅌ": "tʰ", "ㅍ": "pʰ", "ㅎ": "h",
    "ㅏ": "a", "ㅐ": "æ", "ㅑ": "ja", "ㅒ": "jæ", "ㅓ": "ʌ",
    "ㅔ": "e", "ㅕ": "jʌ", "ㅖ": "je", "ㅗ": "o", "ㅘ": "wa",
    "ㅙ": "wæ", "ㅚ": "ø", "ㅛ": "jo", "ㅜ": "u", "ㅝ": "wʌ",
    "ㅞ": "we", "ㅟ": "wi", "ㅠ": "ju", "ㅡ": "ɯ", "ㅢ": "ɯi",
    "ㅣ": "i",
    "ㄳ": "ks", "ㄵ": "ntɕ", "ㄶ": "nh", "ㄺ": "lk", "ㄻ": "lm",
    "ㄼ": "lp", "ㄽ": "ls", "ㄾ": "ltʰ", "ㄿ": "lpʰ", "ㅀ": "lh",
    "ㅄ": "ps",
    "<sp>": "<sp>", "<unk>": "<unk>"
}

LEADS = "ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ"
VOWELS = "ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ"
TAILS = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]


def hangul_g2p(text: str) -> List[str]:
    """Chuyển chữ Hangul → danh sách phoneme (ㄱ, ㅏ, ㄴ, ...)"""
    phonemes = []
    for c in text.strip():
        code = ord(c)
        if 0xAC00 <= code <= 0xD7A3:  # Chữ cái Hangul
            s = code - 0xAC00
            l, v, t = s // 588, (s % 588) // 28, s % 28
            phonemes.append(LEADS[l])
            phonemes.append(VOWELS[v])
            if t:
                phonemes.append(TAILS[t])
        elif c == " ":
            phonemes.append("<sp>")
        else:
            phonemes.append(c)
    return phonemes


# ===== MODEL ARCHITECTURE (từ notebook) =====

class ConformerBlock(nn.Module):
    def __init__(self, dim=512, heads=8, ff_mult=4, kernel_size=15, dropout=0.2):
        super().__init__()
        self.ff1 = nn.Linear(dim, dim * ff_mult)
        self.ff2 = nn.Linear(dim * ff_mult, dim)
        self.mhsa = nn.MultiheadAttention(dim, heads, batch_first=True, dropout=dropout)
        self.conv = nn.Sequential(
            nn.Conv1d(dim, dim*2, 1),
            nn.GLU(dim=1),
            nn.Conv1d(dim, dim, kernel_size, padding=kernel_size//2, groups=dim),
            nn.BatchNorm1d(dim),
            nn.GELU(),
            nn.Conv1d(dim, dim, 1),
            nn.Dropout(dropout)
        )
        self.ln1 = nn.LayerNorm(dim)
        self.ln2 = nn.LayerNorm(dim)
        self.ln3 = nn.LayerNorm(dim)
        self.ln_final = nn.LayerNorm(dim)
        self.dropout_rate = dropout

    def forward(self, x):
        residual = x
        x = self.ff1(x)
        x = F.gelu(x)
        x = self.ff2(x)
        x = F.dropout(x, self.dropout_rate, training=self.training)
        x = self.ln1(x + residual)

        residual = x
        x = self.mhsa(x, x, x)[0]
        x = self.ln2(x + residual)

        residual = x
        x = x.transpose(1, 2)
        x = self.conv(x)
        x = x.transpose(1, 2)
        x = self.ln3(x + residual)

        return self.ln_final(x)


class ConformerPronunciationModel(nn.Module):
    def __init__(self, input_dim=768, num_phonemes=55, dim=256, heads=4, depth=3, dropout=0.2):
        super().__init__()
        self.proj = nn.Linear(input_dim, dim)
        self.pos_emb = nn.Parameter(torch.zeros(1, 500, dim))
        self.blocks = nn.ModuleList([
            ConformerBlock(dim, heads, dropout=dropout)
            for _ in range(depth)
        ])
        self.fc = nn.Linear(dim, num_phonemes)
        self.dropout_rate = dropout

    def forward(self, x):
        x = self.proj(x)
        B, T, D = x.shape
        pos = self.pos_emb[:, :T, :]
        x = x + pos
        x = F.dropout(x, self.dropout_rate, training=self.training)
        for block in self.blocks:
            x = block(x)
        return self.fc(x)


# ===== WAV2VEC2 FEATURE EXTRACTION =====

_wav2vec2_model = None
_wav2vec2_processor = None
_wav2vec2_device = None


def get_wav2vec2_model():
    """Lazy load Wav2Vec2 model"""
    global _wav2vec2_model, _wav2vec2_processor, _wav2vec2_device
    if _wav2vec2_model is None:
        try:
            from transformers import Wav2Vec2Processor, Wav2Vec2Model
            logger.info("Loading Wav2Vec2 model: facebook/wav2vec2-base")
            _wav2vec2_processor = Wav2Vec2Processor.from_pretrained("facebook/wav2vec2-base")
            _wav2vec2_model = Wav2Vec2Model.from_pretrained("facebook/wav2vec2-base")
            _wav2vec2_device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
            _wav2vec2_model.to(_wav2vec2_device)
            _wav2vec2_model.eval()
            logger.info(f"✅ Wav2Vec2 loaded on {_wav2vec2_device}")
        except ImportError:
            logger.error("transformers library not installed. Install with: pip install transformers")
            raise
    return _wav2vec2_model, _wav2vec2_processor, _wav2vec2_device


def extract_wav2vec2_features(audio: np.ndarray, sr: int = 16000) -> np.ndarray:
    """Extract features using Wav2Vec2 model"""
    model, processor, model_device = get_wav2vec2_model()
    
    # Ensure audio is numpy array
    if isinstance(audio, torch.Tensor):
        audio = audio.cpu().numpy()
    
    # Normalize audio
    if len(audio.shape) > 1:
        audio = audio.squeeze()
    
    # Ensure correct sample rate
    if sr != 16000:
        audio = librosa.resample(audio, orig_sr=sr, target_sr=16000)
    
    # Process audio
    inputs = processor(audio, sampling_rate=16000, return_tensors="pt", padding=True)
    
    # Move to model device
    inputs = {k: v.to(model_device) for k, v in inputs.items()}
    
    # Extract features (without gradients for efficiency)
    with torch.no_grad():
        outputs = model(**inputs)
        features = outputs.last_hidden_state  # (batch, seq_len, feature_dim)
    
    # Convert to numpy and return (remove batch dimension)
    features = features.squeeze(0).cpu().numpy()  # (T, 768)
    
    return features


# ===== CTC DECODING =====

def ctc_greedy_decode(log_probs: torch.Tensor, blank_id: int = 0) -> List[List[int]]:
    """
    CTC Greedy Decode
    Input: (B, T, C) - log probabilities
    Output: List[List[int]] - decoded sequences
    """
    if log_probs.dim() == 2:
        log_probs = log_probs.unsqueeze(0)
    
    # Argmax theo dimension cuối
    preds = torch.argmax(log_probs, dim=-1)  # (B, T)
    
    batch_results = []
    for seq in preds:
        decoded = []
        prev = None
        
        for token_id in seq.tolist():
            # Loại bỏ blank và duplicate liên tiếp
            if token_id != blank_id and token_id != prev:
                decoded.append(token_id)
            prev = token_id
        
        batch_results.append(decoded)
    
    return batch_results


# ===== LEVENSHTEIN DISTANCE =====

def levenshtein_distance(seq1: List, seq2: List) -> Tuple[int, Dict]:
    """
    Tính Levenshtein distance (edit distance) giữa 2 sequences
    Returns: (distance, details_dict)
    """
    n, m = len(seq1), len(seq2)
    dp = [[0] * (m + 1) for _ in range(n + 1)]
    
    # Initialize
    for i in range(n + 1):
        dp[i][0] = i
    for j in range(m + 1):
        dp[0][j] = j
    
    # Fill DP table
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            if seq1[i-1] == seq2[j-1]:
                dp[i][j] = dp[i-1][j-1]
            else:
                dp[i][j] = min(
                    dp[i-1][j] + 1,      # deletion
                    dp[i][j-1] + 1,      # insertion
                    dp[i-1][j-1] + 1     # substitution
                )
    
    # Calculate detailed metrics
    matches = sum(1 for i in range(min(n, m)) if seq1[i] == seq2[i])
    substitutions = dp[n][m] - abs(n - m)  # Approximate
    insertions = max(0, m - n)
    deletions = max(0, n - m)
    
    return dp[n][m], {
        "matches": matches,
        "substitutions": substitutions,
        "insertions": insertions,
        "deletions": deletions
    }


# ===== PRONUNCIATION CHECK RESULT =====

@dataclass
class PronunciationCheckResult:
    """Kết quả check pronunciation từ model"""
    phoneme_accuracy: float  # 0-100
    per: float  # Phoneme Error Rate (0-1, lower is better)
    expected_phonemes: List[str]
    predicted_phonemes: List[str]
    wrong_phonemes: List[Tuple[str, str]]  # (expected, predicted)
    wrong_words: List[str]  # Words that have errors
    matches: int
    substitutions: int
    insertions: int
    deletions: int
    overall_score: float  # 0-100


# ===== PRONUNCIATION MODEL SERVICE =====

_pronunciation_model = None
_phoneme_to_id = None
_id_to_phoneme = None
_model_device = None
_model_mean = None
_model_std = None


def load_pronunciation_model(
    model_path: Optional[str] = None,
    p2id_path: Optional[str] = None,
    mean_std_path: Optional[str] = None
) -> bool:
    """
    Load pronunciation model và phoneme dictionary
    
    Args:
        model_path: Đường dẫn đến file model .pt (default: models/pronunciation_model.pt relative to backend dir)
        p2id_path: Đường dẫn đến file p2id.json (default: models/p2id.json relative to backend dir)
        mean_std_path: Đường dẫn đến file wav2vec2_stats.npy (default: models/wav2vec2_stats.npy)
    
    Returns:
        bool: True nếu load thành công
    """
    global _pronunciation_model, _phoneme_to_id, _id_to_phoneme, _model_device, _model_mean, _model_std
    
    try:
        # Resolve paths relative to backend directory
        backend_dir = Path(__file__).parent.parent  # Go up from services/ to backend/
        
        if model_path is None:
            model_path = backend_dir / "models" / "pronunciation_model.pt"
        else:
            model_path = Path(model_path)
            if not model_path.is_absolute():
                model_path = backend_dir / model_path
        
        if p2id_path is None:
            p2id_path = backend_dir / "models" / "p2id.json"
        else:
            p2id_path = Path(p2id_path)
            if not p2id_path.is_absolute():
                p2id_path = backend_dir / p2id_path
        
        if mean_std_path is None:
            mean_std_path = backend_dir / "models" / "wav2vec2_stats.npy"
        else:
            mean_std_path = Path(mean_std_path)
            if not mean_std_path.is_absolute():
                mean_std_path = backend_dir / mean_std_path
        
        logger.info(f"Loading pronunciation model from: {model_path}")
        logger.info(f"Loading phoneme dictionary from: {p2id_path}")
        logger.info(f"Loading normalization stats from: {mean_std_path}")
        
        # Load phoneme dictionary
        if not p2id_path.exists():
            logger.warning(f"Phoneme dictionary not found at {p2id_path}. Using default.")
            # Create default dictionary
            _phoneme_to_id = {"<blank>": 0}
            phonemes = sorted(set(LEADS + VOWELS + "".join(TAILS) + "<sp>"))
            for i, p in enumerate(phonemes, start=1):
                _phoneme_to_id[p] = i
        else:
            with open(p2id_path, 'r', encoding='utf-8') as f:
                _phoneme_to_id = json.load(f)
            logger.info(f"✅ Loaded phoneme dictionary: {len(_phoneme_to_id)} phonemes")
        
        _id_to_phoneme = {v: k for k, v in _phoneme_to_id.items()}
        
        # Load mean/std if provided
        if mean_std_path.exists():
            stats = np.load(mean_std_path)
            _model_mean, _model_std = stats[0], stats[1]
            logger.info(f"✅ Loaded normalization stats: mean={_model_mean:.6f}, std={_model_std:.6f}")
        else:
            _model_mean, _model_std = 0.0, 1.0
            logger.warning(f"Normalization stats not found at {mean_std_path}. Using default (mean=0, std=1)")
        
        # Load model
        if not model_path.exists():
            logger.error(f"❌ Model not found at {model_path}. Model will not be available.")
            return False
        
        _model_device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        num_phonemes = len(_phoneme_to_id)
        
        # Create model architecture
        _pronunciation_model = ConformerPronunciationModel(
            input_dim=768,  # Wav2Vec2 feature dimension
            num_phonemes=num_phonemes,
            dim=256,
            heads=4,
            depth=3,
            dropout=0.2
        )
        
        # Load weights
        logger.info(f"Loading model weights from {model_path}...")
        state_dict = torch.load(model_path, map_location=_model_device)
        _pronunciation_model.load_state_dict(state_dict)
        _pronunciation_model.to(_model_device)
        _pronunciation_model.eval()
        
        logger.info(f"✅ Pronunciation model loaded successfully on {_model_device}")
        logger.info(f"   Model parameters: {sum(p.numel() for p in _pronunciation_model.parameters()):,}")
        logger.info(f"   Phonemes: {num_phonemes}")
        return True
        
    except Exception as e:
        logger.error(f"Error loading pronunciation model: {e}")
        return False


def is_model_loaded() -> bool:
    """Check if pronunciation model is loaded"""
    return _pronunciation_model is not None


def check_pronunciation(
    audio_path: str,
    expected_text: str,
    sample_rate: int = 16000
) -> Optional[PronunciationCheckResult]:
    """
    Check pronunciation của một audio file với text expected
    
    Args:
        audio_path: Đường dẫn đến audio file
        expected_text: Văn bản mong đợi bằng Hangul
        sample_rate: Sample rate của audio (sẽ resample về 16000)
    
    Returns:
        PronunciationCheckResult hoặc None nếu có lỗi
    """
    global _pronunciation_model, _phoneme_to_id, _id_to_phoneme, _model_device, _model_mean, _model_std
    
    if _pronunciation_model is None:
        logger.error("Pronunciation model not loaded. Call load_pronunciation_model() first.")
        return None
    
    try:
        # 1. Load và resample audio
        audio, sr = sf.read(audio_path)
        if sr != sample_rate:
            audio = librosa.resample(audio, orig_sr=sr, target_sr=sample_rate)
        
        # 2. Extract Wav2Vec2 features
        features = extract_wav2vec2_features(audio, sample_rate)
        
        # 3. Normalize features
        features = (features - _model_mean) / (_model_std + 1e-8)
        features_tensor = torch.tensor(features, dtype=torch.float32).unsqueeze(0).to(_model_device)
        
        # 4. Predict phonemes từ audio
        #    Audio → Wav2Vec2 features → Conformer model → logits → phoneme IDs → phoneme strings
        with torch.no_grad():
            logits = _pronunciation_model(features_tensor)  # (batch, time, num_phonemes)
            log_probs = F.log_softmax(logits, dim=-1)
            pred_ids = ctc_greedy_decode(log_probs.cpu())[0]  # Decode CTC → phoneme IDs
            predicted_phonemes = [_id_to_phoneme.get(pid, '?') for pid in pred_ids]  # IDs → phoneme strings (ㄱ, ㅏ, ...)
        
        # 5. Get expected phonemes từ expected_text (Hangul)
        #    Hangul text → phân tích Unicode → phoneme strings (ㄱ, ㅏ, ...)
        #    Ví dụ: "안녕하세요" → ["ㅇ", "ㅏ", "ㄴ", "ㄴ", "ㅕ", "ㅇ", "ㅎ", "ㅏ", "ㅅ", "ㅔ", "ㅇ", "ㅛ"]
        expected_phonemes = hangul_g2p(expected_text)
        expected_phonemes = [p for p in expected_phonemes if p != '<sp>']
        predicted_phonemes = [p for p in predicted_phonemes if p != '<sp>' and p != '<blank>']
        
        # 6. Calculate PER and accuracy
        edit_dist, details = levenshtein_distance(predicted_phonemes, expected_phonemes)
        per = edit_dist / max(len(expected_phonemes), 1)
        phoneme_accuracy = max(0.0, min(100.0, (1.0 - per) * 100))
        
        # 7. Find wrong phonemes (simplified alignment)
        wrong_phonemes = []
        min_len = min(len(predicted_phonemes), len(expected_phonemes))
        for i in range(min_len):
            if predicted_phonemes[i] != expected_phonemes[i]:
                wrong_phonemes.append((expected_phonemes[i], predicted_phonemes[i]))
        
        # 8. Find wrong words (simplified - would need proper alignment)
        wrong_words = []
        words = expected_text.split()
        # Simple heuristic: if PER > 0.2 for a word region, mark as wrong
        phn_per_word = len(expected_phonemes) / len(words) if words else 0
        for i, word in enumerate(words):
            start_idx = int(i * phn_per_word)
            end_idx = int((i + 1) * phn_per_word)
            word_exp_phns = expected_phonemes[start_idx:end_idx]
            word_pred_phns = predicted_phonemes[start_idx:end_idx] if start_idx < len(predicted_phonemes) else []
            
            if len(word_exp_phns) > 0:
                word_edit_dist, _ = levenshtein_distance(word_pred_phns, word_exp_phns)
                word_per = word_edit_dist / len(word_exp_phns)
                if word_per > 0.2:  # Threshold
                    wrong_words.append(word)
        
        return PronunciationCheckResult(
            phoneme_accuracy=round(phoneme_accuracy, 1),
            per=round(per, 4),
            expected_phonemes=expected_phonemes,
            predicted_phonemes=predicted_phonemes,
            wrong_phonemes=wrong_phonemes[:10],  # Limit to 10
            wrong_words=wrong_words,
            matches=details["matches"],
            substitutions=details["substitutions"],
            insertions=details["insertions"],
            deletions=details["deletions"],
            overall_score=phoneme_accuracy  # Use phoneme accuracy as overall score
        )
        
    except Exception as e:
        logger.error(f"Error checking pronunciation: {e}")
        return None


def check_pronunciation_from_bytes(
    audio_bytes: bytes,
    expected_text: str,
    sample_rate: int = 16000,
    audio_format: str = "wav"
) -> Optional[PronunciationCheckResult]:
    """
    Check pronunciation từ audio bytes (từ UploadFile)
    
    Args:
        audio_bytes: Audio data as bytes
        expected_text: Văn bản mong đợi bằng Hangul
        sample_rate: Sample rate
        audio_format: Format của audio (wav, mp3, webm, etc.)
    
    Returns:
        PronunciationCheckResult hoặc None
    """
    try:
        # Save to temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=f".{audio_format}") as temp_file:
            temp_file.write(audio_bytes)
            temp_path = temp_file.name
        
        try:
            result = check_pronunciation(temp_path, expected_text, sample_rate)
            return result
        finally:
            # Cleanup
            if os.path.exists(temp_path):
                os.unlink(temp_path)
                
    except Exception as e:
        logger.error(f"Error checking pronunciation from bytes: {e}")
        return None

