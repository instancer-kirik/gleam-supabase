#!/bin/bash

# GitHub Setup Script for Gleam Supabase Package
# This script helps you set up your GitHub repository and prepare for Hex.pm publishing

set -e

echo "🚀 Gleam Supabase - GitHub Setup Script"
echo "======================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    read -p "$prompt [$default]: " input
    eval "$var_name=\${input:-\$default}"
}

# Check if git is initialized
if [ ! -d .git ]; then
    echo -e "${YELLOW}Initializing git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit: Gleam Supabase client library"
    echo -e "${GREEN}✓ Git repository initialized${NC}"
else
    echo -e "${GREEN}✓ Git repository already initialized${NC}"
fi

# Get GitHub username
prompt_with_default "Enter your GitHub username" "yourusername" GITHUB_USERNAME

# Get repository name
prompt_with_default "Enter repository name" "gleam-supabase" REPO_NAME

# Update gleam.toml files with actual GitHub info
echo -e "\n${BLUE}Updating gleam.toml files...${NC}"
sed -i.bak "s/user = \"yourusername\"/user = \"$GITHUB_USERNAME\"/" gleam.toml
sed -i.bak "s/repo = \"gleam-supabase\"/repo = \"$REPO_NAME\"/" gleam.toml
sed -i.bak "s/user = \"yourusername\"/user = \"$GITHUB_USERNAME\"/" erlang/gleam.toml
sed -i.bak "s/repo = \"gleam-supabase\"/repo = \"$REPO_NAME\"/" erlang/gleam.toml
rm -f gleam.toml.bak erlang/gleam.toml.bak
echo -e "${GREEN}✓ Updated gleam.toml files${NC}"

# Update CHANGELOG.md with actual GitHub URLs
echo -e "\n${BLUE}Updating CHANGELOG.md...${NC}"
sed -i.bak "s|yourusername/gleam-supabase|$GITHUB_USERNAME/$REPO_NAME|g" CHANGELOG.md
rm -f CHANGELOG.md.bak
echo -e "${GREEN}✓ Updated CHANGELOG.md${NC}"

# Update CONTRIBUTING.md
echo -e "\n${BLUE}Updating CONTRIBUTING.md...${NC}"
sed -i.bak "s|yourusername/gleam-supabase|$GITHUB_USERNAME/$REPO_NAME|g" CONTRIBUTING.md
rm -f CONTRIBUTING.md.bak
echo -e "${GREEN}✓ Updated CONTRIBUTING.md${NC}"

# Create/check GitHub repository
echo -e "\n${YELLOW}GitHub Repository Setup${NC}"
echo "========================"
echo ""
echo "Please create a new repository on GitHub:"
echo -e "${BLUE}https://github.com/new${NC}"
echo ""
echo "Repository name: ${GREEN}$REPO_NAME${NC}"
echo "Description: ${GREEN}A type-safe Supabase client for Gleam${NC}"
echo "Public/Private: Your choice"
echo "Initialize: ${RED}DO NOT${NC} add README, .gitignore, or license"
echo ""
read -p "Press Enter when you've created the repository..."

# Add GitHub remote
echo -e "\n${BLUE}Adding GitHub remote...${NC}"
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git" 2>/dev/null || {
    echo -e "${YELLOW}Remote 'origin' already exists. Updating URL...${NC}"
    git remote set-url origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
}
echo -e "${GREEN}✓ GitHub remote configured${NC}"

# Push to GitHub
echo -e "\n${BLUE}Pushing to GitHub...${NC}"
git branch -M main
git push -u origin main
echo -e "${GREEN}✓ Code pushed to GitHub${NC}"

# Hex.pm setup instructions
echo -e "\n${YELLOW}Hex.pm Setup Instructions${NC}"
echo "=========================="
echo ""
echo "1. Create a Hex.pm account (if you don't have one):"
echo -e "   ${BLUE}https://hex.pm/signup${NC}"
echo ""
echo "2. Generate an API key:"
echo -e "   ${BLUE}https://hex.pm/settings/api_keys${NC}"
echo "   - Name: GitHub Actions (or similar)"
echo "   - Permissions: Write"
echo ""
echo "3. Add the API key as a GitHub repository secret:"
echo -e "   ${BLUE}https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions/new${NC}"
echo "   - Name: ${GREEN}HEX_API_KEY${NC}"
echo "   - Value: Your Hex.pm API key"
echo ""
read -p "Press Enter when you've added the HEX_API_KEY secret..."

# Publishing checklist
echo -e "\n${YELLOW}Publishing Checklist${NC}"
echo "===================="
echo ""
echo "Before publishing to Hex.pm, ensure:"
echo -e "${GREEN}✓${NC} All tests pass (gleam test)"
echo -e "${GREEN}✓${NC} Documentation is complete"
echo -e "${GREEN}✓${NC} CHANGELOG.md is updated"
echo -e "${GREEN}✓${NC} Version in gleam.toml is correct"
echo -e "${GREEN}✓${NC} HEX_API_KEY is set in GitHub secrets"
echo ""
echo "To publish your package:"
echo "1. Update version in both gleam.toml files"
echo "2. Update CHANGELOG.md"
echo "3. Commit and push changes"
echo "4. Create a GitHub release:"
echo -e "   ${BLUE}https://github.com/$GITHUB_USERNAME/$REPO_NAME/releases/new${NC}"
echo "   - Tag: v0.1.0 (or your version)"
echo "   - Title: Release v0.1.0"
echo "   - Description: Link to CHANGELOG.md"
echo ""
echo "The GitHub Actions workflow will automatically publish to Hex.pm!"
echo ""
echo -e "${GREEN}✨ Setup complete! Your package is ready for GitHub and Hex.pm.${NC}"
echo ""
echo "Repository URL: ${BLUE}https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
echo "Future Hex.pm URL: ${BLUE}https://hex.pm/packages/supabase${NC}"
echo "Documentation URL: ${BLUE}https://hexdocs.pm/supabase${NC}"