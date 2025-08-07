import 'package:flutter/material.dart';

/// Utility class for responsive design across different screen sizes
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Screen breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Get responsive value based on device type
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: const EdgeInsets.all(12),
      tablet: const EdgeInsets.all(16),
      desktop: const EdgeInsets.all(20),
    );
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: const EdgeInsets.all(8),
      tablet: const EdgeInsets.all(12),
      desktop: const EdgeInsets.all(16),
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    return getResponsiveValue(
      context: context,
      mobile: baseFontSize * 0.9,
      tablet: baseFontSize,
      desktop: baseFontSize * 1.1,
    );
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    return getResponsiveValue(
      context: context,
      mobile: baseIconSize * 0.9,
      tablet: baseIconSize,
      desktop: baseIconSize * 1.1,
    );
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing * 0.8;
    } else if (isTablet(context)) {
      return baseSpacing * 0.9;
    }
    return baseSpacing;
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  /// Get responsive grid columns
  static int getResponsiveGridColumns(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }

  /// Get responsive slider height
  static double getResponsiveSliderHeight(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 60.0,
      tablet: 80.0,
      desktop: 100.0,
    );
  }

  /// Get responsive effects panel height
  static double getResponsiveEffectsPanelHeight(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 300.0,
      tablet: 400.0,
      desktop: 500.0,
    );
  }

  /// Get responsive waveform height
  static double getResponsiveWaveformHeight(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 80.0,
      tablet: 120.0,
      desktop: 150.0,
    );
  }

  /// Get responsive button size
  static Size getResponsiveButtonSize(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: const Size(120, 40),
      tablet: const Size(140, 45),
      desktop: const Size(160, 50),
    );
  }

  /// Get responsive tab bar height
  static double getResponsiveTabBarHeight(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 60.0,
      tablet: 70.0,
      desktop: 80.0,
    );
  }

  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 56.0,
      tablet: 64.0,
      desktop: 72.0,
    );
  }

  /// Get responsive bottom navigation height
  static double getResponsiveBottomNavHeight(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 60.0,
      tablet: 70.0,
      desktop: 80.0,
    );
  }

  /// Get responsive glassmorphism blur
  static double getResponsiveBlur(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 8.0,
      tablet: 10.0,
      desktop: 12.0,
    );
  }

  /// Get responsive glassmorphism opacity
  static double getResponsiveOpacity(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 0.12,
      tablet: 0.10,
      desktop: 0.08,
    );
  }

  /// Create responsive layout builder
  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget Function(BuildContext, DeviceType) builder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }

  /// Create responsive grid view
  static Widget responsiveGridView({
    required BuildContext context,
    required List<Widget> children,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
  }) {
    final columns = getResponsiveGridColumns(context);
    final spacing = getResponsiveMargin(context).left;
    
    return GridView.count(
      crossAxisCount: columns,
      childAspectRatio: childAspectRatio ?? 1.0,
      mainAxisSpacing: mainAxisSpacing ?? spacing,
      crossAxisSpacing: crossAxisSpacing ?? spacing,
      padding: getResponsivePadding(context),
      children: children,
    );
  }

  /// Create responsive wrap
  static Widget responsiveWrap({
    required BuildContext context,
    required List<Widget> children,
    WrapAlignment alignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
  }) {
    final spacing = getResponsiveMargin(context).left;
    
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  /// Create responsive row/column based on screen size
  static Widget responsiveRowColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    bool forceColumn = false,
  }) {
    final isMobileDevice = isMobile(context) || forceColumn;
    
    if (isMobileDevice) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// Get screen orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Get responsive animation duration
  static Duration getResponsiveAnimationDuration(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: const Duration(milliseconds: 200),
      tablet: const Duration(milliseconds: 250),
      desktop: const Duration(milliseconds: 300),
    );
  }

  /// Get responsive curve
  static Curve getResponsiveCurve(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: Curves.easeOut,
      tablet: Curves.easeInOut,
      desktop: Curves.easeInOutCubic,
    );
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extension methods for responsive design
extension ResponsiveExtension on Widget {
  /// Make widget responsive
  Widget responsive(BuildContext context) {
    return ResponsiveUtils.responsiveBuilder(
      context: context,
      builder: (context, deviceType) => this,
    );
  }

  /// Add responsive padding
  Widget withResponsivePadding(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: this,
    );
  }

  /// Add responsive margin
  Widget withResponsiveMargin(BuildContext context) {
    return Container(
      margin: ResponsiveUtils.getResponsiveMargin(context),
      child: this,
    );
  }

  /// Make widget adapt to orientation
  Widget adaptToOrientation(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return this;
      },
    );
  }
}

/// Responsive text style helper
class ResponsiveTextStyle {
  static TextStyle getResponsiveTextStyle({
    required BuildContext context,
    required TextStyle baseStyle,
    double? fontSizeMultiplier,
  }) {
    final multiplier = fontSizeMultiplier ?? 1.0;
    final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      (baseStyle.fontSize ?? 14) * multiplier,
    );
    
    return baseStyle.copyWith(fontSize: responsiveFontSize);
  }
}