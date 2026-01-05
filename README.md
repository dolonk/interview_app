# e-Signature App

A comprehensive Flutter application for electronic document signing and management. Built with Clean Architecture, Riverpod, and Firebase.

## 📦 Deliverables
- **Source Code**: [GitHub Repository Link](https://github.com/dolonk/e_signature.git)
- **APK File**: `build/app/outputs/flutter-apk/app-release.apk`

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (3.10.x or higher)
- Dart SDK
- Android Studio
- Firebase Account

### Installation
1. **Clone the repository**
   ```bash
   git clone https://github.com/dolonk/e_signature.git
   cd e_signature
   ```

### 📺 App Demo
Watch the app in action here:

[![Watch the video](https://img.youtube.com/vi/1Ttc4zyudG4/maxresdefault.jpg)](https://youtu.be/1Ttc4zyudG4)

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔥 Firebase Configuration
This app uses Firebase for Authentication. You must configure it for the app to work.

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Create a new project.
3. Enable **Authentication** and set up **Email/Password** provider.
4. **Android Setup**:
   - Register app with package name: `com.example.e_signature`.
   - Download `google-services.json`.
   - Place it in: `android/app/google-services.json`.
5. **iOS Setup**:
   - Register app with Bundle ID.
   - Download `GoogleService-Info.plist`.
   - Place it in: `ios/Runner/GoogleService-Info.plist`.

## 🏗️ App Architecture
The project follows **Clean Architecture** principles to ensure separation of concerns and maintainability.

```
lib/
├── core/             # Core utilities, theme, dependency injection
├── features/         # Feature-based modules (Auth, Editor, Documents)
│   ├── data/         # Repositories, Models, Data Sources
│   ├── domain/       # Entities, Usecases, Repository Interfaces
│   └── presentation/ # UI Screens, Widgets, ViewModels (Riverpod)
├── route/            # Navigation configuration
└── shared/           # Shared components and entities
```

### State Management
- **Riverpod** is used for state management and dependency injection.
- **StateNotifier** pattern is used for ViewModels.

## 🛠️ Tech Stack & Packages

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: `flutter_riverpod`
- **Backend/Auth**: `firebase_auth`, `firebase_core`
- **Database**: `isar` (Local caching)
- **PDF Handling**: `syncfusion_flutter_pdf`, `syncfusion_flutter_pdfviewer`, `pdf_image_renderer`
- **UI Components**: `flutter_screenutil`, `gap`
- **Utilities**: `file_picker`, `share_plus`, `path_provider`

## ✨ Key Features
- **User Authentication**: Login/Register with Firebase.
- **Document Management**: Upload, list, and delete documents.
- **PDF Editor**:
  - Drag and drop fields (Signature, Date, Text).
  - Resizable and draggable elements.
  - Multi-page PDF support.
- **Signing Mode**: Fill in fields and sign documents.
- **Export/Share**: Generate final signed PDFs and share them.
