import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CancelButtonWidget extends StatelessWidget {
  final VoidCallback onCancel;

  const CancelButtonWidget({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6.h,
      right: 4.w,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => _showCancelDialog(context),
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color:
                  AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Cancel Processing?',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel the AI processing? This will stop the current operation and you\'ll need to start over.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue',
                style: TextStyle(color: AppTheme.accentColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: AppTheme.textPrimary,
              ),
              child: const Text('Cancel Processing'),
            ),
          ],
        );
      },
    );
  }
}
