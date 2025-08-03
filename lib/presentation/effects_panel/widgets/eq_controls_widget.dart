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

class _EqControlsWidgetState extends State<EqControlsWidget> {
  final Map<String, double> _eqValues = {
    '60Hz': 0.0,
    '250Hz': 0.0,
    '1kHz': 0.0,
    '4kHz': 0.0,
    '16kHz': 0.0,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 3.h),
          _buildFrequencyResponseCurve(),
          SizedBox(height: 3.h),
          _buildEqSliders(),
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
          'Equalizer',
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

  Widget _buildFrequencyResponseCurve() {
    return Container(
      width: double.infinity,
      height: 15.h,
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: CustomPaint(
        painter: FrequencyResponsePainter(_eqValues, widget.isBypassed),
        child: Container(),
      ),
    );
  }

  Widget _buildEqSliders() {
    return Container(
      height: 25.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _eqValues.keys.map((frequency) {
          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 3,
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
                      activeColor: widget.isBypassed
                          ? AppTheme.textSecondary
                          : AppTheme.accentColor,
                      inactiveColor: AppTheme.borderColor,
                      thumbColor: widget.isBypassed
                          ? AppTheme.textSecondary
                          : AppTheme.accentColor,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '${_eqValues[frequency]!.toStringAsFixed(1)}dB',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: widget.isBypassed
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  frequency,
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _eqValues.updateAll((key, value) => 0.0);
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
          child: ElevatedButton(
            onPressed: () => _showPresetDialog(),
            style: AppTheme.darkTheme.elevatedButtonTheme.style?.copyWith(
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
            child: Text(
              'Presets',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.primaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPresetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'EQ Presets',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPresetOption('Flat', {
              '60Hz': 0.0,
              '250Hz': 0.0,
              '1kHz': 0.0,
              '4kHz': 0.0,
              '16kHz': 0.0
            }),
            _buildPresetOption('Bass Boost', {
              '60Hz': 6.0,
              '250Hz': 3.0,
              '1kHz': 0.0,
              '4kHz': 0.0,
              '16kHz': 0.0
            }),
            _buildPresetOption('Vocal', {
              '60Hz': -2.0,
              '250Hz': 1.0,
              '1kHz': 4.0,
              '4kHz': 3.0,
              '16kHz': 1.0
            }),
            _buildPresetOption('Bright', {
              '60Hz': 0.0,
              '250Hz': 0.0,
              '1kHz': 2.0,
              '4kHz': 4.0,
              '16kHz': 6.0
            }),
          ],
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

  Widget _buildPresetOption(String name, Map<String, double> preset) {
    return ListTile(
      title: Text(
        name,
        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimary,
        ),
      ),
      onTap: () {
        setState(() {
          _eqValues.addAll(preset);
        });
        for (String frequency in preset.keys) {
          widget.onEqChange(frequency, preset[frequency]!);
        }
        Navigator.pop(context);
      },
    );
  }
}

class FrequencyResponsePainter extends CustomPainter {
  final Map<String, double> eqValues;
  final bool isBypassed;

  FrequencyResponsePainter(this.eqValues, this.isBypassed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isBypassed ? AppTheme.textSecondary : AppTheme.accentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final frequencies = eqValues.keys.toList();

    for (int i = 0; i < frequencies.length; i++) {
      final x = (i / (frequencies.length - 1)) * size.width;
      final gain = eqValues[frequencies[i]]!;
      final y = size.height / 2 - (gain / 12.0) * (size.height / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw center line
    final centerPaint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
