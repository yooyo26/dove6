#!/bin/bash
echo "Building DOVE6 Flutter client for Linux..."
cd "$(dirname "$0")/../client"
flutter pub get
flutter build linux --release
echo "Build complete."
echo "Binary: client/build/linux/x64/release/bundle/dove6_client"
