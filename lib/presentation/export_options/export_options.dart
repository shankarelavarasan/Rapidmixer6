import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/export_service.dart';
import './widgets/export_format_selector.dart';
import './widgets/export_progress_dialog.dart';
import './widgets/export_range_selector.dart';
import './widgets/metadata_editor.dart';
import './widgets/share_destination_options.dart';
import './widgets/watermark_settings.dart';

class ExportOptions extends StatefulWidget {
  const ExportOptions({super.key});

  @override
  State<ExportOptions> createState() => _ExportOptionsState();
}

class _ExportOptionsState extends State<ExportOptions> {
  final ExportService _exportService = ExportService();

  // Export settings
  String _selectedFormat = 'mp3';
  String _selectedQuality = 'high';
  String _fileName = '';
  Map<String, String> _metadata = {};
  String _exportRange = 'full';
  double _startTime = 0.0;
  double _endTime = 180.0;
  bool _includeWatermark = false;
  String _shareDestination = 'local';

  // State tracking
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportStatus = '';

  // Add controllers for metadata
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeExportService();
    _generateDefaultFileName();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _exportService.dispose();
    super.dispose();
  }

  void _initializeExportService() {
    // Listen to export progress
    _exportService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _exportProgress = progress;
        });
      }
    });

    _exportService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _exportStatus = status;
        });
      }
    });

    _exportService.errorStream.listen((error) {
      if (mounted) {
        _showErrorSnackBar(error);
      }
    });
  }

  void _generateDefaultFileName() {
    final timestamp = DateTime.now();
    final dateStr =
        '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}';
    _fileName = 'RapidMixer_$dateStr\\_$timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        appBar: AppBar(
            backgroundColor: AppTheme.primaryDark,
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.textPrimary,
                    size: 6.w)),
            title: Text('Export Options',
                style: AppTheme.darkTheme.textTheme.titleLarge),
            actions: [
              IconButton(
                  onPressed: _showExportInfo,
                  icon: CustomIconWidget(
                      iconName: 'info_outline',
                      color: AppTheme.textSecondary,
                      size: 6.w)),
            ]),
        body: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Export Format Selection
                        ExportFormatSelector(
                            selectedFormat: _selectedFormat,
                            selectedQuality: _selectedQuality,
                            onFormatChanged: (format) {
                              setState(() {
                                _selectedFormat = format;
                              });
                            },
                            onQualityChanged: (quality) {
                              setState(() {
                                _selectedQuality = quality;
                              });
                            }),

                        SizedBox(height: 3.h),

                        // File Name Input
                        _buildFileNameSection(),

                        SizedBox(height: 3.h),

                        // Metadata Editor
                        MetadataEditor(
                            projectName: 'RapidMixer Project',
                            titleController: _titleController,
                            artistController: _artistController,
                            albumController: _albumController),

                        SizedBox(height: 3.h),

                        // Export Range Selector
                        ExportRangeSelector(
                            selectedRange: _exportRange,
                            startTime: _startTime,
                            endTime: _endTime,
                            totalDuration: 180.0,
                            onRangeChanged: (range) {
                              setState(() {
                                _exportRange = range;
                              });
                            },
                            onCustomRangeChanged: (start, end) {
                              setState(() {
                                _startTime = start;
                                _endTime = end;
                              });
                            }),

                        SizedBox(height: 3.h),

                        // Watermark Settings
                        WatermarkSettings(
                            isWatermarkEnabled: _includeWatermark,
                            onWatermarkToggled: (enabled) {
                              setState(() {
                                _includeWatermark = enabled;
                              });
                            }),

                        SizedBox(height: 3.h),

                        // Share Destination Options
                        ShareDestinationOptions(
                            onDestinationSelected: (destination) {
                              setState(() {
                                _shareDestination = destination;
                              });
                            }),

                        SizedBox(height: 4.h),
                      ]))),

          // Export Button
          _buildExportButton(),
        ]));
  }

  Widget _buildFileNameSection() {
    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('File Name',
              style: AppTheme.darkTheme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 2.h),
          TextFormField(
              initialValue: _fileName,
              onChanged: (value) {
                setState(() {
                  _fileName = value;
                });
              },
              style: AppTheme.darkTheme.textTheme.bodyMedium,
              decoration: InputDecoration(
                  hintText: 'Enter file name',
                  hintStyle: AppTheme.darkTheme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.darkTheme.colorScheme.secondaryContainer,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  suffixText: '.$_selectedFormat',
                  suffixStyle: AppTheme.darkTheme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.accentColor))),
        ]));
  }

  Widget _buildExportButton() {
    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.surface,
            border:
                Border(top: BorderSide(color: AppTheme.borderColor, width: 1))),
        child: Column(children: [
          // Export options summary
          Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                      width: 1)),
              child: Row(children: [
                CustomIconWidget(
                    iconName: 'info', color: AppTheme.accentColor, size: 4.w),
                SizedBox(width: 3.w),
                Expanded(
                    child: Text(
                        'Format: ${_selectedFormat.toUpperCase()} • Quality: ${_selectedQuality} • Range: ${_exportRange}',
                        style: AppTheme.darkTheme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.textPrimary))),
              ])),

          SizedBox(height: 2.h),

          // Export buttons
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: _isExporting ? null : _exportStems,
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.accentColor),
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text('Export Stems',
                        style: AppTheme.darkTheme.textTheme.titleMedium
                            ?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w600)))),
            SizedBox(width: 3.w),
            Expanded(
                flex: 2,
                child: ElevatedButton(
                    onPressed: _isExporting ? null : _exportMasterTrack,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _isExporting
                            ? AppTheme.textSecondary
                            : AppTheme.accentColor,
                        foregroundColor: AppTheme.primaryDark,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _isExporting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                SizedBox(
                                    width: 4.w,
                                    height: 4.w,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppTheme.primaryDark))),
                                SizedBox(width: 2.w),
                                Text('Exporting...',
                                    style: AppTheme
                                        .darkTheme.textTheme.titleMedium
                                        ?.copyWith(
                                            color: AppTheme.primaryDark,
                                            fontWeight: FontWeight.w600)),
                              ])
                        : Text('Export Master',
                            style: AppTheme.darkTheme.textTheme.titleMedium
                                ?.copyWith(
                                    color: AppTheme.primaryDark,
                                    fontWeight: FontWeight.w600)))),
          ]),
        ]));
  }

  Future<void> _exportMasterTrack() async {
    if (_fileName.isEmpty) {
      _showErrorSnackBar('Please enter a file name');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // Show progress dialog
      _showExportProgressDialog();

      // Mock input path - in real app, this would be the actual mixed audio file
      final inputPath = '/mock/path/to/mixed_audio.wav';

      final result = await _exportService.exportAudio(
          inputPath: inputPath,
          outputFormat: _selectedFormat,
          quality: _selectedQuality,
          outputFileName: '$_fileName.$_selectedFormat',
          metadata: _metadata.isNotEmpty ? _metadata : null);

      if (result != null) {
        Navigator.pop(context); // Close progress dialog
        _showExportSuccessDialog(result);
      } else {
        Navigator.pop(context); // Close progress dialog
        _showErrorSnackBar('Export failed. Please try again.');
      }
    } catch (e) {
      Navigator.pop(context); // Close progress dialog
      _showErrorSnackBar('Export error: $e');
    } finally {
      setState(() {
        _isExporting = false;
        _exportProgress = 0.0;
      });
    }
  }

  Future<void> _exportStems() async {
    if (_fileName.isEmpty) {
      _showErrorSnackBar('Please enter a file name');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // Show progress dialog
      _showExportProgressDialog();

      // Mock stem paths - in real app, these would be actual separated stem files
      final stemPaths = {
        'vocals': '/mock/path/to/vocals.wav',
        'drums': '/mock/path/to/drums.wav',
        'bass': '/mock/path/to/bass.wav',
        'piano': '/mock/path/to/piano.wav',
        'other': '/mock/path/to/other.wav',
      };

      final result = await _exportService.exportStems(
          stemPaths: stemPaths,
          outputFormat: _selectedFormat,
          quality: _selectedQuality,
          metadata: _metadata.isNotEmpty ? _metadata : null);

      if (result != null && result.isNotEmpty) {
        Navigator.pop(context); // Close progress dialog
        _showStemsExportSuccessDialog(result);
      } else {
        Navigator.pop(context); // Close progress dialog
        _showErrorSnackBar('Stems export failed. Please try again.');
      }
    } catch (e) {
      Navigator.pop(context); // Close progress dialog
      _showErrorSnackBar('Stems export error: $e');
    } finally {
      setState(() {
        _isExporting = false;
        _exportProgress = 0.0;
      });
    }
  }

  void _showExportProgressDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ExportProgressDialog(
            progress: _exportProgress,
            status: _exportStatus,
            errorMessage: '',
            estimatedTime: 0,
            hasError: false,
            isCompleted: false,
            onCancel: () {
              Navigator.pop(context);
              setState(() {
                _isExporting = false;
              });
            }));
  }

  void _showExportSuccessDialog(String filePath) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: AppTheme.darkTheme.colorScheme.surface,
                title: Row(children: [
                  CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.successColor,
                      size: 6.w),
                  SizedBox(width: 3.w),
                  Text('Export Successful',
                      style: AppTheme.darkTheme.textTheme.titleLarge),
                ]),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your audio has been exported successfully!',
                          style: AppTheme.darkTheme.textTheme.bodyMedium),
                      SizedBox(height: 2.h),
                      Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                              color: AppTheme
                                  .darkTheme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('File Details:',
                                    style: AppTheme
                                        .darkTheme.textTheme.bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                SizedBox(height: 1.h),
                                Text('Name: $_fileName.$_selectedFormat',
                                    style:
                                        AppTheme.darkTheme.textTheme.bodySmall),
                                Text('Format: ${_selectedFormat.toUpperCase()}',
                                    style:
                                        AppTheme.darkTheme.textTheme.bodySmall),
                                Text('Quality: $_selectedQuality',
                                    style:
                                        AppTheme.darkTheme.textTheme.bodySmall),
                                if (filePath.isNotEmpty)
                                  Text('Location: $filePath',
                                      style: AppTheme
                                          .darkTheme.textTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                              ])),
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: TextStyle(color: AppTheme.accentColor))),
                ]));
  }

  void _showStemsExportSuccessDialog(Map<String, String> stemPaths) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: AppTheme.darkTheme.colorScheme.surface,
                title: Row(children: [
                  CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.successColor,
                      size: 6.w),
                  SizedBox(width: 3.w),
                  Text('Stems Exported',
                      style: AppTheme.darkTheme.textTheme.titleLarge),
                ]),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'All ${stemPaths.length} stems have been exported successfully!',
                          style: AppTheme.darkTheme.textTheme.bodyMedium),
                      SizedBox(height: 2.h),
                      Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                              color: AppTheme
                                  .darkTheme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Exported Stems:',
                                    style: AppTheme
                                        .darkTheme.textTheme.bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                SizedBox(height: 1.h),
                                ...stemPaths.entries
                                    .map((entry) => Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.25.h),
                                        child: Text(
                                            '• ${entry.key.toUpperCase()} stem',
                                            style: AppTheme.darkTheme.textTheme
                                                .bodySmall)))
                                    .toList(),
                              ])),
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: TextStyle(color: AppTheme.accentColor))),
                ]));
  }

  void _showExportInfo() async {
    final exportInfo = await _exportService.getExportInfo();
    if (exportInfo == null) return;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: AppTheme.darkTheme.colorScheme.surface,
                title: Text('Export Information',
                    style: AppTheme.darkTheme.textTheme.titleLarge),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Platform', exportInfo['platform']),
                      _buildInfoRow(
                          'Export Location', exportInfo['exportLocation']),
                      if (exportInfo.containsKey('exportCount'))
                        _buildInfoRow('Previous Exports',
                            '${exportInfo['exportCount']} files'),
                      SizedBox(height: 2.h),
                      Text('Supported Formats:',
                          style: AppTheme.darkTheme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 1.h),
                      Wrap(
                          spacing: 1.w,
                          runSpacing: 1.h,
                          children: (exportInfo['supportedFormats'] as List)
                              .map((format) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                      color: AppTheme.accentColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(format.toString().toUpperCase(),
                                      style: AppTheme
                                          .darkTheme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppTheme.accentColor))))
                              .toList()),
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: TextStyle(color: AppTheme.accentColor))),
                ]));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 25.w,
              child: Text('$label:',
                  style: AppTheme.darkTheme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(
              child:
                  Text(value, style: AppTheme.darkTheme.textTheme.bodySmall)),
        ]));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating));
  }
}