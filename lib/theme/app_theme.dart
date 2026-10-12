import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Botanical greens and soft natural surfaces from the plant-store reference.
const brandPrimary = Color(0xFF648A3D);
const brandGreen = Color(0xFF83A94D);
const brandLime = Color(0xFFD6E7B5);
const textDark = Color(0xFF263329);
const textGrey = Color(0xFF7C857B);
const surfaceGrey = Color(0xFFE4E9DF);
const surfaceTint = Color(0xFFEEF3E7);
const dividerColor = Color(0xFFE5E9E1);
const errorRed = Color(0xFFE0463C); // delete, discount

const screenBackground = Color(0xFFF8F9F5);
const cardRadius = 22.0;
const buttonRadius = 16.0;

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandPrimary,
      primary: brandPrimary,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: textDark,
    ),
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: textDark,
    displayColor: textDark,
  );

  return base.copyWith(
    scaffoldBackgroundColor: screenBackground,
    textTheme: textTheme,
    dividerColor: dividerColor,
    appBarTheme: AppBarTheme(
      backgroundColor: screenBackground,
      foregroundColor: textDark,
      surfaceTintColor: screenBackground,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: textDark,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textDark,
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: surfaceGrey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: GoogleFonts.inter(color: textGrey, fontSize: 14),
      labelStyle: GoogleFonts.inter(color: textDark, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        borderSide: const BorderSide(color: surfaceGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        borderSide: const BorderSide(color: surfaceGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
        borderSide: const BorderSide(color: brandPrimary, width: 1.5),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? brandPrimary : Colors.white,
      ),
      side: const BorderSide(color: surfaceGrey, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}
