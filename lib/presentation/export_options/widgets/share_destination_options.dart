import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ShareDestinationOptions extends StatelessWidget {
  final Function(String) onDestinationSelected;

  const ShareDestinationOptions({
    super.key,
    required this.onDestinationSelected,
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
            'Share Destination',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildDestinationGrid(),
        ],
      ),
    );
  }

  Widget _buildDestinationGrid() {
    final destinations = [
      {
        'title': 'Save to Device',
        'subtitle': 'Local storage',
        'icon': 'save',
        'action': 'save_device',
        'color': AppTheme.successColor,
      },
      {
        'title': 'Share via Apps',
        'subtitle': kIsWeb ? 'Download file' : 'System share',
        'icon': 'share',
        'action': 'share_apps',
        'color': AppTheme.accentColor,
      },
      {
        'title': 'Upload to Cloud',
        'subtitle': 'Cloud storage',
        'icon': 'cloud_upload',
        'action': 'upload_cloud',
        'color': AppTheme.warningColor,
      },
      {
        'title': 'Export History',
        'subtitle': 'Recent exports',
        'icon': 'history',
        'action': 'export_history',
        'color': AppTheme.textSecondary,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1.2,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        return _buildDestinationCard(destination);
      },
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> destination) {
    return GestureDetector(
      onTap: () => onDestinationSelected(destination['action'] as String),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: (destination['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: destination['icon'] as String,
                color: destination['color'] as Color,
                size: 28,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              destination['title'] as String,
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              destination['subtitle'] as String,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
