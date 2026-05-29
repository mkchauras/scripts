#!/usr/bin/env python3
"""
Real-time visualization of file writes from BPF trace
Parses bpftrace output and creates a live updating bar chart
"""

import sys
import time
import subprocess
from collections import defaultdict
import os

def clear_screen():
    os.system('clear')

def create_bar(count, max_count, width=50):
    """Create a visual bar for the count"""
    if max_count == 0:
        return ""
    filled = int((count / max_count) * width)
    bar = "█" * filled + "░" * (width - filled)
    return bar

def format_bytes(bytes_val):
    """Format bytes into human-readable format"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes_val < 1024.0:
            return f"{bytes_val:.1f}{unit}"
        bytes_val /= 1024.0
    return f"{bytes_val:.1f}TB"

def monitor_writes(duration=30):
    """Monitor file writes using bpftrace"""
    print("Starting BPF trace... (requires sudo)")
    print(f"Monitoring for {duration} seconds...")
    print("=" * 80)
    
    # Simple bpftrace one-liner to track writes
    bpf_cmd = f"""
    sudo bpftrace -e '
    tracepoint:syscalls:sys_enter_write /comm == "zsh"/ {{
        @fd[tid] = args->fd;
    }}
    tracepoint:syscalls:sys_exit_write /@fd[tid] && args->ret > 0/ {{
        $path = path(curtask->files->fdt->fd[@fd[tid]]);
        @writes[$path] = count();
        @bytes[$path] = sum(args->ret);
        delete(@fd[tid]);
    }}
    interval:s:1 {{
        print(@writes);
        print(@bytes);
        clear(@writes);
        clear(@bytes);
    }}
    '
    """
    
    try:
        process = subprocess.Popen(
            bpf_cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        start_time = time.time()
        file_stats = defaultdict(lambda: {'writes': 0, 'bytes': 0})
        
        while time.time() - start_time < duration:
            line = process.stdout.readline()
            if line:
                # Parse bpftrace output
                if ':' in line and '@' not in line:
                    parts = line.strip().split(':')
                    if len(parts) >= 2:
                        filepath = parts[0].strip()
                        count = parts[1].strip()
                        if count.isdigit():
                            file_stats[filepath]['writes'] += int(count)
            
            # Update display every second
            if int(time.time() - start_time) % 1 == 0:
                display_stats(file_stats)
        
        process.terminate()
        
    except KeyboardInterrupt:
        print("\n\nMonitoring stopped by user")
    except Exception as e:
        print(f"Error: {e}")

def display_stats(file_stats):
    """Display statistics with visual bars"""
    clear_screen()
    
    print("╔" + "═" * 78 + "╗")
    print("║" + " " * 20 + "ZSH FILE WRITE ACTIVITY" + " " * 35 + "║")
    print("╚" + "═" * 78 + "╝")
    print()
    
    if not file_stats:
        print("No writes detected yet...")
        return
    
    # Sort by write count
    sorted_files = sorted(file_stats.items(), key=lambda x: x[1]['writes'], reverse=True)[:20]
    
    if sorted_files:
        max_writes = max(f[1]['writes'] for f in sorted_files)
        
        print(f"{'FILE PATH':<50} {'WRITES':<10} {'VISUAL'}")
        print("-" * 80)
        
        for filepath, stats in sorted_files:
            # Truncate long paths
            display_path = filepath[-47:] if len(filepath) > 47 else filepath
            if len(filepath) > 47:
                display_path = "..." + display_path
            
            bar = create_bar(stats['writes'], max_writes, width=15)
            print(f"{display_path:<50} {stats['writes']:<10} {bar}")
    
    print("\n" + "=" * 80)
    print("Press Ctrl+C to stop monitoring")

def main():
    if len(sys.argv) > 1:
        try:
            duration = int(sys.argv[1])
        except ValueError:
            print("Usage: sudo python3 visualize_writes.py [duration_in_seconds]")
            sys.exit(1)
    else:
        duration = 30
    
    if os.geteuid() != 0:
        print("This script requires root privileges. Please run with sudo.")
        sys.exit(1)
    
    monitor_writes(duration)

if __name__ == "__main__":
    main()

# Made with Bob
