# File Write Tracking Scripts

These BPF scripts help identify which files are being written to most frequently, particularly useful for finding disk-intensive shell plugins.

## Scripts

### 1. track_zsh_writes.bt (Recommended)
**Best for identifying zsh plugin disk activity**

```bash
sudo bpftrace track_zsh_writes.bt
```

Features:
- Tracks writes specifically from zsh/bash processes
- Shows write counts, bytes written, and fsync operations
- Visual histograms of write sizes
- Beautiful formatted output

**Usage:**
1. Open a new terminal
2. Run: `sudo bpftrace ~/scripts/bpf-scripts/track_zsh_writes.bt`
3. In another terminal, use your shell normally (run commands, use tab completion, etc.)
4. After 30-60 seconds, press Ctrl+C to see results
5. Look for files like:
   - `~/.zsh_history` (history writes)
   - `~/.zsh-update` (oh-my-zsh updates)
   - Cache files in `~/.cache/` or `~/.local/share/`

### 2. track_file_writes.bt
**General purpose file write tracker**

```bash
sudo bpftrace track_file_writes.bt
```

Tracks all file writes system-wide (not just zsh). More comprehensive but noisier.

### 3. visualize_writes.py
**Real-time visualization (experimental)**

```bash
sudo python3 visualize_writes.py 30
```

Attempts to create a live updating display of file writes. May need adjustments based on your system.

## Quick Analysis Commands

### Using existing Linux tools (no BPF required):

#### 1. Monitor writes to specific files:
```bash
# Watch zsh history file
watch -n 1 'ls -lh ~/.zsh_history'

# Monitor all writes in home directory
inotifywait -m -r -e modify,create,delete ~/.cache/ ~/.local/share/ 2>&1 | grep -E "zsh|autosugg|history"
```

#### 2. Use iotop to see disk I/O by process:
```bash
sudo iotop -o -P
```
Then use your shell and watch for zsh processes with high DISK WRITE.

#### 3. Check file access times:
```bash
# Find recently modified files in cache directories
find ~/.cache ~/.local/share -type f -mmin -5 -ls 2>/dev/null | grep -i zsh
```

## Expected Culprits

Based on your ~/.zshrc, watch for writes to:

1. **~/.zsh_history** - Your 100M line history (MAIN CULPRIT)
2. **~/.cache/p10k-instant-prompt-*.zsh** - Powerlevel10k cache
3. **~/.zsh-update** - Oh-my-zsh update checks
4. **~/.local/share/zsh/** - Autosuggestions cache
5. **~/.cache/zsh/** - Various plugin caches

## Interpreting Results

High write counts to these files indicate:
- **~/.zsh_history**: Reduce HISTSIZE/SAVEHIST
- **Autosuggestions cache**: Consider disabling or using history-only strategy
- **P10k cache**: Normal, only written at startup
- **Plugin caches**: May need to disable specific plugins

## Troubleshooting

If bpftrace doesn't work:
```bash
# Check if bpftrace is installed
which bpftrace

# Install if needed (Ubuntu/Debian)
sudo apt install bpftrace

# Check kernel support
uname -r  # Should be 4.9+
```

If you get permission errors:
```bash
# All BPF scripts require root
sudo bpftrace script.bt
```

## Simple Alternative: strace

If BPF tools aren't available, use strace:

```bash
# Start a new zsh and trace its writes
strace -e trace=write,writev,pwrite,pwrite64 -f zsh 2>&1 | grep -E "write|\.zsh"
```

Then use the shell normally and watch the output.