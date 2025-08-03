import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

enum PlatformType {
  web,
  android,
  ios,
  windows,
  macos,
  linux,
}

class CrossPlatformService {
  static final CrossPlatformService _instance = CrossPlatformService._internal();
  factory CrossPlatformService() => _instance;
  CrossPlatformService._internal();

  final StreamController<Map<String, dynamic>> _platformStateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get platformStateStream => _platformStateController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Map<String, dynamic> _platformState = {
    'platform': PlatformType.web,
    'isWeb': kIsWeb,
    'isMobile': false,
    'isDesktop': false,
    'hasFileSystem': false,
    'hasAudioPermission': false,
    'hasMicrophonePermission': false,
    'hasStoragePermission': false,
    'supportsFFmpeg': false,
    'supportsWebAudio': false,
    'supportsFileSharing': false,
    'supportsNotifications': false,
    'deviceInfo': {},
    'capabilities': {},
  };

  Map<String, dynamic> _audioCapabilities = {
    'maxSampleRate': 48000,
    'supportedFormats': ['wav', 'mp3'],
    'maxChannels': 2,
    'bufferSize': 1024,
    'latency': 'normal',
    'realtimeProcessing': false,
  };

  Map<String, dynamic> _storageCapabilities = {
    'documentsDirectory': null,
    'tempDirectory': null,
    'cacheDirectory': null,
    'maxFileSize': 100 * 1024 * 1024, // 100MB default
    'supportedFileTypes': [],
  };

  bool _isInitialized = false;

  // Initialize cross-platform service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _statusController.add('Initializing cross-platform service...');
      
      await _detectPlatform();
      await _checkPermissions();
      await _detectCapabilities();
      await _initializeStorage();
      await _initializeAudio();
      
