#!/bin/bash
# Generate Javadoc for Wayang AI Platform
# Usage: ./generate-javadoc.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WAYANG_DIR="$PROJECT_ROOT/wayang"
JAVADOC_OUTPUT="$PROJECT_ROOT/website/wayang.github.io/javadoc"

echo "==================================="
echo "Wayang AI Platform - Javadoc Generator"
echo "==================================="
echo ""
echo "Project Root: $PROJECT_ROOT"
echo "Javadoc Output: $JAVADOC_OUTPUT"
echo ""

# Clean existing Javadoc
echo "Cleaning existing Javadoc..."
rm -rf "$JAVADOC_OUTPUT"/*
mkdir -p "$JAVADOC_OUTPUT"

# Generate Javadoc
echo "Generating Javadoc (this may take a few minutes)..."
cd "$WAYANG_DIR"
mvn javadoc:aggregate-no-fork \
    -DskipTests \
    -Dmaven.test.skip=true \
    -Dcompiler.skipMainCompilation=true \
    -q

# Copy to correct location if needed
if [ -d "$WAYANG_DIR/website/wayang.github.io/javadoc" ]; then
    echo "Copying Javadoc to website directory..."
    cp -r "$WAYANG_DIR/website/wayang.github.io/javadoc/"* "$JAVADOC_OUTPUT/"
    rm -rf "$WAYANG_DIR/website"
fi

echo ""
echo "==================================="
echo "✓ Javadoc generation complete!"
echo "==================================="
echo ""
echo "To view the Javadoc:"
echo "  1. Open in browser: open $JAVADOC_OUTPUT/index.html"
echo "  2. Or run Jekyll: cd website/wayang.github.io && bundle exec jekyll serve"
echo "  3. Navigate to: http://localhost:4000/docs/javadoc/index.html"
echo ""
