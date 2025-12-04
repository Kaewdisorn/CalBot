"""
Schedule Service - Business logic for schedule operations

This service handles all schedule-related operations.
It's used by both the API routes and the Discord bot.

Currently uses in-memory storage (a dict) for simplicity.
In production, you would connect to a database.

Methods:
- get_all()              → Get all schedules
- get_by_id(id)          → Get one schedule
- create(data)           → Create new schedule
- update(id, data)       → Update schedule
- delete(id)             → Delete schedule
"""

from datetime import datetime, timedelta
from typing import Optional
import uuid

from app.models.schedule import Schedule, ScheduleCreate, ScheduleUpdate


class ScheduleService:
    """
    Service class for schedule operations.
    
    Uses in-memory storage for demo purposes.
    Replace with database operations in production.
    """
    
    def __init__(self):
        # In-memory storage: dict[id, Schedule]
        # In production, this would be a database connection
        self._storage: dict[str, Schedule] = {}
        
        # Add sample data
        self._init_sample_data()
    
    def _init_sample_data(self):
        """Initialize with sample schedules for testing."""
        now = datetime.now()
        today = now.replace(hour=0, minute=0, second=0, microsecond=0)
        
        samples = [
            Schedule(
                id="sch_001",
                subject="Team Standup",
                notes="Daily sync meeting",
                start_time=today.replace(hour=9, minute=0),
                end_time=today.replace(hour=9, minute=30),
                is_all_day=False,
                is_done=False,
                recurrence_rule="FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR",
                color="#4285F4",
                created_at=now,
            ),
            Schedule(
                id="sch_002",
                subject="Lunch with Sarah",
                notes="At the Italian restaurant",
                start_time=(today + timedelta(days=1)).replace(hour=12, minute=0),
                end_time=(today + timedelta(days=1)).replace(hour=13, minute=0),
                is_all_day=False,
                is_done=False,
                color="#34A853",
                created_at=now,
            ),
            Schedule(
                id="sch_003",
                subject="Project Deadline",
                notes="Submit final report",
                start_time=today + timedelta(days=3),
                end_time=today + timedelta(days=3),
                is_all_day=True,
                is_done=False,
                color="#EA4335",
                created_at=now,
            ),
        ]
        
        for schedule in samples:
            self._storage[schedule.id] = schedule
    
    def get_all(self) -> list[Schedule]:
        """
        Get all schedules.
        
        Returns:
            List of all schedules
        """
        return list(self._storage.values())
    
    def get_by_id(self, schedule_id: str) -> Optional[Schedule]:
        """
        Get a schedule by its ID.
        
        Args:
            schedule_id: The unique ID of the schedule
            
        Returns:
            The schedule if found, None otherwise
        """
        return self._storage.get(schedule_id)
    
    def create(self, data: ScheduleCreate) -> Schedule:
        """
        Create a new schedule.
        
        Args:
            data: The schedule data (validated by Pydantic)
            
        Returns:
            The created schedule with generated ID
        """
        # Generate unique ID
        schedule_id = f"sch_{uuid.uuid4().hex[:8]}"
        
        # Create schedule with generated fields
        schedule = Schedule(
            id=schedule_id,
            created_at=datetime.now(),
            **data.model_dump()  # Spread all fields from data
        )
        
        # Store it
        self._storage[schedule_id] = schedule
        
        return schedule
    
    def update(self, schedule_id: str, data: ScheduleUpdate) -> Optional[Schedule]:
        """
        Update an existing schedule.
        
        Args:
            schedule_id: The ID of schedule to update
            data: Fields to update (only non-None fields)
            
        Returns:
            Updated schedule if found, None otherwise
        """
        # Check if exists
        existing = self._storage.get(schedule_id)
        if not existing:
            return None
        
        # Get only the fields that were provided (not None)
        update_data = data.model_dump(exclude_unset=True)
        
        # Create updated schedule
        updated = existing.model_copy(update={
            **update_data,
            "updated_at": datetime.now(),
        })
        
        # Store it
        self._storage[schedule_id] = updated
        
        return updated
    
    def delete(self, schedule_id: str) -> bool:
        """
        Delete a schedule.
        
        Args:
            schedule_id: The ID of schedule to delete
            
        Returns:
            True if deleted, False if not found
        """
        if schedule_id not in self._storage:
            return False
        
        del self._storage[schedule_id]
        return True
