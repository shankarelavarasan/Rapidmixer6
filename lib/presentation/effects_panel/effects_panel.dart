import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/utils/glassmorphism_utils.dart';
import './widgets/compression_controls_widget.dart';
import './widgets/echo_controls_widget.dart';
import './widgets/eq_controls_widget.dart';
import './widgets/reverb_controls_widget.dart';
import './widgets/waveform_visualization_widget.dart';
import '../../widgets/effects/enhanced_effects_panel.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedHeader(),
              SizedBox(height: 2.h),
              _buildWaveformSection(),
              SizedBox(height: 1.h),
              Expanded(
                child: EnhancedEffectsPanel(
                  onEffectChanged: _handleEffectChange,
                  effectsEnabled: Map.fromEntries(
                    _effectsBypassed.entries.map((e) => MapEntry(e.key, !e.value)),
                  ),
                  effectsParameters: _effectsParameters,
                ),
              ),
              _buildEnhancedBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 16,
      blur: 12,
      opacity: 0.1,
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.all(4.w),
      boxShadow: [
        BoxShadow(
          color: AppTheme.glassShadow,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor.withOpacity(0.2),
                  AppTheme.accentColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
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
                  'Professional Effects',
                  style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Studio-grade audio processing suite',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
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
          gradient: LinearGradient(
            colors: [
              AppTheme.accentColor,
              AppTheme.accentColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomIconWidget(
          iconName: 'apps',
          color: AppTheme.primaryDark,
          size: 20,
        ),
      ),
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      onSelected: (route) => Navigator.pushNamed(context, route),
      itemBuilder: (context) => _navigationRoutes.map((routeData) {
        return PopupMenuItem<String>(
          value: routeData['route'],
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.surfaceColor.withOpacity(0.9),
                  AppTheme.surfaceColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor.withOpacity(0.2),
                      AppTheme.accentColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: routeData['icon'],
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
              title: Text(
                routeData['title'],
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                routeData['description'],
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 1.h,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWaveformSection() {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 16,
      blur: 10,
      opacity: 0.08,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      padding: EdgeInsets.all(2.w),
      child: WaveformVisualizationWidget(
        isProcessing: _isProcessing,
        activeEffects: Map.fromEntries(
          _effectsBypassed.entries.map((e) => MapEntry(e.key, !e.value)),
        ),
      ),
    );
  }

  Widget _buildEnhancedTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceColor.withOpacity(0.8),
            AppTheme.surfaceColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TabBar(
          controller: _tabController,
          tabs: [
            _buildEnhancedTab('EQ', 'equalizer', !_effectsBypassed['eq']!),
            _buildEnhancedTab('Reverb', 'surround_sound', !_effectsBypassed['reverb']!),
            _buildEnhancedTab('Echo', 'repeat', !_effectsBypassed['delay']!),
            _buildEnhancedTab('Comp', 'compress', !_effectsBypassed['compression']!),
          ],
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accentColor,
          indicatorWeight: 3,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 2.w),
          labelStyle: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
          unselectedLabelStyle:
              AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTab(String label, String iconName, bool isActive) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppTheme.accentColor.withOpacity(0.2),
                    AppTheme.accentColor.withOpacity(0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              AppTheme.accentColor.withOpacity(0.3),
                              AppTheme.accentColor.withOpacity(0.1),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: iconName,
                    color: isActive ? AppTheme.accentColor : AppTheme.textSecondary,
                    size: 20,
                  ),
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
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        EqControlsWidget(
          onEqChange: (frequency, gain) =>
              _handleEffectChange('eq', {'frequency': frequency, 'gain': gain}),
          onReset: () => _handleEffectReset('eq'),
          isBypassed: _effectsBypassed['eq']!,
          onBypassToggle: () => _toggleEffectBypass('eq'),
        ),
        ReverbControlsWidget(
          onReverbChange: (parameter, value) =>
              _handleEffectChange('reverb', {parameter: value}),
          onReset: () => _handleEffectReset('reverb'),
          isBypassed: _effectsBypassed['reverb']!,
          onBypassToggle: () => _toggleEffectBypass('reverb'),
        ),
        EchoControlsWidget(
          onEchoChange: (parameter, value) =>
              _handleEffectChange('delay', {parameter: value}),
          onReset: () => _handleEffectReset('delay'),
          isBypassed: _effectsBypassed['delay']!,
          onBypassToggle: () => _toggleEffectBypass('delay'),
        ),
        CompressionControlsWidget(
          onCompressionChange: (parameter, value) =>
              _handleEffectChange('compression', {parameter: value}),
          onReset: () => _handleEffectReset('compression'),
          isBypassed: _effectsBypassed['compression']!,
          onBypassToggle: () => _toggleEffectBypass('compression'),
        ),
      ],
    );
  }

  Widget _buildEnhancedBottomControls() {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 16,
      blur: 12,
      opacity: 0.1,
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.all(4.w),
      boxShadow: [
        BoxShadow(
          color: AppTheme.glassShadow,
          blurRadius: 20,
          offset: const Offset(0, -8),
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor.withOpacity(0.1),
                    AppTheme.accentColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide.none,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor.withOpacity(0.8),
                    AppTheme.accentColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.successColor,
                  AppTheme.successColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.successColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _applyEffects,
              icon: CustomIconWidget(
                iconName: 'check',
                color: AppTheme.primaryDark,
                size: 24,
              ),
              style: IconButton.styleFrom(
                padding: EdgeInsets.all(3.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEffectChange(String effectType, Map<String, dynamic> parameters) {
    setState(() {
      _effectsParameters[effectType]!.addAll(parameters);
    });
    parameters.forEach((parameter, value) {
      _processAudioEffect(effectType, parameter, value);
    });
  }

  // Legacy method for backward compatibility
  void _handleEffectChangeLegacy(String effectType, String parameter, dynamic value) {
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
