"""
CalBot Python Server - Main API Entry Point

This file creates and configures the FastAPI application.
Run with: python main.py

Project Structure:
- main.py     → API server (this file)
- bot.py      → Discord bot (separate entry point)
- app/        → Application code (routes, models, services)
"""

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import the router that combines all API routes
from app.api.router import api_router

# Create the FastAPI app
app = FastAPI(
    title="CalBot API",
    description="Backend API for CalBot calendar application",
    version="1.0.0",
)

# Allow requests from Flutter web app (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all API routes with /api prefix
# This connects: /api/health, /api/schedules, /api/ai, etc.
app.include_router(api_router, prefix="/api")


@app.get("/")
def root():
    """Root endpoint - API welcome message."""
    return {
        "message": "Welcome to CalBot API 🗓️",
        "docs": "/docs",
        "health": "/api/health",
    }


if __name__ == "__main__":
    print("\n🚀 Starting CalBot API Server...")
    print("📖 API Docs: http://localhost:8001/docs")
    print("🔧 Health: http://localhost:8001/api/health\n")

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8001,
        reload=True,
    )
