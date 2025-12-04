"""
Core Package - Configuration and utilities

This package contains shared infrastructure code:
- config.py  → Settings and environment variables
- (future)   → Database connections, logging, etc.

These are "core" because they're used throughout the app,
not specific to any one feature.

Example:
    from app.core.config import settings
    print(settings.API_PORT)
"""
