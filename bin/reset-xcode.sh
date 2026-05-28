#!/bin/bash
#
# reset-xcode.sh
#
# A helper script to reset Xcode's cached state when it starts complaining
# about files being "modified by another application" after git operations.
#
# Usage:
#   ./bin/reset-xcode.sh
#
# This is safe to run. It will:
#   1. Quit Xcode (if running)
#   2. Clear DerivedData and ModuleCache
#   3. Optionally clear workspace user data (with confirmation)
#
# Because you're working with AI tools (Grok + Claude) and terminal git,
# you'll probably run this more often than most developers.
#

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME=$(basename "$PROJECT_ROOT")

echo "========================================"
echo "  Xcode State Reset Utility"
echo "  Project: $PROJECT_NAME"
echo "========================================"
echo

# 1. Quit Xcode gracefully
echo "→ Quitting Xcode (if it's running)..."
osascript -e 'tell application "Xcode" to quit' 2>/dev/null || true
sleep 1.5

# 2. Clear Derived Data (biggest source of weirdness)
echo "→ Clearing DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true

# 3. Clear Module Cache (often helps after rebase or branch switches)
echo "→ Clearing ModuleCache..."
rm -rf ~/Library/Developer/Xcode/ModuleCache.noindex/* 2>/dev/null || true

# 4. Ask about clearing workspace user data (more aggressive)
echo
read -p "Also clear this project's workspace user data (open tabs, breakpoints, etc.)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "→ Clearing workspace xcuserdata..."
    rm -rf "$PROJECT_ROOT"/*.xcodeproj/project.xcworkspace/xcuserdata 2>/dev/null || true
    rm -rf "$PROJECT_ROOT"/*.xcodeproj/xcuserdata 2>/dev/null || true
    echo "   (Workspace state cleared. You'll lose open file history, etc.)"
else
    echo "   Skipped workspace user data."
fi

echo
echo "========================================"
echo "  Reset complete."
echo
echo "  Next steps:"
echo "    1. Reopen the project in Xcode"
echo "    2. If issues persist, do Product → Clean Build Folder (⇧⌘K)"
echo "    3. In extreme cases, delete the entire DerivedData folder manually"
echo "========================================"
echo

# Optional: show current git status so you know where you stand
if command -v git &> /dev/null; then
    echo "Current git status:"
    git -C "$PROJECT_ROOT" status --short
fi
