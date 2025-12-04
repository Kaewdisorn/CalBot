"""
AI Service - Natural language parsing with AI (PLACEHOLDER)

This service will handle AI-powered features:
- Parse natural language to schedule data
- Detect user intent (create, query, update, delete)
- Generate responses for the Discord bot

Future implementation will use:
- OpenAI API (GPT-4)
- LangChain for prompt management

Example usage (future):
    service = AIService()
    result = await service.parse_schedule("Meeting tomorrow at 2pm")
    # Returns: { subject: "Meeting", start_time: "2024-12-05T14:00:00", ... }

Dependencies needed (add to requirements.txt when ready):
    openai
    langchain
    langchain-openai
"""


class AIService:
    """
    AI Service for natural language processing.
    
    Currently a placeholder - will be implemented when you add AI features.
    """
    
    def __init__(self):
        # TODO: Initialize OpenAI client
        # self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        pass
    
    async def parse_schedule(self, text: str) -> dict:
        """
        Parse natural language text into schedule data.
        
        Args:
            text: Natural language description like "Meeting tomorrow at 2pm"
            
        Returns:
            Dictionary with parsed schedule fields
        """
        # TODO: Implement with OpenAI/LangChain
        return {
            "success": False,
            "message": "AI parsing not implemented yet",
            "original_text": text,
        }
    
    async def detect_intent(self, text: str) -> str:
        """
        Detect what the user wants to do.
        
        Args:
            text: User's message
            
        Returns:
            Intent: "create", "query", "update", "delete", or "unknown"
        """
        # TODO: Implement with AI
        return "unknown"
