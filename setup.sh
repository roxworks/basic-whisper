#!/usr/bin/env bash
set -e

# Update packages
sudo apt update

# Install required packages
sudo apt install -y ffmpeg python3 python3-pip python3-venv curl

# Create virtual environment
python3 -m venv whisperenv

# Activate the virtual environment
source whisperenv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install Whisper and dependencies
pip install openai-whisper
pip install torch --index-url https://download.pytorch.org/whl/cpu

# Download test MP3 file
echo "Downloading test MP3 file..."
curl -o test.mp3 "https://traffic.megaphone.fm/NSR6725884392.mp3?updated=1734658129"
echo "Test MP3 file downloaded as test.mp3."

echo "Setup complete. To use, run:"
echo "source whisperenv/bin/activate && python3 transcribe.py test.mp3"
