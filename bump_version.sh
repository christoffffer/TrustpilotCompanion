#!/bin/bash

# Path to manifest.json
MANIFEST="TrustpilotCompanion Extension/Resources/manifest.json"

# Extract current version
CURRENT_VERSION=$(grep -o '"version": "[0-9.]*"' "$MANIFEST" | cut -d'"' -f4)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Bump patch version
PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update manifest.json
sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$MANIFEST"

# Commit and tag
git add "$MANIFEST"
git commit -m "Bump version to $NEW_VERSION"
git tag "v$NEW_VERSION"
git push origin main --tags
if [ "$CONFIGURATION" != "Release" ]; then
  echo "Skipping version bump in non-release build"
  exit 0
fi
if [ ! -f "$MANIFEST" ]; then
  echo "🚨 manifest.json not found at $MANIFEST"
  exit 1
fi
echo "✅ Version bumped to $NEW_VERSION and pushed with tag v$NEW_VERSION"
