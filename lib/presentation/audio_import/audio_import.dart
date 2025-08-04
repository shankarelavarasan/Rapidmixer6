import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/audio_processing_service.dart';

class AudioImportScreen extends StatefulWidget {
  const AudioImportScreen({Key? key}) : super(key: key);

  @override
  State<AudioImportScreen> createState() => _AudioImportScreenState();
}

class _AudioImportScreenState extends State<AudioImportScreen> {
  final AudioProcessingService _audioService = AudioProcessingService();
  bool _isProcessing = false;
  String _statusMessage = '';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _audioService.statusStream.listen((status) {
      setState(() {
        _statusMessage = status;
      });
    });

    _audioService.progressStream.listen((progress) {
      setState(() {
        _progress = progress;
      });
    });

    _audioService.errorStream.listen((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    });
  }

  Future<void> _pickAndProcessAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isProcessing = true;
        });

        File audioFile = File(result.files.single.path!);
        
        // Process the audio file
        final stems = await _audioService.separateStems(audioFile);
        
        // Navigate to track editor with the stems
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/track-editor',
            arguments: {
              'originalFile': audioFile.path,
              'stems': stems,
            },
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process audio: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
        _progress = 0.0;
        _statusMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Audio'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.audio_file,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              const Text(
                'Import Your Audio File',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select an audio file to separate into individual stems using AI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              if (_isProcessing) ...
              [
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 16),
                Text(_statusMessage),
                const SizedBox(height: 32),
              ],
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickAndProcessAudio,
                icon: const Icon(Icons.upload_file),
                label: Text(_isProcessing ? 'Processing...' : 'Select Audio File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
