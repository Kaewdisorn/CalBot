"""
Gemini AI Service - Handles communication with Google's Gemini API

This service provides a simple interface for generating AI responses
using Google's Gemini model. It's used by the Discord bot to respond
to user mentions with intelligent, conversational replies.

Usage:
    service = GeminiService()
    response = await service.chat("Hello, how are you?")

Requirements:
    - GEMINI_API_KEY in environment/.env file
    - google-genai package installed (pip install google-genai)
"""

from google import genai
from google.genai import types
from core.config import config


class GeminiService:
    """
    Service class for interacting with Google's Gemini AI.
    
    Provides async methods for generating chat responses.
    Handles API initialization and error handling.
    """
    
    def __init__(self):
        """
        Initialize the Gemini client with API key from config.
        
        The API key should be set in your .env file:
        GEMINI_API_KEY=your_api_key_here
        
        Get your API key from: https://makersuite.google.com/app/apikey
        """
        # Initialize the Gemini client with your API key
        self.client = genai.Client(api_key=config.GEMINI_API_KEY)
        
        # Model to use for chat responses
        # gemini-2.0-flash is fast and good for conversational AI
        self.model = "gemini-2.0-flash"
        
        # System instruction to set the bot's personality and behavior
        self.system_instruction = """
        You are CalBot, a friendly and helpful Discord bot assistant.
        You help users manage their calendar and schedules.
        Keep responses concise and friendly.
        Use emojis occasionally to be more engaging.
        If asked about scheduling, remind users they can use slash commands like /addschedule.
        """
    
    async def chat(self, message: str) -> str:
        """
        Generate an AI response to the user's message.
        
        Args:
            message: The user's message/question
            
        Returns:
            The AI-generated response string
            
        Example:
            response = await gemini.chat("What can you help me with?")
            # Returns: "I can help you manage your calendar! Try /addschedule..."
        """
        try:
            # =================================================================
            # GENERATE RESPONSE
            # Call Gemini API with the user's message and system instructions
            # =================================================================
            response = self.client.models.generate_content(
                model=self.model,
                contents=message,
                config=types.GenerateContentConfig(
                    system_instruction=self.system_instruction,
                    # Limit response length to keep Discord messages reasonable
                    max_output_tokens=500,
                    # Temperature controls randomness (0=deterministic, 1=creative)
                    temperature=0.7,
                ),
            )
            
            # Extract text from response
            return response.text
            
        except Exception as e:
            # =================================================================
            # ERROR HANDLING
            # Return a friendly error message if something goes wrong
            # Log the actual error for debugging
            # =================================================================
            print(f"❌ Gemini API error: {e}")
            return "😅 Sorry, I'm having trouble thinking right now. Please try again later!"
    
    async def chat_with_context(self, message: str, context: str = "") -> str:
        """
        Generate a response with additional context (e.g., user's schedule).
        
        Args:
            message: The user's message/question
            context: Additional context to include (e.g., schedule data)
            
        Returns:
            The AI-generated response string
            
        Example:
            response = await gemini.chat_with_context(
                "What do I have tomorrow?",
                context="User's schedule: Meeting at 2pm, Dentist at 4pm"
            )
        """
        # Combine context with user message
        full_message = f"{context}\n\nUser question: {message}" if context else message
        return await self.chat(full_message)
