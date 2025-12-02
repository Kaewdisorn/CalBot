# 🗓️ CalBot — Smart Calendar & Scheduling Application

<div align="center">

![CalBot Logo](frontend/assets/images/halulu_128x128.png)

**A modern, feature-rich calendar application built with Flutter Web and Node.js**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-5.x-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)

[Features](#-features) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack) • [Architecture](#-architecture) • [Getting Started](#-getting-started)

</div>

---

## 📋 Overview

CalBot is a professional-grade calendar and scheduling application designed for productivity and ease of use. Built with a modern tech stack, it offers comprehensive event management with support for recurring events, custom themes, and an intuitive user interface.

The application demonstrates advanced software engineering practices including:
- **Reactive State Management** with GetX
- **RFC 5545 Compliant** recurrence rules
- **Responsive Design** for all screen sizes
- **Clean Architecture** with separation of concerns

---

## ✨ Features

### 📅 Calendar Management
- **Multiple Views** — Month view with agenda panel support
- **Event CRUD** — Create, read, update, and delete events with ease
- **All-Day Events** — Support for full-day scheduling
- **Location & Notes** — Rich event details with optional fields

### 🔄 Advanced Recurring Events
- **Flexible Patterns** — Daily, Weekly, Monthly recurrence options
- **Weekly Multi-Day** — Select multiple days of the week (Mon, Wed, Fri)
- **Monthly Options** — By day number (15th) or by position (2nd Tuesday)
- **End Conditions** — Forever, until date, or after N occurrences
- **Exception Dates** — Delete single occurrences without affecting the series
- **Per-Occurrence Tracking** — Mark individual occurrences as done

### 🎨 Customization
- **Theme Colors** — 6 preset colors + custom hex color input
- **Event Colors** — 5 preset colors per event + custom hex support
- **Visual Indicators** — Strikethrough and gray color for completed tasks

### 💡 User Experience
- **Responsive Design** — Optimized for desktop, tablet, and mobile
- **Intuitive Dialogs** — Professional form dialogs with validation
- **Quick Actions** — One-click toggles for all-day and done status
- **Smart Defaults** — Auto-populated fields based on context

---

## 📸 Screenshots

> **📌 Add your screenshots to the `docs/screenshots/` folder**

### Calendar View
| Month View | Agenda View |
|:---:|:---:|
| ![Month View](docs/screenshots/month-view.png) | ![Agenda View](docs/screenshots/agenda-view.png) |

### Schedule Management
| Add Schedule | Edit Schedule | Recurring Options |
|:---:|:---:|:---:|
| ![Add](docs/screenshots/add-schedule.png) | ![Edit](docs/screenshots/edit-schedule.png) | ![Recurring](docs/screenshots/recurring-options.png) |

### Customization
| Theme Settings | Color Picker | Custom Colors |
|:---:|:---:|:---:|
| ![Theme](docs/screenshots/theme-settings.png) | ![Colors](docs/screenshots/color-picker.png) | ![Custom](docs/screenshots/custom-color.png) |

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter 3.x** | Cross-platform UI framework |
| **Dart 3.x** | Programming language |
| **GetX** | State management, routing, dependency injection |
| **Syncfusion Calendar** | Professional calendar widget |
| **GetStorage** | Local persistence |

### Backend
| Technology | Purpose |
|------------|---------|
| **Node.js 20.x** | Runtime environment |
| **Express 5.x** | Web framework |
| **Docker** | Containerization |

### Development Tools
| Tool | Purpose |
|------|---------|
| **VS Code** | IDE with Flutter/Dart extensions |
| **Docker Compose** | Multi-container orchestration |
| **Git** | Version control |

---

## 🏗️ Architecture

```
CalBot/
├── frontend/                    # Flutter Web Application
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   ├── controllers/        # GetX Controllers
│   │   │   ├── home_controller.dart
│   │   │   └── widgets_controller/
│   │   │       ├── auth_controller.dart
│   │   │       ├── schedule_form_controller.dart
│   │   │       └── setting_controller.dart
│   │   ├── models/             # Data Models
│   │   │   └── schedule_model.dart
│   │   └── views/              # UI Components
│   │       ├── home_view.dart
│   │       └── widgets/
│   │           ├── auth_dialog.dart
│   │           ├── custom_appbar.dart
│   │           ├── schedule_form_dialog.dart
│   │           └── settings_drawer.dart
│   ├── assets/
│   │   └── images/
│   └── web/
│
├── backend/                     # Node.js API Server
│   └── node-server/
│       ├── src/
│       │   ├── server.js
│       │   └── routes/
│       │       ├── api.js
│       │       └── health/
│       └── package.json
│
├── Dockerfile                   # Container configuration
├── deploy.sh                    # Deployment script
└── README.md
```

### Design Patterns

- **MVC Pattern** — Models, Views, Controllers separation
- **Reactive Programming** — Observable state with GetX Rx types
- **Dependency Injection** — GetX `Get.put()` and `Get.find()`
- **Repository Pattern** — Data layer abstraction (ready for backend integration)

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or later)
- [Node.js](https://nodejs.org/) (20.x or later)
- [Docker](https://docker.com/) (optional, for containerized deployment)

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Run in development mode (Chrome)
flutter run -d chrome

# Build for production
flutter build web --release
```

### Backend Setup

```bash
# Navigate to backend directory
cd backend/node-server

# Install dependencies
npm install

# Run in development mode
npm run dev

# Run in production mode
npm start
```

### Docker Deployment

```bash
# Build and run with Docker
docker build -t calbot .
docker run -p 3000:3000 calbot

# Or use deploy script
./deploy.sh
```

---

## 📁 Key Components

### Schedule Model
Comprehensive event model supporting:
- Basic properties (title, start, end, location, notes)
- Recurrence rules (RFC 5545 compliant)
- Exception dates for recurring events
- Per-occurrence done tracking with `NoteData` class
- Color customization

### Schedule Form Controller
Advanced recurrence management:
- Frequency options (Never, Daily, Weekly, Monthly)
- Interval settings (every N days/weeks/months)
- Weekly day selection with multi-select
- Monthly modes (by day number or week position)
- End conditions (forever, until date, count)

### Settings Controller
Theme and preferences:
- Persistent color theme storage
- Custom hex color parsing and validation
- Animation controllers for smooth transitions

---

## 🎯 Future Roadmap

- [ ] **Backend Integration** — Full API connectivity with PostgreSQL
- [ ] **Discord Bot** — Natural language scheduling via chat
- [ ] **Push Notifications** — Event reminders
- [ ] **Google Calendar Sync** — Two-way synchronization
- [ ] **Multi-User Support** — Shared calendars and collaboration
- [ ] **Dark Mode** — System theme detection

---

## 👨‍💻 Author

**Kaewdisorn**

- GitHub: [@Kaewdisorn](https://github.com/Kaewdisorn)

---

## 📄 License

This project is licensed under the ISC License.

---

<div align="center">

**Built with ❤️ using Flutter & Node.js**

</div>