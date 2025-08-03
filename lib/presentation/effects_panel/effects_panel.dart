import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/compression_controls_widget.dart';
import './widgets/delay_controls_widget.dart';
import './widgets/eq_controls_widget.dart';
import './widgets/reverb_controls_widget.dart';
import './widgets/waveform_visualization_widget.dart';

class EffectsPanel extends StatefulWidget {
  const EffectsPanel({super.key});

  @override
  State<EffectsPanel> createState() => _EffectsPanelState();
}

class _EffectsPanelState extends State<EffectsPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  final Map<String, bool> _effectsBypassed = {
    'eq': false,
    'reverb': false,
    'delay': false,
    'compression': false,
  };

  final Map<String, Map<String, dynamic>> _effectsParameters = {
    'eq': {},
    'reverb': {},
    'delay': {},
    'compression': {},
  };

  final List<Map<String, dynamic>> _navigationRoutes = [
    {
      'title': 'Audio Import',
      'route': '/audio-import',
      'icon': 'upload_file',
      'description': 'Import audio files',
    },
    {
      'title': 'AI Processing',
      'route': '/ai-processing',
      'icon': 'auto_awesome',
      'description': 'AI stem separation',
    },
    {
      'title': 'Track Editor',
      'route': '/track-editor',
      'icon': 'multitrack_audio',
      'description': 'Edit audio tracks',
    },
    {
      'title': 'Beat Library',
      'route': '/beat-library',
      'icon': 'library_music',
      'description': 'Browse beats',
    },
    {
      'title': 'Export Options',
      'route': '/export-options',
      'icon': 'download',
      'description': 'Export your mix',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildWaveformSection(),
            _buildTabBar(),
            Expanded(
              child: _buildTabBarView(),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: AppTheme.textPrimary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Effects Panel',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Professional audio processing controls',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildQuickNavigationButton(),
        ],
      ),
    );
  }

  Widget _buildQuickNavigationButton() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: 'apps',
          color: AppTheme.primaryDark,
          size: 20,
        ),
      ),
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.borderColor),
      ),
      onSelected: (route) => Navigator.pushNamed(context, route),
      itemBuilder: (context) => _navigationRoutes.map((routeData) {
        return PopupMenuItem<String>(
          value: routeData['route'],
          child: ListTile(
            leading: CustomIconWidget(
              iconName: routeData['icon'],
              color: AppTheme.accentColor,
              size: 20,
            ),
            title: Text(
              routeData['title'],
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: Text(
              routeData['description'],
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWaveformSection() {
    return WaveformVisualizationWidget(
      isProcessing: _isProcessing,
      activeEffects: Map.fromEntries(
        _effectsBypassed.entries.map((e) => MapEntry(e.key, !e.value)),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          _buildTab('EQ', 'equalizer', !_effectsBypassed['eq']!),
          _buildTab('Reverb', 'surround_sound', !_effectsBypassed['reverb']!),
          _buildTab('Delay', 'repeat', !_effectsBypassed['delay']!),
          _buildTab('Comp', 'compress', !_effectsBypassed['compression']!),
        ],
        labelColor: AppTheme.accentColor,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.accentColor,
        indicatorWeight: 3,
        labelStyle: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle:
            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTab(String label, String iconName, bool isActive) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: isActive ? AppTheme.accentColor : AppTheme.textSecondary,
                size: 20,
              ),
              if (isActive)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        EqControlsWidget(
          onEqChange: (frequency, gain) =>
              _handleEffectChange('eq', frequency, gain),
          onReset: () => _handleEffectReset('eq'),
          isBypassed: _effectsBypassed['eq']!,
          onBypassToggle: () => _toggleEffectBypass('eq'),
        ),
        ReverbControlsWidget(
          onReverbChange: (parameter, value) =>
              _handleEffectChange('reverb', parameter, value),
          onReset: () => _handleEffectReset('reverb'),
          isBypassed: _effectsBypassed['reverb']!,
          onBypassToggle: () => _toggleEffectBypass('reverb'),
        ),
        DelayControlsWidget(
          onDelayChange: (parameter, value) =>
              _handleEffectChange('delay', parameter, value),
          onReset: () => _handleEffectReset('delay'),
          isBypassed: _effectsBypassed['delay']!,
          onBypassToggle: () => _toggleEffectBypass('delay'),
        ),
        CompressionControlsWidget(
          onCompressionChange: (parameter, value) =>
              _handleEffectChange('compression', parameter, value),
          onReset: () => _handleEffectReset('compression'),
          isBypassed: _effectsBypassed['compression']!,
          onBypassToggle: () => _toggleEffectBypass('compression'),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _resetAllEffects,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.accentColor,
                size: 18,
              ),
              label: Text(
                'Reset All',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.accentColor,
                ),
              ),
              style: AppTheme.darkTheme.outlinedButtonTheme.style?.copyWith(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _savePreset,
              icon: CustomIconWidget(
                iconName: 'save',
                color: AppTheme.primaryDark,
                size: 18,
              ),
              label: Text(
                'Save Preset',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryDark,
                ),
              ),
              style: AppTheme.darkTheme.elevatedButtonTheme.style?.copyWith(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _applyEffects,
              icon: CustomIconWidget(
                iconName: 'check',
                color: AppTheme.primaryDark,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEffectChange(String effectType, String parameter, dynamic value) {
    setState(() {
      _effectsParameters[effectType]![parameter] = value;
    });
    _processAudioEffect(effectType, parameter, value);
  }

  void _handleEffectReset(String effectType) {
    setState(() {
      _effectsParameters[effectType]!.clear();
    });
    _processAudioReset(effectType);
  }

  void _toggleEffectBypass(String effectType) {
    setState(() {
      _effectsBypassed[effectType] = !_effectsBypassed[effectType]!;
    });
    _processEffectBypass(effectType, _effectsBypassed[effectType]!);
  }

  void _resetAllEffects() {
    setState(() {
      _effectsBypassed.updateAll((key, value) => false);
      _effectsParameters.forEach((key, value) => value.clear());
    });
    _processAllEffectsReset();
  }

  void _savePreset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Save Effects Preset',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter preset name',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSaveSuccess();
            },
            child: Text(
              'Save',
              style: TextStyle(color: AppTheme.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preset saved successfully!',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _applyEffects() {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Effects applied successfully!',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }

  void _processAudioEffect(String effectType, String parameter, dynamic value) {
    // Real-time audio processing would be implemented here
    // This would interface with native audio processing engines
    print('Processing $effectType: $parameter = $value');
  }

  void _processAudioReset(String effectType) {
    // Reset specific effect processing
    print('Resetting $effectType effect');
  }

  void _processEffectBypass(String effectType, bool bypassed) {
    // Toggle effect bypass in audio processing chain
    print('$effectType bypass: $bypassed');
  }

  void _processAllEffectsReset() {
    // Reset all effects in audio processing chain
    print('Resetting all effects');
  }
}
