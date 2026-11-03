# bifrost

Shared Flutter UI pieces for Metis and Snotra — the bridge between the apps.

## What's inside

- **Theme colour picker** (`ThemeColorPicker`): ready-made light + dark
  sets, plus per-mode custom swatches.
  - `ThemeSwatches.standard` / `ThemeSets.standard` — the colours and sets
    both apps offer.
  - `ThemeSwatch.custom` — add an app's own hand-tuned scheme to the picker.
  - `ThemePalette` — what one app offers, its default, and parsing of
    stored ids.

Each app keeps its own words (`ThemeColorPickerLabels`) and its own
storage; the picker only shows the choice and reports taps.

## Using it

```yaml
dependencies:
  bifrost:
    git:
      url: git@github.com:LarryHsiao/bifrost
      ref: main
```
