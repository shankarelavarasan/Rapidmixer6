import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class PWAService {
  static bool _isInstallPromptAvailable = false;
  static bool _isInstalled = false;

  /// Check if the app is running as a PWA
  static bool get isInstalled {
    if (kIsWeb) {
      try {
        return html.window.matchMedia('(display-mode: standalone)').matches ||
               html.window.navigator.standalone == true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// Check if install prompt is available
  static bool get canInstall => _isInstallPromptAvailable && !isInstalled;

  /// Initialize PWA service
  static void initialize() {
    if (!kIsWeb) return;
    
    try {
      // Check if already installed
      _isInstalled = isInstalled;
      
      // Listen for install prompt availability
      html.window.addEventListener('beforeinstallprompt', (event) {
        _isInstallPromptAvailable = true;
        print('PWA install prompt is available');
      });
      
      // Listen for app installed event
      html.window.addEventListener('appinstalled', (event) {
        _isInstalled = true;
        _isInstallPromptAvailable = false;
        print('PWA has been installed');
      });
      
      print('PWA Service initialized. Installed: $_isInstalled');
    } catch (e) {
      print('Error initializing PWA service: $e');
    }
  }

  /// Trigger install prompt
  static Future<bool> promptInstall() async {
    if (!kIsWeb || !_isInstallPromptAvailable) {
      print('Install prompt not available');
      return false;
    }
    
    try {
      // Call the JavaScript function to show install prompt
      final result = js.context.callMethod('installPWA');
      return true;
    } catch (e) {
      print('Error showing install prompt: $e');
      return false;
    }
  }

  /// Show install instructions for different platforms
  static String getInstallInstructions() {
    if (isInstalled) {
      return 'App is already installed!';
    }
    
    // Detect platform and provide specific instructions
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    
    if (userAgent.contains('android')) {
      return 'Tap the menu (⋮) → "Add to Home screen" to install';
    } else if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
      return 'Tap the Share button (□↗) → "Add to Home Screen" to install';
    } else if (userAgent.contains('chrome')) {
      return 'Click the install button (⊕) in the address bar or menu';
    } else if (userAgent.contains('firefox')) {
      return 'Click the install button in the address bar';
    } else if (userAgent.contains('safari')) {
      return 'This browser doesn\'t support PWA installation';
    }
    
    return 'Look for an "Install" or "Add to Home Screen" option in your browser';
  }

  /// Check if the browser supports PWA installation
  static bool get isSupported {
    if (!kIsWeb) return false;
    
    try {
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      // Safari doesn't support PWA installation prompts
      return !userAgent.contains('safari') || userAgent.contains('chrome');
    } catch (e) {
      return false;
    }
  }

  /// Get PWA status information
  static Map<String, dynamic> getStatus() {
    return {
      'isInstalled': isInstalled,
      'canInstall': canInstall,
      'isSupported': isSupported,
      'instructions': getInstallInstructions(),
    };
  }
}