"""
Error handling utilities for OpenAI API and other services
"""
import logging
from fastapi import HTTPException
from typing import Optional

logger = logging.getLogger(__name__)


def is_quota_error(error: Exception) -> bool:
    """Check if error is related to OpenAI quota"""
    error_str = str(error).lower()
    return any(keyword in error_str for keyword in [
        "insufficient_quota",
        "429",
        "quota",
        "exceeded"
    ])


def is_auth_error(error: Exception) -> bool:
    """Check if error is related to authentication"""
    error_str = str(error).lower()
    return any(keyword in error_str for keyword in [
        "invalid_api_key",
        "401",
        "unauthorized",
        "authentication"
    ])


def handle_openai_error(
    error: Exception,
    service_name: str = "OpenAI service",
    allow_503: bool = True
) -> HTTPException:
    """
    Handle OpenAI API errors and return appropriate HTTPException
    
    Args:
        error: The exception that occurred
        service_name: Name of the service for logging
        allow_503: Whether to return 503 for quota errors (vs 500)
    
    Returns:
        HTTPException with appropriate status code and message
    """
    error_str = str(error)
    
    if is_quota_error(error):
        logger.error(f"{service_name} quota exceeded: {error}")
        status_code = 503 if allow_503 else 500
        return HTTPException(
            status_code=status_code,
            detail="OpenAI API quota exceeded. Please check your billing and add credits."
        )
    
    if is_auth_error(error):
        logger.error(f"{service_name} authentication failed: {error}")
        return HTTPException(
            status_code=500,
            detail="OpenAI API key is invalid. Please check your configuration."
        )
    
    # Generic error
    logger.error(f"{service_name} error: {error}")
    return HTTPException(
        status_code=500,
        detail=f"Failed to process {service_name.lower()} request: {str(error)[:200]}"
    )

