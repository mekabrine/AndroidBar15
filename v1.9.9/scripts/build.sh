#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${THEOS:-}" ]]; then
  echo "ERROR: THEOS environment variable is not set. Install Theos and export THEOS=/path/to/theos"
  exit 1
fi

echo "==> Cleaning"
make clean || true

echo "==> Building (rootless, arm64, iOS 15+)"
make package

echo "==> Done. Packages:"
ls -lh packages/*.deb
