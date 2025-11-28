"""
Configuration settings for the Korean Learning App backend

Loads configuration from environment variables and .env file.
"""
from typing import Literal

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables
    
    All settings can be overridden via environment variables or .env file.
    """

    # OpenAI Configuration
    openai_api_key: str
    openai_model_name: str = "gpt-4o-mini"

    # Server Configuration
    backend_host: str = "0.0.0.0"
    backend_port: int = 8000
    frontend_url: str = "http://localhost:5173"

    # Environment
    env: Literal["development", "production", "testing"] = "development"

    # MySQL Configuration
    mysql_host: str = "localhost"
    mysql_port: int = 3306
    mysql_user: str = "root"
    mysql_password: str = ""
    mysql_database: str = "koreanhwa"

    class Config:
        env_file = ".env"
        case_sensitive = False
        extra = "ignore"  # Ignore extra fields in .env that are not in Settings


# Global settings instance - initialized on import
settings = Settings()
