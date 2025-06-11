#!/bin/bash

# Perspective Views Migration Script
# Systematically resolves duplicate files by keeping organized versions
# and removing duplicates from root Views directory

echo "🔄 Starting Perspective Views Migration..."
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
REMOVED=0
CONFLICTS=0
ERRORS=0

# Function to log actions
log_action() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

# Function to check if file exists in subdirectory
check_and_remove_duplicate() {
    local root_file=$1
    local sub_file=$2
    local description=$3
    
    if [ -f "$root_file" ] && [ -f "$sub_file" ]; then
        # Compare files
        if cmp -s "$root_file" "$sub_file"; then
            # Files are identical, safe to remove root version
            rm "$root_file"
            log_action "Removed duplicate: $root_file (identical to $sub_file)"
            ((REMOVED++))
        else
            # Files differ, need manual review
            log_warning "CONFLICT: $root_file differs from $sub_file - manual review needed"
            echo "  Description: $description"
            ((CONFLICTS++))
        fi
    elif [ -f "$root_file" ] && [ ! -f "$sub_file" ]; then
        # Only root version exists, move it
        mkdir -p "$(dirname "$sub_file")"
        mv "$root_file" "$sub_file"
        log_action "Moved: $root_file → $sub_file"
        ((REMOVED++))
    fi
}

echo -e "\n${BLUE}Phase 1: Authentication Views${NC}"
check_and_remove_duplicate \
    "perspective/Views/LoginView.swift" \
    "perspective/Views/Authentication/LoginView.swift" \
    "User login interface"

check_and_remove_duplicate \
    "perspective/Views/RegisterView.swift" \
    "perspective/Views/Authentication/RegisterView.swift" \
    "User registration interface"

check_and_remove_duplicate \
    "perspective/Views/AuthenticationView.swift" \
    "perspective/Views/Authentication/AuthenticationView.swift" \
    "Authentication container view"

echo -e "\n${BLUE}Phase 2: Profile Views${NC}"
check_and_remove_duplicate \
    "perspective/Views/ProfileView.swift" \
    "perspective/Views/Profile/ProfileView.swift" \
    "User profile main view"

check_and_remove_duplicate \
    "perspective/Views/EditProfileView.swift" \
    "perspective/Views/Profile/EditProfileView.swift" \
    "Profile editing interface"

check_and_remove_duplicate \
    "perspective/Views/ProfileHeaderView.swift" \
    "perspective/Views/Profile/ProfileHeaderView.swift" \
    "Profile header component"

check_and_remove_duplicate \
    "perspective/Views/ProfileSettingsSectionView.swift" \
    "perspective/Views/Profile/ProfileSettingsSectionView.swift" \
    "Profile settings section"

check_and_remove_duplicate \
    "perspective/Views/ProfileStatisticsView.swift" \
    "perspective/Views/Profile/ProfileStatisticsView.swift" \
    "Profile statistics display"

check_and_remove_duplicate \
    "perspective/Views/ProfileQuickActionsView.swift" \
    "perspective/Views/Profile/ProfileQuickActionsView.swift" \
    "Profile quick actions component"

check_and_remove_duplicate \
    "perspective/Views/BiasProfileSectionView.swift" \
    "perspective/Views/Profile/BiasProfileSectionView.swift" \
    "Bias profile section"

check_and_remove_duplicate \
    "perspective/Views/ProfileEchoScoreSummaryView.swift" \
    "perspective/Views/Profile/ProfileEchoScoreSummaryView.swift" \
    "Profile echo score summary"

echo -e "\n${BLUE}Phase 3: Challenge Views${NC}"
check_and_remove_duplicate \
    "perspective/Views/DailyChallengeHeaderView.swift" \
    "perspective/Views/Challenge/DailyChallengeHeaderView.swift" \
    "Daily challenge header"

check_and_remove_duplicate \
    "perspective/Views/ChallengeContentView.swift" \
    "perspective/Views/Challenge/ChallengeContentView.swift" \
    "Challenge content display"

check_and_remove_duplicate \
    "perspective/Views/ChallengeLoadingView.swift" \
    "perspective/Views/Challenge/ChallengeLoadingView.swift" \
    "Challenge loading state"

check_and_remove_duplicate \
    "perspective/Views/ChallengeCompletedView.swift" \
    "perspective/Views/Challenge/ChallengeCompletedView.swift" \
    "Challenge completion view"

