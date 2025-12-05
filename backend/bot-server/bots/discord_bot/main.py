"""
CalBot Discord Bot - Main Entry Point

This bot provides:
- Slash commands for calendar management (/ping, /addschedule)
- AI chat via mentions (mention @bot to chat with Gemini AI)

Run with: python main.py
Requires: DISCORD_TOKEN and GEMINI_API_KEY in .env
"""

import sys
from pathlib import Path

# =============================================================================
# PATH SETUP
# Add bot-server root to sys.path so imports like `from core.config` work
# regardless of the current working directory when running the script.
# =============================================================================
BOT_SERVER_ROOT = Path(__file__).resolve().parents[2]  # backend/bot-server
if str(BOT_SERVER_ROOT) not in sys.path:
    sys.path.insert(0, str(BOT_SERVER_ROOT))

import asyncio
import discord
from discord import app_commands
from core.config import config

# Import Gemini AI service for chat functionality
from bots.discord_bot.services.gemini_service import GeminiService


class MyDiscordBot(discord.Client):
    """
    Main Discord bot client.
    
    Handles:
    - Slash command registration and syncing
    - Message events (specifically @mentions for AI chat)
    - Bot lifecycle (ready, shutdown)
    """
    
    def __init__(self):
        # =================================================================
        # INTENTS SETUP
        # Intents control what events the bot receives from Discord.
        # - default(): Basic events (guilds, members joining, etc.)
        # - message_content: Required to read message text (for @mentions)
        # =================================================================
        intents = discord.Intents.default()
        intents.message_content = True  # Required to read message content
        
        super().__init__(intents=intents)
        
        # Command tree holds all slash commands
        self.tree = app_commands.CommandTree(self)
        
        # Initialize Gemini AI service for chat responses
        self.gemini = GeminiService()

    async def setup_hook(self):
        """
        Called when the bot is starting up, before on_ready.
        Use this to register commands and perform async initialization.
        """
        # Import and register all slash commands
        from bots.discord_bot.handlers.slash import register_slash_commands
        register_slash_commands(self.tree)

        # Sync commands to Discord (makes them available in the Discord UI)
        # Note: This can take a few seconds; global commands may take up to 1 hour
        await self.tree.sync()
        print("🔄 Slash commands synced.")

    async def on_ready(self):
        """
        Called when the bot has successfully connected to Discord.
        """
        print(f"🤖 Discord Bot logged in as {self.user}")
        print(f"📡 Connected to {len(self.guilds)} server(s)")
    
    async def on_message(self, message: discord.Message):
        """
        Called when a message is sent in any channel the bot can see.
        
        This handler checks if the bot was mentioned and responds
        using Gemini AI to create a conversational chat experience.
        
        Args:
            message: The Discord message object containing author, content, etc.
        """
        # =================================================================
        # DEBUG LOGGING
        # Shows all messages the bot receives (remove in production)
        # =================================================================
        print(f"📨 Message from {message.author.name}: {message.content[:50]}...")
        
        # =================================================================
        # IGNORE SELF
        # Prevent the bot from responding to its own messages (infinite loop)
        # =================================================================
        if message.author == self.user:
            return
        
        # =================================================================
        # IGNORE OTHER BOTS
        # Prevent responding to other bots (avoids bot loops)
        # =================================================================
        if message.author.bot:
            return
        
        # =================================================================
        # CHECK FOR MENTION (Bot user OR Bot role)
        # - self.user.mentioned_in() returns True if bot was @mentioned directly
        # - Also check if any of the bot's roles were mentioned (@role)
        # =================================================================
        
        # Check if bot user was mentioned directly
        bot_mentioned = self.user and self.user.mentioned_in(message)
        
        # Check if any role the bot has was mentioned
        # This allows users to mention a role like @CalBot-Role to trigger the bot
        bot_role_mentioned = False
        if message.guild and self.user:
            bot_member = message.guild.get_member(self.user.id)
            if bot_member:
                # Check if any of the bot's roles were mentioned in the message
                bot_role_mentioned = any(
                    role in message.role_mentions 
                    for role in bot_member.roles 
                    if role.name != "@everyone"  # Ignore @everyone role
                )
        
        if bot_mentioned or bot_role_mentioned:
            mention_type = "directly" if bot_mentioned else "via role"
            print(f"✅ Bot mentioned {mention_type} by {message.author.name} in #{message.channel.name}")
            
            # Remove the bot mention from the message to get the actual question
            # e.g., "@CalBot what is the weather?" -> "what is the weather?"
            user_message = message.content
            
            # Remove direct bot mention
            if self.user:
                user_message = user_message.replace(f'<@{self.user.id}>', '')
            
            # Remove role mentions (format: <@&ROLE_ID>)
            for role in message.role_mentions:
                user_message = user_message.replace(f'<@&{role.id}>', '')
            
            user_message = user_message.strip()
            
            # If user just mentioned the bot without any message
            if not user_message:
                await message.reply("👋 Hi! Mention me with a message and I'll chat with you!")
                return
            
            # Show typing indicator while generating response
            async with message.channel.typing():
                # Call Gemini API to generate a response
                response = await self.gemini.chat(user_message)
            
            # Reply to the user's message with Gemini's response
            await message.reply(response)


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
