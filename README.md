# 🗓️ CalBot — Smart Calendar & Scheduling Application

<div align="center">

![CalBot Logo](docs\screenshots\halulu_calendar.png)

**A modern, cross-platform calendar and scheduling application with Discord bot integration**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-5.x-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com)
[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![Discord.py](https://img.shields.io/badge/Discord.py-2.x-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discordpy.readthedocs.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgresql.org)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)

[Features](#-features) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack) • [Architecture](#-architecture)

</div>

---

## Overview

CalBot is a professional-grade, cross-platform calendar and scheduling application that seamlessly integrates web, API, and Discord bot interfaces. Built with Flutter Web for the frontend, Node.js for the REST API, and Python for the Discord bot server, it provides comprehensive event management with support for RFC 5545-compliant recurring events, natural language scheduling via Discord, and an intuitive user interface.

The application demonstrates modern software engineering practices including:

- **Microservices Architecture** with containerized services (Frontend, API Server, Bot Server, Database)
- **Multi-Platform Integration** — Web interface, REST API, and Discord bot for universal access
- **Reactive State Management** with GetX for seamless UI updates
- **RFC 5545 Compliant** recurrence rules for professional-grade scheduling
- **Responsive Design** optimized for desktop, tablet, and mobile devices
- **Clean Architecture** with clear separation of concerns across all services

## Features

### 📅 Calendar Management

- **Multiple Calendar Views** — Month view with integrated agenda panel
- **Complete Event CRUD** — Create, read, update, and delete events seamlessly
- **All-Day Event Support** — Schedule full-day activities
- **Rich Event Details** — Add locations, notes, and custom metadata
- **Cross-Platform Access** — Manage schedules via web interface or Discord bot

### 🔄 Advanced Recurring Events

- **Flexible Recurrence Patterns** — Daily, Weekly, and Monthly options
- **Multi-Day Weekly Scheduling** — Select specific days (e.g., Mon, Wed, Fri)
- **Smart Monthly Recurrence** — By day number (15th) or position (2nd Tuesday)
- **Multiple End Conditions** — Recur forever, until a specific date, or for N occurrences
- **Exception Date Handling** — Delete individual occurrences without affecting the series
- **Per-Occurrence Task Tracking** — Mark individual recurring instances as complete

### 🤖 Discord Bot Integration

- **Natural Language Scheduling** — Create events using conversational commands
- **Event Notifications** — Receive reminders and updates directly in Discord
- **Quick Event Queries** — Check your schedule without leaving Discord
- **Multi-Server Support** — Deploy across multiple Discord servers
- **Command-Based Interface** — Intuitive slash commands and text-based interactions

### 🎨 Customization & UX

- **Theme Customization** — 6 preset color themes plus custom hex color input
- **Event Color Coding** — 5 preset colors per event with custom hex support
- **Visual Task Indicators** — Strikethrough and gray styling for completed items
- **Responsive Design** — Optimized layouts for desktop, tablet, and mobile devices
- **Professional Dialogs** — Intuitive form interfaces with validation
- **Smart Defaults** — Context-aware field auto-population

## Tech Stack

### Frontend

- **Flutter 3.x** — Cross-platform UI framework for web deployment
- **Dart 3.x** — Programming language with null safety
- **GetX** — State management, routing, and dependency injection
- **Syncfusion Calendar** — Professional-grade calendar widget
- **GetStorage** — Local data persistence

### Backend Services

#### API Server (Node.js)

- **Node.js 20.x** — JavaScript runtime environment
- **Express 5.x** — Minimalist web framework for REST API
- **RESTful Architecture** — Standard HTTP methods for CRUD operations
- **JSON Communication** — Structured data exchange format

#### Bot Server (Python)

- **Python 3.x** — Interpreted, high-level programming language
- **discord.py** — Python wrapper for Discord API (async/await support)
- **Natural Language Processing** — Parse scheduling commands from chat
- **Event Scheduling Logic** — Handle recurring events and reminders
- **Database Integration** — PostgreSQL connection for persistent storage
- **Webhook Support** — Real-time event notifications to Discord channels

### Infrastructure & Database

- **PostgreSQL** — Robust relational database for event and user data
- **Docker** — Containerization for consistent deployment
- **Docker Compose** — Multi-container orchestration
- **Nginx** (optional) — Reverse proxy and load balancing

### Development & Tools

- **VS Code** — IDE with Flutter, Dart, Python, and JavaScript extensions
- **Git** — Version control system
- **Shell Scripts** — Automated deployment and stack management

## Screenshots

### Calendar Views

| Month View                                   | Agenda View                                    |
| -------------------------------------------- | ---------------------------------------------- |
| ![Month View](docs/screenshots/month-view.png) | ![Agenda View](docs/screenshots/agenda-view.png) |

### Schedule Management

| Add Schedule                            | Edit Schedule                             | Recurring Options                                  |
| --------------------------------------- | ----------------------------------------- | -------------------------------------------------- |
| ![Add](docs/screenshots/add-schedule.png) | ![Edit](docs/screenshots/edit-schedule.png) | ![Recurring](docs/screenshots/recurring-options.png) |

### Discord Bot Interface

| Bot Commands                                 | Event Notifications                                    | Schedule Query                         |
| -------------------------------------------- | ------------------------------------------------------ | -------------------------------------- |
| ![Commands](docs/screenshots/bot-commands.png) | ![Notifications](docs/screenshots/bot-notifications.png) | ![Query](docs/screenshots/bot-query.png) |

### Customization

| Theme Settings                              | Color Picker                               | Custom Colors                              |
| ------------------------------------------- | ------------------------------------------ | ------------------------------------------ |
| ![Theme](docs/screenshots/theme-settings.png) | ![Colors](docs/screenshots/color-picker.png) | ![Custom](docs/screenshots/custom-color.png) |

## Architecture

### System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                            │
├─────────────────────────────────────────────────────────────────┤
│  Flutter Web App          │          Discord Client             │
│  (Browser-based UI)       │       (Bot Commands Interface)      │
└───────────┬───────────────┴──────────────────┬──────────────────┘
            │                                  │
            │ HTTP/REST API                    │ Discord API
            │                                  │
┌───────────▼──────────────────────────────────▼──────────────────┐
│                      Application Layer                           │
├──────────────────────────────┬───────────────────────────────────┤
│   Node.js API Server         │   Python Discord Bot Server       │
│   • Express REST endpoints   │   • discord.py framework          │
│   • Event CRUD operations    │   • Command handlers              │
│   • User authentication      │   • Natural language parsing      │
│   • Data validation          │   • Event notification system     │
└──────────────┬───────────────┴──────────────┬────────────────────┘
               │                              │
               │ SQL Queries                  │ SQL Queries
               │                              │
┌──────────────▼──────────────────────────────▼────────────────────┐
│                       Data Layer                                  │
├───────────────────────────────────────────────────────────────────┤
│                   PostgreSQL Database                             │
│   • Users table                                                   │
│   • Events table (with recurrence rules)                          │
│   • Discord server configurations                                │
│   • Notification queue                                            │
└───────────────────────────────────────────────────────────────────┘
```

### Project Structure

```
CalBot/
├── frontend/                           # Flutter Web Application
│   ├── lib/
│   │   ├── main.dart                  # Application entry point
│   │   ├── controllers/               # GetX State Controllers
│   │   │   ├── home_controller.dart   # Main calendar logic
│   │   │   └── widgets_controller/
│   │   │       ├── auth_controller.dart
│   │   │       ├── schedule_form_controller.dart
│   │   │       └── setting_controller.dart
│   │   ├── models/                    # Data Models
│   │   │   └── schedule_model.dart    # Event/Schedule model with recurrence
│   │   ├── services/                  # API communication layer
│   │   │   └── api_service.dart       # HTTP client for backend API
│   │   └── views/                     # UI Components
│   │       ├── home_view.dart         # Main calendar view
│   │       └── widgets/
│   │           ├── auth_dialog.dart
│   │           ├── custom_appbar.dart
│   │           ├── schedule_form_dialog.dart
│   │           └── settings_drawer.dart
│   ├── assets/
│   │   └── images/                    # App icons and graphics
│   └── web/                           # Web-specific configurations
│
├── backend/                            # Backend Services
│   ├── node-server/                   # Node.js API Server
│   │   ├── src/
│   │   │   ├── server.js              # Express server entry point
│   │   │   ├── routes/
│   │   │   │   ├── api.js             # Main API routes
│   │   │   │   ├── events.js          # Event CRUD endpoints
│   │   │   │   ├── users.js           # User management endpoints
│   │   │   │   └── health/            # Health check endpoints
│   │   │   ├── middleware/
│   │   │   │   ├── auth.js            # Authentication middleware
│   │   │   │   └── validation.js      # Request validation
│   │   │   ├── models/                # Database models
│   │   │   │   ├── event.js
│   │   │   │   └── user.js
│   │   │   └── db/
│   │   │       └── connection.js      # PostgreSQL connection pool
│   │   └── package.json
│   │
│   └── discord-bot/                   # Python Discord Bot Server
│       ├── bot.py                     # Main bot application
│       ├── cogs/                      # Command modules (Discord.py cogs)
│       │   ├── calendar_commands.py   # Calendar-related commands
│       │   ├── event_management.py    # Event CRUD via Discord
│       │   └── reminders.py           # Notification/reminder system
│       ├── utils/
│       │   ├── parser.py              # Natural language date/time parser
│       │   ├── formatter.py           # Discord embed formatters
│       │   └── db_helper.py           # Database utility functions
│       ├── config.py                  # Bot configuration and settings
│       ├── requirements.txt           # Python dependencies
│       └── .env.example               # Environment variables template
│
├── database/                           # Database configurations
│   ├── schema.sql                     # PostgreSQL schema definitions
│   ├── migrations/                    # Database migration scripts
│   └── seeds/                         # Sample data for development
│
├── docker/                            # Docker configurations
│   ├── Dockerfile.api                 # API server container
│   ├── Dockerfile.bot                 # Discord bot container
│   └── Dockerfile.frontend            # Frontend container (if applicable)
│
├── postgres-stack.yml                 # Docker Compose for PostgreSQL
├── deploy-stack.sh                    # Deployment automation script
├── .env.example                       # Environment variables template
└── README.md                          # This file
```

### Service Communication Flow

**Web Interface → API → Database:**

```
User Action (Flutter) → HTTP Request → Express API → PostgreSQL → Response → UI Update
```

**Discord Bot → Database:**

```
Discord Command → discord.py Handler → PostgreSQL → Discord Embed Response
```

**Event Notification Flow:**

```
PostgreSQL (Event Queue) → Bot Scheduler → Discord Webhook → User Notification
```

### Design Patterns & Principles

**MVC Architecture** — Clear separation of Models, Views, and Controllers across all services for maintainability and scalability

**Microservices Pattern** — Independent, containerized services (Web Frontend, API Server, Bot Server, Database) that communicate via well-defined interfaces

**Reactive Programming** — Observable state management using GetX reactive types (Rx) for real-time UI updates

**Dependency Injection** — Decoupled component management via GetX `Get.put()` and `Get.find()` for testability

**Repository Pattern** — Abstracted data access layer for clean separation between business logic and data storage

**Command Pattern** — Discord bot uses command/cog pattern for modular and extensible bot functionality

**Async/Await** — Non-blocking I/O operations in both Node.js and Python services for optimal performance

### Discord Bot Features

**Slash Commands:**

- `/schedule add [title] [date] [time]` — Create a new event
- `/schedule list [date]` — View events for a specific day
- `/schedule delete [id]` — Remove an event
- `/schedule upcoming` — Show next 7 days of events
- `/reminder set [event_id] [minutes_before]` — Set event reminders

**Natural Language Processing:**

- "Remind me about the meeting tomorrow at 3pm"
- "Schedule dentist appointment next Friday"
- "What's on my calendar this week?"

**Notification System:**

- Pre-event reminders (configurable timing)
- Daily agenda summaries
- Event updates and cancellations
- Recurring event notifications

### Database Schema

**Events Table:**

- `id`, `user_id`, `title`, `start_time`, `end_time`
- `location`, `notes`, `color`, `is_all_day`
- `recurrence_rule` (RRULE format), `recurrence_exceptions`
- `done_occurrences` (JSON array of completed instances)
- `created_at`, `updated_at`

**Users Table:**

- `id`, `discord_id`, `username`, `email`
- `timezone`, `notification_preferences` (JSON)
- `created_at`, `last_active`

**Discord Servers Table:**

- `id`, `server_id`, `server_name`, `prefix`
- `notification_channel_id`, `settings` (JSON)

---

**Built with ❤️ using Flutter, Node.js, and Python**
