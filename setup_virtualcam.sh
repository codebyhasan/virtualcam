#!/usr/bin/env bash

# Ensure script runs as root where needed
if [ "$EUID" -ne 0 ]; then
  echo "Some steps require root. You may be prompted for sudo."
fi

# ---------- Install prerequisites ----------
echo "Updating package list and installing prerequisites..."
sudo apt update
sudo apt install -y linux-headers-$(uname -r) v4l2loopback-dkms ffmpeg python3 kmod git

# ---------- Clone virtualcam script ----------
if [ ! -d "$HOME/virtualcam" ]; then
  echo "Cloning virtualcam repository..."
  git clone git@github.com:codebyhasan/virtualcam.git "$HOME/virtualcam"
else
  echo "virtualcam repository already exists at $HOME/virtualcam"
fi

# ---------- Install virtualcam ----------
echo "Installing virtualcam..."
chmod +x "$HOME/virtualcam/virtualcam.py"
mkdir -p "$HOME/.local/bin"
mv "$HOME/virtualcam/virtualcam.py" "$HOME/.local/bin/virtualcam"

# ---------- Add ~/.local/bin to PATH permanently ----------
SHELL_RC="$HOME/.bashrc"
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
  echo "Added ~/.local/bin to PATH in $SHELL_RC"
fi
# Apply immediately for current session
export PATH="$HOME/.local/bin:$PATH"

# ---------- Configure v4l2loopback ----------
CONF_FILE="/etc/modprobe.d/v4l2loopback.conf"
echo "Creating modprobe configuration..."
echo 'options v4l2loopback video_nr=0 card_label="VirtualCam" exclusive_caps=1' | sudo tee "$CONF_FILE"

echo "Updating initramfs..."
sudo update-initramfs -u

echo "Reloading v4l2loopback module..."
sudo modprobe -r v4l2loopback 2>/dev/null
sudo modprobe v4l2loopback

# ---------- Verify virtual camera ----------
if [ -e /dev/video0 ]; then
  echo "Virtual camera created successfully at /dev/video0:"
  ls -l /dev/video0
else
  echo "Failed to create /dev/video0."
  echo "Try running manually:"
  echo "sudo modprobe v4l2loopback video_nr=0 card_label=\"VirtualCam\" exclusive_caps=1"
fi

echo "Setup complete! You can now use the 'virtualcam' command."
echo "Run 'virtualcam' to start in background or 'virtualcam start' for foreground."
