// lib/services/responsive_service.dart
import 'package:flutter/material.dart';

class ResponsiveService {
  // Base dimensions for scaling calculations
  static const double _baseWidth = 393.0; // iPhone 14 Pro width
  static const double _baseHeight = 852.0; // iPhone 14 Pro height

  // Device type breakpoints
  static const double _tabletBreakpoint = 600.0;
  static const double _smallDeviceBreakpoint = 360.0;
  static const double _largeTabletBreakpoint = 900.0;

  final BuildContext _context;
  late final Size _screenSize;
  late final double _screenWidth;
  late final double _screenHeight;
  late final EdgeInsets _safeArea;
  late final EdgeInsets _viewInsets;

  ResponsiveService(this._context) {
    _screenSize = MediaQuery.of(_context).size;
    _screenWidth = _screenSize.width;
    _screenHeight = _screenSize.height;
    _safeArea = MediaQuery.of(_context).padding;
    _viewInsets = MediaQuery.of(_context).viewInsets;
  }

  // Device type getters
  bool get isSmallDevice => _screenWidth < _smallDeviceBreakpoint;
  bool get isTablet => _screenWidth >= _tabletBreakpoint && _screenWidth < _largeTabletBreakpoint;
  bool get isLargeTablet => _screenWidth >= _largeTabletBreakpoint;
  bool get isMobile => _screenWidth < _tabletBreakpoint;
  bool get isLandscape => _screenWidth > _screenHeight;
  bool get isPortrait => _screenHeight > _screenWidth;

  // Screen dimension getters
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  Size get screenSize => _screenSize;
  EdgeInsets get safeArea => _safeArea;
  EdgeInsets get viewInsets => _viewInsets;

  // Responsive scaling methods
  double scaleWidth(double width) {
    return width * (_screenWidth / _baseWidth);
  }

  double scaleHeight(double height) {
    return height * (_screenHeight / _baseHeight);
  }

  double scale(double size) {
    // Use the smaller scale factor to maintain aspect ratio
    final widthScale = _screenWidth / _baseWidth;
    final heightScale = _screenHeight / _baseHeight;
    return size * (widthScale < heightScale ? widthScale : heightScale);
  }

  // Font size scaling
  double scaleFontSize(double fontSize) {
    if (isSmallDevice) {
      return fontSize * 0.85;
    } else if (isTablet) {
      return fontSize * 1.1;
    } else if (isLargeTablet) {
      return fontSize * 1.2;
    }
    return fontSize;
  }

