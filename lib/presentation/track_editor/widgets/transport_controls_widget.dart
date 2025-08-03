import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransportControlsWidget extends StatefulWidget {
  final bool isPlaying;
  final bool isRecording;
  final double currentTime;
  final double totalDuration;
  final double tempo;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onRecord;
  final ValueChanged<double> onTempoChanged;

  const TransportControlsWidget({
    super.key,
    required this.isPlaying,
    required this.isRecording,
    required this.currentTime,
    required this.totalDuration,
    required this.tempo,
    required this.onPlayPause,
    required this.onStop,
    required this.onRecord,
    required this.onTempoChanged,
  });

  @override
  State<TransportControlsWidget> createState() =>
      _TransportControlsWidgetState();
}

class _TransportControlsWidgetState extends State<TransportControlsWidget> {
  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    final milliseconds = ((seconds % 1) * 100).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 12.h,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 2.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            // Transport buttons
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Stop button
                  GestureDetector(
                    onTap: widget.onStop,
                    child: Container(
                      width: 12.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color:
                            AppTheme.darkTheme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'stop',
                          color: AppTheme.textPrimary,
                          size: 6.w,
                        ),
                      ),
                    ),
                  ),
                  // Play/Pause button
                  GestureDetector(
                    onTap: widget.onPlayPause,
                    child: Container(
                      width: 15.w,
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: widget.isPlaying
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowDark,
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: widget.isPlaying ? 'pause' : 'play_arrow',
                          color: AppTheme.primaryDark,
                          size: 8.w,
                        ),
                      ),
                    ),
                  ),
                  // Record button
                  GestureDetector(
                    onTap: widget.onRecord,
                    child: Container(
                      width: 12.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: widget.isRecording
                            ? AppTheme.errorColor
                            : AppTheme.darkTheme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: widget.isRecording
                              ? AppTheme.errorColor
                              : AppTheme.borderColor,
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'fiber_manual_record',
                          color: widget.isRecording
                              ? AppTheme.textPrimary
                              : AppTheme.errorColor,
                          size: 6.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Time display
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(widget.currentTime),
                    style: AppTheme.timecodeTextStyle(isLight: false).copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _formatTime(widget.totalDuration),
                    style: AppTheme.timecodeTextStyle(isLight: false).copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Tempo control
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BPM',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    widget.tempo.toInt().toString(),
                    style: AppTheme.technicalTextStyle(isLight: false).copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  SizedBox(
                    width: 15.w,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.0,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 4.0),
                      ),
                      child: Slider(
                        value: widget.tempo,
                        min: 60.0,
                        max: 180.0,
                        onChanged: widget.onTempoChanged,
                        activeColor: AppTheme.accentColor,
                        inactiveColor: AppTheme.borderColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
