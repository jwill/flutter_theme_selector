import 'package:flutter/material.dart';
import 'package:flutter_theme_selector/src/settings/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.

class SettingsSignalsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  final SharedPreferencesWithCache prefs;

  EffectCleanup? _cleanup;
  SettingsSignalsService(this.prefs) {
    _cleanup = effect(() {
      for (final entry in setting.store.entries) {
        final value = entry.value.peek();
        if (prefs.getString(entry.key.$1) != value) {
          prefs.setString(entry.key.$1, value).ignore();
        }
      }
    });
  }

  late final setting = signalContainer<String, (String, String)>(
        (val) => signal(prefs.getString(val.$1) ?? val.$2),
    cache: true,
  );

  // second value is default
  //Signal<String> get darkMode => setting(('dark-mode', 'false'));
  Signal<String> get themeMode => setting((THEME_MODE, 'system'));
  Signal<String> get seed => setting((COLOR_SEED, DEFAULT_COLOR));
  Signal<String> get fontScale => setting((FONT_SIZE_FACTOR, "1.0"));
  // Signal<ColorSeed> get colorSeed {
  //
  //   Color? secondarySeed = (await prefs.getInt(COLOR_SECONDARY_SEED)).toColor();
  //   Color? tertiarySeed = (await prefs.getInt(COLOR_TERTIARY_SEED)).toColor();
  //   Color? neutralSeed = (await prefs.getInt(COLOR_NEUTRAL_SEED)).toColor();
  //   Color? neutralVariantSeed = (await prefs.getInt(COLOR_NV_SEED)).toColor();
  //   Color? errorSeed = (await prefs.getInt(COLOR_ERROR_SEED)).toColor();
  // }

  void dispose() {
      _cleanup?.call();
      setting.dispose();
    }

    Future<double> contrast() async => 0.0;

    Future<DynamicSchemeVariant> variant() async {
      String? variant = await prefs.getString(VARIANT);
      if (variant == null) return DynamicSchemeVariant.tonalSpot;
      return DynamicSchemeVariant.values.firstWhere((elem) {
        return elem.name == variant;
      }, orElse: () {
        return DynamicSchemeVariant.tonalSpot;
      });
    }

    Future<void> loadSettings() async {
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      //TODO
    }

    // /// Persists the user's preferred ThemeMode to local or remote storage.
    // Future<void> updateThemeMode(ThemeMode mode) async {
    //   // Use the shared_preferences package to persist settings locally or the
    //   // http package to persist settings over the network.
    //   switch (mode) {
    //     case ThemeMode.light:
    //       prefs.setString("themeMode", "light");
    //       break;
    //     case ThemeMode.dark:
    //       prefs.setString("themeMode", "dark");
    //       break;
    //     case ThemeMode.system:
    //       prefs.setString("themeMode", "system");
    //       break;
    //   }
    // }

  Future <ColorSeed> colorSeed2() async {
    Color? seed = (await prefs.getInt(COLOR_SEED))?.toColor();
    Color? secondarySeed = (await prefs.getInt(COLOR_SECONDARY_SEED)).toColor();
    Color? tertiarySeed = (await prefs.getInt(COLOR_TERTIARY_SEED)).toColor();
    Color? neutralSeed = (await prefs.getInt(COLOR_NEUTRAL_SEED)).toColor();
    Color? neutralVariantSeed = (await prefs.getInt(COLOR_NV_SEED)).toColor();
    Color? errorSeed = (await prefs.getInt(COLOR_ERROR_SEED)).toColor();

    if (seed == null) {
      seed = Color(0x6750A4FF);
    }

    return ColorSeed("", seed);
  }

    Future <String> displayHeadlineFont() async {
      String? displayFont = await prefs.getString(DISPLAY_FONT);
      if (displayFont == null) {
        await prefs.setString(DISPLAY_FONT, "Noto Sans");
        return 'Noto Sans';
      }
      else {
        return displayFont;
      }
    }

    Future <String> bodyLabelFont() async {
      String? bodyFont = await prefs.getString(BODY_FONT);
      if (bodyFont == null) {
        await prefs.setString(BODY_FONT, "Noto Sans");
        return 'Noto Sans';
      }
      else {
        return bodyFont;
      }
    }

    Future<double> fontSizeFactor() async {
      double? fontSize = await prefs.getDouble(FONT_SIZE_FACTOR);
      if (fontSize == null) {
        return 1.0;
      } else {
        return fontSize;
      }
    }




    Future <bool> monochrome() async {
      bool? isMonochrome = await prefs.getBool(MONOCHROME);
      if (isMonochrome == null) {
        return false;
      } else
        return isMonochrome;
    }

    Future<void> updateDisplayFont(String newValue) async {
      String? displayFont = await prefs.getString(DISPLAY_FONT);
      if (newValue != displayFont) {
        prefs.setString(DISPLAY_FONT, newValue);
      }
    }

    Future<void> updateBodyFont(String newValue) async {
      String? bodyFont = await prefs.getString(BODY_FONT);
      if (newValue != bodyFont) {
        prefs.setString(BODY_FONT, newValue);
      }
    }

    Future <void> updateFontSizeFactor(double newValue) async {
      double? sizeFactor = await prefs.getDouble(FONT_SIZE_FACTOR);
      if (newValue != sizeFactor) {
        prefs.setDouble(FONT_SIZE_FACTOR, newValue);
      }
    }

    Future <void> updateContrast(double newValue) async {
      double? contrastSize = await prefs.getDouble(CONTRAST_VALUE);
      if (newValue != contrastSize) {
        prefs.setDouble(CONTRAST_VALUE, newValue);
      }
    }

    Future <void> updateSeedColor(int newValue) async {
      int? seedColor = await prefs.getInt(COLOR_SEED);
      if (newValue != seedColor) {
        prefs.setInt(COLOR_SEED, newValue);
      }
    }

    Future<void> updateVariant(String newValue) async {
      String? variant = await prefs.getString(VARIANT);
      if (newValue != variant) {
        prefs.setString(VARIANT, newValue);
      }
    }
  }

