#!/bin/bash

# Gollek Documentation Site - Local Run Script
# This script starts the Jekyll server with livereload and incremental builds.

echo "🚀 Starting Wayang Documentation Site locally..."

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "❌ Error: Bundler is not installed."
    echo "Please install Ruby and Bundler first: gem install bundler"
    exit 1
fi

# Install dependencies if Gemfile.lock doesn't exist or is older than Gemfile
if [ ! -f Gemfile.lock ] || [ Gemfile -nt Gemfile.lock ]; then
    echo "📦 Installing/Updating dependencies..."
    bundle install
fi

# Run Jekyll server
echo "⚡ Starting Jekyll..."
bundle exec jekyll serve --livereload --incremental --host 0.0.0.0
