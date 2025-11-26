"""
Dictionary Router - Endpoints for Korean-Vietnamese dictionary
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any, Optional
import logging

from services import dictionary_service

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/dictionary",
    tags=["dictionary"]
)


@router.get("/search")
async def search_dictionary(
    query: str = Query(..., description="Korean word to search for"),
    limit: int = Query(10, ge=1, le=100, description="Maximum number of results")
) -> Dict[str, Any]:
    """
    Search Korean-Vietnamese dictionary
    
    Args:
        query: Korean word to search for
        limit: Maximum number of results (1-100)
    
    Returns:
        Dictionary with search results
    """
    try:
        results = dictionary_service.search_dictionary(query, limit)
        return {
            "query": query,
            "results": results,
            "count": len(results)
        }
    except Exception as e:
        logger.error(f"Error searching dictionary: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to search dictionary: {str(e)}")


@router.get("/lookup/{korean_word}")
async def lookup_word(korean_word: str) -> Dict[str, Any]:
    """
    Get exact dictionary entry for a Korean word
    
    Args:
        korean_word: Korean word to look up
    
    Returns:
        Dictionary entry if found
    """
    try:
        entry = dictionary_service.get_dictionary_entry(korean_word)
        if entry is None:
            raise HTTPException(status_code=404, detail=f"Word '{korean_word}' not found in dictionary")
        
        return {
            "korean": entry.get("source"),
            "vietnamese": entry.get("meta", {}).get("vi_word", ""),
            "definition": entry.get("meta", {}).get("vi_def", ""),
            "full_target": entry.get("target", ""),
            "meta": entry.get("meta", {})
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error looking up word: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to lookup word: {str(e)}")


@router.post("/translate")
async def translate_text(
    text: str,
    max_words: int = Query(50, ge=1, le=200, description="Maximum number of words to translate")
) -> Dict[str, Any]:
    """
    Extract vocabulary from Korean text and translate using dictionary
    
    Args:
        text: Korean text to translate
        max_words: Maximum number of words to translate
    
    Returns:
        Dictionary with original text, extracted words, and translations
    """
    try:
        result = dictionary_service.translate_text_with_dictionary(text, max_words)
        return result
    except Exception as e:
        logger.error(f"Error translating text: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to translate text: {str(e)}")


@router.get("/stats")
async def get_dictionary_stats() -> Dict[str, Any]:
    """
    Get statistics about the dictionary
    
    Returns:
        Dictionary with statistics
    """
    try:
        stats = dictionary_service.get_dictionary_stats()
        return stats
    except Exception as e:
        logger.error(f"Error getting dictionary stats: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get stats: {str(e)}")

