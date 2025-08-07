import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class for creating smooth animated transitions throughout the application
class AnimationUtils {
  AnimationUtils._();

  /// Standard animation durations
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);

  /// Standard animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve sharpCurve = Curves.easeOutExpo;

  /// Create a fade transition
  static Widget createFadeTransition({
    required Widget child,
    required Animation<double> animation,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
      child: child,
    );
  }

  /// Create a slide transition
  static Widget createSlideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(0.0, 1.0),
    Offset end = Offset.zero,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: child,
    );
  }

  /// Create a scale transition
  static Widget createScaleTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
    Alignment alignment = Alignment.center,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      alignment: alignment,
      child: child,
    );
  }

  /// Create a rotation transition
  static Widget createRotationTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
    Alignment alignment = Alignment.center,
  }) {
    return RotationTransition(
      turns: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      alignment: alignment,
      child: child,
    );
  }

  /// Create a size transition
  static Widget createSizeTransition({
    required Widget child,
    required Animation<double> animation,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
    Axis axis = Axis.vertical,
    double axisAlignment = 0.0,
  }) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
      axis: axis,
      axisAlignment: axisAlignment,
      child: child,
    );
  }

  /// Create a combined fade and slide transition
  static Widget createFadeSlideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset slideBegin = const Offset(0.0, 0.3),
    Offset slideEnd = Offset.zero,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: slideBegin,
        end: slideEnd,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: curve,
        ),
        child: child,
      ),
    );
  }

  /// Create a combined fade and scale transition
  static Widget createFadeScaleTransition({
    required Widget child,
    required Animation<double> animation,
    double scaleBegin = 0.8,
    double scaleEnd = 1.0,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: scaleBegin,
        end: scaleEnd,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: curve,
        ),
        child: child,
      ),
    );
  }

  /// Create a staggered animation
  static Widget createStaggeredAnimation({
    required List<Widget> children,
    required Animation<double> animation,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
    Axis direction = Axis.vertical,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return direction == Axis.vertical
            ? Column(
                children: children.asMap().entries.map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  final delay = staggerDelay.inMilliseconds * index;
                  final totalDuration = duration.inMilliseconds;
                  final progress = ((animation.value * totalDuration) - delay) / totalDuration;
                  final clampedProgress = math.max(0.0, math.min(1.0, progress));
                  
                  return createFadeSlideTransition(
                    child: child,
                    animation: AlwaysStoppedAnimation(clampedProgress),
                    curve: curve,
                  );
                }).toList(),
              )
            : Row(
                children: children.asMap().entries.map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  final delay = staggerDelay.inMilliseconds * index;
                  final totalDuration = duration.inMilliseconds;
                  final progress = ((animation.value * totalDuration) - delay) / totalDuration;
                  final clampedProgress = math.max(0.0, math.min(1.0, progress));
                  
                  return Expanded(
                    child: createFadeSlideTransition(
                      child: child,
                      animation: AlwaysStoppedAnimation(clampedProgress),
                      slideBegin: const Offset(0.3, 0.0),
                      curve: curve,
                    ),
                  );
                }).toList(),
              );
      },
    );
  }

  /// Create a wave animation
  static Widget createWaveAnimation({
    required Widget child,
    required Animation<double> animation,
    double amplitude = 10.0,
    double frequency = 2.0,
    Duration duration = normalDuration,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final offset = math.sin(animation.value * 2 * math.pi * frequency) * amplitude;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
    );
  }

  /// Create a pulse animation
  static Widget createPulseAnimation({
    required Widget child,
    required Animation<double> animation,
    double minScale = 0.95,
    double maxScale = 1.05,
    Duration duration = normalDuration,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final scale = minScale + (maxScale - minScale) * 
            (0.5 + 0.5 * math.sin(animation.value * 2 * math.pi));
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
    );
  }

  /// Create a shimmer animation
  static Widget createShimmerAnimation({
    required Widget child,
    required Animation<double> animation,
    Color highlightColor = Colors.white,
    Color baseColor = Colors.grey,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor.withOpacity(0.5),
                baseColor,
              ],
              stops: [
                math.max(0.0, animation.value - 0.3),
                animation.value,
                math.min(1.0, animation.value + 0.3),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }

  /// Create a page transition
  static PageRouteBuilder createPageTransition({
    required Widget page,
    PageTransitionType type = PageTransitionType.fadeSlide,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case PageTransitionType.fade:
            return createFadeTransition(
              child: child,
              animation: animation,
              curve: curve,
            );
          case PageTransitionType.slide:
            return createSlideTransition(
              child: child,
              animation: animation,
              curve: curve,
            );
          case PageTransitionType.scale:
            return createScaleTransition(
              child: child,
              animation: animation,
              curve: curve,
            );
          case PageTransitionType.fadeSlide:
            return createFadeSlideTransition(
              child: child,
              animation: animation,
              curve: curve,
            );
          case PageTransitionType.fadeScale:
            return createFadeScaleTransition(
              child: child,
              animation: animation,
              curve: curve,
            );
        }
      },
    );
  }

  /// Create a hero transition
  static Widget createHeroTransition({
    required String tag,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }

  /// Create a morphing container transition
  static Widget createMorphingContainer({
    required Widget child,
    required Animation<double> animation,
    BorderRadius? beginBorderRadius,
    BorderRadius? endBorderRadius,
    Color? beginColor,
    Color? endColor,
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.lerp(
              beginBorderRadius ?? BorderRadius.zero,
              endBorderRadius ?? BorderRadius.zero,
              curvedAnimation.value,
            ),
            color: Color.lerp(
              beginColor ?? Colors.transparent,
              endColor ?? Colors.transparent,
              curvedAnimation.value,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// Page transition types
enum PageTransitionType {
  fade,
  slide,
  scale,
  fadeSlide,
  fadeScale,
}

/// Extension methods for easy animation usage
extension AnimationExtension on Widget {
  /// Add fade animation
  Widget withFadeAnimation({
    required Animation<double> animation,
    Duration duration = AnimationUtils.normalDuration,
    Curve curve = AnimationUtils.defaultCurve,
  }) {
    return AnimationUtils.createFadeTransition(
      child: this,
      animation: animation,
      duration: duration,
      curve: curve,
    );
  }

  /// Add slide animation
  Widget withSlideAnimation({
    required Animation<double> animation,
    Offset begin = const Offset(0.0, 1.0),
    Offset end = Offset.zero,
    Duration duration = AnimationUtils.normalDuration,
    Curve curve = AnimationUtils.defaultCurve,
  }) {
    return AnimationUtils.createSlideTransition(
      child: this,
      animation: animation,
      begin: begin,
      end: end,
      duration: duration,
      curve: curve,
    );
  }

  /// Add scale animation
  Widget withScaleAnimation({
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = AnimationUtils.normalDuration,
    Curve curve = AnimationUtils.defaultCurve,
  }) {
    return AnimationUtils.createScaleTransition(
      child: this,
      animation: animation,
      begin: begin,
      end: end,
      duration: duration,
      curve: curve,
    );
  }

  /// Add pulse animation
  Widget withPulseAnimation({
    required Animation<double> animation,
    double minScale = 0.95,
    double maxScale = 1.05,
    Duration duration = AnimationUtils.normalDuration,
  }) {
    return AnimationUtils.createPulseAnimation(
      child: this,
      animation: animation,
      minScale: minScale,
      maxScale: maxScale,
      duration: duration,
    );
  }

  /// Add hero transition
  Widget withHero({
    required String tag,
    VoidCallback? onTap,
  }) {
    return AnimationUtils.createHeroTransition(
      tag: tag,
      child: this,
      onTap: onTap,
    );
  }
}

/// Animation controller helper
class AnimationControllerHelper {
  /// Create a repeating animation controller
  static AnimationController createRepeatingController({
    required TickerProvider vsync,
    Duration duration = AnimationUtils.normalDuration,
    bool reverse = false,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    if (reverse) {
      controller.repeat(reverse: true);
    } else {
      controller.repeat();
    }
    
    return controller;
  }

  /// Create a forward animation controller
  static AnimationController createForwardController({
    required TickerProvider vsync,
    Duration duration = AnimationUtils.normalDuration,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    controller.forward();
    return controller;
  }

  /// Create a sequence of animations
  static List<Animation<double>> createSequence({
    required AnimationController controller,
    required List<double> intervals,
    Curve curve = AnimationUtils.defaultCurve,
  }) {
    final animations = <Animation<double>>[];
    
    for (int i = 0; i < intervals.length - 1; i++) {
      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              intervals[i],
              intervals[i + 1],
              curve: curve,
            ),
          ),
        ),
      );
    }
    
    return animations;
  }
}