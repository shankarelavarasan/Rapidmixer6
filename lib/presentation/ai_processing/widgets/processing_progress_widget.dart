import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../core/utils/math_utils.dart';

class ProcessingProgressWidget extends StatefulWidget {
  final double progress;
  final String currentStage;
  final String estimatedTime;

  const ProcessingProgressWidget({
    super.key,
    required this.progress,
    required this.currentStage,
    required this.estimatedTime,
  });

  @override
  State<ProcessingProgressWidget> createState() =>
      _ProcessingProgressWidgetState();
}

class _ProcessingProgressWidgetState extends State<ProcessingProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _progressController;
  late Animation<double> _waveAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    // Validate and normalize progress value
    final normalizedProgress = _validateProgress(widget.progress);
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: normalizedProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(ProcessingProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      // Validate and normalize both old and new progress values
      final oldNormalizedProgress = _validateProgress(oldWidget.progress);
      final newNormalizedProgress = _validateProgress(widget.progress);
      
      _progressAnimation = Tween<double>(
        begin: oldNormalizedProgress,
        end: newNormalizedProgress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// Validates and normalizes progress value to prevent NaN errors
  double _validateProgress(double progress) {
    return MathUtils.safeProgressCalculation(progress);
  }

  /// Gets the circular progress value (0.0 to 1.0) from percentage
  double _getCircularProgressValue(double progressPercentage) {
    return MathUtils.safeDivision(progressPercentage, 100.0, 0.0).clamp(0.0, 1.0);
  }

  /// Gets the display percentage as integer
  int _getDisplayPercentage(double progressPercentage) {
    return MathUtils.validateAndClamp(progressPercentage, 0.0, 100.0).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.darkTheme.colorScheme.surface,
        border: Border.all(
          color: AppTheme.borderColor,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated waveform background
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(50.w, 50.w),
                painter: WaveformPainter(
                  animation: _waveAnimation.value,
                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                ),
              );
            },
          ),

          // Progress circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 55.w,
                height: 55.w,
                child: CircularProgressIndicator(
                  value: _getCircularProgressValue(_progressAnimation.value),
                  strokeWidth: 4.0,
                  backgroundColor: AppTheme.borderColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                ),
              );
            },
          ),

          // Progress percentage text
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${_getDisplayPercentage(_progressAnimation.value)}%',
                style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animation;
  final Color color;

  WaveformPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;
    final waveCount = 8;

    for (int i = 0; i < waveCount; i++) {
      final x = (size.width / waveCount) * i;
      final amplitude = (i % 2 == 0 ? 20 : 15) * MathUtils.validateAndClamp((0.5 + 0.5 * animation), 0.0, 1.0);
      final y = centerY + amplitude * (i % 2 == 0 ? 1 : -1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
