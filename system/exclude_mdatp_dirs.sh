#!/bin/bash

# Script to exclude directories from Microsoft Defender ATP scanning
# This reduces CPU usage by preventing scanning of development directories

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Microsoft Defender ATP - Add Exclusions               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Directories to exclude (add more as needed)
EXCLUDE_DIRS=(
    "/home/mkchauras/src"
    "/home/mkchauras/.cache"
    "/home/mkchauras/.local/share"
    "/home/mkchauras/qemu"
    "/home/mkchauras/.cargo"
    "/home/mkchauras/.rustup"
    "/home/mkchauras/go"
    "/home/mkchauras/.npm"
    "/home/mkchauras/.gradle"
    "/home/mkchauras/.m2"
)

# Optional: Exclude common build/cache directories
OPTIONAL_DIRS=(
    "/home/mkchauras/.cargo"
    "/home/mkchauras/.rustup"
    "/home/mkchauras/go"
    "/home/mkchauras/.npm"
    "/home/mkchauras/.gradle"
    "/home/mkchauras/.m2"
)

echo "This script will add the following exclusions to Microsoft Defender ATP:"
echo ""
echo "Required exclusions:"
for dir in "${EXCLUDE_DIRS[@]}"; do
    echo "  ✓ $dir"
done

echo ""
echo "Optional exclusions (uncomment in script if needed):"
for dir in "${OPTIONAL_DIRS[@]}"; do
    echo "  ○ $dir"
done

echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Adding exclusions (requires sudo)..."
echo "======================================"

# Add folder exclusions
for dir in "${EXCLUDE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "Adding: $dir"
        sudo mdatp exclusion folder add --path "$dir"
        if [ $? -eq 0 ]; then
            echo "  ✓ Success"
        else
            echo "  ✗ Failed"
        fi
    else
        echo "Skipping (not found): $dir"
    fi
    echo ""
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Current Exclusions                                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
sudo mdatp exclusion list | grep -A 2 "mkchauras"

echo ""
echo "Done! Microsoft Defender should now skip these directories."
echo ""
echo "To verify CPU usage improvement:"
echo "  top -p \$(pgrep wdavdaemon | tr '\n' ',')"
echo ""
echo "To remove an exclusion:"
echo "  sudo mdatp exclusion folder remove --path /path/to/dir"

# Made with Bob
