# CalBot Frontend

A **Flutter Web** calendar application with professional scheduling features, reactive state management, and beautiful UI.

---

## 🌟 Features

### Core Functionality
- ✅ **Calendar Views** — Month view with optional agenda panel
- ✅ **Event Management** — Full CRUD operations with intuitive dialogs
- ✅ **All-Day Events** — Toggle for full-day scheduling
- ✅ **Location & Notes** — Rich event details

### Advanced Recurring Events (RFC 5545)
- ✅ **Daily/Weekly/Monthly** — Flexible recurrence patterns
- ✅ **Weekly Multi-Day** — Select Mon, Wed, Fri etc.
- ✅ **Monthly by Day** — "On day 15" of each month
- ✅ **Monthly by Position** — "First Monday" or "Last Friday"
- ✅ **End Conditions** — Forever, until date, or after N occurrences
- ✅ **Exception Dates** — Delete single occurrences from series
- ✅ **Per-Occurrence Tracking** — Mark individual occurrences done

### Customization
- ✅ **Theme Colors** — 6 presets + custom hex input
- ✅ **Event Colors** — 5 presets + custom hex input
- ✅ **Visual Done State** — Strikethrough + gray color

### State Management
- ✅ **GetX** — Reactive controllers with Rx observables
- ✅ **GetStorage** — Local persistence for preferences

---

## 🛠️ Tech Stack

| Package | Version | Purpose |
|---------|---------|---------|
| Flutter | 3.x | UI Framework |
| GetX | 4.7.3 | State Management |
| Syncfusion Calendar | 31.2.12 | Calendar Widget |
| GetStorage | 2.0.3 | Local Storage |
| intl | 0.20.2 | Date Formatting |

---

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Build for production
flutter build web --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── controllers/
│   ├── home_controller.dart     # Calendar state & schedule list
│   └── widgets_controller/
│       ├── auth_controller.dart
│       ├── schedule_form_controller.dart  # Form state & recurrence logic
│       └── setting_controller.dart        # Theme & preferences
├── models/
│   └── schedule_model.dart      # ScheduleModel + NoteData
└── views/
    ├── home_view.dart           # Main calendar view
    └── widgets/
        ├── auth_dialog.dart
        ├── custom_appbar.dart
        ├── schedule_form_dialog.dart  # Add/Edit schedule form
        └── settings_drawer.dart       # Settings panel
```

---

## 📄 License

ISC License
