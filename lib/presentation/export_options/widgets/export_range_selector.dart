import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportRangeSelector extends StatelessWidget {
  final String selectedRange;
  final Function(String) onRangeChanged;
  final double startTime;
  final double endTime;
  final double totalDuration;
  final Function(double, double) onCustomRangeChanged;

  const ExportRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    required this.onCustomRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Range',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildRangeOptions(),
          if (selectedRange == 'Custom Range') ...[
            SizedBox(height: 3.h),
            _buildCustomRangeControls(),
          ],
        ],
      ),
    );
  }

  Widget _buildRangeOptions() {
    final ranges = [
      {
        'value': 'Full Mix',
        'icon': 'queue_music',
        'description': 'Complete track'
      },
      {
        'value': 'Loop Region',
        'icon': 'repeat',
        'description': 'Selected loop'
      },
      {
        'value': 'Custom Range',
        'icon': 'tune',
        'description': 'Custom selection'
      },
    ];

    return Column(
      children: ranges.map((range) {
        final isSelected = selectedRange == range['value'];
        return GestureDetector(
          onTap: () => onRangeChanged(range['value'] as String),
          child: Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentColor
                        : AppTheme.secondaryDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomIconWidget(
                    iconName: range['icon'] as String,
                    color: isSelected
                        ? AppTheme.primaryDark
                        : AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        range['value'] as String,
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? AppTheme.accentColor
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        range['description'] as String,
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomRangeControls() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline Selection',
            style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          _buildTimelineSlider(),
          SizedBox(height: 2.h),
          _buildTimeDisplay(),
        ],
      ),
    );
  }

  Widget _buildTimelineSlider() {
    return Container(
      height: 6.h,
      child: Stack(
        children: [
          // Background track
          Positioned(
            top: 2.5.h,
            left: 0,
            right: 0,
            child: Container(
              height: 1.h,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Selected range
          Positioned(
            top: 2.5.h,
            left: (startTime / totalDuration) * 100.w - 8.w,
            width: ((endTime - startTime) / totalDuration) * (100.w - 16.w),
            child: Container(
              height: 1.h,
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Start handle
          Positioned(
            top: 1.h,
            left: (startTime / totalDuration) * (100.w - 16.w),
            child: GestureDetector(
              onPanUpdate: (details) {
                final newStart =
                    (details.localPosition.dx / (100.w - 16.w)) * totalDuration;
                if (newStart >= 0 && newStart < endTime) {
                  onCustomRangeChanged(newStart, endTime);
                }
              },
              child: Container(
                width: 4.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: AppTheme.primaryDark,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'drag_indicator',
                    color: AppTheme.primaryDark,
                    size: 12,
                  ),
                ),
              ),
            ),
          ),
          // End handle
          Positioned(
            top: 1.h,
            left: (endTime / totalDuration) * (100.w - 16.w),
            child: GestureDetector(
              onPanUpdate: (details) {
                final newEnd =
                    (details.localPosition.dx / (100.w - 16.w)) * totalDuration;
                if (newEnd <= totalDuration && newEnd > startTime) {
                  onCustomRangeChanged(startTime, newEnd);
                }
              },
              child: Container(
                width: 4.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: AppTheme.primaryDark,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'drag_indicator',
                    color: AppTheme.primaryDark,
                    size: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    String formatTime(double seconds) {
      final minutes = (seconds / 60).floor();
      final secs = (seconds % 60).floor();
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              formatTime(startTime),
              style: AppTheme.timecodeTextStyle(isLight: false),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              'Duration',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              formatTime(endTime - startTime),
              style: AppTheme.timecodeTextStyle(isLight: false),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'End',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              formatTime(endTime),
              style: AppTheme.timecodeTextStyle(isLight: false),
            ),
          ],
        ),
      ],
    );
  }
}
