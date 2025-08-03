import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/audio_service.dart';
import './widgets/audio_controls_widget.dart';
import './widgets/audio_meter_widget.dart';
import './widgets/timeline_widget.dart';
import './widgets/track_header_widget.dart';
import './widgets/transport_controls_widget.dart';
import './widgets/waveform_widget.dart';

class TrackEditor extends StatefulWidget {
  const TrackEditor({super.key});

  @override
  State<TrackEditor> createState() => _TrackEditorState();
}

class _TrackEditorState extends State<TrackEditor>
    with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();

  // Audio playback state
  bool _isPlaying = false;
  bool _isRecording = false;
  double _currentTime = 0.0;
  double _totalDuration = 180.0; // 3 minutes
  double _tempo = 120.0;

  // Audio controls
  double _masterVolume = 0.8;
  double _masterPitch = 0.0;
  double _masterSpeed = 1.0;
  double _masterReverb = 0.0;
  double _masterEcho = 0.0;
  bool _metronomeEnabled = false;
  bool _loopEnabled = false;
  double _loopStart = 0.0;
  double _loopEnd = 100.0;

  // Timeline state
  double _playheadPosition = 0.0;
  double _zoomLevel = 1.0;
  double _scrollPosition = 0.0;

  // Enhanced track data with more instruments and effects
  final List<Map<String, dynamic>> _tracks = [
    {
      "id": 1,
      "name": "Vocals",
      "icon": "mic",
      "color": const Color(0xFF00D4FF),
      "isMuted": false,
      "isSolo": false,
      "volume": 0.8,
      "pitch": 0.0,
      "speed": 1.0,
      "level": 0.6,
      "pan": 0.0,
      "reverb": 0.0,
      "echo": 0.0,
      "eq": {"low": 0.0, "mid": 0.0, "high": 0.0},
      "stemPath": null,
      "waveformData": [
        0.2,
        0.5,
        0.8,
        0.3,
        0.7,
        0.4,
        0.9,
        0.1,
        0.6,
        0.5,
        0.3,
        0.8,
        0.2,
        0.7,
        0.4,
        0.6,
        0.9,
        0.3,
        0.5,
        0.8
      ],
    },
    {
      "id": 2,
      "name": "Drums",
      "icon": "music_note",
      "color": const Color(0xFFFF4757),
      "isMuted": false,
      "isSolo": false,
      "volume": 0.9,
      "pitch": 0.0,
      "speed": 1.0,
      "level": 0.8,
      "pan": 0.0,
      "reverb": 0.0,
      "echo": 0.0,
      "eq": {"low": 0.0, "mid": 0.0, "high": 0.0},
      "stemPath": null,
      "waveformData": [
        0.9,
        0.1,
        0.8,
        0.2,
        0.9,
        0.1,
        0.7,
        0.3,
        0.8,
        0.2,
        0.9,
        0.1,
        0.6,
        0.4,
        0.8,
        0.2,
        0.9,
        0.1,
        0.7,
        0.3
      ],
    },
    {
      "id": 3,
      "name": "Bass",
      "icon": "graphic_eq",
      "color": const Color(0xFF00C896),
      "isMuted": false,
      "isSolo": false,
      "volume": 0.7,
      "pitch": 0.0,
      "speed": 1.0,
      "level": 0.5,
      "pan": 0.0,
      "reverb": 0.0,
      "echo": 0.0,
      "eq": {"low": 0.0, "mid": 0.0, "high": 0.0},
      "stemPath": null,
      "waveformData": [
        0.4,
        0.6,
        0.3,
        0.7,
        0.4,
        0.6,
        0.5,
        0.3,
        0.6,
        0.4,
        0.7,
        0.3,
        0.5,
        0.6,
        0.4,
        0.7,
        0.3,
        0.6,
        0.4,
        0.5
      ],
    },
    {
      "id": 4,
      "name": "Piano",
      "icon": "piano",
      "color": const Color(0xFFFFB800),
      "isMuted": false,
      "isSolo": false,
      "volume": 0.6,
      "pitch": 0.0,
      "speed": 1.0,
      "level": 0.4,
      "pan": 0.0,
      "reverb": 0.0,
      "echo": 0.0,
      "eq": {"low": 0.0, "mid": 0.0, "high": 0.0},
      "stemPath": null,
      "waveformData": [
        0.3,
        0.4,
        0.6,
        0.2,
        0.5,
        0.7,
        0.3,
        0.4,
        0.6,
        0.2,
        0.5,
        0.7,
        0.3,
        0.4,
        0.6,
        0.2,
        0.5,
        0.7,
        0.3,
        0.4
      ],
    },
    {
      "id": 5,
      "name": "Guitar",
      "icon": "music_video",
      "color": const Color(0xFFFFC107),
      "isMuted": false,
      "isSolo": false,
      "volume": 0.6,
      "pitch": 0.0,
      "speed": 1.0,
      "level": 0.5,
      "pan": 0.0,
      "reverb": 0.0,
      "echo": 0.0,
      "eq": {"low": 0.0, "mid": 0.0, "high": 0.0},
      "stemPath": null,
      "waveformData": [
        0.5,
        0.3,
        0.7,
        0.2,
        0.6,
        0.4,
        0.8,
        0.1,
        0.5,
        0.3,
        0.7,
        0.2,
        0.6,
        0.4,
        0.8,
        0.1,
        0.5,
        0.3,
        0.7,
        0.2
      ],
    },
    {
      "id": 6,
      "name": "Violin",
      "icon": "library_music",
      "color": const Color(0xFF3F51B5),
      "isMuted": false,
      "isSolo": false,
      "volume": 0.5,
      "pitch": 0.0,
      "speed": 1.0,
      "level": 0.4,
      "pan": 0.0,
      "reverb": 0.0,
      "echo": 0.0,
      "eq": {"low": 0.0, "mid": 0.0, "high": 0.0},
      "stemPath": null,
      "waveformData": [
        0.3,
        0.6,
        0.2,
        0.8,
        0.4,
        0.7,
        0.1,
        0.5,
        0.3,
        0.6,
        0.2,
        0.8,
        0.4,
        0.7,
        0.1,
        0.5,
        0.3,
        0.6,
        0.2,
        0.8
      ],
    },
    {
      "id": 7,
      "name": "Flute",
      "icon": "air",
      "color": const Color(0xFF00BCD4),
      "isMuted": false,
      "isSolo": false,
      "volume": 0.4,
      "pitch": 0.0,
      "speed": 1.0,
      "level": 0.3,
      "pan": 0.0,
      "reverb": 0.0,
      "echo": 0.0,
      "eq": {"low": 0.0, "mid": 0.0, "high": 0.0},
      "stemPath": null,
      "waveformData": [
        0.1,
        0.4,
        0.2,
        0.6,
        0.3,
        0.5,
        0.1,
        0.4,
        0.2,
        0.6,
        0.3,
        0.5,
        0.1,
        0.4,
        0.2,
        0.6,
        0.3,
        0.5,
        0.1,
        0.4
      ],
    },
    {
      "id": 8,
      "name": "Other",
      "icon": "audiotrack",
      "color": const Color(0xFFB0B0B0),
      "isMuted": false,
      "isSolo": false,
      "volume": 0.5,
      "pitch": 0.0,
      "speed": 1.0,
      "level": 0.3,
      "pan": 0.0,
      "reverb": 0.0,
      "echo": 0.0,
      "eq": {"low": 0.0, "mid": 0.0, "high": 0.0},
      "stemPath": null,
      "waveformData": [
        0.2,
        0.3,
        0.4,
        0.1,
        0.3,
        0.5,
        0.2,
        0.4,
        0.3,
        0.1,
        0.4,
        0.5,
        0.2,
        0.3,
        0.4,
        0.1,
        0.3,
        0.5,
        0.2,
        0.4
      ],
    },
  ];

  // Auto-save timer
  late AnimationController _autoSaveController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeAudioService();
    _autoSaveController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _startAutoSave();

    // Get stem data from arguments if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('stems')) {
        _loadStemData(args['stems'] as Map<String, String>);
      }
    });
  }

  @override
  void dispose() {
    _autoSaveController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioService() async {
    await _audioService.initialize();

    // Listen to audio service streams
    _audioService.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });

    _audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentTime = position.inSeconds.toDouble();
          _playheadPosition =
              _totalDuration > 0 ? _currentTime / _totalDuration : 0.0;
        });
      }
    });

    _audioService.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _totalDuration = duration.inSeconds.toDouble();
        });
      }
    });
  }

  void _loadStemData(Map<String, String> stemPaths) {
    for (int i = 0; i < _tracks.length; i++) {
      final trackName = _tracks[i]["name"].toString().toLowerCase();
      final stemPath = stemPaths[trackName];
      if (stemPath != null) {
        _tracks[i]["stemPath"] = stemPath;
        // Load stem into audio service
        _audioService.loadStemTrack(trackName, stemPath);
      }
    }
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void _startAutoSave() {
    _autoSaveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_hasUnsavedChanges) {
          _saveProject();
        }
        _autoSaveController.reset();
        _autoSaveController.forward();
      }
    });
    _autoSaveController.forward();
  }

  void _saveProject() {
    setState(() {
      _hasUnsavedChanges = false;
    });

    // Show save confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successColor,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Project auto-saved',
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onPlayPause() async {
    try {
      if (_isPlaying) {
        await _audioService.pause();
        await _audioService.pauseAllStems();
      } else {
        await _audioService.play();
        await _audioService.playAllStems();
      }

      setState(() {
        _hasUnsavedChanges = true;
      });

      // Haptic feedback
      HapticFeedback.lightImpact();
    } catch (e) {
      _showErrorSnackBar('Playback failed: $e');
    }
  }

  void _onStop() async {
    try {
      await _audioService.stop();
      await _audioService.pauseAllStems();

      setState(() {
        _isPlaying = false;
        _isRecording = false;
        _currentTime = 0.0;
        _playheadPosition = 0.0;
        _hasUnsavedChanges = true;
      });

      HapticFeedback.mediumImpact();
    } catch (e) {
      _showErrorSnackBar('Stop failed: $e');
    }
  }

  void _onRecord() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _isPlaying = true;
      }
      _hasUnsavedChanges = true;
    });

    HapticFeedback.heavyImpact();
  }

  void _onPlayheadChanged(double position) async {
    setState(() {
      _playheadPosition = position;
      _currentTime = position * _totalDuration;
      _hasUnsavedChanges = true;
    });

    // Seek audio to new position
    final seekPosition = Duration(seconds: _currentTime.round());
    await _audioService.seek(seekPosition);
  }

  void _onZoomChanged(double zoom) {
    setState(() {
      _zoomLevel = zoom.clamp(0.5, 4.0);
    });
  }

  void _onScrollChanged(double scroll) {
    setState(() {
      _scrollPosition = scroll.clamp(0.0, 1.0);
    });
  }

  void _onTempoChanged(double tempo) {
    setState(() {
      _tempo = tempo;
      _hasUnsavedChanges = true;
    });
  }

  void _onMasterVolumeChanged(double volume) async {
    setState(() {
      _masterVolume = volume;
      _hasUnsavedChanges = true;
    });
    await _audioService.setVolume(volume);
  }

  void _onMasterSpeedChanged(double speed) async {
    setState(() {
      _masterSpeed = speed;
      _hasUnsavedChanges = true;
    });
    await _audioService.setSpeed(speed);
  }

  void _onMasterPitchChanged(double pitch) {
    setState(() {
      _masterPitch = pitch;
      _hasUnsavedChanges = true;
    });
    // Note: Pitch shifting would require additional audio processing
    // This is a placeholder for the UI control
  }

  void _resetAudioControls() {
    setState(() {
      _masterVolume = 0.8;
      _masterPitch = 0.0;
      _masterSpeed = 1.0;
      _hasUnsavedChanges = true;
    });
    _audioService.setVolume(_masterVolume);
    _audioService.setSpeed(_masterSpeed);
  }

  void _onTrackMuteToggle(int trackIndex) async {
    setState(() {
      _tracks[trackIndex]["isMuted"] =
          !(_tracks[trackIndex]["isMuted"] as bool);
      _hasUnsavedChanges = true;
    });

    // Mute/unmute stem in audio service
    final trackName = _tracks[trackIndex]["name"].toString().toLowerCase();
    final volume = _tracks[trackIndex]["isMuted"] as bool
        ? 0.0
        : _tracks[trackIndex]["volume"] as double;
    await _audioService.setStemVolume(trackName, volume);

    HapticFeedback.selectionClick();
  }

  void _onTrackSoloToggle(int trackIndex) async {
    setState(() {
      // Toggle solo for selected track
      _tracks[trackIndex]["isSolo"] = !(_tracks[trackIndex]["isSolo"] as bool);

      // If soloing, mute all other tracks
      if (_tracks[trackIndex]["isSolo"] as bool) {
        for (int i = 0; i < _tracks.length; i++) {
          if (i != trackIndex) {
            _tracks[i]["isSolo"] = false;
          }
        }
      }
      _hasUnsavedChanges = true;
    });

    // Apply solo logic to audio service
    for (int i = 0; i < _tracks.length; i++) {
      final trackName = _tracks[i]["name"].toString().toLowerCase();
      final isSolo = _tracks[trackIndex]["isSolo"] as bool;
      final volume =
          (isSolo && i != trackIndex) ? 0.0 : _tracks[i]["volume"] as double;
      await _audioService.setStemVolume(trackName, volume);
    }

    HapticFeedback.selectionClick();
  }

  void _onTrackVolumeChanged(int trackIndex, double volume) async {
    setState(() {
      _tracks[trackIndex]["volume"] = volume;
      _hasUnsavedChanges = true;
    });

    // Update stem volume in audio service
    final trackName = _tracks[trackIndex]["name"].toString().toLowerCase();
    await _audioService.setStemVolume(trackName, volume);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimary,
            size: 6.w,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track Editor',
              style: AppTheme.darkTheme.textTheme.titleLarge,
            ),
            if (_hasUnsavedChanges)
              Text(
                'Unsaved changes',
                style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.warningColor,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showAudioControls(),
            icon: CustomIconWidget(
              iconName: 'tune',
              color: AppTheme.accentColor,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/export-options'),
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.textPrimary,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timeline
          TimelineWidget(
            playheadPosition: _playheadPosition,
            zoomLevel: _zoomLevel,
            scrollPosition: _scrollPosition,
            totalDuration: _totalDuration,
            onPlayheadChanged: _onPlayheadChanged,
            onZoomChanged: _onZoomChanged,
            onScrollChanged: _onScrollChanged,
          ),

          // Track area
          Expanded(
            child: GestureDetector(
              onScaleUpdate: (details) {
                // Pinch to zoom
                if (details.scale != 1.0) {
                  _onZoomChanged(_zoomLevel * details.scale);
                }
              },
              onPanUpdate: (details) {
                // Pan to scroll
                if (details.delta.dx.abs() > details.delta.dy.abs()) {
                  final scrollDelta = -details.delta.dx / (100.w);
                  _onScrollChanged(_scrollPosition + scrollDelta);
                }
              },
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tracks.length,
                itemBuilder: (context, index) {
                  final track = _tracks[index];
                  return Row(
                    children: [
                      // Track header
                      TrackHeaderWidget(
                        trackName: track["name"] as String,
                        iconName: track["icon"] as String,
                        trackColor: track["color"] as Color,
                        isMuted: track["isMuted"] as bool,
                        isSolo: track["isSolo"] as bool,
                        volume: track["volume"] as double,
                        onMuteToggle: () => _onTrackMuteToggle(index),
                        onSoloToggle: () => _onTrackSoloToggle(index),
                        onVolumeChanged: (volume) =>
                            _onTrackVolumeChanged(index, volume),
                      ),

                      // Waveform
                      Expanded(
                        child: WaveformWidget(
                          trackColor: track["color"] as Color,
                          isMuted: track["isMuted"] as bool,
                          playheadPosition: _playheadPosition,
                          zoomLevel: _zoomLevel,
                          scrollPosition: _scrollPosition,
                          waveformData:
                              (track["waveformData"] as List).cast<double>(),
                        ),
                      ),

                      // Audio meter
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: AudioMeterWidget(
                          level: track["level"] as double,
                          trackColor: track["color"] as Color,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Transport controls
          TransportControlsWidget(
            isPlaying: _isPlaying,
            isRecording: _isRecording,
            currentTime: _currentTime,
            totalDuration: _totalDuration,
            tempo: _tempo,
            onPlayPause: _onPlayPause,
            onStop: _onStop,
            onRecord: _onRecord,
            onTempoChanged: _onTempoChanged,
          ),
        ],
      ),

      // Floating action buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "beat_library",
            onPressed: () => Navigator.pushNamed(context, '/beat-library'),
            backgroundColor: AppTheme.warningColor,
            child: CustomIconWidget(
              iconName: 'library_music',
              color: AppTheme.primaryDark,
              size: 6.w,
            ),
          ),
          SizedBox(height: 2.h),
          FloatingActionButton(
            heroTag: "ai_processing",
            onPressed: () => Navigator.pushNamed(context, '/ai-processing'),
            backgroundColor: AppTheme.successColor,
            child: CustomIconWidget(
              iconName: 'auto_fix_high',
              color: AppTheme.primaryDark,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  void _showAudioControls() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: AudioControlsWidget(
                  volume: _masterVolume,
                  pitch: _masterPitch,
                  speed: _masterSpeed,
                  onVolumeChanged: _onMasterVolumeChanged,
                  onPitchChanged: _onMasterPitchChanged,
                  onSpeedChanged: _onMasterSpeedChanged,
                  onReset: _resetAudioControls,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
