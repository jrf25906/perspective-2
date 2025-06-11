#!/bin/bash

# Target Membership Verification Script
# Checks for common iOS project configuration issues

echo "🔍 Perspective iOS Project Verification"
echo "========================================"

PROJECT_DIR="/Users/jamesfarmer/Desktop/perspective/perspective"
XCODE_PROJECT="/Users/jamesfarmer/Desktop/perspective/perspective.xcodeproj"

# Check if project exists
if [ ! -d "$XCODE_PROJECT" ]; then
    echo "❌ ERROR: Xcode project not found at $XCODE_PROJECT"
    exit 1
fi

echo "✅ Xcode project found"

# Check for Swift files
SWIFT_FILES=$(find "$PROJECT_DIR" -name "*.swift" | wc -l)
echo "📄 Found $SWIFT_FILES Swift files"

# List all Swift files by category
echo ""
echo "📂 File Structure Analysis:"
echo "=========================="

# Models
MODELS_COUNT=$(find "$PROJECT_DIR/Models" -name "*.swift" 2>/dev/null | wc -l)
echo "Models: $MODELS_COUNT files"
find "$PROJECT_DIR/Models" -name "*.swift" 2>/dev/null | sed 's|.*/||' | sort

# Services
SERVICES_COUNT=$(find "$PROJECT_DIR/Services" -name "*.swift" 2>/dev/null | wc -l)
echo "Services: $SERVICES_COUNT files"
find "$PROJECT_DIR/Services" -name "*.swift" 2>/dev/null | sed 's|.*/||' | sort

# Views
VIEWS_COUNT=$(find "$PROJECT_DIR/Views" -name "*.swift" 2>/dev/null | wc -l)
echo "Views: $VIEWS_COUNT files"
find "$PROJECT_DIR/Views" -name "*.swift" 2>/dev/null | sed 's|.*/||' | sort

# Core
CORE_COUNT=$(find "$PROJECT_DIR/Core" -name "*.swift" 2>/dev/null | wc -l)
echo "Core: $CORE_COUNT files"
find "$PROJECT_DIR/Core" -name "*.swift" 2>/dev/null | sed 's|.*/||' | sort

# Utils
UTILS_COUNT=$(find "$PROJECT_DIR/Utils" -name "*.swift" 2>/dev/null | wc -l)
echo "Utils: $UTILS_COUNT files"
find "$PROJECT_DIR/Utils" -name "*.swift" 2>/dev/null | sed 's|.*/||' | sort

echo ""
echo "🔧 Required Actions:"
echo "==================="
echo "1. Open Xcode project: $XCODE_PROJECT"
echo "2. For each folder (Models, Services, Views, Core, Utils):"
echo "   - Right-click folder in Project Navigator"
echo "   - Select 'Add Files to perspective...'"
echo "   - Navigate to corresponding physical folder"
echo "   - Select all .swift files"
echo "   - UNCHECK 'Copy items if needed'"
echo "   - ENSURE 'perspective' target is checked"
echo "   - Click 'Add'"
echo ""
echo "3. Add Swift Package Dependencies:"
echo "   - File → Add Packages..."
echo "   - Add: https://github.com/kishikawakatsumi/KeychainAccess"
echo "   - Add: https://github.com/google/GoogleSignIn-iOS"
echo ""
echo "4. Clean and Build:"
echo "   - Product → Clean Build Folder (⇧⌘K)"
echo "   - Product → Build (⌘B)"

# Check for critical files
echo ""
echo "🎯 Critical File Verification:"
echo "============================="

CRITICAL_FILES=(
    "Models/APIError.swift"
    "Models/User.swift" 
    "Models/Challenge.swift"
    "Models/NewsReference.swift"
    "Services/APIService.swift"
    "Services/AuthenticationService.swift"
    "Services/NetworkClient.swift"
    "Core/UserPreferences.swift"
    "Core/AppEnvironment.swift"
    "Views/LoginView.swift"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo "✅ $file"
    else
        echo "❌ MISSING: $file"
    fi
done

echo ""
echo "🚀 Next Steps:"
echo "=============="
echo "1. Run: chmod +x verify-targets.sh"
echo "2. Follow the Required Actions above"
echo "3. Re-run this script to verify fixes"
echo "4. Check build status in Xcode"

# Generate Swift file import verification
echo ""
echo "💡 Swift Import Verification:"
echo "============================="
echo "After adding files to Xcode, verify these imports work:"
echo ""
echo "import Foundation"
echo "import SwiftUI"
echo "import Combine"
echo "import KeychainAccess"
echo "import GoogleSignIn"
echo ""
echo "Test compilation of critical types:"
echo "let user = User(id: \"test\", email: \"test@example.com\", username: \"test\")"
echo "let error = APIError.unauthorized"
echo "let preferences = UserPreferences()"
echo "let config = Config.current" 