extension Converters on String {
  ThemeMode toThemeMode() {
    switch(this) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
    }
    return ThemeMode.system;
  }
}



class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  Future<double> contrast() async => 0.0;

  Future<DynamicSchemeVariant> variant() async {
    String? variant = await prefs.getString(VARIANT);
    if (variant == null) return DynamicSchemeVariant.tonalSpot;
    return DynamicSchemeVariant.values.firstWhere((elem) {
      return elem.name == variant;
    }, orElse: () {
      return DynamicSchemeVariant.tonalSpot;
    });
  }

  Future<void> loadSettings() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode mode) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
    print(mode);
    switch (mode) {
      case ThemeMode.light:
        prefs.setString("themeMode", "light");
        break;
      case ThemeMode.dark:
        prefs.setString("themeMode", "dark");
        break;
      case ThemeMode.system:
        prefs.setString("themeMode", "system");
        break;
    }
  }


  Future <String> displayHeadlineFont() async {
    String? displayFont = await prefs.getString(DISPLAY_FONT);
    if (displayFont == null) {
      await prefs.setString(DISPLAY_FONT, "Noto Sans");
      return 'Noto Sans';
    }
    else {
      return displayFont;
    }
  }

  Future <String> bodyLabelFont() async {
    String? bodyFont = await prefs.getString(BODY_FONT);
    if (bodyFont == null) {
      await prefs.setString(BODY_FONT, "Noto Sans");
      return 'Noto Sans';
    }
    else {
      return bodyFont;
    }
  }

  // Future<double> fontSizeFactor() async {
  //   double? fontSize = await prefs.getDouble(FONT_SIZE_FACTOR);
  //   if (fontSize == null) {
  //     return 1.0;
  //   } else {
  //     return fontSize;
  //   }
  // }


  Future <ColorSeed> colorSeed() async {
    Color? seed = (await prefs.getInt(COLOR_SEED))?.toColor();
    Color? secondarySeed = (await prefs.getInt(COLOR_SECONDARY_SEED)).toColor();
    Color? tertiarySeed = (await prefs.getInt(COLOR_TERTIARY_SEED)).toColor();
    Color? neutralSeed = (await prefs.getInt(COLOR_NEUTRAL_SEED)).toColor();
    Color? neutralVariantSeed = (await prefs.getInt(COLOR_NV_SEED)).toColor();
    Color? errorSeed = (await prefs.getInt(COLOR_ERROR_SEED)).toColor();

    if (seed == null) {
      seed = Color(0x6750A4FF);
    }

    return ColorSeed("", seed);
  }

  Future <bool> monochrome() async {
    bool? isMonochrome = await prefs.getBool(MONOCHROME);
    if (isMonochrome == null) {
      return false;
    } else
      return isMonochrome;
  }

  Future<void> updateDisplayFont(String newValue) async {
    String? displayFont = await prefs.getString(DISPLAY_FONT);
    if (newValue != displayFont) {
      prefs.setString(DISPLAY_FONT, newValue);
    }
  }

  Future<void> updateBodyFont(String newValue) async {
    String? bodyFont = await prefs.getString(BODY_FONT);
    if (newValue != bodyFont) {
      prefs.setString(BODY_FONT, newValue);
    }
  }

  // Future <void> updateFontSizeFactor(double newValue) async {
  //   double? sizeFactor = await prefs.getDouble(FONT_SIZE_FACTOR);
  //   if (newValue != sizeFactor) {
  //     prefs.setDouble(FONT_SIZE_FACTOR, newValue);
  //   }
  // }

  Future <void> updateContrast(double newValue) async {
    double? contrastSize = await prefs.getDouble(CONTRAST_VALUE);
    if (newValue != contrastSize) {
      prefs.setDouble(CONTRAST_VALUE, newValue);
    }
  }

  Future <void> updateSeedColor(int newValue) async {
    int? seedColor = await prefs.getInt(COLOR_SEED);
    if (newValue != seedColor) {
      prefs.setInt(COLOR_SEED, newValue);
    }
  }

  Future<void> updateVariant(String newValue) async {
    String? variant = await prefs.getString(VARIANT);
    if (newValue != variant) {
      prefs.setString(VARIANT, newValue);
    }
  }


}

extension on int? {
  Color? toColor() {
    if (this == null) {
      return null;
    } else {
      return Color(this!.toInt());
    }
  }
}
