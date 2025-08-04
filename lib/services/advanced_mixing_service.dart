import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

class AdvancedMixingService {
  static final AdvancedMixingService _instance = AdvancedMixingService._internal();
  factory AdvancedMixingService() => _instance;
  AdvancedMixingService._internal();

  final StreamController<Map<String, dynamic>> _mixingStateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _analysisController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final StreamController<double> _progressController = StreamController<double>.broadcast();

  Stream<Map<String, dynamic>> get mixingStateStream => _mixingStateController.stream;
  Stream<Map<String, dynamic>> get analysisStream => _analysisController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<double> get progressStream => _progressController.stream;

  Map<String, dynamic> _mixingState = {
    'masterVolume': 0.8,
    'masterPan': 0.0,
    'masterEQ': {
      'lowShelf': {'frequency': 80.0, 'gain': 0.0, 'q': 0.7},
      'lowMid': {'frequency': 250.0, 'gain': 0.0, 'q': 1.0},
      'highMid': {'frequency': 2000.0, 'gain': 0.0, 'q': 1.0},
      'highShelf': {'frequency': 8000.0, 'gain': 0.0, 'q': 0.7},
    },
    'masterCompressor': {
      'enabled': false,
      'threshold': -12.0,
      'ratio': 4.0,
      'attack': 3.0,
      'release': 100.0,
      'knee': 2.0,
      'makeupGain': 0.0,
    },
    'masterLimiter': {
      'enabled': false,
      'threshold': -1.0,
      'release': 50.0,
      'lookahead': 5.0,
    },
    'masterReverb': {
      'enabled': false,
      'roomSize': 0.5,
      'damping': 0.5,
      'wetLevel': 0.3,
      'dryLevel': 0.7,
      'width': 1.0,
      'freezeMode': false,
    },
    'masterDelay': {
      'enabled': false,
      'time': 250.0,
      'feedback': 0.3,
      'wetLevel': 0.2,
      'highCut': 8000.0,
      'lowCut': 100.0,
    },
    'stereoImaging': {
      'width': 1.0,
      'bassMonoFreq': 120.0,
      'enabled': false,
    },
    'spectralAnalysis': {
      'enabled': true,
      'fftSize': 2048,
      'windowType': 'hann',
      'overlapRatio': 0.5,
    },
  };

  Map<String, dynamic> _analysisData = {
    'spectrum': List.filled(1024, 0.0),
    'peakFrequency': 0.0,
    'spectralCentroid': 0.0,
    'spectralRolloff': 0.0,
    'spectralFlux': 0.0,
    'mfcc': List.filled(13, 0.0),
    'lufs': -23.0,
    'truePeak': -6.0,
    'dynamicRange': 12.0,
    'stereoWidth': 1.0,
    'phaseCorrelation': 1.0,
    'tonalBalance': {
      'bass': 0.0,
      'lowMid': 0.0,
      'highMid': 0.0,
      'treble': 0.0,
    },
  };

  List<Map<String, dynamic>> _mixingPresets = [];
  bool _isProcessing = false;
  bool _isAnalyzing = false;

  // Initialize the mixing service
  Future<void> initialize() async {
    try {
      _statusController.add('Initializing advanced mixing engine...');
      
      await _loadMixingPresets().catchError((e) {
        _errorController.add('Failed to load mixing presets: $e');
      });
      
      await _initializeAnalysis().catchError((e) {
        _errorController.add('Failed to initialize analysis: $e');
      });
      
      _mixingStateController.add(Map<String, dynamic>.from(_mixingState));
      _analysisController.add(Map<String, dynamic>.from(_analysisData));
      
      _statusController.add('Advanced mixing engine ready');
    } catch (e) {
      _errorController.add('Failed to initialize mixing engine: $e');
      rethrow;
    }
  }

