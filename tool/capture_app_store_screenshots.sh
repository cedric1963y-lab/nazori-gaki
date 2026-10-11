#!/usr/bin/env bash
# Builds a debug simulator app for each store shot, launches it on the booted
# simulator and saves a RAW screenshot (xcrun simctl io screenshot).
# No cropping, framing or editing. The SHOWCASE dart-define is read by debug
# builds only; release builds ignore it.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-$HOME/Downloads/nazori-screenshots-raw}"
BUNDLE=jp.nazorigaki.app
mkdir -p "$OUT"
xcrun simctl list devices booted | grep -q Booted || { echo "boot a simulator first" >&2; exit 1; }
xcrun simctl status_bar booted override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100 || true

# Close other apps so the status bar shows no "back to app" breadcrumb.
for app in $(xcrun simctl spawn booted launchctl list | sed -nE 's/.*UIKitApplication:([^[]+)\[.*/\1/p' | grep -v '^com\.apple\.' | sort -u); do
  xcrun simctl terminate booted "$app" 2>/dev/null || true
done

shot() { # name scene
  local name=$1 scene=$2
  flutter build ios --simulator --debug --dart-define=SHOWCASE=$scene >/dev/null
  xcrun simctl terminate booted $BUNDLE 2>/dev/null || true
  xcrun simctl install booted build/ios/iphonesimulator/Runner.app
  xcrun simctl launch booted $BUNDLE >/dev/null
  sleep 12
  xcrun simctl io booted screenshot "$OUT/$name.png"
  sips -g pixelWidth -g pixelHeight "$OUT/$name.png" | tail -2
}

shot 01-purpose home
shot 02-shugi-name shugi
shot 03-kouden-usuzumi kouden
shot 04-noshi noshi
shot iap-review-unlock unlock
echo "saved to $OUT"
