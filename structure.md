lib/
├── main.dart
├── app/
│   ├── data/
│   │   ├── models/
│   │   │   └── user_model.dart
│   │   ├── providers/
│   │   │   ├── network/
│   │   │   │   └── api_provider.dart
│   │   │   └── local/
│   │   │       └── local_storage_provider.dart
│   │   └── repositories/
│   │       └── user_repository.dart
│   │
│   ├── modules/
│   │   ├── home/
│   │   │   ├── controllers/
│   │   │   │   └── home_controller.dart
│   │   │   ├── views/
│   │   │   │   └── home_view.dart
│   │   │   └── bindings/
│   │   │       └── home_binding.dart
│   │   │
│   │   ├── auth/
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart
│   │   │   ├── views/
│   │   │   │   ├── login_view.dart
│   │   │   │   └── register_view.dart
│   │   │   └── bindings/
│   │   │       └── auth_binding.dart
│   │   │
│   │   └── profile/
│   │       ├── controllers/
│   │       │   └── profile_controller.dart
│   │       ├── views/
│   │       │   └── profile_view.dart
│   │       └── bindings/
│   │           └── profile_binding.dart
│   │
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   │
│   └── core/
│       ├── utils/
│       │   └── helpers.dart
│       ├── values/
│       │   ├── colors.dart
│       │   ├── strings.dart
│       │   └── text_styles.dart
│       ├── theme/
│       │   └── app_theme.dart
│       └── widgets/
│           ├── custom_button.dart
│           └── loading_widget.dart
│
└── services/
    ├── storage_service.dart
    ├── api_service.dart
    └── auth_service.dart