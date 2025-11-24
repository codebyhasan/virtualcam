
# VirtualCam

This script will automatically set up a virtual camera on your Linux system using **v4l2loopback** and **FFmpeg**, configure it to persist across reboots, and ensure all prerequisites are installed.

Run the following command to download, make executable, and run the setup script:

```bash
wget https://github.com/codebyhasan/virtualcam/blob/main/setup_virtualcam.sh -O setup_virtualcam.sh && chmod +x setup_virtualcam.sh && ./setup_virtualcam.sh
````

**What it does:**

* Installs required packages: `linux-headers`, `v4l2loopback-dkms`, `ffmpeg`, `python3`, `kmod`.
* Configures the virtual camera to appear as `/dev/video0`.
* Sets up `v4l2loopback` to load automatically with your preferred settings after reboot.
* Makes the Python script `virtualcam.py` ready to run as a command.

Once done, you can control the virtual camera using the `virtualcam` command:

```bash
virtualcam start      # Start in foreground
virtualcam start --bg # Start in background
virtualcam stop       # Stop the camera
virtualcam toggle     # Toggle ON/OFF
virtualcam status     # Show current status
```
