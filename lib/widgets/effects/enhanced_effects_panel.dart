import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/utils/glassmorphism_utils.dart';
import '../../theme/app_theme.dart';
import '../../presentation/effects_panel/widgets/reverb_controls_widget.dart';
import '../../presentation/effects_panel/widgets/echo_controls_widget.dart';
import '../../presentation/effects_panel/widgets/compression_controls_widget.dart';
import '../../presentation/effects_panel/widgets/eq_controls_widget.dart';

class EnhancedEffectsPanel extends StatefulWidget {
  final Function(String, Map<String, dynamic>)? onEffectChanged;
  final Map<String, bool> effectsEnabled;
  final Map<String, Map<String, dynamic>> effectsParameters;

  const EnhancedEffectsPanel({
    Key? key,
    this.onEffectChanged,
    this.effectsEnabled = const {},
    this.effectsParameters = const {},
  }) : super(key: key);

  @override
  State<EnhancedEffectsPanel> createState() => _EnhancedEffectsPanelState();
}

class _EnhancedEffectsPanelState extends State<EnhancedEffectsPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  int _selectedTab = 0;
  bool _isExpanded = true;
  
  final List<EffectTab> _effectTabs = [
    EffectTab(
      name: 'Reverb',
      icon: Icons.waves,
      color: AppTheme.accentColor,
    ),
    EffectTab(
      name: 'Echo',
      icon: Icons.graphic_eq,
      color: const Color(0xFF74B9FF),
    ),
    EffectTab(
      name: 'EQ',
      icon: Icons.equalizer,
      color: const Color(0xFF55EFC4),
    ),
    EffectTab(
      name: 'Compression',
      icon: Icons.compress,
      color: const Color(0xFFE17055),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _effectTabs.length, vsync: this);
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 16,
      blur: 12,
      opacity: 0.1,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) ...[
            _buildTabBar(),
            _buildTabContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentColor.withOpacity(0.3 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.auto_fix_high,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Effects Panel',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textHighEmphasisDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Professional Audio Processing',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMediumEmphasisDark,
                  ),
                ),
              ],
            ),
          ),
          _buildMasterBypass(),
          const SizedBox(width: 8),
          GlassmorphismUtils.createGlassButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: 8,
            padding: const EdgeInsets.all(8),
            child: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more,
                color: AppTheme.textHighEmphasisDark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterBypass() {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 20,
      blur: 6,
      opacity: 0.2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.power_settings_new,
            size: 16,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            'MASTER',
            style: TextStyle(
              color: AppTheme.textHighEmphasisDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassmorphismUtils.createGlassContainer(
        borderRadius: 12,
        blur: 8,
        opacity: 0.15,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: _effectTabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _selectedTab == index;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                  _tabController.animateTo(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected 
                        ? tab.color.withOpacity(0.2)
                        : Colors.transparent,
                    border: isSelected
                        ? Border.all(color: tab.color.withOpacity(0.5), width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        color: isSelected ? tab.color : AppTheme.textMediumEmphasisDark,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab.name,
                        style: TextStyle(
                          color: isSelected ? tab.color : AppTheme.textMediumEmphasisDark,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(16),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildEffectContent(
            child: ReverbControlsWidget(
              onReverbChange: (param, value) {
                widget.onEffectChanged?.call('reverb', {param: value});
              },
              onReset: () {},
              isBypassed: widget.effectsEnabled['reverb'] != true,
              onBypassToggle: () {
                widget.onEffectChanged?.call('reverb', {'bypass': !(widget.effectsEnabled['reverb'] ?? false)});
              },
            ),
          ),
          _buildEffectContent(
            child: EchoControlsWidget(
              onEchoChange: (param, value) {
                widget.onEffectChanged?.call('echo', {param: value});
              },
              onReset: () {},
              isBypassed: widget.effectsEnabled['echo'] != true,
              onBypassToggle: () {
                widget.onEffectChanged?.call('echo', {'bypass': !(widget.effectsEnabled['echo'] ?? false)});
              },
            ),
          ),
          _buildEffectContent(
            child: EqControlsWidget(
              onEqChange: (param, value) {
                widget.onEffectChanged?.call('eq', {param: value});
              },
              onReset: () {},
              isBypassed: widget.effectsEnabled['eq'] != true,
              onBypassToggle: () {
                widget.onEffectChanged?.call('eq', {'bypass': !(widget.effectsEnabled['eq'] ?? false)});
              },
            ),
          ),
          _buildEffectContent(
            child: CompressionControlsWidget(
              onCompressionChange: (param, value) {
                widget.onEffectChanged?.call('compression', {param: value});
              },
              onReset: () {},
              isBypassed: widget.effectsEnabled['compression'] != true,
              onBypassToggle: () {
                widget.onEffectChanged?.call('compression', {'bypass': !(widget.effectsEnabled['compression'] ?? false)});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectContent({required Widget child}) {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 12,
      blur: 10,
      opacity: 0.08,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class EffectTab {
  final String name;
  final IconData icon;
  final Color color;

  const EffectTab({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Enhanced frequency analyzer widget with glassmorphism effects
class FrequencyAnalyzer extends StatefulWidget {
  final List<double> frequencyData;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;

  const FrequencyAnalyzer({
    Key? key,
    required this.frequencyData,
    this.height = 120,
    this.primaryColor = AppTheme.accentColor,
    this.secondaryColor = const Color(0xFF74B9FF),
  }) : super(key: key);

  @override
  State<FrequencyAnalyzer> createState() => _FrequencyAnalyzerState();
}

class _FrequencyAnalyzerState extends State<FrequencyAnalyzer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: 8,
      blur: 6,
      opacity: 0.1,
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.all(8),
        child: CustomPaint(
          painter: FrequencyAnalyzerPainter(
            frequencyData: widget.frequencyData,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            animationValue: _animation.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class FrequencyAnalyzerPainter extends CustomPainter {
  final List<double> frequencyData;
  final Color primaryColor;
  final Color secondaryColor;
  final double animationValue;

  FrequencyAnalyzerPainter({
    required this.frequencyData,
    required this.primaryColor,
    required this.secondaryColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final barWidth = size.width / frequencyData.length;
    
    for (int i = 0; i < frequencyData.length; i++) {
      final barHeight = frequencyData[i] * size.height * animationValue;
      final x = i * barWidth;
      final y = size.height - barHeight;
      
      // Create gradient for each bar
      paint.shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          primaryColor.withOpacity(0.8),
          secondaryColor.withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(x, y, barWidth - 1, barHeight));
      
      // Draw bar with rounded top
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth - 1, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
      
      // Add glow effect
      paint.shader = RadialGradient(
        center: Alignment.center,
        colors: [
          primaryColor.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(x - 2, y - 2, barWidth + 4, barHeight + 4));
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 1, y - 1, barWidth + 1, barHeight + 2),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}