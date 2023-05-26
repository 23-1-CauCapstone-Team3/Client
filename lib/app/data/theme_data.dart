import 'package:flutter/material.dart';

class CustomColors {
  static Color primaryTextColor = Colors.white;
  static Color dividerColor = Colors.white54;
  static Color pageBackgroundColor = Color(0xFF0A0A0A);
  static Color menuBackgroundColor = Color(0xFF131313);
  static Color tableBackgroundColor = Color(0xFF2C2C2D);
  static Color sheetBackgroundColor = Color(0xFF1C1C1D);

  static Color clockBG = Color(0xFF444974);
  static Color clockOutline = Color(0xFFEAECFF);
  static Color? secHandColor = Colors.orange[300];
  static Color minHandStatColor = Color(0xFF748EF6);
  static Color minHandEndColor = Color(0xFF77DDFF);
  static Color hourHandStatColor = Color(0xFFC279FB);
  static Color hourHandEndColor = Color(0xFFEA74AB);
}

class TransportColors {
  static List<Color> subway = [
    Color(0xFF000000),
    Color(0xFF0052A4),
    Color(0xFF00A84D),
    Color(0xFFEF7C1C),
    Color(0xFF00A5DE),
    Color(0xFF996CAC),
    Color(0xFFCD7C2F),
    Color(0xFF747F00),
    Color(0xFFE6186C),
    Color(0xFFBDB092),
  ];
  static List<Color> bus = [
    Color(0xFF000000),
    Color(0xFF33CC99),
    Color(0xFF0068b7),
    Color(0xFF53b332),
    Color(0xFFe60012),
    Color(0xFF00a0e9),
    Color(0xFFe60012),
    Color(0xFF000000),
    Color(0xFF000000),
    Color(0xFF000000),
    Color(0xFFfe5b10),
    Color(0xFF0068b7),
    Color(0xFF53b332),
    Color(0xFFf2b70a),
    Color(0xFFe60012),
    Color(0xFF006896),
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFF000000),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFF000000),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
  ];
}

class GradientColors {
  final List<Color> colors;
  GradientColors(this.colors);

  static List<Color> sky = [Color(0xFF6448FE), Color(0xFF5FC6FF)];
  static List<Color> sunset = [Color(0xFFFE6197), Color(0xFFFFB463)];
  static List<Color> sea = [Color(0xFF61A3FE), Color(0xFF63FFD5)];
  static List<Color> mango = [Color(0xFFFFA738), Color(0xFFFFE130)];
  static List<Color> fire = [Color(0xFFFF5DCD), Color(0xFFFF8484)];
}

class GradientTemplate {
  static List<GradientColors> gradientTemplate = [
    GradientColors(GradientColors.sky),
    GradientColors(GradientColors.sunset),
    GradientColors(GradientColors.sea),
    GradientColors(GradientColors.mango),
    GradientColors(GradientColors.fire),
  ];
}
