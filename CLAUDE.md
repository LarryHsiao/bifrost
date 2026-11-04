# bifrost

Shared Flutter UI pieces for the Metis and Snotra apps. Both apps depend on
this repository through git, so a change here reaches them only when they
update their lock files. This file tells a follow-up session how to work
here; it holds no secrets.

## Running the checks

```
flutter analyze
flutter test
```

Both need no login and no network beyond `flutter pub get`. Every public
member needs a doc comment (`public_member_api_docs` is on).

`flutter` may rewrite `analysis_options.yaml` to add a `build/**` exclude.
The file already has one; drop that rewrite instead of committing it.

## TeamCity

`.teamcity/settings.kts` (Kotlin DSL, synced by TeamCity's Versioned
Settings, same as snotra_app's) holds one build config, **Unit Test**:
`fvm flutter pub get`, `fvm flutter analyze`, `fvm flutter test` on every
new commit to any branch. There is no release build; the apps fetch
bifrost through git.

- Flutter comes from fvm, pinned in `.fvmrc` to **3.35.7**: the older of the
  two apps' pins (Snotra 3.35.7, Metis 3.41.0), so code that passes here
  builds in both. Do not use Flutter APIs newer than that pin; raise it only
  together with Snotra's.
- The VCS root reads the repo with an SSH key uploaded to the TeamCity
  project as `bifrost-deploy-key` (public half: a read-only deploy key on
  GitHub). If the root is changed in the TeamCity UI instead, TeamCity
  writes a patch under `.teamcity/patches/`; fold it into `settings.kts`
  and delete it, as snotra_app's own patch shows.
- The **apps'** TeamCity builds (snotra_app's `Unit Test` and release
  configs, metis_app's `Metis_BuildApp` / `Metis_BuildAppIos`) now also
  fetch bifrost during `flutter pub get`, over `git@github.com:`. The
  agent's own SSH key must be allowed to read bifrost, the same way it
  reads `metis_core`. A GitHub deploy key works for one repository only,
  so the agent's key cannot be metis_core's deploy key reused; if those
  builds fail at `pub get` with a git permission error, that is why.

## What belongs here

Something goes into bifrost once **both** apps use it. App-specific things
stay in the app:

- **Words.** Metis has several languages (easy_localization keys); Snotra is
  Traditional Chinese only, written inline. So no widget here carries its
  own text: it takes it as parameters (see `ThemeColorPickerLabels`).
- **Storage.** Metis keeps settings in `shared_preferences`, Snotra in
  `flutter_secure_storage` behind Riverpod. Widgets here only show a value
  and report changes through a callback; the app stores it.
- **Haptics and brand colours.** The app adds those in its own callback or
  palette (Snotra's navy/cream/gold joins the picker as a
  `ThemeSwatch.custom`).

Keep the dependency list to the Flutter SDK unless a shared piece truly
needs more; each package added here is added to both apps.

## How the apps depend on it

```yaml
bifrost:
  git:
    url: git@github.com:LarryHsiao/bifrost
    ref: main
```

- Metis: `LarryHsiao/metis_app`, default branch `master`, wrapper in
  `lib/setting_theme_color_row.dart`, palette in `lib/theme_palette.dart`.
- Snotra: `LarryHsiao/snotra_app`, default branch `main`, wrapper in
  `lib/settings/theme_color_row.dart`, palette in `lib/theme_palette.dart`.

Both apps pin a commit in `pubspec.lock`. After pushing here, bump it in each
app with `flutter pub upgrade bifrost`, then run that app's tests. Keep the
lock diff to the bifrost entry: a newer Flutter than the app's own rewrites
dozens of unrelated entries, so restore those.

A cloud session without SSH can still fetch the `git@github.com:` URL once
the repositories are attached to it, by mapping it to HTTPS for that run:

```
git config --global url."https://github.com/".insteadOf "git@github.com:"
```

Remove it afterwards with `git config --global --unset url."https://github.com/".insteadOf`.

## Facts that are not obvious from the code

- **Swatch and set `id`s are stored by the apps** (e.g. `theme_color_light`
  = `pink`). Renaming one silently resets users who picked it to the
  default. Metis's translation keys are also built from them
  (`theme_color_<id>`, `theme_set_<id>`), so a new id needs a key there.
- `ThemeSwatch` equality is by `id` only.
- `ThemeColorPicker` switches to the custom swatches whenever it receives a
  pairing that matches no set, including one that arrives after it is
  first shown. Snotra relies on this: it restores the stored choice after
  the settings page may already be on screen.
- Tests use `containsSemantics`, deprecated in newer Flutter than the apps
  run; its replacement does not exist in theirs, so the deprecation is
  ignored in place.
