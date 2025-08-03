import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentFileItem extends StatelessWidget {
  final Map<String, dynamic> fileData;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  const RecentFileItem({
    super.key,
    required this.fileData,
    required this.onTap,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.w,
      margin: EdgeInsets.only(right: 3.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File thumbnail/waveform preview
          Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.secondaryContainer,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Stack(
              children: [
                // Waveform visualization placeholder
                Center(
                  child: CustomIconWidget(
                    iconName: 'graphic_eq',
                    color: AppTheme.accentColor.withValues(alpha: 0.6),
                    size: 6.w,
                  ),
                ),
                // Play preview button
                Positioned(
                  top: 1.h,
                  right: 2.w,
                  child: GestureDetector(
                    onTap: onPreview,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'play_arrow',
                        color: AppTheme.primaryDark,
                        size: 4.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // File information
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (fileData["name"] as String?) ?? "Unknown File",
                    style: AppTheme.darkTheme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "${(fileData["duration"] as String?) ?? "0:00"} • ${(fileData["size"] as String?) ?? "0 MB"}",
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Select button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: AppTheme.primaryDark,
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        "Select",
                        style:
                            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
