import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TimelineWidget extends StatefulWidget {
  final double playheadPosition;
  final double zoomLevel;
  final double scrollPosition;
  final double totalDuration;
  final ValueChanged<double> onPlayheadChanged;
  final ValueChanged<double> onZoomChanged;
  final ValueChanged<double> onScrollChanged;

  const TimelineWidget({
    super.key,
    required this.playheadPosition,
    required this.zoomLevel,
    required this.scrollPosition,
    required this.totalDuration,
    required this.onPlayheadChanged,
    required this.onZoomChanged,
    required this.onScrollChanged,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 8.h,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 2.0,
          ),
        ),
      ),
      child: Column(
        children: [
          // Time ruler
          Container(
            height: 4.h,
            child: CustomPaint(
              size: Size(double.infinity, 4.h),
              painter: TimeRulerPainter(
                zoomLevel: widget.zoomLevel,
                scrollPosition: widget.scrollPosition,
                totalDuration: widget.totalDuration,
              ),
            ),
          ),
          // Playhead control area
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                final newPosition =
                    (details.localPosition.dx / 100.w).clamp(0.0, 1.0);
                widget.onPlayheadChanged(newPosition);
              },
              child: Container(
                width: double.infinity,
                color: AppTheme.primaryDark,
                child: Stack(
                  children: [
                    // Playhead line
                    Positioned(
                      left: widget.playheadPosition * 100.w,
                      child: Container(
                        width: 2.0,
                        height: 4.h,
                        color: AppTheme.accentColor,
                        child: Column(
                          children: [
                            Container(
                              width: 12.0,
                              height: 12.0,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 2.0,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeRulerPainter extends CustomPainter {
  final double zoomLevel;
  final double scrollPosition;
  final double totalDuration;

  TimeRulerPainter({
    required this.zoomLevel,
    required this.scrollPosition,
    required this.totalDuration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw time markers
    final markerInterval = 10.0 / zoomLevel; // Seconds between markers
    final pixelsPerSecond = size.width / (totalDuration * zoomLevel);

    for (double time = 0; time <= totalDuration; time += markerInterval) {
      final x = (time * pixelsPerSecond) - (scrollPosition * size.width);

      if (x >= 0 && x <= size.width) {
        // Draw marker line
        canvas.drawLine(
          Offset(x, size.height * 0.6),
          Offset(x, size.height),
          paint,
        );

        // Draw time label
        final minutes = (time / 60).floor();
        final seconds = (time % 60).floor();
        final timeText =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        textPainter.text = TextSpan(
          text: timeText,
          style: AppTheme.technicalTextStyle(isLight: false),
        );
        textPainter.layout();

        if (x + textPainter.width <= size.width) {
          textPainter.paint(canvas, Offset(x + 2, 4));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
