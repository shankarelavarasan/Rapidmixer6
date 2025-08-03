import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ImportOptionCard extends StatelessWidget {
  final String title;
  final String iconName;
  final VoidCallback onTap;
  final bool isEnabled;

  const ImportOptionCard({
    super.key,
    required this.title,
    required this.iconName,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 15.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppTheme.darkTheme.colorScheme.secondaryContainer
              : AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isEnabled ? AppTheme.accentColor : AppTheme.textSecondary,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color:
                    isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
