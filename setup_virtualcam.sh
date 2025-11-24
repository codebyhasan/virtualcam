#!/usr/bin/env bash

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

# ---------- Check and install prerequisites ----------
echo "Checking prerequisites..."

# Update package list
apt update

# Install v4l2loopback-dkms and linux headers
apt install -y v4l2loopback-dkms linux-headers-$(uname -r) ffmpeg

# Check Python3
if ! command -v python3 &> /dev/null; then
  echo "Python3 not found. Installing..."
  apt install -y python3
fi

# Check modinfo
if ! command -v modinfo &> /dev/null; then
  echo "Installing kmod for modinfo..."
  apt install -y kmod
fi

# ---------- Configure v4l2loopback ----------
CONF_FILE="/etc/modprobe.d/v4l2loopback.conf"
echo "Creating modprobe config..."
echo 'options v4l2loopback video_nr=0 card_label="VirtualCam" exclusive_caps=1' > "$CONF_FILE"

echo "Updating initramfs..."
update-initramfs -u

# Reload module
echo "Reloading v4l2loopback module..."
modprobe -r v4l2loopback 2>/dev/null
modprobe v4l2loopback

# ---------- Verify ----------
if [ -e /dev/video0 ]; then
  echo "Virtual camera created successfully at /dev/video0:"
  ls -l /dev/video0
else
  echo "Failed to create /dev/video0. Try running:"
  echo "sudo modprobe v4l2loopback video_nr=0 card_label=\"VirtualCam\" exclusive_caps=1"
fi

echo "All done! This setup will persist after reboot."
