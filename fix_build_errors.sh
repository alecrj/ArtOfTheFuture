#!/bin/bash

# ArtOfTheFuture Build Error Fix Script
# Run this from your project root directory

echo "🎨 ArtOfTheFuture Build Error Fix Script"
echo "========================================"

# Check if we're in the right directory
if [ ! -d "ArtOfTheFuture" ]; then
    echo "❌ Error: Please run this script from your project root directory"
    exit 1
fi

echo "✅ Found ArtOfTheFuture directory"

# Function to fix Container.shared references
fix_container_shared() {
    echo "🔧 Fixing Container.shared references..."
    
    # Files to fix
    files=(
        "ArtOfTheFuture/Features/Drawing/DrawingComponents.swift"
        "ArtOfTheFuture/Features/Drawing/DrawingView.swift"
        "ArtOfTheFuture/Features/Home/HomeDashboardView.swift"
        "ArtOfTheFuture/Features/Onboarding/OnboardingView.swift"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            echo "  - Fixing $file"
            sed -i '' 's/Container\.shared/ArtOfTheFuture.Container.shared/g' "$file"
        fi
    done
}

# Function to fix Color issues
fix_color_issues() {
    echo "🎨 Fixing Color issues..."
    
    if [ -f "ArtOfTheFuture/Features/Gallery/GalleryView.swift" ]; then
        echo "  - Fixing GalleryView.swift"
        sed -i '' 's/Color?\.tertiaryLabel/Color(.tertiaryLabel)/g' "ArtOfTheFuture/Features/Gallery/GalleryView.swift"
    fi
}

# Function to remove duplicate HapticManager from GalleryViewModel
remove_duplicate_haptic() {
    echo "🔨 Removing duplicate HapticManager..."
    
    if [ -f "ArtOfTheFuture/Features/Gallery/GalleryViewModel.swift" ]; then
        echo "  - Cleaning GalleryViewModel.swift"
        # This is a complex operation, so we'll just notify the user
        echo "  ⚠️  Please manually remove HapticManager class from GalleryViewModel.swift (around line 290)"
    fi
}

# Function to remove duplicate RecommendationEngine
remove_duplicate_recommendation() {
    echo "🤖 Removing duplicate RecommendationEngine..."
    
    if [ -f "ArtOfTheFuture/Features/Onboarding/OnboardingViewModel.swift" ]; then
        echo "  - Cleaning OnboardingViewModel.swift"
        # This is a complex operation, so we'll just notify the user
        echo "  ⚠️  Please manually remove RecommendationEngine struct from OnboardingViewModel.swift (around line 182)"
    fi
}

# Function to clean Xcode
clean_xcode() {
    echo "🧹 Cleaning Xcode build..."
    
    # Clean build folder
    xcodebuild clean -quiet
    
    # Remove derived data
    rm -rf ~/Library/Developer/Xcode/DerivedData/ArtOfTheFuture-*
    
    echo "  ✅ Xcode cleaned"
}

# Main execution
echo ""
echo "Starting fixes..."
echo ""

fix_container_shared
fix_color_issues
remove_duplicate_haptic
remove_duplicate_recommendation

echo ""
echo "🎯 Automated fixes completed!"
echo ""
echo "⚠️  Manual fixes still required:"
echo "1. Change 'let modifiedAt' to 'var modifiedAt' in Artwork.swift"
echo "2. Add 'import AVFoundation' to GalleryService.swift"
echo "3. Remove HapticManager class from GalleryViewModel.swift"
echo "4. Remove RecommendationEngine struct from OnboardingViewModel.swift"
echo "5. Rename StatCard to ProfileStatCard in ProfileView.swift"
echo "6. Fix StatCard initialization in GallerySupportingViews.swift"
echo ""

read -p "Would you like to clean Xcode build? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    clean_xcode
fi

echo ""
echo "✅ Script completed!"
echo "📱 Now open Xcode and try building again"
echo ""
echo "If you still have errors:"
echo "1. Restart Xcode"
echo "2. Clean build folder (Cmd+Shift+K)"
echo "3. Delete derived data (Cmd+Shift+Option+K)"
echo "4. Build again (Cmd+B)"
