#!/bin/bash

# Perspective Build Validation Script
# Comprehensive check for architectural violations and build issues
# Ensures SOLID principles compliance and prevents regression

echo "🔍 Starting Perspective Build Validation..."
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

# Function to log errors
log_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ((ERRORS++))
}

# Function to log warnings
log_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    ((WARNINGS++))
}

# Function to log success
log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to log info
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo
log_info "Phase 1: Checking for Duplicate Declarations..."

# Check for duplicate notification names
echo "Checking for duplicate notification name declarations..."
NOTIFICATION_DUPS=$(find perspective -name "*.swift" -exec grep -l "userNeedsToReauthenticate.*=" {} \; | wc -l | tr -d ' ')
if [ "$NOTIFICATION_DUPS" -gt 1 ]; then
    log_error "Multiple declarations of userNeedsToReauthenticate found"
    find perspective -name "*.swift" -exec grep -H -n "userNeedsToReauthenticate.*=" {} \;
else
    log_success "No duplicate notification declarations found"
fi

# Check for duplicate apiEncoder declarations
echo "Checking for duplicate apiEncoder declarations..."
API_ENCODER_DUPS=$(find perspective -name "*.swift" -exec grep -l "apiEncoder.*=" {} \; | wc -l | tr -d ' ')
if [ "$API_ENCODER_DUPS" -gt 1 ]; then
    log_error "Multiple declarations of apiEncoder found"
    find perspective -name "*.swift" -exec grep -H -n "apiEncoder.*=" {} \;
else
    log_success "No duplicate apiEncoder declarations found"
fi

# Check for duplicate SuccessResponse declarations
echo "Checking for duplicate SuccessResponse declarations..."
SUCCESS_RESPONSE_DUPS=$(find perspective -name "*.swift" -exec grep -l "struct SuccessResponse" {} \; | wc -l | tr -d ' ')
if [ "$SUCCESS_RESPONSE_DUPS" -gt 1 ]; then
    log_error "Multiple SuccessResponse struct declarations found"
    find perspective -name "*.swift" -exec grep -H -n "struct SuccessResponse" {} \;
else
    log_success "No duplicate SuccessResponse declarations found"
fi

# Check for duplicate ViewModel classes
echo "Checking for duplicate ViewModel class declarations..."
VIEWMODEL_DUPS=$(find perspective -name "*.swift" -exec grep -l "class.*ViewModel.*ObservableObject" {} \; | sort | uniq -d | wc -l | tr -d ' ')
if [ "$VIEWMODEL_DUPS" -gt 0 ]; then
    log_warning "Potential duplicate ViewModel classes found"
    find perspective -name "*.swift" -exec grep -H -n "class.*ViewModel.*ObservableObject" {} \;
else
    log_success "No duplicate ViewModel classes found"
fi

# Check for protocol/struct naming conflicts
echo "Checking for protocol/struct naming conflicts..."
PROTOCOL_STRUCT_CONFLICTS=0

# Extract all protocol names
PROTOCOLS=$(find perspective -name "*.swift" -exec grep -h "^protocol " {} \; | sed 's/protocol \([A-Za-z0-9_]*\).*/\1/' | sort)

# Extract all struct names  
STRUCTS=$(find perspective -name "*.swift" -exec grep -h "^struct " {} \; | sed 's/struct \([A-Za-z0-9_]*\).*/\1/' | sort)

# Find common names
COMMON_NAMES=$(comm -12 <(echo "$PROTOCOLS") <(echo "$STRUCTS"))

if [ ! -z "$COMMON_NAMES" ]; then
    log_error "Protocol/struct naming conflicts found:"
    echo "$COMMON_NAMES"
    ((PROTOCOL_STRUCT_CONFLICTS++))
else
    log_success "No protocol/struct naming conflicts found"
fi

# Check for nested type scope issues
echo "Checking for potential nested type scope issues..."
SCOPE_ISSUES=0

# Check for known problematic patterns that were previously fixed
PAGEMETADATA_ISSUES=$(find perspective -name "*.swift" -exec grep -l "PageMetadata(" {} \; | xargs grep -L "Self(" | wc -l | tr -d ' ')
if [ "$PAGEMETADATA_ISSUES" -gt 1 ]; then  # Allow one for the factory
    log_warning "Found potential PageMetadata scope issues"
    ((SCOPE_ISSUES++))
fi

# Check for extension scope issues by looking for specific patterns
EXTENSION_SCOPE_ISSUES=$(find perspective -name "*.swift" -exec grep -l "extension.*\." {} \; | xargs grep "-> [A-Z][a-zA-Z]*(" | grep -v "-> Self(" | grep -v "String\|Int\|Bool\|Double\|Float\|Data\|Date\|URL" | wc -l | tr -d ' ')
if [ "$EXTENSION_SCOPE_ISSUES" -gt 0 ]; then
    log_warning "Found potential extension scope issues"
    ((SCOPE_ISSUES++))
