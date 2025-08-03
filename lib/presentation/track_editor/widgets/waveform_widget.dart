import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WaveformWidget extends StatefulWidget {
  final Color trackColor;
  final bool isMuted;
  final double playheadPosition;
  final double zoomLevel;
  final double scrollPosition;
  final List<double> waveformData;

  const WaveformWidget({
    super.key,
    required this.trackColor,
    required this.isMuted,
    required this.playheadPosition,
    required this.zoomLevel,
    required this.scrollPosition,
    required this.waveformData,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75.w,
      height: 12.h,
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Waveform visualization
          CustomPaint(
            size: Size(75.w, 12.h),
            painter: WaveformPainter(
              waveformData: widget.waveformData,
              trackColor: widget.isMuted
                  ? widget.trackColor.withValues(alpha: 0.3)
                  : widget.trackColor,
              zoomLevel: widget.zoomLevel,
              scrollPosition: widget.scrollPosition,
            ),
          ),
          // Playhead indicator
          Positioned(
            left: widget.playheadPosition * 75.w,
            child: Container(
              width: 2.0,
              height: 12.h,
              color: AppTheme.accentColor,
            ),
          ),
          // Grid lines
          CustomPaint(
            size: Size(75.w, 12.h),
            painter: GridPainter(),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color trackColor;
  final double zoomLevel;
  final double scrollPosition;

  WaveformPainter({
    required this.waveformData,
    required this.trackColor,
    required this.zoomLevel,
    required this.scrollPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = trackColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    final barWidth = (size.width / waveformData.length) * zoomLevel;

    for (int i = 0; i < waveformData.length; i++) {
      final x = (i * barWidth) - (scrollPosition * size.width);
      if (x >= -barWidth && x <= size.width) {
        final amplitude = waveformData[i] * centerY * 0.8;
        final rect = Rect.fromLTWH(
          x,
          centerY - amplitude,
          barWidth.clamp(1.0, 3.0),
          amplitude * 2,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Vertical grid lines (time markers)
    for (int i = 0; i <= 8; i++) {
      final x = (size.width / 8) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
