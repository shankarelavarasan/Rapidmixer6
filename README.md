# RapidMixer - AI-Powered Music Production App

## Overview
RapidMixer is a comprehensive Flutter-based music production application that allows users to upload songs, separate them into individual instrument tracks using AI, and create professional mixes with advanced audio controls.

## Features

### 🎵 AI-Powered Stem Separation
- **Multiple AI Services**: Integrates with Spleeter, Voice.ai, and Soundverse APIs
- **Instrument Separation**: Automatically separates uploaded songs into:
  - Vocals, Drums, Bass, Piano/Keyboard, Guitar, Violin, Flute, Other instruments
- **Fallback Processing**: Uses FFmpeg for local processing when APIs are unavailable

### 🎛️ Advanced Multi-Track Editor
- **Individual Track Controls**: Volume, Pitch, Speed, Pan, Mute/Solo functionality
- **Professional Audio Effects**: Reverb, Echo/Delay, 3-Band Equalizer
- **Master Effects**: Apply effects to the entire mix
- **Real-time Processing**: All effects applied in real-time

### 🎼 Comprehensive Beat Library
- **Multiple Genres**: Hip Hop, Electronic, Rock, Jazz, Classical, Pop, Reggae, Country, R&B
- **Beat Features**: BPM information, Duration display, Waveform visualization, Preview playback
- **Organization**: Browse, Favorites, and Recent tabs with search and filter functionality

### 🎯 Advanced Mixing Features
- **Tempo Control**: Adjust overall project tempo
- **Metronome**: Built-in metronome for timing
- **Loop Mode**: Set loop points for continuous playback
- **Timeline Navigation**: Precise playhead control
- **Auto-save**: Automatic project saving

### 📤 Professional Export Options
- **Multiple Formats**: MP3, WAV, FLAC, AAC with various quality settings
- **Metadata Support**: Add title, artist, album information
- **Time Range Export**: Export specific sections
- **Watermark Option**: Add app branding
- **Advanced Processing**: Applies all track effects and master processing

### 📱 Cross-Platform Support
- **Web**: Full functionality in web browsers
- **Mobile**: Native Android and iOS support
- **Responsive Design**: Adapts to different screen sizes

## Technical Architecture

### Core Services
- **AudioProcessingService**: AI-powered stem separation with multiple API integrations
- **AudioService**: Multi-track playback and recording management
- **ExportService**: Advanced mixing and export with professional audio processing

### API Integrations
- **Spleeter API**: Deezer's open-source separation technology
- **Voice.ai API**: Advanced AI-powered separation
- **Soundverse API**: Professional-grade separation
- **FFmpeg Fallback**: Local processing when APIs are unavailable

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation & Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Run on web:
```bash
flutter run -d web-server --web-port=8080
```

3. Run on mobile:
```bash
flutter run
```

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## Usage Guide

1. **Audio Import**: Upload audio files and preview before processing
2. **AI Processing**: Automatic stem separation with real-time progress
3. **Multi-Track Editing**: Professional mixing with advanced effects
4. **Beat Integration**: Browse and add beats from comprehensive library
5. **Export & Share**: Professional export with multiple formats and options

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new
