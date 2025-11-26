"""
Dictionary Service - Load and search Korean-Vietnamese dictionary from JSONL file
"""
import json
import logging
from pathlib import Path
from typing import List, Dict, Optional, Any
from functools import lru_cache

logger = logging.getLogger(__name__)

# Path to dictionary file
DICTIONARY_FILE = Path(__file__).parent.parent / "korean_vietnamese_train_data_by_phuc.jsonl"

# In-memory cache for dictionary
_dictionary_cache: Optional[List[Dict[str, Any]]] = None


def load_dictionary() -> List[Dict[str, Any]]:
    """
    Load dictionary from JSONL file into memory
    
    Returns:
        List of dictionary entries
    """
    global _dictionary_cache
    
    if _dictionary_cache is not None:
        return _dictionary_cache
    
    if not DICTIONARY_FILE.exists():
        logger.warning(f"Dictionary file not found: {DICTIONARY_FILE}")
        return []
    
    dictionary = []
    try:
        with open(DICTIONARY_FILE, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                    dictionary.append(entry)
                except json.JSONDecodeError as e:
                    logger.warning(f"Failed to parse line {line_num}: {e}")
                    continue
        
        _dictionary_cache = dictionary
        logger.info(f"Loaded {len(dictionary)} dictionary entries")
        return dictionary
    except Exception as e:
        logger.error(f"Error loading dictionary: {e}")
        return []


def search_dictionary(query: str, limit: int = 10) -> List[Dict[str, Any]]:
    """
    Search dictionary by Korean word (exact match or contains)
    
    Args:
        query: Korean word to search for
        limit: Maximum number of results to return
    
    Returns:
        List of matching dictionary entries
    """
    dictionary = load_dictionary()
    if not dictionary:
        return []
    
    query_lower = query.lower().strip()
    results = []
    
    for entry in dictionary:
        source = entry.get("source", "").lower()
        # Exact match first
        if source == query_lower:
            results.insert(0, entry)
        # Contains match
        elif query_lower in source:
            results.append(entry)
        
        if len(results) >= limit * 2:  # Get more than limit to prioritize exact matches
            break
    
    # Return limited results, prioritizing exact matches
    return results[:limit]


def get_dictionary_entry(korean_word: str) -> Optional[Dict[str, Any]]:
    """
    Get exact dictionary entry for a Korean word
    
    Args:
        korean_word: Korean word to look up
    
    Returns:
        Dictionary entry if found, None otherwise
    """
    dictionary = load_dictionary()
    if not dictionary:
        return None
    
    korean_word_lower = korean_word.lower().strip()
    
    for entry in dictionary:
        if entry.get("source", "").lower() == korean_word_lower:
            return entry
    
    return None


def extract_vocabulary_from_text(text: str, min_length: int = 2) -> List[str]:
    """
    Extract Korean words from text (simple word extraction)
    
    Args:
        text: Korean text
        min_length: Minimum word length
    
    Returns:
        List of unique Korean words found
    """
    # Simple word extraction - split by spaces and common punctuation
    import re
    # Extract Korean characters (Hangul)
    korean_words = re.findall(r'[가-힣]+', text)
    # Filter by length and get unique words
    unique_words = list(set([word for word in korean_words if len(word) >= min_length]))
    return unique_words


def translate_text_with_dictionary(text: str, max_words: int = 50) -> Dict[str, Any]:
    """
    Extract vocabulary from text and translate using dictionary
    
    Args:
        text: Korean text to translate
        max_words: Maximum number of words to translate
    
    Returns:
        Dictionary with original text, extracted words, and translations
    """
    words = extract_vocabulary_from_text(text)
    translations = []
    
    for word in words[:max_words]:
        entry = get_dictionary_entry(word)
        if entry:
            translations.append({
                "korean": entry.get("source"),
                "vietnamese": entry.get("meta", {}).get("vi_word", ""),
                "definition": entry.get("meta", {}).get("vi_def", "")
            })
    
    return {
        "original_text": text,
        "extracted_words": words[:max_words],
        "translations": translations,
        "total_words": len(words),
        "translated_count": len(translations)
    }


def get_dictionary_stats() -> Dict[str, Any]:
    """
    Get statistics about the dictionary
    
    Returns:
        Dictionary with statistics
    """
    dictionary = load_dictionary()
    return {
        "total_entries": len(dictionary),
        "file_path": str(DICTIONARY_FILE),
        "loaded": _dictionary_cache is not None
    }

