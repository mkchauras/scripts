# Microsoft Defender ATP (MDATP) Quick Reference

## Quick Commands to Exclude /home/mkchauras/src

### Single Command (Fastest):
```bash
sudo mdatp exclusion folder add --path "/home/mkchauras/src"
```

### Verify it was added:
```bash
sudo mdatp exclusion list | grep mkchauras
```

### Remove if needed:
```bash
sudo mdatp exclusion folder remove --path "/home/mkchauras/src"
```

## Using the Helper Script

Run the interactive script:
```bash
~/scripts/system/exclude_mdatp_dirs.sh
```

This will add multiple common directories:
- `/home/mkchauras/src` (your source code)
- `/home/mkchauras/.cache` (cache files)
- `/home/mkchauras/.local/share` (local data)
- `/home/mkchauras/qemu` (QEMU builds)

## Common MDATP Commands

### Check current exclusions:
```bash
sudo mdatp exclusion list
```

### Add folder exclusion:
```bash
sudo mdatp exclusion folder add --path "/path/to/folder"
```

### Add file extension exclusion:
```bash
sudo mdatp exclusion extension add --name "o"      # object files
sudo mdatp exclusion extension add --name "a"      # archive files
sudo mdatp exclusion extension add --name "so"     # shared libraries
```

### Add process exclusion:
```bash
sudo mdatp exclusion process add --name "gcc"
sudo mdatp exclusion process add --name "make"
sudo mdatp exclusion process add --name "qemu-system-x86_64"
```

### Check MDATP status:
```bash
sudo mdatp health
```

### Check real-time protection status:
```bash
sudo mdatp config real-time-protection --value enabled
```

### Temporarily disable real-time protection (not recommended):
```bash
sudo mdatp config real-time-protection --value disabled
```

### View MDATP logs:
```bash
sudo journalctl -u mdatp -f
```

## Monitor CPU Usage

### Check wdavdaemon CPU usage:
```bash
top -p $(pgrep wdavdaemon | tr '\n' ',')
```

### Or with htop:
```bash
htop -p $(pgrep wdavdaemon | paste -sd,)
```

### Watch CPU usage over time:
```bash
watch -n 2 'ps aux | grep wdavdaemon | grep -v grep'
```

## Recommended Exclusions for Development

### For kernel/QEMU development:
```bash
sudo mdatp exclusion folder add --path "/home/mkchauras/src"
sudo mdatp exclusion folder add --path "/home/mkchauras/qemu"
sudo mdatp exclusion extension add --name "o"
sudo mdatp exclusion extension add --name "a"
sudo mdatp exclusion extension add --name "ko"
sudo mdatp exclusion process add --name "gcc"
sudo mdatp exclusion process add --name "make"
sudo mdatp exclusion process add --name "ld"
```

### For general development:
```bash
sudo mdatp exclusion folder add --path "/home/mkchauras/.cache"
sudo mdatp exclusion folder add --path "/home/mkchauras/.local/share"
sudo mdatp exclusion folder add --path "/home/mkchauras/.cargo"
sudo mdatp exclusion folder add --path "/home/mkchauras/.rustup"
```

## Troubleshooting

### If MDATP is using too much CPU:
1. Add exclusions for your development directories
2. Exclude build artifacts (*.o, *.a, *.so)
3. Exclude compiler processes (gcc, clang, make)
4. Check what files are being scanned:
   ```bash
   sudo mdatp diagnostic real-time-protection-statistics --output json
   ```

### If exclusions aren't working:
1. Verify the path is correct (use absolute paths)
2. Restart MDATP service:
   ```bash
   sudo systemctl restart mdatp
   ```
3. Check MDATP health:
   ```bash
   sudo mdatp health
   ```

## Performance Impact

After adding exclusions, you should see:
- Lower CPU usage from wdavdaemon processes
- Faster compilation times
- Reduced disk I/O
- Better shell responsiveness

Monitor before and after:
```bash
# Before
time make -j$(nproc)

# Add exclusions, then:
# After
time make -j$(nproc)
```

## Security Note

⚠️ Only exclude directories you trust. Excluded paths won't be scanned for malware.
Safe to exclude:
- Your own source code directories
- Build output directories
- Package manager caches
- Language-specific toolchain directories

Do NOT exclude:
- Downloads folder
- Temporary directories with untrusted content
- Directories where you extract archives from the internet