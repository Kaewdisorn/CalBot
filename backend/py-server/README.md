# CalBot Python Server

A simple FastAPI server for learning Python web development.

## Quick Start

```bash
# 1. Activate virtual environment
.\venv\Scripts\activate   # Windows
source venv/bin/activate  # macOS/Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the server
python main.py
```

## Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/` | Hello World message |
| GET | `/health` | Health check |
| GET | `/hello/{name}` | Personalized greeting |

## API Documentation

When server is running, open:
- **Swagger UI**: http://localhost:8001/docs
- **ReDoc**: http://localhost:8001/redoc

## Understanding the Code

```python
# 1. Import FastAPI
from fastapi import FastAPI

# 2. Create an app instance
app = FastAPI()

# 3. Define routes using decorators
@app.get("/")           # This handles GET requests to "/"
def root():
    return {"message": "Hello World!"}

# 4. Run the server
uvicorn.run("main:app", port=8001)
```

That's it! FastAPI automatically:
- Validates request/response data
- Generates API documentation
- Handles JSON serialization
