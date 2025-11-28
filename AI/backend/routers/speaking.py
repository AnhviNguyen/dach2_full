"""
Speaking Router - Korean speaking practice and pronunciation evaluation
Tích hợp model pronunciation check với GPT để đạt độ chính xác cao và trải nghiệm tốt
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from models.schemas import (
    ReadAloudResponse, 
    AccuracyDetails, 
    FreeSpeakResponse,
    PronunciationFeedback,
    PhonemeDetail,
    WordFeedback,
    PronunciationFeedbackSummary
)
from services import openai_service, accuracy_service
from services.tts_service import generate_speech
from services.stt_service import transcribe_audio_cheap  # Use local Whisper (FREE)
from services.pronunciation_model_service import (
    check_pronunciation_from_bytes,
    is_model_loaded
)
from services.error_handlers import handle_openai_error
import logging
from typing import Optional, Dict, Any, Tuple, List
from pathlib import Path

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api",
    tags=["speaking"]
)

# Model is loaded in main.py startup event
# Just check if it's available
def get_model_status() -> bool:
    """Check if pronunciation model is loaded"""
    return is_model_loaded()


def _classify_phoneme(phoneme: str) -> str:
    """Phân loại phoneme: initial (phụ âm đầu), vowel (nguyên âm), final (phụ âm cuối)"""
    from services.pronunciation_model_service import LEADS, VOWELS, TAILS
    
    if phoneme in LEADS:
        return "initial"  # Phụ âm đầu
    elif phoneme in VOWELS:
        return "vowel"  # Nguyên âm
    elif phoneme in TAILS:
        return "final"  # Phụ âm cuối
    else:
        return "other"


def _generate_local_feedback_vi(
    expected_text: str,
    spoken_text: str,
    phoneme_accuracy: Optional[float] = None,
    word_accuracy: Optional[float] = None,
    model_result: Optional[Dict[str, Any]] = None,
    accuracy_details: Optional[Dict[str, Any]] = None
) -> Tuple[str, List[str]]:
    """
    Tạo feedback bằng tiếng Việt từ pronunciation model results (KHÔNG dùng GPT)
    
    Args:
        expected_text: Văn bản đúng
        spoken_text: Văn bản người dùng đã nói
        phoneme_accuracy: Độ chính xác ở mức phoneme (0-100)
        word_accuracy: Độ chính xác ở mức từ (0-100)
        model_result: Kết quả từ pronunciation model
        accuracy_details: Chi tiết từ accuracy service
    
    Returns:
        tuple: (feedback_vi, tricky_words)
    """
    feedback_parts = []
    tricky_words = []
    
    # Xác định overall score
    overall_score = phoneme_accuracy if phoneme_accuracy is not None else word_accuracy
    
    if overall_score is None:
        overall_score = 0.0
    
    # Overall assessment bằng tiếng Việt
    if overall_score >= 95:
        feedback_parts.append("🎉 Tuyệt vời! Phát âm của bạn gần như hoàn hảo!")
    elif overall_score >= 85:
        feedback_parts.append("👍 Làm tốt lắm! Phát âm của bạn rất tốt.")
    elif overall_score >= 70:
        feedback_parts.append("✅ Cố gắng tốt! Bạn đang đi đúng hướng.")
    elif overall_score >= 50:
        feedback_parts.append("💪 Tiếp tục luyện tập! Bạn đang tiến bộ.")
    else:
        feedback_parts.append("🔄 Hãy thử lại. Đừng lo, luyện tập sẽ giúp bạn cải thiện!")
    
    # Chi tiết từ pronunciation model (nếu có)
    if model_result:
        wrong_phonemes = model_result.get("wrong_phonemes", [])
        wrong_words = model_result.get("wrong_words", [])
        substitutions = model_result.get("substitutions", 0)
        deletions = model_result.get("deletions", 0)
        insertions = model_result.get("insertions", 0)
        
        if phoneme_accuracy is not None:
            feedback_parts.append(f"Độ chính xác phoneme: {phoneme_accuracy:.1f}%.")
        
        if wrong_phonemes:
            tricky_phonemes = list(set([exp for exp, pred in wrong_phonemes[:5]]))
            feedback_parts.append(f"Phát âm cần cải thiện: {', '.join(tricky_phonemes[:3])}.")
        
        if wrong_words:
            tricky_words = list(set(wrong_words[:5]))
            feedback_parts.append(f"Các từ cần luyện tập: {', '.join(tricky_words[:3])}.")
        
        if substitutions > 0:
            feedback_parts.append(f"Có {substitutions} phoneme bị thay thế sai.")
        if deletions > 0:
            feedback_parts.append(f"Có {deletions} phoneme bị thiếu.")
        if insertions > 0:
            feedback_parts.append(f"Có {insertions} phoneme thừa.")
    
    # Chi tiết từ word accuracy (nếu không có model result)
    elif accuracy_details:
        matches = accuracy_details.get("matches", 0)
        substitutions = accuracy_details.get("substitutions", 0)
        deletions = accuracy_details.get("deletions", 0)
        insertions = accuracy_details.get("insertions", 0)
        
        issues = []
        if deletions > 0:
            issues.append(f"{deletions} từ bị thiếu")
        if substitutions > 0:
            issues.append(f"{substitutions} từ bị sai")
        if insertions > 0:
            issues.append(f"{insertions} từ thừa")
        
        if issues:
            feedback_parts.append(f"Các vấn đề: {', '.join(issues)}.")
        
        if matches > 0:
            feedback_parts.append(f"Bạn đã phát âm đúng {matches} từ!")
    
    feedback_text = " ".join(feedback_parts)
    return feedback_text, tricky_words


def _build_pronunciation_feedback(
    pronunciation_result,
    expected_text: str
) -> Optional[PronunciationFeedback]:
    """Tạo pronunciation_feedback chi tiết từ pronunciation_result"""
    try:
        from services.pronunciation_model_service import LEADS, VOWELS, TAILS
        
        # Tạo phoneme_details
        phoneme_details = []
        expected_phonemes = pronunciation_result.expected_phonemes
        predicted_phonemes = pronunciation_result.predicted_phonemes
        
        # Tạo map của wrong phonemes để dễ tra cứu
        wrong_phoneme_map = {}
        for exp, pred in pronunciation_result.wrong_phonemes:
            # Tìm vị trí của wrong phoneme trong expected_phonemes
            for idx, exp_phn in enumerate(expected_phonemes):
                if exp_phn == exp and idx not in wrong_phoneme_map:
                    wrong_phoneme_map[idx] = pred
                    break
        
        # Xử lý từng phoneme expected
        max_len = max(len(expected_phonemes), len(predicted_phonemes))
        for i in range(max_len):
            exp_phn = expected_phonemes[i] if i < len(expected_phonemes) else None
            pred_phn = predicted_phonemes[i] if i < len(predicted_phonemes) else None
            
            if exp_phn is None:
                # Insertion - phoneme thừa
                phoneme_details.append(PhonemeDetail(
                    position=i,
                    expected="",
                    predicted=pred_phn,
                    type=_classify_phoneme(pred_phn) if pred_phn else "other",
                    is_correct=False,
                    is_extra=True
                ))
            elif pred_phn is None:
                # Deletion - phoneme thiếu
                phoneme_details.append(PhonemeDetail(
                    position=i,
                    expected=exp_phn,
                    predicted="",
                    type=_classify_phoneme(exp_phn),
                    is_correct=False,
                    is_missing=True
                ))
            else:
                # So sánh expected vs predicted
                is_correct = exp_phn == pred_phn
                # Nếu không đúng, có thể là substitution
                if not is_correct and i in wrong_phoneme_map:
                    pred_phn = wrong_phoneme_map[i]
                
                phoneme_details.append(PhonemeDetail(
                    position=i,
                    expected=exp_phn,
                    predicted=pred_phn,
                    type=_classify_phoneme(exp_phn),
                    is_correct=is_correct
                ))
        
        # Phân tích từng từ với phoneme details
        word_feedback_list = []
        words = expected_text.split()
        
        # Map phonemes to words (simplified - mỗi từ có ~3 phonemes: initial, vowel, final)
        phoneme_idx = 0
        for word_idx, word in enumerate(words):
            # Ước tính số phoneme trong từ này (mỗi ký tự Hangul = 2-3 phonemes)
            word_phoneme_count = len(word) * 2  # Ước tính
            word_phonemes = []
            
            for i in range(min(word_phoneme_count, len(phoneme_details) - phoneme_idx)):
                if phoneme_idx + i < len(phoneme_details):
                    phn_detail = phoneme_details[phoneme_idx + i]
                    word_phonemes.append(phn_detail)
            
            # Tính accuracy cho từ này
            if word_phonemes:
                correct_count = sum(1 for p in word_phonemes if p.is_correct)
                word_accuracy = (correct_count / len(word_phonemes)) * 100
            else:
                word_accuracy = 0
            
            word_feedback_list.append(WordFeedback(
                word=word,
                position=word_idx,
                phonemes=word_phonemes,
                accuracy=round(word_accuracy, 1),
                is_correct=word_accuracy >= 80  # Threshold 80%
            ))
            
            phoneme_idx += len(word_phonemes)
        
        # Tạo wrong_phonemes với feedback
        wrong_phonemes_list = []
        for i, (exp, pred) in enumerate(pronunciation_result.wrong_phonemes):
            wrong_phonemes_list.append({
                "expected": exp,
                "predicted": pred,
                "position": i,
                "type": _classify_phoneme(exp),
                "is_correct": False,
                "feedback": f"Phát âm '{exp}' thành '{pred}'. Cần luyện tập {'phụ âm đầu' if _classify_phoneme(exp) == 'initial' else 'nguyên âm' if _classify_phoneme(exp) == 'vowel' else 'phụ âm cuối'}."
            })
        
        # Tạo summary
        summary = PronunciationFeedbackSummary(
            total_phonemes=len(expected_phonemes),
            correct_phonemes=pronunciation_result.matches,
            wrong_phonemes=pronunciation_result.substitutions,
            missing_phonemes=pronunciation_result.deletions,
            extra_phonemes=pronunciation_result.insertions,
            initial_errors=sum(1 for p in phoneme_details if p.type == "initial" and not p.is_correct),
            vowel_errors=sum(1 for p in phoneme_details if p.type == "vowel" and not p.is_correct),
            final_errors=sum(1 for p in phoneme_details if p.type == "final" and not p.is_correct)
        )
        
        return PronunciationFeedback(
            phoneme_accuracy=pronunciation_result.phoneme_accuracy,
            per=pronunciation_result.per,
            phoneme_details=phoneme_details,
            word_feedback=word_feedback_list,
            wrong_phonemes=wrong_phonemes_list,
            expected_phonemes=expected_phonemes,
            predicted_phonemes=predicted_phonemes,
            wrong_words=pronunciation_result.wrong_words,
            matches=pronunciation_result.matches,
            substitutions=pronunciation_result.substitutions,
            insertions=pronunciation_result.insertions,
            deletions=pronunciation_result.deletions,
            summary=summary
        )
    except Exception as e:
        logger.error(f"Error building pronunciation feedback: {e}")
        return None


@router.post("/speaking/read-aloud", response_model=ReadAloudResponse)
async def check_read_aloud(
    audio: UploadFile = File(..., description="Audio file (webm, mp3, wav)"),
    expected_text: str = Form(..., description="The Korean text the user should read"),
    language: str = Form(default="ko", description="Language code (ko for Korean)")
):
    """
    Đánh giá phát âm tiếng Hàn khi đọc to
    Sử dụng LOCAL models - KHÔNG dùng OpenAI API
    
    FLOW:
    =====
    1. Người dùng bấm mic → ghi âm (5 giây) → file .m4a
    2. Flutter gửi file audio lên backend (FastAPI/Python)
    3. Backend xử lý:
       a. ⭐ PHẦN CHÍNH - Dùng pronunciation_model.pt để tính điểm:
          - Audio → Wav2Vec2 features → Conformer model → predicted_phonemes
          - expected_text → hangul_g2p() → expected_phonemes
          - So sánh predicted_phonemes vs expected_phonemes → tính điểm + tìm lỗi
          - ĐÂY LÀ CÁCH TÍNH ĐIỂM PHÁT ÂM - KHÔNG CẦN TRANSCRIPT!
       
       b. (OPTIONAL) Dùng LOCAL Whisper → chuyển audio thành text (transcript)
          - Chỉ để hiển thị cho user biết họ nói gì
          - Tính word accuracy (bổ sung, KHÔNG phải điểm chính)
          - Nếu Whisper fail, vẫn tính được điểm từ pronunciation model
       
    4. Trả về JSON với:
       - overall_score: điểm tổng (từ phoneme_accuracy - điểm chính)
       - phoneme_accuracy: độ chính xác phoneme (từ pronunciation_model.pt)
       - pronunciation_feedback: chi tiết từng phoneme, từng từ
       - transcript: text người dùng đã nói (optional, chỉ để hiển thị)
    5. Flutter nhận JSON → vẽ giao diện đẹp (highlight lỗi, vòng tròn điểm, animation)

    Supported audio formats: webm, mp3, wav, m4a
    """
    try:
        logger.info(f"Read-aloud check - Expected: '{expected_text[:50]}...', Audio: {audio.filename}")

        # ============================================
        # STEP 1: Transcribe audio → Text (OPTIONAL - chỉ để hiển thị)
        # ============================================
        # ⚠️ QUAN TRỌNG: Transcript KHÔNG được dùng để tính điểm phát âm!
        # 
        # Điểm phát âm được tính HOÀN TOÀN từ pronunciation_model.pt:
        # - Audio → pronunciation_model.pt → predicted phonemes
        # - expected_text → hangul_g2p() → expected phonemes  
        # - So sánh predicted vs expected → điểm
        #
        # Transcript chỉ để:
        # - Hiển thị cho user biết họ nói gì (UI feedback)
        # - Tính word accuracy (bổ sung, KHÔNG phải điểm chính)
        transcript = ""
        try:
            transcript = await transcribe_audio_cheap(
                file=audio,
                language=language
            )
            logger.info(f"✅ Transcript (người dùng nói): '{transcript}'")
        except Exception as e:
            logger.warning(f"⚠️ Transcript failed (KHÔNG ảnh hưởng điểm phát âm): {e}")
            # Transcript không bắt buộc, tiếp tục với pronunciation model

        # ============================================
        # STEP 2: Dùng pronunciation_model.pt → Dự đoán phoneme (PHẦN CHÍNH - TÍNH ĐIỂM)
        # ============================================
        # ⭐ ĐÂY LÀ PHẦN QUAN TRỌNG NHẤT - Tính điểm phát âm:
        # 
        # Flow tính điểm:
        # 1. Audio → Wav2Vec2 features (extract acoustic features từ audio)
        # 2. pronunciation_model.pt (Conformer) → dự đoán chuỗi phoneme từ audio
        #    → predicted_phonemes = ["ㅇ", "ㅏ", "ㄴ", ...] (từ audio trực tiếp)
        # 3. expected_text → hangul_g2p() → phoneme chuẩn
        #    → expected_phonemes = ["ㅇ", "ㅏ", "ㄴ", ...] (từ text)
        # 4. So sánh predicted_phonemes vs expected_phonemes → tính điểm + tìm lỗi
        # 
        # ⚠️ KHÔNG CẦN TRANSCRIPT - Model tự dự đoán phonemes từ audio!
        # Transcript chỉ để hiển thị, không ảnh hưởng điểm phát âm
        model_result = None
        phoneme_accuracy = None
        per = None
        pronunciation_result = None
        pronunciation_feedback_obj = None
        
        if get_model_status():
            try:
                # Đọc audio bytes từ file đã upload
                audio_bytes = await audio.read()
                await audio.seek(0)  # Reset file pointer để có thể dùng lại
                
                # Gọi pronunciation model để dự đoán phoneme và so sánh
                pronunciation_result = check_pronunciation_from_bytes(
                    audio_bytes=audio_bytes,
                    expected_text=expected_text,  # Text chuẩn để tạo phoneme chuẩn
                    sample_rate=16000,
                    audio_format=Path(audio.filename).suffix[1:] if audio.filename else "wav"
                )
                
                if pronunciation_result:
                    # Lưu kết quả từ model
                    model_result = {
                        "phoneme_accuracy": pronunciation_result.phoneme_accuracy,
                        "per": pronunciation_result.per,
                        "wrong_phonemes": pronunciation_result.wrong_phonemes,
                        "wrong_words": pronunciation_result.wrong_words,
                        "matches": pronunciation_result.matches,
                        "substitutions": pronunciation_result.substitutions,
                        "insertions": pronunciation_result.insertions,
                        "deletions": pronunciation_result.deletions
                    }
                    phoneme_accuracy = pronunciation_result.phoneme_accuracy
                    per = pronunciation_result.per
                    logger.info(f"✅ Pronunciation model check: {phoneme_accuracy:.1f}% accuracy, PER: {per:.4f}")
                    
                    # Tạo pronunciation_feedback chi tiết (từng phoneme, từng từ)
                    pronunciation_feedback_obj = _build_pronunciation_feedback(
                        pronunciation_result=pronunciation_result,
                        expected_text=expected_text
                    )
                else:
                    logger.warning("⚠️ Model check returned None, falling back to word accuracy")
            except Exception as e:
                logger.error(f"❌ Error in pronunciation model check: {e}. Falling back to word accuracy.", exc_info=True)
        
        # ============================================
        # STEP 3: Tính word-level accuracy (BỔ SUNG - không phải điểm chính)
        # ============================================
        # So sánh transcript (người dùng nói) vs expected_text (chuẩn)
        # ⚠️ LƯU Ý: Điểm chính là phoneme_accuracy từ model, không phải word_accuracy
        # Word accuracy chỉ để bổ sung thông tin, không ảnh hưởng overall_score
        word_accuracy = 0.0
        details = {}
        if transcript:
            try:
                word_accuracy, details = accuracy_service.calculate_word_accuracy(
                    expected_text=expected_text,
                    spoken_text=transcript,
                    ignore_fillers=True
                )
                logger.info(f"✅ Word accuracy (bổ sung): {word_accuracy}%")
            except Exception as e:
                logger.warning(f"⚠️ Word accuracy calculation failed: {e} (không ảnh hưởng điểm chính)")
                # Không ảnh hưởng điểm phát âm

        # ============================================
        # STEP 4: Tạo feedback bằng tiếng Việt (LOCAL, không dùng GPT)
        # ============================================
        feedback_vi, tricky_words = _generate_local_feedback_vi(
            expected_text=expected_text,
            spoken_text=transcript,
            phoneme_accuracy=phoneme_accuracy,
            word_accuracy=word_accuracy,
            model_result=model_result,
            accuracy_details=details
        )
        logger.info(f"Feedback tiếng Việt (local): '{feedback_vi[:50]}...'")

        # Step 5: Generate TTS cho feedback (optional - won't fail if error)
        tts_vi_path = await generate_speech(
            text=feedback_vi,
            lang="vi",  # Vietnamese feedback
            allow_failure=True  # Don't fail the whole request if TTS fails
        )
        tts_vi_url = f"/media/{Path(tts_vi_path).name}" if tts_vi_path else None
        if tts_vi_url:
            logger.info(f"VI TTS generated: {tts_vi_url}")

        # Step 6: Calculate overall score
        # Ưu tiên model score nếu có, nếu không dùng word accuracy
        if phoneme_accuracy is not None:
            # Model có độ chính xác cao hơn, dùng làm chính
            overall_score = phoneme_accuracy
            logger.info(f"Using model phoneme accuracy as overall score: {overall_score:.1f}%")
        else:
            # Fallback: dùng word accuracy
            overall_score = word_accuracy
            logger.info(f"Using word accuracy as overall score: {overall_score:.1f}%")

        # Determine emotion tag
        if overall_score >= 85:
            emotion_tag = "praise"
        elif overall_score >= 70:
            emotion_tag = "encouraging"
        else:
            emotion_tag = "corrective"

        # Build accuracy details
        # Nếu có model result, ưu tiên dùng thông tin từ model
        if model_result:
            accuracy_details_obj = AccuracyDetails(
                word_accuracy=phoneme_accuracy,  # Dùng phoneme accuracy từ model
                wer=per,  # Dùng PER từ model
                matches=model_result.get("matches", 0),
                substitutions=model_result.get("substitutions", 0),
                insertions=model_result.get("insertions", 0),
                deletions=model_result.get("deletions", 0),
                expected_words=details.get("expected_words", []),  # Giữ word list từ accuracy service
                spoken_words=details.get("spoken_words", [])
            )
        else:
            accuracy_details_obj = AccuracyDetails(
                word_accuracy=word_accuracy,
                wer=details.get("wer", 1.0),
                matches=details.get("matches", 0),
                substitutions=details.get("substitutions", 0),
                insertions=details.get("insertions", 0),
                deletions=details.get("deletions", 0),
                expected_words=details.get("expected_words", []),
                spoken_words=details.get("spoken_words", [])
            )

        # ============================================
        # STEP 5: Trả về JSON response
        # ============================================
        # JSON này sẽ được Flutter nhận để vẽ giao diện:
        # - overall_score: điểm tổng (vẽ vòng tròn điểm)
        # - pronunciation_feedback: chi tiết từng phoneme (highlight lỗi)
        # - transcript: text người dùng đã nói
        # - feedback_vi: feedback bằng tiếng Việt
        ai_feedback_combined = feedback_vi

        logger.info(f"✅ Returning response - Overall score: {overall_score:.1f}%, Phoneme accuracy: {phoneme_accuracy}%")
        return ReadAloudResponse(
            transcript=transcript,
            expected_text=expected_text,
            word_accuracy=word_accuracy,
            ai_feedback=ai_feedback_combined,  # Legacy field
            overall_score=overall_score,
            emotion_tag=emotion_tag,
            accuracy_details=accuracy_details_obj,
            feedback_en="",  # Không dùng nữa, để trống
            feedback_vi=feedback_vi,
            tts_en_url=None,  # Không dùng nữa
            tts_vi_url=tts_vi_url,
            tricky_words=tricky_words,
            tts_url=None,
            pronunciation_feedback=pronunciation_feedback_obj  # Chi tiết từng phoneme, từng từ
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in check_read_aloud: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail=f"Lỗi khi đánh giá phát âm: {str(e)}"
        )


@router.get("/speaking/phrases")
async def get_korean_phrases(
    category: Optional[str] = None,
    difficulty: Optional[str] = None
):
    """
    Get Korean phrases and terms for pronunciation practice
    
    Args:
        category: Filter by category (greetings, food, etc.)
        difficulty: Filter by difficulty (beginner, intermediate, advanced)
    
    Returns:
        List of Korean phrases organized by category
    """
    try:
        import json
        from pathlib import Path
        
        phrases_file = Path("models/korean_phrases.json")
        if not phrases_file.exists():
            logger.warning("Korean phrases file not found")
            return {
                "categories": {},
                "difficulty_levels": {},
                "message": "Phrases file not found"
            }
        
        with open(phrases_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Filter by category if provided
        if category:
            if category in data.get("categories", {}):
                return {
                    "category": category,
                    "name": data["categories"][category]["name"],
                    "phrases": data["categories"][category]["phrases"]
                }
            else:
                raise HTTPException(
                    status_code=404,
                    detail=f"Category '{category}' not found"
                )
        
        # Filter by difficulty if provided
        if difficulty:
            if difficulty in data.get("difficulty_levels", {}):
                level_data = data["difficulty_levels"][difficulty]
                categories = level_data.get("categories", [])
                filtered_categories = {
                    cat: data["categories"][cat]
                    for cat in categories
                    if cat in data.get("categories", {})
                }
                return {
                    "difficulty": difficulty,
                    "description": level_data.get("description", ""),
                    "categories": filtered_categories
                }
            else:
                raise HTTPException(
                    status_code=404,
                    detail=f"Difficulty level '{difficulty}' not found"
                )
        
        # Return all data
        return data
        
    except json.JSONDecodeError as e:
        logger.error(f"Error parsing phrases JSON: {e}")
        raise HTTPException(
            status_code=500,
            detail="Error reading phrases file"
        )
    except Exception as e:
        logger.error(f"Error getting phrases: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error getting phrases: {str(e)}"
        )


@router.get("/speaking/model-status")
async def get_model_status_endpoint():
    """
    Check if pronunciation model is loaded and ready
    
    Returns:
        Status information about the pronunciation model
    """
    try:
        # Check current status
        model_loaded = get_model_status()
        logger.info(f"Model status check - loaded: {model_loaded}")
        
        # If not loaded, try to load it
        if not model_loaded:
            logger.info("Model not loaded, attempting to load...")
            from services.pronunciation_model_service import load_pronunciation_model
            try:
                loaded = load_pronunciation_model()
                if loaded:
                    logger.info("✅ Model loaded successfully on demand")
                    model_loaded = True
                else:
                    logger.warning("⚠️ Failed to load model on demand")
                    # Check if files exist
                    from pathlib import Path
                    model_path = Path("models/pronunciation_model.pt")
                    p2id_path = Path("models/p2id.json")
                    stats_path = Path("models/wav2vec2_stats.npy")
                    
                    files_exist = {
                        "model_file": model_path.exists(),
                        "p2id_file": p2id_path.exists(),
                        "stats_file": stats_path.exists()
                    }
                    logger.info(f"Model files status: {files_exist}")
            except Exception as load_error:
                logger.error(f"Error loading model on demand: {load_error}", exc_info=True)
        
        # Double check after loading attempt
        model_loaded = get_model_status()
        
        return {
            "model_loaded": model_loaded,
            "status": "ready" if model_loaded else "not_available",
            "message": "Pronunciation model is loaded and ready" if model_loaded else "Pronunciation model not available. Will use word-level accuracy only.",
            "available": model_loaded  # Alias for frontend compatibility
        }
    except Exception as e:
        logger.error(f"Error checking model status: {e}", exc_info=True)
        return {
            "model_loaded": False,
            "status": "error",
            "message": f"Error checking model status: {str(e)}",
            "available": False
        }


@router.post("/speaking/free-speak", response_model=FreeSpeakResponse)
async def check_free_speaking(
    audio: UploadFile = File(..., description="Audio file"),
    context: Optional[str] = Form(default=None, description="Conversation context"),
    language: str = Form(default="ko", description="Language code (ko for Korean)"),
    history: Optional[str] = Form(default=None, description="JSON array of conversation history for context")
):
    """
    Free-form Korean speaking practice với Coach Ivy - Cuộc hội thoại tự nhiên
    
    Flow:
    1. User nói → Whisper (STT) → Text
    2. Text → GPT → Phản hồi bằng tiếng Hàn (như một cuộc hội thoại)
    3. Phản hồi text → TTS → Speech để user nghe được
    
    This endpoint allows natural conversation in Korean.
    GPT will respond in Korean like a real conversation partner.
    """
    try:
        logger.info(f"Free-speak request - Audio: {audio.filename}, Language: {language}")
        
        # Step 1: Transcribe user's speech using LOCAL Whisper (FREE, không tốn quota)
        # Fallback to OpenAI Whisper only if local fails
        transcript = await transcribe_audio_cheap(
            file=audio,
            language=language
        )
        logger.info(f"User said: '{transcript}'")

        if not transcript.strip():
            raise HTTPException(
                status_code=400,
                detail="Could not transcribe audio. Please try speaking again."
            )

        # Step 2: Parse conversation history if provided (for context)
        conversation_context = None
        if history:
            try:
                import json
                history_messages = json.loads(history)
                if history_messages:
                    # Build context from history
                    conversation_context = {
                        "type": "speaking_practice",
                        "history": history_messages[-5:],  # Last 5 messages for context
                        "context": context
                    }
            except json.JSONDecodeError:
                logger.warning("Invalid history JSON, continuing without history")

        # Step 3: Check pronunciation với model (nếu có) - giống live_talk
        pronunciation_result = None
        pronunciation_feedback = None
        pronunciation_accuracy = None
        
        if get_model_status():
            try:
                # Đọc audio bytes
                audio_bytes = await audio.read()
                await audio.seek(0)  # Reset file pointer
                
                # Check pronunciation với model
                pronunciation_result = check_pronunciation_from_bytes(
                    audio_bytes=audio_bytes,
                    expected_text=transcript,  # So sánh với transcript từ STT
                    sample_rate=16000,
                    audio_format=Path(audio.filename).suffix[1:] if audio.filename else "wav"
                )
                
                if pronunciation_result:
                    pronunciation_accuracy = pronunciation_result.phoneme_accuracy
                    
                    # Tạo phản hồi chi tiết về từng phoneme (phụ âm, nguyên âm, nguyên âm cuối)
                    from services.pronunciation_model_service import LEADS, VOWELS, TAILS
                    
                    # Phân loại phoneme thành phụ âm, nguyên âm, nguyên âm cuối
                    def classify_phoneme(phoneme: str) -> str:
                        """Phân loại phoneme: initial (phụ âm đầu), vowel (nguyên âm), final (phụ âm cuối)"""
                        if phoneme in LEADS:
                            return "initial"  # Phụ âm đầu
                        elif phoneme in VOWELS:
                            return "vowel"  # Nguyên âm
                        elif phoneme in TAILS:
                            return "final"  # Phụ âm cuối
                        else:
                            return "other"
                    
                    # Tạo danh sách phoneme với thông tin chi tiết
                    phoneme_details = []
                    
                    # Tạo map của wrong phonemes để dễ tra cứu
                    wrong_phoneme_map = {}
                    for exp, pred in pronunciation_result.wrong_phonemes:
                        # Tìm vị trí của wrong phoneme trong expected_phonemes
                        for idx, exp_phn in enumerate(pronunciation_result.expected_phonemes):
                            if exp_phn == exp and idx not in wrong_phoneme_map:
                                wrong_phoneme_map[idx] = pred
                                break
                    
                    # Xử lý từng phoneme expected
                    max_len = max(len(pronunciation_result.expected_phonemes), len(pronunciation_result.predicted_phonemes))
                    for i in range(max_len):
                        exp_phn = pronunciation_result.expected_phonemes[i] if i < len(pronunciation_result.expected_phonemes) else None
                        pred_phn = pronunciation_result.predicted_phonemes[i] if i < len(pronunciation_result.predicted_phonemes) else None
                        
                        if exp_phn is None:
                            # Insertion - phoneme thừa
                            phoneme_details.append({
                                "position": i,
                                "expected": "",
                                "predicted": pred_phn,
                                "type": classify_phoneme(pred_phn) if pred_phn else "other",
                                "is_correct": False,
                                "is_extra": True
                            })
                        elif pred_phn is None:
                            # Deletion - phoneme thiếu
                            phoneme_details.append({
                                "position": i,
                                "expected": exp_phn,
                                "predicted": "",
                                "type": classify_phoneme(exp_phn),
                                "is_correct": False,
                                "is_missing": True
                            })
                        else:
                            # So sánh expected vs predicted
                            is_correct = exp_phn == pred_phn
                            # Nếu không đúng, có thể là substitution
                            if not is_correct and i in wrong_phoneme_map:
                                pred_phn = wrong_phoneme_map[i]
                            
                            phoneme_details.append({
                                "position": i,
                                "expected": exp_phn,
                                "predicted": pred_phn,
                                "type": classify_phoneme(exp_phn),  # initial, vowel, final
                                "is_correct": is_correct
                            })
                    
                    # Phân tích từng từ với phoneme details
                    word_feedback_list = []
                    words = transcript.split()
                    
                    # Map phonemes to words (simplified - mỗi từ có ~3 phonemes: initial, vowel, final)
                    phoneme_idx = 0
                    for word_idx, word in enumerate(words):
                        # Ước tính số phoneme trong từ này (mỗi ký tự Hangul = 2-3 phonemes)
                        word_phoneme_count = len(word) * 2  # Ước tính
                        word_phonemes = []
                        
                        for i in range(min(word_phoneme_count, len(phoneme_details) - phoneme_idx)):
                            if phoneme_idx + i < len(phoneme_details):
                                phn_detail = phoneme_details[phoneme_idx + i]
                                word_phonemes.append(phn_detail)
                        
                        # Tính accuracy cho từ này
                        if word_phonemes:
                            correct_count = sum(1 for p in word_phonemes if p.get("is_correct", False))
                            word_accuracy = (correct_count / len(word_phonemes)) * 100
                        else:
                            word_accuracy = 0
                        
                        word_feedback_list.append({
                            "word": word,
                            "position": word_idx,
                            "phonemes": word_phonemes,
                            "accuracy": round(word_accuracy, 1),
                            "is_correct": word_accuracy >= 80  # Threshold 80%
                        })
                        
                        phoneme_idx += len(word_phonemes)
                    
                    # Tạo phản hồi chi tiết với phân tích từng phoneme
                    pronunciation_feedback = {
                        "phoneme_accuracy": pronunciation_result.phoneme_accuracy,
                        "per": pronunciation_result.per,
                        "phoneme_details": phoneme_details,  # Chi tiết từng phoneme với type (initial/vowel/final)
                        "word_feedback": word_feedback_list,  # Phản hồi từng từ
                        "wrong_phonemes": [
                            {
                                "expected": exp,
                                "predicted": pred,
                                "position": i,
                                "type": classify_phoneme(exp),  # initial, vowel, final
                                "is_correct": False,
                                "feedback": f"Phát âm '{exp}' thành '{pred}'. Cần luyện tập {'phụ âm đầu' if classify_phoneme(exp) == 'initial' else 'nguyên âm' if classify_phoneme(exp) == 'vowel' else 'phụ âm cuối'}."
                            }
                            for i, (exp, pred) in enumerate(pronunciation_result.wrong_phonemes)
                        ],
                        "expected_phonemes": pronunciation_result.expected_phonemes,
                        "predicted_phonemes": pronunciation_result.predicted_phonemes,
                        "wrong_words": pronunciation_result.wrong_words,
                        "matches": pronunciation_result.matches,
                        "substitutions": pronunciation_result.substitutions,
                        "insertions": pronunciation_result.insertions,
                        "deletions": pronunciation_result.deletions,
                        "summary": {
                            "total_phonemes": len(pronunciation_result.expected_phonemes),
                            "correct_phonemes": pronunciation_result.matches,
                            "wrong_phonemes": pronunciation_result.substitutions,
                            "missing_phonemes": pronunciation_result.deletions,
                            "extra_phonemes": pronunciation_result.insertions,
                            "initial_errors": sum(1 for p in phoneme_details if p.get("type") == "initial" and not p.get("is_correct", True)),
                            "vowel_errors": sum(1 for p in phoneme_details if p.get("type") == "vowel" and not p.get("is_correct", True)),
                            "final_errors": sum(1 for p in phoneme_details if p.get("type") == "final" and not p.get("is_correct", True))
                        }
                    }
                    
                    logger.info(f"✅ Pronunciation check: {pronunciation_accuracy:.1f}% accuracy, PER: {pronunciation_result.per:.4f}")
                    logger.info(f"   Wrong phonemes: {len(pronunciation_result.wrong_phonemes)}")
                else:
                    logger.warning("Pronunciation model check returned None")
            except Exception as e:
                logger.error(f"Error in pronunciation check: {e}. Continuing without pronunciation feedback.")

        # Step 4: Get conversational response from Coach Ivy (GPT)
        # GPT will respond in Korean like a real conversation
        # Include pronunciation feedback in context if available
        gpt_context = conversation_context or ({"type": "speaking_practice", "context": context} if context else None)
        if pronunciation_feedback:
            if gpt_context is None:
                gpt_context = {}
            gpt_context["pronunciation_feedback"] = {
                "accuracy": pronunciation_accuracy,
                "wrong_phonemes_count": len(pronunciation_feedback.get("wrong_phonemes", [])),
                "wrong_words": pronunciation_feedback.get("wrong_words", [])
            }
        
        reply, emotion_tag = await openai_service.chat_with_coach(
            message=transcript,
            mode="free_chat",
            context=gpt_context
        )
        
        # Log full reply for debugging
        logger.info(f"Coach Ivy replied (Korean, full): '{reply}'")
        logger.info(f"Coach Ivy replied (Korean, preview): '{reply[:100]}...'")
        logger.info(f"Reply length: {len(reply)} chars, emotion: {emotion_tag}")

        # Step 5: Generate TTS for Coach's response (Speech)
        # Coach responses are typically in Korean, so use "ko" language
        # Use allow_failure=True to gracefully handle TTS errors
        tts_path = await generate_speech(
            text=reply,
            lang="ko",  # Korean for Coach responses
            allow_failure=True  # Don't fail the whole request if TTS fails
        )
        
        tts_url = None
        if tts_path:
            tts_url = f"/media/{Path(tts_path).name}"
            logger.info(f"TTS generated: {tts_url}")
        else:
            logger.warning("TTS generation failed, but continuing with text response")

        # Return response with proper model
        response_data = FreeSpeakResponse(
            transcript=transcript,
            reply=reply,
            emotion_tag=emotion_tag,
            tts_url=tts_url,
            pronunciation_feedback=pronunciation_feedback,
            pronunciation_accuracy=pronunciation_accuracy
        )
        
        # Log response for debugging
        logger.info(f"Returning response - transcript: '{transcript}', reply: '{reply[:50]}...'")
        logger.info(f"   Pronunciation accuracy: {pronunciation_accuracy}%, tts_url: {tts_url}")
        
        return response_data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in check_free_speaking: {e}")
        # Use error handler for OpenAI errors (429, etc.)
        raise handle_openai_error(e, service_name="Free speaking")
