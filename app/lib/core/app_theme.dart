import 'package:flutter/material.dart';

const retroInk = Color(0xFF17202A);
const retroShell = Color(0xFF2637A8);
const retroScreen = Color(0xFFE6FF8F);
const retroPanel = Color(0xFFFFF0B8);
const retroMint = Color(0xFF35D68A);
const retroAmber = Color(0xFFFFB931);
const retroRed = Color(0xFFFF4F5E);
const arcadeViolet = Color(0xFF5B35D5);
const arcadeCyan = Color(0xFF24C7FF);
const arcadePink = Color(0xFFFF5CC8);
const arcadeNight = Color(0xFF15112A);
const arcadeCabinet = Color(0xFF6B4FE8);
const retroInputTextStyle = TextStyle(
  color: retroInk,
  fontFamily: 'monospace',
  fontSize: 15,
  fontWeight: FontWeight.w800,
  letterSpacing: 0,
);

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: retroShell,
    onPrimary: Colors.white,
    secondary: retroMint,
    onSecondary: retroInk,
    tertiary: retroAmber,
    onTertiary: retroInk,
    error: retroRed,
    onError: Colors.white,
    surface: retroPanel,
    onSurface: retroInk,
    surfaceContainerHighest: retroScreen,
    outline: retroInk,
    shadow: retroInk,
  );

  return ThemeData(
    colorScheme: colorScheme,
    fontFamily: 'monospace',
    useMaterial3: true,
    scaffoldBackgroundColor: arcadeNight,
    textTheme: ThemeData.light().textTheme.apply(
      fontFamily: 'monospace',
      bodyColor: retroInk,
      displayColor: retroInk,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: retroShell,
      selectionColor: Color(0x665FB87B),
      selectionHandleColor: retroShell,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: arcadeNight,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontFamily: 'monospace',
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: retroPanel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: retroInk, width: 2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: retroScreen,
      labelStyle: const TextStyle(
        color: retroInk,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w800,
      ),
      floatingLabelStyle: const TextStyle(
        color: retroShell,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w900,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF4F5847),
        fontFamily: 'monospace',
        fontWeight: FontWeight.w700,
      ),
      errorStyle: const TextStyle(
        color: retroRed,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w800,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      prefixIconColor: retroInk,
      suffixIconColor: retroInk,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: retroInk, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: retroInk, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: arcadePink, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: retroRed, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: arcadePink,
        foregroundColor: retroInk,
        disabledBackgroundColor: const Color(0xFF9DA58C),
        disabledForegroundColor: const Color(0xFF4F5847),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: retroInk, width: 2),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: retroShell,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontFamily: 'monospace',
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: retroInk,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: retroInk, width: 1.5),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: arcadePink,
      foregroundColor: retroInk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        side: BorderSide(color: retroInk, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: retroPanel,
      selectedColor: retroMint,
      secondarySelectedColor: retroMint,
      labelStyle: const TextStyle(color: retroInk, fontWeight: FontWeight.w700),
      secondaryLabelStyle: const TextStyle(
        color: retroInk,
        fontWeight: FontWeight.w900,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: retroInk, width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: retroPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: retroInk, width: 2),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: retroPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        side: BorderSide(color: retroInk, width: 2),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: retroInk,
      contentTextStyle: TextStyle(
        color: retroScreen,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
