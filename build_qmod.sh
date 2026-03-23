#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== SliderClickControl Build Script ===${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ -z "$ANDROID_NDK_HOME" ]; then
    ANDROID_NDK_HOME="$HOME/.local/share/QPM-RS/ndk/27.3.13750724+preview-0"
    echo -e "${YELLOW}ANDROID_NDK_HOME not set, using: $ANDROID_NDK_HOME${NC}"
fi

if [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo -e "${RED}Error: Android NDK not found at $ANDROID_NDK_HOME${NC}"
    exit 1
fi

export ANDROID_NDK_HOME

echo -e "${GREEN}Step 1: Restoring dependencies...${NC}"
qpm restore

echo -e "${GREEN}Step 2: Configuring build...${NC}"
if [ -d "build" ]; then
    echo "Cleaning old build directory..."
    rm -rf build
fi

cmake -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -B build .

echo -e "${GREEN}Step 3: Building...${NC}"
cmake --build ./build

echo -e "${GREEN}Step 4: Creating .qmod package...${NC}"
QMOD_FILE="SliderClickControl.qmod"

if [ -f "$QMOD_FILE" ]; then
    rm "$QMOD_FILE"
    echo "Removed old $QMOD_FILE"
fi

zip -j "$QMOD_FILE" mod.json build/libsliderclickcontrol.so

FILE_SIZE=$(du -h "$QMOD_FILE" | cut -f1)

echo ""
echo -e "${GREEN}=== Build Complete! ===${NC}"
echo -e "Created: ${YELLOW}$QMOD_FILE${NC} (${FILE_SIZE})"
echo -e "Location: ${YELLOW}$(pwd)/$QMOD_FILE${NC}"
