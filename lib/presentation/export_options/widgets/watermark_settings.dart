import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WatermarkSettings extends StatelessWidget {
  final bool isWatermarkEnabled;
  final Function(bool) onWatermarkToggled;

  const WatermarkSettings({
    super.key,
    required this.isWatermarkEnabled,
    required this.onWatermarkToggled,
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
            'Content Protection',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildWatermarkToggle(),
          if (isWatermarkEnabled) ...[
            SizedBox(height: 2.h),
            _buildWatermarkInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildWatermarkToggle() {
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isWatermarkEnabled
                  ? AppTheme.accentColor.withValues(alpha: 0.2)
                  : AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: 'security',
              color: isWatermarkEnabled
                  ? AppTheme.accentColor
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
                  'Audio Watermark',
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Add subtle signature for content protection',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isWatermarkEnabled,
            onChanged: onWatermarkToggled,
            activeColor: AppTheme.accentColor,
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWatermarkInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.accentColor,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Watermark Details',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          _buildInfoRow('Type', 'Inaudible digital signature'),
          _buildInfoRow('Location', 'Embedded throughout track'),
          _buildInfoRow('Impact', 'No quality loss'),
          _buildInfoRow('Purpose', 'Content identification & protection'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20.w,
            child: Text(
              '$label:',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
