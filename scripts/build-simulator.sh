#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
xcodebuild -project MosquitoNinja.xcodeproj -scheme MosquitoNinja -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
