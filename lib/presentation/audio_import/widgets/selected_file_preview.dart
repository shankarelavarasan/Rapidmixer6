import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SelectedFilePreview extends StatelessWidget {
  final Map<String, dynamic> fileData;
  final VoidCallback onRemove;
  final VoidCallback onPlay;
  final bool isPlaying;

  const SelectedFilePreview({
    super.key,
    required this.fileData,
    required this.onRemove,
    required this.onPlay,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with file info and remove button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected File",
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      (fileData["name"] as String?) ?? "Unknown File",
                      style: AppTheme.darkTheme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.errorColor,
                    size: 5.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Waveform visualization
          Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Waveform bars
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(20, (index) {
                      final heights = [
                        0.3,
                        0.7,
                        0.5,
                        0.9,
                        0.4,
                        0.8,
                        0.6,
                        0.3,
                        0.7,
                        0.5,
                        0.9,
                        0.4,
                        0.8,
                        0.6,
                        0.3,
                        0.7,
                        0.5,
                        0.9,
                        0.4,
                        0.8
                      ];
                      return Container(
                        width: 0.8.w,
                        height: 6.h * heights[index],
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }),
                  ),
                ),
                // Play button overlay
                Center(
                  child: GestureDetector(
                    onTap: onPlay,
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowDark,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomIconWidget(
                        iconName: isPlaying ? 'pause' : 'play_arrow',
                        color: AppTheme.primaryDark,
                        size: 6.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // File details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  "Duration",
                  (fileData["duration"] as String?) ?? "0:00",
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  "Size",
                  (fileData["size"] as String?) ?? "0 MB",
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  "Format",
                  (fileData["format"] as String?) ?? "MP3",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
