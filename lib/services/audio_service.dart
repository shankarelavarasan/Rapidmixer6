import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final Map<String, AudioPlayer> _stemPlayers = {};

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // Audio state
  bool get isPlaying => _player.playing;
  Duration get currentPosition => _player.position;
  Duration? get totalDuration => _player.duration;

  // Stream controllers for state management
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController =
      StreamController<Duration?>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Getters for streams
  Stream<bool> get playingStream => _playingController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Future<void> initialize() async {
    try {
      // Request audio permissions for mobile platforms
      if (!kIsWeb) {
        await _requestAudioPermissions();
      }

      // Listen to player state changes
      _playerStateSubscription = _player.playerStateStream.listen((state) {
        _playingController.add(state.playing);
      });

      _positionSubscription = _player.positionStream.listen((position) {
        _positionController.add(position);
      });

      _durationSubscription = _player.durationStream.listen((duration) {
        _durationController.add(duration);
      });
    } catch (e) {
      _errorController.add('Failed to initialize audio service: $e');
    }
  }

  Future<bool> _requestAudioPermissions() async {
    if (kIsWeb) return true;

    final audioPermission = await Permission.audio.request();
    final storagePermission = await Permission.storage.request();

    return audioPermission.isGranted && storagePermission.isGranted;
  }

  Future<bool> loadAudioFile(String filePath) async {
    try {
      await _player.stop();

      if (kIsWeb) {
        // For web, assume the file path is a URL or blob URL
        await _player.setUrl(filePath);
      } else {
        // For mobile platforms, load from file path
        await _player.setFilePath(filePath);
      }

      return true;
    } catch (e) {
      _errorController.add('Failed to load audio file: $e');
      return false;
    }
  }

  Future<bool> loadAudioUrl(String url) async {
    try {
      await _player.stop();
      await _player.setUrl(url);
      return true;
    } catch (e) {
      _errorController.add('Failed to load audio URL: $e');
      return false;
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      _errorController.add('Failed to play audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      _errorController.add('Failed to pause audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      _errorController.add('Failed to stop audio: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      _errorController.add('Failed to seek audio: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      _errorController.add('Failed to set volume: $e');
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed.clamp(0.25, 4.0));
    } catch (e) {
      _errorController.add('Failed to set speed: $e');
    }
  }

  // Stem separation player management
  Future<bool> loadStemTrack(String stemId, String filePath) async {
    try {
      if (_stemPlayers[stemId] == null) {
        _stemPlayers[stemId] = AudioPlayer();
      }

      final player = _stemPlayers[stemId]!;

      if (kIsWeb) {
        await player.setUrl(filePath);
      } else {
        await player.setFilePath(filePath);
      }

      return true;
    } catch (e) {
      _errorController.add('Failed to load stem track $stemId: $e');
      return false;
    }
  }

  Future<void> playStem(String stemId) async {
    try {
      final player = _stemPlayers[stemId];
      if (player != null) {
        await player.play();
      }
    } catch (e) {
      _errorController.add('Failed to play stem $stemId: $e');
    }
  }

  Future<void> pauseStem(String stemId) async {
    try {
      final player = _stemPlayers[stemId];
      if (player != null) {
        await player.pause();
      }
    } catch (e) {
      _errorController.add('Failed to pause stem $stemId: $e');
    }
  }

  Future<void> setStemVolume(String stemId, double volume) async {
    try {
      final player = _stemPlayers[stemId];
      if (player != null) {
        await player.setVolume(volume.clamp(0.0, 1.0));
      }
    } catch (e) {
      _errorController.add('Failed to set stem volume for $stemId: $e');
    }
  }

  Future<void> playAllStems() async {
    try {
      for (final player in _stemPlayers.values) {
        await player.play();
      }
    } catch (e) {
      _errorController.add('Failed to play all stems: $e');
    }
  }

  Future<void> pauseAllStems() async {
    try {
      for (final player in _stemPlayers.values) {
        await player.pause();
      }
    } catch (e) {
      _errorController.add('Failed to pause all stems: $e');
    }
  }

  // Parse audio duration from file
  Future<Duration?> getAudioDuration(String filePath) async {
    try {
      final tempPlayer = AudioPlayer();

      if (kIsWeb) {
        await tempPlayer.setUrl(filePath);
      } else {
        await tempPlayer.setFilePath(filePath);
      }

      // Wait for duration to be loaded
      await tempPlayer.durationStream.first;
      final duration = tempPlayer.duration;

      await tempPlayer.dispose();
      return duration;
    } catch (e) {
      _errorController.add('Failed to get audio duration: $e');
      return null;
    }
  }

  String formatDuration(Duration? duration) {
    if (duration == null) return "0:00";

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  void dispose() {
    _player.dispose();
    for (final player in _stemPlayers.values) {
      player.dispose();
    }
    _stemPlayers.clear();

    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();

    _playingController.close();
    _positionController.close();
    _durationController.close();
    _errorController.close();
  }
}
