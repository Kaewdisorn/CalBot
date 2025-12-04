"""
CalBot Discord Bot - Separate Entry Point

This file runs the Discord bot independently from the API server.
Run with: python bot.py

The bot can:
- Respond to commands like !schedule, !today
- Parse natural language to create events
- Query the API server for schedule data

Note: You need DISCORD_BOT_TOKEN in your environment or .env file
"""

import os
import asyncio

# TODO: Uncomment when you install discord.py
# import discord
# from discord.ext import commands

# Load environment variables (optional, for .env file support)
# from dotenv import load_dotenv
# load_dotenv()


def main():
    """
    Main function to run the Discord bot.
    
    Currently a placeholder - uncomment the discord code when ready.
    """
    print("\n🤖 CalBot Discord Bot")
    print("=" * 40)
    print("This is a placeholder for the Discord bot.")
    print("\nTo enable the bot:")
    print("1. pip install discord.py python-dotenv")
    print("2. Add DISCORD_BOT_TOKEN to .env file")
    print("3. Uncomment the discord code in this file")
    print("=" * 40)
    
    # Example of what the bot setup looks like:
    """
    # Get token from environment
    token = os.getenv("DISCORD_BOT_TOKEN")
    if not token:
        print("Error: DISCORD_BOT_TOKEN not found!")
        return
    
    # Create bot with command prefix "!"
    intents = discord.Intents.default()
    intents.message_content = True
    bot = commands.Bot(command_prefix="!", intents=intents)
    
    @bot.event
    async def on_ready():
        print(f"Bot logged in as {bot.user}")
    
    @bot.command()
    async def hello(ctx):
        await ctx.send("Hello! I'm CalBot 🗓️")
    
    # Run the bot
    bot.run(token)
    """


if __name__ == "__main__":
    main()
