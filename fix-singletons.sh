#!/bin/bash

# Fix Singleton Pattern Script
# Adds 'final' modifier to all singleton classes

echo "🔧 Fixing Singleton Pattern Issues..."
echo "===================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counter
FIXED=0

# Find all files with singleton pattern
SINGLETONS=$(find perspective -name "*.swift" -exec grep -l "static let shared" {} \;)

for file in $SINGLETONS; do
    # Skip if already final
    if grep -q "final class" "$file"; then
        continue
    fi
    
    # Skip mock classes
    if [[ $(basename "$file") =~ Mock ]]; then
        continue
    fi
    
    # Check if it's a class with singleton
    if grep -q "class.*{" "$file" && grep -q "static let shared" "$file"; then
        # Replace 'class ClassName' with 'final class ClassName'
        sed -i '' 's/^\([ ]*\)class \([A-Za-z0-9_]*\)/\1final class \2/' "$file"
        echo -e "${GREEN}✅ Fixed: $file${NC}"
        ((FIXED++))
    fi
done

echo -e "\n===================================="
echo -e "${GREEN}Fixed $FIXED singleton classes${NC}"
echo -e "${YELLOW}Remember to run validation script to verify${NC}" 