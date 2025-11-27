"""
Error handling utilities for OpenAI API and other services
"""
import logging
from fastapi import HTTPException
from typing import Optional

try:
    from openai import APIError, RateLimitError
    OPENAI_ERRORS_AVAILABLE = True
except ImportError:
    OPENAI_ERRORS_AVAILABLE = False

logger = logging.getLogger(__name__)


def is_quota_error(error: Exception) -> bool:
    """Check if error is related to OpenAI quota"""
    # Check for OpenAI-specific error types
    if OPENAI_ERRORS_AVAILABLE:
        if isinstance(error, RateLimitError):
            return True
        if isinstance(error, APIError):
            # Check status code
            if hasattr(error, 'status_code') and error.status_code == 429:
                return True
            # Check error body
            if hasattr(error, 'response') and error.response is not None:
                try:
                    if hasattr(error.response, 'json'):
                        error_body = error.response.json()
                        if isinstance(error_body, dict):
                            error_info = error_body.get('error', {})
                            if isinstance(error_info, dict):
                                error_type = error_info.get('type', '').lower()
                                error_code = error_info.get('code', '').lower()
                                if 'insufficient_quota' in error_type or 'insufficient_quota' in error_code:
                                    return True
                except:
                    pass
    
    # Fallback: check error string
    error_str = str(error).lower()
    return any(keyword in error_str for keyword in [
        "insufficient_quota",
        "429",
        "quota",
        "exceeded"
    ])


def is_auth_error(error: Exception) -> bool:
    """Check if error is related to authentication"""
    # Check for OpenAI-specific error types
    if OPENAI_ERRORS_AVAILABLE:
        if isinstance(error, APIError):
            # Check status code
            if hasattr(error, 'status_code') and error.status_code == 401:
                return True
            # Check error body
            if hasattr(error, 'response') and error.response is not None:
                try:
                    if hasattr(error.response, 'json'):
                        error_body = error.response.json()
                        if isinstance(error_body, dict):
                            error_info = error_body.get('error', {})
                            if isinstance(error_info, dict):
                                error_type = error_info.get('type', '').lower()
                                if 'invalid_api_key' in error_type or 'authentication' in error_type:
                                    return True
                except:
                    pass
    
    # Fallback: check error string
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
    
    # Extract error details if available
    error_message = None
    if OPENAI_ERRORS_AVAILABLE and isinstance(error, APIError):
        if hasattr(error, 'response') and error.response is not None:
            try:
                if hasattr(error.response, 'json'):
                    error_body = error.response.json()
                    if isinstance(error_body, dict):
                        error_info = error_body.get('error', {})
                        if isinstance(error_info, dict):
                            error_message = error_info.get('message', error_str)
            except:
                pass
    
    if is_quota_error(error):
        logger.error(f"{service_name} quota exceeded: {error}")
        status_code = 503 if allow_503 else 500
        # Use user-friendly message in Vietnamese
        detail_message = "Đã vượt quá hạn mức API. Vui lòng kiểm tra tài khoản và thêm credits. Xin lỗi vì sự bất tiện này."
        # Include original message for debugging if available
        if error_message:
            logger.debug(f"Original OpenAI error: {error_message}")
        return HTTPException(
            status_code=status_code,
            detail=detail_message
        )
    
    if is_auth_error(error):
        logger.error(f"{service_name} authentication failed: {error}")
        detail_message = error_message if error_message else "OpenAI API key is invalid. Please check your configuration."
        return HTTPException(
            status_code=401,
            detail=detail_message
        )
    
    # Generic error
    logger.error(f"{service_name} error: {error}")
    detail_message = error_message if error_message else f"Failed to process {service_name.lower()} request: {str(error)[:200]}"
    return HTTPException(
        status_code=500,
        detail=detail_message
    )

