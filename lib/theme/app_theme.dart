import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the mobile audio editing application.
class AppTheme {
  AppTheme._();

  // Studio Dark Professional Color Palette
  static const Color primaryDark = Color(0xFF1A1A1A); // Deep studio background
  static const Color secondaryDark =
      Color(0xFF2D2D30); // Elevated surface color
  static const Color accentColor =
      Color(0xFF00D4FF); // High-visibility audio control highlight
  static const Color successColor =
      Color(0xFF00C896); // Recording and export completion states
  static const Color warningColor =
      Color(0xFFFFB800); // Audio clipping and processing alerts
  static const Color errorColor = Color(0xFFFF4757); // Critical audio errors
  static const Color textPrimary =
      Color(0xFFFFFFFF); // Maximum contrast white text
  static const Color textSecondary = Color(0xFFB0B0B0); // Reduced emphasis text
  static const Color surfaceColor =
      Color(0xFF252528); // Modal and sheet backgrounds
  static const Color borderColor =
      Color(0xFF404040); // Minimal track separation

  // Light theme variants (for potential future use)
  static const Color primaryLight = Color(0xFFF5F5F5);
  static const Color secondaryLight = Color(0xFFE0E0E0);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color onPrimaryLight = Color(0xFF000000);
  static const Color onSecondaryLight = Color(0xFF000000);
  static const Color onBackgroundLight = Color(0xFF000000);
  static const Color onSurfaceLight = Color(0xFF000000);

  // Shadow and elevation colors
  static const Color shadowDark =
      Color(0x1A000000); // 2dp shadows with 0.1 opacity
  static const Color shadowLight = Color(0x1F000000);

  // Text emphasis colors for dark theme
  static const Color textHighEmphasisDark = Color(0xFFFFFFFF); // 100% opacity
  static const Color textMediumEmphasisDark = Color(0xB3FFFFFF); // 70% opacity
  static const Color textDisabledDark = Color(0x61FFFFFF); // 38% opacity

  // Text emphasis colors for light theme
  static const Color textHighEmphasisLight = Color(0xDE000000); // 87% opacity
  static const Color textMediumEmphasisLight = Color(0x99000000); // 60% opacity
  static const Color textDisabledLight = Color(0x61000000); // 38% opacity

