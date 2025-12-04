"""
AI Routes - Natural language parsing endpoints

This file handles AI-powered features like:
- Parsing natural language into schedule data
- Intent detection (create, update, delete, query)

Example:
  Input:  "Schedule a meeting tomorrow at 2pm"
  Output: { subject: "meeting", start_time: "2024-12-05T14:00:00", ... }

Endpoints:
- POST /api/ai/parse → Parse natural language to schedule
"""

from fastapi import APIRouter
from pydantic import BaseModel

# TODO: Import AI service when implemented
# from app.services.ai_service import AIService

router = APIRouter()


class ParseRequest(BaseModel):
    """Request model for parsing natural language."""
    text: str  # The natural language text to parse
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {"text": "Schedule a meeting tomorrow at 2pm for 1 hour"}
            ]
        }
    }


class ParseResponse(BaseModel):
    """Response model with parsed schedule data."""
    success: bool
    message: str
    data: dict | None = None  # Parsed schedule data


@router.post("/parse", response_model=ParseResponse)
def parse_natural_language(request: ParseRequest):
    """
    Parse natural language into structured schedule data.
    
    This endpoint will use AI (OpenAI/LangChain) to understand
    user's text and extract schedule information.
    
    Args:
        request: Contains the text to parse
        
    Returns:
        Parsed schedule data or error message
    """
    # TODO: Implement actual AI parsing with AIService
    # For now, return a placeholder response
    
    return ParseResponse(
        success=True,
        message="AI parsing coming soon!",
        data={
            "original_text": request.text,
            "parsed": {
                "subject": "Example Event",
                "note": "This is a placeholder. AI parsing not implemented yet.",
            }
        }
    )
