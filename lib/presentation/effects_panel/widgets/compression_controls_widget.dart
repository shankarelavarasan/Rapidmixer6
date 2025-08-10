import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';
import '../../../core/app_export.dart';

class CompressionControlsWidget extends StatefulWidget {
  final bool isBypassed;
  final Function(String, double) onCompressionChange;
  final VoidCallback onReset;
  final VoidCallback? onBypassToggle;

  const CompressionControlsWidget({
    super.key,
    required this.isBypassed,
    required this.onCompressionChange,
    required this.onReset,
    this.onBypassToggle,
  });

  @override
  State<CompressionControlsWidget> createState() => _CompressionControlsWidgetState();
}

class _CompressionControlsWidgetState extends State<CompressionControlsWidget>
    with TickerProviderStateMixin {
  // Core compression parameters
  double _threshold = 0.7; // -6dB
  double _ratio = 0.4; // 4:1
  double _attack = 0.3; // 3ms
  double _release = 0.5; // 50ms
  double _makeupGain = 0.2; // +2dB
  double _knee = 0.3; // Soft knee
  
  // Advanced parameters
  double _lookAhead = 0.1;
  double _sidechain = 0.0;
  
  // UI state
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showGainReduction = false;
  String _selectedPreset = 'Vocal';
  
  // Compression presets
  final List<Map<String, dynamic>> _compressionPresets = [
    {
      'name': 'Vocal',
      'threshold': 0.7,
      'ratio': 0.4,
      'attack': 0.2,
      'release': 0.4,
      'makeupGain': 0.3,
      'knee': 0.4,
      'lookAhead': 0.1,
      'sidechain': 0.0,
    },
    {
      'name': 'Drums',
      'threshold': 0.6,
      'ratio': 0.6,
      'attack': 0.1,
      'release': 0.2,
      'makeupGain': 0.4,
      'knee': 0.2,
      'lookAhead': 0.05,
      'sidechain': 0.0,
    },
    {
      'name': 'Bass',
      'threshold': 0.8,
      'ratio': 0.3,
      'attack': 0.4,
      'release': 0.6,
      'makeupGain': 0.2,
      'knee': 0.5,
      'lookAhead': 0.2,
      'sidechain': 0.0,
    },
    {
      'name': 'Master',
      'threshold': 0.9,
      'ratio': 0.2,
      'attack': 0.3,
      'release': 0.5,
      'makeupGain': 0.1,
      'knee': 0.6,
      'lookAhead': 0.15,
      'sidechain': 0.0,
    },
    {
      'name': 'Limiter',
      'threshold': 0.95,
      'ratio': 1.0,
      'attack': 0.05,
      'release': 0.1,
      'makeupGain': 0.0,
      'knee': 0.0,
      'lookAhead': 0.3,
      'sidechain': 0.0,
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
            if (_showGainReduction) ...[
              _buildGainReductionMeter(),
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
                'Professional Compressor',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Dynamic Range Control',
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
                    _showGainReduction = !_showGainReduction;
                  });
                },
                icon: Icon(
                  _showGainReduction ? Icons.visibility_off : Icons.visibility,
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
            'Compression Presets',
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
              itemCount: _compressionPresets.length,
              itemBuilder: (context, index) {
                final preset = _compressionPresets[index];
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

  Widget _buildGainReductionMeter() {
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
            'Gain Reduction Meter',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 15.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: CustomPaint(
              painter: GainReductionMeterPainter(
                _threshold,
                _ratio,
                _makeupGain,
                widget.isBypassed,
              ),
              size: Size.infinite,
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
            'Compression Parameters',
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
                  'Threshold',
                  _threshold,
                  0.0,
                  1.0,
                  Icons.horizontal_rule,
                  AppTheme.errorColor,
                  (value) {
                    setState(() {
                      _threshold = value;
                    });
                    widget.onCompressionChange('threshold', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Ratio',
                  _ratio,
                  0.0,
                  1.0,
                  Icons.compress,
                  AppTheme.warningColor,
                  (value) {
                    setState(() {
                      _ratio = value;
                    });
                    widget.onCompressionChange('ratio', value);
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
                  'Attack',
                  _attack,
                  0.0,
                  1.0,
                  Icons.flash_on,
                  AppTheme.accentColor,
                  (value) {
                    setState(() {
                      _attack = value;
                    });
                    widget.onCompressionChange('attack', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Release',
                  _release,
                  0.0,
                  1.0,
                  Icons.flash_off,
                  AppTheme.successColor,
                  (value) {
                    setState(() {
                      _release = value;
                    });
                    widget.onCompressionChange('release', value);
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
                  'Makeup Gain',
                  _makeupGain,
                  0.0,
                  1.0,
                  Icons.volume_up,
                  AppTheme.accentColor,
                  (value) {
                    setState(() {
                      _makeupGain = value;
                    });
                    widget.onCompressionChange('makeupGain', value);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildEnhancedParameterSlider(
                  'Knee',
                  _knee,
                  0.0,
                  1.0,
                  Icons.tune,
                  AppTheme.warningColor,
                  (value) {
                    setState(() {
                      _knee = value;
                    });
                    widget.onCompressionChange('knee', value);
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
      case 'Threshold':
        displayValue = '${(-60 + (value * 60)).toInt()}';
        unit = 'dB';
        break;
      case 'Ratio':
        final ratioValue = 1 + (value * 19); // 1:1 to 20:1
        displayValue = '${ratioValue.toStringAsFixed(1)}:1';
        unit = '';
        break;
      case 'Attack':
        displayValue = '${(0.1 + (value * 99.9)).toStringAsFixed(1)}';
        unit = 'ms';
        break;
      case 'Release':
        displayValue = '${(10 + (value * 990)).toInt()}';
        unit = 'ms';
        break;
      case 'Makeup Gain':
        displayValue = '${(value * 20).toStringAsFixed(1)}';
        unit = 'dB';
        break;
      case 'Knee':
        displayValue = '${(value * 10).toStringAsFixed(1)}';
        unit = 'dB';
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
              thumbShape: CustomCompressionSliderThumb(accentColor),
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
                    _threshold = 0.7;
                    _ratio = 0.4;
                    _attack = 0.3;
                    _release = 0.5;
                    _makeupGain = 0.2;
                    _knee = 0.3;
                    _lookAhead = 0.1;
                    _sidechain = 0.0;
                  });
                  widget.onReset();
                },
              ),
              _buildControlButton(
                'Auto',
                Icons.auto_fix_high,
                AppTheme.successColor,
                () {
                  // Auto compression adjustment logic
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
                      'Look-ahead',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: CustomCompressionSliderThumb(AppTheme.accentColor),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                      ),
                      child: Slider(
                        value: _lookAhead,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() {
                            _lookAhead = value;
                          });
                          widget.onCompressionChange('lookAhead', value);
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
                      'Sidechain',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: CustomCompressionSliderThumb(AppTheme.successColor),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                      ),
                      child: Slider(
                        value: _sidechain,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) {
                          setState(() {
                            _sidechain = value;
                          });
                          widget.onCompressionChange('sidechain', value);
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
      case 'Drums':
        return Icons.album;
      case 'Bass':
        return Icons.graphic_eq;
      case 'Master':
        return Icons.tune;
      case 'Limiter':
        return Icons.block;
      default:
        return Icons.compress;
    }
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _threshold = preset['threshold'];
      _ratio = preset['ratio'];
      _attack = preset['attack'];
      _release = preset['release'];
      _makeupGain = preset['makeupGain'];
      _knee = preset['knee'];
      _lookAhead = preset['lookAhead'];
      _sidechain = preset['sidechain'];
      _selectedPreset = preset['name'];
    });

    // Notify parent of all parameter changes
    widget.onCompressionChange('threshold', _threshold);
    widget.onCompressionChange('ratio', _ratio);
    widget.onCompressionChange('attack', _attack);
    widget.onCompressionChange('release', _release);
    widget.onCompressionChange('makeupGain', _makeupGain);
    widget.onCompressionChange('knee', _knee);
    widget.onCompressionChange('lookAhead', _lookAhead);
    widget.onCompressionChange('sidechain', _sidechain);
  }
}

class GainReductionMeterPainter extends CustomPainter {
  final double threshold;
  final double ratio;
  final double makeupGain;
  final bool isBypassed;

  GainReductionMeterPainter(
    this.threshold,
    this.ratio,
    this.makeupGain,
    this.isBypassed,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (isBypassed) {
      _drawBypassedState(canvas, size);
      return;
    }

    _drawMeterBackground(canvas, size);
    _drawGainReductionBars(canvas, size);
    _drawThresholdLine(canvas, size);
    _drawLabels(canvas, size);
  }

  void _drawBypassedState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'BYPASSED',
        style: TextStyle(
          color: AppTheme.textSecondary.withOpacity(0.7),
          fontSize: 14,
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

  void _drawMeterBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryDark.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 1; i < 10; i++) {
      final y = (i / 10) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawGainReductionBars(Canvas canvas, Size size) {
    final random = Random(42);
    final barWidth = size.width / 50;

    for (int i = 0; i < 50; i++) {
      final x = i * barWidth;
      final inputLevel = random.nextDouble();
      final gainReduction = _calculateGainReduction(inputLevel);
      final barHeight = gainReduction * size.height;

      final paint = Paint()
        ..color = _getBarColor(gainReduction)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(x, size.height - barHeight, barWidth - 1, barHeight),
        paint,
      );
    }
  }

  void _drawThresholdLine(Canvas canvas, Size size) {
    final y = size.height * (1 - threshold);
    final paint = Paint()
      ..color = AppTheme.errorColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'GR',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, 5));
  }

  double _calculateGainReduction(double inputLevel) {
    if (inputLevel < threshold || inputLevel <= 0.0) return 0.0;
    
    final overThreshold = inputLevel - threshold;
    final safeRatio = ratio.isFinite ? ratio.clamp(0.0, 20.0) : 1.0;
    final compressionFactor = 1 + safeRatio * 9;
    final compressedLevel = compressionFactor > 0 ? overThreshold / compressionFactor : 0.0;
    final gainReduction = (overThreshold - compressedLevel) / inputLevel;
    
    return gainReduction.isFinite ? gainReduction.clamp(0.0, 1.0) : 0.0;
  }

  Color _getBarColor(double gainReduction) {
    if (gainReduction < 0.2) return AppTheme.successColor;
    if (gainReduction < 0.5) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CustomCompressionSliderThumb extends SliderComponentShape {
  final Color color;
  final double radius;

  CustomCompressionSliderThumb(this.color, {this.radius = 12.0});

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