import 'package:bifrost/bifrost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _palette = ThemePalette(
  swatches: ThemeSwatches.standard,
  sets: ThemeSets.standard,
  fallback: ThemeColors(
    light: ThemeSwatches.orange,
    dark: ThemeSwatches.orange,
  ),
);

final _labels = ThemeColorPickerLabels(
  title: 'Theme colour',
  customize: 'Customize',
  backToSets: 'Back to themes',
  light: 'Light',
  dark: 'Dark',
  setName: (s) => 'set:${s.id}',
  swatchName: (s) => 'swatch:${s.id}',
);

/// Hosts a picker whose choice lives in [colors], like an app would.
class _Host extends StatefulWidget {
  const _Host(this.colors);

  final ValueNotifier<ThemeColors> colors;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: widget.colors,
    builder: (context, colors, _) => ThemeColorPicker(
      palette: _palette,
      colors: colors,
      labels: _labels,
      onChanged: (c) => widget.colors.value = c,
    ),
  );
}

Future<ValueNotifier<ThemeColors>> _pump(
  WidgetTester tester, [
  ThemeColors start = const ThemeColors(
    light: ThemeSwatches.orange,
    dark: ThemeSwatches.orange,
  ),
]) async {
  final colors = ValueNotifier(start);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: _Host(colors))),
    ),
  );
  return colors;
}

void main() {
  testWidgets('tapping a set applies its light and dark colours', (
    tester,
  ) async {
    final colors = await _pump(tester);

    await tester.tap(find.text('set:forest'));
    await tester.pumpAndSettle();

    expect(colors.value, ThemeSets.forest.colors);
  });

  testWidgets('customize lets the dark colour change on its own', (
    tester,
  ) async {
    final colors = await _pump(tester);

    await tester.tap(find.text('Customize'));
    await tester.pumpAndSettle();
    // Each mode has its own row of swatches; the second is dark's.
    await tester.tap(find.bySemanticsLabel('swatch:purple').last);
    await tester.pumpAndSettle();

    const expected = ThemeColors(
      light: ThemeSwatches.orange,
      dark: ThemeSwatches.purple,
    );
    expect(colors.value, expected);
  });

  testWidgets('a custom pairing opens straight into the swatches', (
    tester,
  ) async {
    await _pump(
      tester,
      const ThemeColors(light: ThemeSwatches.ink, dark: ThemeSwatches.ink),
    );

    expect(find.text('Back to themes'), findsOneWidget);
  });

  testWidgets('a custom pairing arriving later also opens the swatches', (
    tester,
  ) async {
    final colors = await _pump(tester);

    colors.value = const ThemeColors(
      light: ThemeSwatches.ink,
      dark: ThemeSwatches.ink,
    );
    await tester.pumpAndSettle();

    expect(find.text('Back to themes'), findsOneWidget);
  });

  testWidgets('the picked set is marked selected', (tester) async {
    await _pump(tester);

    expect(
      tester.getSemantics(find.bySemanticsLabel('set:warm')),
      // isSemantics replaces this only in newer Flutter than the apps use.
      // ignore: deprecated_member_use
      containsSemantics(isSelected: true),
    );
  });
}
