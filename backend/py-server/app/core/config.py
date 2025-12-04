"""
Configuration - Application settings

This file manages all configuration using environment variables.
Settings are loaded from:
1. Environment variables (highest priority)
2. .env file (if exists)
3. Default values (defined here)

Usage:
    from app.core.config import settings
    
    print(settings.API_PORT)        # 8001
    print(settings.DEBUG)           # True
    print(settings.DISCORD_TOKEN)   # from .env file

For production:
    Set environment variables or use .env file:
    
    API_PORT=8001
    DEBUG=false
    DISCORD_TOKEN=your_token_here
    OPENAI_API_KEY=your_key_here
"""

import os
from typing import Optional

# Try to load .env file if python-dotenv is installed
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    # python-dotenv not installed, skip .env loading
    pass


class Settings:
    """
    Application settings.
    
    Reads from environment variables with sensible defaults.
    """
    
    # Server settings
    API_HOST: str = os.getenv("API_HOST", "0.0.0.0")
    API_PORT: int = int(os.getenv("API_PORT", "8001"))
    DEBUG: bool = os.getenv("DEBUG", "true").lower() == "true"
    
    # Discord bot (optional, for future)
    DISCORD_TOKEN: Optional[str] = os.getenv("DISCORD_TOKEN")
    
    # OpenAI (optional, for future AI features)
    OPENAI_API_KEY: Optional[str] = os.getenv("OPENAI_API_KEY")
    OPENAI_MODEL: str = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
    
    # Node.js server URL (for API calls)
    NODE_SERVER_URL: str = os.getenv("NODE_SERVER_URL", "http://localhost:3000")


# Global settings instance
settings = Settings()
