import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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

class _ReverbControlsWidgetState extends State<ReverbControlsWidget> {
  double _roomSize = 0.5;
  double _decayTime = 0.3;
  double _wetDryMix = 0.2;
  String _selectedPreset = 'Studio';

  final List<Map<String, dynamic>> _presets = [
    {'name': 'Studio', 'roomSize': 0.3, 'decayTime': 0.2, 'wetDryMix': 0.15},
    {'name': 'Hall', 'roomSize': 0.8, 'decayTime': 0.7, 'wetDryMix': 0.3},
    {'name': 'Plate', 'roomSize': 0.4, 'decayTime': 0.4, 'wetDryMix': 0.25},
    {'name': 'Spring', 'roomSize': 0.2, 'decayTime': 0.1, 'wetDryMix': 0.1},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 3.h),
          _buildPresetSelector(),
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
          'Reverb',
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

  Widget _buildPresetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presets',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          height: 6.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _presets.length,
            itemBuilder: (context, index) {
              final preset = _presets[index];
              final isSelected = _selectedPreset == preset['name'];

              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: FilterChip(
                  label: Text(
                    preset['name'],
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: widget.isBypassed
                      ? null
                      : (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPreset = preset['name'];
                              _roomSize = preset['roomSize'];
                              _decayTime = preset['decayTime'];
                              _wetDryMix = preset['wetDryMix'];
                            });
                            widget.onReverbChange('roomSize', _roomSize);
                            widget.onReverbChange('decayTime', _decayTime);
                            widget.onReverbChange('wetDryMix', _wetDryMix);
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

  Widget _buildParameterControls() {
    return Column(
      children: [
        _buildParameterSlider(
          'Room Size',
          _roomSize,
          0.0,
          1.0,
          (value) {
            setState(() => _roomSize = value);
            widget.onReverbChange('roomSize', value);
          },
        ),
        SizedBox(height: 2.h),
        _buildParameterSlider(
          'Decay Time',
          _decayTime,
          0.0,
          1.0,
          (value) {
            setState(() => _decayTime = value);
            widget.onReverbChange('decayTime', value);
          },
        ),
        SizedBox(height: 2.h),
        _buildParameterSlider(
          'Wet/Dry Mix',
          _wetDryMix,
          0.0,
          1.0,
          (value) {
            setState(() => _wetDryMix = value);
            widget.onReverbChange('wetDryMix', value);
          },
        ),
      ],
    );
  }

  Widget _buildParameterSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
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
              '${(value * 100).toInt()}%',
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
                _roomSize = 0.5;
                _decayTime = 0.3;
                _wetDryMix = 0.2;
                _selectedPreset = 'Studio';
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
            onPressed: widget.isBypassed ? null : () => _showVisualization(),
            icon: CustomIconWidget(
              iconName: 'graphic_eq',
              color: widget.isBypassed
                  ? AppTheme.textSecondary
                  : AppTheme.primaryDark,
              size: 18,
            ),
            label: Text(
              'Visualize',
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

  void _showVisualization() {
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
