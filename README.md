# Rapid Mixer 6 - Professional Audio Production Suite

A comprehensive, AI-powered audio mixing and production application built with Flutter, featuring advanced stem separation, professional multi-track editing, and cross-platform compatibility.

## 🚀 Key Features

### 🎵 AI-Powered Stem Separation
- **Multiple AI Services**: Integrates with Replicate (Spleeter), LALAL.AI, Voice.ai, and Soundverse APIs
- **Intelligent Fallbacks**: Automatically tries multiple services for best results
- **Advanced Separation**: 2, 4, or 5-stem separation (vocals, drums, bass, piano, other)
- **Local Processing**: FFmpeg-based fallback when APIs are unavailable
- **Real-time Progress**: Live updates with detailed processing status
- **High-Quality Output**: Maintains audio fidelity during separation

### 🎛️ Professional Multi-Track Editor
- **Unlimited Tracks**: Add and manage multiple audio tracks
- **Real-time Effects**: EQ, compressor, gate, reverb, echo, pitch, speed
- **Advanced Controls**: Volume, pan, solo, mute per track
- **Waveform Visualization**: Visual representation with zoom and scroll
- **Timeline Management**: Precise editing with playhead control
- **Recording Capability**: Record directly into tracks
- **Automation Support**: Parameter automation and playback
- **Project Management**: Save and load complete projects

### 🥁 Comprehensive Beat Library
- **Online Integration**: Fetches beats from Free Music Archive, Zapsplat, BBC Sound Effects
- **Procedural Generation**: AI-powered beat creation with custom parameters
- **Smart Search**: Filter by BPM, genre, mood, duration, and keywords
- **Favorites System**: Save and organize preferred beats
- **Offline Support**: Download beats for offline use
- **Preview Playback**: Listen before adding to projects
- **Seamless Integration**: Direct import into multi-track editor

### 🎚️ Advanced Mixing Features
- **Master Controls**: Global volume, pan, EQ, compressor, limiter
- **Professional Effects**: Reverb, delay, stereo imaging
- **Spectral Analysis**: Real-time frequency analysis
- **Auto-Mixing**: AI-powered auto-balance, auto-compress, auto-limit
- **Mix Templates**: Save and load mixing presets
- **Real-time Processing**: Low-latency audio processing

### 💾 Professional Export
- **Multiple Formats**: MP3, WAV, FLAC, AAC, OGG support
- **Quality Control**: Custom bitrate, sample rate, bit depth
- **Metadata Support**: Artist, title, album, artwork
- **Master Effects**: Apply final processing during export
- **Normalization**: Audio level optimization
- **Watermarking**: Optional audio watermarks
- **Batch Processing**: Export multiple versions simultaneously

### 🌐 Cross-Platform Compatibility
- **Universal Support**: Web, iOS, Android, Windows, macOS, Linux
- **Platform Detection**: Automatic capability detection
- **Permission Management**: Seamless permission handling
- **File Operations**: Platform-specific file picking and sharing
- **Performance Optimization**: Platform-optimized processing
- **Responsive Design**: Adapts to any screen size

## 🏗️ Technical Architecture

### Core Services

#### AudioProcessingService
- Unified interface for all audio operations
- Integrates all specialized services
- Manages service initialization and coordination

#### RealAudioProcessingService
- AI-powered stem separation with multiple API integrations
- Local FFmpeg processing fallback
- Enhanced mock separation with realistic processing

#### BeatLibraryService
- Online beat fetching from multiple sources
- Procedural beat generation using Web Audio API/FFmpeg
- Caching and offline support

#### MultiTrackEditorService
- Track management and mixing
- Real-time effects processing
- Recording and playback controls

#### AdvancedMixingService
- Professional mixing algorithms
- Spectral analysis and auto-mixing
- Master effects and processing

#### ProfessionalExportService
- Multi-format audio export
- Quality control and metadata
- Master effects application

#### CrossPlatformService
- Platform detection and capabilities
- Permission and file management
- Performance monitoring

#### ApiIntegrationService
- External API management
- Rate limiting and error handling
- API key configuration

### AI Integration
- **Replicate API**: Spleeter model integration
- **LALAL.AI**: Professional stem separation
- **Voice.ai**: Advanced vocal processing
- **Soundverse API**: AI audio analysis
- **Freesound API**: Beat and sample search
- **MusicGen**: AI beat generation

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
