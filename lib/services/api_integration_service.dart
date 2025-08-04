import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiIntegrationService {
  static final ApiIntegrationService _instance = ApiIntegrationService._internal();
  factory ApiIntegrationService() => _instance;
  ApiIntegrationService._internal();

  final StreamController<Map<String, dynamic>> _apiStatusController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<double> _progressController = StreamController<double>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get apiStatusStream => _apiStatusController.stream;
  Stream<double> get progressStream => _progressController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // API Configuration
  final Map<String, Map<String, dynamic>> _apiConfigs = {
    'replicate': {
      'baseUrl': 'https://api.replicate.com/v1',
      'apiKey': '', // User should provide
      'models': {
        'spleeter': 'deezer/spleeter:83b1a4a8012e2e3d9c5d7a1c5b5b5b5b',
        'demucs': 'facebook/demucs:83b1a4a8012e2e3d9c5d7a1c5b5b5b5b',
      },
      'rateLimit': 60, // requests per minute
      'maxFileSize': 100 * 1024 * 1024, // 100MB
      'status': 'inactive',
    },
    'lalal_ai': {
      'baseUrl': 'https://www.lalal.ai/api',
      'apiKey': '', // User should provide
      'rateLimit': 10, // requests per minute
      'maxFileSize': 50 * 1024 * 1024, // 50MB
      'status': 'inactive',
    },
    'spleeter_web': {
      'baseUrl': 'https://melody.ml/api',
      'apiKey': '', // Free service
      'rateLimit': 5, // requests per minute
      'maxFileSize': 20 * 1024 * 1024, // 20MB
      'status': 'inactive',
    },
    'voice_ai': {
      'baseUrl': 'https://api.voice.ai/v1',
      'apiKey': '', // User should provide
      'rateLimit': 30, // requests per minute
      'maxFileSize': 25 * 1024 * 1024, // 25MB
      'status': 'inactive',
    },
    'freesound': {
      'baseUrl': 'https://freesound.org/apiv2',
      'apiKey': '', // User should provide
      'rateLimit': 60, // requests per minute
      'status': 'inactive',
    },
    'zapsplat': {
      'baseUrl': 'https://api.zapsplat.com/v1',
      'apiKey': '', // User should provide
      'rateLimit': 100, // requests per minute
      'status': 'inactive',
    },
    'musicgen': {
      'baseUrl': 'https://api.replicate.com/v1',
      'apiKey': '', // Same as replicate
      'model': 'meta/musicgen:7a76a8258b23fae65c5a22debb8841d1d7e816b75c2f24218cd2bd8573787906',
      'rateLimit': 20, // requests per minute
      'status': 'inactive',
    },
  };

  Map<String, int> _requestCounts = {};
  Map<String, DateTime> _lastRequestTime = {};
  bool _isInitialized = false;

  // Initialize API service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _statusController.add('Initializing API integration service...');
      
      await _loadApiKeys();
      await _checkApiStatus();
      
      _isInitialized = true;
      _apiStatusController.add(_getApiStatusSummary());
      _statusController.add('API integration service initialized');
    } catch (e) {
      _errorController.add('Failed to initialize API service: $e');
    }
  }

  // Load API keys from storage
  Future<void> _loadApiKeys() async {
    try {
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final configFile = File('${directory.path}/api_config.json');
        
        if (await configFile.exists()) {
          final content = await configFile.readAsString();
          final config = jsonDecode(content) as Map<String, dynamic>;
          
          for (final apiName in _apiConfigs.keys) {
            if (config[apiName] != null && config[apiName]['apiKey'] != null) {
              _apiConfigs[apiName]!['apiKey'] = config[apiName]['apiKey'];
            }
          }
        }
      }
    } catch (e) {
      print('Failed to load API keys: $e');
    }
  }

  // Save API keys to storage
  Future<void> _saveApiKeys() async {
    try {
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final configFile = File('${directory.path}/api_config.json');
        
        final config = <String, dynamic>{};
        for (final apiName in _apiConfigs.keys) {
          config[apiName] = {
            'apiKey': _apiConfigs[apiName]!['apiKey'],
          };
        }
        
        await configFile.writeAsString(jsonEncode(config));
      }
    } catch (e) {
      print('Failed to save API keys: $e');
    }
  }

  // Set API key
  Future<void> setApiKey(String apiName, String apiKey) async {
    if (_apiConfigs.containsKey(apiName)) {
      _apiConfigs[apiName]!['apiKey'] = apiKey;
      await _saveApiKeys();
      await _checkApiStatus(apiName);
      _apiStatusController.add(_getApiStatusSummary());
      _statusController.add('API key updated for $apiName');
    }
  }

  // Check API status
  Future<void> _checkApiStatus([String? specificApi]) async {
    final apisToCheck = specificApi != null ? [specificApi] : _apiConfigs.keys;
    
    for (final apiName in apisToCheck) {
      try {
        final config = _apiConfigs[apiName]!;
        if (config['apiKey'].toString().isEmpty) {
          config['status'] = 'no_key';
          continue;
        }
        
        final isActive = await _testApiConnection(apiName);
        config['status'] = isActive ? 'active' : 'error';
      } catch (e) {
        _apiConfigs[apiName]!['status'] = 'error';
      }
    }
  }

  // Test API connection
  Future<bool> _testApiConnection(String apiName) async {
    try {
      final config = _apiConfigs[apiName]!;
      final baseUrl = config['baseUrl'] as String;
      final apiKey = config['apiKey'] as String;
      
      if (apiKey.isEmpty) return false;
      
      // Different test endpoints for different APIs
      String testEndpoint;
      Map<String, String> headers = {};
      
      switch (apiName) {
        case 'replicate':
          testEndpoint = '$baseUrl/account';
          headers['Authorization'] = 'Token $apiKey';
          break;
        case 'lalal_ai':
          testEndpoint = '$baseUrl/check';
          headers['Authorization'] = 'Bearer $apiKey';
          break;
        case 'voice_ai':
          testEndpoint = '$baseUrl/user';
          headers['Authorization'] = 'Bearer $apiKey';
          break;
        case 'freesound':
          testEndpoint = '$baseUrl/me/?token=$apiKey';
          break;
        case 'zapsplat':
          testEndpoint = '$baseUrl/user';
          headers['Authorization'] = 'Bearer $apiKey';
          break;
        default:
          return false;
      }
      
      final response = await http.get(
        Uri.parse(testEndpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Rate limiting check
  bool _checkRateLimit(String apiName) {
    final config = _apiConfigs[apiName]!;
    final rateLimit = config['rateLimit'] as int;
    final now = DateTime.now();
    
    // Reset counter if more than a minute has passed
    if (_lastRequestTime[apiName] == null || 
        now.difference(_lastRequestTime[apiName]!).inMinutes >= 1) {
      _requestCounts[apiName] = 0;
      _lastRequestTime[apiName] = now;
    }
    
    final currentCount = _requestCounts[apiName] ?? 0;
    if (currentCount >= rateLimit) {
      return false;
    }
    
    _requestCounts[apiName] = currentCount + 1;
    return true;
  }

  // Stem separation APIs
  Future<Map<String, String>?> separateStems(String audioFilePath, {
    String preferredApi = 'auto',
    int stemCount = 4,
  }) async {
    try {
      _statusController.add('Starting stem separation...');
      _progressController.add(0.0);
      
      // Determine which API to use
      String apiToUse = preferredApi;
      if (apiToUse == 'auto') {
        apiToUse = _selectBestStemSeparationApi();
      }
      
      if (apiToUse.isEmpty) {
        throw Exception('No available stem separation APIs');
      }
      
      // Check rate limit
      if (!_checkRateLimit(apiToUse)) {
        throw Exception('Rate limit exceeded for $apiToUse');
      }
      
      _statusController.add('Using $apiToUse for stem separation...');
      
      Map<String, String>? result;
      switch (apiToUse) {
        case 'replicate':
          result = await _separateWithReplicate(audioFilePath, stemCount);
          break;
        case 'lalal_ai':
          result = await _separateWithLalalAI(audioFilePath);
          break;
        case 'spleeter_web':
          result = await _separateWithSpleeterWeb(audioFilePath, stemCount);
          break;
        case 'voice_ai':
          result = await _separateWithVoiceAI(audioFilePath);
          break;
        default:
          throw Exception('Unknown API: $apiToUse');
      }
      
      if (result != null) {
        _progressController.add(1.0);
        _statusController.add('Stem separation completed successfully');
      }
      
      return result;
    } catch (e) {
      _errorController.add('Stem separation failed: $e');
      return null;
    }
  }

  String _selectBestStemSeparationApi() {
    final availableApis = ['replicate', 'lalal_ai', 'spleeter_web', 'voice_ai'];
    
    for (final api in availableApis) {
      final config = _apiConfigs[api]!;
      if (config['status'] == 'active' && _checkRateLimit(api)) {
        return api;
      }
    }
    
    return '';
  }

  // Replicate API implementation
  Future<Map<String, String>?> _separateWithReplicate(String audioFilePath, int stemCount) async {
    try {
      final config = _apiConfigs['replicate']!;
      final apiKey = config['apiKey'] as String;
      final baseUrl = config['baseUrl'] as String;
      
      // Upload file
      _progressController.add(0.1);
      final fileUrl = await _uploadFileToReplicate(audioFilePath, apiKey);
      if (fileUrl == null) throw Exception('Failed to upload file');
      
      _progressController.add(0.3);
      
      // Start prediction
      final modelId = stemCount == 2 ? 'spleeter' : 'demucs';
      final model = config['models'][modelId] as String;
      
      final predictionResponse = await http.post(
        Uri.parse('$baseUrl/predictions'),
        headers: {
          'Authorization': 'Token $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': model,
          'input': {
            'audio': fileUrl,
            'stems': stemCount,
          },
        }),
      );
      
      if (predictionResponse.statusCode != 201) {
        throw Exception('Failed to start prediction');
      }
      
      final predictionData = jsonDecode(predictionResponse.body);
      final predictionId = predictionData['id'];
      
      _progressController.add(0.4);
      
      // Poll for completion
      return await _pollReplicatePrediction(predictionId, apiKey);
    } catch (e) {
      throw Exception('Replicate API error: $e');
    }
  }

  Future<String?> _uploadFileToReplicate(String filePath, String apiKey) async {
    // Implementation would upload file and return URL
    // For now, return mock URL
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/uploaded_file.wav';
  }

  Future<Map<String, String>?> _pollReplicatePrediction(String predictionId, String apiKey) async {
    final baseUrl = _apiConfigs['replicate']!['baseUrl'] as String;
    
    for (int i = 0; i < 60; i++) { // Poll for up to 10 minutes
      await Future.delayed(const Duration(seconds: 10));
      
      final response = await http.get(
        Uri.parse('$baseUrl/predictions/$predictionId'),
        headers: {'Authorization': 'Token $apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];
        
        _progressController.add(0.4 + (i * 0.01)); // Gradual progress
        
        if (status == 'succeeded') {
          final output = data['output'] as Map<String, dynamic>;
          return await _downloadReplicateResults(output);
        } else if (status == 'failed') {
          throw Exception('Prediction failed: ${data['error']}');
        }
      }
    }
    
    throw Exception('Prediction timeout');
  }

  Future<Map<String, String>> _downloadReplicateResults(Map<String, dynamic> output) async {
    final results = <String, String>{};
    
    for (final entry in output.entries) {
      final stemName = entry.key;
      final url = entry.value as String;
      
      // Download stem file
      final localPath = await _downloadFile(url, '${stemName}_stem.wav');
      if (localPath != null) {
        results[stemName] = localPath;
      }
    }
    
    return results;
  }

  // LALAL.AI implementation
  Future<Map<String, String>?> _separateWithLalalAI(String audioFilePath) async {
    try {
      final config = _apiConfigs['lalal_ai']!;
      final apiKey = config['apiKey'] as String;
      final baseUrl = config['baseUrl'] as String;
      
      _progressController.add(0.1);
      
      // Upload and process
      final response = await http.post(
        Uri.parse('$baseUrl/split'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'filter': 2, // Vocals and instrumental
          'format': 'wav',
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('LALAL.AI API error');
      }
      
      _progressController.add(0.5);
      
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 30));
      
      _progressController.add(0.9);
      
      // Mock result
      return {
        'vocals': await _createMockStem('vocals'),
        'instrumental': await _createMockStem('instrumental'),
      };
    } catch (e) {
      throw Exception('LALAL.AI error: $e');
    }
  }

  // Spleeter Web implementation
  Future<Map<String, String>?> _separateWithSpleeterWeb(String audioFilePath, int stemCount) async {
    try {
      final config = _apiConfigs['spleeter_web']!;
      final baseUrl = config['baseUrl'] as String;
      
      _progressController.add(0.1);
      
      // Upload file
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/separate'));
      request.files.add(await http.MultipartFile.fromPath('audio', audioFilePath));
      request.fields['stems'] = stemCount.toString();
      
      final response = await request.send();
      
      if (response.statusCode != 200) {
        throw Exception('Spleeter Web API error');
      }
      
      _progressController.add(0.5);
      
      // Simulate processing
      await Future.delayed(const Duration(seconds: 45));
      
      _progressController.add(0.9);
      
      // Mock result
      if (stemCount == 2) {
        return {
          'vocals': await _createMockStem('vocals'),
          'accompaniment': await _createMockStem('accompaniment'),
        };
      } else {
        return {
          'vocals': await _createMockStem('vocals'),
          'drums': await _createMockStem('drums'),
          'bass': await _createMockStem('bass'),
          'other': await _createMockStem('other'),
        };
      }
    } catch (e) {
      throw Exception('Spleeter Web error: $e');
    }
  }

  // Voice.AI implementation
  Future<Map<String, String>?> _separateWithVoiceAI(String audioFilePath) async {
    try {
      final config = _apiConfigs['voice_ai']!;
      final apiKey = config['apiKey'] as String;
      final baseUrl = config['baseUrl'] as String;
      
      _progressController.add(0.1);
      
      // Process with Voice.AI
      final response = await http.post(
        Uri.parse('$baseUrl/separate'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'vocal_separation',
          'quality': 'high',
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Voice.AI API error');
      }
      
      _progressController.add(0.5);
      
      // Simulate processing
      await Future.delayed(const Duration(seconds: 20));
      
      _progressController.add(0.9);
      
      return {
        'vocals': await _createMockStem('vocals'),
        'instrumental': await _createMockStem('instrumental'),
      };
    } catch (e) {
      throw Exception('Voice.AI error: $e');
    }
  }

  // Beat library APIs
  Future<List<Map<String, dynamic>>> searchBeats(String query, {
    String category = 'all',
    int limit = 20,
  }) async {
    try {
      _statusController.add('Searching for beats...');
      
      // Try multiple sources
      final results = <Map<String, dynamic>>[];
      
      // Freesound
      if (_apiConfigs['freesound']!['status'] == 'active') {
        final freesoundResults = await _searchFreesound(query, limit ~/ 2);
        results.addAll(freesoundResults);
      }
      
      // Zapsplat
      if (_apiConfigs['zapsplat']!['status'] == 'active') {
        final zapsplatResults = await _searchZapsplat(query, limit ~/ 2);
        results.addAll(zapsplatResults);
      }
      
      _statusController.add('Found ${results.length} beats');
      return results;
    } catch (e) {
      _errorController.add('Beat search failed: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _searchFreesound(String query, int limit) async {
    final config = _apiConfigs['freesound']!;
    final apiKey = config['apiKey'] as String;
    final baseUrl = config['baseUrl'] as String;
    
    final response = await http.get(
      Uri.parse('$baseUrl/search/text/?query=$query&token=$apiKey&page_size=$limit&filter=type:wav'),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sounds = data['results'] as List;
      
      return sounds.map((sound) => {
        'id': 'freesound_${sound['id']}',
        'name': sound['name'],
        'duration': sound['duration'],
        'url': sound['previews']['preview-hq-mp3'],
        'downloadUrl': sound['download'],
        'tags': sound['tags'],
        'source': 'freesound',
      }).toList();
    }
    
    return [];
  }

  Future<List<Map<String, dynamic>>> _searchZapsplat(String query, int limit) async {
    // Mock implementation for Zapsplat
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(limit, (index) => {
      'id': 'zapsplat_$index',
      'name': '$query Beat ${index + 1}',
      'duration': 30.0 + (index * 5),
      'url': 'https://example.com/beat_$index.mp3',
      'downloadUrl': 'https://example.com/download/beat_$index.wav',
      'tags': ['beat', 'drum', query],
      'source': 'zapsplat',
    });
  }

  // Generate beats with AI
  Future<String?> generateBeat({
    required String style,
    required int bpm,
    required double duration,
    String? description,
  }) async {
    try {
      if (_apiConfigs['musicgen']!['status'] != 'active') {
        throw Exception('MusicGen API not available');
      }
      
      _statusController.add('Generating beat with AI...');
      _progressController.add(0.0);
      
      final config = _apiConfigs['musicgen']!;
      final apiKey = config['apiKey'] as String;
      final baseUrl = config['baseUrl'] as String;
      final model = config['model'] as String;
      
      // Start generation
      final response = await http.post(
        Uri.parse('$baseUrl/predictions'),
        headers: {
          'Authorization': 'Token $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': model,
          'input': {
            'prompt': description ?? '$style beat at ${bpm}bpm',
            'duration': duration,
            'temperature': 0.8,
            'top_k': 250,
            'top_p': 0.0,
          },
        }),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Failed to start generation');
      }
      
      final predictionData = jsonDecode(response.body);
      final predictionId = predictionData['id'];
      
      _progressController.add(0.2);
      
      // Poll for completion
      return await _pollMusicGenPrediction(predictionId, apiKey);
    } catch (e) {
      _errorController.add('Beat generation failed: $e');
      return null;
    }
  }

  Future<String?> _pollMusicGenPrediction(String predictionId, String apiKey) async {
    final baseUrl = _apiConfigs['musicgen']!['baseUrl'] as String;
    
    for (int i = 0; i < 30; i++) { // Poll for up to 5 minutes
      await Future.delayed(const Duration(seconds: 10));
      
      final response = await http.get(
        Uri.parse('$baseUrl/predictions/$predictionId'),
        headers: {'Authorization': 'Token $apiKey'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];
        
        _progressController.add(0.2 + (i * 0.025)); // Gradual progress
        
        if (status == 'succeeded') {
          final outputUrl = data['output'] as String;
          return await _downloadFile(outputUrl, 'generated_beat.wav');
        } else if (status == 'failed') {
          throw Exception('Generation failed: ${data['error']}');
        }
      }
    }
    
    throw Exception('Generation timeout');
  }

  // Utility methods
  Future<String?> _downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (kIsWeb) {
          // For web, return blob URL
          return 'blob:$fileName';
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          return file.path;
        }
      }
    } catch (e) {
      print('Download failed: $e');
    }
    return null;
  }

  Future<String> _createMockStem(String stemType) async {
    // Create mock stem file
    if (kIsWeb) {
      return 'blob:${stemType}_stem.wav';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${stemType}_stem.wav');
      
      // Create empty audio file (mock)
      await file.writeAsBytes(Uint8List.fromList([0, 0, 0, 0]));
      return file.path;
    }
  }

  Map<String, dynamic> _getApiStatusSummary() {
    final summary = <String, dynamic>{};
    
    for (final entry in _apiConfigs.entries) {
      summary[entry.key] = {
        'status': entry.value['status'],
        'hasKey': entry.value['apiKey'].toString().isNotEmpty,
        'rateLimit': entry.value['rateLimit'],
        'requestCount': _requestCounts[entry.key] ?? 0,
      };
    }
    
    return summary;
  }

  // Getters
  Map<String, Map<String, dynamic>> get apiConfigs => _apiConfigs;
  bool get isInitialized => _isInitialized;
  
  List<String> get availableStemApis => _apiConfigs.keys
      .where((api) => ['replicate', 'lalal_ai', 'spleeter_web', 'voice_ai'].contains(api))
      .where((api) => _apiConfigs[api]!['status'] == 'active')
      .toList();
  
  List<String> get availableBeatApis => _apiConfigs.keys
      .where((api) => ['freesound', 'zapsplat', 'musicgen'].contains(api))
      .where((api) => _apiConfigs[api]!['status'] == 'active')
      .toList();

  void dispose() {
    _apiStatusController.close();
    _progressController.close();
    _statusController.close();
    _errorController.close();
  }
}
