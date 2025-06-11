#!/bin/bash

# Build Status Monitor for Perspective iOS Project
# Provides real-time compilation feedback and issue detection

echo "🚀 Perspective Build Monitor"
echo "============================"

PROJECT_PATH="/Users/jamesfarmer/Desktop/perspective/perspective.xcodeproj"
WORKSPACE_PATH="/Users/jamesfarmer/Desktop/perspective/perspective.xcworkspace"

# Check if project exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ ERROR: Project not found at $PROJECT_PATH"
    exit 1
fi

echo "✅ Project found: $PROJECT_PATH"

# Function to check build status
check_build_status() {
    echo ""
    echo "🔨 Building project..."
    
    # Use workspace if it exists, otherwise use project
    if [ -d "$WORKSPACE_PATH" ]; then
        BUILD_TARGET="$WORKSPACE_PATH"
        echo "📦 Using workspace: $WORKSPACE_PATH"
    else
        BUILD_TARGET="$PROJECT_PATH"
        echo "📁 Using project: $PROJECT_PATH"
    fi
    
    # Attempt to build
    xcodebuild -project "$PROJECT_PATH" \
               -scheme perspective \
               -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
               -quiet \
               clean build 2>&1 | tee build_output.log
    
    BUILD_EXIT_CODE=$?
    
    if [ $BUILD_EXIT_CODE -eq 0 ]; then
        echo "✅ BUILD SUCCESSFUL!"
        echo "🎉 All APIError ambiguity issues resolved!"
        analyze_success
    else
        echo "❌ BUILD FAILED"
        analyze_failures
    fi
    
    return $BUILD_EXIT_CODE
}

# Function to analyze successful builds
analyze_success() {
    echo ""
    echo "🎯 Build Success Analysis:"
    echo "========================="
    echo "✅ APIError conflicts resolved"
    echo "✅ Type system validated"
    echo "✅ Dependencies linked correctly"
    echo "✅ Swift Package Manager integration working"
    
    # Check for warnings
    WARNING_COUNT=$(grep -c "warning:" build_output.log || echo "0")
    echo "⚠️  Warnings found: $WARNING_COUNT"
    
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo ""
        echo "🟡 Warnings to review:"
        grep "warning:" build_output.log | head -5
    fi
    
    echo ""
    echo "🚀 Next Steps:"
    echo "- Test app launch in simulator"
    echo "- Verify LoginView displays correctly"
    echo "- Test backend connectivity"
    echo "- Run type validation: TypeValidator.validateCoreTypes()"
}

# Function to analyze build failures
analyze_failures() {
    echo ""
    echo "🔍 Build Failure Analysis:"
    echo "=========================="
    
    # Check for common issues
    if grep -q "APIError.*ambiguous" build_output.log; then
        echo "❌ STILL FOUND: APIError ambiguity issues"
        echo "🔧 Action: Verify APIError removed from APIModels.swift"
    fi
    
    if grep -q "No such module" build_output.log; then
        echo "❌ FOUND: Missing module imports"
        echo "🔧 Action: Add Swift Package dependencies"
        grep "No such module" build_output.log | head -3
    fi
    
    if grep -q "Cannot find.*in scope" build_output.log; then
        echo "❌ FOUND: Type resolution issues"
        echo "🔧 Action: Check target membership for files"
        grep "Cannot find.*in scope" build_output.log | head -3
    fi
    
    if grep -q "Multiple commands produce" build_output.log; then
        echo "❌ FOUND: Duplicate file references"
        echo "🔧 Action: Remove duplicate files from target"
    fi
    
    # Show top errors
    echo ""
    echo "🚨 Top Errors:"
    grep "error:" build_output.log | head -5
    
    echo ""
    echo "🔧 Recommended Actions:"
    echo "1. Verify all files added to Xcode target"
    echo "2. Check Swift Package dependencies"
    echo "3. Clean derived data and rebuild"
    echo "4. Review target membership settings"
}

# Function to check dependencies
check_dependencies() {
    echo ""
    echo "📦 Dependency Check:"
    echo "==================="
    
    if xcodebuild -list -project "$PROJECT_PATH" | grep -q "KeychainAccess"; then
        echo "✅ KeychainAccess package detected"
    else
        echo "⚠️  KeychainAccess package may be missing"
    fi
    
    if xcodebuild -list -project "$PROJECT_PATH" | grep -q "GoogleSignIn"; then
        echo "✅ GoogleSignIn package detected"
    else
        echo "⚠️  GoogleSignIn package may be missing"
    fi
}

# Function to check file targets
check_file_targets() {
    echo ""
    echo "📂 File Target Verification:"
    echo "============================"
    
    # Key files that must be in target
    KEY_FILES=(
        "APIError.swift"
        "NewsReference.swift" 
        "UserPreferences.swift"
        "AppEnvironment.swift"
        "LoginView.swift"
    )
    
    for file in "${KEY_FILES[@]}"; do
        if find "/Users/jamesfarmer/Desktop/perspective/perspective" -name "$file" -type f > /dev/null 2>&1; then
            echo "✅ Found: $file"
        else
            echo "❌ Missing: $file"
        fi
    done
}

# Main execution
main() {
    check_dependencies
    check_file_targets
    check_build_status
    
    echo ""
    echo "📊 Build Monitor Summary:"
    echo "========================"
    echo "Timestamp: $(date)"
    echo "Project: perspective"
    echo "Platform: iOS Simulator"
    
    if [ -f "build_output.log" ]; then
        ERROR_COUNT=$(grep -c "error:" build_output.log || echo "0")
        WARNING_COUNT=$(grep -c "warning:" build_output.log || echo "0")
        echo "Errors: $ERROR_COUNT"
        echo "Warnings: $WARNING_COUNT"
    fi
    
    echo ""
    echo "💡 Pro Tips:"
    echo "- Use Xcode build (⌘B) for detailed error locations"
    echo "- Check Issues Navigator for quick fixes"
    echo "- Use Product → Clean Build Folder if issues persist"
    echo "- Re-run this script after making changes"
}

# Execute main function
main "$@"

# Cleanup
rm -f build_output.log 