  // Load mixing presets
  Future<void> _loadMixingPresets() async {
    _mixingPresets = [
      {
        'id': 'rock_master',
        'name': 'Rock Master',
        'description': 'Punchy rock mix with tight low end',
        'settings': {
          'masterEQ': {
            'lowShelf': {'frequency': 80.0, 'gain': 1.0, 'q': 0.7},
            'lowMid': {'frequency': 250.0, 'gain': -1.0, 'q': 1.0},
            'highMid': {'frequency': 3000.0, 'gain': 2.0, 'q': 1.0},
            'highShelf': {'frequency': 10000.0, 'gain': 1.5, 'q': 0.7},
          },
          'masterCompressor': {
            'enabled': true,
            'threshold': -8.0,
            'ratio': 3.0,
            'attack': 5.0,
            'release': 80.0,
          },
          'masterLimiter': {
            'enabled': true,
            'threshold': -0.5,
            'release': 30.0,
          },
        },
      },
      {
        'id': 'pop_vocal',
        'name': 'Pop Vocal',
        'description': 'Clear vocals with modern pop sound',
        'settings': {
          'masterEQ': {
            'lowShelf': {'frequency': 100.0, 'gain': -0.5, 'q': 0.7},
            'lowMid': {'frequency': 400.0, 'gain': -1.5, 'q': 1.2},
            'highMid': {'frequency': 2500.0, 'gain': 2.5, 'q': 1.0},
            'highShelf': {'frequency': 8000.0, 'gain': 2.0, 'q': 0.7},
          },
          'masterCompressor': {
            'enabled': true,
            'threshold': -10.0,
            'ratio': 2.5,
            'attack': 3.0,
            'release': 120.0,
          },
          'masterReverb': {
            'enabled': true,
            'roomSize': 0.3,
            'wetLevel': 0.15,
          },
        },
      },
      {
        'id': 'electronic_dance',
        'name': 'Electronic Dance',
        'description': 'Powerful electronic music mix',
        'settings': {
          'masterEQ': {
            'lowShelf': {'frequency': 60.0, 'gain': 3.0, 'q': 0.7},
            'lowMid': {'frequency': 200.0, 'gain': -2.0, 'q': 1.0},
            'highMid': {'frequency': 4000.0, 'gain': 1.5, 'q': 1.0},
            'highShelf': {'frequency': 12000.0, 'gain': 2.5, 'q': 0.7},
          },
          'masterCompressor': {
            'enabled': true,
            'threshold': -6.0,
            'ratio': 4.0,
            'attack': 1.0,
            'release': 50.0,
          },
          'masterLimiter': {
            'enabled': true,
            'threshold': -0.1,
            'release': 20.0,
          },
          'stereoImaging': {
            'width': 1.2,
            'enabled': true,
          },
        },
      },
      {
        'id': 'acoustic_natural',
        'name': 'Acoustic Natural',
        'description': 'Natural acoustic sound with warmth',
        'settings': {
          'masterEQ': {
            'lowShelf': {'frequency': 100.0, 'gain': 0.5, 'q': 0.7},
            'lowMid': {'frequency': 300.0, 'gain': 0.5, 'q': 1.0},
            'highMid': {'frequency': 3000.0, 'gain': 1.0, 'q': 1.0},
            'highShelf': {'frequency': 8000.0, 'gain': 0.5, 'q': 0.7},
          },
          'masterCompressor': {
            'enabled': true,
            'threshold': -15.0,
            'ratio': 2.0,
            'attack': 10.0,
            'release': 200.0,
          },
          'masterReverb': {
            'enabled': true,
            'roomSize': 0.7,
            'wetLevel': 0.25,
          },
        },
      },
      {
        'id': 'broadcast_ready',
        'name': 'Broadcast Ready',
        'description': 'Broadcast standards compliant mix',
        'settings': {
          'masterEQ': {
            'lowShelf': {'frequency': 80.0, 'gain': 0.0, 'q': 0.7},
            'lowMid': {'frequency': 250.0, 'gain': 0.0, 'q': 1.0},
            'highMid': {'frequency': 2000.0, 'gain': 0.5, 'q': 1.0},
            'highShelf': {'frequency': 8000.0, 'gain': 0.0, 'q': 0.7},
          },
          'masterCompressor': {
            'enabled': true,
            'threshold': -18.0,
            'ratio': 3.0,
            'attack': 5.0,
            'release': 100.0,
          },
          'masterLimiter': {
            'enabled': true,
            'threshold': -1.0,
            'release': 50.0,
          },
        },
      },
    ];
  }

