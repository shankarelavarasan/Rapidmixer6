import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Utility class for creating glassmorphism effects throughout the application
class GlassmorphismUtils {
  GlassmorphismUtils._();

  /// Creates a glassmorphism container with frosted glass effect
  static Widget createGlassContainer({
    required Widget child,
    double borderRadius = 16.0,
    double blur = 10.0,
    double opacity = 0.1,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppTheme.surfaceColor.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppTheme.borderColor.withOpacity(0.3),
                width: borderWidth,
              ),
              boxShadow: boxShadow ?? [
                BoxShadow(
                  color: AppTheme.shadowDark.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Creates a glassmorphism card with enhanced visual effects
  static Widget createGlassCard({
    required Widget child,
    double borderRadius = 12.0,
    double blur = 8.0,
    double opacity = 0.15,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    bool showShimmer = false,
    Color? glowColor,
  }) {
    Widget cardContent = createGlassContainer(
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      child: child,
    );

    if (showShimmer) {
      cardContent = _addShimmerEffect(cardContent);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// Creates a glassmorphism button with ripple effects
  static Widget createGlassButton({
    required Widget child,
    required VoidCallback onPressed,
    double borderRadius = 8.0,
    double blur = 6.0,
    double opacity = 0.2,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? splashColor,
    Color? glowColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Material(
          color: backgroundColor ?? AppTheme.accentColor.withOpacity(opacity),
          child: InkWell(
            onTap: onPressed,
            splashColor: splashColor ?? AppTheme.accentColor.withOpacity(0.3),
            highlightColor: AppTheme.accentColor.withOpacity(0.1),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.borderColor.withOpacity(0.3),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a glassmorphism modal/dialog background
  static Widget createGlassModal({
    required Widget child,
    double borderRadius = 20.0,
    double blur = 15.0,
    double opacity = 0.1,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return createGlassContainer(
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding ?? const EdgeInsets.all(24),
      margin: margin ?? const EdgeInsets.all(20),
      boxShadow: [
        BoxShadow(
          color: AppTheme.shadowDark.withOpacity(0.3),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ],
      child: child,
    );
  }

  /// Creates a glassmorphism navigation bar
  static Widget createGlassNavBar({
    required Widget child,
    double borderRadius = 0.0,
    double blur = 12.0,
    double opacity = 0.15,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(opacity),
            border: Border(
              top: BorderSide(
                color: AppTheme.borderColor.withOpacity(0.3),
                width: 1.0,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Creates a glassmorphism app bar
  static PreferredSizeWidget createGlassAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    double blur = 10.0,
    double opacity = 0.1,
    double elevation = 0.0,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: AppBar(
            title: Text(title),
            actions: actions,
            leading: leading,
            backgroundColor: AppTheme.primaryDark.withOpacity(opacity),
            elevation: elevation,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderColor.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Creates animated glassmorphism transition
  static Widget createAnimatedGlass({
    required Widget child,
    required Animation<double> animation,
    double borderRadius = 12.0,
    double maxBlur = 10.0,
    double maxOpacity = 0.15,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return createGlassContainer(
          borderRadius: borderRadius,
          blur: maxBlur * animation.value,
          opacity: maxOpacity * animation.value,
          child: child,
        );
      },
    );
  }

  /// Adds shimmer effect to glassmorphism elements
  static Widget _addShimmerEffect(Widget child) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    AppTheme.accentColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Creates a glassmorphism slider track
  static Widget createGlassSliderTrack({
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    Color? activeColor,
    Color? inactiveColor,
    double borderRadius = 8.0,
    double blur = 4.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppTheme.borderColor.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(null!).copyWith(
              activeTrackColor: activeColor ?? AppTheme.accentColor,
              inactiveTrackColor: inactiveColor ?? AppTheme.borderColor.withOpacity(0.3),
              thumbColor: AppTheme.accentColor,
              overlayColor: AppTheme.accentColor.withOpacity(0.2),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension methods for adding glassmorphism effects to existing widgets
extension GlassmorphismExtension on Widget {
  /// Wraps the widget with a glassmorphism container
  Widget withGlass({
    double borderRadius = 12.0,
    double blur = 8.0,
    double opacity = 0.15,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphismUtils.createGlassContainer(
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding,
      margin: margin,
      child: this,
    );
  }

  /// Wraps the widget with a glassmorphism card
  Widget withGlassCard({
    double borderRadius = 12.0,
    double blur = 8.0,
    double opacity = 0.15,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return GlassmorphismUtils.createGlassCard(
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: this,
    );
  }
}