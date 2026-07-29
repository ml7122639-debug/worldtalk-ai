#!/usr/bin/env bash
# ──────────────────────────────────────────────────
#  WorldTalk AI — APK Builder (Local Machine)
# ──────────────────────────────────────────────────
#  Prerequisites: Flutter SDK 3.44+, Android SDK
#
#  Usage:
#    chmod +x build.sh && ./build.sh
#
#  Output:
#    build/app/outputs/flutter-apk/app-release.apk
# ──────────────────────────────────────────────────
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}→${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; exit 1; }

info "Checking Flutter..."
command -v flutter &>/dev/null || err "Flutter not found. Install from https://docs.flutter.dev/get-started/install"
flutter --version | head -1

info "Running flutter doctor..."
flutter doctor --android-licenses 2>&1 | tail -2

info "Generating Android project files..."
flutter create --org com.worldtalk --project-name worldtalk_ai .

info "Installing dependencies..."
flutter pub get

info "Running analysis..."
flutter analyze --no-fatal-infos || err "Fix the warnings above first"

info "Building release APK..."
flutter build apk --release

APK=build/app/outputs/flutter-apk/app-release.apk
SIZE=$(du -h "$APK" | cut -f1)

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ APK BUILT SUCCESSFULLY!${NC}"
echo -e "${GREEN}  📦 Size: $SIZE${NC}"
echo -e "${GREEN}  📁 Path: $APK${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Transfer to your phone:"
echo "  1. USB:  adb install $APK"
echo "  2. WiFi: Upload to Google Drive / WhatsApp"
