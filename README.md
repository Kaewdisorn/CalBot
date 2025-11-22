# 📅 CalBot

**Smart cross-platform scheduling bot with Discord integration, Flutter Web UI, and Python AI for natural-language event creation.**

---

## 🚀 Features

- `/add_event` slash command to create events in Discord
- Natural-language event creation (e.g., "tomorrow 3pm meeting")
- Modal-based event creation in Discord
- Real-time reminders sent to Discord channels or DMs
- Event management: add, edit, delete
- Timezone support
- Conflict detection and smart reminder suggestions
- Recurring events (daily, weekly, monthly)
- Flutter Web calendar UI for viewing and managing events

---

## ⚙️ Technology Stack

- **Flutter Web**: Calendar UI, event management frontend
- **Node.js**: Discord bot, API, backend logic
- **discord.js v14**: Slash commands, modals, webhooks
- **Python (FastAPI)**: NLP parsing, smart scheduling
- **PostgreSQL**: Events, reminders, users
- **Redis** (optional): Job queue / reminders
