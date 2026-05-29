#!/bin/bash

# Simple file write tracker for current zsh session
# Monitors file modifications in real-time

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Real-time ZSH File Write Monitor (inotifywait)       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if inotifywait is available
if ! command -v inotifywait &> /dev/null; then
    echo "❌ inotifywait not found!"
    echo "Install with: sudo apt install inotify-tools"
    echo ""
    echo "Alternative: Check current file stats"
    echo "======================================"
    echo ""
    echo "Current .zsh_history:"
    ls -lh ~/.zsh_history 2>/dev/null
    echo ""
    echo "Recently modified zsh files (last 10 minutes):"
    find ~ -maxdepth 3 -name "*zsh*" -type f -mmin -10 2>/dev/null | head -10
    exit 1
fi

DURATION=${1:-30}
echo "Monitoring zsh-related file writes for ${DURATION} seconds..."
echo "Watching: ~/.zsh_history, ~/.cache/, ~/.local/share/"
echo ""
echo "Now use your shell in another terminal:"
echo "  - Run some commands"
echo "  - Use tab completion"
echo "  - Navigate directories"
echo ""
echo "Press Ctrl+C to stop early"
echo "================================================================"
echo ""

# Create a temp file to store results
RESULTS="/tmp/zsh_write_monitor_$$.txt"

# Monitor the directories
timeout ${DURATION} inotifywait -m -r \
    -e modify,close_write,create \
    --format '%T %w%f %e' \
    --timefmt '%H:%M:%S' \
    ~/.zsh_history \
    ~/.cache/ \
    ~/.local/share/ \
    2>/dev/null | tee "$RESULTS" | while read -r line; do
    
    # Only show zsh-related files
    if echo "$line" | grep -qE "zsh|history|autosugg|p10k|oh-my"; then
        echo "✍️  $line"
    fi
done

echo ""
echo "================================================================"
echo "ANALYSIS"
echo "================================================================"
echo ""

if [ -f "$RESULTS" ]; then
    echo "📊 Write Statistics:"
    echo "-------------------"
    
    HISTORY_COUNT=$(grep "zsh_history" "$RESULTS" 2>/dev/null | wc -l)
    CACHE_COUNT=$(grep "/cache/" "$RESULTS" 2>/dev/null | wc -l)
    AUTOSUGG_COUNT=$(grep "autosugg" "$RESULTS" 2>/dev/null | wc -l)
    P10K_COUNT=$(grep "p10k" "$RESULTS" 2>/dev/null | wc -l)
    
    echo "  .zsh_history writes:        $HISTORY_COUNT"
    echo "  Cache file writes:          $CACHE_COUNT"
    echo "  Autosuggestions writes:     $AUTOSUGG_COUNT"
    echo "  Powerlevel10k writes:       $P10K_COUNT"
    
    echo ""
    echo "📁 Most Written Files:"
    echo "---------------------"
    grep -oE '/[^ ]+' "$RESULTS" | sort | uniq -c | sort -rn | head -10
    
    echo ""
    echo "💡 RECOMMENDATIONS:"
    echo "==================="
    
    if [ "$HISTORY_COUNT" -gt 20 ]; then
        echo "⚠️  HIGH: .zsh_history is written frequently ($HISTORY_COUNT times)"
        echo "   Solution: Reduce HISTSIZE in ~/.zshrc"
        echo "   Current: export HISTSIZE=100000000"
        echo "   Suggest: export HISTSIZE=50000"
        echo ""
    fi
    
    if [ "$AUTOSUGG_COUNT" -gt 10 ]; then
        echo "⚠️  MODERATE: zsh-autosuggestions cache writes detected"
        echo "   Solution: Use history-only strategy"
        echo "   Add to ~/.zshrc: export ZSH_AUTOSUGGEST_STRATEGY=(history)"
        echo ""
    fi
    
    if [ "$CACHE_COUNT" -gt 30 ]; then
        echo "⚠️  MODERATE: Many cache writes detected"
        echo "   Consider disabling some plugins temporarily to identify culprit"
        echo ""
    fi
    
    echo "Full log saved to: $RESULTS"
else
    echo "No writes detected during monitoring period."
fi

echo ""

# Made with Bob