  // Apply mixing preset
  Future<void> applyPreset(String presetId) async {
    try {
      final preset = _mixingPresets.firstWhere((p) => p['id'] == presetId);
      final settings = preset['settings'] as Map<String, dynamic>;
      
      _statusController.add('Applying preset: ${preset['name']}');
      
      // Merge preset settings with current state
      _mixingState = _deepMerge(_mixingState, settings);
      
      _mixingStateController.add(_mixingState);
      await _applyMixingSettings();
      
      _statusController.add('Preset "${preset['name']}" applied successfully');
    } catch (e) {
      _errorController.add('Failed to apply preset: $e');
    }
  }

  // Update mixing parameter
  Future<void> updateMixingParameter(String category, String parameter, dynamic value) async {
    try {
      if (_mixingState[category] != null) {
        if (_mixingState[category] is Map) {
          (_mixingState[category] as Map<String, dynamic>)[parameter] = value;
        } else {
          _mixingState[category] = value;
        }
        
        _mixingStateController.add(_mixingState);
        
        // Apply changes in real-time
        await _applyMixingSettings();
      }
    } catch (e) {
      _errorController.add('Failed to update mixing parameter: $e');
    }
  }

  // Update EQ band
  Future<void> updateEQBand(String band, String parameter, double value) async {
    try {
      final eq = _mixingState['masterEQ'] as Map<String, dynamic>;
      if (eq[band] != null) {
        (eq[band] as Map<String, dynamic>)[parameter] = value;
        
        _mixingStateController.add(_mixingState);
        await _applyMixingSettings();
      }
    } catch (e) {
      _errorController.add('Failed to update EQ: $e');
    }
  }

  // Apply mixing settings
  Future<void> _applyMixingSettings() async {
    if (_isProcessing || kIsWeb) return;
    
    try {
      _isProcessing = true;
      _statusController.add('Applying mixing settings...');
      
      // This would apply the mixing settings to the audio engine
      // For now, we'll simulate the processing
      await Future.delayed(const Duration(milliseconds: 500));
      
      _statusController.add('Mixing settings applied');
    } catch (e) {
      _errorController.add('Failed to apply mixing settings: $e');
    } finally {
      _isProcessing = false;
    }
  }

