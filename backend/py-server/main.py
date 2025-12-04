"""
CalBot Python Server - Simple FastAPI Example

This is a minimal FastAPI app to help you understand the basics.
Run with: python main.py
Then open: http://localhost:8001/docs (interactive API docs)
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Create the FastAPI app
app = FastAPI(
    title="CalBot API",
    description="Simple API for learning FastAPI",
    version="1.0.0",
)

# Allow requests from Flutter web app (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)


# ============================================================
# ROUTES - These are your API endpoints
# ============================================================

@app.get("/")
def root():
    """
    Root endpoint - just returns a welcome message.
    
    Try it: http://localhost:8001/
    """
    return {"message": "Hello World! Welcome to CalBot API 🗓️"}


@app.get("/health")
def health_check():
    """
    Health check endpoint - useful to verify server is running.
    
    Try it: http://localhost:8001/health
    """
    return {"status": "ok", "service": "py-server"}


@app.get("/hello/{name}")
def say_hello(name: str):
    """
    Dynamic route with a path parameter.
    
    Try it: http://localhost:8001/hello/YourName
    
    Args:
        name: The name to greet (from URL path)
    """
    return {"message": f"Hello, {name}! 👋"}


# ============================================================
# Run the server when this file is executed directly
# ============================================================

if __name__ == "__main__":
    import uvicorn
    
    print("\n🚀 Starting CalBot Python Server...")
    print("📖 API Docs: http://localhost:8001/docs")
    print("🔧 Health Check: http://localhost:8001/health\n")
    
    uvicorn.run(
        "main:app",      # "filename:app_variable"
        host="0.0.0.0",  # Listen on all interfaces
        port=8001,       # Port number
        reload=True,     # Auto-reload when code changes
    )
