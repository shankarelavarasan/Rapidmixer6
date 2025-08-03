import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MetadataEditor extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController artistController;
  final TextEditingController albumController;
  final String projectName;

  const MetadataEditor({
    super.key,
    required this.titleController,
    required this.artistController,
    required this.albumController,
    required this.projectName,
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
          Row(
            children: [
              Text(
                'Track Metadata',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () => _autoFillFromProject(),
                child: Text(
                  'Auto-fill',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildMetadataField(
            label: 'Title',
            controller: titleController,
            icon: 'title',
            hint: 'Enter track title',
          ),
          SizedBox(height: 2.h),
          _buildMetadataField(
            label: 'Artist',
            controller: artistController,
            icon: 'person',
            hint: 'Enter artist name',
          ),
          SizedBox(height: 2.h),
          _buildMetadataField(
            label: 'Album',
            controller: albumController,
            icon: 'album',
            hint: 'Enter album name',
          ),
          SizedBox(height: 2.h),
          _buildProjectInfo(),
        ],
      ),
    );
  }

  Widget _buildMetadataField({
    required String label,
    required TextEditingController controller,
    required String icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppTheme.primaryDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.accentColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectInfo() {
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
            iconName: 'folder',
            color: AppTheme.textSecondary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Project: ',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              projectName,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _autoFillFromProject() {
    if (titleController.text.isEmpty) {
      titleController.text = projectName;
    }
    if (artistController.text.isEmpty) {
      artistController.text = 'Rapid Mixer User';
    }
    if (albumController.text.isEmpty) {
      albumController.text = 'Mobile Remixes';
    }
  }
}
