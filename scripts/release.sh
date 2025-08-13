#!/usr/bin/env bash
# Release helper script for pypostal-flake
# Usage: ./scripts/release.sh [major|minor|patch]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git is clean
if [[ -n $(git status -s) ]]; then
    echo -e "${RED}Error: Working directory is not clean. Please commit or stash changes.${NC}"
    exit 1
fi

# Get the release type
RELEASE_TYPE=${1:-patch}
if [[ ! "$RELEASE_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error: Invalid release type. Use major, minor, or patch.${NC}"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CURRENT_VERSION=${CURRENT_VERSION#v}

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Calculate new version
case $RELEASE_TYPE in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        ;;
    minor)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        ;;
    patch)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="v${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"

echo -e "${GREEN}Preparing release ${NEW_VERSION} (current: v${CURRENT_VERSION})${NC}"

# Check if CHANGELOG.md exists
if [[ ! -f CHANGELOG.md ]]; then
    echo -e "${YELLOW}Warning: CHANGELOG.md not found. Creating one...${NC}"
    cat > CHANGELOG.md << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}] - $(date +%Y-%m-%d)

### Added
- 

### Changed
- 

### Fixed
- 

[${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}]: https://github.com/jamesbrink/pypostal-flake/compare/v${CURRENT_VERSION}...${NEW_VERSION}
EOF
    echo -e "${YELLOW}Please edit CHANGELOG.md to add release notes for ${NEW_VERSION}${NC}"
    exit 0
fi

# Check if version already exists in CHANGELOG
if grep -q "## \[${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}\]" CHANGELOG.md; then
    echo -e "${GREEN}Version ${NEW_VERSION} already documented in CHANGELOG.md${NC}"
else
    echo -e "${YELLOW}Version ${NEW_VERSION} not found in CHANGELOG.md${NC}"
    echo -e "${YELLOW}Please add a section for ${NEW_VERSION} with the following format:${NC}"
    echo ""
    echo "## [${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}] - $(date +%Y-%m-%d)"
    echo ""
    echo "### Added"
    echo "- New features"
    echo ""
    echo "### Changed"
    echo "- Changes in existing functionality"
    echo ""
    echo "### Fixed"
    echo "- Bug fixes"
    echo ""
    echo "[${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}]: https://github.com/jamesbrink/pypostal-flake/compare/v${CURRENT_VERSION}...${NEW_VERSION}"
    echo ""
    echo -e "${RED}Please update CHANGELOG.md before releasing.${NC}"
    exit 1
fi

# Confirm release
echo -e "${YELLOW}Ready to create release ${NEW_VERSION}${NC}"
echo "This will:"
echo "  1. Commit any CHANGELOG.md changes"
echo "  2. Create and push tag ${NEW_VERSION}"
echo "  3. Trigger the release workflow"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Release cancelled."
    exit 0
fi

# Commit CHANGELOG if needed
if [[ -n $(git status -s CHANGELOG.md) ]]; then
    git add CHANGELOG.md
    git commit -m "Update CHANGELOG.md for ${NEW_VERSION}"
    git push origin main
fi

# Create and push tag
echo -e "${GREEN}Creating tag ${NEW_VERSION}...${NC}"
git tag -a "${NEW_VERSION}" -m "Release ${NEW_VERSION}

See CHANGELOG.md for details."

echo -e "${GREEN}Pushing tag to trigger release...${NC}"
git push origin "${NEW_VERSION}"

echo -e "${GREEN}✅ Release ${NEW_VERSION} initiated!${NC}"
echo ""
echo "Monitor the release at:"
echo "https://github.com/jamesbrink/pypostal-flake/actions"
echo ""
echo "Once complete, view at:"
echo "https://github.com/jamesbrink/pypostal-flake/releases/tag/${NEW_VERSION}"