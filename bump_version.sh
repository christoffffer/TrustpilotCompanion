#!/bin/bash

# Path to manifest.json
MANIFEST="TrustpilotCompanion Extension/Resources/manifest.json"

# Skip on non-release builds
if [ "$CONFIGURATION" != "Release" ]; then
  echo "⏭ Skipping version bump in non-release build"
  exit 0
fi

# Check if manifest exists
if [ ! -f "$MANIFEST" ]; then
  echo "🚨 manifest.json not found at $MANIFEST"
  exit 1
fi

# Extract current version
CURRENT_VERSION=$(grep -o '"version": "[0-9.]*"' "$MANIFEST" | cut -d'"' -f4)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

echo "🔢 Current version is $CURRENT_VERSION"

# Prompt user to choose bump type
echo "🔧 Select version bump type:"
echo "1) Patch (default)"
echo "2) Minor"
echo "3) Major"
read -p "Choice [1-3]: " bump_type

case "$bump_type" in
  2)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  3)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  *)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update manifest.json
sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$MANIFEST"

# Commit and tag
git add "$MANIFEST"
git commit -m "Bump version to $NEW_VERSION"
git tag "v$NEW_VERSION"
git push origin main --tags

echo "✅ Version bumped to $NEW_VERSION and pushed with tag v$NEW_VERSION"

# Optionally write version to file for use in Xcode or CI
echo "$NEW_VERSION" > /tmp/latest_extension_version.txt
