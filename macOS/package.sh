#!/bin/bash

# package.sh - Create a Critique.dmg (Free Path)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Change to the script's directory so paths are relative to the project
cd "$(dirname "$0")"

echo -e "${BLUE}==> Starting Critique Build & Packaging...${NC}"

# 1. Configuration
APP_NAME="Critique"
SCHEME="Critique"
BUILD_DIR="./build"
DMG_NAME="Critique.dmg"
RELEASE_DIR="$BUILD_DIR/Release"
STAGING_DIR="$BUILD_DIR/Staging"

# 2. Clean up old builds
echo -e "${BLUE}==> Cleaning old build files...${NC}"
rm -rf "$BUILD_DIR"
rm -f "$DMG_NAME"

# 3. Build the App
echo -e "${BLUE}==> Building $APP_NAME in Release mode...${NC}"
# We use xcodebuild to create a signed-to-run (locally) archive
xcodebuild build \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=YES \
    CODE_SIGNING_ALLOWED=YES

if [ $? -ne 0 ]; then
    echo -e "${RED}xcodebuild failed. Check the error above.${NC}"
    echo -e "${RED}NOTE: You may need to run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer${NC}"
    exit 1
fi

# 4. Prepare Staging Area
echo -e "${BLUE}==> Preparing DMG staging area...${NC}"
mkdir -p "$STAGING_DIR"

# Find the .app - handle nested folder structure of derivedData
APP_PATH=$(find "$BUILD_DIR" -name "*.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}Could not find the built .app bundle.${NC}"
    exit 1
fi

cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# 5. Create DMG
echo -e "${BLUE}==> Creating $DMG_NAME...${NC}"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}SUCCESS! Your DMG is ready: ${DMG_NAME}${NC}"
    echo -e "${GREEN}To share:${NC}"
    echo -e "1. Upload ${DMG_NAME} to GitHub Releases."
    echo -e "2. Tell users to ${BLUE}Right-Click -> Open${NC} the first time."
else
    echo -e "${RED}DMG creation failed.${NC}"
    exit 1
fi

# Cleanup staging
rm -rf "$BUILD_DIR"
