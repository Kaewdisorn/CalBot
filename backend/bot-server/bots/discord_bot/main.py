import sys
from pathlib import Path

# Add bot-server root to sys.path so `from core.config` works
BOT_SERVER_ROOT = Path(__file__).resolve().parents[2]  # backend/bot-server
if str(BOT_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(BOT_SERVER_ROOT))

import asyncio
import discord
from discord import app_commands
from core.config import config

class MyDiscordBot(discord.Client):
    def __init__(self):
        intents = discord.Intents.default()
        super().__init__(intents=intents)
        self.tree = app_commands.CommandTree(self)

    async def setup_hook(self):
        # Import slash commands
        from bots.discord_bot.handlers.slash import register_slash_commands
        register_slash_commands(self.tree)

        # Sync commands to Discord
        await self.tree.sync()
        print("🔄 Slash commands synced.")

    async def on_ready(self):
        print(f"🤖 Discord Bot logged in as {self.user}")


async def run():
    bot = MyDiscordBot()
    try:
        await bot.start(config.DISCORD_TOKEN)
    except KeyboardInterrupt:
        await bot.close()
    except Exception:
        await bot.close()
        raise
# Entry point for direct run
if __name__ == "__main__":
    asyncio.run(run())
