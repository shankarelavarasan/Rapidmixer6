import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class AudioControlsWidget extends StatelessWidget {
  final double volume;
  final double pitch;
  final double pan;
  final double reverb;
  final double echo;
  final double speed; // Add this
  final Map<String, double> eq;
  final Function(double) onVolumeChanged;
  final Function(double) onPitchChanged;
  final Function(double) onPanChanged;
  final Function(double) onReverbChanged;
  final Function(double) onEchoChanged;
  final Function(double) onSpeedChanged; // Add this
  final Function(Map<String, double>) onEqChanged;
  final VoidCallback? onReset; // Add this
  
  const AudioControlsWidget({
    Key? key,
    required this.volume,
    required this.pitch,
    required this.pan,
    required this.reverb,
    required this.echo,
    required this.speed, // Add this
    required this.eq,
    required this.onVolumeChanged,
    required this.onPitchChanged,
    required this.onPanChanged,
    required this.onReverbChanged,
    required this.onEchoChanged,
    required this.onSpeedChanged, // Add this
    required this.onEqChanged,
    this.onReset, // Add this
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
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
                'Audio Controls',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onReset != null)
                TextButton(
                  onPressed: onReset,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),

          // Basic Controls
          _buildControlSlider(
            label: 'Volume',
            value: volume,
            min: 0.0,
            max: 1.0,
            onChanged: onVolumeChanged,
            icon: 'volume_up',
            displayValue: '${(volume * 100).round()}%',
          ),

          SizedBox(height: 2.h),

          _buildControlSlider(
            label: 'Pitch',
            value: pitch,
            min: -12.0,
            max: 12.0,
            onChanged: onPitchChanged,
            icon: 'tune',
            displayValue: '${pitch > 0 ? '+' : ''}${pitch.toStringAsFixed(1)}',
          ),

          SizedBox(height: 2.h),

          _buildControlSlider(
            label: 'Speed',
            value: speed,
            min: 0.25,
            max: 4.0,
            onChanged: onSpeedChanged,
            icon: 'speed',
            displayValue: '${speed.toStringAsFixed(2)}x',
          ),

          SizedBox(height: 2.h),

          _buildControlSlider(
            label: 'Pan',
            value: pan,
            min: -1.0,
            max: 1.0,
            onChanged: onPanChanged,
            icon: 'surround_sound',
            displayValue: pan == 0 ? 'Center' : pan < 0 ? 'L${(-pan * 100).round()}' : 'R${(pan * 100).round()}',
          ),

          SizedBox(height: 3.h),

          Text(
            'Effects',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          _buildControlSlider(
            label: 'Reverb',
            value: reverb,
            min: 0.0,
            max: 1.0,
            onChanged: onReverbChanged,
            icon: 'waves',
            displayValue: '${(reverb * 100).round()}%',
          ),

          SizedBox(height: 2.h),

          _buildControlSlider(
            label: 'Echo',
            value: echo,
            min: 0.0,
            max: 1.0,
            onChanged: onEchoChanged,
            icon: 'graphic_eq',
            displayValue: '${(echo * 100).round()}%',
          ),

          SizedBox(height: 3.h),

          Text(
            'Equalizer',
            style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          _buildEqualizer(),
        ],
      ),
    );
  }

  Widget _buildControlSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required String icon,
    required String displayValue,
  }) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: icon,
                    color: AppTheme.accentColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    label,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  displayValue,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.accentColor,
              inactiveTrackColor: AppTheme.borderColor,
              thumbColor: AppTheme.accentColor,
              overlayColor: AppTheme.accentColor.withValues(alpha: 0.2),
              valueIndicatorColor: AppTheme.accentColor,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
              divisions: label == 'Volume' ? 100 : (label == 'Pitch' ? 240 : 150),
              label: displayValue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEqBand('Low', eq['60'] ?? 0.0, (value) {
          final newEq = Map<String, double>.from(eq);
          newEq['60'] = value;
          onEqChanged(newEq);
        }),
        _buildEqBand('Mid', eq['1000'] ?? 0.0, (value) {
          final newEq = Map<String, double>.from(eq);
          newEq['1000'] = value;
          onEqChanged(newEq);
        }),
        _buildEqBand('High', eq['12000'] ?? 0.0, (value) {
          final newEq = Map<String, double>.from(eq);
          newEq['12000'] = value;
          onEqChanged(newEq);
        }),
      ],
    );
  }

  Widget _buildEqBand(String label, double value, Function(double) onChanged) {
    return Builder(
      builder: (context) => Column(
        children: [
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 20.h,
            width: 8.w,
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.accentColor,
                  inactiveTrackColor: AppTheme.borderColor,
                  thumbColor: AppTheme.accentColor,
                  overlayColor: AppTheme.accentColor.withValues(alpha: 0.2),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: value.clamp(-12.0, 12.0),
                  min: -12.0,
                  max: 12.0,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '${value.toStringAsFixed(1)}dB',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}