#!/bin/bash

# Perspective Duplicate Analysis Script
# Analyzes duplicate files without making changes

echo "🔍 Analyzing Perspective Codebase for Duplicates..."
echo "=================================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
IDENTICAL=0
DIFFERENT=0
UNIQUE_ROOT=0
UNIQUE_SUB=0

# Function to analyze duplicates
analyze_duplicate() {
    local root_file=$1
    local sub_file=$2
    local category=$3
    
    if [ -f "$root_file" ] && [ -f "$sub_file" ]; then
        if cmp -s "$root_file" "$sub_file"; then
            echo -e "${GREEN}✅ IDENTICAL:${NC} $(basename "$root_file")"
            echo "   Root: $root_file"
            echo "   Sub:  $sub_file"
            ((IDENTICAL++))
        else
            echo -e "${YELLOW}⚠️  DIFFERENT:${NC} $(basename "$root_file")"
            echo "   Root: $root_file"
            echo "   Sub:  $sub_file"
            # Show size difference
            size1=$(wc -l < "$root_file")
            size2=$(wc -l < "$sub_file")
            echo "   Size: $size1 lines (root) vs $size2 lines (sub)"
            ((DIFFERENT++))
        fi
    elif [ -f "$root_file" ] && [ ! -f "$sub_file" ]; then
        echo -e "${BLUE}📁 ONLY IN ROOT:${NC} $root_file"
        ((UNIQUE_ROOT++))
    elif [ ! -f "$root_file" ] && [ -f "$sub_file" ]; then
        echo -e "${BLUE}📁 ONLY IN SUB:${NC} $sub_file"
        ((UNIQUE_SUB++))
    fi
}

# Analyze all categories
echo -e "\n${BLUE}=== AUTHENTICATION VIEWS ===${NC}"
analyze_duplicate "perspective/Views/LoginView.swift" "perspective/Views/Authentication/LoginView.swift" "Auth"
analyze_duplicate "perspective/Views/RegisterView.swift" "perspective/Views/Authentication/RegisterView.swift" "Auth"
analyze_duplicate "perspective/Views/AuthenticationView.swift" "perspective/Views/Authentication/AuthenticationView.swift" "Auth"

echo -e "\n${BLUE}=== PROFILE VIEWS ===${NC}"
analyze_duplicate "perspective/Views/ProfileView.swift" "perspective/Views/Profile/ProfileView.swift" "Profile"
analyze_duplicate "perspective/Views/EditProfileView.swift" "perspective/Views/Profile/EditProfileView.swift" "Profile"
analyze_duplicate "perspective/Views/ProfileHeaderView.swift" "perspective/Views/Profile/ProfileHeaderView.swift" "Profile"
analyze_duplicate "perspective/Views/ProfileSettingsSectionView.swift" "perspective/Views/Profile/ProfileSettingsSectionView.swift" "Profile"
analyze_duplicate "perspective/Views/ProfileStatisticsView.swift" "perspective/Views/Profile/ProfileStatisticsView.swift" "Profile"
analyze_duplicate "perspective/Views/ProfileQuickActionsView.swift" "perspective/Views/Profile/ProfileQuickActionsView.swift" "Profile"
analyze_duplicate "perspective/Views/BiasProfileSectionView.swift" "perspective/Views/Profile/BiasProfileSectionView.swift" "Profile"

echo -e "\n${BLUE}=== CHALLENGE VIEWS ===${NC}"
analyze_duplicate "perspective/Views/DailyChallengeHeaderView.swift" "perspective/Views/Challenge/DailyChallengeHeaderView.swift" "Challenge"
analyze_duplicate "perspective/Views/ChallengeContentView.swift" "perspective/Views/Challenge/ChallengeContentView.swift" "Challenge"
analyze_duplicate "perspective/Views/ChallengeLoadingView.swift" "perspective/Views/Challenge/ChallengeLoadingView.swift" "Challenge"
analyze_duplicate "perspective/Views/ChallengeCompletedView.swift" "perspective/Views/Challenge/ChallengeCompletedView.swift" "Challenge"
analyze_duplicate "perspective/Views/CelebrationView.swift" "perspective/Views/Challenge/CelebrationView.swift" "Challenge"

echo -e "\n${BLUE}=== ECHOSCORE VIEWS ===${NC}"
analyze_duplicate "perspective/Views/EchoScoreDashboardView.swift" "perspective/Views/EchoScore/EchoScoreDashboardView.swift" "EchoScore"
analyze_duplicate "perspective/Views/EchoScoreChartView.swift" "perspective/Views/EchoScore/EchoScoreChartView.swift" "EchoScore"
analyze_duplicate "perspective/Views/EchoScoreInsightsView.swift" "perspective/Views/EchoScore/EchoScoreInsightsView.swift" "EchoScore"
analyze_duplicate "perspective/Views/CurrentEchoScoreView.swift" "perspective/Views/EchoScore/CurrentEchoScoreView.swift" "EchoScore"

echo -e "\n${BLUE}=== SERVICE LAYER ===${NC}"
analyze_duplicate "perspective/Core/NetworkMonitor.swift" "perspective/Services/NetworkMonitor.swift" "Services"
analyze_duplicate "perspective/Core/OfflineDataManager.swift" "perspective/Services/OfflineDataManager.swift" "Services"

# Additional analysis
echo -e "\n${BLUE}=== TYPE DEFINITION CONFLICTS ===${NC}"
echo "Checking for duplicate struct/class definitions..."

# Find duplicate structs
echo -e "\n${YELLOW}Duplicate Structs:${NC}"
find perspective -name "*.swift" -exec grep -H "^struct " {} \; | \
    sed 's/:struct / /' | \
    awk '{print $2}' | \
    sort | uniq -d | \
    while read struct_name; do
        echo -e "${RED}  • $struct_name${NC}"
        find perspective -name "*.swift" -exec grep -l "^struct $struct_name" {} \; | sed 's/^/    - /'
    done

# Find duplicate classes
echo -e "\n${YELLOW}Duplicate Classes:${NC}"
find perspective -name "*.swift" -exec grep -H "^class " {} \; | \
    sed 's/:class / /' | \
    awk '{print $2}' | \
    sort | uniq -d | \
    while read class_name; do
        echo -e "${RED}  • $class_name${NC}"
        find perspective -name "*.swift" -exec grep -l "^class $class_name" {} \; | sed 's/^/    - /'
    done

# Summary
echo -e "\n=================================================="
echo -e "${GREEN}ANALYSIS SUMMARY:${NC}"
echo -e "Identical files (safe to remove): ${GREEN}$IDENTICAL${NC}"
echo -e "Different files (need review): ${YELLOW}$DIFFERENT${NC}"
echo -e "Only in root Views/: ${BLUE}$UNIQUE_ROOT${NC}"
echo -e "Only in subdirectories: ${BLUE}$UNIQUE_SUB${NC}"
echo -e "\n${YELLOW}Total potential issues: $((IDENTICAL + DIFFERENT))${NC}"

if [ "$DIFFERENT" -gt 0 ]; then
    echo -e "\n${RED}⚠️  WARNING: $DIFFERENT files have different content!${NC}"
    echo -e "${YELLOW}These require manual review before migration.${NC}"
fi

echo -e "\n${BLUE}Recommendation:${NC}"
if [ "$IDENTICAL" -gt 0 ]; then
    echo -e "• Run ${GREEN}./migrate-views.sh${NC} to automatically clean up $IDENTICAL identical duplicates"
fi
if [ "$DIFFERENT" -gt 0 ]; then
    echo -e "• Manually review $DIFFERENT files with different content"
fi 