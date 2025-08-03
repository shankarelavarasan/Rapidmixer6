import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportProgressDialog extends StatelessWidget {
  final double progress;
  final String status;
  final String estimatedTime;
  final bool isCompleted;
  final bool hasError;
  final String errorMessage;
  final VoidCallback onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onShare;

  const ExportProgressDialog({
    super.key,
    required this.progress,
    required this.status,
    required this.estimatedTime,
    required this.isCompleted,
    required this.hasError,
    required this.errorMessage,
    required this.onCancel,
    this.onRetry,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 4.h),
            _buildContent(),
            SizedBox(height: 4.h),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: hasError
                ? AppTheme.errorColor.withValues(alpha: 0.2)
                : isCompleted
                    ? AppTheme.successColor.withValues(alpha: 0.2)
                    : AppTheme.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: hasError
                ? 'error'
                : isCompleted
                    ? 'check_circle'
                    : 'music_note',
            color: hasError
                ? AppTheme.errorColor
                : isCompleted
                    ? AppTheme.successColor
                    : AppTheme.accentColor,
            size: 24,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasError
                    ? 'Export Failed'
                    : isCompleted
                        ? 'Export Complete'
                        : 'Exporting Mix',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!hasError && !isCompleted)
                Text(
                  'Processing audio tracks...',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (hasError) {
      return _buildErrorContent();
    } else if (isCompleted) {
      return _buildCompletedContent();
    } else {
      return _buildProgressContent();
    }
  }

  Widget _buildProgressContent() {
    return Column(
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: 1.h,
          decoration: BoxDecoration(
            color: AppTheme.borderColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        // Progress percentage
        Text(
          '${(progress * 100).toInt()}%',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        // Status and time
        Text(
          status,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'schedule',
              color: AppTheme.textSecondary,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              estimatedTime,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletedContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successColor,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                'Your mix has been exported successfully!',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Ready to share with the world',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: AppTheme.errorColor,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                errorMessage,
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Please try again or check your settings',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (hasError) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: Text('Cancel'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ),
        ],
      );
    } else if (isCompleted) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: Text('Close'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: ElevatedButton(
              onPressed: onShare,
              child: Text('Share'),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onCancel,
          child: Text('Cancel Export'),
        ),
      );
    }
  }
}
