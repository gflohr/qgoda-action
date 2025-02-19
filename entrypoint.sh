#!/bin/sh

set -e

echo "Building the site with Qgoda..."
qgoda build

echo "Preparing to publish to the github-pages branch..."

# Configure Git
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

# Clone the existing `github-pages` branch (if it exists)
git fetch origin github-pages || true
git checkout -B github-pages origin/github-pages || git checkout -B github-pages

# Remove old content and copy the new site
rm -rf ./*
cp -r _site/* .

# Commit and push changes
git add .
git commit -m "Automated deployment from GitHub Actions" || echo "No changes to commit"
git push origin github-pages --force

echo "Deployment successful!"

