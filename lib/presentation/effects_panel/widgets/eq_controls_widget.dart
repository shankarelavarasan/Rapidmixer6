import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class EqControlsWidget extends StatefulWidget {
  final Function(String frequency, double gain) onEqChange;
  final VoidCallback onReset;
  final bool isBypassed;
  final VoidCallback onBypassToggle;

  const EqControlsWidget({
    super.key,
    required this.onEqChange,
    required this.onReset,
    required this.isBypassed,
    required this.onBypassToggle,
  });

  @override
  State<EqControlsWidget> createState() => _EqControlsWidgetState();
}

class _EqControlsWidgetState extends State<EqControlsWidget>
    with TickerProviderStateMixin {
  final Map<String, double> _eqValues = {
    '60Hz': 0.0,
    '170Hz': 0.0,
    '350Hz': 0.0,
    '1kHz': 0.0,
    '3.5kHz': 0.0,
    '10kHz': 0.0,
    '16kHz': 0.0,
  };

  late AnimationController _animationController;
  late AnimationController _spectrumController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _spectrumAnimation;
  bool _showFrequencyAnalyzer = true;
  String _selectedPreset = 'Flat';
  double _qFactor = 1.0;
  double _gainRange = 12.0;
  List<double> _spectrumData = [];

  final List<Map<String, dynamic>> _eqPresets = [
    {'name': 'Flat', 'values': {'60Hz': 0.0, '170Hz': 0.0, '350Hz': 0.0, '1kHz': 0.0, '3.5kHz': 0.0, '10kHz': 0.0, '16kHz': 0.0}},
    {'name': 'Rock', 'values': {'60Hz': 3.0, '170Hz': 1.0, '350Hz': -2.0, '1kHz': 2.0, '3.5kHz': 4.0, '10kHz': 3.0, '16kHz': 2.0}},
    {'name': 'Pop', 'values': {'60Hz': 1.0, '170Hz': 2.0, '350Hz': 0.0, '1kHz': 1.0, '3.5kHz': 2.0, '10kHz': 3.0, '16kHz': 1.0}},
    {'name': 'Jazz', 'values': {'60Hz': 2.0, '170Hz': 0.0, '350Hz': 1.0, '1kHz': 2.0, '3.5kHz': 1.0, '10kHz': 2.0, '16kHz': 3.0}},
    {'name': 'Classical', 'values': {'60Hz': 0.0, '170Hz': 0.0, '350Hz': 0.0, '1kHz': 0.0, '3.5kHz': 1.0, '10kHz': 2.0, '16kHz': 3.0}},
    {'name': 'Bass Boost', 'values': {'60Hz': 6.0, '170Hz': 4.0, '350Hz': 2.0, '1kHz': 0.0, '3.5kHz': 0.0, '10kHz': 0.0, '16kHz': 0.0}},
    {'name': 'Vocal', 'values': {'60Hz': -2.0, '170Hz': -1.0, '350Hz': 2.0, '1kHz': 4.0, '3.5kHz': 3.0, '10kHz': 1.0, '16kHz': 0.0}},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _spectrumController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _spectrumAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spectrumController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _generateMockSpectrumData();
    _startSpectrumAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _spectrumController.dispose();
    super.dispose();
  }
  
  void _generateMockSpectrumData() {
    // Generate realistic spectrum data for demonstration
    _spectrumData = List.generate(32, (index) {
      final frequency = index / 32.0;
      final baseAmplitude = 0.3 + (0.4 * (1.0 - frequency));
      final randomVariation = (math.Random().nextDouble() - 0.5) * 0.3;
      return math.max(0.0, math.min(1.0, baseAmplitude + randomVariation));
    });
  }
  
  void _startSpectrumAnimation() {
    _spectrumController.repeat();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (mounted && !widget.isBypassed) {
        setState(() {
          _generateMockSpectrumData();
        });
      } else {
        timer.cancel();
      }
    });
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
              AppTheme.primaryDark.withOpacity(0.8),
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
              color: AppTheme.accentColor.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEnhancedHeader(),
            SizedBox(height: 2.h),
            _buildPresetSelector(),
            SizedBox(height: 2.h),
            if (_showFrequencyAnalyzer) ...[
              _buildFrequencyAnalyzer(),
              SizedBox(height: 2.h),
            ],
            _buildEnhancedEqSliders(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional EQ',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                '7-Band Parametric Equalizer',
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
                    _showFrequencyAnalyzer = !_showFrequencyAnalyzer;
                  });
                },
                icon: Icon(
                  _showFrequencyAnalyzer ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      widget.isBypassed ? AppTheme.textSecondary : AppTheme.accentColor,
                      widget.isBypassed ? AppTheme.textSecondary.withOpacity(0.7) : AppTheme.accentColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Switch(
                  value: !widget.isBypassed,
                  onChanged: (value) => widget.onBypassToggle(),
                  activeColor: Colors.white,
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

  Widget _buildPresetSelector() {
    return Container(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _eqPresets.length,
        itemBuilder: (context, index) {
          final preset = _eqPresets[index];
          final isSelected = _selectedPreset == preset['name'];

          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: GestureDetector(
              onTap: widget.isBypassed ? null : () => _applyPreset(preset),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppTheme.accentColor,
                            AppTheme.accentColor.withOpacity(0.8),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            AppTheme.secondaryDark.withOpacity(0.8),
                            AppTheme.secondaryDark.withOpacity(0.6),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentColor.withOpacity(0.5)
                        : AppTheme.borderColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    preset['name'],
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryDark
                          : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrequencyAnalyzer() {
    if (!_showFrequencyAnalyzer) return SizedBox.shrink();
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      height: 20.h,
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
            AnimatedBuilder(
              animation: _spectrumAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: EnhancedFrequencyResponsePainter(
                    _eqValues, 
                    widget.isBypassed,
                    animationValue: _fadeAnimation.value,
                    spectrumData: _spectrumData,
                  ),
                  child: Container(),
                );
              },
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
                  'Frequency Response',
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

  Widget _buildEnhancedEqSliders() {
    return Container(
      height: 30.h,
      padding: EdgeInsets.all(2.w),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _eqValues.keys.map((frequency) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background track
                        Container(
                          width: 4,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.errorColor.withOpacity(0.3),
                                AppTheme.borderColor.withOpacity(0.5),
                                AppTheme.successColor.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Slider
                        RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: CustomSliderThumb(),
                              overlayShape: RoundSliderOverlayShape(overlayRadius: 15),
                              activeTrackColor: widget.isBypassed
                                  ? AppTheme.textSecondary
                                  : AppTheme.accentColor,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: widget.isBypassed
                                  ? AppTheme.textSecondary
                                  : AppTheme.accentColor,
                              overlayColor: AppTheme.accentColor.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _eqValues[frequency]!,
                              min: -12.0,
                              max: 12.0,
                              divisions: 48,
                              onChanged: widget.isBypassed
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _eqValues[frequency] = value;
                                      });
                                      widget.onEqChange(frequency, value);
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _eqValues[frequency]! != 0.0
                          ? AppTheme.accentColor.withOpacity(0.2)
                          : AppTheme.secondaryDark.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _eqValues[frequency]! != 0.0
                            ? AppTheme.accentColor.withOpacity(0.5)
                            : AppTheme.borderColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_eqValues[frequency]!.toStringAsFixed(1)}dB',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: widget.isBypassed
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    frequency,
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
            AppTheme.secondaryDark.withOpacity(0.4),
            AppTheme.primaryDark.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.refresh,
                label: 'Reset',
                onPressed: widget.isBypassed
                    ? null
                    : () {
                        setState(() {
                          _eqValues.updateAll((key, value) => 0.0);
                        });
                        _eqValues.forEach((frequency, value) {
                          widget.onEqChange(frequency, value);
                        });
                      },
              ),
              _buildControlButton(
                icon: Icons.auto_fix_high,
                label: 'Auto EQ',
                onPressed: widget.isBypassed ? null : _autoEQ,
              ),
              _buildControlButton(
                icon: Icons.save_alt,
                label: 'Save',
                onPressed: widget.isBypassed ? null : () {},
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
                      'Q Factor',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: _qFactor,
                        min: 0.1,
                        max: 10.0,
                        divisions: 99,
                        onChanged: widget.isBypassed
                            ? null
                            : (value) {
                                setState(() {
                                  _qFactor = value;
                                });
                              },
                        activeColor: AppTheme.accentColor,
                        inactiveColor: AppTheme.borderColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gain Range',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: _gainRange,
                        min: 6.0,
                        max: 24.0,
                        divisions: 18,
                        onChanged: widget.isBypassed
                            ? null
                            : (value) {
                                setState(() {
                                  _gainRange = value;
                                });
                              },
                        activeColor: AppTheme.warningColor,
                        inactiveColor: AppTheme.borderColor,
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

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isBypassed
                ? AppTheme.secondaryDark.withOpacity(0.3)
                : AppTheme.secondaryDark.withOpacity(0.8),
            foregroundColor: widget.isBypassed
                ? AppTheme.textSecondary
                : AppTheme.textPrimary,
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: AppTheme.borderColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            elevation: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 4.w,
                color: widget.isBypassed
                    ? AppTheme.textSecondary
                    : AppTheme.accentColor,
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: widget.isBypassed
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _selectedPreset = preset['name'];
      final values = preset['values'] as Map<String, double>;
      _eqValues.updateAll((key, value) => values[key] ?? 0.0);
    });
    
    // Notify parent of changes
    _eqValues.forEach((frequency, value) {
      widget.onEqChange(frequency, value);
    });
  }

  void _autoEQ() {
    // Simple auto EQ algorithm - enhance based on common preferences
    setState(() {
      _eqValues['60Hz'] = 2.0;    // Slight bass boost
      _eqValues['170Hz'] = 1.0;   // Warmth
      _eqValues['350Hz'] = 0.0;   // Neutral
      _eqValues['1kHz'] = 1.0;    // Presence
      _eqValues['3.5kHz'] = 2.0;  // Clarity
      _eqValues['10kHz'] = 1.5;   // Air
      _eqValues['16kHz'] = 1.0;   // Sparkle
    });
    
    _eqValues.forEach((frequency, value) {
      widget.onEqChange(frequency, value);
    });
  }
}

class EnhancedFrequencyResponsePainter extends CustomPainter {
  final Map<String, double> eqValues;
  final bool isBypassed;
  final double animationValue;
  final List<double> spectrumData;

  EnhancedFrequencyResponsePainter(
    this.eqValues, 
    this.isBypassed, {
    this.animationValue = 1.0,
    this.spectrumData = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background gradient
    _drawBackground(canvas, size);
    
    // Draw grid lines
    _drawGrid(canvas, size);
    
    // Draw real-time spectrum bars
    _drawSpectrumBars(canvas, size);
    
    // Draw frequency response curve
    _drawFrequencyResponse(canvas, size);
    
    // Draw frequency markers
    _drawFrequencyMarkers(canvas, size);
    
    // Draw gain indicators
    _drawGainIndicators(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryDark.withOpacity(0.1),
          AppTheme.secondaryDark.withOpacity(0.05),
          AppTheme.primaryDark.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.15)
      ..strokeWidth = 0.5;

    final majorGridPaint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Horizontal grid lines (gain levels)
    for (int i = -12; i <= 12; i += 3) {
      final y = size.height / 2 - (i / 12.0) * (size.height / 2);
      final paint = i == 0 ? majorGridPaint : gridPaint;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical grid lines (frequency bands)
    final frequencies = eqValues.keys.toList();
    for (int i = 0; i < frequencies.length; i++) {
      final x = (i / (frequencies.length - 1)) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  void _drawSpectrumBars(Canvas canvas, Size size) {
    if (spectrumData.isEmpty || isBypassed) return;
    
    final barWidth = size.width / spectrumData.length;
    final maxHeight = size.height * 0.3;
    
    for (int i = 0; i < spectrumData.length; i++) {
      final x = i * barWidth;
      final amplitude = spectrumData[i] * animationValue;
      final barHeight = amplitude * maxHeight;
      
      // Create gradient for spectrum bars
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppTheme.accentColor.withOpacity(0.8),
            AppTheme.successColor.withOpacity(0.6),
            AppTheme.warningColor.withOpacity(0.4),
          ],
        ).createShader(Rect.fromLTWH(x, size.height - barHeight, barWidth - 1, barHeight));
      
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - barHeight, barWidth - 1, barHeight),
        barPaint,
      );
    }
  }

  void _drawFrequencyResponse(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isBypassed ? AppTheme.textSecondary : AppTheme.accentColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = (isBypassed ? AppTheme.textSecondary : AppTheme.accentColor).withOpacity(0.2)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isBypassed ? AppTheme.textSecondary : AppTheme.accentColor).withOpacity(0.1),
          (isBypassed ? AppTheme.textSecondary : AppTheme.accentColor).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final shadowPath = Path();
    final fillPath = Path();
    final frequencies = eqValues.keys.toList();

    // Create smooth curve using cubic bezier
    for (int i = 0; i < frequencies.length; i++) {
      final x = (i / (frequencies.length - 1)) * size.width;
      final gain = eqValues[frequencies[i]]! * animationValue;
      final y = size.height / 2 - (gain / 12.0) * (size.height / 2);

      if (i == 0) {
        path.moveTo(x, y);
        shadowPath.moveTo(x, y);
        fillPath.moveTo(x, size.height / 2);
        fillPath.lineTo(x, y);
      } else {
        // Use quadratic bezier for smoother curves
        final prevX = ((i - 1) / (frequencies.length - 1)) * size.width;
        final prevGain = eqValues[frequencies[i - 1]]! * animationValue;
        final prevY = size.height / 2 - (prevGain / 12.0) * (size.height / 2);
        
        final controlX = (prevX + x) / 2;
        final controlY = (prevY + y) / 2;
        
        path.quadraticBezierTo(controlX, controlY, x, y);
        shadowPath.quadraticBezierTo(controlX, controlY, x, y);
        fillPath.quadraticBezierTo(controlX, controlY, x, y);
      }
    }
    
    // Complete fill path
    fillPath.lineTo(size.width, size.height / 2);
    fillPath.close();

    // Draw fill area
    canvas.drawPath(fillPath, fillPaint);
    // Draw shadow
    canvas.drawPath(shadowPath, shadowPaint);
    // Draw main curve
    canvas.drawPath(path, paint);

    // Draw center line (0 dB)
    final centerPaint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke; // Solid line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  void _drawFrequencyMarkers(Canvas canvas, Size size) {
    final frequencies = eqValues.keys.toList();
    
    for (int i = 0; i < frequencies.length; i++) {
      final x = (i / (frequencies.length - 1)) * size.width;
      final gain = eqValues[frequencies[i]]! * animationValue;
      final y = size.height / 2 - (gain / 12.0) * (size.height / 2);
      final isActive = gain.abs() > 0.1;

      // Outer glow for active markers
      if (isActive && !isBypassed) {
        final glowPaint = Paint()
          ..color = AppTheme.accentColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 8, glowPaint);
      }

      // Main marker circle
      final markerPaint = Paint()
        ..color = isBypassed 
            ? AppTheme.textSecondary 
            : (isActive ? AppTheme.accentColor : AppTheme.borderColor)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), isActive ? 5 : 3, markerPaint);
      
      // Inner circle
      final innerPaint = Paint()
        ..color = AppTheme.primaryDark
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), isActive ? 2.5 : 1.5, innerPaint);
      
      // Center dot for active markers
      if (isActive && !isBypassed) {
        final centerPaint = Paint()
          ..color = AppTheme.accentColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 1, centerPaint);
      }
    }
  }

  void _drawGainIndicators(Canvas canvas, Size size) {
    final frequencies = eqValues.keys.toList();
    
    for (int i = 0; i < frequencies.length; i++) {
      final x = (i / (frequencies.length - 1)) * size.width;
      final gain = eqValues[frequencies[i]]! * animationValue;
      
      if (gain.abs() > 0.1 && !isBypassed) {
        final y = size.height / 2 - (gain / 12.0) * (size.height / 2);
        final isBoost = gain > 0;
        
        // Draw gain value text
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${gain.toStringAsFixed(1)}dB',
            style: TextStyle(
              color: isBoost ? AppTheme.successColor : AppTheme.warningColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        final textY = isBoost ? y - 20 : y + 10;
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, textY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! EnhancedFrequencyResponsePainter) return true;
    return oldDelegate.eqValues != eqValues ||
           oldDelegate.isBypassed != isBypassed ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.spectrumData != spectrumData;
  }
}

class CustomSliderThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(24, 24);
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

    // Outer circle (shadow)
    final shadowPaint = Paint()
      ..color = AppTheme.primaryDark.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, shadowPaint);

    // Main circle
    final mainPaint = Paint()
      ..color = sliderTheme.thumbColor ?? AppTheme.accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, mainPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = AppTheme.primaryDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, innerPaint);

    // Center dot
    final centerPaint = Paint()
      ..color = sliderTheme.thumbColor ?? AppTheme.accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2, centerPaint);
  }
}
