#!/bin/bash

# Full release pipeline: version bump → commit → tag → publish
# Creates individual tags for each published package.

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/packages"
VERSION_SNAPSHOT_DIR=$(mktemp -d)

echo "=== 1. Recording current versions ==="
for pkg_dir in "$PACKAGES_DIR"/*/; do
  pkg_name=$(node -p "require('$pkg_dir/package.json').name")
  pkg_ver=$(node -p "require('$pkg_dir/package.json').version")
  echo "$pkg_ver" > "$VERSION_SNAPSHOT_DIR/$(echo "$pkg_name" | tr '/' '_')"
  echo "  $pkg_name@$pkg_ver"
done

echo ""
echo "=== 2. Bumping versions ==="
pnpm changeset version

echo ""
echo "=== 3. Updating lockfile ==="
pnpm install --lockfile-only

echo ""
echo "=== 4. Determining changed packages ==="
TAGS=""
for pkg_dir in "$PACKAGES_DIR"/*/; do
  pkg_name=$(node -p "require('$pkg_dir/package.json').name")
  new_ver=$(node -p "require('$pkg_dir/package.json').version")
  snap_file="$VERSION_SNAPSHOT_DIR/$(echo "$pkg_name" | tr '/' '_')"
  old_ver=$(cat "$snap_file" 2>/dev/null || echo "unknown")
  if [ "$new_ver" != "$old_ver" ]; then
    echo "  $pkg_name: $old_ver → $new_ver"
    TAGS="$TAGS $pkg_name@$new_ver"
  fi
done
rm -rf "$VERSION_SNAPSHOT_DIR"

if [ -z "$TAGS" ]; then
  echo "  No packages were bumped. Nothing to do."
  exit 0
fi

echo ""
echo "=== 5. Committing ==="
git add .
git commit -m "chore: version bump"

echo ""
echo "=== 6. Creating tags ==="
for tag in $TAGS; do
  echo "  git tag $tag"
  git tag "$tag"
done

echo ""
echo "=== 7. Publishing to npm ==="
pnpm changeset publish

echo ""
echo "=== 8. Pushing to remote ==="
echo "  git push && git push --tags"
git push
git push --tags

echo ""
echo "=== Done! ==="
echo "Published: $TAGS"
