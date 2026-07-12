import 'package:flutter/material.dart';

class AppColors {
  static const kill = Color(0xFFFF1744);
  static const death = Color(0xFF2979FF);
}

class WargameColors extends ThemeExtension<WargameColors> {
  const WargameColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.line,
    required this.text,
    required this.muted,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color line;
  final Color text;
  final Color muted;

  static const dark = WargameColors(
    background: Color(0xFF070A10),
    surface: Color(0xFF101722),
    surfaceHigh: Color(0xFF151F2E),
    line: Color(0xFF283447),
    text: Color(0xFFEAF1FF),
    muted: Color(0xFF9AA8BB),
  );

  static const light = WargameColors(
    background: Color(0xFFF6F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF0F3F8),
    line: Color(0xFFE1E6EF),
    text: Color(0xFF121820),
    muted: Color(0xFF697380),
  );

  @override
  WargameColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? line,
    Color? text,
    Color? muted,
  }) {
    return WargameColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      line: line ?? this.line,
      text: text ?? this.text,
      muted: muted ?? this.muted,
    );
  }

  @override
  WargameColors lerp(ThemeExtension<WargameColors>? other, double t) {
    if (other is! WargameColors) {
      return this;
    }
    return WargameColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      line: Color.lerp(line, other.line, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

extension WargameTheme on BuildContext {
  WargameColors get wargameColors =>
      Theme.of(this).extension<WargameColors>()!;
}

class AppTheme {
  static ThemeData get light {
    return _build(Brightness.light, WargameColors.light);
  }

  static ThemeData get dark {
    return _build(Brightness.dark, WargameColors.dark);
  }

  static ThemeData _build(Brightness brightness, WargameColors colors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.death,
      brightness: brightness,
      surface: colors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: 'Roboto',
      extensions: <ThemeExtension<dynamic>>[colors],
      textTheme: TextTheme(
        displaySmall: TextStyle(
          color: colors.text,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          color: colors.text,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: colors.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: colors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: colors.muted,
          fontSize: 14,
          letterSpacing: 0,
        ),
        labelLarge: TextStyle(
          color: colors.text,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: AppColors.death.withAlpha(36),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: colors.text, fontWeight: FontWeight.w700),
        ),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: colors.text)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.death,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static BoxDecoration panelDecoration(BuildContext context, {Color? color}) {
    final colors = context.wargameColors;
    return BoxDecoration(
      color: color ?? colors.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colors.line),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A1D2B3A),
          blurRadius: 24,
          offset: Offset(0, 12),
        ),
      ],
    );
  }
}