      _isInitialized = true;
      _platformStateController.add(_platformState);
      _statusController.add('Cross-platform service initialized');
    } catch (e) {
      _errorController.add('Failed to initialize cross-platform service: $e');
    }
  }

  // Detect current platform
  Future<void> _detectPlatform() async {
    if (kIsWeb) {
      _platformState['platform'] = PlatformType.web;
      _platformState['isWeb'] = true;
      _platformState['isMobile'] = false;
      _platformState['isDesktop'] = false;
      _platformState['hasFileSystem'] = false;
      _platformState['supportsWebAudio'] = true;
    } else {
      if (Platform.isAndroid) {
        _platformState['platform'] = PlatformType.android;
        _platformState['isMobile'] = true;
        _platformState['supportsFFmpeg'] = true;
      } else if (Platform.isIOS) {
        _platformState['platform'] = PlatformType.ios;
        _platformState['isMobile'] = true;
        _platformState['supportsFFmpeg'] = true;
      } else if (Platform.isWindows) {
        _platformState['platform'] = PlatformType.windows;
        _platformState['isDesktop'] = true;
        _platformState['supportsFFmpeg'] = true;
      } else if (Platform.isMacOS) {
        _platformState['platform'] = PlatformType.macos;
        _platformState['isDesktop'] = true;
        _platformState['supportsFFmpeg'] = true;
      } else if (Platform.isLinux) {
        _platformState['platform'] = PlatformType.linux;
        _platformState['isDesktop'] = true;
        _platformState['supportsFFmpeg'] = true;
      }
      
      _platformState['isWeb'] = false;
      _platformState['hasFileSystem'] = true;
      _platformState['supportsFileSharing'] = true;
      _platformState['supportsNotifications'] = true;
    }
  }

  // Check platform permissions
  Future<void> _checkPermissions() async {
    if (kIsWeb) {
      // Web permissions are handled differently
      _platformState['hasAudioPermission'] = true;
      _platformState['hasMicrophonePermission'] = false; // Requires user gesture
      _platformState['hasStoragePermission'] = true;
      return;
    }

    try {
      // Check microphone permission
      final micStatus = await Permission.microphone.status;
      _platformState['hasMicrophonePermission'] = micStatus.isGranted;
      
      // Check storage permission (Android)
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        _platformState['hasStoragePermission'] = storageStatus.isGranted;
      } else {
        _platformState['hasStoragePermission'] = true;
      }
      
      _platformState['hasAudioPermission'] = true;
    } catch (e) {
      print('Permission check failed: $e');
    }
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return await _requestWebPermissions();
    }

    try {
      _statusController.add('Requesting permissions...');
      
      final permissions = <Permission>[];
      
      if (!_platformState['hasMicrophonePermission']) {
        permissions.add(Permission.microphone);
      }
      
      if (Platform.isAndroid && !_platformState['hasStoragePermission']) {
        permissions.add(Permission.storage);
        permissions.add(Permission.manageExternalStorage);
      }
      
      if (permissions.isNotEmpty) {
        final statuses = await permissions.request();
        
        _platformState['hasMicrophonePermission'] = 
            statuses[Permission.microphone]?.isGranted ?? _platformState['hasMicrophonePermission'];
        
        if (Platform.isAndroid) {
          _platformState['hasStoragePermission'] = 
              statuses[Permission.storage]?.isGranted ?? _platformState['hasStoragePermission'];
        }
      }
      
      _platformStateController.add(_platformState);
      _statusController.add('Permissions updated');
      
      return _platformState['hasMicrophonePermission'] && _platformState['hasStoragePermission'];
    } catch (e) {
      _errorController.add('Failed to request permissions: $e');
      return false;
    }
  }

  // Request web permissions
  Future<bool> _requestWebPermissions() async {
    try {
      // Request microphone access
      final mediaStream = await _requestWebMediaAccess();
      if (mediaStream != null) {
        _platformState['hasMicrophonePermission'] = true;
        // Stop the stream immediately as we just needed permission
        _stopWebMediaStream(mediaStream);
      }
      
      _platformStateController.add(_platformState);
      return _platformState['hasMicrophonePermission'];
    } catch (e) {
      _errorController.add('Web permission request failed: $e');
      return false;
    }
  }

  // Web media access (using platform channels)
  Future<dynamic> _requestWebMediaAccess() async {
    if (!kIsWeb) return null;
    
    try {
      // This would use a web-specific implementation
      // For now, we'll simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      return 'mock_media_stream';
    } catch (e) {
      return null;
    }
  }

  void _stopWebMediaStream(dynamic stream) {
    // Stop web media stream
  }

  // Detect platform capabilities
  Future<void> _detectCapabilities() async {
    // Audio capabilities
    if (kIsWeb) {
      _audioCapabilities = {
        'maxSampleRate': 48000,
        'supportedFormats': ['wav', 'mp3', 'ogg'],
        'maxChannels': 2,
        'bufferSize': 1024,
        'latency': 'normal',
        'realtimeProcessing': true,
      };
    } else if (_platformState['isMobile']) {
      _audioCapabilities = {
        'maxSampleRate': 48000,
        'supportedFormats': ['wav', 'mp3', 'aac', 'm4a'],
        'maxChannels': 2,
        'bufferSize': 512,
        'latency': 'low',
        'realtimeProcessing': true,
      };
    } else {
      _audioCapabilities = {
        'maxSampleRate': 192000,
        'supportedFormats': ['wav', 'mp3', 'flac', 'aac', 'ogg'],
        'maxChannels': 8,
        'bufferSize': 256,
        'latency': 'ultra-low',
        'realtimeProcessing': true,
      };
    }
    
    _platformState['capabilities'] = {
      'audio': _audioCapabilities,
      'storage': _storageCapabilities,
    };
  }

  // Initialize storage
  Future<void> _initializeStorage() async {
    if (kIsWeb) {
      _storageCapabilities = {
        'documentsDirectory': '/downloads',
        'tempDirectory': '/temp',
        'cacheDirectory': '/cache',
        'maxFileSize': 50 * 1024 * 1024, // 50MB for web
        'supportedFileTypes': ['wav', 'mp3', 'ogg'],
      };
      return;
    }

    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();
      
      _storageCapabilities['documentsDirectory'] = documentsDir.path;
      _storageCapabilities['tempDirectory'] = tempDir.path;
      
      if (Platform.isAndroid || Platform.isIOS) {
        final cacheDir = await getApplicationCacheDirectory();
        _storageCapabilities['cacheDirectory'] = cacheDir.path;
        _storageCapabilities['maxFileSize'] = 200 * 1024 * 1024; // 200MB for mobile
      } else {
        _storageCapabilities['maxFileSize'] = 1024 * 1024 * 1024; // 1GB for desktop
      }
      
      _storageCapabilities['supportedFileTypes'] = [
        'wav', 'mp3', 'flac', 'aac', 'm4a', 'ogg', 'aiff'
      ];
    } catch (e) {
      _errorController.add('Storage initialization failed: $e');
    }
  }

  // Initialize audio system
  Future<void> _initializeAudio() async {
    try {
      if (kIsWeb) {
        await _initializeWebAudio();
      } else {
        await _initializeNativeAudio();
      }
    } catch (e) {
      _errorController.add('Audio initialization failed: $e');
    }
  }

  Future<void> _initializeWebAudio() async {
    // Initialize Web Audio API
    _statusController.add('Initializing Web Audio API...');
    // Implementation would set up Web Audio context
  }

  Future<void> _initializeNativeAudio() async {
    // Initialize native audio system
    _statusController.add('Initializing native audio system...');
    // Implementation would set up native audio
  }

  // File operations
  Future<String?> pickAudioFile() async {
    try {
      if (kIsWeb) {
        return await _pickWebFile();
      } else {
        return await _pickNativeFile();
      }
    } catch (e) {
      _errorController.add('File picking failed: $e');
      return null;
    }
  }

  Future<String?> _pickWebFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'ogg', 'm4a'],
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        // Save to browser storage or return blob URL
        return 'blob:${file.name}';
      }
    }
    
    return null;
  }

  Future<String?> _pickNativeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _storageCapabilities['supportedFileTypes'],
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      return result.files.first.path;
    }
    
    return null;
  }

  // Save file
  Future<String?> saveFile(Uint8List data, String fileName, {String? directory}) async {
    try {
      if (kIsWeb) {
        return await _saveWebFile(data, fileName);
      } else {
        return await _saveNativeFile(data, fileName, directory);
      }
    } catch (e) {
      _errorController.add('File saving failed: $e');
      return null;
    }
  }

  Future<String?> _saveWebFile(Uint8List data, String fileName) async {
    // For web, trigger download
    final blob = data;
    // Implementation would create blob URL and trigger download
    return 'downloaded:$fileName';
  }

  Future<String?> _saveNativeFile(Uint8List data, String fileName, String? directory) async {
    final dir = directory ?? _storageCapabilities['documentsDirectory'];
    if (dir == null) return null;
    
    final file = File('$dir/$fileName');
    await file.writeAsBytes(data);
    return file.path;
  }

  // Share functionality
  Future<bool> shareFile(String filePath, {String? text}) async {
    if (!_platformState['supportsFileSharing']) {
      _errorController.add('File sharing not supported on this platform');
      return false;
    }

    try {
      if (kIsWeb) {
        // Web sharing API or fallback to download
        await _shareWebFile(filePath, text);
      } else {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: text ?? 'Shared from Rapid Mixer',
        );
      }
      
      _statusController.add('File shared successfully');
      return true;
    } catch (e) {
      _errorController.add('File sharing failed: $e');
      return false;
    }
  }

  Future<void> _shareWebFile(String filePath, String? text) async {
    // Web sharing implementation
    final url = Uri.parse(filePath);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // URL operations
  Future<bool> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      _errorController.add('Failed to open URL: $e');
      return false;
    }
  }

  // Platform-specific audio processing
  Future<Uint8List?> processAudioPlatformSpecific(
    Uint8List audioData, 
    Map<String, dynamic> parameters
  ) async {
    try {
      if (kIsWeb) {
        return await _processAudioWeb(audioData, parameters);
      } else {
        return await _processAudioNative(audioData, parameters);
      }
    } catch (e) {
      _errorController.add('Audio processing failed: $e');
      return null;
    }
  }

  Future<Uint8List?> _processAudioWeb(Uint8List audioData, Map<String, dynamic> parameters) async {
    // Web Audio API processing
    _statusController.add('Processing audio with Web Audio API...');
    
    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return processed data (mock)
    return audioData;
  }

  Future<Uint8List?> _processAudioNative(Uint8List audioData, Map<String, dynamic> parameters) async {
    // Native audio processing (FFmpeg, etc.)
    _statusController.add('Processing audio with native libraries...');
    
    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Return processed data (mock)
    return audioData;
  }

  // Platform-specific optimizations
  Map<String, dynamic> getOptimalSettings() {
    if (kIsWeb) {
      return {
        'bufferSize': 1024,
        'sampleRate': 44100,
        'channels': 2,
        'useWebWorkers': true,
        'enableOfflineProcessing': true,
      };
    } else if (_platformState['isMobile']) {
      return {
        'bufferSize': 512,
        'sampleRate': 44100,
        'channels': 2,
        'lowLatencyMode': true,
        'powerOptimized': true,
      };
    } else {
      return {
        'bufferSize': 256,
        'sampleRate': 48000,
        'channels': 2,
        'ultraLowLatency': true,
        'highQualityProcessing': true,
      };
    }
  }

  // Device info
  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_platformState['deviceInfo'].isNotEmpty) {
      return _platformState['deviceInfo'];
    }

    try {
      Map<String, dynamic> deviceInfo = {};
      
      if (kIsWeb) {
        deviceInfo = {
          'platform': 'web',
          'userAgent': 'Web Browser',
          'supportsWebAudio': true,
          'supportsWebWorkers': true,
        };
      } else {
        deviceInfo = {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
          'numberOfProcessors': Platform.numberOfProcessors,
          'pathSeparator': Platform.pathSeparator,
        };
      }
      
      _platformState['deviceInfo'] = deviceInfo;
      return deviceInfo;
    } catch (e) {
      _errorController.add('Failed to get device info: $e');
      return {};
    }
  }

  // Performance monitoring
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'memoryUsage': _getMemoryUsage(),
      'cpuUsage': _getCpuUsage(),
      'audioLatency': _getAudioLatency(),
      'frameRate': _getFrameRate(),
    };
  }

  double _getMemoryUsage() {
    // Platform-specific memory usage
    return 0.0; // Mock implementation
  }

  double _getCpuUsage() {
    // Platform-specific CPU usage
    return 0.0; // Mock implementation
  }

  double _getAudioLatency() {
    // Platform-specific audio latency
    if (kIsWeb) return 20.0;
    if (_platformState['isMobile']) return 10.0;
    return 5.0;
  }

  double _getFrameRate() {
    // Platform-specific frame rate
    return 60.0; // Mock implementation
  }

  // Getters
  PlatformType get currentPlatform => _platformState['platform'];
  bool get isWeb => _platformState['isWeb'];
  bool get isMobile => _platformState['isMobile'];
  bool get isDesktop => _platformState['isDesktop'];
  bool get hasFileSystem => _platformState['hasFileSystem'];
  bool get supportsFFmpeg => _platformState['supportsFFmpeg'];
  bool get supportsWebAudio => _platformState['supportsWebAudio'];
  Map<String, dynamic> get platformState => _platformState;
  Map<String, dynamic> get audioCapabilities => _audioCapabilities;
  Map<String, dynamic> get storageCapabilities => _storageCapabilities;
  bool get isInitialized => _isInitialized;

  void dispose() {
    _platformStateController.close();
    _statusController.close();
    _errorController.close();
  }
}