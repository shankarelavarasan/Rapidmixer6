import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'dart:math';

import '../../../core/app_export.dart';

class ReverbControlsWidget extends StatefulWidget {
  final Function(String parameter, double value) onReverbChange;
  final VoidCallback onReset;
  final bool isBypassed;
  final VoidCallback onBypassToggle;

  const ReverbControlsWidget({
    super.key,
    required this.onReverbChange,
    required this.onReset,
    required this.isBypassed,
    required this.onBypassToggle,
  });

  @override
  State<ReverbControlsWidget> createState() => _ReverbControlsWidgetState();
}

class _ReverbControlsWidgetState extends State<ReverbControlsWidget>
    with TickerProviderStateMixin {
  double _roomSize = 0.5;
  double _decayTime = 0.3;
  double _wetDryMix = 0.2;
  double _damping = 0.4;
  double _predelay = 0.1;
  double _diffusion = 0.7;
  String _selectedPreset = 'Studio';
  bool _showVisualization = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Timer _impulseTimer;
  List<double> _impulseResponse = [];

  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Studio',
      'roomSize': 0.3,
      'decayTime': 0.2,
      'wetDryMix': 0.15,
      'damping': 0.5,
      'predelay': 0.05,
      'diffusion': 0.6
    },
    {
      'name': 'Hall',
      'roomSize': 0.8,
      'decayTime': 0.7,
      'wetDryMix': 0.3,
      'damping': 0.3,
      'predelay': 0.15,
      'diffusion': 0.8
    },
    {
      'name': 'Plate',
      'roomSize': 0.4,
      'decayTime': 0.4,
      'wetDryMix': 0.25,
      'damping': 0.6,
      'predelay': 0.02,
      'diffusion': 0.9
    },
    {
      'name': 'Spring',
      'roomSize': 0.2,
      'decayTime': 0.1,
      'wetDryMix': 0.1,
      'damping': 0.8,
      'predelay': 0.01,
      'diffusion': 0.4
    },
    {
      'name': 'Cathedral',
      'roomSize': 0.95,
      'decayTime': 0.9,
      'wetDryMix': 0.4,
      'damping': 0.2,
      'predelay': 0.25,
      'diffusion': 0.85
    },
    {
      'name': 'Room',
      'roomSize': 0.25,
      'decayTime': 0.15,
      'wetDryMix': 0.12,
      'damping': 0.7,
      'predelay': 0.03,
      'diffusion': 0.5
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    
    // Generate initial impulse response
    _generateImpulseResponse();
    
    // Set up periodic impulse response updates
    _impulseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        _generateImpulseResponse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _impulseTimer.cancel();
    super.dispose();
  }
  
  void _generateImpulseResponse() {
    final random = Random();
    final length = 128;
    final newResponse = <double>[];
    
    for (int i = 0; i < length; i++) {
      final normalizedTime = i / length;
      
      // Generate impulse response based on current parameters
      final decay = exp(-normalizedTime * (_decayTime * 10) * (1 + _damping));
      final diffusionNoise = (random.nextDouble() - 0.5) * _diffusion * 0.4;
      final roomReflection = sin(normalizedTime * pi * _roomSize * 4) * 0.3;
      
      final amplitude = decay * (1.0 + diffusionNoise + roomReflection);
      newResponse.add(amplitude.clamp(-1.0, 1.0));
    }
    
    if (mounted) {
      setState(() {
        _impulseResponse = newResponse;
      });
    }
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
              AppTheme.primaryDark.withOpacity(0.95),
              AppTheme.secondaryDark.withOpacity(0.9),
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
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEnhancedHeader(),
            SizedBox(height: 2.h),
            _buildEnhancedPresetSelector(),
            SizedBox(height: 2.h),
            if (_showVisualization) ...[
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return _buildReverbVisualization();
                },
              ),
              SizedBox(height: 2.h),
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
            AppTheme.accentColor.withOpacity(0.15),
            AppTheme.secondaryDark.withOpacity(0.8),
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
                'Professional Reverb',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Algorithmic Spatial Processing',
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
                    _showVisualization = !_showVisualization;
                  });
                },
                icon: Icon(
                  _showVisualization ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.accentColor,
                  size: 5.w,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark.withOpacity(0.5),
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
                      AppTheme.accentColor.withOpacity(0.2),
                      AppTheme.primaryDark.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Switch(
                  value: !widget.isBypassed,
                  onChanged: (value) => widget.onBypassToggle(),
                  activeColor: AppTheme.accentColor,
                  inactiveThumbColor: AppTheme.textSecondary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPresetSelector() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.secondaryDark.withOpacity(0.4),
            AppTheme.primaryDark.withOpacity(0.6),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reverb Presets',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _selectedPreset,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 8.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final isSelected = _selectedPreset == preset['name'];

                return Container(
                  margin: EdgeInsets.only(right: 2.w),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
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
                                AppTheme.secondaryDark.withOpacity(0.6),
                                AppTheme.primaryDark.withOpacity(0.8),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.accentColor.withOpacity(0.8)
                            : AppTheme.borderColor.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.accentColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: InkWell(
                      onTap: widget.isBypassed
                          ? null
                          : () => _applyPreset(preset),
                      borderRadius: BorderRadius.circular(10),
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
                            style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                              color: isSelected
                                  ? AppTheme.accentColor
                                  : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildReverbVisualization() {
    return Container(
      height: 20.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryDark.withOpacity(0.9),
            AppTheme.secondaryDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              CustomPaint(
                painter: EnhancedReverbVisualizationPainter(
                  _roomSize,
                  _decayTime,
                  _wetDryMix,
                  _damping,
                  _diffusion,
                  widget.isBypassed,
                  animationValue: _fadeAnimation.value,
                  impulseResponse: _impulseResponse,
                ),
                child: Container(),
              ),
            Positioned(
              top: 2.w,
              left: 2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Reverb Response',
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedParameterControls() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.secondaryDark.withOpacity(0.3),
            AppTheme.primaryDark.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Room Size',
                  _roomSize,
                  0.0,
                  1.0,
                  Icons.home,
                  AppTheme.successColor,
                  (value) {
                    setState(() => _roomSize = value);
                    widget.onReverbChange('roomSize', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Decay Time',
                  _decayTime,
                  0.0,
                  1.0,
                  Icons.timer,
                  AppTheme.warningColor,
                  (value) {
                    setState(() => _decayTime = value);
                    widget.onReverbChange('decayTime', value);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Wet/Dry Mix',
                  _wetDryMix,
                  0.0,
                  1.0,
                  Icons.water_drop,
                  AppTheme.accentColor,
                  (value) {
                    setState(() => _wetDryMix = value);
                    widget.onReverbChange('wetDryMix', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Damping',
                  _damping,
                  0.0,
                  1.0,
                  Icons.tune,
                  AppTheme.errorColor,
                  (value) {
                    setState(() => _damping = value);
                    widget.onReverbChange('damping', value);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Pre-delay',
                  _predelay,
                  0.0,
                  0.5,
                  Icons.schedule,
                  AppTheme.successColor,
                  (value) {
                    setState(() => _predelay = value);
                    widget.onReverbChange('predelay', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Diffusion',
                  _diffusion,
                  0.0,
                  1.0,
                  Icons.blur_on,
                  AppTheme.warningColor,
                  (value) {
                    setState(() => _diffusion = value);
                    widget.onReverbChange('diffusion', value);
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
    final percentage = ((value - min) / (max - min) * 100).toInt();
    
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
                  '$percentage%',
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
              thumbShape: CustomReverbSliderThumb(accentColor),
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
                    _roomSize = 0.5;
                    _decayTime = 0.3;
                    _wetDryMix = 0.2;
                    _damping = 0.4;
                    _predelay = 0.1;
                    _diffusion = 0.6;
                  });
                  widget.onReset();
                },
              ),
              _buildControlButton(
                'Auto',
                Icons.auto_fix_high,
                AppTheme.successColor,
                () {
                  // Auto reverb adjustment logic
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
                      'Early Reflections',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: CustomReverbSliderThumb(AppTheme.accentColor),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                      ),
                      child: Slider(
                        value: _predelay,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() {
                            _predelay = value;
                          });
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
                      'Spatial Width',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: CustomReverbSliderThumb(AppTheme.successColor),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                      ),
                      child: Slider(
                        value: _diffusion,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() {
                            _diffusion = value;
                          });
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

  void _showVisualizationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Reverb Visualization',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Container(
          width: 80.w,
          height: 30.h,
          child: CustomPaint(
            painter:
                ReverbVisualizationPainter(_roomSize, _decayTime, _wetDryMix),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getPresetIcon(String presetName) {
    switch (presetName) {
      case 'Studio':
        return Icons.mic;
      case 'Hall':
        return Icons.account_balance;
      case 'Plate':
        return Icons.rectangle;
      case 'Spring':
        return Icons.waves;
      case 'Cathedral':
        return Icons.church;
      case 'Room':
        return Icons.home;
      default:
        return Icons.music_note;
    }
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _roomSize = preset['roomSize'];
      _decayTime = preset['decayTime'];
      _wetDryMix = preset['wetDryMix'];
      _damping = preset['damping'];
      _predelay = preset['predelay'];
      _diffusion = preset['diffusion'];
      _selectedPreset = preset['name'];
    });

    // Notify parent of all parameter changes
    widget.onReverbChange('roomSize', _roomSize);
    widget.onReverbChange('decayTime', _decayTime);
    widget.onReverbChange('wetDryMix', _wetDryMix);
    widget.onReverbChange('damping', _damping);
    widget.onReverbChange('predelay', _predelay);
    widget.onReverbChange('diffusion', _diffusion);
  }
}

class ReverbVisualizationPainter extends CustomPainter {
  final double roomSize;
  final double decayTime;
  final double wetDryMix;

  ReverbVisualizationPainter(this.roomSize, this.decayTime, this.wetDryMix);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw decay curve
    final path = Path();
    path.moveTo(0, size.height * 0.2);

    for (int i = 0; i <= 100; i++) {
      final x = (i / 100) * size.width;
      final decay = 1.0 - (i / 100) * decayTime;
      final y = size.height * 0.2 + (size.height * 0.6) * (1 - decay);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw room size indicator
    final roomPaint = Paint()
      ..color = AppTheme.successColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * roomSize, size.height * 0.1),
      roomPaint,
    );

    // Draw wet/dry mix indicator
    final mixPaint = Paint()
      ..color = AppTheme.warningColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
          0, size.height * 0.9, size.width * wetDryMix, size.height * 0.1),
      mixPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! ReverbVisualizationPainter) return true;
    return oldDelegate.roomSize != roomSize ||
           oldDelegate.decayTime != decayTime ||
           oldDelegate.wetDryMix != wetDryMix;
  }
}

class EnhancedReverbVisualizationPainter extends CustomPainter {
  final double roomSize;
  final double decayTime;
  final double wetDryMix;
  final double damping;
  final double diffusion;
  final bool isBypassed;
  final double animationValue;
  final List<double> impulseResponse;

  EnhancedReverbVisualizationPainter(
    this.roomSize,
    this.decayTime,
    this.wetDryMix,
    this.damping,
    this.diffusion,
    this.isBypassed, {
    this.animationValue = 1.0,
    this.impulseResponse = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background gradient
    _drawBackground(canvas, size);
    
    if (isBypassed) {
      _drawBypassedState(canvas, size);
      return;
    }

    // Draw 3D room visualization
    _draw3DRoom(canvas, size);
    
    // Draw impulse response
    _drawImpulseResponse(canvas, size);
    
    // Draw frequency response
    _drawFrequencyResponse(canvas, size);
    
    // Draw real-time parameter indicators
    _drawParameterIndicators(canvas, size);
    
    // Draw spatial indicators
    _drawSpatialIndicators(canvas, size);
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
  }

  void _draw3DRoom(Canvas canvas, Size size) {
    final roomPaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Calculate room dimensions based on roomSize
    final roomWidth = size.width * 0.6 * roomSize;
    final roomHeight = size.height * 0.4 * roomSize;
    final roomDepth = roomWidth * 0.6;
    
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.3;
    
    // Draw 3D room using isometric projection
    final frontRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: roomWidth,
      height: roomHeight,
    );
    
    // Draw room walls with perspective
    final path = Path();
    
    // Front face
    path.addRect(frontRect);
    
    // Right wall (perspective)
    path.moveTo(frontRect.right, frontRect.top);
    path.lineTo(frontRect.right + roomDepth * 0.3, frontRect.top - roomDepth * 0.2);
    path.lineTo(frontRect.right + roomDepth * 0.3, frontRect.bottom - roomDepth * 0.2);
    path.lineTo(frontRect.right, frontRect.bottom);
    path.close();
    
    // Top face (perspective)
    path.moveTo(frontRect.left, frontRect.top);
    path.lineTo(frontRect.left + roomDepth * 0.3, frontRect.top - roomDepth * 0.2);
    path.lineTo(frontRect.right + roomDepth * 0.3, frontRect.top - roomDepth * 0.2);
    path.lineTo(frontRect.right, frontRect.top);
    path.close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, roomPaint);
    
    // Draw sound source
    final sourcePaint = Paint()
      ..color = AppTheme.successColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(centerX - roomWidth * 0.3, centerY),
      4 * animationValue,
      sourcePaint,
    );
    
    // Draw sound waves
    _drawSoundWaves(canvas, size, centerX - roomWidth * 0.3, centerY);
  }

  void _drawSoundWaves(Canvas canvas, Size size, double sourceX, double sourceY) {
    final wavePaint = Paint()
      ..color = AppTheme.successColor.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 4; i++) {
      final radius = i * 15.0 * animationValue * (1.0 + wetDryMix);
      final opacity = (1.0 - (i / 4.0)) * 0.6;
      
      final paint = Paint()
        ..color = AppTheme.successColor.withOpacity(opacity)
        ..strokeWidth = 2.0 - (i * 0.3)
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(Offset(sourceX, sourceY), radius, paint);
    }
  }

  void _drawImpulseResponse(Canvas canvas, Size size) {
    if (impulseResponse.isEmpty) {
      // Generate synthetic impulse response
      _drawSyntheticImpulseResponse(canvas, size);
      return;
    }
    
    final paint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final baseY = size.height * 0.7;
    
    for (int i = 0; i < impulseResponse.length; i++) {
      final x = (i / impulseResponse.length) * size.width;
      final amplitude = impulseResponse[i] * animationValue;
      final y = baseY - (amplitude * size.height * 0.2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawSyntheticImpulseResponse(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final baseY = size.height * 0.7;
    path.moveTo(0, baseY);

    for (int i = 0; i <= 100; i++) {
      final x = (i / 100) * size.width;
      final normalizedTime = i / 100;
      
      // Calculate decay with damping influence
      final dampedDecay = exp(-normalizedTime * (decayTime * 8) * (1 + damping));
      final diffusionNoise = (Random(i).nextDouble() - 0.5) * diffusion * 0.3;
      final amplitude = dampedDecay * (1.0 + diffusionNoise) * animationValue;
      final y = baseY - (amplitude * size.height * 0.15);
      
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Fill area under curve
    final fillPaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, baseY);
    fillPath.lineTo(0, baseY);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawFrequencyResponse(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.successColor.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    for (int i = 0; i <= 50; i++) {
      final x = (i / 50) * size.width;
      final freq = i / 50;
      
      // Simulate frequency response based on damping
      final response = 1.0 - (freq * damping * 0.5);
      final y = size.height * 0.8 - (size.height * 0.1) * response;
      
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawParameterIndicators(Canvas canvas, Size size) {
    // Draw parameter value indicators
    final indicators = [
      {'label': 'Room', 'value': roomSize, 'color': AppTheme.warningColor, 'x': 0.1},
      {'label': 'Decay', 'value': decayTime, 'color': AppTheme.errorColor, 'x': 0.3},
      {'label': 'Mix', 'value': wetDryMix, 'color': AppTheme.accentColor, 'x': 0.5},
      {'label': 'Damp', 'value': damping, 'color': AppTheme.successColor, 'x': 0.7},
      {'label': 'Diff', 'value': diffusion, 'color': AppTheme.warningColor, 'x': 0.9},
    ];
    
    for (final indicator in indicators) {
      final x = size.width * (indicator['x'] as double);
      final value = indicator['value'] as double;
      final color = indicator['color'] as Color;
      final label = indicator['label'] as String;
      
      // Draw parameter bar
      final barHeight = size.height * 0.08;
      final barY = size.height * 0.88;
      
      // Background bar
      final bgPaint = Paint()
        ..color = AppTheme.borderColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 15, barY, 30, barHeight),
          Radius.circular(4),
        ),
        bgPaint,
      );
      
      // Value bar
      final valuePaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 15, barY + barHeight * (1 - value), 30, barHeight * value),
          Radius.circular(4),
        ),
        valuePaint,
      );
      
      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, barY - 15),
      );
    }
  }

  void _drawSpatialIndicators(Canvas canvas, Size size) {
    // Enhanced diffusion visualization
    final diffusionPaint = Paint()
      ..color = AppTheme.successColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent pattern
    final dotCount = (diffusion * 30 * animationValue).round();
    
    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * 0.15 + random.nextDouble() * size.height * 0.5;
      final radius = 1.0 + random.nextDouble() * 2.0;
      
      canvas.drawCircle(Offset(x, y), radius, diffusionPaint);
    }
    
    // Draw reflection paths
    _drawReflectionPaths(canvas, size);
  }

  void _drawReflectionPaths(Canvas canvas, Size size) {
    final reflectionPaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerX = size.width * 0.5;
    final centerY = size.height * 0.3;
    final sourceX = centerX - size.width * 0.15;
    final sourceY = centerY;
    
    // Draw reflection paths based on room size and diffusion
    final pathCount = (roomSize * 8).round();
    
    for (int i = 0; i < pathCount; i++) {
      final angle = (i / pathCount) * 2 * pi;
      final distance = roomSize * size.width * 0.3;
      
      final endX = sourceX + cos(angle) * distance;
      final endY = sourceY + sin(angle) * distance * 0.6; // Flatten for perspective
      
      // Add some randomness based on diffusion
      final diffusionOffset = (Random(i).nextDouble() - 0.5) * diffusion * 20;
      
      canvas.drawLine(
        Offset(sourceX, sourceY),
        Offset(endX + diffusionOffset, endY),
        reflectionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! EnhancedReverbVisualizationPainter) return true;
    return oldDelegate.roomSize != roomSize ||
           oldDelegate.decayTime != decayTime ||
           oldDelegate.wetDryMix != wetDryMix ||
           oldDelegate.damping != damping ||
           oldDelegate.diffusion != diffusion ||
           oldDelegate.isBypassed != isBypassed ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.impulseResponse != impulseResponse;
  }
}

class CustomReverbSliderThumb extends SliderComponentShape {
  final Color color;
  final double radius;

  CustomReverbSliderThumb(this.color, {this.radius = 12.0});

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