  // Responsive padding methods
  EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: scale(left ?? horizontal ?? all ?? 0),
      top: scale(top ?? vertical ?? all ?? 0),
      right: scale(right ?? horizontal ?? all ?? 0),
      bottom: scale(bottom ?? vertical ?? all ?? 0),
    );
  }

  EdgeInsets get defaultScreenPadding {
    if (isLargeTablet) {
      return EdgeInsets.symmetric(horizontal: _screenWidth * 0.15);
    } else if (isTablet) {
      return EdgeInsets.symmetric(horizontal: _screenWidth * 0.1);
    }
    return EdgeInsets.symmetric(horizontal: scale(20));
  }

  EdgeInsets get formPadding {
    return EdgeInsets.only(
      left: _viewInsets.left + (isTablet ? scale(40) : scale(30)),
      right: _viewInsets.right + (isTablet ? scale(40) : scale(30)),
      top: _viewInsets.top + scale(20),
      bottom: _viewInsets.bottom + scale(20),
    );
  }

  // Responsive sizing for common UI elements
  double get appBarHeight {
    if (isTablet) return scale(64);
    return scale(56);
  }

  double get buttonHeight {
    if (isSmallDevice) return scale(44);
    if (isTablet) return scale(52);
    return scale(48);
  }

  double get inputFieldHeight {
    if (isSmallDevice) return scale(48);
    if (isTablet) return scale(56);
    return scale(52);
  }

  double get iconSize {
    if (isSmallDevice) return scale(30);
    if (isTablet) return scale(38);
    return scale(34);
  }

  double get socialButtonSize {
    return scale(48);
  }

  // Container and layout constraints
  BoxConstraints get formConstraints {
    if (isLargeTablet) {
      return BoxConstraints(maxWidth: 500, minHeight: _screenHeight * 0.4);
    } else if (isTablet) {
      return BoxConstraints(maxWidth: 400, minHeight: _screenHeight * 0.4);
    }
    return BoxConstraints(minHeight: _screenHeight * 0.4);
  }

  BoxConstraints get contentConstraints {
    if (isLargeTablet) {
      return BoxConstraints(maxWidth: 800);
    } else if (isTablet) {
      return BoxConstraints(maxWidth: 600);
    }
    return const BoxConstraints();
  }

  // Spacing helpers
  SizedBox verticalSpace(double height) => SizedBox(height: scale(height));
  SizedBox horizontalSpace(double width) => SizedBox(width: scale(width));

  // Common responsive spacings
  SizedBox get smallVerticalSpace => verticalSpace(8);
  SizedBox get mediumVerticalSpace => verticalSpace(16);
  SizedBox get largeVerticalSpace => verticalSpace(24);
  SizedBox get extraLargeVerticalSpace => verticalSpace(150);

  SizedBox get smallHorizontalSpace => horizontalSpace(8);
  SizedBox get mediumHorizontalSpace => horizontalSpace(16);
  SizedBox get largeHorizontalSpace => horizontalSpace(24);

  // Text styles with responsive font sizes
  TextStyle responsiveTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: scaleFontSize(fontSize),
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Predefined text styles
  TextStyle get headingLarge => responsiveTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  TextStyle get headingMedium => responsiveTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  TextStyle get headingSmall => responsiveTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  TextStyle get bodyLarge => responsiveTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  TextStyle get bodyMedium => responsiveTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  TextStyle get bodySmall => responsiveTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  TextStyle get labelLarge => responsiveTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  TextStyle get labelMedium => responsiveTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  TextStyle get labelSmall => responsiveTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Responsive border radius
  BorderRadius responsiveBorderRadius(double radius) {
    return BorderRadius.circular(scale(radius));
  }

  BorderRadius get smallBorderRadius => responsiveBorderRadius(4);
  BorderRadius get mediumBorderRadius => responsiveBorderRadius(8);
  BorderRadius get largeBorderRadius => responsiveBorderRadius(12);
  BorderRadius get extraLargeBorderRadius => responsiveBorderRadius(16);

  // Layout-specific helpers
  double get brandFontSize {
    if (isLargeTablet) return scaleFontSize(48);
    if (isTablet) return scaleFontSize(42);
    return scaleFontSize(36);
  }

  double get brandSpacing => scale(isTablet ? 60 : 40);

  double get tabBarHorizontalPadding {
    if (isLargeTablet) return _screenWidth * 0.25;
    if (isTablet) return _screenWidth * 0.2;
    return scale(20);
  }

  double get contentHorizontalPadding {
    if (isLargeTablet) return _screenWidth * 0.25;
    if (isTablet) return _screenWidth * 0.2;
    return 0;
  }

  double get maxContentWidth {
    if (isLargeTablet) return _screenWidth * 0.5;
    if (isTablet) return _screenWidth * 0.6;
    return _screenWidth - scale(120);
  }

  Widget maxWidthContainer({required Widget child}) {
    return Container(
      width: maxContentWidth,
      child: child,
    );
  }

  // Animation durations based on device performance
  Duration get fastAnimation {
    if (isSmallDevice) return const Duration(milliseconds: 200);
    return const Duration(milliseconds: 150);
  }

  Duration get normalAnimation {
    if (isSmallDevice) return const Duration(milliseconds: 350);
    return const Duration(milliseconds: 300);
  }

  Duration get slowAnimation {
    if (isSmallDevice) return const Duration(milliseconds: 600);
    return const Duration(milliseconds: 500);
  }
}

// Extension to make ResponsiveService easily accessible
extension ResponsiveContext on BuildContext {
  ResponsiveService get responsive => ResponsiveService(this);
}