# AndroidBar15 (Swift)

A Swift/Orion remake of **AndroBar** that targets **rootless iOS 15** (iPhone X et al.).
It overlays an Android-style navigation bar (Back, Home, Switcher) on SpringBoard and inside apps.

## Build

- Install Theos + Orion and ElleKit on your rootless device/toolchain.
- Clone into `$THEOS_PROJECT_DIR`, then:

```sh
make do
```

> Ensure `THEOS_PACKAGE_SCHEME = rootless` and that your target jailbreak uses ElleKit (e.g. Dopamine).

## Preferences

This skeleton mirrors some AndroBar keys (see `Preferences.swift`). A minimal PreferenceBundle is included.

## Themes

Theme PNGs are placed in `/var/jb/Library/Application Support/AndroidBar15/Themes/<Theme>/`.
Three example themes (Pixel, Samsung, Samsung S8, Simple) were imported from your reference package.

## Actions

The code attempts SpringBoard selectors for Home/Switcher and falls back in apps. You may need to adjust selectors for your firmware.
Look at `Actions.perform(_:)` to fine‑tune for your setup (e.g. `SBFluidSwitcherManager`, `SBUIController`, etc.).
