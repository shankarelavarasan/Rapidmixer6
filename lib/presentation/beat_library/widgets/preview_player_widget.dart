import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PreviewPlayerWidget extends StatefulWidget {
  final Map<String, dynamic>? currentBeat;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final bool tempoMatchEnabled;
  final VoidCallback onTempoMatchToggle;
  final double currentPosition;
  final double totalDuration;
  final Function(double) onSeek;

  const PreviewPlayerWidget({
    super.key,
    this.currentBeat,
    required this.isPlaying,
    required this.onPlayPause,
    required this.tempoMatchEnabled,
    required this.onTempoMatchToggle,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
  });

  @override
  State<PreviewPlayerWidget> createState() => _PreviewPlayerWidgetState();
}

class _PreviewPlayerWidgetState extends State<PreviewPlayerWidget> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentBeat == null) {
      return const SizedBox.shrink();
    }

    final beat = widget.currentBeat!;
    final progress = widget.totalDuration > 0
        ? (_isDragging ? _dragValue : widget.currentPosition) /
            widget.totalDuration
        : 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Beat info and controls
            Row(
              children: [
                // Beat artwork placeholder
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'music_note',
                      color: AppTheme.accentColor,
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                // Beat details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beat['name'] ?? 'Unknown Beat',
                        style: AppTheme.darkTheme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Text(
                            '${beat['bpm'] ?? 120} BPM',
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(color: AppTheme.accentColor),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              beat['genre'] ?? 'Unknown',
                              style: AppTheme.darkTheme.textTheme.labelSmall
                                  ?.copyWith(color: AppTheme.accentColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tempo match toggle
                GestureDetector(
                  onTap: widget.onTempoMatchToggle,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: widget.tempoMatchEnabled
                          ? AppTheme.accentColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.tempoMatchEnabled
                            ? AppTheme.accentColor
                            : AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'sync',
                          color: widget.tempoMatchEnabled
                              ? AppTheme.accentColor
                              : AppTheme.textSecondary,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'SYNC',
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: widget.tempoMatchEnabled
                                ? AppTheme.accentColor
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                // Play/pause button
                GestureDetector(
                  onTap: widget.onPlayPause,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: widget.isPlaying ? 'pause' : 'play_arrow',
                        color: AppTheme.primaryDark,
                        size: 6.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Progress bar and time
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      _formatDuration(
                          _isDragging ? _dragValue : widget.currentPosition),
                      style: AppTheme.darkTheme.textTheme.bodySmall,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppTheme.accentColor,
                          inactiveTrackColor: AppTheme.borderColor,
                          thumbColor: AppTheme.accentColor,
                          overlayColor:
                              AppTheme.accentColor.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            setState(() {
                              _isDragging = true;
                              _dragValue = value * widget.totalDuration;
                            });
                          },
                          onChangeEnd: (value) {
                            setState(() {
                              _isDragging = false;
                            });
                            widget.onSeek(value * widget.totalDuration);
                          },
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(widget.totalDuration),
                      style: AppTheme.darkTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
