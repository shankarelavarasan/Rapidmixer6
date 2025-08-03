import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BeatCardWidget extends StatefulWidget {
  final Map<String, dynamic> beatData;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onLongPress;
  final bool isSelected;

  const BeatCardWidget({
    super.key,
    required this.beatData,
    required this.isPlaying,
    required this.onPlay,
    required this.onLongPress,
    this.isSelected = false,
  });

  @override
  State<BeatCardWidget> createState() => _BeatCardWidgetState();
}

class _BeatCardWidgetState extends State<BeatCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isInProject = widget.beatData['isInProject'] ?? false;
    final bool isFavorite = widget.beatData['isFavorite'] ?? false;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPlay,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppTheme.accentColor.withValues(alpha: 0.1)
                    : AppTheme.darkTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSelected
                    ? Border.all(color: AppTheme.accentColor, width: 2)
                    : Border.all(color: AppTheme.borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowDark,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with play button and favorite
                  Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Play button
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: widget.isPlaying
                                ? AppTheme.accentColor
                                : AppTheme.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName:
                                  widget.isPlaying ? 'pause' : 'play_arrow',
                              color: widget.isPlaying
                                  ? AppTheme.primaryDark
                                  : AppTheme.accentColor,
                              size: 5.w,
                            ),
                          ),
                        ),
                        // Favorite and project indicators
                        Row(
                          children: [
                            if (isFavorite)
                              Padding(
                                padding: EdgeInsets.only(right: 2.w),
                                child: CustomIconWidget(
                                  iconName: 'favorite',
                                  color: AppTheme.errorColor,
                                  size: 4.w,
                                ),
                              ),
                            if (isInProject)
                              CustomIconWidget(
                                iconName: 'check_circle',
                                color: AppTheme.successColor,
                                size: 4.w,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Waveform preview
                  Container(
                    height: 8.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomPaint(
                      painter: WaveformPainter(
                        waveformData: (widget.beatData['waveform'] as List?)
                                ?.cast<double>() ??
                            _generateMockWaveform(),
                        isPlaying: widget.isPlaying,
                        accentColor: AppTheme.accentColor,
                      ),
                      size: Size(double.infinity, 8.h),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Beat info
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.beatData['name'] ?? 'Unknown Beat',
                          style: AppTheme.darkTheme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.beatData['bpm'] ?? 120} BPM',
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.accentColor),
                            ),
                            Text(
                              widget.beatData['duration'] ?? '0:30',
                              style: AppTheme.darkTheme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.beatData['genre'] ?? 'Unknown',
                            style: AppTheme.darkTheme.textTheme.labelSmall
                                ?.copyWith(color: AppTheme.accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<double> _generateMockWaveform() {
    return List.generate(50, (index) {
      return (index % 3 == 0 ? 0.8 : (index % 2 == 0 ? 0.6 : 0.4)) *
          (1 + (index % 7) * 0.1);
    });
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final bool isPlaying;
  final Color accentColor;

  WaveformPainter({
    required this.waveformData,
    required this.isPlaying,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final barHeight = waveformData[i] * size.height * 0.8;
      final startY = centerY - barHeight / 2;
      final endY = centerY + barHeight / 2;

      // Use active paint for first 30% if playing
      final useActivePaint = isPlaying && i < waveformData.length * 0.3;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        useActivePaint ? activePaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
