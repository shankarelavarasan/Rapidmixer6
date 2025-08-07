import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/utils/glassmorphism_utils.dart';
import '../../theme/app_theme.dart';

class EQControlsWidget extends StatefulWidget {
  final Function(String, double)? onParameterChanged;
  final Map<String, double> initialParameters;

  const EQControlsWidget({
    Key? key,
    this.onParameterChanged,
    this.initialParameters = const {},
  }) : super(key: key);

  @override
  State<EQControlsWidget> createState() => _EQControlsWidgetState();
}

class _EQControlsWidgetState extends State<EQControlsWidget>
    with TickerProviderStateMixin {
  // EQ Band parameters
  final List<EQBand> _eqBands = [
    EQBand(frequency: 60, gain: 0, q: 1.0, type: EQBandType.highPass),
    EQBand(frequency: 200, gain: 0, q: 1.0, type: EQBandType.bell),
    EQBand(frequency: 800, gain: 0, q: 1.0, type: EQBandType.bell),
    EQBand(frequency: 3200, gain: 0, q: 1.0, type: EQBandType.bell),
    EQBand(frequency: 8000, gain: 0, q: 1.0, type: EQBandType.bell),
    EQBand(frequency: 12000, gain: 0, q: 1.0, type: EQBandType.lowPass),
  ];

  late AnimationController _spectrumController;
  late Animation<double> _spectrumAnimation;
  
  bool _isEnabled = true;
  int _selectedBand = 0;
  List<double> _frequencyResponse = [];
  
  // Presets
  final Map<String, List<double>> _presets = {
    'Flat': [0, 0, 0, 0, 0, 0],
    'Bass Boost': [6, 4, 2, 0, -1, -2],
    'Treble Boost': [-2, -1, 0, 2, 4, 6],
    'Vocal': [-2, -1, 3, 4, 2, 0],
    'Rock': [4, 2, -1, 0, 2, 3],
    'Jazz': [3, 1, 0, 1, 2, 2],
    'Classical': [2, 0, -1, 0, 1, 3],
  };

  @override
  void initState() {
    super.initState();
    _initializeParameters();
    _spectrumController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _spectrumAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spectrumController, curve: Curves.easeOut),
    );
    _spectrumController.repeat();
    _generateFrequencyResponse();
  }

  void _initializeParameters() {
    for (int i = 0; i < _eqBands.length; i++) {
      final key = 'band_${i}_gain';
      if (widget.initialParameters.containsKey(key)) {
        _eqBands[i].gain = widget.initialParameters[key]!;
      }
    }
  }

  void _generateFrequencyResponse() {
    _frequencyResponse.clear();
    for (int i = 0; i < 128; i++) {
      final frequency = 20 * math.pow(1000, i / 127);
      double response = 0;
      
      for (final band in _eqBands) {
        response += _calculateBandResponse(frequency, band);
      }
      
      _frequencyResponse.add(response);
    }
  }

  double _calculateBandResponse(double frequency, EQBand band) {
    final ratio = frequency / band.frequency;
    switch (band.type) {
      case EQBandType.bell:
        final q = band.q;
        final gain = band.gain;
        final w = 2 * math.pi * frequency;
        final w0 = 2 * math.pi * band.frequency;
        final alpha = math.sin(w0) / (2 * q);
        final a = math.pow(10, gain / 40).toDouble();
        
        final b0 = 1 + alpha * a;
        final b1 = -2 * math.cos(w0);
        final b2 = 1 - alpha * a;
        final a0 = 1 + alpha / a;
        final a1 = -2 * math.cos(w0);
        final a2 = 1 - alpha / a;
        
        final h = math.sqrt(
          (math.pow(b0 + b1 + b2, 2)) / (math.pow(a0 + a1 + a2, 2))
        );
        
        return 20 * math.log(h) / math.ln10;
      
      case EQBandType.highPass:
        if (frequency < band.frequency) {
          final rolloff = -12 * math.log(band.frequency / frequency) / math.ln10;
          return rolloff;
        }
        return 0;
      
      case EQBandType.lowPass:
        if (frequency > band.frequency) {
          final rolloff = -12 * math.log(frequency / band.frequency) / math.ln10;
          return rolloff;
        }
        return 0;
    }
  }

  @override
  void dispose() {
    _spectrumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildFrequencyResponse(),
        const SizedBox(height: 16),
        _buildBandControls(),
        const SizedBox(height: 16),
        _buildPresets(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.equalizer,
          color: AppTheme.accentColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parametric EQ',
                style: TextStyle(
                  color: AppTheme.textHighEmphasisDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '6-Band Professional Equalizer',
                style: TextStyle(
                  color: AppTheme.textMediumEmphasisDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        GlassmorphismUtils.createGlassButton(
          onPressed: () {
            setState(() {
              _isEnabled = !_isEnabled;
            });
          },
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: _isEnabled 
              ? AppTheme.accentColor.withOpacity(0.2)
              : AppTheme.surfaceColor.withOpacity(0.1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isEnabled ? Icons.power_settings_new : Icons.power_off,
                color: _isEnabled ? AppTheme.accentColor : AppTheme.textMediumEmphasisDark,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _isEnabled ? 'ON' : 'OFF',
                style: TextStyle(
                  color: _isEnabled ? AppTheme.accentColor : AppTheme.textMediumEmphasisDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyResponse() {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 12,
      blur: 8,
      opacity: 0.1,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequency Response',
            style: TextStyle(
              color: AppTheme.textHighEmphasisDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            child: CustomPaint(
              painter: EQResponsePainter(
                frequencyResponse: _frequencyResponse,
                eqBands: _eqBands,
                selectedBand: _selectedBand,
                animationValue: _spectrumAnimation.value,
                isEnabled: _isEnabled,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandControls() {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 12,
      blur: 8,
      opacity: 0.1,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Band Controls',
            style: TextStyle(
              color: AppTheme.textHighEmphasisDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _eqBands.asMap().entries.map((entry) {
              final index = entry.key;
              final band = entry.value;
              final isSelected = _selectedBand == index;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBand = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildBandSlider(index, band, isSelected),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildSelectedBandDetails(),
        ],
      ),
    );
  }

  Widget _buildBandSlider(int index, EQBand band, bool isSelected) {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 8,
      blur: 6,
      opacity: isSelected ? 0.2 : 0.1,
      padding: const EdgeInsets.all(8),
      borderColor: isSelected ? AppTheme.accentColor.withOpacity(0.5) : null,
      child: Column(
        children: [
          Text(
            '${(band.frequency / 1000).toStringAsFixed(band.frequency >= 1000 ? 1 : 0)}${band.frequency >= 1000 ? 'k' : ''}',
            style: TextStyle(
              color: isSelected ? AppTheme.accentColor : AppTheme.textMediumEmphasisDark,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 80,
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                  inactiveTrackColor: AppTheme.borderColor.withOpacity(0.3),
                  thumbColor: isSelected ? AppTheme.accentColor : AppTheme.textMediumEmphasisDark,
                  overlayColor: AppTheme.accentColor.withOpacity(0.2),
                  trackHeight: 3.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: (band.gain + 12) / 24, // Normalize -12 to +12 to 0-1
                  onChanged: (value) {
                    setState(() {
                      band.gain = (value * 24) - 12; // Convert back to -12 to +12
                      _generateFrequencyResponse();
                    });
                    widget.onParameterChanged?.call('band_${index}_gain', band.gain);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${band.gain.toStringAsFixed(1)}dB',
            style: TextStyle(
              color: isSelected ? AppTheme.accentColor : AppTheme.textMediumEmphasisDark,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedBandDetails() {
    final selectedBand = _eqBands[_selectedBand];
    
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 8,
      blur: 6,
      opacity: 0.15,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Band ${_selectedBand + 1} - ${selectedBand.type.name.toUpperCase()}',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildParameterControl(
                  'Frequency',
                  '${selectedBand.frequency.toInt()}Hz',
                  selectedBand.frequency,
                  20,
                  20000,
                  (value) {
                    setState(() {
                      selectedBand.frequency = value;
                      _generateFrequencyResponse();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildParameterControl(
                  'Q Factor',
                  selectedBand.q.toStringAsFixed(1),
                  selectedBand.q,
                  0.1,
                  10.0,
                  (value) {
                    setState(() {
                      selectedBand.q = value;
                      _generateFrequencyResponse();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterControl(
    String label,
    String value,
    double currentValue,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textMediumEmphasisDark,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textHighEmphasisDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        GlassmorphismUtils.createGlassSliderTrack(
          value: (currentValue - min) / (max - min),
          onChanged: (normalizedValue) {
            final actualValue = min + (normalizedValue * (max - min));
            onChanged(actualValue);
          },
          activeColor: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildPresets() {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 12,
      blur: 8,
      opacity: 0.1,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Presets',
            style: TextStyle(
              color: AppTheme.textHighEmphasisDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.keys.map((presetName) {
              return GlassmorphismUtils.createGlassButton(
                onPressed: () => _applyPreset(presetName),
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  presetName,
                  style: TextStyle(
                    color: AppTheme.textHighEmphasisDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _applyPreset(String presetName) {
    final gains = _presets[presetName]!;
    setState(() {
      for (int i = 0; i < _eqBands.length && i < gains.length; i++) {
        _eqBands[i].gain = gains[i];
      }
      _generateFrequencyResponse();
    });
  }
}

class EQBand {
  double frequency;
  double gain;
  double q;
  EQBandType type;

  EQBand({
    required this.frequency,
    required this.gain,
    required this.q,
    required this.type,
  });
}

enum EQBandType {
  bell,
  highPass,
  lowPass,
}

class EQResponsePainter extends CustomPainter {
  final List<double> frequencyResponse;
  final List<EQBand> eqBands;
  final int selectedBand;
  final double animationValue;
  final bool isEnabled;

  EQResponsePainter({
    required this.frequencyResponse,
    required this.eqBands,
    required this.selectedBand,
    required this.animationValue,
    required this.isEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isEnabled) {
      _drawBypassedState(canvas, size);
      return;
    }

    _drawGrid(canvas, size);
    _drawFrequencyResponse(canvas, size);
    _drawBandMarkers(canvas, size);
  }

  void _drawBypassedState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textMediumEmphasisDark.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw flat response line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Draw "BYPASSED" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'BYPASSED',
        style: TextStyle(
          color: AppTheme.textMediumEmphasisDark.withOpacity(0.5),
          fontSize: 16,
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

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal grid lines (dB)
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical grid lines (frequency)
    final frequencies = [100, 1000, 10000];
    for (final freq in frequencies) {
      final x = _frequencyToX(freq.toDouble(), size.width);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawFrequencyResponse(Canvas canvas, Size size) {
    if (frequencyResponse.isEmpty) return;

    final path = Path();
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = LinearGradient(
        colors: [
          AppTheme.accentColor,
          const Color(0xFF74B9FF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create response curve
    for (int i = 0; i < frequencyResponse.length; i++) {
      final x = (i / (frequencyResponse.length - 1)) * size.width;
      final response = frequencyResponse[i];
      final y = size.height / 2 - (response / 24) * (size.height / 2); // ±12dB range
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Fill area under curve
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height / 2);
    fillPath.lineTo(0, size.height / 2);
    fillPath.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.accentColor.withOpacity(0.3 * animationValue),
          AppTheme.accentColor.withOpacity(0.1 * animationValue),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawBandMarkers(Canvas canvas, Size size) {
    for (int i = 0; i < eqBands.length; i++) {
      final band = eqBands[i];
      final x = _frequencyToX(band.frequency, size.width);
      final y = size.height / 2 - (band.gain / 24) * (size.height / 2);
      
      final isSelected = i == selectedBand;
      final paint = Paint()
        ..color = isSelected ? AppTheme.accentColor : AppTheme.textMediumEmphasisDark
        ..style = PaintingStyle.fill;

      // Draw band marker
      canvas.drawCircle(
        Offset(x, y),
        isSelected ? 6 : 4,
        paint,
      );

      // Draw selection ring
      if (isSelected) {
        final ringPaint = Paint()
          ..color = AppTheme.accentColor.withOpacity(0.3 * animationValue)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        canvas.drawCircle(
          Offset(x, y),
          8 + (2 * animationValue),
          ringPaint,
        );
      }
    }
  }

  double _frequencyToX(double frequency, double width) {
    final logFreq = math.log(frequency) / math.ln10;
    final logMin = math.log(20) / math.ln10;
    final logMax = math.log(20000) / math.ln10;
    return ((logFreq - logMin) / (logMax - logMin)) * width;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}