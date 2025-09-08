# The Lock-In Factory

A social accountability application that leverages the observer effect and positive peer pressure to help users accomplish their goals. The app documents your journey every step of the way, creating transparency and motivation through community support.

The current MVP includes authentication, username management, and a foundational home page. The app is built with Flutter for cross-platform support and Firebase for backend services.

## 🚀 Getting Started

These instructions will help you set up the project for local development across all supported platforms (iOS, Android, Web, Windows, macOS, Linux).

### Prerequisites

Before you begin, ensure you have the following installed on your development machine:

#### Required Software

- **Flutter SDK**: `>=3.8.1` 
  - [Install Flutter](https://docs.flutter.dev/get-started/install)
  - Verify installation: `flutter --version`

- **Dart SDK**: Included with Flutter
  - Required version: `>=3.8.1`

- **Git**: For version control
  - [Download Git](https://git-scm.com/downloads)

- **Code Editor**: 
  - [Visual Studio Code](https://code.visualstudio.com/) with Flutter extensions
  - [Android Studio](https://developer.android.com/studio) with Flutter plugin
  - [IntelliJ IDEA](https://www.jetbrains.com/idea/) with Flutter plugin

#### Platform-Specific Requirements

**For Android Development:**
- **Android Studio**: Latest stable version
- **Android SDK**: API level 21 or higher
- **Java Development Kit (JDK)**: Version 11 or higher

**For iOS Development (macOS only):**
- **Xcode**: Latest stable version (14.0+)
- **iOS Simulator**: Included with Xcode
- **CocoaPods**: `gem install cocoapods`

**For Web Development:**
- **Chrome Browser**: For debugging and testing

**For Windows Development:**
- **Visual Studio 2022**: With C++ build tools
- **Windows 10 SDK**: Version 10.0.17763.0 or higher

**For macOS Development:**
- **Xcode**: Latest stable version
- **macOS SDK**: Latest version

**For Linux Development:**
- **Build essentials**: `sudo apt-get install build-essential`
- **GTK development libraries**: `sudo apt-get install libgtk-3-dev`

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/the_lock_in_factory.git
   cd the_lock_in_factory
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify your Flutter installation**
   ```bash
   flutter doctor
   ```
   
   Ensure all checkmarks are green for your target platforms. Address any issues before proceeding.

4. **Verify project setup**
   ```bash
   flutter analyze
   flutter test
   ```

## 🔥 Firebase Setup

This project uses Firebase for authentication, Firestore database, and other backend services. You'll need to set up your own Firebase project.

### 1. Create Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., `your-project-id`)
4. Follow the setup wizard

### 2. Enable Required Services

In your Firebase project console, enable the following services:

- **Authentication**
  - Go to Authentication > Sign-in method
  - Enable Google Sign-in provider
  - Add your domain to authorized domains

- **Cloud Firestore**
  - Go to Firestore Database
  - Create database in test mode (or production mode with proper rules)

- **Cloud Storage** (if needed)
  - Go to Storage
  - Get started with default settings

### 3. Platform-Specific Configuration

#### FlutterFire CLI (Recommended)

1. **Install FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Configure FlutterFire**
   ```bash
   flutterfire configure
   ```
   
   This will:
   - Generate `lib/firebase_options.dart`
   - Create platform-specific configuration files
   - Set up your project ID in all platforms

#### Manual Configuration (Alternative)

**Android Setup:**
1. Download `google-services.json` from Firebase Console > Project Settings > Your Apps > Android
2. Place it in `android/app/google-services.json`
3. **Note**: This file is gitignored for security

**iOS Setup:**
1. Download `GoogleService-Info.plist` from Firebase Console > Project Settings > Your Apps > iOS
2. Place it in `ios/Runner/GoogleService-Info.plist`
3. **Note**: This file is gitignored for security

**Web Setup:**
1. Add Firebase SDK configuration to `web/index.html`
2. Use the config from Firebase Console > Project Settings > Your Apps > Web

### 4. Security Rules

Set up Firestore security rules in Firebase Console > Firestore Database > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Add more rules as needed for your collections
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Environment Variables

Create a `.env` file in the project root for local development:
```bash
# Copy from your Firebase project settings
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
```

**⚠️ Security Note**: Never commit Firebase configuration files or API keys to version control. These are already included in `.gitignore`.

## 📱 Running the App

### Development Mode

**Run on all available devices:**
```bash
flutter run
```

**Run on specific platforms:**

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d web-server --web-port 8080

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Platform-Specific Instructions

#### Android
1. Enable Developer Options and USB Debugging on your device
2. Connect via USB or start an Android emulator
3. Run: `flutter run -d android`

#### iOS (macOS only)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your target device/simulator
3. Build and run from Xcode, or use: `flutter run -d ios`

#### Web
1. Run: `flutter run -d web-server`
2. Open browser to `http://localhost:8080`
3. Use Chrome for best debugging experience

### Release Builds

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🔧 Development Workflow

### Hot Reload
- Press `r` in the terminal while running `flutter run`
- Use your IDE's hot reload button
- Changes to Dart code will update instantly

### Hot Restart
- Press `R` in the terminal while running `flutter run`
- Restarts the app completely
- Use when hot reload doesn't reflect changes

### Code Formatting
```bash
# Format all Dart files
dart format .

# Check formatting
dart format --set-exit-if-changed .
```

### Linting
```bash
# Analyze code for issues
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Dependencies
```bash
# Add new dependency
flutter pub add package_name

# Add dev dependency
flutter pub add --dev package_name

# Update dependencies
flutter pub upgrade

# Get dependencies after checkout
flutter pub get
```

## 🧪 Testing

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Integration Tests
```bash
# Run integration tests
flutter test integration_test/
```

### Widget Tests
```bash
# Run widget tests specifically
flutter test test/widget/
```

### Coverage Reports
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   └── user_profile.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── username_selection_page.dart
│   └── home/
│       └── home_page.dart
├── services/                 # Business logic services
│   ├── auth_service.dart
│   └── user_service.dart
├── utils/                    # Utility functions
│   └── validation_utils.dart
├── widgets/                  # Reusable UI components
│   └── google_sign_in_button.dart
└── wrappers/                 # App-level wrappers
    └── auth_wrapper.dart

android/                      # Android-specific code
ios/                         # iOS-specific code
web/                         # Web-specific code
windows/                     # Windows-specific code
macos/                       # macOS-specific code
linux/                       # Linux-specific code
test/                        # Unit and widget tests
assets/                      # Static assets (images, etc.)
```

## 🔧 Troubleshooting

### Common Issues

#### Flutter Doctor Issues
```bash
# Update Flutter
flutter upgrade

# Clean and reinstall
flutter clean
flutter pub get
```

#### Android Build Issues
```bash
# Clean Android build
cd android && ./gradlew clean && cd ..
flutter clean
flutter pub get
```

#### iOS Build Issues (macOS only)
```bash
# Clean iOS build
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter clean
flutter pub get
```

#### Web Build Issues
```bash
# Clear web build cache
flutter clean
flutter pub get
flutter build web
```

#### Firebase Connection Issues
1. Verify Firebase project configuration
2. Check internet connectivity
3. Ensure Firebase services are enabled
4. Verify API keys and project IDs

#### Package Conflicts
```bash
# Reset dependencies
flutter clean
rm pubspec.lock
flutter pub get
```

### Getting Help

- **Flutter Documentation**: https://docs.flutter.dev
- **Firebase Documentation**: https://firebase.google.com/docs
- **Stack Overflow**: Tag questions with `flutter` and `firebase`
- **Flutter Community**: https://flutter.dev/community

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Run tests and linting**
   ```bash
   flutter analyze
   flutter test
   ```
5. **Commit your changes**
   ```bash
   git commit -m "feat: add your feature description"
   ```
6. **Push to your branch**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` before committing
- Ensure `flutter analyze` passes
- Write tests for new features

### Commit Messages

Use conventional commits format:
- `feat:` new features
- `fix:` bug fixes  
- `docs:` documentation changes
- `style:` formatting changes
- `refactor:` code refactoring
- `test:` adding tests
- `chore:` maintenance tasks

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. **Check the Troubleshooting section** above
2. **Search existing issues** in the GitHub repository
3. **Create a new issue** with detailed information:
   - Operating system and version
   - Flutter version (`flutter --version`)
   - Error messages and stack traces
   - Steps to reproduce

## 📖 About

The Lock-In Factory is a social accountability application designed to help users achieve their goals through community support and positive peer pressure. By documenting your journey and sharing progress with others, the app creates motivation through transparency and social accountability.

### Key Features

- **Goal Setting and Tracking**: Set personal goals and track progress
- **Social Accountability**: Share your journey with a supportive community
- **Progress Documentation**: Keep detailed records of your progress
- **Peer Support**: Encourage and be encouraged by others
- **Cross-Platform**: Available on iOS, Android, Web, and Desktop

### Technology Stack

- **Frontend**: Flutter (cross-platform mobile and web)
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)
- **State Management**: Provider pattern
- **Authentication**: Firebase Auth with Google Sign-In
- **Database**: Cloud Firestore
- **Hosting**: Firebase Hosting (Web)

---

**Happy coding! 🚀**