  /// Dark theme - Primary theme for audio editing application
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: accentColor,
      onPrimary: primaryDark,
      primaryContainer: secondaryDark,
      onPrimaryContainer: textPrimary,
      secondary: successColor,
      onSecondary: primaryDark,
      secondaryContainer: surfaceColor,
      onSecondaryContainer: textPrimary,
      tertiary: warningColor,
      onTertiary: primaryDark,
      tertiaryContainer: surfaceColor,
      onTertiaryContainer: textPrimary,
      error: errorColor,
      onError: textPrimary,
      surface: surfaceColor,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: borderColor,
      outlineVariant: borderColor,
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: primaryLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: accentColor,
    ),
    scaffoldBackgroundColor: primaryDark,
    cardColor: secondaryDark,
    dividerColor: borderColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: textPrimary,
      elevation: 2.0,
      shadowColor: shadowDark,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: secondaryDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: accentColor,
      unselectedItemColor: textSecondary,
      elevation: 2.0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: primaryDark,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryDark,
        backgroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2.0,
        shadowColor: shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: accentColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: false),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: secondaryDark,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: accentColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: errorColor, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledDark,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor;
        }
        return textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor.withValues(alpha: 0.3);
        }
        return borderColor;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(primaryDark),
      side: BorderSide(color: borderColor, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor;
        }
        return borderColor;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accentColor,
      linearTrackColor: borderColor,
      circularTrackColor: borderColor,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accentColor,
      thumbColor: accentColor,
      overlayColor: accentColor.withValues(alpha: 0.2),
      inactiveTrackColor: borderColor,
      trackHeight: 4.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: accentColor,
      unselectedLabelColor: textSecondary,
      indicatorColor: accentColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: shadowDark,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceColor,
      contentTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: accentColor,
      behavior: SnackBarBehavior.floating,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceColor,
      elevation: 2.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      modalBackgroundColor: surfaceColor,
      modalElevation: 2.0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      titleTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  /// Light theme - Alternative theme for different lighting conditions
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: accentColor,
      onPrimary: backgroundLight,
      primaryContainer: primaryLight,
      onPrimaryContainer: onPrimaryLight,
      secondary: successColor,
      onSecondary: backgroundLight,
      secondaryContainer: secondaryLight,
      onSecondaryContainer: onSecondaryLight,
      tertiary: warningColor,
      onTertiary: backgroundLight,
      tertiaryContainer: secondaryLight,
      onTertiaryContainer: onSecondaryLight,
      error: errorColor,
      onError: backgroundLight,
      surface: backgroundLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textMediumEmphasisLight,
      outline: borderColor,
      outlineVariant: borderColor,
      shadow: shadowLight,
      scrim: shadowLight,
      inverseSurface: primaryDark,
      onInverseSurface: textPrimary,
      inversePrimary: accentColor,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: primaryLight,
    dividerColor: borderColor,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: onBackgroundLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onBackgroundLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: primaryLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundLight,
      selectedItemColor: accentColor,
      unselectedItemColor: textMediumEmphasisLight,
      elevation: 2.0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: backgroundLight,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: backgroundLight,
        backgroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2.0,
        shadowColor: shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: accentColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: primaryLight,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: accentColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: errorColor, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textMediumEmphasisLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textMediumEmphasisLight,
      suffixIconColor: textMediumEmphasisLight,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor;
        }
        return textMediumEmphasisLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor.withValues(alpha: 0.3);
        }
        return borderColor;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(backgroundLight),
      side: BorderSide(color: borderColor, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor;
        }
        return borderColor;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accentColor,
      linearTrackColor: borderColor,
      circularTrackColor: borderColor,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accentColor,
      thumbColor: accentColor,
      overlayColor: accentColor.withValues(alpha: 0.2),
      inactiveTrackColor: borderColor,
      trackHeight: 4.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: accentColor,
      unselectedLabelColor: textMediumEmphasisLight,
      indicatorColor: accentColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: onSurfaceLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: shadowLight,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: GoogleFonts.inter(
        color: backgroundLight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: onSurfaceLight,
      contentTextStyle: GoogleFonts.inter(
        color: backgroundLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: accentColor,
      behavior: SnackBarBehavior.floating,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: backgroundLight,
      elevation: 2.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      modalBackgroundColor: backgroundLight,
      modalElevation: 2.0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: backgroundLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      titleTextStyle: GoogleFonts.inter(
        color: onBackgroundLight,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: GoogleFonts.inter(
        color: onBackgroundLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  /// Helper method to build text theme based on brightness
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis =
        isLight ? textHighEmphasisLight : textHighEmphasisDark;
    final Color textMediumEmphasis =
        isLight ? textMediumEmphasisLight : textMediumEmphasisDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
      // Display styles - Inter Medium/SemiBold for headers
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
      ),

      // Headline styles - Inter Medium/SemiBold for track names and headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
      ),

      // Title styles - Inter Medium for section headers
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.1,
      ),

      // Body styles - Inter Regular/Medium for descriptions and content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
        letterSpacing: 0.4,
      ),

      // Label styles - Inter Regular/Medium for metadata and controls
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMediumEmphasis,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textDisabled,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Custom text styles for audio-specific data using JetBrains Mono
  static TextStyle dataTextStyle({
    required bool isLight,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    final Color textColor =
        isLight ? textHighEmphasisLight : textHighEmphasisDark;
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
      letterSpacing: 0.5,
    );
  }

  /// Audio timecode text style
  static TextStyle timecodeTextStyle({required bool isLight}) {
    return dataTextStyle(
      isLight: isLight,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }

  /// BPM and technical specifications text style
  static TextStyle technicalTextStyle({required bool isLight}) {
    return dataTextStyle(
      isLight: isLight,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
  }
}
