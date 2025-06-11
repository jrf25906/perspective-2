#!/bin/bash

# Source and destination paths
OLD_PROJECT="/Users/jamesfarmer/perspective-app/ios/Perspective"
NEW_PROJECT="/Users/jamesfarmer/Desktop/perspective/perspective"

echo "Copying all Swift files from old project to new project..."

# Copy all Models
echo "Copying Models..."
cp "$OLD_PROJECT/Models/"*.swift "$NEW_PROJECT/Models/" 2>/dev/null || true

# Copy all Services
echo "Copying Services..."
cp "$OLD_PROJECT/Services/"*.swift "$NEW_PROJECT/Services/" 2>/dev/null || true

# Copy all Views (excluding the main app files)
echo "Copying Views..."
find "$OLD_PROJECT/Views" -name "*.swift" -not -name "PerspectiveApp.swift" -not -name "AppDelegate.swift" -exec cp {} "$NEW_PROJECT/Views/" \; 2>/dev/null || true

# Copy View subdirectories
echo "Copying View subdirectories..."
for dir in Authentication Challenge Components Debug DesignSystem EchoScore Profile; do
    if [ -d "$OLD_PROJECT/Views/$dir" ]; then
        mkdir -p "$NEW_PROJECT/Views/$dir"
        find "$OLD_PROJECT/Views/$dir" -name "*.swift" -exec cp {} "$NEW_PROJECT/Views/$dir/" \; 2>/dev/null || true
    fi
done

# Copy Utils
echo "Copying Utils..."
cp "$OLD_PROJECT/Utils/"*.swift "$NEW_PROJECT/Utils/" 2>/dev/null || true

# Copy ViewModels if exists
if [ -d "$OLD_PROJECT/ViewModels" ]; then
    echo "Copying ViewModels..."
    mkdir -p "$NEW_PROJECT/ViewModels"
    cp "$OLD_PROJECT/ViewModels/"*.swift "$NEW_PROJECT/ViewModels/" 2>/dev/null || true
fi

# Copy Extensions if exists
if [ -d "$OLD_PROJECT/Extensions" ]; then
    echo "Copying Extensions..."
    mkdir -p "$NEW_PROJECT/Extensions"
    cp "$OLD_PROJECT/Extensions/"*.swift "$NEW_PROJECT/Extensions/" 2>/dev/null || true
fi

# Copy Managers if exists
if [ -d "$OLD_PROJECT/Managers" ]; then
    echo "Copying Managers..."
    mkdir -p "$NEW_PROJECT/Managers"
    cp "$OLD_PROJECT/Managers/"*.swift "$NEW_PROJECT/Managers/" 2>/dev/null || true
fi

# Copy Protocols
if [ -d "$OLD_PROJECT/Protocols" ]; then
    echo "Copying Protocols..."
    mkdir -p "$NEW_PROJECT/Protocols"
    cp "$OLD_PROJECT/Protocols/"*.swift "$NEW_PROJECT/Protocols/" 2>/dev/null || true
fi

# Copy Data
if [ -d "$OLD_PROJECT/Data" ]; then
    echo "Copying Data..."
    mkdir -p "$NEW_PROJECT/Data"
    cp "$OLD_PROJECT/Data/"*.swift "$NEW_PROJECT/Data/" 2>/dev/null || true
fi

# Copy Core
if [ -d "$OLD_PROJECT/Core" ]; then
    echo "Copying Core..."
    cp "$OLD_PROJECT/Core/"*.swift "$NEW_PROJECT/Core/" 2>/dev/null || true
fi

# Copy configuration files
echo "Copying configuration files..."
cp "$OLD_PROJECT/GoogleService-Info.plist" "$NEW_PROJECT/" 2>/dev/null || true

echo "File copy complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Right-click on each folder and 'Add Files to perspective...'"
echo "3. Make sure to uncheck 'Copy items if needed'"
echo "4. Ensure your app target is selected" 