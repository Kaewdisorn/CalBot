"""
Services Package - Business logic layer

Services contain the actual logic of your application.
They sit between routes (API) and data (database/storage).

Why use services?
1. Keep routes clean (just handle HTTP stuff)
2. Reusable logic (bot can use same service as API)
3. Easier to test
4. Single place to change business rules

Flow:
  Route → Service → Repository/Database
          ↓
       Business
       Logic

Files:
- schedule_service.py → Schedule CRUD operations
- ai_service.py       → AI/LLM parsing logic (for future)

Example:
    from app.services.schedule_service import ScheduleService
    
    service = ScheduleService()
    schedules = service.get_all()
"""
