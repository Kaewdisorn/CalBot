# CalBot Python Server

A FastAPI server with a clean project structure for learning.

## Project Structure

```
py-server/
├── main.py              # API server entry point (run this)
├── bot.py               # Discord bot entry point (for future)
├── requirements.txt     # Python dependencies
├── README.md
│
└── app/                 # Application code
    ├── __init__.py
    │
    ├── api/             # API layer (HTTP endpoints)
    │   ├── __init__.py
    │   ├── router.py    # Combines all routes
    │   └── routes/      # Individual route files
    │       ├── __init__.py
    │       ├── health.py    # /api/health
    │       ├── schedule.py  # /api/schedules
    │       └── ai.py        # /api/ai
    │
    ├── models/          # Data models (Pydantic)
    │   ├── __init__.py
    │   └── schedule.py  # Schedule, ScheduleCreate, ScheduleUpdate
    │
    ├── services/        # Business logic
    │   ├── __init__.py
    │   ├── schedule_service.py  # Schedule CRUD logic
    │   └── ai_service.py        # AI parsing (placeholder)
    │
    └── core/            # Config and utilities
        ├── __init__.py
        └── config.py    # Settings from environment
```

## Quick Start

```bash
# 1. Activate virtual environment
.\venv\Scripts\activate   # Windows

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the server
python main.py
```

## Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/` | Welcome message |
| GET | `/api/health` | Health check |
| GET | `/api/schedules` | Get all schedules |
| POST | `/api/schedules` | Create schedule |
| GET | `/api/schedules/{id}` | Get one schedule |
| PUT | `/api/schedules/{id}` | Update schedule |
| DELETE | `/api/schedules/{id}` | Delete schedule |
| POST | `/api/ai/parse` | Parse natural language |

## API Documentation

Open http://localhost:8001/docs for interactive Swagger UI.

## Architecture Flow

```
Request → Route → Service → (Database)
            ↓        ↓
         Model    Business
       Validation   Logic
```

- **Routes**: Handle HTTP (request/response)
- **Services**: Business logic (reusable by bot too)
- **Models**: Data validation with Pydantic
