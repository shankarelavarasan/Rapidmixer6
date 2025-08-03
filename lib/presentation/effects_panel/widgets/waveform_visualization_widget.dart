import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WaveformVisualizationWidget extends StatefulWidget {
  final bool isProcessing;
  final Map<String, bool> activeEffects;

  const WaveformVisualizationWidget({
    super.key,
    required this.isProcessing,
    required this.activeEffects,
  });

  @override
  State<WaveformVisualizationWidget> createState() =>
      _WaveformVisualizationWidgetState();
}

class _WaveformVisualizationWidgetState
    extends State<WaveformVisualizationWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isProcessing) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProcessing != oldWidget.isProcessing) {
      if (widget.isProcessing) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 12.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Stack(
        children: [
          _buildWaveform(),
          if (widget.isProcessing) _buildProcessingOverlay(),
          _buildEffectIndicators(),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 12.h),
          painter: WaveformPainter(
            animationValue: _animation.value,
            isProcessing: widget.isProcessing,
            activeEffects: widget.activeEffects,
          ),
        );
      },
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.1),
            AppTheme.accentColor.withValues(alpha: 0.3),
            AppTheme.accentColor.withValues(alpha: 0.1),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 4.w,
              height: 4.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'Processing Audio...',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectIndicators() {
    final activeEffectsList = widget.activeEffects.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (activeEffectsList.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 1.h,
      right: 2.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'graphic_eq',
              color: AppTheme.accentColor,
              size: 12,
            ),
            SizedBox(width: 1.w),
            Text(
              '${activeEffectsList.length} FX',
              style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.accentColor,
                fontSize: 8.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animationValue;
  final bool isProcessing;
  final Map<String, bool> activeEffects;

  WaveformPainter({
    required this.animationValue,
    required this.isProcessing,
    required this.activeEffects,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final waveformData = _generateWaveformData(size.width.toInt());

    // Draw original waveform
    paint.color = AppTheme.textSecondary.withValues(alpha: 0.3);
    _drawWaveform(canvas, size, waveformData, paint, centerY, 0.5);

    // Draw processed waveform with effects
    if (activeEffects.values.any((active) => active)) {
      paint.color = isProcessing
          ? AppTheme.accentColor.withValues(alpha: 0.6 + 0.4 * animationValue)
          : AppTheme.accentColor;

      final processedData = _applyEffectsToWaveform(waveformData);
      _drawWaveform(canvas, size, processedData, paint, centerY, 1.0);
    } else {
      paint.color = AppTheme.textPrimary.withValues(alpha: 0.8);
      _drawWaveform(canvas, size, waveformData, paint, centerY, 1.0);
    }

    // Draw frequency bands if EQ is active
    if (activeEffects['eq'] == true) {
      _drawFrequencyBands(canvas, size);
    }
  }

  List<double> _generateWaveformData(int points) {
    final data = <double>[];
    for (int i = 0; i < points; i++) {
      final x = i / points * 4 * 3.14159;
      var amplitude = 0.3 * (1 + 0.5 * (i / points).clamp(0.0, 1.0));

      // Add some variation
      amplitude *= (0.8 + 0.4 * (i % 7) / 7);
      amplitude *= (1 + 0.2 * (i % 13) / 13);

      final value = amplitude *
          (0.6 * math.sin(x * 0.5) +
              0.3 * math.sin(x * 1.5) +
              0.1 * math.sin(x * 3.0));

      data.add(value);
    }
    return data;
  }

  List<double> _applyEffectsToWaveform(List<double> originalData) {
    var processedData = List<double>.from(originalData);

    // Apply EQ effect
    if (activeEffects['eq'] == true) {
      for (int i = 0; i < processedData.length; i++) {
        processedData[i] *= 1.1; // Slight boost
      }
    }

    // Apply compression effect
    if (activeEffects['compression'] == true) {
      for (int i = 0; i < processedData.length; i++) {
        final value = processedData[i];
        if (value.abs() > 0.5) {
          processedData[i] = value * 0.7; // Compress peaks
        }
      }
    }

    // Apply reverb effect (add some decay)
    if (activeEffects['reverb'] == true) {
      for (int i = 1; i < processedData.length; i++) {
        processedData[i] += processedData[i - 1] * 0.1;
      }
    }

    // Apply delay effect (add echoes)
    if (activeEffects['delay'] == true) {
      final delayPoints = (processedData.length * 0.1).toInt();
      for (int i = delayPoints; i < processedData.length; i++) {
        processedData[i] += processedData[i - delayPoints] * 0.3;
      }
    }

    return processedData;
  }

  void _drawWaveform(Canvas canvas, Size size, List<double> data, Paint paint,
      double centerY, double opacity) {
    if (data.isEmpty) return;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = centerY + data[i] * centerY * 0.8;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    paint.color = paint.color.withValues(alpha: paint.color.alpha * opacity);
    canvas.drawPath(path, paint);
  }

  void _drawFrequencyBands(Canvas canvas, Size size) {
    final bandPaint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final bandWidth = size.width / 5;
    for (int i = 0; i < 5; i++) {
      final rect = Rect.fromLTWH(
        i * bandWidth,
        0,
        bandWidth - 1,
        size.height,
      );
      canvas.drawRect(rect, bandPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
