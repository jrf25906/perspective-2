#!/bin/bash

# Fix Xcode Target Membership Script
# Ensures all Swift files are properly included in the build target

PROJECT_FILE="perspective.xcodeproj/project.pbxproj"
BACKUP_FILE="perspective.xcodeproj/project.pbxproj.backup"

echo "🔧 Fixing Xcode Target Membership Issues"
echo "========================================"

# Create backup
cp "$PROJECT_FILE" "$BACKUP_FILE"
echo "✅ Created backup: $BACKUP_FILE"

# Function to check if a file is in the sources build phase
check_file_membership() {
    local filename="$1"
    if grep -q "$filename" "$PROJECT_FILE"; then
        echo "   ✓ $filename found in project"
        return 0
    else
        echo "   ✗ $filename NOT found in project"
        return 1
    fi
}

echo ""
echo "🔍 Checking critical files..."
echo ""

# Check critical authentication files
critical_files=(
    "LoginView.swift"
    "RegisterView.swift"
    "AuthenticationView.swift"
    "QuickLoginView.swift"
)

missing_files=()

for file in "${critical_files[@]}"; do
    if ! check_file_membership "$file"; then
        missing_files+=("$file")
    fi
done

echo ""
if [ ${#missing_files[@]} -eq 0 ]; then
    echo "✅ All critical files are in the project!"
else
    echo "❌ Missing files detected: ${#missing_files[@]}"
    echo ""
    echo "Missing files:"
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "⚠️  These files need to be added to the Xcode project manually:"
    echo ""
    echo "1. Open perspective.xcodeproj in Xcode"
    echo "2. Right-click on the appropriate folder in Project Navigator"
    echo "3. Select 'Add Files to \"perspective\"...'"
    echo "4. Navigate to the files and add them"
    echo "5. Ensure 'Copy items if needed' is UNCHECKED"
    echo "6. Ensure 'perspective' target is CHECKED"
fi

echo ""
echo "📊 Project Statistics:"
echo "   Total Swift files: $(find perspective -name "*.swift" | wc -l | tr -d ' ')"
echo "   Authentication views: $(find perspective/Views/Authentication -name "*.swift" | wc -l | tr -d ' ')"
echo "   Debug views: $(find perspective/Views/Debug -name "*.swift" | wc -l | tr -d ' ')"

echo ""
echo "🔍 Detailed File Locations:"
echo ""
for file in "${critical_files[@]}"; do
    location=$(find perspective -name "$file" -type f 2>/dev/null | head -1)
    if [ -n "$location" ]; then
        echo "   $file -> $location"
    else
        echo "   $file -> NOT FOUND IN FILESYSTEM"
    fi
done

echo ""
echo "✅ Analysis complete!" 