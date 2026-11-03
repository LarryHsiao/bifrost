import 'package:bifrost/bifrost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ColorScheme _light() => const ColorScheme.light(primary: Color(0xFF123456));
ColorScheme _dark() => const ColorScheme.dark(primary: Color(0xFF654321));

const _own = ThemeSwatch.custom(
  'own',
  Color(0xFF123456),
  light: _light,
  dark: _dark,
);

const _palette = ThemePalette(
  swatches: [_own, ...ThemeSwatches.standard],
  sets: [
    ThemeSet('original', ThemeColors(light: _own, dark: _own)),
    ...ThemeSets.standard,
  ],
  fallback: ThemeColors(light: _own, dark: _own),
);

void main() {
  test('stored ids come back as the same pairing', () {
    expect(
      _palette.parse('pink', 'teal'),
      const ThemeColors(light: ThemeSwatches.pink, dark: ThemeSwatches.teal),
    );
  });

  test('an unknown or missing id falls back per side', () {
    expect(_palette.parse('chartreuse', null), _palette.fallback);
  });

  test('a custom swatch uses its own hand-tuned schemes', () {
    expect(
      [_own.scheme(Brightness.light), _own.scheme(Brightness.dark)],
      [_light(), _dark()],
    );
  });

  test('a seeded swatch derives its scheme from the seed', () {
    expect(
      ThemeSwatches.blue.scheme(Brightness.dark),
      ColorScheme.fromSeed(
        seedColor: ThemeSwatches.blue.seed,
        brightness: Brightness.dark,
      ),
    );
  });

  test('a pairing that is no set matches nothing', () {
    expect(
      _palette.matching(
        const ThemeColors(light: ThemeSwatches.ink, dark: ThemeSwatches.ink),
      ),
      isNull,
    );
  });

  test('every standard set is a distinct pairing', () {
    expect(
      ThemeSets.standard.map((s) => s.colors).toSet().length,
      ThemeSets.standard.length,
    );
  });

  test('every standard id is unique', () {
    expect(
      ThemeSwatches.standard.map((s) => s.id).toSet().length,
      ThemeSwatches.standard.length,
    );
  });
}
