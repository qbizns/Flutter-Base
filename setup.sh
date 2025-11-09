#!/bin/bash

# Flutter Starter Template Setup Script
# This script helps you set up the project after cloning

set -e  # Exit on error

echo "🚀 Flutter Starter Template Setup"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓${NC} Flutter is installed"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
echo "Flutter version: $FLUTTER_VERSION"
echo ""

# Run Flutter doctor
echo "📋 Running Flutter doctor..."
flutter doctor
echo ""

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Dependencies installed successfully"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi
echo ""

# Run code generation
echo "🔧 Running code generation..."
flutter pub run build_runner build --delete-conflicting-outputs
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Code generation completed"
else
    echo -e "${YELLOW}⚠${NC}  Code generation failed (this might be expected if providers are not set up yet)"
fi
echo ""

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Code analysis passed"
else
    echo -e "${YELLOW}⚠${NC}  Code analysis found issues"
fi
echo ""

# Format code
echo "✨ Formatting code..."
dart format lib/ test/
echo -e "${GREEN}✓${NC} Code formatted"
echo ""

# Run tests
echo "🧪 Running tests..."
flutter test
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All tests passed"
else
    echo -e "${RED}❌ Some tests failed${NC}"
fi
echo ""

# Display available commands
echo ""
echo "=================================="
echo "📚 Available Commands"
echo "=================================="
echo ""
echo "Run on different platforms:"
echo "  flutter run -d chrome       # Web"
echo "  flutter run -d ios          # iOS"
echo "  flutter run -d android      # Android"
echo "  flutter run -d windows      # Windows"
echo "  flutter run -d macos        # macOS"
echo "  flutter run -d linux        # Linux"
echo ""
echo "Build for production:"
echo "  flutter build web --release"
echo "  flutter build apk --release"
echo "  flutter build ios --release"
echo "  flutter build windows --release"
echo "  flutter build macos --release"
echo "  flutter build linux --release"
echo ""
echo "Development commands:"
echo "  flutter test                          # Run tests"
echo "  flutter test --coverage               # Generate coverage"
echo "  flutter analyze                       # Analyze code"
echo "  dart format lib/ test/                # Format code"
echo "  flutter pub run build_runner watch    # Watch for changes"
echo ""
echo -e "${GREEN}✓${NC} Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Customize the app in lib/src/core/config/app_config.dart"
echo "2. Update colors in lib/src/core/theme/app_colors.dart"
echo "3. Add your logo to assets/logo/"
echo "4. Start building your features in lib/src/features/"
echo ""
echo "Happy coding! 🎉"
