#!/bin/bash

# Script to push frontend code to GitHub and deploy to Vercel
# Make sure you've created the GitHub repository first!

echo "🚀 Pushing frontend to GitHub..."

cd "/Users/maishaahmed/Desktop/finalone 2/finalone/worker-calling-frontend"

# Check if remote already exists
if git remote | grep -q "^origin$"; then
    echo "Remote 'origin' already exists. Current URL:"
    git remote get-url origin
    read -p "Do you want to update it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your GitHub repository URL (e.g., https://github.com/maisha0055/worker-calling-frontend.git): " repo_url
        git remote set-url origin "$repo_url"
    fi
else
    read -p "Enter your GitHub repository URL (e.g., https://github.com/maisha0055/worker-calling-frontend.git): " repo_url
    git remote add origin "$repo_url"
fi

echo "📤 Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "Next steps:"
    echo "1. Go to https://vercel.com and sign in"
    echo "2. Click 'Add New Project'"
    echo "3. Import your GitHub repository"
    echo "4. Add environment variable: REACT_APP_API_URL = your-backend-url"
    echo "5. Click Deploy!"
else
    echo "❌ Failed to push. Make sure:"
    echo "   - The GitHub repository exists"
    echo "   - You have push access"
    echo "   - The repository URL is correct"
fi

