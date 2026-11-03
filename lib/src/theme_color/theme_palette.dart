import 'package:flutter/material.dart';

/// One colour the user can pick for the light or the dark theme.
///
/// Most swatches derive their whole [ColorScheme] from [seed], so every
/// pick keeps readable contrast without hand-tuned values. An app's own
/// hand-tuned scheme can join the same picker through [ThemeSwatch.custom].
///
/// [id] is what an app stores to remember the pick; keep it stable.
@immutable
class ThemeSwatch {
  /// A swatch whose schemes are generated from [seed].
  const ThemeSwatch(
    this.id,
    this.seed, {
    this.variant = DynamicSchemeVariant.tonalSpot,
  }) : _light = null,
       _dark = null;

  /// A swatch with hand-tuned schemes; [seed] is only its representative
  /// colour.
  const ThemeSwatch.custom(
    this.id,
    this.seed, {
    required ColorScheme Function() light,
    required ColorScheme Function() dark,
  }) : variant = DynamicSchemeVariant.tonalSpot,
       _light = light,
       _dark = dark;

  /// Stable name for storage and labels, e.g. `orange`.
  final String id;

  /// The colour the scheme is generated from.
  final Color seed;

  /// How the scheme is derived from [seed].
  final DynamicSchemeVariant variant;

  final ColorScheme Function()? _light;
  final ColorScheme Function()? _dark;

  /// The full scheme for [brightness].
  ColorScheme scheme(Brightness brightness) {
    final custom = brightness == Brightness.light ? _light : _dark;
    if (custom != null) return custom();
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: variant,
    );
  }

  @override
  bool operator ==(Object other) => other is ThemeSwatch && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ThemeSwatch($id)';
}

/// The swatches both apps offer.
abstract final class ThemeSwatches {
  /// Warm orange.
  static const orange = ThemeSwatch('orange', Color(0xFFE0732A));

  /// Forest green.
  static const green = ThemeSwatch('green', Color(0xFF4C8C4A));

  /// Ocean blue.
  static const blue = ThemeSwatch('blue', Color(0xFF3F6FD8));

  /// Cherry-blossom pink.
  static const pink = ThemeSwatch('pink', Color(0xFFD06A8A));

  /// Lavender purple.
  static const purple = ThemeSwatch('purple', Color(0xFF7E5BD6));

  /// Lake teal.
  static const teal = ThemeSwatch('teal', Color(0xFF1A9A9A));

  /// Ink: a colourless, monochrome scheme.
  static const ink = ThemeSwatch(
    'ink',
    Color(0xFF6B6B6B),
    variant: DynamicSchemeVariant.monochrome,
  );

  /// All of the above, in display order.
  static const standard = [orange, green, blue, pink, purple, teal, ink];
}

/// The pair of swatches in effect: one for the light theme, one for the
/// dark.
@immutable
class ThemeColors {
  /// Ctor.
  const ThemeColors({required this.light, required this.dark});

  /// Swatch for the light theme.
  final ThemeSwatch light;

  /// Swatch for the dark theme.
  final ThemeSwatch dark;

  /// Copy with one side replaced.
  ThemeColors copyWith({ThemeSwatch? light, ThemeSwatch? dark}) =>
      ThemeColors(light: light ?? this.light, dark: dark ?? this.dark);

  @override
  bool operator ==(Object other) =>
      other is ThemeColors && other.light == light && other.dark == dark;

  @override
  int get hashCode => Object.hash(light, dark);

  @override
  String toString() => 'ThemeColors(${light.id}, ${dark.id})';
}

/// A ready-made light + dark pairing, offered as one card in the picker.
@immutable
class ThemeSet {
  /// Ctor.
  const ThemeSet(this.id, this.colors);

  /// Stable name for labels, e.g. `forest`.
  final String id;

  /// The pairing this set applies.
  final ThemeColors colors;
}

/// The sets both apps offer.
abstract final class ThemeSets {
  /// Orange in both modes.
  static const warm = ThemeSet(
    'warm',
    ThemeColors(light: ThemeSwatches.orange, dark: ThemeSwatches.orange),
  );

  /// Green by day, teal by night.
  static const forest = ThemeSet(
    'forest',
    ThemeColors(light: ThemeSwatches.green, dark: ThemeSwatches.teal),
  );

  /// Blue by day, purple by night.
  static const ocean = ThemeSet(
    'ocean',
    ThemeColors(light: ThemeSwatches.blue, dark: ThemeSwatches.purple),
  );

  /// Pink by day, purple by night.
  static const sakura = ThemeSet(
    'sakura',
    ThemeColors(light: ThemeSwatches.pink, dark: ThemeSwatches.purple),
  );

  /// Teal by day, blue by night.
  static const lake = ThemeSet(
    'lake',
    ThemeColors(light: ThemeSwatches.teal, dark: ThemeSwatches.blue),
  );

  /// Ink by day, orange by night.
  static const study = ThemeSet(
    'study',
    ThemeColors(light: ThemeSwatches.ink, dark: ThemeSwatches.orange),
  );

  /// All of the above, in display order.
  static const standard = [warm, forest, ocean, sakura, lake, study];
}

/// Everything one app offers: its swatches, its sets, and its default.
@immutable
class ThemePalette {
  /// Ctor. [sets] come first in the picker; the first is normally the
  /// [fallback] look.
  const ThemePalette({
    required this.swatches,
    required this.sets,
    required this.fallback,
  });

  /// Swatches offered in the custom view, in display order.
  final List<ThemeSwatch> swatches;

  /// Ready-made sets, in display order.
  final List<ThemeSet> sets;

  /// The pairing used until the user picks.
  final ThemeColors fallback;

  /// The swatch with [id]; [orElse] when absent or unknown.
  ThemeSwatch swatch(String? id, ThemeSwatch orElse) {
    for (final s in swatches) {
      if (s.id == id) return s;
    }
    return orElse;
  }

  /// The pairing for stored ids; each unknown side falls back to
  /// [fallback]'s swatch for that side.
  ThemeColors parse(String? lightId, String? darkId) => ThemeColors(
    light: swatch(lightId, fallback.light),
    dark: swatch(darkId, fallback.dark),
  );

  /// The set matching [colors], or null when the pairing is a custom one.
  ThemeSet? matching(ThemeColors colors) {
    for (final set in sets) {
      if (set.colors == colors) return set;
    }
    return null;
  }
}
