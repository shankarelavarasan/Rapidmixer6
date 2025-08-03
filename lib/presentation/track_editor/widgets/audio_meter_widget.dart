import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AudioMeterWidget extends StatefulWidget {
  final double level;
  final Color trackColor;
  final bool isVertical;

  const AudioMeterWidget({
    super.key,
    required this.level,
    required this.trackColor,
    this.isVertical = true,
  });

  @override
  State<AudioMeterWidget> createState() => _AudioMeterWidgetState();
}

class _AudioMeterWidgetState extends State<AudioMeterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.level,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AudioMeterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.level,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.isVertical ? 1.w : 20.w,
          height: widget.isVertical ? 10.h : 1.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryDark,
            borderRadius: BorderRadius.circular(2.0),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 0.5,
            ),
          ),
          child: CustomPaint(
            painter: AudioMeterPainter(
              level: _animation.value,
              trackColor: widget.trackColor,
              isVertical: widget.isVertical,
            ),
          ),
        );
      },
    );
  }
}

class AudioMeterPainter extends CustomPainter {
  final double level;
  final Color trackColor;
  final bool isVertical;

  AudioMeterPainter({
    required this.level,
    required this.trackColor,
    required this.isVertical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (isVertical) {
      // Vertical meter (bottom to top)
      final meterHeight = size.height * level;
      final segments = 20;
      final segmentHeight = size.height / segments;

      for (int i = 0; i < segments; i++) {
        final segmentY = size.height - (i + 1) * segmentHeight;
        final segmentLevel = (i + 1) / segments;

        if (segmentLevel <= level) {
          // Color coding: green (0-0.7), yellow (0.7-0.9), red (0.9-1.0)
          if (segmentLevel <= 0.7) {
            paint.color = AppTheme.successColor;
          } else if (segmentLevel <= 0.9) {
            paint.color = AppTheme.warningColor;
          } else {
            paint.color = AppTheme.errorColor;
          }

          final rect = Rect.fromLTWH(
            1.0,
            segmentY + 1.0,
            size.width - 2.0,
            segmentHeight - 2.0,
          );
          canvas.drawRect(rect, paint);
        }
      }
    } else {
      // Horizontal meter (left to right)
      final meterWidth = size.width * level;
      final segments = 20;
      final segmentWidth = size.width / segments;

      for (int i = 0; i < segments; i++) {
        final segmentX = i * segmentWidth;
        final segmentLevel = (i + 1) / segments;

        if (segmentLevel <= level) {
          // Color coding: green (0-0.7), yellow (0.7-0.9), red (0.9-1.0)
          if (segmentLevel <= 0.7) {
            paint.color = AppTheme.successColor;
          } else if (segmentLevel <= 0.9) {
            paint.color = AppTheme.warningColor;
          } else {
            paint.color = AppTheme.errorColor;
          }

          final rect = Rect.fromLTWH(
            segmentX + 1.0,
            1.0,
            segmentWidth - 2.0,
            size.height - 2.0,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
