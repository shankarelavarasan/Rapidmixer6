import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CompressionControlsWidget extends StatefulWidget {
  final Function(String parameter, double value) onCompressionChange;
  final VoidCallback onReset;
  final bool isBypassed;
  final VoidCallback onBypassToggle;

  const CompressionControlsWidget({
    super.key,
    required this.onCompressionChange,
    required this.onReset,
    required this.isBypassed,
    required this.onBypassToggle,
  });

  @override
  State<CompressionControlsWidget> createState() =>
      _CompressionControlsWidgetState();
}

class _CompressionControlsWidgetState extends State<CompressionControlsWidget> {
  double _threshold = -12.0;
  double _ratio = 4.0;
  double _attack = 0.003;
  double _release = 0.1;
  double _makeupGain = 0.0;
  double _gainReduction = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 3.h),
          _buildGainReductionMeter(),
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
          'Compressor',
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

  Widget _buildGainReductionMeter() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gain Reduction',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${_gainReduction.toStringAsFixed(1)} dB',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            height: 3.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.successColor,
                        AppTheme.warningColor,
                        AppTheme.errorColor,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width:
                      ((_gainReduction.abs() / 20.0).clamp(0.0, 1.0)) * 100.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
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
          'Threshold',
          _threshold,
          -40.0,
          0.0,
          (value) {
            setState(() => _threshold = value);
            widget.onCompressionChange('threshold', value);
            _updateGainReduction();
          },
          unit: 'dB',
        ),
        SizedBox(height: 2.h),
        _buildRatioSelector(),
        SizedBox(height: 2.h),
        _buildParameterSlider(
          'Attack',
          _attack,
          0.001,
          0.1,
          (value) {
            setState(() => _attack = value);
            widget.onCompressionChange('attack', value);
          },
          unit: 'ms',
          isLogarithmic: true,
        ),
        SizedBox(height: 2.h),
        _buildParameterSlider(
          'Release',
          _release,
          0.01,
          1.0,
          (value) {
            setState(() => _release = value);
            widget.onCompressionChange('release', value);
          },
          unit: 's',
          isLogarithmic: true,
        ),
        SizedBox(height: 2.h),
        _buildParameterSlider(
          'Makeup Gain',
          _makeupGain,
          0.0,
          20.0,
          (value) {
            setState(() => _makeupGain = value);
            widget.onCompressionChange('makeupGain', value);
          },
          unit: 'dB',
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
    bool isLogarithmic = false,
  }) {
    String displayValue;
    if (unit == 'dB') {
      displayValue = '${value.toStringAsFixed(1)} dB';
    } else if (unit == 'ms') {
      displayValue = '${(value * 1000).toStringAsFixed(1)} ms';
    } else if (unit == 's') {
      displayValue = '${value.toStringAsFixed(3)} s';
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

  Widget _buildRatioSelector() {
    final ratios = [1.5, 2.0, 3.0, 4.0, 6.0, 8.0, 12.0, 20.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ratio',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: widget.isBypassed
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
              ),
            ),
            Text(
              '${_ratio.toStringAsFixed(1)}:1',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: widget.isBypassed
                    ? AppTheme.textSecondary
                    : AppTheme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 6.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ratios.length,
            itemBuilder: (context, index) {
              final ratio = ratios[index];
              final isSelected = (_ratio - ratio).abs() < 0.1;

              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: FilterChip(
                  label: Text(
                    '${ratio.toStringAsFixed(1)}:1',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryDark
                          : AppTheme.textPrimary,
                      fontSize: 10.sp,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: widget.isBypassed
                      ? null
                      : (selected) {
                          if (selected) {
                            setState(() => _ratio = ratio);
                            widget.onCompressionChange('ratio', ratio);
                            _updateGainReduction();
                          }
                        },
                  selectedColor: AppTheme.accentColor,
                  backgroundColor: AppTheme.secondaryDark,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.accentColor
                        : AppTheme.borderColor,
                  ),
                ),
              );
            },
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
                _threshold = -12.0;
                _ratio = 4.0;
                _attack = 0.003;
                _release = 0.1;
                _makeupGain = 0.0;
                _gainReduction = 0.0;
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
            onPressed: widget.isBypassed ? null : () => _showPresets(),
            icon: CustomIconWidget(
              iconName: 'tune',
              color: widget.isBypassed
                  ? AppTheme.textSecondary
                  : AppTheme.primaryDark,
              size: 18,
            ),
            label: Text(
              'Presets',
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

  void _updateGainReduction() {
    // Simulate gain reduction calculation
    final inputLevel = -6.0; // Simulated input level
    if (inputLevel > _threshold) {
      final overage = inputLevel - _threshold;
      setState(() {
        _gainReduction = -(overage * (1.0 - (1.0 / _ratio)));
      });
    } else {
      setState(() {
        _gainReduction = 0.0;
      });
    }
  }

  void _showPresets() {
    final presets = [
      {
        'name': 'Vocal',
        'threshold': -18.0,
        'ratio': 3.0,
        'attack': 0.003,
        'release': 0.1,
        'makeupGain': 3.0
      },
      {
        'name': 'Drums',
        'threshold': -8.0,
        'ratio': 6.0,
        'attack': 0.001,
        'release': 0.05,
        'makeupGain': 2.0
      },
      {
        'name': 'Bass',
        'threshold': -15.0,
        'ratio': 4.0,
        'attack': 0.01,
        'release': 0.2,
        'makeupGain': 4.0
      },
      {
        'name': 'Master',
        'threshold': -6.0,
        'ratio': 2.0,
        'attack': 0.005,
        'release': 0.1,
        'makeupGain': 1.0
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Compressor Presets',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: presets.map((preset) {
            return ListTile(
              title: Text(
                preset['name'] as String,
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                setState(() {
                  _threshold = preset['threshold'] as double;
                  _ratio = preset['ratio'] as double;
                  _attack = preset['attack'] as double;
                  _release = preset['release'] as double;
                  _makeupGain = preset['makeupGain'] as double;
                });
                widget.onCompressionChange('threshold', _threshold);
                widget.onCompressionChange('ratio', _ratio);
                widget.onCompressionChange('attack', _attack);
                widget.onCompressionChange('release', _release);
                widget.onCompressionChange('makeupGain', _makeupGain);
                _updateGainReduction();
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
