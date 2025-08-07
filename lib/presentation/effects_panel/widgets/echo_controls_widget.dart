import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class EchoControlsWidget extends StatefulWidget {
  final bool isBypassed;
  final Function(String, double) onEchoChange;
  final VoidCallback onReset;
  final VoidCallback? onBypassToggle;

  const EchoControlsWidget({
    super.key,
    required this.isBypassed,
    required this.onEchoChange,
    required this.onReset,
    this.onBypassToggle,
  });

  @override
  State<EchoControlsWidget> createState() => _EchoControlsWidgetState();
}

class _EchoControlsWidgetState extends State<EchoControlsWidget>
    with TickerProviderStateMixin {
  // Core echo parameters
  double _delayTime = 0.3; // 300ms
  double _feedback = 0.4; // 40%
  double _wetDryMix = 0.3; // 30% wet
  double _highCut = 0.7; // High frequency damping
  double _lowCut = 0.2; // Low frequency damping
  
  // Advanced parameters
  double _stereoSpread = 0.5;
  double _modulation = 0.1;
  double _pingPong = 0.0;
  
  // UI state
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _waveformController;
  late Animation<double> _waveformAnimation;
  bool _showWaveform = false;
  String _selectedPreset = 'Vocal';
  
  // Echo presets
  final List<Map<String, dynamic>> _echoPresets = [
    {
      'name': 'Vocal',
      'delayTime': 0.25,
      'feedback': 0.3,
      'wetDryMix': 0.2,
      'highCut': 0.8,
      'lowCut': 0.3,
      'stereoSpread': 0.4,
      'modulation': 0.05,
      'pingPong': 0.0,
    },
    {
      'name': 'Slap',
      'delayTime': 0.15,
      'feedback': 0.2,
      'wetDryMix': 0.3,
      'highCut': 0.9,
      'lowCut': 0.1,
      'stereoSpread': 0.2,
      'modulation': 0.0,
      'pingPong': 0.0,
    },
    {
      'name': 'Tape',
      'delayTime': 0.4,
      'feedback': 0.6,
      'wetDryMix': 0.4,
      'highCut': 0.5,
      'lowCut': 0.4,
      'stereoSpread': 0.3,
      'modulation': 0.2,
      'pingPong': 0.0,
    },
    {
      'name': 'Ping Pong',
      'delayTime': 0.35,
      'feedback': 0.5,
      'wetDryMix': 0.5,
      'highCut': 0.7,
      'lowCut': 0.2,
      'stereoSpread': 1.0,
      'modulation': 0.1,
      'pingPong': 1.0,
    },
    {
      'name': 'Ambient',
      'delayTime': 0.8,
      'feedback': 0.7,
      'wetDryMix': 0.6,
      'highCut': 0.4,
      'lowCut': 0.5,
      'stereoSpread': 0.8,
      'modulation': 0.3,
      'pingPong': 0.5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize waveform animation
    _waveformController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _waveformAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveformController,
      curve: Curves.linear,
    ));
    
    _animationController.forward();
    _waveformController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.secondaryDark.withOpacity(0.8),
              AppTheme.primaryDark.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEnhancedHeader(),
            SizedBox(height: 3.h),
            _buildPresetSelector(),
            SizedBox(height: 3.h),
            if (_showWaveform) ...[
              _buildEchoWaveform(),
              SizedBox(height: 3.h),
            ],
            _buildEnhancedParameterControls(),
            SizedBox(height: 3.h),
            _buildAdvancedControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentColor.withOpacity(0.2),
            AppTheme.successColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional Echo',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Digital Delay Processing',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showWaveform = !_showWaveform;
                  });
                },
                icon: Icon(
                  _showWaveform ? Icons.show_chart : Icons.graphic_eq,
                  color: AppTheme.accentColor,
                  size: 6.w,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.isBypassed
                          ? AppTheme.textSecondary.withOpacity(0.3)
                          : AppTheme.successColor.withOpacity(0.3),
                      widget.isBypassed
                          ? AppTheme.textSecondary.withOpacity(0.1)
                          : AppTheme.successColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isBypassed
                        ? AppTheme.textSecondary.withOpacity(0.5)
                        : AppTheme.successColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Switch(
                  value: !widget.isBypassed,
                  onChanged: (value) {
                    // Handle bypass toggle
                  },
                  activeColor: AppTheme.successColor,
                  inactiveThumbColor: AppTheme.textSecondary,
                  inactiveTrackColor: AppTheme.textSecondary.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryDark.withOpacity(0.6),
            AppTheme.primaryDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Echo Presets',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 8.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _echoPresets.length,
              itemBuilder: (context, index) {
                final preset = _echoPresets[index];
                final isSelected = _selectedPreset == preset['name'];
                
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 2.w),
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? [
                              AppTheme.accentColor.withOpacity(0.3),
                              AppTheme.accentColor.withOpacity(0.1),
                            ]
                          : [
                              AppTheme.borderColor.withOpacity(0.2),
                              AppTheme.borderColor.withOpacity(0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentColor.withOpacity(0.6)
                          : AppTheme.borderColor.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _applyPreset(preset),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getPresetIcon(preset['name']),
                          color: isSelected
                              ? AppTheme.accentColor
                              : AppTheme.textSecondary,
                          size: 5.w,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          preset['name'],
                          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? AppTheme.accentColor
                                : AppTheme.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEchoWaveform() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryDark.withOpacity(0.6),
            AppTheme.primaryDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Echo Waveform',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 12.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: AnimatedBuilder(
              animation: _waveformAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: EchoWaveformPainter(
                    _delayTime,
                    _feedback,
                    _wetDryMix,
                    _modulation,
                    widget.isBypassed,
                    animationValue: _waveformAnimation.value,
                    stereoSpread: _stereoSpread,
                    pingPong: _pingPong,
                    highCut: _highCut,
                    lowCut: _lowCut,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedParameterControls() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryDark.withOpacity(0.6),
            AppTheme.primaryDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Echo Parameters',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Delay Time',
                  _delayTime,
                  0.0,
                  1.0,
                  Icons.access_time,
                  AppTheme.accentColor,
                  (value) {
                    setState(() {
                      _delayTime = value;
                    });
                    widget.onEchoChange('delayTime', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Feedback',
                  _feedback,
                  0.0,
                  1.0,
                  Icons.repeat,
                  AppTheme.warningColor,
                  (value) {
                    setState(() {
                      _feedback = value;
                    });
                    widget.onEchoChange('feedback', value);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Wet/Dry Mix',
                  _wetDryMix,
                  0.0,
                  1.0,
                  Icons.water_drop,
                  AppTheme.successColor,
                  (value) {
                    setState(() {
                      _wetDryMix = value;
                    });
                    widget.onEchoChange('wetDryMix', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'High Cut',
                  _highCut,
                  0.0,
                  1.0,
                  Icons.trending_down,
                  AppTheme.errorColor,
                  (value) {
                    setState(() {
                      _highCut = value;
                    });
                    widget.onEchoChange('highCut', value);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Low Cut',
                  _lowCut,
                  0.0,
                  1.0,
                  Icons.trending_up,
                  AppTheme.accentColor,
                  (value) {
                    setState(() {
                      _lowCut = value;
                    });
                    widget.onEchoChange('lowCut', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Stereo Spread',
                  _stereoSpread,
                  0.0,
                  1.0,
                  Icons.surround_sound,
                  AppTheme.warningColor,
                  (value) {
                    setState(() {
                      _stereoSpread = value;
                    });
                    widget.onEchoChange('stereoSpread', value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedParameterSlider(
    String label,
    double value,
    double min,
    double max,
    IconData icon,
    Color accentColor,
    Function(double) onChanged,
  ) {
    String displayValue;
    String unit;
    
    switch (label) {
      case 'Delay Time':
        displayValue = '${(10 + (value * 990)).toInt()}';
        unit = 'ms';
        break;
      case 'Feedback':
        displayValue = '${(value * 100).toInt()}';
        unit = '%';
        break;
      case 'Wet/Dry Mix':
        displayValue = '${(value * 100).toInt()}';
        unit = '%';
        break;
      case 'High Cut':
        displayValue = '${(2000 + (value * 18000)).toInt()}';
        unit = 'Hz';
        break;
      case 'Low Cut':
        displayValue = '${(20 + (value * 480)).toInt()}';
        unit = 'Hz';
        break;
      case 'Stereo Spread':
        displayValue = '${(value * 100).toInt()}';
        unit = '%';
        break;
      default:
        displayValue = '${(value * 100).toInt()}';
        unit = '%';
    }
    
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryDark.withOpacity(0.6),
            AppTheme.primaryDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: widget.isBypassed
                        ? AppTheme.textSecondary
                        : accentColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    label,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: widget.isBypassed
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: widget.isBypassed
                      ? AppTheme.textSecondary.withOpacity(0.2)
                      : accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isBypassed
                        ? AppTheme.textSecondary.withOpacity(0.5)
                        : accentColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$displayValue$unit',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: widget.isBypassed
                        ? AppTheme.textSecondary
                        : accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: CustomEchoSliderThumb(accentColor),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: widget.isBypassed
                  ? AppTheme.textSecondary
                  : accentColor,
              inactiveTrackColor: AppTheme.borderColor.withOpacity(0.3),
              overlayColor: accentColor.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: widget.isBypassed ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedControls() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryDark.withOpacity(0.6),
            AppTheme.primaryDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Controls',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                'Reset',
                Icons.refresh,
                AppTheme.warningColor,
                () {
                  setState(() {
                    _delayTime = 0.3;
                    _feedback = 0.4;
                    _wetDryMix = 0.3;
                    _highCut = 0.7;
                    _lowCut = 0.2;
                    _stereoSpread = 0.5;
                    _modulation = 0.1;
                    _pingPong = 0.0;
                  });
                  widget.onReset();
                },
              ),
              _buildControlButton(
                'Sync',
                Icons.sync,
                AppTheme.successColor,
                () {
                  // Tempo sync logic
                },
              ),
              _buildControlButton(
                'Save',
                Icons.save,
                AppTheme.accentColor,
                () {
                  // Save preset logic
                },
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modulation',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: CustomEchoSliderThumb(AppTheme.accentColor),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                      ),
                      child: Slider(
                        value: _modulation,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() {
                            _modulation = value;
                          });
                          widget.onEchoChange('modulation', value);
                        },
                        activeColor: AppTheme.accentColor,
                        inactiveColor: AppTheme.borderColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ping Pong',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: CustomEchoSliderThumb(AppTheme.successColor),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                      ),
                      child: Slider(
                        value: _pingPong,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() {
                            _pingPong = value;
                          });
                          widget.onEchoChange('pingPong', value);
                        },
                        activeColor: AppTheme.successColor,
                        inactiveColor: AppTheme.borderColor.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 5.w,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  label,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  IconData _getPresetIcon(String presetName) {
    switch (presetName) {
      case 'Vocal':
        return Icons.mic;
      case 'Slap':
        return Icons.flash_on;
      case 'Tape':
        return Icons.album;
      case 'Ping Pong':
        return Icons.swap_horiz;
      case 'Ambient':
        return Icons.cloud;
      default:
        return Icons.graphic_eq;
    }
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _delayTime = preset['delayTime'];
      _feedback = preset['feedback'];
      _wetDryMix = preset['wetDryMix'];
      _highCut = preset['highCut'];
      _lowCut = preset['lowCut'];
      _stereoSpread = preset['stereoSpread'];
      _modulation = preset['modulation'];
      _pingPong = preset['pingPong'];
      _selectedPreset = preset['name'];
    });

    // Notify parent of all parameter changes
    widget.onEchoChange('delayTime', _delayTime);
    widget.onEchoChange('feedback', _feedback);
    widget.onEchoChange('wetDryMix', _wetDryMix);
    widget.onEchoChange('highCut', _highCut);
    widget.onEchoChange('lowCut', _lowCut);
    widget.onEchoChange('stereoSpread', _stereoSpread);
    widget.onEchoChange('modulation', _modulation);
    widget.onEchoChange('pingPong', _pingPong);
  }
}

class EchoWaveformPainter extends CustomPainter {
  final double delayTime;
  final double feedback;
  final double wetDryMix;
  final double modulation;
  final bool isBypassed;
  final double animationValue;
  final double stereoSpread;
  final double pingPong;
  final double highCut;
  final double lowCut;

  EchoWaveformPainter(
    this.delayTime,
    this.feedback,
    this.wetDryMix,
    this.modulation,
    this.isBypassed, {
    this.animationValue = 1.0,
    this.stereoSpread = 0.5,
    this.pingPong = 0.0,
    this.highCut = 0.7,
    this.lowCut = 0.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background gradient
    _drawBackground(canvas, size);
    
    if (isBypassed) {
      _drawBypassedState(canvas, size);
      return;
    }

    // Draw frequency response visualization
    _drawFrequencyResponse(canvas, size);
    
    // Draw stereo channels
    _drawStereoChannels(canvas, size);
    
    // Draw echo signals with ping-pong effect
    _drawAdvancedEchoSignals(canvas, size);
    
    // Draw modulation visualization
    _drawEnhancedModulation(canvas, size);
    
    // Draw real-time parameter indicators
    _drawParameterIndicators(canvas, size);
  }

  void _drawBypassedState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw flat line indicating no processing
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );

    // Draw "BYPASSED" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'BYPASSED',
        style: TextStyle(
          color: AppTheme.textSecondary.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryDark.withOpacity(0.05),
          AppTheme.secondaryDark.withOpacity(0.1),
          AppTheme.primaryDark.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    // Draw time grid
    _drawTimeGrid(canvas, size);
  }
  
  void _drawTimeGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    // Vertical time lines
    for (int i = 1; i < 10; i++) {
      final x = (i / 10) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    // Horizontal amplitude lines
    for (int i = 1; i < 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }
  
  void _drawFrequencyResponse(Canvas canvas, Size size) {
    final responsePaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, size.height);
    
    for (int i = 0; i <= 100; i++) {
      final x = (i / 100) * size.width;
      final normalizedFreq = i / 100;
      
      // Calculate frequency response based on high/low cut
      double response = 1.0;
      
      // High cut filter
      if (normalizedFreq > highCut) {
        response *= exp(-(normalizedFreq - highCut) * 5);
      }
      
      // Low cut filter
      if (normalizedFreq < lowCut) {
        response *= exp(-(lowCut - normalizedFreq) * 5);
      }
      
      final y = size.height - (response * size.height * 0.3);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, responsePaint);
  }
  
  void _drawStereoChannels(Canvas canvas, Size size) {
    // Left channel (top half)
    _drawChannelSignal(canvas, size, true);
    
    // Right channel (bottom half)
    _drawChannelSignal(canvas, size, false);
    
    // Center line
    final centerPaint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      centerPaint,
    );
  }
  
  void _drawChannelSignal(Canvas canvas, Size size, bool isLeftChannel) {
    final paint = Paint()
      ..color = isLeftChannel ? AppTheme.accentColor : AppTheme.successColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = isLeftChannel ? size.height * 0.25 : size.height * 0.75;
    final amplitude = size.height * 0.15;
    
    path.moveTo(0, centerY);

    for (int i = 0; i <= 100; i++) {
      final x = (i / 100) * size.width;
      final time = i * 0.1 + animationValue * 2 * pi;
      
      // Add stereo spread effect
      final spreadOffset = isLeftChannel ? -stereoSpread * 0.5 : stereoSpread * 0.5;
      final y = centerY + sin(time + spreadOffset) * amplitude * (1.0 - wetDryMix * 0.3);
      
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawAdvancedEchoSignals(Canvas canvas, Size size) {
    final delayPixels = delayTime * size.width * 0.8;
    final echoCount = (feedback * 6).round() + 1;

    for (int echo = 1; echo <= echoCount; echo++) {
      final amplitude = pow(feedback, echo) * wetDryMix;
      final delay = delayPixels * echo;
      
      if (delay > size.width) break;

      // Ping-pong effect: alternate between channels
      final isPingPongLeft = pingPong > 0.5 ? (echo % 2 == 1) : true;
      final channelY = isPingPongLeft ? size.height * 0.25 : size.height * 0.75;
      
      final paint = Paint()
        ..color = (isPingPongLeft ? AppTheme.warningColor : AppTheme.errorColor)
            .withOpacity(amplitude * 0.8)
        ..strokeWidth = 2.0 - (echo * 0.2)
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(delay, channelY);

      for (int i = 0; i <= 50; i++) {
        final x = delay + (i / 50) * (size.width - delay) * 0.5;
        if (x > size.width) break;
        
        final time = i * 0.2 + animationValue * 2 * pi;
        final echoAmplitude = amplitude * size.height * 0.1;
        
        // Apply frequency filtering to echo
        final filterEffect = _calculateFilterEffect(i / 50.0);
        final y = channelY + sin(time) * echoAmplitude * filterEffect;
        
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
      
      // Draw echo reflection indicators
      _drawEchoReflection(canvas, size, delay, channelY, amplitude, echo);
    }
  }
  
  double _calculateFilterEffect(double normalizedPos) {
    // Simulate high and low cut filters
    double effect = 1.0;
    
    if (normalizedPos > highCut) {
      effect *= (1.0 - (normalizedPos - highCut) * 2).clamp(0.0, 1.0);
    }
    
    if (normalizedPos < lowCut) {
      effect *= (normalizedPos / lowCut).clamp(0.0, 1.0);
    }
    
    return effect;
  }
  
  void _drawEchoReflection(Canvas canvas, Size size, double x, double y, double amplitude, int echoIndex) {
    final reflectionPaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(amplitude * 0.4)
      ..style = PaintingStyle.fill;
    
    final radius = 3.0 + amplitude * 5.0;
    
    // Draw reflection point
    canvas.drawCircle(Offset(x, y), radius, reflectionPaint);
    
    // Draw ripple effect
    for (int i = 1; i <= 3; i++) {
      final ripplePaint = Paint()
        ..color = AppTheme.accentColor.withOpacity(amplitude * 0.2 / i)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(
        Offset(x, y),
        radius + (i * 8.0 * animationValue),
        ripplePaint,
      );
    }
  }

  void _drawEnhancedModulation(Canvas canvas, Size size) {
    if (modulation <= 0) return;

    // Draw modulation LFO
    final lfoPath = Path();
    lfoPath.moveTo(0, size.height * 0.9);

    for (int i = 0; i <= 100; i++) {
      final x = (i / 100) * size.width;
      final time = i * 0.1 + animationValue * 4 * pi;
      final y = size.height * 0.9 + sin(time) * size.height * 0.05 * modulation;
      lfoPath.lineTo(x, y);
    }

    final lfoPaint = Paint()
      ..color = AppTheme.warningColor.withOpacity(modulation * 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(lfoPath, lfoPaint);
    
    // Draw modulation effect on delay time
    _drawDelayModulation(canvas, size);
  }
  
  void _drawDelayModulation(Canvas canvas, Size size) {
    final modulationAmount = modulation * 0.2;
    final baseDelay = delayTime * size.width * 0.8;
    
    for (int i = 0; i < 5; i++) {
      final time = animationValue * 2 * pi + i;
      final modulatedDelay = baseDelay + sin(time) * modulationAmount * size.width;
      
      if (modulatedDelay > 0 && modulatedDelay < size.width) {
        final modulationPaint = Paint()
          ..color = AppTheme.warningColor.withOpacity(0.3)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(
          Offset(modulatedDelay, 0),
          Offset(modulatedDelay, size.height),
          modulationPaint,
        );
      }
    }
  }
  
  void _drawParameterIndicators(Canvas canvas, Size size) {
    // Draw parameter value bars at the bottom
    final indicators = [
      {'label': 'Delay', 'value': delayTime, 'color': AppTheme.accentColor, 'x': 0.1},
      {'label': 'Feedback', 'value': feedback, 'color': AppTheme.warningColor, 'x': 0.3},
      {'label': 'Mix', 'value': wetDryMix, 'color': AppTheme.successColor, 'x': 0.5},
      {'label': 'Mod', 'value': modulation, 'color': AppTheme.errorColor, 'x': 0.7},
      {'label': 'Spread', 'value': stereoSpread, 'color': AppTheme.accentColor, 'x': 0.9},
    ];
    
    for (final indicator in indicators) {
      final x = size.width * (indicator['x'] as double);
      final value = indicator['value'] as double;
      final color = indicator['color'] as Color;
      final label = indicator['label'] as String;
      
      // Draw parameter bar
      final barHeight = size.height * 0.06;
      final barY = size.height * 0.02;
      
      // Background bar
      final bgPaint = Paint()
        ..color = AppTheme.borderColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 8, barY, 16, barHeight),
          Radius.circular(2),
        ),
        bgPaint,
      );
      
      // Value bar
      final valuePaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 8, barY + barHeight * (1 - value), 16, barHeight * value),
          Radius.circular(2),
        ),
        valuePaint,
      );
      
      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 7,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, barY + barHeight + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! EchoWaveformPainter) return true;
    return oldDelegate.delayTime != delayTime ||
           oldDelegate.feedback != feedback ||
           oldDelegate.wetDryMix != wetDryMix ||
           oldDelegate.modulation != modulation ||
           oldDelegate.isBypassed != isBypassed ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.stereoSpread != stereoSpread ||
           oldDelegate.pingPong != pingPong ||
           oldDelegate.highCut != highCut ||
           oldDelegate.lowCut != lowCut;
  }
}

class CustomEchoSliderThumb extends SliderComponentShape {
  final Color color;
  final double radius;

  CustomEchoSliderThumb(this.color, {this.radius = 12.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 4, glowPaint);

    // Main thumb
    final thumbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, thumbPaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.6, highlightPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, borderPaint);
  }
}