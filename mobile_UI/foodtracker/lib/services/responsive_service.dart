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
  static const double _desktopBreakpoint = 1200.0;

  final BuildContext _context;
  late final Size _screenSize;
  late final double _screenWidth;
  late final double _screenHeight;
  late final EdgeInsets _safeArea;
  late final EdgeInsets _viewInsets;
  late final double _devicePixelRatio;
  late final Orientation _orientation;

  ResponsiveService(this._context) {
    final mediaQuery = MediaQuery.of(_context);
    _screenSize = mediaQuery.size;
    _screenWidth = _screenSize.width;
    _screenHeight = _screenSize.height;
    _safeArea = mediaQuery.padding;
    _viewInsets = mediaQuery.viewInsets;
    _devicePixelRatio = mediaQuery.devicePixelRatio;
    _orientation = mediaQuery.orientation;
  }

  // Device type getters
  bool get isSmallDevice => _screenWidth < _smallDeviceBreakpoint;
  bool get isMediumDevice => _screenWidth >= _smallDeviceBreakpoint && _screenWidth < _tabletBreakpoint;
  bool get isTablet => _screenWidth >= _tabletBreakpoint && _screenWidth < _largeTabletBreakpoint;
  bool get isLargeTablet => _screenWidth >= _largeTabletBreakpoint && _screenWidth < _desktopBreakpoint;
  bool get isDesktop => _screenWidth >= _desktopBreakpoint;
  bool get isMobile => _screenWidth < _tabletBreakpoint;
  bool get isLandscape => _orientation == Orientation.landscape;
  bool get isPortrait => _orientation == Orientation.portrait;

  // Screen dimension getters
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  Size get screenSize => _screenSize;
  EdgeInsets get safeArea => _safeArea;
  EdgeInsets get viewInsets => _viewInsets;
  double get devicePixelRatio => _devicePixelRatio;
  Orientation get orientation => _orientation;

  // Available screen dimensions (excluding safe areas)
  double get availableWidth => _screenWidth;
  double get availableHeight => _screenHeight - _safeArea.top - _safeArea.bottom;
  double get usableHeight => availableHeight - _viewInsets.bottom;

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

  // Advanced scaling with min/max constraints
  double scaleBetween(double size, {double? minScale, double? maxScale}) {
    double scaled = scale(size);
    if (minScale != null) scaled = scaled < minScale ? minScale : scaled;
    if (maxScale != null) scaled = scaled > maxScale ? maxScale : scaled;
    return scaled;
  }

  // Percentage-based scaling
  double widthPercent(double percentage) => _screenWidth * (percentage / 100);
  double heightPercent(double percentage) => _screenHeight * (percentage / 100);

  // Font size scaling with device-specific adjustments
  double scaleFontSize(double fontSize) {
    double scaledSize = fontSize;

    if (isSmallDevice) {
      scaledSize = fontSize * 0.85;
    } else if (isTablet) {
      scaledSize = fontSize * 1.1;
    } else if (isLargeTablet) {
      scaledSize = fontSize * 1.2;
    } else if (isDesktop) {
      scaledSize = fontSize * 1.3;
    }

    // Apply base scaling
    return scale(scaledSize);
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

  // Symmetric padding helpers
  EdgeInsets symmetricPadding({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: scale(horizontal ?? 0),
      vertical: scale(vertical ?? 0),
    );
  }

  // Screen-specific padding
  EdgeInsets get defaultScreenPadding {
    if (isDesktop) {
      return EdgeInsets.symmetric(horizontal: _screenWidth * 0.2);
    } else if (isLargeTablet) {
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

  // Card and container padding
  EdgeInsets get cardPadding {
    if (isDesktop) return responsivePadding(all: 24);
    if (isLargeTablet) return responsivePadding(all: 20);
    if (isTablet) return responsivePadding(all: 16);
    return responsivePadding(all: 12);
  }

  EdgeInsets get listItemPadding {
    return responsivePadding(horizontal: 16, vertical: 12);
  }

  // Responsive sizing for common UI elements
  double get appBarHeight {
    if (isDesktop) return scale(72);
    if (isLargeTablet) return scale(68);
    if (isTablet) return scale(64);
    return scale(56);
  }

  double get buttonHeight {
    if (isSmallDevice) return scale(44);
    if (isTablet) return scale(52);
    if (isLargeTablet) return scale(56);
    if (isDesktop) return scale(60);
    return scale(48);
  }

  double get smallButtonHeight {
    if (isSmallDevice) return scale(32);
    if (isTablet) return scale(38);
    if (isLargeTablet) return scale(42);
    return scale(36);
  }

  double get inputFieldHeight {
    if (isSmallDevice) return scale(48);
    if (isTablet) return scale(56);
    if (isLargeTablet) return scale(60);
    if (isDesktop) return scale(64);
    return scale(52);
  }

  // Icon sizes with device-specific scaling
  double get iconSize {
    if (isSmallDevice) return scale(20);
    if (isTablet) return scale(24);
    if (isLargeTablet) return scale(28);
    if (isDesktop) return scale(32);
    return scale(22);
  }

  double get smallIconSize {
    if (isSmallDevice) return scale(16);
    if (isTablet) return scale(18);
    if (isLargeTablet) return scale(20);
    if (isDesktop) return scale(22);
    return scale(18);
  }

  double get largeIconSize {
    if (isSmallDevice) return scale(28);
    if (isTablet) return scale(32);
    if (isLargeTablet) return scale(36);
    if (isDesktop) return scale(40);
    return scale(30);
  }

  double get socialButtonSize {
    if (isSmallDevice) return scale(44);
    if (isTablet) return scale(52);
    if (isLargeTablet) return scale(56);
    if (isDesktop) return scale(60);
    return scale(48);
  }

  // Avatar sizes
  double get avatarSizeSmall => scale(32);
  double get avatarSizeMedium => scale(48);
  double get avatarSizeLarge => scale(64);
  double get avatarSizeXLarge => scale(96);

  // Container and layout constraints
  BoxConstraints get formConstraints {
    if (isDesktop) {
      return BoxConstraints(maxWidth: 600, minHeight: _screenHeight * 0.4);
    } else if (isLargeTablet) {
      return BoxConstraints(maxWidth: 500, minHeight: _screenHeight * 0.4);
    } else if (isTablet) {
      return BoxConstraints(maxWidth: 400, minHeight: _screenHeight * 0.4);
    }
    return BoxConstraints(minHeight: _screenHeight * 0.4);
  }

  BoxConstraints get contentConstraints {
    if (isDesktop) {
      return BoxConstraints(maxWidth: 1200);
    } else if (isLargeTablet) {
      return BoxConstraints(maxWidth: 800);
    } else if (isTablet) {
      return BoxConstraints(maxWidth: 600);
    }
    return const BoxConstraints();
  }

  BoxConstraints get cardConstraints {
    if (isDesktop) {
      return BoxConstraints(maxWidth: 400, minHeight: scale(200));
    } else if (isLargeTablet) {
      return BoxConstraints(maxWidth: 350, minHeight: scale(180));
    } else if (isTablet) {
      return BoxConstraints(maxWidth: 300, minHeight: scale(160));
    }
    return BoxConstraints(minHeight: scale(140));
  }

  // Spacing helpers with more granular control
  SizedBox verticalSpace(double height) => SizedBox(height: scale(height));
  SizedBox horizontalSpace(double width) => SizedBox(width: scale(width));

  // Common responsive spacings
  SizedBox get tinyVerticalSpace => verticalSpace(4);
  SizedBox get smallVerticalSpace => verticalSpace(8);
  SizedBox get mediumVerticalSpace => verticalSpace(16);
  SizedBox get largeVerticalSpace => verticalSpace(24);
  SizedBox get extraLargeVerticalSpace => verticalSpace(32);
  SizedBox get massiveVerticalSpace => verticalSpace(48);

  SizedBox get tinyHorizontalSpace => horizontalSpace(4);
  SizedBox get smallHorizontalSpace => horizontalSpace(8);
  SizedBox get mediumHorizontalSpace => horizontalSpace(16);
  SizedBox get largeHorizontalSpace => horizontalSpace(24);
  SizedBox get extraLargeHorizontalSpace => horizontalSpace(32);

  // Special spacing for specific contexts
  SizedBox get sectionSpacing => verticalSpace(isTablet ? 32 : 24);
  SizedBox get listItemSpacing => verticalSpace(8);
  SizedBox get formFieldSpacing => verticalSpace(16);

  // Text styles with enhanced responsive font sizes
  TextStyle responsiveTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: scaleFontSize(fontSize),
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
      letterSpacing: letterSpacing != null ? scale(letterSpacing) : null,
      height: height,
      decoration: decoration,
    );
  }

  // Enhanced predefined text styles
  TextStyle get displayLarge => responsiveTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
  );

  TextStyle get displayMedium => responsiveTextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );

  TextStyle get displaySmall => responsiveTextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  TextStyle get headlineLarge => responsiveTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
  );

  TextStyle get headlineMedium => responsiveTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  );

  TextStyle get headlineSmall => responsiveTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  TextStyle get titleLarge => responsiveTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
  );

  TextStyle get titleMedium => responsiveTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  TextStyle get titleSmall => responsiveTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  TextStyle get bodyLarge => responsiveTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  TextStyle get bodyMedium => responsiveTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  TextStyle get bodySmall => responsiveTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  TextStyle get labelLarge => responsiveTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  TextStyle get labelMedium => responsiveTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  TextStyle get labelSmall => responsiveTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // Custom text styles for specific use cases
  TextStyle get buttonTextStyle => responsiveTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  TextStyle get captionStyle => responsiveTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade600,
  );

  TextStyle get overlineStyle => responsiveTextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
  );

  // Responsive border radius with enhanced options
  BorderRadius responsiveBorderRadius(double radius) {
    return BorderRadius.circular(scale(radius));
  }

  BorderRadius get tinyBorderRadius => responsiveBorderRadius(2);
  BorderRadius get smallBorderRadius => responsiveBorderRadius(4);
  BorderRadius get mediumBorderRadius => responsiveBorderRadius(8);
  BorderRadius get largeBorderRadius => responsiveBorderRadius(12);
  BorderRadius get extraLargeBorderRadius => responsiveBorderRadius(16);
  BorderRadius get circularBorderRadius => responsiveBorderRadius(50);

  // Custom border radius for specific components
  BorderRadius get buttonBorderRadius => responsiveBorderRadius(isTablet ? 12 : 8);
  BorderRadius get cardBorderRadius => responsiveBorderRadius(isTablet ? 16 : 12);
  BorderRadius get inputBorderRadius => responsiveBorderRadius(8);

  // Layout-specific helpers with enhanced calculations
  double get brandFontSize {
    if (isDesktop) return scaleFontSize(52);
    if (isLargeTablet) return scaleFontSize(48);
    if (isTablet) return scaleFontSize(42);
    return scaleFontSize(36);
  }

  double get brandSpacing => scale(isTablet ? 60 : 40);

  double get tabBarHorizontalPadding {
    if (isDesktop) return _screenWidth * 0.3;
    if (isLargeTablet) return _screenWidth * 0.25;
    if (isTablet) return _screenWidth * 0.2;
    return scale(20);
  }

  double get contentHorizontalPadding {
    if (isDesktop) return _screenWidth * 0.3;
    if (isLargeTablet) return _screenWidth * 0.25;
    if (isTablet) return _screenWidth * 0.2;
    return 0;
  }

  double get maxContentWidth {
    if (isDesktop) return _screenWidth * 0.4;
    if (isLargeTablet) return _screenWidth * 0.5;
    if (isTablet) return _screenWidth * 0.6;
    return _screenWidth - scale(120);
  }

  // Grid and list layout helpers
  int get gridCrossAxisCount {
    if (isDesktop) return 4;
    if (isLargeTablet) return 3;
    if (isTablet) return 2;
    return 1;
  }

  double get gridSpacing {
    if (isTablet) return scale(16);
    return scale(12);
  }

  double get listTileHeight {
    if (isTablet) return scale(80);
    return scale(72);
  }

  // Container helpers with enhanced functionality
  Widget maxWidthContainer({required Widget child}) {
    return Container(
      width: maxContentWidth,
      child: child,
    );
  }

  Widget responsiveContainer({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxConstraints? constraints,
    Decoration? decoration,
  }) {
    return Container(
      padding: padding ?? cardPadding,
      margin: margin,
      constraints: constraints ?? contentConstraints,
      decoration: decoration,
      child: child,
    );
  }

  // Animation durations based on device performance and type
  Duration get microAnimation => const Duration(milliseconds: 100);
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

  Duration get pageTransitionDuration => const Duration(milliseconds: 300);

  // Elevation and shadow helpers
  double get cardElevation {
    if (isTablet) return 8.0;
    return 4.0;
  }

  double get buttonElevation {
    if (isTablet) return 4.0;
    return 2.0;
  }

  // Helper methods for common responsive patterns
  T deviceValue<T>({
    required T mobile,
    T? tablet,
    T? largeTablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isLargeTablet && largeTablet != null) return largeTablet;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Breakpoint-specific values
  T breakpointValue<T>({
    T? small,
    T? medium,
    T? tablet,
    T? largeTablet,
    T? desktop,
    required T fallback,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isLargeTablet && largeTablet != null) return largeTablet;
    if (isTablet && tablet != null) return tablet;
    if (isMediumDevice && medium != null) return medium;
    if (isSmallDevice && small != null) return small;
    return fallback;
  }
}

// Extension to make ResponsiveService easily accessible
extension ResponsiveContext on BuildContext {
  ResponsiveService get responsive => ResponsiveService(this);
}