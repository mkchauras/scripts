#!/bin/sh

# Usage: ./pinctrl.sh <PIN> <STATE>
PIN="$1"
STATE="$2"

# Check if both arguments are provided
if [ -z "$PIN" ] || [ -z "$STATE" ]; then
  echo "Usage: $0 <PIN> <STATE>"
  exit 1
fi

# Construct and send JSON POST request
curl -X POST http://lab-power-socket.local/pin-ctrl \
     -H "Content-Type: application/json" \
     -d "{\"$PIN\":\"$STATE\"}"

