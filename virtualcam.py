#!/usr/bin/env python3
import subprocess
import os
import signal
import sys

PID_FILE = "/tmp/virtualcam.pid"

# ---------- Helpers ----------

def is_running():
    if not os.path.exists(PID_FILE):
        return False
    try:
        pid = int(open(PID_FILE).read())
        os.kill(pid, 0)
        return True
    except:
        return False


def start(bg=False):
    if is_running():
        print("Virtual camera is already running.")
        return

    cmd = [
        "ffmpeg",
        "-re",
        "-f", "lavfi",
        "-i", "testsrc=size=1280x1280:rate=1",
        "-f", "v4l2",
        "/dev/video0"
    ]

    if bg:
        # Background: suppress all FFmpeg output
        p = subprocess.Popen(cmd, preexec_fn=os.setsid,
                             stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL)
        open(PID_FILE, "w").write(str(p.pid))
        print("Virtual camera started (background).")
        return

    # Foreground: show FFmpeg logs
    p = subprocess.Popen(cmd, preexec_fn=os.setsid)
    open(PID_FILE, "w").write(str(p.pid))
    print("Virtual camera started (foreground). Press Ctrl+C to stop.")
    try:
        p.wait()
    except KeyboardInterrupt:
        stop()

def stop():
    if not is_running():
        print("Virtual camera is not running.")
        return

    pid = int(open(PID_FILE).read())

    try:
        os.killpg(pid, signal.SIGTERM)
    except:
        pass

    if os.path.exists(PID_FILE):
        os.remove(PID_FILE)

    print("Virtual camera stopped.")

def status():
    print("Virtual camera is ON" if is_running() else "Virtual camera is OFF")

def toggle():
    if is_running():
        stop()
    else:
        start(bg=True)

def help_menu():
    print("""
Usage: virtualcam <command>

Commands:
  start           Start camera (foreground)
  start --bg      Start camera in background
  stop            Stop virtual camera
  status          Show camera status
  toggle          Turn ON if OFF, turn OFF if ON
  help            Show this help menu

Default:
  Running 'virtualcam' with no arguments = start --bg

Prerequisites:
  Requires v4l2loopback module and kernel headers:
    sudo apt install linux-headers-$(uname -r) v4l2loopback-dkms

--------------
VirtualCam is a tiny command-line tool that creates a virtual camera device using FFmpeg.
It was built to be lightweight, fast, and easy to control with simple commands.
No GUI, no extra services—just a clean script that can start, stop, and toggle a virtual camera on Linux.
It runs quietly in the background when launched without arguments, making it convenient for screen sharing,
testing, or feeding custom video into applications. Everything is handled through one small script.

Prerequisites:
- Linux system with /dev/video0 available for virtual camera
- FFmpeg installed and accessible in your PATH
- Python 3.x (tested with Python 3.13+)
- v4l2loopback kernel module installed

Install kernel module and headers (if missing):
sudo apt install linux-headers-$(uname -r) v4l2loopback-dkms
Load module:
sudo modprobe v4l2loopback video_nr=0 card_label="VirtualCam" exclusive_caps=1

----
HASAN
https://codebyhasan.link
10:42 PM BST (UTC+6)
Gaibandha, Bangladesh • Monday, November 24, 2025
""")

# ---------- Main ----------

if __name__ == "__main__":

    # Default: background start
    if len(sys.argv) == 1:
        start(bg=True)
        sys.exit()

    cmd = sys.argv[1]

    if cmd == "start":
        start(bg="--bg" in sys.argv)
    elif cmd == "stop":
        stop()
    elif cmd == "status":
        status()
    elif cmd == "toggle":
        toggle()
    elif cmd == "help":
        help_menu()
    else:
        print("Unknown command. Use 'virtualcam help'")
