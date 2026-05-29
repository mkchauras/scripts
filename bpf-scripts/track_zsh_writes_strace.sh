#!/bin/bash

# Track zsh file writes using strace (no sudo required for own processes)
# Usage: ./track_zsh_writes_strace.sh [duration_in_seconds]

DURATION=${1:-30}
OUTPUT_FILE="/tmp/zsh_write_analysis_$$.txt"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          ZSH File Write Tracker (using strace)            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Starting new zsh shell with write tracking for ${DURATION} seconds..."
echo "Please use the shell normally (run commands, use tab completion, etc.)"
echo ""
echo "Press Ctrl+C or wait ${DURATION} seconds to see results"
echo "================================================================"
echo ""

# Start a new zsh with strace tracking writes
timeout ${DURATION} strace -f -e trace=write,writev,pwrite,pwrite64,fsync,fdatasync -o "$OUTPUT_FILE" zsh -i -c "
echo 'Shell ready! Run some commands...'
echo 'Try: ls, cd, history, etc.'
# Keep shell interactive
exec zsh
" 2>/dev/null

echo ""
echo "================================================================"
echo "Analyzing write patterns..."
echo "================================================================"
echo ""

# Parse the strace output
if [ -f "$OUTPUT_FILE" ]; then
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          FILES WRITTEN TO (sorted by frequency)           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    
    # Extract file descriptors and their paths, count writes
    grep -E "write|writev|pwrite" "$OUTPUT_FILE" | \
        grep -oE '\([0-9]+,' | \
        tr -d '(,' | \
        sort | uniq -c | sort -rn | head -20
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          WRITE SYSCALLS BY TYPE                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    
    echo "write():    $(grep -c '^[0-9]* write(' "$OUTPUT_FILE")"
    echo "writev():   $(grep -c '^[0-9]* writev(' "$OUTPUT_FILE")"
    echo "pwrite():   $(grep -c '^[0-9]* pwrite' "$OUTPUT_FILE")"
    echo "fsync():    $(grep -c '^[0-9]* fsync(' "$OUTPUT_FILE")"
    echo "fdatasync(): $(grep -c '^[0-9]* fdatasync(' "$OUTPUT_FILE")"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          SAMPLE WRITE OPERATIONS                          ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    
    # Show some actual write operations
    grep -E "write.*zsh_history|write.*cache|write.*autosugg" "$OUTPUT_FILE" | head -10
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          DETAILED ANALYSIS                                ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    
    # Count writes to history file
    HISTORY_WRITES=$(grep -c "zsh_history" "$OUTPUT_FILE" 2>/dev/null || echo "0")
    echo "Writes to .zsh_history: $HISTORY_WRITES"
    
    # Count writes to cache files
    CACHE_WRITES=$(grep -c "/cache/" "$OUTPUT_FILE" 2>/dev/null || echo "0")
    echo "Writes to cache files: $CACHE_WRITES"
    
    # Count fsync operations (forced disk writes)
    FSYNC_COUNT=$(grep -c "fsync\|fdatasync" "$OUTPUT_FILE" 2>/dev/null || echo "0")
    echo "Forced disk syncs (fsync): $FSYNC_COUNT"
    
    echo ""
    echo "Full trace saved to: $OUTPUT_FILE"
    echo "View with: less $OUTPUT_FILE"
    
else
    echo "No trace file generated. The shell may have exited too quickly."
fi

echo ""
echo "================================================================"
echo "RECOMMENDATIONS:"
echo "================================================================"

if [ "$HISTORY_WRITES" -gt 50 ]; then
    echo "⚠️  HIGH: Many writes to .zsh_history detected!"
    echo "   → Reduce HISTSIZE in ~/.zshrc (currently 100000000)"
    echo "   → Suggested: export HISTSIZE=50000"
fi

if [ "$CACHE_WRITES" -gt 20 ]; then
    echo "⚠️  MODERATE: Cache writes detected"
    echo "   → Check zsh-autosuggestions and other plugins"
fi

if [ "$FSYNC_COUNT" -gt 10 ]; then
    echo "⚠️  HIGH: Many forced disk syncs (fsync)"
    echo "   → This causes disk I/O latency"
    echo "   → Consider disabling aggressive plugins"
fi

echo ""

# Made with Bob
