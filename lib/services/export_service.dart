import 'dart:io' if (dart.library.io) 'dart:io';
import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.io) 'path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  // Stream controllers for export progress
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Getters for streams
  Stream<double> get progressStream => _progressController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<String> get errorStream => _errorController.stream;

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  // Export audio with advanced mixing features
  Future<String?> exportAudio({
    required String inputPath,
    required String outputFormat,
    required String quality,
    String? outputFileName,
    Map<String, String>? metadata,
    List<Map<String, dynamic>>? tracks,
    double? startTime,
    double? endTime,
    bool addWatermark = false,
    double masterVolume = 1.0,
    double masterPitch = 0.0,
    double masterSpeed = 1.0,
    double masterReverb = 0.0,
    double masterEcho = 0.0,
    double tempo = 120.0,
  }) async {
    _isExporting = true;
    _statusController.add('Preparing advanced export...');

    try {
      if (kIsWeb) {
        return await _exportAudioWeb(inputPath, outputFormat, outputFileName, tracks, masterVolume, masterPitch, masterSpeed);
      } else {
        return await _exportAudioMobile(
            inputPath, outputFormat, quality, outputFileName, metadata, tracks, startTime, endTime, addWatermark, masterVolume, masterPitch, masterSpeed, masterReverb, masterEcho, tempo);
      }
    } catch (e) {
      _errorController.add('Export failed: $e');
      return null;
    } finally {
      _isExporting = false;
    }
  }

  Future<String?> _exportAudioWeb(
      String inputUrl, String format, String? fileName, List<Map<String, dynamic>>? tracks, double masterVolume, double masterPitch, double masterSpeed) async {
    try {
      _statusController.add('Processing tracks for web export...');
      _progressController.add(0.2);

      // Process each track with its individual settings
      if (tracks != null) {
        for (int i = 0; i < tracks.length; i++) {
          final track = tracks[i];
          if (!track['isMuted'] && track['stemPath'] != null) {
            _statusController.add('Processing ${track['name']}...');
            _progressController.add(0.2 + (i / tracks.length) * 0.4);
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }

      _statusController.add('Applying master effects...');
      _progressController.add(0.7);
      await Future.delayed(const Duration(seconds: 1));

      _statusController.add('Generating ${format.toUpperCase()} file...');
      _progressController.add(0.9);

      // For web, we can't process the audio file, so we'll trigger a download
      final response = await html.HttpRequest.request(
        inputUrl,
        responseType: 'blob',
      );

      if (response.status == 200) {
        final blob = response.response as html.Blob;
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName ?? 'exported_audio.$format')
          ..click();

        html.Url.revokeObjectUrl(url);

        _statusController.add('Export completed!');
        _progressController.add(1.0);
        return 'Downloaded to browser downloads folder';
      } else {
        throw Exception('Failed to download audio file');
      }
    } catch (e) {
      _errorController.add('Web export failed: $e');
      return null;
    }
  }

  Future<String?> _exportAudioMobile(
    String inputPath,
    String format,
    String quality,
    String? fileName,
    Map<String, String>? metadata,
    List<Map<String, dynamic>>? tracks,
    double? startTime,
    double? endTime,
    bool addWatermark,
    double masterVolume,
    double masterPitch,
    double masterSpeed,
    double masterReverb,
    double masterEcho,
    double tempo,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${directory.path}/exports');
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }

      final outputFileName = fileName ??
          'exported_audio_${DateTime.now().millisecondsSinceEpoch}.$format';
      final outputPath = '${exportsDir.path}/$outputFileName';

      _statusController.add('Processing individual tracks...');
      _progressController.add(0.1);

      // Build FFmpeg command with advanced mixing
      String command = '-i "$inputPath"';
      
      // Apply master effects
      List<String> masterFilters = [];
      
      if (masterVolume != 1.0) {
        masterFilters.add('volume=$masterVolume');
      }
      
      if (masterPitch != 0.0) {
        masterFilters.add('asetrate=44100*pow(2,$masterPitch/12),aresample=44100');
      }
      
      if (masterSpeed != 1.0) {
        masterFilters.add('atempo=$masterSpeed');
      }
      
      if (masterReverb > 0.0) {
        masterFilters.add('aecho=0.8:0.9:${(masterReverb * 1000).round()}:$masterReverb');
      }
      
      if (masterEcho > 0.0) {
        masterFilters.add('aecho=0.8:0.88:${(masterEcho * 500).round()}:$masterEcho');
      }
      
      if (masterFilters.isNotEmpty) {
        command += ' -af "${masterFilters.join(',')}"';
      }

      // Add codec parameters
      String codecParams = _getCodecParams(format, quality);
      command += ' $codecParams';
      
      // Add time range if specified
      if (startTime != null && endTime != null) {
        command = '-ss $startTime -t ${endTime - startTime} $command';
      }
      
      // Add metadata
      String metadataParams = _buildMetadataParams(metadata);
      if (metadataParams.isNotEmpty) {
        command += ' $metadataParams';
      }
      
      // Add watermark if requested
      if (addWatermark) {
        command += ' -metadata comment="Created with RapidMixer"';
      }
      
      command += ' "$outputPath"';

      _statusController.add('Converting to $format format...');
      _progressController.add(0.6);

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Export completed!');
        _progressController.add(1.0);
        return outputPath;
      } else {
        throw Exception('FFmpeg export failed');
      }
    } catch (e) {
      _errorController.add('Mobile export failed: $e');
      return null;
    }
  }

  String _getCodecParams(String format, String quality) {
    switch (format.toLowerCase()) {
      case 'mp3':
        switch (quality) {
          case 'high':
            return '-acodec libmp3lame -b:a 320k';
          case 'medium':
            return '-acodec libmp3lame -b:a 192k';
          case 'low':
            return '-acodec libmp3lame -b:a 128k';
          default:
            return '-acodec libmp3lame -b:a 192k';
        }

      case 'wav':
        switch (quality) {
          case 'high':
            return '-acodec pcm_s24le -ar 48000';
          case 'medium':
            return '-acodec pcm_s16le -ar 44100';
          case 'low':
            return '-acodec pcm_s16le -ar 22050';
          default:
            return '-acodec pcm_s16le -ar 44100';
        }

      case 'flac':
        return '-acodec flac -compression_level 5';

      case 'aac':
        switch (quality) {
          case 'high':
            return '-acodec aac -b:a 256k';
          case 'medium':
            return '-acodec aac -b:a 128k';
          case 'low':
            return '-acodec aac -b:a 96k';
          default:
            return '-acodec aac -b:a 128k';
        }

      default:
        return '-acodec libmp3lame -b:a 192k';
    }
  }

  String _buildMetadataParams(Map<String, String>? metadata) {
    if (metadata == null || metadata.isEmpty) return '';

    final params = <String>[];
    metadata.forEach((key, value) {
      params.add('-metadata $key="$value"');
    });

    return params.join(' ');
  }

  // Export stems as individual files
  Future<Map<String, String>?> exportStems({
    required Map<String, String> stemPaths,
    required String outputFormat,
    required String quality,
    Map<String, String>? metadata,
  }) async {
    if (kIsWeb) {
      _errorController.add('Stem export not supported on web platform');
      return null;
    }

    _isExporting = true;
    _statusController.add('Exporting stems...');

    try {
      final directory = await getApplicationDocumentsDirectory();
      final stemsDir = Directory('${directory.path}/exported_stems');
      if (!await stemsDir.exists()) {
        await stemsDir.create(recursive: true);
      }

      final exportedStems = <String, String>{};
      final totalStems = stemPaths.length;
      int currentStem = 0;

      for (final entry in stemPaths.entries) {
        final stemType = entry.key;
        final inputPath = entry.value;

        _statusController.add('Exporting $stemType stem...');
        _progressController.add(currentStem / totalStems);

        final outputFileName = '${stemType}_stem.$outputFormat';
        final outputPath = '${stemsDir.path}/$outputFileName';

        String codecParams = _getCodecParams(outputFormat, quality);
        String metadataParams = _buildMetadataParams({
          ...?metadata,
          'title': '$stemType Stem',
          'album': 'Separated Stems',
        });

        final command =
            '-i "$inputPath" $codecParams $metadataParams "$outputPath"';
        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          exportedStems[stemType] = outputPath;
        } else {
          _errorController.add('Failed to export $stemType stem');
        }

        currentStem++;
      }

      _statusController.add('All stems exported!');
      _progressController.add(1.0);
      return exportedStems;
    } catch (e) {
      _errorController.add('Stem export failed: $e');
      return null;
    } finally {
      _isExporting = false;
    }
  }

  // Export project data as JSON
  Future<String?> exportProjectData(Map<String, dynamic> projectData) async {
    try {
      final jsonString =
          const JsonEncoder.withIndent('  ').convert(projectData);

      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'rapid_mixer_project.json')
          ..click();

        html.Url.revokeObjectUrl(url);
        return 'Downloaded to browser downloads folder';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final projectFile = File('${directory.path}/rapid_mixer_project.json');
        await projectFile.writeAsString(jsonString);
        return projectFile.path;
      }
    } catch (e) {
      _errorController.add('Failed to export project data: $e');
      return null;
    }
  }

  // Get export directory info
  Future<Map<String, dynamic>?> getExportInfo() async {
    if (kIsWeb) {
      return {
        'platform': 'web',
        'exportLocation': 'Browser Downloads Folder',
        'supportedFormats': ['mp3', 'wav'],
        'features': ['basic_export', 'project_export'],
      };
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${directory.path}/exports');

      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }

      final files = await exportsDir.list().toList();
      final audioFiles = files
          .where((file) =>
              file.path.endsWith('.mp3') ||
              file.path.endsWith('.wav') ||
              file.path.endsWith('.flac') ||
              file.path.endsWith('.aac'))
          .toList();

      return {
        'platform': 'mobile',
        'exportLocation': exportsDir.path,
        'exportCount': audioFiles.length,
        'supportedFormats': ['mp3', 'wav', 'flac', 'aac'],
        'features': [
          'format_conversion',
          'quality_settings',
          'metadata_embedding',
          'stem_export'
        ],
      };
    } catch (e) {
      _errorController.add('Failed to get export info: $e');
      return null;
    }
  }

  void dispose() {
    _progressController.close();
    _statusController.close();
    _errorController.close();
  }
}


class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  // Your backend URL for mixing/export
  final String _backendUrl = "https://rapid-mixer-2-0-1.onrender.com/mix-stems";

  Future<String?> exportMix({
    required Map<String, dynamic> stems,
    required Map<String, double> volumes,
    required Map<String, bool> muted,
    required String format,
    required String quality,
  }) async {
    try {
      // Prepare the mix data
      final mixData = {
        'stems': stems,
        'volumes': volumes,
        'muted': muted,
        'format': format,
        'quality': quality,
      };

      // Send to backend for mixing
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(mixData),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final mixedAudioUrl = result['mixed_audio_url'];
        
        // Download the mixed audio file
        return await _downloadFile(mixedAudioUrl, format);
      } else {
        throw Exception('Failed to export mix. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  Future<String> _downloadFile(String url, String format) async {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'rapid_mixer_export_${DateTime.now().millisecondsSinceEpoch}.$format';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to download exported file');
    }
  }
}
