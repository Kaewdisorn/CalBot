from pathlib import Path
import os
from dotenv import load_dotenv

# Find .env file
BASE_DIR = Path(__file__).resolve().parents[3]
dotenv_path = BASE_DIR / ".env"
load_dotenv(dotenv_path)

class Config:
    # Discord bot token (required)
    DISCORD_TOKEN: str = os.getenv("DISCORD_TOKEN", "").strip()
    
    # Gemini API key for AI chat responses (required for mention feature)
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "").strip()
    
    # Logging level (DEBUG, INFO, WARNING, ERROR)
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")

    @classmethod
    def require(cls, name: str):
        val = getattr(cls, name, None)
        if not val:
            raise RuntimeError(f"Missing required config: {name}")
        return val

# Validate required values at import time (optional)
Config.require("DISCORD_TOKEN")

config = Config()