# Employee Leave Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)

Cross-platform mobile application for Employee Leave Management System with real-time notifications.

## ✨ Features

- 🔐 **JWT Authentication** - Secure login with token persistence
- 📊 **Dashboard** - Leave balance overview and recent requests
- 📝 **Leave Requests** - Submit with file attachments
- 📜 **Leave History** - View and cancel pending requests
- 👤 **Profile Management** - Update personal information
- 🔔 **Real-time Notifications** - SignalR + Firebase Cloud Messaging
- 🌐 **PWA Support** - Deploy as Progressive Web App

## 📁 Project Structure

```
emp_leave_app/
├── lib/
│   ├── core/
│   │   ├── api/                  # API client (Dio)
│   │   ├── constants/            # App constants
│   │   ├── services/             # Notification service
│   │   └── theme/                # App theme
│   ├── features/
│   │   ├── auth/                 # Login screen
│   │   ├── dashboard/            # Dashboard screen
│   │   ├── leave/                # Leave request & history
│   │   └── profile/              # Profile screen
│   ├── models/                   # Data models
│   ├── providers/                # Riverpod state management
│   ├── widgets/                  # Reusable widgets
│   └── main.dart                 # Entry point
├── pubspec.yaml                  # Dependencies
├── Dockerfile                    # Flutter Web container
└── docker-compose.yml            # Full stack orchestration
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / Xcode (for mobile)

### Run on Device/Emulator

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Run on specific platform
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
```

### Build APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build Web (PWA)

```bash
flutter build web
# Output: build/web/
```

### Docker Deployment

```bash
# Build and run as web app
docker-compose up --build

# Access at http://localhost:8080
```

## 🔗 API Configuration

Update API URL in `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // For iOS Simulator / Web
  // static const String baseUrl = 'http://localhost:5000/api';

  // For Production
  // static const String baseUrl = 'https://your-api.com/api';
}
```

## 🔔 Notifications

### SignalR (In-App)

Real-time notifications for leave status updates:

- Approval/rejection alerts
- New request notifications (for managers)

### Firebase Cloud Messaging (Background)

Push notifications when app is closed:

- Configure in `android/app/google-services.json`
- Configure in `ios/Runner/GoogleService-Info.plist`

## 📦 Key Dependencies

| Package              | Purpose            |
| -------------------- | ------------------ |
| `flutter_riverpod`   | State management   |
| `dio`                | HTTP client        |
| `signalr_netcore`    | Real-time SignalR  |
| `firebase_messaging` | Push notifications |
| `file_picker`        | File attachments   |
| `shared_preferences` | Token persistence  |

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Supported Platforms

| Platform  | Status          |
| --------- | --------------- |
| Android   | ✅ Supported    |
| iOS       | ✅ Supported    |
| Web (PWA) | ✅ Supported    |
| Windows   | 🔄 Experimental |
| macOS     | 🔄 Experimental |

## 🐳 Docker Architecture

```
┌─────────────────────────────────────┐
│         Nginx :80 (Flutter Web)     │
│         Static file serving         │
└─────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│       Backend API :8080             │
│     (SignalR + REST endpoints)      │
└─────────────────────────────────────┘
```

## 📄 License

MIT License
