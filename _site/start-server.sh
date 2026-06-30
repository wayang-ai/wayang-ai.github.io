#!/bin/bash
# Start Jekyll for Wayang AI website
# This script handles port conflicts automatically

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT=4001
BUNDLER_VERSION="2.5.22"

echo "==================================="
echo "Wayang AI Website - Jekyll Server"
echo "==================================="
echo ""

# Kill any existing Jekyll processes
echo "Stopping any existing Jekyll servers..."
pkill -9 -f "jekyll serve" 2>/dev/null || true
pkill -9 -f webrick 2>/dev/null || true
sleep 2

# Check if port is in use
if lsof -i:$PORT > /dev/null 2>&1; then
    echo "Port $PORT is in use, finding alternative..."
    PORT=$((PORT + 1))
fi

# Copy Javadoc to _site
echo "Copying Javadoc to _site..."
if [ -x "$SCRIPT_DIR/_scripts/post-build.sh" ]; then
    "$SCRIPT_DIR/_scripts/post-build.sh"
else
    echo "⚠ Post-build script not found or not executable"
fi

echo ""
echo "Starting Jekyll on port $PORT..."
echo "==================================="
echo ""
echo "Access your site at:"
echo "  Home:    http://127.0.0.1:$PORT"
echo "  Docs:    http://127.0.0.1:$PORT/docs/"
echo "  Javadoc: http://127.0.0.1:$PORT/docs/javadoc/index.html"
echo ""
echo "Press Ctrl+C to stop the server"
echo "==================================="
echo ""

# Start Jekyll with specific Bundler version
cd "$SCRIPT_DIR"
bundle _$BUNDLER_VERSION_ exec jekyll serve --port $PORT --force-polling --host 127.0.0.1