fi

if [ "$SCOPE_ISSUES" -eq 0 ]; then
    log_success "No nested type scope issues detected"
fi

# Check for proper factory pattern usage in pagination
echo "Checking pagination factory pattern usage..."
PAGINATION_FACTORY_VIOLATIONS=0

# Look for direct PageMetadata() calls instead of factory usage
DIRECT_PAGE_METADATA=$(find perspective -name "*.swift" -exec grep -l "PageMetadata(" {} \; | xargs grep -L "PaginationFactory\|\.create" | wc -l | tr -d ' ')
if [ "$DIRECT_PAGE_METADATA" -gt 0 ]; then
    log_warning "Found direct PageMetadata instantiation that should use PaginationFactory"
    find perspective -name "*.swift" -exec grep -l "PageMetadata(" {} \; | xargs grep -L "PaginationFactory\|\.create"
    ((PAGINATION_FACTORY_VIOLATIONS++))
fi

# Look for pagination creation without validation
UNVALIDATED_PAGINATION=$(find perspective -name "*.swift" -exec grep -l "page.*limit.*total" {} \; | xargs grep -L "validate.*[Pp]agination" | wc -l | tr -d ' ')
if [ "$UNVALIDATED_PAGINATION" -gt 2 ]; then  # Allow some tolerance for the factory itself
    log_warning "Found pagination creation without validation"
else
    log_success "Pagination validation patterns properly used"
fi

echo
log_info "Phase 2: Checking Model Completeness..."

# Check for incomplete ChallengeResult initializations
echo "Checking ChallengeResult initializations..."
INCOMPLETE_RESULTS=$(find perspective -name "*.swift" -exec grep -l "ChallengeResult(" {} \; | xargs grep -l "ChallengeResult(" | xargs grep -L "detailedFeedback\|ChallengeResultFactory" | wc -l | tr -d ' ')
if [ "$INCOMPLETE_RESULTS" -gt 0 ]; then
    log_warning "Found ChallengeResult initializations not using factory pattern"
    find perspective -name "*.swift" -exec grep -l "ChallengeResult(" {} \; | xargs grep -L "detailedFeedback\|ChallengeResultFactory"
else
    log_success "All ChallengeResult initializations follow factory pattern"
fi

# Check for incomplete StreakInfo initializations
echo "Checking StreakInfo initializations..."
INCOMPLETE_STREAKS=$(find perspective -name "*.swift" -exec grep -A 5 "StreakInfo(" {} \; | grep -c "StreakInfo(" | tr -d ' ')
COMPLETE_STREAKS=$(find perspective -name "*.swift" -exec grep -A 10 "StreakInfo(" {} \; | grep -c "lastActivityDate" | tr -d ' ')
if [ "$INCOMPLETE_STREAKS" -gt "$COMPLETE_STREAKS" ]; then
    log_warning "Some StreakInfo initializations may be missing lastActivityDate parameter"
else
    log_success "All StreakInfo initializations appear complete"
fi

echo
log_info "Phase 3: Checking SOLID Principles Compliance..."

# Check for proper dependency injection
echo "Checking dependency injection patterns..."
DI_VIOLATIONS=$(find perspective -name "*.swift" -exec grep -l "= APIService()" {} \; | wc -l | tr -d ' ')
if [ "$DI_VIOLATIONS" -gt 0 ]; then
    log_warning "Found direct APIService instantiations (should use protocol injection)"
    find perspective -name "*.swift" -exec grep -H -n "= APIService()" {} \;
else
    log_success "Proper dependency injection patterns followed"
fi

# Check for proper protocol usage
echo "Checking protocol usage..."
PROTOCOL_USAGE=$(find perspective -name "*.swift" -exec grep -c "APIServiceProtocol" {} \; | awk '{sum += $1} END {print sum}')
if [ "$PROTOCOL_USAGE" -lt 5 ]; then
    log_warning "Low protocol usage detected - ensure interfaces are properly abstracted"
else
    log_success "Good protocol usage detected"
fi

echo
log_info "Phase 4: Checking Import Dependencies..."

# Check for proper imports
echo "Checking Foundation imports..."
MISSING_FOUNDATION=$(find perspective -name "*.swift" -exec grep -L "import Foundation" {} \; | xargs grep -l "Date\|Calendar" | wc -l | tr -d ' ')
if [ "$MISSING_FOUNDATION" -gt 0 ]; then
    log_error "Files using Foundation types without importing Foundation"
    find perspective -name "*.swift" -exec grep -L "import Foundation" {} \; | xargs grep -l "Date\|Calendar"
else
    log_success "All Foundation dependencies properly imported"
fi

echo
log_info "Phase 5: Checking File Structure..."

