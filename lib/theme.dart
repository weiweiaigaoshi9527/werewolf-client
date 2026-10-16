import 'package:flutter/material.dart';

/// 与网页版一致的暗黑哥特配色。
const kBg = Color(0xFF090D18);
const kPanel = Color(0xFF141A2E);
const kPanel2 = Color(0xFF1A2238);
const kBorder = Color(0xFF2A3350);
const kText = Color(0xFFCDD6F4);
const kDim = Color(0xFF7B85A8);
const kAccent = Color(0xFFE8A33D);
const kBlood = Color(0xFFA4243B);
const kGreen = Color(0xFF4F9D69);
const kMoon = Color(0xFFE3E8FF);

/// 座位标记（本地、仅自己可见）的配色，对齐网页版 `.mk-btn.m-sus / .m-good / .m-wolf`。
/// 等级 0（未标）返回 null，表示不显示任何标记。
Color? markColor(int level) => switch (level) {
      1 => kAccent, // 可疑
      2 => kGreen, // 好人
      3 => kBlood, // 狼人
      _ => null,
    };

ThemeData werewolfTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      secondary: kAccent,
      surface: kPanel,
      error: kBlood,
      onSurface: kText,
    ),
    appBarTheme: const AppBarTheme(backgroundColor: kPanel, foregroundColor: kMoon, elevation: 0, centerTitle: false),
    cardTheme: CardTheme(
      color: kPanel2,
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    dividerColor: kBorder,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kAccent, width: 1.5)),
      hintStyle: const TextStyle(color: kDim),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: kText),
      bodyLarge: TextStyle(color: kText),
      titleLarge: TextStyle(color: kMoon),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: const Color(0xFF1A1206),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: kText, side: const BorderSide(color: kBorder), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: kAccent)),
    snackBarTheme: const SnackBarThemeData(backgroundColor: kPanel2, contentTextStyle: TextStyle(color: kText)),
  );
}