  // Process mix with tracks
  Future<String?> processMix(List<Map<String, dynamic>> tracks, {
    String outputFormat = 'wav',
    int sampleRate = 44100,
    int bitDepth = 24,
  }) async {
    if (_isProcessing) {
      _errorController.add('Another mixing operation is already in progress');
      return null;
    }
    
    if (kIsWeb) {
      _errorController.add('Mix processing is not supported on web platform');
      return null;
    }
    
    if (tracks.isEmpty) {
      _errorController.add('No tracks provided for mixing');
      return null;
    }
    
    try {
      _isProcessing = true;
      _progressController.add(0.0);
      _statusController.add('Validating tracks...');
      
      // Validate all track files exist
      for (final track in tracks) {
        final filePath = track['filePath'] as String?;
        if (filePath == null || !await File(filePath).exists()) {
          throw Exception('Track file not found: $filePath');
        }
      }
      
      _progressController.add(0.1);
      _statusController.add('Processing mix...');
      
      final directory = await getApplicationDocumentsDirectory();
      final mixDir = Directory('${directory.path}/mixes');
      if (!await mixDir.exists()) {
        await mixDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${mixDir.path}/mix_$timestamp.$outputFormat';
      
      // Build complex FFmpeg command for mixing
      final command = await _buildMixCommand(tracks, outputPath, sampleRate, bitDepth);
      
      _progressController.add(0.2);
      _statusController.add('Applying effects and mixing...');
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      _progressController.add(0.8);
      
      if (ReturnCode.isSuccess(returnCode)) {
        // Verify output file was created
        final outputFile = File(outputPath);
        if (await outputFile.exists() && await outputFile.length() > 0) {
          _progressController.add(1.0);
          _statusController.add('Mix processed successfully');
          return outputPath;
        } else {
          throw Exception('Output file was not created or is empty');
        }
      } else {
        final logs = await session.getAllLogsAsString();
        throw Exception('FFmpeg processing failed: $logs');
      }
    } catch (e) {
      _errorController.add('Failed to process mix: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  // Build FFmpeg command for mixing
  Future<String> _buildMixCommand(
    List<Map<String, dynamic>> tracks, 
    String outputPath, 
    int sampleRate, 
    int bitDepth
  ) async {
    List<String> inputs = [];
    List<String> filters = [];
    
    // Add input files
    for (int i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      if (track['filePath'] != null && !track['isMuted']) {
        inputs.add('-i "${track['filePath']}"');
        
        // Build track-specific filters
        List<String> trackFilters = [];
        
        // Volume
        if (track['volume'] != 1.0) {
          trackFilters.add('volume=${track['volume']}');
        }
        
        // EQ
        final eq = track['eq'] as Map<String, dynamic>? ?? {};
        if (eq['low'] != null && eq['low'] != 0.0) {
          trackFilters.add('equalizer=f=100:width_type=h:width=50:g=${eq['low']}');
        }
        if (eq['mid'] != null && eq['mid'] != 0.0) {
          trackFilters.add('equalizer=f=1000:width_type=h:width=100:g=${eq['mid']}');
        }
        if (eq['high'] != null && eq['high'] != 0.0) {
          trackFilters.add('equalizer=f=10000:width_type=h:width=1000:g=${eq['high']}');
        }
        
        // Pan
        if (track['pan'] != null && track['pan'] != 0.0) {
          final panValue = track['pan'] as double;
          if (panValue < 0) {
            trackFilters.add('pan=stereo|c0=c0*${1 + panValue}+c1*${-panValue}|c1=c1');
          } else {
            trackFilters.add('pan=stereo|c0=c0|c1=c1*${1 - panValue}+c0*${panValue}');
          }
        }
        
        if (trackFilters.isNotEmpty) {
          filters.add('[$i:0]${trackFilters.join(',')}[track$i]');
        } else {
          filters.add('[$i:0]anull[track$i]');
        }
      }
    }
    
    // Mix all tracks
    if (filters.isNotEmpty) {
      final trackLabels = List.generate(filters.length, (i) => '[track$i]').join('');
      filters.add('${trackLabels}amix=inputs=${filters.length}:duration=longest[mixed]');
      
      // Apply master effects
      List<String> masterFilters = [];
      
      // Master EQ
      final masterEQ = _mixingState['masterEQ'] as Map<String, dynamic>;
      for (final band in masterEQ.keys) {
        final bandData = masterEQ[band] as Map<String, dynamic>;
        if (bandData['gain'] != 0.0) {
          masterFilters.add('equalizer=f=${bandData['frequency']}:width_type=q:width=${bandData['q']}:g=${bandData['gain']}');
        }
      }
      
      // Master compressor
      final comp = _mixingState['masterCompressor'] as Map<String, dynamic>;
      if (comp['enabled'] == true) {
        masterFilters.add('acompressor=threshold=${comp['threshold']}dB:ratio=${comp['ratio']}:attack=${comp['attack']}:release=${comp['release']}');
      }
      
      // Master limiter
      final limiter = _mixingState['masterLimiter'] as Map<String, dynamic>;
      if (limiter['enabled'] == true) {
        masterFilters.add('alimiter=level_in=1:level_out=1:limit=${limiter['threshold']}:attack=5:release=${limiter['release']}');
      }
      
      // Master volume
      masterFilters.add('volume=${_mixingState['masterVolume']}');
      
      if (masterFilters.isNotEmpty) {
        filters.add('[mixed]${masterFilters.join(',')}[final]');
      } else {
        filters.add('[mixed]anull[final]');
      }
    }
    
    // Build final command
    String command = inputs.join(' ');
    if (filters.isNotEmpty) {
      command += ' -filter_complex "${filters.join(';')}"';
      command += ' -map "[final]"';
    }
    command += ' -ar $sampleRate';
    
    if (outputPath.endsWith('.wav')) {
      command += ' -acodec pcm_s${bitDepth}le';
    } else if (outputPath.endsWith('.mp3')) {
      command += ' -acodec libmp3lame -b:a 320k';
    }
    
    command += ' "$outputPath"';
    
    return command;
  }

  // Audio analysis
  Future<void> _initializeAnalysis() async {
    try {
      _isAnalyzing = true;
      
      // Start real-time analysis simulation
      Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (!_isAnalyzing) {
          timer.cancel();
          return;
        }
        
        try {
          _updateAnalysisData();
        } catch (e) {
          _errorController.add('Analysis update failed: $e');
          timer.cancel();
          _isAnalyzing = false;
        }
      });
    } catch (e) {
      _errorController.add('Failed to initialize analysis: $e');
      _isAnalyzing = false;
      rethrow;
    }
  }

  void _updateAnalysisData() {
    try {
      final random = Random();
      
      // Create a copy to avoid concurrent modification
      final updatedData = Map<String, dynamic>.from(_analysisData);
      
      // Simulate spectrum analysis
      final spectrum = List<double>.from(updatedData['spectrum'] as List);
      for (int i = 0; i < spectrum.length; i++) {
        final frequency = i * 22050 / spectrum.length;
        final amplitude = _generateSpectrumValue(frequency, random);
        spectrum[i] = amplitude;
      }
      updatedData['spectrum'] = spectrum;
      
      // Update other analysis parameters with bounds checking
      updatedData['peakFrequency'] = (440.0 + random.nextDouble() * 2000).clamp(20.0, 20000.0);
      updatedData['spectralCentroid'] = (1000.0 + random.nextDouble() * 3000).clamp(100.0, 10000.0);
      updatedData['spectralRolloff'] = (8000.0 + random.nextDouble() * 4000).clamp(1000.0, 20000.0);
      updatedData['lufs'] = (-23.0 + random.nextDouble() * 10).clamp(-60.0, 0.0);
      updatedData['truePeak'] = (-6.0 + random.nextDouble() * 5).clamp(-20.0, 0.0);
      updatedData['dynamicRange'] = (8.0 + random.nextDouble() * 8).clamp(1.0, 30.0);
      updatedData['stereoWidth'] = (0.8 + random.nextDouble() * 0.4).clamp(0.0, 2.0);
      updatedData['phaseCorrelation'] = (0.7 + random.nextDouble() * 0.3).clamp(-1.0, 1.0);
      
      // Update tonal balance
      final tonalBalance = Map<String, dynamic>.from(updatedData['tonalBalance'] as Map<String, dynamic>);
      tonalBalance['bass'] = (-3.0 + random.nextDouble() * 6).clamp(-12.0, 12.0);
      tonalBalance['lowMid'] = (-2.0 + random.nextDouble() * 4).clamp(-12.0, 12.0);
      tonalBalance['highMid'] = (-1.0 + random.nextDouble() * 3).clamp(-12.0, 12.0);
      tonalBalance['treble'] = (-2.0 + random.nextDouble() * 4).clamp(-12.0, 12.0);
      updatedData['tonalBalance'] = tonalBalance;
      
      // Update the main data and notify listeners
      _analysisData = updatedData;
      _analysisController.add(Map<String, dynamic>.from(_analysisData));
    } catch (e) {
      _errorController.add('Failed to update analysis data: $e');
    }
  }

  double _generateSpectrumValue(double frequency, Random random) {
    // Simulate realistic spectrum with peaks and valleys
    double value = 0.0;
    
    // Bass frequencies (20-250 Hz)
    if (frequency < 250) {
      value = 0.6 + random.nextDouble() * 0.4;
    }
    // Low-mid frequencies (250-2000 Hz)
    else if (frequency < 2000) {
      value = 0.4 + random.nextDouble() * 0.5;
    }
    // High-mid frequencies (2000-8000 Hz)
    else if (frequency < 8000) {
      value = 0.3 + random.nextDouble() * 0.6;
    }
    // High frequencies (8000+ Hz)
    else {
      value = 0.2 + random.nextDouble() * 0.4;
    }
    
    // Add some randomness and peaks
    if (random.nextDouble() < 0.1) {
      value *= 1.5; // Random peaks
    }
    
    return value.clamp(0.0, 1.0);
  }

  // Auto-mixing features
  Future<void> autoBalance() async {
    try {
      _statusController.add('Auto-balancing mix...');
      
      // Analyze current mix and suggest improvements
      final analysis = await _analyzeMixBalance();
      
      // Apply automatic adjustments
      if (analysis['bassHeavy']) {
        await updateEQBand('lowShelf', 'gain', -1.5);
      }
      if (analysis['tooMuchMidrange']) {
        await updateEQBand('lowMid', 'gain', -1.0);
      }
      if (analysis['lackingPresence']) {
        await updateEQBand('highMid', 'gain', 1.5);
      }
      if (analysis['dullTop']) {
        await updateEQBand('highShelf', 'gain', 1.0);
      }
      
      _statusController.add('Auto-balance complete');
    } catch (e) {
      _errorController.add('Auto-balance failed: $e');
    }
  }

  Future<Map<String, bool>> _analyzeMixBalance() async {
    // Simulate mix analysis
    final random = Random();
    return {
      'bassHeavy': random.nextBool(),
      'tooMuchMidrange': random.nextBool(),
      'lackingPresence': random.nextBool(),
      'dullTop': random.nextBool(),
    };
  }

  Future<void> autoCompress() async {
    try {
      _statusController.add('Applying intelligent compression...');
      
      // Analyze dynamic range and apply appropriate compression
      final dynamicRange = _analysisData['dynamicRange'] as double;
      
      if (dynamicRange > 15) {
        // Wide dynamic range - gentle compression
        await updateMixingParameter('masterCompressor', 'threshold', -15.0);
        await updateMixingParameter('masterCompressor', 'ratio', 2.5);
        await updateMixingParameter('masterCompressor', 'attack', 10.0);
        await updateMixingParameter('masterCompressor', 'release', 150.0);
      } else if (dynamicRange < 8) {
        // Already compressed - minimal processing
        await updateMixingParameter('masterCompressor', 'threshold', -20.0);
        await updateMixingParameter('masterCompressor', 'ratio', 1.5);
      } else {
        // Normal range - moderate compression
        await updateMixingParameter('masterCompressor', 'threshold', -12.0);
        await updateMixingParameter('masterCompressor', 'ratio', 3.0);
        await updateMixingParameter('masterCompressor', 'attack', 5.0);
        await updateMixingParameter('masterCompressor', 'release', 100.0);
      }
      
      await updateMixingParameter('masterCompressor', 'enabled', true);
      
      _statusController.add('Intelligent compression applied');
    } catch (e) {
      _errorController.add('Auto-compression failed: $e');
    }
  }

  Future<void> autoLimit() async {
    try {
      _statusController.add('Applying intelligent limiting...');
      
      final truePeak = _analysisData['truePeak'] as double;
      
      if (truePeak > -1.0) {
        // Peaks too high - aggressive limiting
        await updateMixingParameter('masterLimiter', 'threshold', -0.5);
        await updateMixingParameter('masterLimiter', 'release', 30.0);
      } else {
        // Safe levels - gentle limiting
        await updateMixingParameter('masterLimiter', 'threshold', -1.0);
        await updateMixingParameter('masterLimiter', 'release', 50.0);
      }
      
      await updateMixingParameter('masterLimiter', 'enabled', true);
      
      _statusController.add('Intelligent limiting applied');
    } catch (e) {
      _errorController.add('Auto-limiting failed: $e');
    }
  }

  // Utility methods
  Map<String, dynamic> _deepMerge(Map<String, dynamic> target, Map<String, dynamic> source) {
    final result = Map<String, dynamic>.from(target);
    
    source.forEach((key, value) {
      if (value is Map<String, dynamic> && result[key] is Map<String, dynamic>) {
        result[key] = _deepMerge(result[key] as Map<String, dynamic>, value);
      } else {
        result[key] = value;
      }
    });
    
    return result;
  }

  // Getters
  Map<String, dynamic> get mixingState => _mixingState;
  Map<String, dynamic> get analysisData => _analysisData;
  List<Map<String, dynamic>> get mixingPresets => _mixingPresets;
  bool get isProcessing => _isProcessing;
  bool get isAnalyzing => _isAnalyzing;

  void dispose() {
    _isAnalyzing = false;
    _mixingStateController.close();
    _analysisController.close();
    _statusController.close();
    _errorController.close();
    _progressController.close();
  }
}
