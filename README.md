# Spotter Frontend Flutter Conversion Plan

## 1. Development Environment Setup

- Flutter SDK (Latest stable version)
- Android Studio / VS Code with Flutter plugins
- Required dependencies in `pubspec.yaml`

## 2. Core Libraries & Alternatives

### UI Components (MUI Alternatives)
- **Material Design**: `flutter/material.dart`
- **Custom Widgets**: `flutter/widgets.dart`
- **Extended Widgets**: `flutter_form_builder` for complex forms
- **Data Tables**: `data_tables_2` package for MUI DataGrid alternative

### Maps Implementation
- **Google Maps**: `google_maps_flutter` package
  - Native performance
  - Custom markers support
  - Camera controls
  - Location tracking

### State Management (React Alternatives)
- **Provider**: Simple state management
- **Riverpod**: More robust state management with dependency injection
- **Bloc**: Complex state management with event-driven architecture

### Network & API
- **Dio**: HTTP client for API calls
- **Retrofit**: Type-safe API client generator
- **Json Serialization**: `json_serializable` for model classes

### Media Handling (New Features)
- **camera**: Native camera access
- **image_picker**: Media selection
- **photo_view**: Image viewing with zoom
- **video_player**: Video playback
- **ffmpeg_kit_flutter**: Video processing
- **image**: Image processing and watermarking

## 3. Project Structure

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── routes.dart
│   └── theme.dart
├── features/
│   ├── auth/
│   ├── reports/
│   ├── camera/
│   └── maps/
├── core/
│   ├── api/
│   ├── models/
│   └── utils/
└── shared/
    ├── widgets/
    └── constants/
```

## 4. Feature Implementation Details

### Authentication Flow
```dart
// Implementation using Provider
class AuthProvider extends ChangeNotifier {
  User? _user;
  
  Future<void> login() async {
    // Implement SingPass authentication
  }
  
  Future<void> logout() async {
    // Clear user data and navigate
  }
}
```

### Reports Module
```dart
// Report model
@JsonSerializable()
class Report {
  final int id;
  final double latitude;
  final double longitude;
  final double? bearing;
  final String? remarks;
  final String? mediaUrl;
  
  Report({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.bearing,
    this.remarks,
    this.mediaUrl,
  });
}

// Reports repository
class ReportsRepository {
  final Dio _dio;
  
  Future<List<Report>> getReports() async {
    // Implement API calls
  }
}
```

### Enhanced Camera Features
```dart
class CameraService {
  late CameraController _controller;
  
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller.initialize();
  }
  
  Future<XFile> takePhoto() async {
    // Implement photo capture with watermark
  }
  
  Future<XFile> recordVideo() async {
    // Implement video recording with watermark
  }
}
```

### Maps Integration
```dart
class MapView extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: _markers,
      initialCameraPosition: _initialPosition,
      onMapCreated: _onMapCreated,
    );
  }
}
```

## 5. New Features Implementation

### Photo Capture Enhancements
- Custom camera controls
- Resolution selection
- Zoom controls
- Watermark overlay
- Direct upload (bypass storage)
- Image annotation tools

### Video Recording Enhancements
- Quality selection
- Duration limits
- Compression options
- Real-time watermarking
- Custom recording controls

## 6. Data Flow

1. User Authentication
   - SingPass integration
   - Token management
   - Session handling

2. Report Submission
   - Form validation
   - Media processing
   - API integration
   - Progress tracking

3. Media Management
   - Capture → Process → Upload flow
   - Watermark application
   - Compression
   - Caching strategy

## 7. Security Considerations

- Secure storage for tokens
- Media encryption
- Network security
- Permission handling
- Prevention of local storage

## 8. Testing Strategy

- Unit tests for business logic
- Widget tests for UI components
- Integration tests for features
- Performance testing for media handling
