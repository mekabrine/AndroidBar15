# AndroidBar15 (Swift) - Slim

Minimal build for rootless iOS 15 (Swift/Orion). Renders a small bottom bar; taps **vibrate only**.
Prompts once to **respring** after install. No PreferenceBundle to avoid Settings crashes.

## Build
make package FINALPACKAGE=1

## Install
dpkg -i packages/*.deb
