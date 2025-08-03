import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TrackHeaderWidget extends StatefulWidget {
  final String trackName;
  final String iconName;
  final Color trackColor;
  final bool isMuted;
  final bool isSolo;
  final double volume;
  final VoidCallback onMuteToggle;
  final VoidCallback onSoloToggle;
  final ValueChanged<double> onVolumeChanged;

  const TrackHeaderWidget({
    super.key,
    required this.trackName,
    required this.iconName,
    required this.trackColor,
    required this.isMuted,
    required this.isSolo,
    required this.volume,
    required this.onMuteToggle,
    required this.onSoloToggle,
    required this.onVolumeChanged,
  });

  @override
  State<TrackHeaderWidget> createState() => _TrackHeaderWidgetState();
}

class _TrackHeaderWidgetState extends State<TrackHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      height: 12.h,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.secondaryContainer,
        border: Border(
          right: BorderSide(
            color: AppTheme.borderColor,
            width: 1.0,
          ),
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: widget.iconName,
                  color: widget.trackColor,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    widget.trackName,
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onMuteToggle,
                  child: Container(
                    width: 6.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: widget.isMuted
                          ? AppTheme.errorColor
                          : AppTheme.darkTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: widget.isMuted
                            ? AppTheme.errorColor
                            : AppTheme.borderColor,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'M',
                        style:
                            AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                          color: widget.isMuted
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 1.w),
                GestureDetector(
                  onTap: widget.onSoloToggle,
                  child: Container(
                    width: 6.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: widget.isSolo
                          ? AppTheme.warningColor
                          : AppTheme.darkTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: widget.isSolo
                            ? AppTheme.warningColor
                            : AppTheme.borderColor,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'S',
                        style:
                            AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                          color: widget.isSolo
                              ? AppTheme.primaryDark
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'volume_up',
                  color: AppTheme.textSecondary,
                  size: 3.w,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.0,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12.0),
                    ),
                    child: Slider(
                      value: widget.volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: widget.onVolumeChanged,
                      activeColor: widget.trackColor,
                      inactiveColor: AppTheme.borderColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
