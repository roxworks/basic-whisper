#!/usr/bin/env bash
set -e

echo "Starting DigitalOcean box setup..."

# Step 1: Configure swap space (6GB)
echo "Checking for existing swap space..."
if [ -f /swapfile ]; then
    echo "Swap file already exists. Checking if it is active..."
    if swapon --show | grep -q "/swapfile"; then
        echo "Swap file is already active."
    else
        echo "Activating existing swap file..."
        sudo swapon /swapfile
        echo "Swap file activated."
    fi
else
    echo "No existing swap file found. Creating a new 6GB swap file..."
    sudo fallocate -l 6G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "Swap space configured (6GB)."
fi

# Step 2: Update packages
echo "Updating packages..."
sudo apt update

# Step 3: Install required packages
echo "Installing required packages..."
sudo apt install -y ffmpeg python3 python3-pip python3-venv curl

# Step 4: Create Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv whisperenv

# Step 5: Activate the virtual environment
source whisperenv/bin/activate

# Step 6: Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Step 7: Install Whisper and dependencies
echo "Installing Whisper and dependencies..."
pip install openai-whisper
pip install torch --index-url https://download.pytorch.org/whl/cpu

# Step 8: Download test MP3 file
echo "Downloading test MP3 file..."
curl -o test.mp3 "https://traffic.megaphone.fm/NSR6725884392.mp3?updated=1734658129"
echo "Test MP3 file downloaded as test.mp3."

echo "Setup complete. To use, run the following commands:"
echo "source whisperenv/bin/activate"
echo "python3 transcribe.py test.mp3"
