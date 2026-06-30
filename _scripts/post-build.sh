#!/bin/bash
# Post-build script to copy Javadoc to _site directory
# This ensures Javadoc is served as static files

# Get the parent directory (website root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBSITE_ROOT="$(dirname "$SCRIPT_DIR")"
JAVADOC_SRC="$WEBSITE_ROOT/javadoc"
JAVADOC_DEST="$WEBSITE_ROOT/_site/javadoc"

if [ -d "$JAVADOC_SRC" ]; then
    echo "Copying Javadoc to _site/javadoc..."
    rm -rf "$JAVADOC_DEST"
    mkdir -p "$(dirname "$JAVADOC_DEST")"
    cp -r "$JAVADOC_SRC" "$JAVADOC_DEST"
    echo "✓ Javadoc copied successfully"
else
    echo "⚠ Javadoc directory not found: $JAVADOC_SRC"
    exit 1
fi
