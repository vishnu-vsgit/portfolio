#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Clone Flutter stable branch if it doesn't exist (shallow clone for speed)
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable branch)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "Flutter SDK already exists. Fetching updates..."
  cd flutter
  git pull origin stable
  cd ..
fi

# Add Flutter to the path
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify Flutter installation
flutter --version

# Enable Web support
flutter config --enable-web

# Get project dependencies
flutter pub get

# Build the release web bundle
flutter build web --release
