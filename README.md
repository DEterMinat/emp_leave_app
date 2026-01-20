# Employee Leave Mobile App

Flutter mobile application for Employee Leave Management System.

## Features

- 🔐 User Authentication (JWT)
- 📊 Dashboard with Leave Balance
- 📝 Request Leave
- 📜 View Leave History

## Getting Started

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # API client, constants, theme
├── features/       # Feature modules (auth, dashboard, leave)
├── models/         # Data models
├── providers/      # Riverpod state management
└── widgets/        # Reusable widgets
```

## Backend API

Make sure the backend is running at `http://localhost:5000`.
For Android Emulator, use `http://10.0.2.2:5000`.

## Configuration

Update API URL in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```
