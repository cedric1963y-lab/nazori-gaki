import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/occasions.dart';

/// 和紙と墨、朱と藍。現場系アプリとは別の、儀礼の道具らしい配色。
abstract final class Washi {
  static const paper = Color(0xFFF4EEE2);
  static const paperDeep = Color(0xFFE9DFCC);
  static const card = Color(0xFFFBF8F1);
  static const sumi = Color(0xFF26221E);
  static const sumiSoft = Color(0xFF5E564C);
  static const shu = Color(0xFFB0412E);
  static const ai = Color(0xFF3B4B5C);
  static const kin = Color(0xFFAE8A45);
  static const gin = Color(0xFF9DA3A8);
  static const line = Color(0xFFD8CBB2);
  static const usuzumi = Color(0xFF7E7E7E);
  static const koizumi = Color(0xFF141414);

  static const title = 'YujiSyuku';

  static Color accentFor(Mood m) => switch (m) {
    Mood.celebration => shu,
    Mood.condolence => ai,
    Mood.neutral => kin,
  };
}

ThemeData buildWashiTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Washi.shu,
    brightness: Brightness.light,
  ).copyWith(
    primary: Washi.shu,
    onPrimary: Colors.white,
    secondary: Washi.ai,
    surface: Washi.paper,
    onSurface: Washi.sumi,
    outline: Washi.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Washi.paper,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Washi.sumi,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: Washi.title,
        fontSize: 21,
        color: Washi.sumi,
      ),
    ),
    dividerTheme: const DividerThemeData(color: Washi.line, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: Washi.card,
      selectedColor: Washi.sumi,
      labelStyle: const TextStyle(color: Washi.sumi, fontSize: 15),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 15),
      side: const BorderSide(color: Washi.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      showCheckmark: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Washi.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Washi.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Washi.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Washi.sumi, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Washi.sumi,
        foregroundColor: Washi.paper,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Washi.sumi,
        side: const BorderSide(color: Washi.sumi),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
  );
}
