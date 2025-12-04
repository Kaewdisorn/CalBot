"""
Health Check Routes

Simple endpoints to verify the server is running.
Useful for:
- Load balancers to check if server is alive
- Monitoring systems
- Quick debugging

Endpoints:
- GET /api/health       → Basic health status
- GET /api/health/ready → Readiness check (can include DB check)
"""

from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def health_check():
    """
    Basic health check.
    
    Returns simple status to confirm server is running.
    """
    return {
        "status": "ok",
        "service": "calbot-py-server",
    }


@router.get("/ready")
def readiness_check():
    """
    Readiness check - more detailed than basic health.
    
    In production, you might check:
    - Database connection
    - External API availability
    - Required environment variables
    """
    # TODO: Add actual readiness checks
    checks = {
        "database": "ok",  # Placeholder
        "api": "ok",       # Placeholder
    }
    
    all_ok = all(v == "ok" for v in checks.values())
    
    return {
        "status": "ready" if all_ok else "not_ready",
        "checks": checks,
    }
