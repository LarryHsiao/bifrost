import 'package:flutter/material.dart';

import 'theme_palette.dart';

/// The words the picker shows; each app passes its own, so it keeps its
/// own languages.
@immutable
class ThemeColorPickerLabels {
  /// Ctor.
  const ThemeColorPickerLabels({
    required this.title,
    required this.customize,
    required this.backToSets,
    required this.light,
    required this.dark,
    required this.setName,
    required this.swatchName,
  });

  /// Heading above the picker, e.g. "Theme colour".
  final String title;

  /// Button that opens the per-mode swatches.
  final String customize;

  /// Button that returns to the ready-made sets.
  final String backToSets;

  /// Heading of the light-mode swatches.
  final String light;

  /// Heading of the dark-mode swatches.
  final String dark;

  /// Display name of a set.
  final String Function(ThemeSet set) setName;

  /// Display name of a swatch.
  final String Function(ThemeSwatch swatch) swatchName;
}

/// The theme-colour picker for a settings page.
///
/// Shows [palette]'s ready-made sets as cards — each card's left half is
/// the light look, its right half the dark — so one tap sets both modes.
/// "Customize" swaps the cards for two rows of swatches, one per mode, for
/// users who want their own pairing. A pairing that matches no set opens
/// straight into the swatches, including one that arrives after the
/// picker is first shown (a choice restored after launch).
///
/// The picker holds no choice of its own: it shows [colors] and reports
/// taps through [onChanged]; storing the choice is up to the app.
class ThemeColorPicker extends StatefulWidget {
  /// Ctor.
  const ThemeColorPicker({
    required this.palette,
    required this.colors,
    required this.labels,
    required this.onChanged,
    super.key,
  });

  /// What the app offers.
  final ThemePalette palette;

  /// The pairing in effect.
  final ThemeColors colors;

  /// The words to show.
  final ThemeColorPickerLabels labels;

  /// Called with a newly picked pairing; never with the current one.
  final ValueChanged<ThemeColors> onChanged;

  @override
  State<ThemeColorPicker> createState() => _ThemeColorPickerState();
}

class _ThemeColorPickerState extends State<ThemeColorPicker> {
  late bool _custom = widget.palette.matching(widget.colors) == null;

  static const _columns = 3;
  static const _gap = 8.0;

  @override
  void didUpdateWidget(ThemeColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.colors != oldWidget.colors &&
        widget.palette.matching(widget.colors) == null) {
      _custom = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModeLabel(icon: Icons.palette_outlined, text: widget.labels.title),
        ...(_custom ? _customView() : _setsView()),
      ],
    );
  }

  void _apply(ThemeColors chosen) {
    if (chosen != widget.colors) widget.onChanged(chosen);
  }

  List<Widget> _setsView() {
    final selected = widget.palette.matching(widget.colors);
    return [
      LayoutBuilder(
        builder: (context, constraints) {
          final width =
              (constraints.maxWidth - _gap * (_columns - 1)) / _columns;
          return Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (final set in widget.palette.sets)
                SizedBox(
                  width: width,
                  child: _SetCard(
                    set: set,
                    labels: widget.labels,
                    selected: set == selected,
                    onTap: () => _apply(set.colors),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 4),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => setState(() => _custom = true),
          icon: const Icon(Icons.tune),
          label: Text(widget.labels.customize),
        ),
      ),
    ];
  }

  List<Widget> _customView() {
    final colors = widget.colors;
    return [
      _ModeLabel(icon: Icons.light_mode, text: widget.labels.light),
      _Swatches(
        swatches: widget.palette.swatches,
        labels: widget.labels,
        selected: colors.light,
        brightness: Brightness.light,
        onSelected: (s) => _apply(colors.copyWith(light: s)),
      ),
      const SizedBox(height: 12),
      _ModeLabel(icon: Icons.dark_mode, text: widget.labels.dark),
      _Swatches(
        swatches: widget.palette.swatches,
        labels: widget.labels,
        selected: colors.dark,
        brightness: Brightness.dark,
        onSelected: (s) => _apply(colors.copyWith(dark: s)),
      ),
      const SizedBox(height: 4),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => setState(() => _custom = false),
          icon: const Icon(Icons.grid_view),
          label: Text(widget.labels.backToSets),
        ),
      ),
    ];
  }
}

/// One ready-made set: light half, dark half, name underneath.
class _SetCard extends StatelessWidget {
  const _SetCard({
    required this.set,
    required this.labels,
    required this.selected,
    required this.onTap,
  });

  final ThemeSet set;
  final ThemeColorPickerLabels labels;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final current = Theme.of(context).colorScheme;
    final light = set.colors.light.scheme(Brightness.light);
    final dark = set.colors.dark.scheme(Brightness.dark);
    final radius = BorderRadius.circular(12);
    return Semantics(
      button: true,
      selected: selected,
      label: labels.setName(set),
      excludeSemantics: true,
      child: Material(
        color: current.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? current.primary : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(child: _Half(scheme: light)),
                    Expanded(child: _Half(scheme: dark)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected) ...[
                      Icon(Icons.check, size: 14, color: current.primary),
                      const SizedBox(width: 2),
                    ],
                    Flexible(
                      child: Text(
                        labels.setName(set),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Half extends StatelessWidget {
  const _Half({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: scheme.surface,
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// One row of colour dots for one mode; each dot shows the primary colour
/// that mode would actually get.
class _Swatches extends StatelessWidget {
  const _Swatches({
    required this.swatches,
    required this.labels,
    required this.selected,
    required this.brightness,
    required this.onSelected,
  });

  final List<ThemeSwatch> swatches;
  final ThemeColorPickerLabels labels;
  final ThemeSwatch selected;
  final Brightness brightness;
  final ValueChanged<ThemeSwatch> onSelected;

  @override
  Widget build(BuildContext context) {
    final ring = Theme.of(context).colorScheme.onSurface;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final seed in swatches)
          _Swatch(
            scheme: seed.scheme(brightness),
            label: labels.swatchName(seed),
            selected: seed == selected,
            ring: ring,
            onTap: () => onSelected(seed),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.scheme,
    required this.label,
    required this.selected,
    required this.ring,
    required this.onTap,
  });

  final ColorScheme scheme;
  final String label;
  final bool selected;
  final Color ring;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          child: Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? ring : Colors.transparent,
                width: 2,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                // Keeps near-white / near-black seeds visible on any
                // background.
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