# Check for proper file organization
echo "Checking factory pattern implementation..."
if [ ! -f "perspective/Utils/ChallengeResultFactory.swift" ]; then
    log_error "ChallengeResultFactory.swift not found - factory pattern not implemented"
else
    log_success "ChallengeResultFactory.swift found"
fi

echo "Checking response models factory implementation..."
if [ ! -f "perspective/Utils/ResponseModelsFactory.swift" ]; then
    log_error "ResponseModelsFactory.swift not found - response factory pattern not implemented"
else
    log_success "ResponseModelsFactory.swift found"
fi

# Check for proper factory usage
echo "Checking factory pattern usage..."
DIRECT_RESPONSE_CREATION=$(find perspective -name "*.swift" -exec grep -l "= .*Response(" {} \; | xargs grep -L "Factory\|ResponseModelsFactory" | wc -l | tr -d ' ')
if [ "$DIRECT_RESPONSE_CREATION" -gt 0 ]; then
    log_warning "Found direct response model creation that should use factory pattern"
    find perspective -name "*.swift" -exec grep -l "= .*Response(" {} \; | xargs grep -L "Factory\|ResponseModelsFactory"
else
    log_success "All response creation follows factory pattern"
fi

# Check for centralized core definitions
echo "Checking core definitions..."
if [ ! -f "perspective/Core/PerspectiveCore.swift" ]; then
    log_error "PerspectiveCore.swift not found"
else
    log_success "PerspectiveCore.swift found"
fi

echo
log_info "Phase 6: Running Swift Compiler Check..."

# Try to compile to check for syntax errors
if command -v swiftc &> /dev/null; then
    echo "Running Swift syntax validation..."
    SWIFT_ERRORS=0
    for file in $(find perspective -name "*.swift"); do
        if ! swiftc -parse "$file" &>/dev/null; then
            log_error "Syntax error in $file"
            ((SWIFT_ERRORS++))
        fi
    done
    
    if [ "$SWIFT_ERRORS" -eq 0 ]; then
        log_success "No Swift syntax errors found"
    fi
else
    log_warning "Swift compiler not available for syntax checking"
fi

echo
echo "======================================="

# Phase 7: Check for duplicate files across directories
echo ""
echo "ℹ️  Phase 7: Checking File Organization..."
echo "Checking for duplicate file names across directories..."
DUPLICATE_FILES=$(find perspective -name "*.swift" -type f | xargs basename | sort | uniq -d | wc -l | tr -d ' ')
if [ "$DUPLICATE_FILES" -gt 0 ]; then
    log_error "Found $DUPLICATE_FILES duplicate file names across directories"
    find perspective -name "*.swift" -type f | xargs basename | sort | uniq -d | head -10
else
    log_success "No duplicate file names found across directories"
fi

# Check for files in wrong locations
echo "Checking for files in root directories that should be organized..."
MISPLACED_VIEWS=$(find perspective/Views -maxdepth 1 -name "*.swift" -type f | grep -v -E "(MainTabView|ContentView)\.swift" | wc -l | tr -d ' ')
if [ "$MISPLACED_VIEWS" -gt 0 ]; then
    log_warning "Found $MISPLACED_VIEWS Swift files directly in Views/ that should be in subdirectories"
    find perspective/Views -maxdepth 1 -name "*.swift" -type f | grep -v "MainTabView.swift" | head -5
else
    log_success "All view files are properly organized in subdirectories"
fi

# Check for singleton pattern consistency
echo "Checking singleton pattern implementation..."
SINGLETON_ISSUES=0
SINGLETONS=$(find perspective -name "*.swift" -exec grep -l "static let shared" {} \;)
for file in $SINGLETONS; do
    # Check if singleton is final class
    if ! grep -q "final class" "$file" && grep -q "class.*{" "$file"; then
        basename_file=$(basename "$file")
        # Skip mock classes
        if [[ ! "$basename_file" =~ Mock ]]; then
            log_warning "Singleton in $file should be a final class"
            ((SINGLETON_ISSUES++))
        fi
    fi
done
if [ "$SINGLETON_ISSUES" -eq 0 ]; then
    log_success "All singletons follow best practices"
fi

# Summary
TOTAL_ERRORS=$((ERRORS + PROTOCOL_STRUCT_CONFLICTS + DUPLICATE_FILES))

if [ "$TOTAL_ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    log_success "🎉 Build validation passed! No issues found."
    echo -e "${GREEN}Your codebase follows SOLID principles and architectural best practices.${NC}"
    exit 0
elif [ "$TOTAL_ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Build validation completed with $WARNINGS warning(s).${NC}"
    echo -e "${YELLOW}Consider addressing warnings to maintain code quality.${NC}"
    exit 0
else
    echo -e "${RED}❌ Build validation failed with $TOTAL_ERRORS error(s) and $WARNINGS warning(s).${NC}"
    echo -e "${RED}Please fix all errors before proceeding with the build.${NC}"
    exit 1
fi 