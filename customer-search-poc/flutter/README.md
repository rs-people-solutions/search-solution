# Customer Search - Flutter Frontend

A Flutter mobile application for searching customers, built to mirror the React web frontend functionality.

## Features

- **Search-as-you-type** with 400ms debouncing
- **Pagination** support (100 results per page)
- **Auto-focus** on search input
- **Loading states** with visual feedback
- **Error handling** with user-friendly messages
- **Clean UI** matching the React frontend design

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Running backend server (see main project README)

## Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure API endpoint:**
   
   Edit `lib/services/customer_service.dart` and update the `apiBaseUrl`:
   
   ```dart
   static const String apiBaseUrl = 'YOUR_API_URL';
   ```
   
   - For **Android Emulator**: `http://10.0.2.2:3000/api`
   - For **iOS Simulator**: `http://localhost:3000/api`
   - For **Physical Device**: `http://YOUR_COMPUTER_IP:3000/api`
   - For **Production**: `https://your-server.com/api`

## Running the App

### Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device_id>
```

### Build for Production

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

## Project Structure

```
lib/
├── main.dart                    # App entry point and main screen
├── models/
│   └── customer.dart           # Customer data model
├── services/
│   └── customer_service.dart   # API communication
├── widgets/
│   ├── search_box.dart         # Search input with debouncing
│   ├── customer_list.dart      # Customer results display
│   └── pagination.dart         # Pagination controls
└── theme/
    └── app_theme.dart          # App-wide theme and colors
```

## API Integration

The app connects to the same backend API as the React frontend:

- **Endpoint**: `GET /api/search?q={query}&page={page}`
- **Response**: JSON with `query` and `results` array
- **Pagination**: 100 results per page

## Troubleshooting

### Cannot connect to API

1. Ensure the backend server is running
2. Check the `apiBaseUrl` in `customer_service.dart`
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. For physical devices, ensure your device and computer are on the same network

### Dependencies issues

```bash
flutter clean
flutter pub get
```

### Build errors

```bash
flutter doctor  # Check Flutter installation
flutter upgrade # Update Flutter SDK
```

## Development Notes

- The app uses **StatefulWidget** for state management (simple approach)
- For larger apps, consider using **Provider**, **Riverpod**, or **Bloc**
- The theme matches the React frontend colors (#3498DB, #2C3E50, etc.)
- Search debouncing prevents excessive API calls during typing

## License

Same as the main project.
