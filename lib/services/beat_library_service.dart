import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class BeatLibraryService {
  static final BeatLibraryService _instance = BeatLibraryService._internal();
  factory BeatLibraryService() => _instance;
  BeatLibraryService._internal();

  final StreamController<List<Map<String, dynamic>>> _beatsController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  Stream<List<Map<String, dynamic>>> get beatsStream => _beatsController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<String> get errorStream => _errorController.stream;

  List<Map<String, dynamic>> _cachedBeats = [];
  bool _isLoading = false;

  // Initialize beat library with both online and offline beats
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _statusController.add('Loading beat library...');

      // Load cached beats first
      await _loadCachedBeats();
      
      // Try to fetch online beats
      await _fetchOnlineBeats();
      
      // Generate procedural beats if needed
      if (_cachedBeats.length < 20) {
        await _generateProceduralBeats();
      }

      _beatsController.add(_cachedBeats);
      _statusController.add('Beat library loaded successfully');
    } catch (e) {
      _errorController.add('Failed to initialize beat library: $e');
    } finally {
      _isLoading = false;
    }
  }

  // Fetch beats from online sources
  Future<void> _fetchOnlineBeats() async {
    try {
      _statusController.add('Fetching online beats...');
      
      // Try multiple free beat sources
      await _fetchFromFreeMusicArchive();
      await _fetchFromZapsplat();
      await _fetchFromBBCLoops();
      
    } catch (e) {
      print('Online beat fetching failed: $e');
    }
  }

  // Free Music Archive API
  Future<void> _fetchFromFreeMusicArchive() async {
    try {
      final response = await http.get(
        Uri.parse('https://freemusicarchive.org/api/get/tracks.json?api_key=YOUR_FMA_KEY&genre=electronic&limit=10'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tracks = data['dataset'] as List;
        
        for (final track in tracks) {
          if (track['track_duration'] != null && 
              double.parse(track['track_duration']) < 60) { // Short loops only
            _cachedBeats.add({
              'id': track['track_id'],
              'name': track['track_title'] ?? 'Unknown Beat',
              'artist': track['artist_name'] ?? 'Unknown Artist',
              'bpm': _estimateBPM(track['track_title'] ?? ''),
              'duration': _formatDuration(double.parse(track['track_duration'] ?? '30')),
              'genre': track['track_genres']?[0]?['genre_title'] ?? 'Electronic',
              'url': track['track_url'],
              'downloadUrl': track['track_file'],
              'isFavorite': false,
              'isInProject': false,
              'source': 'fma',
              'waveform': _generateWaveform(),
            });
          }
        }
      }
    } catch (e) {
      print('FMA fetch failed: $e');
    }
  }

  // Zapsplat API (requires free account)
  Future<void> _fetchFromZapsplat() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.zapsplat.com/v1/search?query=drum+loop&category=music&duration_max=60'),
        headers: {
          'Authorization': 'Bearer YOUR_ZAPSPLAT_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sounds = data['sounds'] as List;
        
        for (final sound in sounds.take(5)) {
          _cachedBeats.add({
            'id': sound['id'],
            'name': sound['title'] ?? 'Drum Loop',
            'artist': 'Zapsplat',
            'bpm': sound['bpm'] ?? _estimateBPM(sound['title'] ?? ''),
            'duration': _formatDuration(sound['duration'] ?? 30),
            'genre': sound['category'] ?? 'Electronic',
            'url': sound['preview_url'],
            'downloadUrl': sound['download_url'],
            'isFavorite': false,
            'isInProject': false,
            'source': 'zapsplat',
            'waveform': _generateWaveform(),
          });
        }
      }
    } catch (e) {
      print('Zapsplat fetch failed: $e');
    }
  }

  // BBC Sound Effects (free)
  Future<void> _fetchFromBBCLoops() async {
    try {
      // BBC has a free sound effects library
      final response = await http.get(
        Uri.parse('https://sound-effects-media.bbcrewind.co.uk/csv/sfx.csv'),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (final line in lines.take(10)) {
          final parts = line.split(',');
          if (parts.length >= 4 && parts[1].toLowerCase().contains('music')) {
            _cachedBeats.add({
              'id': parts[0],
              'name': parts[1],
              'artist': 'BBC',
              'bpm': _estimateBPM(parts[1]),
              'duration': '0:30',
              'genre': 'Cinematic',
              'url': 'https://sound-effects-media.bbcrewind.co.uk/mp3/${parts[0]}.mp3',
              'downloadUrl': 'https://sound-effects-media.bbcrewind.co.uk/mp3/${parts[0]}.mp3',
              'isFavorite': false,
              'isInProject': false,
              'source': 'bbc',
              'waveform': _generateWaveform(),
            });
          }
        }
      }
    } catch (e) {
      print('BBC fetch failed: $e');
    }
  }

  // Generate procedural beats using algorithms
  Future<void> _generateProceduralBeats() async {
    _statusController.add('Generating procedural beats...');
    
    final genres = ['Hip-Hop', 'Electronic', 'Rock', 'Pop', 'Jazz', 'Latin', 'R&B', 'Trap', 'House', 'Techno'];
    final patterns = {
      'Hip-Hop': [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0],
      'Electronic': [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      'Rock': [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
      'Trap': [1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0],
    };

    for (int i = 0; i < 20; i++) {
      final genre = genres[Random().nextInt(genres.length)];
      final bpm = _generateBPMForGenre(genre);
      
      final beat = {
        'id': 'generated_$i',
        'name': _generateBeatName(genre),
        'artist': 'AI Generated',
        'bpm': bpm,
        'duration': _generateDuration(),
        'genre': genre,
        'pattern': patterns[genre] ?? patterns['Electronic'],
        'isFavorite': false,
        'isInProject': false,
        'source': 'generated',
        'waveform': _generateWaveform(),
        'audioData': await _generateAudioData(genre, bpm),
      };
      
      _cachedBeats.add(beat);
    }
  }

  // Generate actual audio data for beats
  Future<String?> _generateAudioData(String genre, int bpm) async {
    try {
      if (kIsWeb) {
        // For web, we'll create a data URL with generated audio
        return await _generateWebAudio(genre, bpm);
      } else {
        // For mobile/desktop, generate actual audio files
        return await _generateMobileAudio(genre, bpm);
      }
    } catch (e) {
      print('Audio generation failed: $e');
      return null;
    }
  }

  Future<String> _generateWebAudio(String genre, int bpm) async {
    // Generate a simple sine wave pattern for web
    // In a real implementation, this would use Web Audio API
    final duration = 30; // 30 seconds
    final sampleRate = 44100;
    final samples = duration * sampleRate;
    
    // Create a simple drum pattern
    final audioData = List<double>.filled(samples, 0.0);
    final beatInterval = (60.0 / bpm) * sampleRate; // Samples per beat
    
    for (int i = 0; i < samples; i++) {
      final beatPosition = i % beatInterval.round();
      if (beatPosition < 1000) { // Kick drum
        audioData[i] = 0.5 * sin(2 * pi * 60 * i / sampleRate);
      } else if (beatPosition > beatInterval / 2 && beatPosition < beatInterval / 2 + 500) { // Snare
        audioData[i] = 0.3 * (Random().nextDouble() - 0.5); // Noise for snare
      }
    }
    
    // Convert to base64 data URL (simplified)
    return 'data:audio/wav;base64,${base64Encode(audioData.map((e) => (e * 127 + 128).round()).toList())}';
  }

  Future<String> _generateMobileAudio(String genre, int bpm) async {
    final directory = await getApplicationDocumentsDirectory();
    final beatsDir = Directory('${directory.path}/generated_beats');
    if (!await beatsDir.exists()) {
      await beatsDir.create(recursive: true);
    }

    final fileName = '${genre.toLowerCase()}_${bpm}bpm_${DateTime.now().millisecondsSinceEpoch}.wav';
    final outputPath = '${beatsDir.path}/$fileName';

    // Generate audio using FFmpeg
    final duration = 30;
    final command = _buildFFmpegCommand(genre, bpm, duration, outputPath);
    
    await FFmpegKit.execute(command);
    
    return outputPath;
  }

  String _buildFFmpegCommand(String genre, int bpm, int duration, String outputPath) {
    final beatInterval = 60.0 / bpm;
    
    switch (genre.toLowerCase()) {
      case 'hip-hop':
        return '-f lavfi -i "sine=frequency=60:duration=$duration" -af "volume=0.5" "$outputPath"';
      case 'electronic':
        return '-f lavfi -i "sine=frequency=80:duration=$duration" -af "volume=0.6" "$outputPath"';
      case 'rock':
        return '-f lavfi -i "sine=frequency=100:duration=$duration" -af "volume=0.7" "$outputPath"';
      default:
        return '-f lavfi -i "sine=frequency=70:duration=$duration" -af "volume=0.5" "$outputPath"';
    }
  }

  // Load cached beats from local storage
  Future<void> _loadCachedBeats() async {
    try {
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final cacheFile = File('${directory.path}/beats_cache.json');
        
        if (await cacheFile.exists()) {
          final content = await cacheFile.readAsString();
          final data = jsonDecode(content) as List;
          _cachedBeats = data.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Failed to load cached beats: $e');
    }
  }

  // Save beats to cache
  Future<void> _saveCachedBeats() async {
    try {
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final cacheFile = File('${directory.path}/beats_cache.json');
        await cacheFile.writeAsString(jsonEncode(_cachedBeats));
      }
    } catch (e) {
      print('Failed to save cached beats: $e');
    }
  }

  // Search and filter beats
  List<Map<String, dynamic>> searchBeats(String query, {String? genre, int? minBpm, int? maxBpm}) {
    return _cachedBeats.where((beat) {
      final matchesQuery = query.isEmpty || 
          beat['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          beat['artist'].toString().toLowerCase().contains(query.toLowerCase());
      
      final matchesGenre = genre == null || genre == 'All' || beat['genre'] == genre;
      
      final matchesBpm = (minBpm == null || beat['bpm'] >= minBpm) &&
                        (maxBpm == null || beat['bpm'] <= maxBpm);
      
      return matchesQuery && matchesGenre && matchesBpm;
    }).toList();
  }

  // Add beat to favorites
  Future<void> toggleFavorite(String beatId) async {
    final beatIndex = _cachedBeats.indexWhere((beat) => beat['id'].toString() == beatId);
    if (beatIndex != -1) {
      _cachedBeats[beatIndex]['isFavorite'] = !_cachedBeats[beatIndex]['isFavorite'];
      _beatsController.add(_cachedBeats);
      await _saveCachedBeats();
    }
  }

  // Add beat to project
  Future<void> addToProject(String beatId) async {
    final beatIndex = _cachedBeats.indexWhere((beat) => beat['id'].toString() == beatId);
    if (beatIndex != -1) {
      _cachedBeats[beatIndex]['isInProject'] = true;
      _beatsController.add(_cachedBeats);
      await _saveCachedBeats();
    }
  }

  // Download beat for offline use
  Future<String?> downloadBeat(String beatId) async {
    try {
      final beat = _cachedBeats.firstWhere((b) => b['id'].toString() == beatId);
      final downloadUrl = beat['downloadUrl'] ?? beat['url'];
      
      if (downloadUrl == null) return null;
      
      _statusController.add('Downloading ${beat['name']}...');
      
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${directory.path}/downloaded_beats');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        
        final fileName = '${beat['name']}_${beat['id']}.mp3';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        // Update beat with local path
        final beatIndex = _cachedBeats.indexWhere((b) => b['id'].toString() == beatId);
        _cachedBeats[beatIndex]['localPath'] = file.path;
        await _saveCachedBeats();
        
        _statusController.add('Downloaded ${beat['name']} successfully');
        return file.path;
      }
    } catch (e) {
      _errorController.add('Download failed: $e');
    }
    return null;
  }

  // Helper methods
  int _estimateBPM(String title) {
    final bpmRegex = RegExp(r'(\d{2,3})\s*bpm', caseSensitive: false);
    final match = bpmRegex.firstMatch(title);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    
    // Default BPMs by genre keywords
    if (title.toLowerCase().contains('trap')) return 140;
    if (title.toLowerCase().contains('hip hop') || title.toLowerCase().contains('hip-hop')) return 90;
    if (title.toLowerCase().contains('house')) return 128;
    if (title.toLowerCase().contains('techno')) return 130;
    if (title.toLowerCase().contains('jazz')) return 120;
    
    return 120; // Default
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).round();
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  List<double> _generateWaveform() {
    final random = Random();
    return List.generate(20, (index) => 0.3 + random.nextDouble() * 0.7);
  }

  int _generateBPMForGenre(String genre) {
    final bpmRanges = {
      'Hip-Hop': [80, 100],
      'Electronic': [120, 140],
      'Rock': [110, 140],
      'Pop': [100, 130],
      'Jazz': [90, 120],
      'Latin': [100, 120],
      'R&B': [70, 100],
      'Trap': [130, 150],
      'House': [120, 130],
      'Techno': [125, 135],
    };
    
    final range = bpmRanges[genre] ?? [100, 130];
    return range[0] + Random().nextInt(range[1] - range[0]);
  }

  String _generateBeatName(String genre) {
    final prefixes = {
      'Hip-Hop': ['Urban', 'Street', 'Boom Bap', 'Trap', 'Lo-Fi'],
      'Electronic': ['Neon', 'Digital', 'Cyber', 'Synth', 'Electric'],
      'Rock': ['Heavy', 'Power', 'Classic', 'Alternative', 'Indie'],
      'Pop': ['Catchy', 'Radio', 'Commercial', 'Mainstream', 'Hit'],
      'Jazz': ['Smooth', 'Cool', 'Swing', 'Bebop', 'Fusion'],
    };
    
    final suffixes = ['Groove', 'Beat', 'Rhythm', 'Loop', 'Track', 'Vibe', 'Flow'];
    
    final genrePrefixes = prefixes[genre] ?? ['Modern', 'Fresh', 'New'];
    final prefix = genrePrefixes[Random().nextInt(genrePrefixes.length)];
    final suffix = suffixes[Random().nextInt(suffixes.length)];
    
    return '$prefix $suffix';
  }

  String _generateDuration() {
    final durations = ['0:15', '0:20', '0:25', '0:30', '0:35', '0:40', '0:45'];
    return durations[Random().nextInt(durations.length)];
  }

  // Get all beats
  List<Map<String, dynamic>> getAllBeats() => _cachedBeats;

  // Get favorites
  List<Map<String, dynamic>> getFavoriteBeats() {
    return _cachedBeats.where((beat) => beat['isFavorite'] == true).toList();
  }

  // Get project beats
  List<Map<String, dynamic>> getProjectBeats() {
    return _cachedBeats.where((beat) => beat['isInProject'] == true).toList();
  }

  // Generate a custom beat with specified parameters
  Future<Map<String, dynamic>?> generateBeat(String style, int bpm, int duration, String description) async {
    try {
      _statusController.add('Generating custom beat...');
      
      final beatId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      final beatName = description.isNotEmpty ? description : _generateBeatName(style);
      
      final beat = {
        'id': beatId,
        'name': beatName,
        'artist': 'AI Generated',
        'bpm': bpm,
        'duration': _formatDuration(duration.toDouble()),
        'genre': style,
        'isFavorite': false,
        'isInProject': false,
        'source': 'custom_generated',
        'waveform': _generateWaveform(),
        'audioData': await _generateAudioData(style, bpm),
        'description': description,
      };
      
      _cachedBeats.add(beat);
      _beatsController.add(_cachedBeats);
      await _saveCachedBeats();
      
      _statusController.add('Custom beat generated successfully');
      return beat;
    } catch (e) {
      _errorController.add('Failed to generate beat: $e');
      return null;
    }
  }

  void dispose() {
    _beatsController.close();
    _statusController.close();
    _errorController.close();
  }
}
