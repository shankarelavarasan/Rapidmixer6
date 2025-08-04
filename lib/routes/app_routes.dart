import 'package:flutter/material.dart';
import '../presentation/audio_import/audio_import.dart';
import '../presentation/beat_library/beat_library.dart';
import '../presentation/track_editor/track_editor.dart';
import '../presentation/export_options/export_options.dart';
import '../presentation/effects_panel/effects_panel.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String audioImport = '/audio-import';
  static const String aiProcessing = '/ai-processing';
  static const String beatLibrary = '/beat-library';
  static const String trackEditor = '/track-editor';
  static const String exportOptions = '/export-options';
  static const String effectsPanel = '/effects-panel';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => AudioImport(),
    audioImport: (context) => AudioImport(),
    beatLibrary: (context) => BeatLibrary(),
    trackEditor: (context) => TrackEditor(),
    exportOptions: (context) => ExportOptions(),
    effectsPanel: (context) => EffectsPanel(),
    // TODO: Add your other routes here
  };
}
