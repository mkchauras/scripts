#!/bin/bash

# Script to install besclient CPU limit service
# This service will automatically set CPU limit after besclient.service starts

set -e

SERVICE_FILE="besclient-cpu-limit.service"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="/etc/systemd/system"

echo "Installing besclient CPU limit service..."

# Copy service file to systemd directory
sudo cp "${SCRIPT_DIR}/${SERVICE_FILE}" "${SYSTEMD_DIR}/"

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable the service to start at boot
sudo systemctl enable ${SERVICE_FILE}

# Start the service now
sudo systemctl start ${SERVICE_FILE}

# Check status
echo ""
echo "Service status:"
sudo systemctl status ${SERVICE_FILE} --no-pager

echo ""
echo "Installation complete!"
echo "The service will automatically run after besclient.service starts."
echo ""
echo "Useful commands:"
echo "  Check status:  sudo systemctl status ${SERVICE_FILE}"
echo "  Stop service:  sudo systemctl stop ${SERVICE_FILE}"
echo "  Disable:       sudo systemctl disable ${SERVICE_FILE}"
echo "  View logs:     sudo journalctl -u ${SERVICE_FILE}"

# Made with Bob
