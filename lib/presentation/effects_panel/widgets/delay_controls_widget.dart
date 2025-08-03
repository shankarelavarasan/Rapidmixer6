import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DelayControlsWidget extends StatefulWidget {
  final Function(String parameter, double value) onDelayChange;
  final VoidCallback onReset;
  final bool isBypassed;
  final VoidCallback onBypassToggle;

  const DelayControlsWidget({
    super.key,
    required this.onDelayChange,
    required this.onReset,
    required this.isBypassed,
    required this.onBypassToggle,
  });

  @override
  State<DelayControlsWidget> createState() => _DelayControlsWidgetState();
}

class _DelayControlsWidgetState extends State<DelayControlsWidget>
    with TickerProviderStateMixin {
  double _delayTime = 0.25;
  double _feedback = 0.3;
  double _mix = 0.2;
  double _currentBpm = 120.0;
  bool _isTapping = false;
  DateTime? _lastTap;
  List<DateTime> _tapTimes = [];

  late AnimationController _tapAnimationController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _tapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _tapAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _tapAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 3.h),
          _buildTapTempo(),
          SizedBox(height: 3.h),
          _buildParameterControls(),
          SizedBox(height: 2.h),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Delay',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          value: !widget.isBypassed,
          onChanged: (value) => widget.onBypassToggle(),
          activeColor: AppTheme.accentColor,
          inactiveThumbColor: AppTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _buildTapTempo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tap Tempo',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${_currentBpm.toInt()} BPM',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _tapAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _tapAnimation.value,
                child: GestureDetector(
                  onTap: widget.isBypassed ? null : _handleTapTempo,
                  child: Container(
                    width: 20.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: widget.isBypassed
                          ? AppTheme.borderColor
                          : (_isTapping
                              ? AppTheme.accentColor
                              : AppTheme.surfaceColor),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isBypassed
                            ? AppTheme.textSecondary
                            : AppTheme.accentColor,
                        width: 2,
                      ),
                      boxShadow: widget.isBypassed
                          ? null
                          : [
                              BoxShadow(
                                color:
                                    AppTheme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'music_note',
                        color: widget.isBypassed
                            ? AppTheme.textSecondary
                            : (_isTapping
                                ? AppTheme.primaryDark
                                : AppTheme.accentColor),
                        size: 32,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap to set tempo',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterControls() {
    return Column(
      children: [
        _buildParameterSlider(
          'Delay Time',
          _delayTime,
          0.0,
          1.0,
          (value) {
            setState(() => _delayTime = value);
            widget.onDelayChange('delayTime', value);
          },
          unit: 's',
        ),
        SizedBox(height: 2.h),
        _buildParameterSlider(
          'Feedback',
          _feedback,
          0.0,
          0.95,
          (value) {
            setState(() => _feedback = value);
            widget.onDelayChange('feedback', value);
          },
          unit: '%',
        ),
        SizedBox(height: 2.h),
        _buildParameterSlider(
          'Mix',
          _mix,
          0.0,
          1.0,
          (value) {
            setState(() => _mix = value);
            widget.onDelayChange('mix', value);
          },
          unit: '%',
        ),
      ],
    );
  }

  Widget _buildParameterSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String unit = '',
  }) {
    String displayValue;
    if (unit == 's') {
      displayValue = '${(value * 1000).toInt()}ms';
    } else if (unit == '%') {
      displayValue = '${(value * 100).toInt()}%';
    } else {
      displayValue = value.toStringAsFixed(2);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: widget.isBypassed
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
              ),
            ),
            Text(
              displayValue,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: widget.isBypassed
                    ? AppTheme.textSecondary
                    : AppTheme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppTheme.secondaryDark,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: widget.isBypassed ? null : onChanged,
            activeColor: widget.isBypassed
                ? AppTheme.textSecondary
                : AppTheme.accentColor,
            inactiveColor: AppTheme.borderColor,
            thumbColor: widget.isBypassed
                ? AppTheme.textSecondary
                : AppTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _delayTime = 0.25;
                _feedback = 0.3;
                _mix = 0.2;
                _currentBpm = 120.0;
                _tapTimes.clear();
              });
              widget.onReset();
            },
            style: AppTheme.darkTheme.outlinedButtonTheme.style?.copyWith(
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
            child: Text(
              'Reset',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.accentColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.isBypassed ? null : () => _syncToTempo(),
            icon: CustomIconWidget(
              iconName: 'sync',
              color: widget.isBypassed
                  ? AppTheme.textSecondary
                  : AppTheme.primaryDark,
              size: 18,
            ),
            label: Text(
              'Sync',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: widget.isBypassed
                    ? AppTheme.textSecondary
                    : AppTheme.primaryDark,
              ),
            ),
            style: AppTheme.darkTheme.elevatedButtonTheme.style?.copyWith(
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(vertical: 1.5.h),
              ),
              backgroundColor: WidgetStateProperty.all(
                widget.isBypassed ? AppTheme.borderColor : AppTheme.accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleTapTempo() {
    final now = DateTime.now();
    _tapAnimationController.forward().then((_) {
      _tapAnimationController.reverse();
    });

    setState(() {
      _isTapping = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isTapping = false;
      });
    });

    _tapTimes.add(now);

    if (_tapTimes.length > 8) {
      _tapTimes.removeAt(0);
    }

    if (_tapTimes.length >= 2) {
      final intervals = <int>[];
      for (int i = 1; i < _tapTimes.length; i++) {
        intervals.add(_tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds);
      }

      final averageInterval =
          intervals.reduce((a, b) => a + b) / intervals.length;
      final bpm = 60000 / averageInterval;

      if (bpm >= 60 && bpm <= 200) {
        setState(() {
          _currentBpm = bpm;
        });
        _syncToTempo();
      }
    }

    _lastTap = now;
  }

  void _syncToTempo() {
    final beatDuration = 60.0 / _currentBpm;
    setState(() {
      _delayTime = beatDuration / 4; // Quarter note delay
    });
    widget.onDelayChange('delayTime', _delayTime);
  }
}
