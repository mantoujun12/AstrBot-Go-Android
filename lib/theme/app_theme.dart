import 'package:material_ui/material_ui.dart';

/// Palette and themes mirroring the desktop AstrBot-Go Vuetify themes
/// (src/theme/LightTheme.ts and DarkTheme.ts) so both launchers feel alike.
abstract final class AppPalette {
  static const lightPrimary = Color(0xFF3C96CA);
  static const lightSecondary = Color(0xFF2F86BD);
  static const darkPrimary = Color(0xFF5BA4D4);
  static const darkSecondary = Color(0xFF4A95C4);

  static const info = Color(0xFF03C9D7);
  static const successLight = Color(0xFF00A850);
  static const successDark = Color(0xFF52C41A);
  static const warningLight = Color(0xFFFFC107);
  static const warningDark = Color(0xFFFAAD14);
  static const errorLight = Color(0xFFF44336);
  static const errorDark = Color(0xFFFF4D4F);

  /// Desktop background tokens: light #ffffff, dark #1a1a1a.
  static const darkBackground = Color(0xFF1A1A1A);

  static Color success(Brightness b) =>
      b == Brightness.dark ? successDark : successLight;

  static Color warning(Brightness b) =>
      b == Brightness.dark ? warningDark : warningLight;

  static Color error(Brightness b) =>
      b == Brightness.dark ? errorDark : errorLight;
}

/// Builds the app theme for [brightness] from the desktop palette.
ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final seed = dark ? AppPalette.darkPrimary : AppPalette.lightPrimary;
  final scheme =
      ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
    primary: seed,
    secondary: dark ? AppPalette.darkSecondary : AppPalette.lightSecondary,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        dark ? AppPalette.darkBackground : const Color(0xFFFFFFFF),
  );
}
