#!/bin/bash

# Test script to demonstrate file write tracking
# This shows what files zsh writes to during normal operation

echo "=== Testing File Write Tracking ==="
echo ""
echo "Method 1: Using inotifywait (if available)"
echo "----------------------------------------"

if command -v inotifywait &> /dev/null; then
    echo "Starting inotifywait monitor for 10 seconds..."
    echo "Monitoring: ~/.zsh_history, ~/.cache, ~/.local/share"
    
    # Start monitoring in background
    timeout 10 inotifywait -m -r -e modify,create,close_write \
        ~/.zsh_history \
        ~/.cache/ \
        ~/.local/share/ \
        2>/dev/null | grep -E "zsh|history|autosugg|p10k" &
    
    MONITOR_PID=$!
    
    # Generate some shell activity
    sleep 2
    echo ""
    echo "Generating shell activity..."
    zsh -c '
        for i in {1..10}; do
            echo "Command $i" >> /tmp/test_output.txt
            ls -la > /dev/null
            pwd > /dev/null
        done
    '
    
    # Wait for monitor to finish
    wait $MONITOR_PID 2>/dev/null
    
    echo ""
    echo "Monitor complete!"
else
    echo "inotifywait not found. Install with: sudo apt install inotify-tools"
fi

echo ""
echo "Method 2: Check recently modified zsh-related files"
echo "---------------------------------------------------"
echo "Files modified in last 5 minutes:"
find ~ -maxdepth 3 -type f -mmin -5 2>/dev/null | grep -E "zsh|history" | head -20

echo ""
echo "Method 3: Check file sizes (large files = more writes)"
echo "------------------------------------------------------"
echo "Large zsh-related files:"
find ~ -maxdepth 3 -type f -size +1M 2>/dev/null | grep -E "zsh|history" | xargs ls -lh 2>/dev/null

echo ""
echo "Method 4: History file stats"
echo "---------------------------"
if [ -f ~/.zsh_history ]; then
    echo "~/.zsh_history:"
    ls -lh ~/.zsh_history
    echo "Line count: $(wc -l < ~/.zsh_history)"
    echo "Last modified: $(stat -c %y ~/.zsh_history)"
fi

echo ""
echo "=== To use BPF tracking (requires sudo): ==="
echo "sudo bpftrace ~/scripts/bpf-scripts/track_zsh_writes.bt"
echo ""
echo "=== Or use iotop (requires sudo): ==="
echo "sudo iotop -o -P"
echo "Then use your shell and watch for 'zsh' processes with DISK WRITE activity"

# Made with Bob
