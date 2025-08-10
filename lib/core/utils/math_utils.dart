import 'dart:math' as math;

/// Utility class for mathematical operations with NaN validation
class MathUtils {
  /// Safely performs truncating division with NaN validation
  static int safeTruncatingDivision(double dividend, double divisor) {
    // Validate inputs
    if (dividend.isNaN || dividend.isInfinite) {
      return 0;
    }
    if (divisor.isNaN || divisor.isInfinite || divisor == 0.0) {
      return 0;
    }
    
    // Perform safe division
    final result = dividend / divisor;
    if (result.isNaN || result.isInfinite) {
      return 0;
    }
    
    return result.truncate();
  }

  /// Safely calculates angle in radians with validation
  static double safeAngleCalculation(double value, double total) {
    if (value.isNaN || value.isInfinite || total.isNaN || total.isInfinite || total == 0.0) {
      return 0.0;
    }
    
    final angle = (value / total) * 2 * math.pi;
    return angle.isNaN || angle.isInfinite ? 0.0 : angle;
  }

  /// Safely converts radians to degrees with validation
  static double safeRadiansToDegrees(double radians) {
    if (radians.isNaN || radians.isInfinite) {
      return 0.0;
    }
    
    final degrees = radians * 180.0 / math.pi;
    return degrees.isNaN || degrees.isInfinite ? 0.0 : degrees;
  }

  /// Safely converts degrees to radians with validation
  static double safeDegreesToRadians(double degrees) {
    if (degrees.isNaN || degrees.isInfinite) {
      return 0.0;
    }
    
    final radians = degrees * math.pi / 180.0;
    return radians.isNaN || radians.isInfinite ? 0.0 : radians;
  }

  /// Safely calculates progress percentage with validation
  static double safeProgressCalculation(double current, double total) {
    if (current.isNaN || current.isInfinite || total.isNaN || total.isInfinite || total == 0.0) {
      return 0.0;
    }
    
    final progress = (current / total) * 100.0;
    return progress.isNaN || progress.isInfinite ? 0.0 : progress.clamp(0.0, 100.0);
  }

  /// Safely performs modulo operation with validation
  static double safeModulo(double dividend, double divisor) {
    if (dividend.isNaN || dividend.isInfinite || divisor.isNaN || divisor.isInfinite || divisor == 0.0) {
      return 0.0;
    }
    
    final result = dividend % divisor;
    return result.isNaN || result.isInfinite ? 0.0 : result;
  }

  /// Safely calculates sine with validation
  static double safeSin(double angle) {
    if (angle.isNaN || angle.isInfinite) {
      return 0.0;
    }
    
    final result = math.sin(angle);
    return result.isNaN || result.isInfinite ? 0.0 : result;
  }

  /// Safely calculates cosine with validation
  static double safeCos(double angle) {
    if (angle.isNaN || angle.isInfinite) {
      return 1.0; // cos(0) = 1
    }
    
    final result = math.cos(angle);
    return result.isNaN || result.isInfinite ? 1.0 : result;
  }

  /// Validates and clamps a value to prevent NaN propagation
  static double validateAndClamp(double value, double min, double max) {
    if (value.isNaN || value.isInfinite) {
      return (min + max) / 2; // Return middle value as default
    }
    return value.clamp(min, max);
  }

  /// Safely performs division with fallback value
  static double safeDivision(double dividend, double divisor, [double fallback = 0.0]) {
    if (dividend.isNaN || dividend.isInfinite || divisor.isNaN || divisor.isInfinite || divisor == 0.0) {
      return fallback;
    }
    
    final result = dividend / divisor;
    return result.isNaN || result.isInfinite ? fallback : result;
  }

  /// Safely performs truncating division specifically for angle calculations
  static int safeTruncatingDivisionForAngles(double angleInDegrees, double divisor) {
    // Special handling for angle values around 359.8888888888889
    if (angleInDegrees.isNaN || angleInDegrees.isInfinite) {
      return 0;
    }
    if (divisor.isNaN || divisor.isInfinite || divisor == 0.0) {
      return 0;
    }
    
    // Normalize angle to 0-360 range first
    final normalizedAngle = safeModulo(angleInDegrees, 360.0);
    
    // Perform safe division
    final result = normalizedAngle / divisor;
    if (result.isNaN || result.isInfinite) {
      return 0;
    }
    
    return result.truncate();
  }

  /// Safely normalizes angle to 0-360 degree range
  static double normalizeAngleDegrees(double angle) {
    if (angle.isNaN || angle.isInfinite) {
      return 0.0;
    }
    
    final normalized = angle % 360.0;
    if (normalized.isNaN || normalized.isInfinite) {
      return 0.0;
    }
    
    return normalized < 0 ? normalized + 360.0 : normalized;
  }

  /// Safely normalizes angle to 0-2π radian range
  static double normalizeAngleRadians(double angle) {
    if (angle.isNaN || angle.isInfinite) {
      return 0.0;
    }
    
    final normalized = angle % (2 * math.pi);
    if (normalized.isNaN || normalized.isInfinite) {
      return 0.0;
    }
    
    return normalized < 0 ? normalized + (2 * math.pi) : normalized;
  }

  /// Safely performs power operation with validation
  static double safePow(double base, double exponent) {
    if (base.isNaN || base.isInfinite || exponent.isNaN || exponent.isInfinite) {
      return 1.0; // Return neutral value for power operations
    }
    
    final result = math.pow(base, exponent).toDouble();
    return result.isNaN || result.isInfinite ? 1.0 : result;
  }
}