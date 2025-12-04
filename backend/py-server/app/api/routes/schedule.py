"""
Schedule Routes - CRUD operations for calendar schedules

This file handles all schedule-related API endpoints.
It uses the ScheduleService for business logic and ScheduleModel for data validation.

Endpoints:
- GET    /api/schedules          → Get all schedules
- GET    /api/schedules/{id}     → Get one schedule by ID
- POST   /api/schedules          → Create new schedule
- PUT    /api/schedules/{id}     → Update schedule
- DELETE /api/schedules/{id}     → Delete schedule

Flow:
  Request → Route → Service → (Database) → Response
              ↓         ↓
           Validate   Business
           with       Logic
           Model
"""

from fastapi import APIRouter, HTTPException

# Import models for request/response validation
from app.models.schedule import Schedule, ScheduleCreate, ScheduleUpdate

# Import service for business logic
from app.services.schedule_service import ScheduleService

router = APIRouter()

# Create service instance
schedule_service = ScheduleService()


@router.get("/")
def get_all_schedules():
    """
    Get all schedules.
    
    Returns:
        List of all schedules
    """
    schedules = schedule_service.get_all()
    return {
        "schedules": schedules,
        "total": len(schedules),
    }


@router.get("/{schedule_id}")
def get_schedule(schedule_id: str):
    """
    Get a single schedule by ID.
    
    Args:
        schedule_id: The unique ID of the schedule
        
    Returns:
        The schedule if found
        
    Raises:
        404: If schedule not found
    """
    schedule = schedule_service.get_by_id(schedule_id)
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    return schedule


@router.post("/", status_code=201)
def create_schedule(data: ScheduleCreate):
    """
    Create a new schedule.
    
    Args:
        data: Schedule data (validated by ScheduleCreate model)
        
    Returns:
        The created schedule with generated ID
    """
    schedule = schedule_service.create(data)
    return schedule


@router.put("/{schedule_id}")
def update_schedule(schedule_id: str, data: ScheduleUpdate):
    """
    Update an existing schedule.
    
    Args:
        schedule_id: The ID of schedule to update
        data: Fields to update (all optional)
        
    Returns:
        The updated schedule
        
    Raises:
        404: If schedule not found
    """
    schedule = schedule_service.update(schedule_id, data)
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    return schedule


@router.delete("/{schedule_id}")
def delete_schedule(schedule_id: str):
    """
    Delete a schedule.
    
    Args:
        schedule_id: The ID of schedule to delete
        
    Returns:
        Confirmation message
        
    Raises:
        404: If schedule not found
    """
    success = schedule_service.delete(schedule_id)
    if not success:
        raise HTTPException(status_code=404, detail="Schedule not found")
    return {"message": "Schedule deleted", "id": schedule_id}
