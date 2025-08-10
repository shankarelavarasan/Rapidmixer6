import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../core/utils/math_utils.dart';

class AnimatedParticlesWidget extends StatefulWidget {
  const AnimatedParticlesWidget({super.key});

  @override
  State<AnimatedParticlesWidget> createState() =>
      _AnimatedParticlesWidgetState();
}

class _AnimatedParticlesWidgetState extends State<AnimatedParticlesWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _particles = List.generate(20, (index) => Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlesPainter(
              particles: _particles,
              animation: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;
  late Color color;

  Particle() {
    final random = math.Random();
    x = MathUtils.validateAndClamp(random.nextDouble(), 0.0, 1.0);
    y = MathUtils.validateAndClamp(random.nextDouble(), 0.0, 1.0);
    size = MathUtils.validateAndClamp(random.nextDouble() * 3 + 1, 1.0, 4.0);
    speed = MathUtils.validateAndClamp(random.nextDouble() * 0.02 + 0.01, 0.01, 0.03);
    opacity = MathUtils.validateAndClamp(random.nextDouble() * 0.5 + 0.1, 0.1, 0.6);
    color = [
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
    ][random.nextInt(3)];
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlesPainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      final safeAnimation = MathUtils.validateAndClamp(animation, 0.0, 1.0);
      final x = MathUtils.safeModulo(particle.x + safeAnimation * particle.speed, 1.0) * size.width;
      final y = MathUtils.safeModulo(particle.y + safeAnimation * particle.speed * 0.5, 1.0) * size.height;

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
