# AndroidBar15 (v1.1.2)
Android-style navigation bar for iOS 15 (iPhone X tested). Provides **Back**, **Home**, and **App Switcher** buttons, hides the system home bar, and disables the native home/app-switcher gestures.

## Features
- Floating Android-style 3-button bar (Back / Home / Switcher)
- Back works in most UIKit apps via `accessibilityPerformEscape`
- Home and App Switcher use SpringBoard private simulation methods
- Hides home indicator and defers system gestures in apps
- iOS 15.x, arm64/arm64e

## Build
Requires Theos.
```bash
export THEOS=/opt/theos
make package
```
The resulting `.deb` will be in `./packages/`.

## Install
- Copy the .deb to your device and install with Sileo/Zebra or:
  ```sh
  dpkg -i ./packages/space.mekabrine.androidbar15_1.1.2_iphoneos-arm64.deb
  ```
- Respring will be triggered automatically.

## Notes
- Back uses accessibility and should work for most apps that support the standard back behavior. Some custom apps may not respond.
- The tweak disables system edge gestures to avoid conflicts with the bar.
- Uninstall to restore default gestures.