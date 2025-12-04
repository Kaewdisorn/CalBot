"""
API Router - Combines all route modules into one router

This file imports all individual route modules and combines them.
The main.py file imports this single router instead of each route separately.

How it works:
1. Each route file (health.py, schedule.py) has its own small router
2. This file combines them with prefixes like /health, /schedules
3. main.py includes this combined router with prefix /api
4. Final URLs: /api/health, /api/schedules, etc.
"""

from fastapi import APIRouter

# Import individual route modules
from app.api.routes import health
from app.api.routes import schedule
from app.api.routes import ai

# Create the main API router
api_router = APIRouter()

# Include each route module with its prefix
# health.router handles: GET /health, GET /health/ready
api_router.include_router(
    health.router,
    prefix="/health",
    tags=["Health"],  # Groups endpoints in /docs
)

# schedule.router handles: GET /schedules, POST /schedules, etc.
api_router.include_router(
    schedule.router,
    prefix="/schedules",
    tags=["Schedules"],
)

# ai.router handles: POST /ai/parse
api_router.include_router(
    ai.router,
    prefix="/ai",
    tags=["AI"],
)
