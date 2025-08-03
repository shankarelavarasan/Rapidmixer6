import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/audio_processing_service.dart';
import './widgets/animated_particles_widget.dart';
import './widgets/cancel_button_widget.dart';
import './widgets/processing_progress_widget.dart';
import './widgets/processing_stage_widget.dart';

class AIProcessing extends StatefulWidget {
  const AIProcessing({super.key});

  @override
  State<AIProcessing> createState() => _AIProcessingState();
}

class _AIProcessingState extends State<AIProcessing>
    with TickerProviderStateMixin {
  final AudioProcessingService _processingService = AudioProcessingService();

  late AnimationController _particlesController;
  late AnimationController _pulseController;

  // Processing state
  bool _isProcessing = false;
  bool _isCompleted = false;
  bool _isCancelled = false;
  double _progress = 0.0;
  String _currentStage = '';
  Map<String, dynamic>? _inputFileData;
  Map<String, String>? _resultStems;

  final List<Map<String, dynamic>> _processingStages = [
    {
      "id": 1,
      "title": "Audio Analysis",
      "description": "Analyzing frequency patterns and audio structure",
      "icon": "analytics",
      "color": const Color(0xFF00D4FF),
      "isCompleted": false,
      "isActive": false,
    },
    {
      "id": 2,
      "title": "Vocal Extraction",
      "description": "Separating vocal tracks from instrumental",
      "icon": "mic",
      "color": const Color(0xFF00D4FF),
      "isCompleted": false,
      "isActive": false,
    },
    {
      "id": 3,
      "title": "Drum Isolation",
      "description": "Identifying and isolating drum patterns",
      "icon": "music_note",
      "color": const Color(0xFFFF4757),
      "isCompleted": false,
      "isActive": false,
    },
    {
      "id": 4,
      "title": "Bass Separation",
      "description": "Extracting bass frequencies and patterns",
      "icon": "graphic_eq",
      "color": const Color(0xFF00C896),
      "isCompleted": false,
      "isActive": false,
    },
    {
      "id": 5,
      "title": "Instrument Processing",
      "description": "Separating piano and other instruments",
      "icon": "piano",
      "color": const Color(0xFFFFB800),
      "isCompleted": false,
      "isActive": false,
    },
    {
      "id": 6,
      "title": "Finalization",
      "description": "Optimizing and finalizing stem tracks",
      "icon": "check_circle",
      "color": const Color(0xFF00C896),
      "isCompleted": false,
      "isActive": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeProcessingService();

    // Get file data from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _inputFileData = args;
        });
        _startProcessing();
      }
    });
  }

  @override
  void dispose() {
    _particlesController.dispose();
    _pulseController.dispose();
    _processingService.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _particlesController =
        AnimationController(duration: const Duration(seconds: 10), vsync: this)
          ..repeat();

    _pulseController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);
  }

  void _initializeProcessingService() {
    // Listen to processing progress
    _processingService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _progress = progress;
          _updateStageProgress(progress);
        });
      }
    });

    _processingService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStage = status;
        });
      }
    });

    _processingService.errorStream.listen((error) {
      if (mounted) {
        _showErrorDialog(error);
      }
    });
  }

  void _updateStageProgress(double progress) {
    final stageIndex = (progress * _processingStages.length).floor();

    for (int i = 0; i < _processingStages.length; i++) {
      setState(() {
        _processingStages[i]["isCompleted"] = i < stageIndex;
        _processingStages[i]["isActive"] = i == stageIndex && progress < 1.0;
      });
    }
  }

  Future<void> _startProcessing() async {
    if (_inputFileData == null) return;

    setState(() {
      _isProcessing = true;
      _isCompleted = false;
      _isCancelled = false;
      _progress = 0.0;
    });

    try {
      final inputPath = _inputFileData!["path"] as String? ?? "";

      if (inputPath.isNotEmpty) {
        final stems = await _processingService.separateStems(inputPath);

        if (stems.isNotEmpty && !_isCancelled) {
          setState(() {
            _resultStems = stems;
            _isCompleted = true;
            _progress = 1.0;
          });

          // Mark all stages as completed
          for (var stage in _processingStages) {
            stage["isCompleted"] = true;
            stage["isActive"] = false;
          }

          // Show completion and navigate to track editor after delay
          await Future.delayed(const Duration(seconds: 2));
          if (mounted && !_isCancelled) {
            _navigateToTrackEditor();
          }
        }
      } else {
        throw Exception('Invalid input file path');
      }
    } catch (e) {
      if (mounted && !_isCancelled) {
        _showErrorDialog('Processing failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _cancelProcessing() {
    setState(() {
      _isCancelled = true;
      _isProcessing = false;
    });

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: AppTheme.darkTheme.colorScheme.surface,
                title: Text('Cancel Processing',
                    style: AppTheme.darkTheme.textTheme.titleLarge),
                content: Text(
                    'Are you sure you want to cancel the AI processing?',
                    style: AppTheme.darkTheme.textTheme.bodyMedium),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isCancelled = false;
                          _isProcessing = true;
                        });
                      },
                      child: Text('Continue',
                          style: TextStyle(color: AppTheme.textSecondary))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context); // Go back to previous screen
                      },
                      child: Text('Cancel',
                          style: TextStyle(color: AppTheme.errorColor))),
                ]));
  }

  void _navigateToTrackEditor() {
    Navigator.pushReplacementNamed(context, '/track-editor', arguments: {
      'inputFile': _inputFileData,
      'stems': _resultStems,
    });
  }

  void _showErrorDialog(String error) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: AppTheme.darkTheme.colorScheme.surface,
                title: Row(children: [
                  CustomIconWidget(
                      iconName: 'error', color: AppTheme.errorColor, size: 6.w),
                  SizedBox(width: 3.w),
                  Text('Processing Error',
                      style: AppTheme.darkTheme.textTheme.titleLarge),
                ]),
                content:
                    Text(error, style: AppTheme.darkTheme.textTheme.bodyMedium),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startProcessing(); // Retry
                      },
                      child: Text('Retry',
                          style: TextStyle(color: AppTheme.accentColor))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context); // Go back
                      },
                      child: Text('Cancel',
                          style: TextStyle(color: AppTheme.textSecondary))),
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: SafeArea(
            child: Stack(children: [
          // Background particles
          AnimatedParticlesWidget(),

          // Main content
          Column(children: [
            _buildHeader(),
            Expanded(
                child: _isCompleted
                    ? _buildCompletionView()
                    : _buildProcessingView()),
          ]),

          // Cancel button (only show during processing)
          if (_isProcessing && !_isCompleted)
            Positioned(
                bottom: 4.h,
                left: 4.w,
                right: 4.w,
                child: CancelButtonWidget(onCancel: _cancelProcessing)),
        ])));
  }

  Widget _buildHeader() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(children: [
          if (!_isProcessing || _isCompleted)
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                        color: AppTheme.darkTheme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppTheme.borderColor, width: 1)),
                    child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.textPrimary,
                        size: 6.w))),
          if (!_isProcessing || _isCompleted) SizedBox(width: 4.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    _isCompleted
                        ? "Processing Complete!"
                        : "AI Stem Separation",
                    style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isCompleted
                            ? AppTheme.successColor
                            : AppTheme.textPrimary)),
                SizedBox(height: 0.5.h),
                Text(
                    _isCompleted
                        ? "Your audio has been successfully separated into stem tracks"
                        : "Processing ${_inputFileData?["name"] ?? "audio file"}...",
                    style: AppTheme.darkTheme.textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.textSecondary)),
              ])),
        ]));
  }

  Widget _buildProcessingView() {
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(children: [
          SizedBox(height: 2.h),

          // Progress indicator
          ProcessingProgressWidget(
              progress: _progress, 
              currentStage: _currentStage,
              estimatedTime: Duration(minutes: 5)),

          SizedBox(height: 4.h),

          // Processing stages
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _processingStages.length,
              itemBuilder: (context, index) {
                final stage = _processingStages[index];
                return ProcessingStageWidget(
                    currentStage: stage,
                    estimatedTime: Duration(minutes: 1));
              }),

          SizedBox(height: 10.h), // Space for cancel button
        ]));
  }

  Widget _buildCompletionView() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Success icon
      Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
              color: AppTheme.successColor, shape: BoxShape.circle),
          child: Center(
              child: CustomIconWidget(
                  iconName: 'check', color: AppTheme.primaryDark, size: 10.w))),

      SizedBox(height: 4.h),

      Text('Stem Separation Complete!',
          style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold, color: AppTheme.successColor),
          textAlign: TextAlign.center),

      SizedBox(height: 2.h),

      Text(
          'Your audio has been successfully separated into 5 individual stem tracks.',
          style: AppTheme.darkTheme.textTheme.bodyLarge
              ?.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center),

      SizedBox(height: 4.h),

      // Stem summary
      Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor, width: 1)),
          child: Column(children: [
            Text('Generated Stems',
                style: AppTheme.darkTheme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 2.h),
            ...['Vocals', 'Drums', 'Bass', 'Piano', 'Other Instruments']
                .map((stemName) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                    child: Row(children: [
                      CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.successColor,
                          size: 4.w),
                      SizedBox(width: 3.w),
                      Text(stemName,
                          style: AppTheme.darkTheme.textTheme.bodyMedium),
                    ]))),
          ])),

      SizedBox(height: 4.h),

      // Continue button
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _navigateToTrackEditor,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: AppTheme.primaryDark,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text('Continue to Track Editor',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w600))))),
    ]));
  }
}