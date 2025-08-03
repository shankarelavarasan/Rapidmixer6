import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportFormatSelector extends StatelessWidget {
  final String selectedFormat;
  final String selectedQuality;
  final Function(String) onFormatChanged;
  final Function(String) onQualityChanged;

  const ExportFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.selectedQuality,
    required this.onFormatChanged,
    required this.onQualityChanged,
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
            'Export Format',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildFormatOptions(),
          SizedBox(height: 3.h),
          _buildQualityOptions(),
          SizedBox(height: 2.h),
          _buildFileSizeEstimate(),
        ],
      ),
    );
  }

  Widget _buildFormatOptions() {
    final formats = ['MP3', 'WAV'];

    return Row(
      children: formats.map((format) {
        final isSelected = selectedFormat == format;
        return Expanded(
          child: GestureDetector(
            onTap: () => onFormatChanged(format),
            child: Container(
              margin: EdgeInsets.only(right: format == 'MP3' ? 2.w : 0),
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppTheme.accentColor : AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: format == 'MP3' ? 'music_note' : 'graphic_eq',
                    color: isSelected
                        ? AppTheme.primaryDark
                        : AppTheme.textPrimary,
                    size: 24,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    format,
                    style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryDark
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    format == 'MP3' ? 'Compressed' : 'Lossless',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryDark.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQualityOptions() {
    final mp3Qualities = ['128 kbps', '192 kbps', '320 kbps'];
    final wavQualities = ['16-bit', '24-bit'];
    final qualities = selectedFormat == 'MP3' ? mp3Qualities : wavQualities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality',
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.5.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: qualities.map((quality) {
            final isSelected = selectedQuality == quality;
            return GestureDetector(
              onTap: () => onQualityChanged(quality),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentColor.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentColor
                        : AppTheme.borderColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  quality,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.accentColor
                        : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileSizeEstimate() {
    String getFileSize() {
      if (selectedFormat == 'MP3') {
        switch (selectedQuality) {
          case '128 kbps':
            return '~3.2 MB';
          case '192 kbps':
            return '~4.8 MB';
          case '320 kbps':
            return '~8.0 MB';
          default:
            return '~4.8 MB';
        }
      } else {
        switch (selectedQuality) {
          case '16-bit':
            return '~35 MB';
          case '24-bit':
            return '~52 MB';
          default:
            return '~35 MB';
        }
      }
    }

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
          CustomIconWidget(
            iconName: 'storage',
            color: AppTheme.textSecondary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Estimated file size: ${getFileSize()}',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
