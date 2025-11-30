"""
Vocabulary Lookup Service
Tìm từ vựng trong file jsonl hoặc dùng GPT để tra từ
"""
import json
import logging
from pathlib import Path
from typing import Dict, Any, Optional, List
from openai import OpenAI
from config import settings

logger = logging.getLogger(__name__)

# Initialize OpenAI client
client = OpenAI(api_key=settings.openai_api_key)

# Path to vocabulary file
VOCAB_FILE = Path(__file__).parent.parent / "korean_vietnamese_train_data_by_phuc.jsonl"

# Cache for loaded vocabulary (lazy loading)
_vocab_cache: Optional[List[Dict[str, Any]]] = None


def load_vocabulary_file() -> List[Dict[str, Any]]:
    """
    Load vocabulary from jsonl file (lazy loading with cache)
    
    Returns:
        List of vocabulary entries
    """
    global _vocab_cache
    
    if _vocab_cache is not None:
        return _vocab_cache
    
    vocab_list = []
    
    try:
        if not VOCAB_FILE.exists():
            logger.warning(f"Vocabulary file not found: {VOCAB_FILE}")
            return []
        
        with open(VOCAB_FILE, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                    vocab_list.append(entry)
                except json.JSONDecodeError as e:
                    logger.warning(f"Failed to parse line in vocabulary file: {e}")
                    continue
        
        _vocab_cache = vocab_list
        logger.info(f"Loaded {len(vocab_list)} vocabulary entries from file")
        
    except Exception as e:
        logger.error(f"Error loading vocabulary file: {e}")
        return []
    
    return vocab_list


def search_vocabulary_in_file(word: str) -> Optional[Dict[str, Any]]:
    """
    Tìm từ vựng trong file jsonl
    
    Args:
        word: Từ tiếng Hàn cần tìm
        
    Returns:
        Dictionary với thông tin từ vựng nếu tìm thấy, None nếu không tìm thấy
    """
    vocab_list = load_vocabulary_file()
    
    # Tìm chính xác
    for entry in vocab_list:
        if entry.get('source', '').strip() == word.strip():
            return {
                'word': entry.get('source', ''),
                'vietnamese': entry.get('target', ''),
                'vi_word': entry.get('meta', {}).get('vi_word', ''),
                'vi_def': entry.get('meta', {}).get('vi_def', ''),
                'source': 'file'
            }
    
    # Tìm không phân biệt hoa thường
    word_lower = word.strip().lower()
    for entry in vocab_list:
        if entry.get('source', '').strip().lower() == word_lower:
            return {
                'word': entry.get('source', ''),
                'vietnamese': entry.get('target', ''),
                'vi_word': entry.get('meta', {}).get('vi_word', ''),
                'vi_def': entry.get('meta', {}).get('vi_def', ''),
                'source': 'file'
            }
    
    return None


def lookup_word_with_gpt(word: str) -> Dict[str, Any]:
    """
    Dùng GPT để tra từ vựng tiếng Hàn
    
    Args:
        word: Từ tiếng Hàn cần tra
        
    Returns:
        Dictionary với thông tin từ vựng từ GPT
    """
    try:
        prompt = f"""Bạn là một từ điển tiếng Hàn - Việt chuyên nghiệp. Hãy giải thích từ "{word}" bằng tiếng Việt.

Yêu cầu:
1. Dịch nghĩa từ sang tiếng Việt (nếu có nhiều nghĩa, liệt kê các nghĩa phổ biến)
2. Giải thích ngắn gọn nghĩa của từ (1-2 câu)
3. Nếu có thể, đưa ra 1 ví dụ câu sử dụng từ này

Định dạng trả lời:
- Nghĩa: [nghĩa tiếng Việt]
- Giải thích: [giải thích ngắn gọn]
- Ví dụ: [ví dụ câu nếu có]

Hãy trả lời bằng tiếng Việt, ngắn gọn và dễ hiểu."""

        response = client.chat.completions.create(
            model=settings.openai_model_name,
            messages=[
                {"role": "system", "content": "Bạn là một từ điển tiếng Hàn - Việt chuyên nghiệp. Trả lời ngắn gọn, rõ ràng."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=300,
            temperature=0.3
        )
        
        gpt_response = response.choices[0].message.content.strip()
        
        return {
            'word': word,
            'vietnamese': gpt_response,
            'vi_word': '',
            'vi_def': '',
            'source': 'gpt',
            'gpt_response': gpt_response
        }
        
    except Exception as e:
        logger.error(f"Error looking up word with GPT: {e}")
        return {
            'word': word,
            'vietnamese': f'Không thể tra từ "{word}". Lỗi: {str(e)}',
            'vi_word': '',
            'vi_def': '',
            'source': 'gpt',
            'error': str(e)
        }


def lookup_word(word: str) -> Dict[str, Any]:
    """
    Tra từ vựng: tìm trong file trước, nếu không có thì dùng GPT
    
    Args:
        word: Từ tiếng Hàn cần tra
        
    Returns:
        Dictionary với thông tin từ vựng
    """
    # Tìm trong file trước
    result = search_vocabulary_in_file(word)
    
    if result:
        logger.info(f"Found word '{word}' in vocabulary file")
        return result
    
    # Nếu không tìm thấy, dùng GPT
    logger.info(f"Word '{word}' not found in file, using GPT")
    return lookup_word_with_gpt(word)


# ===== DICTIONARY SERVICE FUNCTIONS =====
# These functions provide dictionary API format compatibility

def search_dictionary(query: str, limit: int = 10) -> List[Dict[str, Any]]:
    """
    Search Korean-Vietnamese dictionary (dictionary API format)
    
    Args:
        query: Korean word to search for
        limit: Maximum number of results
        
    Returns:
        List of dictionary entries in dictionary API format
    """
    try:
        # Use vocabulary lookup service to search
        result = lookup_word(query)
        
        if result:
            # Format as dictionary entry
            return [{
                "source": result.get("word", query),
                "target": result.get("vietnamese", ""),
                "meta": {
                    "vi_word": result.get("vi_word", ""),
                    "vi_def": result.get("vi_def", ""),
                    "pronunciation": result.get("pronunciation", ""),
                }
            }]
        
        return []
    except Exception as e:
        logger.error(f"Error searching dictionary: {e}")
        return []


def get_dictionary_entry(korean_word: str) -> Optional[Dict[str, Any]]:
    """
    Get exact dictionary entry for a Korean word (dictionary API format)
    
    Args:
        korean_word: Korean word to look up
        
    Returns:
        Dictionary entry if found, None otherwise (in dictionary API format)
    """
    try:
        result = lookup_word(korean_word)
        
        if result:
            return {
                "source": result.get("word", korean_word),
                "target": result.get("vietnamese", ""),
                "meta": {
                    "vi_word": result.get("vi_word", ""),
                    "vi_def": result.get("vi_def", ""),
                    "pronunciation": result.get("pronunciation", ""),
                    "source": result.get("source", "unknown"),
                }
            }
        
        return None
    except Exception as e:
        logger.error(f"Error getting dictionary entry: {e}")
        return None


def translate_text_with_dictionary(text: str, max_words: int = 50) -> Dict[str, Any]:
    """
    Extract vocabulary from Korean text and translate using dictionary
    
    Args:
        text: Korean text to translate
        max_words: Maximum number of words to translate
        
    Returns:
        Dictionary with original text, extracted words, and translations
    """
    try:
        # Simple implementation: split text and lookup each word
        words = text.split()
        translations = []
        
        for word in words[:max_words]:
            word = word.strip('.,!?;:()[]{}"\'').strip()
            if not word:
                continue
                
            entry = get_dictionary_entry(word)
            if entry:
                translations.append({
                    "word": word,
                    "translation": entry.get("target", ""),
                    "meta": entry.get("meta", {})
                })
        
        return {
            "original_text": text,
            "words": translations,
            "count": len(translations)
        }
    except Exception as e:
        logger.error(f"Error translating text: {e}")
        return {
            "original_text": text,
            "words": [],
            "count": 0
        }


def get_dictionary_stats() -> Dict[str, Any]:
    """
    Get statistics about the dictionary
    
    Returns:
        Dictionary with statistics
    """
    try:
        # Return basic stats
        # Note: This is a simple implementation
        # For full stats, would need to load and count all entries
        vocab_list = load_vocabulary_file()
        return {
            "total_entries": len(vocab_list) if vocab_list else 0,
            "source": "vocabulary_lookup_service",
            "file_path": str(VOCAB_FILE),
            "note": "Dictionary stats from vocabulary file"
        }
    except Exception as e:
        logger.error(f"Error getting dictionary stats: {e}")
        return {
            "error": str(e)
        }


