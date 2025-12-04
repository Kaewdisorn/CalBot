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
    await bot.start(config.DISCORD_TOKEN)
