from pathlib import Path
import os
from dotenv import load_dotenv

# Load .env from repository root (adjust if your .env is elsewhere)
BASE_DIR = Path(__file__).resolve().parents[2]  # backend/bot-server
dotenv_path = BASE_DIR / ".env"
load_dotenv(dotenv_path)

class Config:
    DISCORD_TOKEN: str = os.getenv("DISCORD_TOKEN", "").strip()
    # Add more settings if needed
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