"""
Routes Package - Individual route modules

Each file in this folder handles a specific group of endpoints:
- health.py   → Health check endpoints (/health)
- schedule.py → Schedule CRUD endpoints (/schedules)
- ai.py       → AI parsing endpoints (/ai)

Each file creates its own router that gets combined in router.py
"""