check_and_remove_duplicate \
    "perspective/Views/CelebrationView.swift" \
    "perspective/Views/Challenge/CelebrationView.swift" \
    "Challenge celebration animation"

echo -e "\n${BLUE}Phase 4: EchoScore Views${NC}"
check_and_remove_duplicate \
    "perspective/Views/EchoScoreDashboardView.swift" \
    "perspective/Views/EchoScore/EchoScoreDashboardView.swift" \
    "Echo score dashboard"

check_and_remove_duplicate \
    "perspective/Views/EchoScoreChartView.swift" \
    "perspective/Views/EchoScore/EchoScoreChartView.swift" \
    "Echo score chart visualization"

check_and_remove_duplicate \
    "perspective/Views/EchoScoreInsightsView.swift" \
    "perspective/Views/EchoScore/EchoScoreInsightsView.swift" \
    "Echo score insights"

check_and_remove_duplicate \
    "perspective/Views/EchoScoreBreakdownView.swift" \
    "perspective/Views/EchoScore/EchoScoreBreakdownView.swift" \
    "Echo score breakdown"

check_and_remove_duplicate \
    "perspective/Views/CurrentEchoScoreView.swift" \
    "perspective/Views/EchoScore/CurrentEchoScoreView.swift" \
    "Current echo score display"

echo -e "\n${BLUE}Phase 5: Components${NC}"
check_and_remove_duplicate \
    "perspective/Views/SyncStatusIndicator.swift" \
    "perspective/Views/Components/SyncStatusIndicator.swift" \
    "Sync status indicator component"

echo -e "\n${BLUE}Phase 6: Design System${NC}"
check_and_remove_duplicate \
    "perspective/Views/Material3DesignSystem.swift" \
    "perspective/Views/DesignSystem/Material3DesignSystem.swift" \
    "Material 3 design system"

echo -e "\n${BLUE}Phase 7: Bias Assessment${NC}"
check_and_remove_duplicate \
    "perspective/Views/BiasAssessmentView.swift" \
    "perspective/Views/BiasAssessment/BiasAssessmentView.swift" \
    "Bias assessment interface"

echo -e "\n${BLUE}Phase 8: Debug Views${NC}"
check_and_remove_duplicate \
    "perspective/Views/APITestView.swift" \
    "perspective/Views/Debug/APITestView.swift" \
    "API testing interface"

check_and_remove_duplicate \
    "perspective/Views/LoginTestView.swift" \
    "perspective/Views/Debug/LoginTestView.swift" \
    "Login testing interface"

check_and_remove_duplicate \
    "perspective/Views/QuickLoginView.swift" \
    "perspective/Views/Debug/QuickLoginView.swift" \
    "Quick login for development"

# Phase 9: Check for duplicate service files
echo -e "\n${BLUE}Phase 9: Service Layer Duplicates${NC}"
check_and_remove_duplicate \
    "perspective/Core/NetworkMonitor.swift" \
    "perspective/Services/NetworkMonitor.swift" \
    "Network monitoring service"

check_and_remove_duplicate \
    "perspective/Core/OfflineDataManager.swift" \
    "perspective/Services/OfflineDataManager.swift" \
    "Offline data management service"

# Summary
echo -e "\n======================================="
echo -e "${GREEN}Migration Summary:${NC}"
echo -e "Files removed/moved: $REMOVED"
echo -e "Conflicts requiring manual review: $CONFLICTS"
echo -e "Errors encountered: $ERRORS"

if [ "$CONFLICTS" -gt 0 ]; then
    echo -e "\n${YELLOW}⚠️  IMPORTANT: $CONFLICTS files have conflicts and need manual review${NC}"
    echo -e "${YELLOW}These files exist in both locations but have different content.${NC}"
    echo -e "${YELLOW}Please review and merge changes manually.${NC}"
fi

if [ "$ERRORS" -eq 0 ] && [ "$CONFLICTS" -eq 0 ]; then
    echo -e "\n${GREEN}✅ Migration completed successfully!${NC}"
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "\n${YELLOW}⚠️  Migration completed with warnings.${NC}"
    exit 1
else
    echo -e "\n${RED}❌ Migration encountered errors.${NC}"
    exit 2
fi 