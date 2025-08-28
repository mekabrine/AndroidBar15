# AndroidBar15 (space.mekabrine.androidbar15)

Rootless iOS 15 tweak (Dopamine/ElleKit). Minimal Android-style nav bar overlay.

## Build via GitHub Actions
1. Create a new public repo on GitHub named `AndroidBar15`.
2. Upload these files (everything in this zip) to the repo root.
3. Go to **Actions** → **Build AndroidBar15** → **Run workflow**.
4. When it finishes, download **Artifacts → debs**. Inside is your `.deb`.

## Install on device
```sh
ip=iphone.local   # or your device IP
scp ./packages/*.deb root@$ip:/var/mobile/
ssh root@$ip 'dpkg -i /var/mobile/space.mekabrine.androidbar15_1.0.0_iphoneos-arm.deb && uicache -a && (sbreload || killall -9 SpringBoard)'
```

*Note:* The filename uses `iphoneos-arm`, which is standard; the binary inside is **arm64** (`ARCHS=arm64`).

---

If you want the richer version (prefs bundle, edge guard, haptics), ask and I'll generate that variant too.
