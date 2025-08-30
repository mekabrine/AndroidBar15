# AndroBar (Rootless) – Dopamine / iOS 15+ (arm64)

This is a minimal, rootless Theos scaffold to rebuild the tweak for Dopamine (ElleKit) on iOS 15+.
It compiles for `arm64` and installs under `/var/jb`.

## Prereqs
- A Mac or Linux build host
- [Theos](https://theos.dev/) installed and `THEOS` env var set
- Xcode command line tools (macOS) or LLVM/Clang (Linux)
- Device: iOS 15+ with Dopamine (ElleKit)
- Optional deps: PreferenceLoader, AltList, Orion/other SDKs if you need them (add to `Makefile`)

## Build
```bash
# from the repo root
./scripts/build.sh
# Your .deb will be in the "packages/" folder.
```

## Install
Copy the resulting `.deb` to your device and install with Sileo/Zebra/Filza or:
```bash
ssh mobile@DEVICE "sudo uicache -p; sudo sileo install /path/to/com.ginsu.androbar_3.2.1_iphoneos-arm64_rootless.deb"  # or use Filza
```

## Notes
- **Rootless-aware paths**: use `ROOT_PATH_NS()` to access anything that used to live under `/Library/...`.
- Update `AndroBar_FILES` / frameworks / libraries in `Makefile` to match your codebase.
- If you ship resources (themes, images, JSON), place them under `layout/var/jb/Library/Application Support/AndroBar/` so they get packaged.
