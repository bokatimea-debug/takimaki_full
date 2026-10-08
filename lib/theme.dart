import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const takiTeal = Color(0xFF10AAA5);
const takiTealDark = Color(0xFF083B46);
const takiNavy = takiTealDark;
const takiOrange = Color(0xFFFFA51F);
const takiCream = Color(0xFFFFFBF1);
const takiMint = Color(0xFFDDF4EF);
const takiYellowSoft = Color(0xFFFFE7B0);
const takiFieldSurface = Color(0xFFFFFEFA);
const takiMutedText = Color(0xFF617577);
const takiProfileGradient = LinearGradient(colors: [takiTealDark, takiTeal]);

ThemeData takimakiTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: takiTeal,
    primary: takiTeal,
    secondary: takiOrange,
    surface: takiCream,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: takiTealDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: takiCream,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: takiTealDark,
      ),
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 34,
        height: 1.05,
        letterSpacing: -1.1,
        fontWeight: FontWeight.w900,
        color: takiTealDark,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w900,
        color: takiTealDark,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w900,
        color: takiTealDark,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, color: takiTealDark),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, color: takiTealDark),
      bodyLarge: TextStyle(color: Color(0xFF41565A)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: takiOrange,
        foregroundColor: takiNavy,
        disabledBackgroundColor: takiYellowSoft,
        disabledForegroundColor: takiMutedText,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        side: const BorderSide(color: Color(0xFF78908F)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: takiFieldSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD4DFDC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: takiTeal, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: const BorderSide(color: Color(0xFFC7D3D1)),
      selectedColor: takiMint,
      checkmarkColor: takiTealDark,
    ),
    cardTheme: CardThemeData(
      color: takiFieldSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: takiTealDark.withValues(alpha: .12),
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFFF4FBF9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: takiTealDark,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFF9FFFD),
      indicatorColor: takiMint,
      elevation: 8,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w700, color: takiTealDark),
      ),
    ),
  );
}
