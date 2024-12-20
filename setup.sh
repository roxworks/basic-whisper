#!/usr/bin/env bash
set -e

### Digital Ocean Setup Start
echo "Starting DigitalOcean box setup..."

# Update packages
sudo apt update

# Install required packages
sudo apt install -y ffmpeg python3 python3-pip python3-venv curl

# Configure swap space (4GB)
echo "Configuring swap space..."
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
echo "Swap space configured (4GB)."

### Digital Ocean Setup End

# Create Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv whisperenv

# Activate the virtual environment
source whisperenv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install Whisper and dependencies
echo "Installing Whisper and dependencies..."
pip install openai-whisper
pip install torch --index-url https://download.pytorch.org/whl/cpu

# Download test MP3 file
echo "Downloading test MP3 file..."
curl -o test.mp3 "https://traffic.megaphone.fm/NSR6725884392.mp3?updated=1734658129"
echo "Test MP3 file downloaded as test.mp3."

echo "Setup complete. To use, run the following commands:"
echo "source whisperenv/bin/activate"
echo "python3 transcribe.py test.mp3"
