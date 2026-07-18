import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // -- Màu nền & Bề mặt
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5);

  // -- Màu chủ đạo (Xanh lá cây giao thông)
  static const Color primaryColor = Color(0xFF0DD04E);
  static const Color primaryColorDark = Color(0xFF0F963C);
  static const Color primaryColorLight = Color(0xFF00FF55);

  // -- Màu trạng thái giao thông (Giữ lại để làm Marker hoặc Label)
  static const Color trafficRed    = Color(0xFFF44336);
  static const Color trafficYellow  = Color.fromARGB(255, 238, 255, 0);
  static const Color trafficGreen  = Color(0xFF4CAF50);
  static const Color trafficBlue = Color.fromARGB(255, 0, 8, 255);
  static const Color trafficOrange = Color(0xFFFF9800);
  static const Color trafficPurple = Color(0xFF9C27B0);
  // Các màu phụ khác có thể bỏ nếu không dùng đến UI đặc biệt

  // -- Màu chữ & Phụ trợ
  static const Color textPrimaryColor = Color(0xFF000000);
  static final Color textSecondaryColor = const Color(0xFF000000).withValues(alpha: 0.6);
  static final Color textHintColor = const Color(0xFF000000).withValues(alpha: 0.4);
  static final Color borderColor = const Color(0xFF000000).withValues(alpha: 0.08);

  // ── Text Styles ────────────────────────────────────────────────────────────
  static const TextStyle appBarTitle = TextStyle(
    color: textPrimaryColor,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );
  
  static const TextStyle screenTitle = TextStyle(
    color: textPrimaryColor,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  
  static const TextStyle cardTitle = TextStyle(
    color: textPrimaryColor,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle sheetTitle = TextStyle(
    color: textPrimaryColor,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  
  static TextStyle get subtitleSmall => TextStyle(
    color: textSecondaryColor,
    fontSize: 12,
  );

  // ── ThemeData ──────────────────────────────────────────────────────────────
  // Đã chỉnh lại seedColor theo màu chủ đạo của bạn
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: backgroundColor,
  );
 
  // ── Border radius thường dùng ─────────────────────────────────────────────
  static const double radiusCard   = 16;
  static const double radiusSheet  = 24;
  static const double radiusButton = 14;
}