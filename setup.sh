#!/usr/bin/env bash
set -e

echo "Starting DigitalOcean box setup..."

# Step 1: Configure swap space (5GB)
echo "Checking swap space configuration..."
current_swap_size=$(free -h | awk '/Swap:/ {print $2}')

if [ -f /swapfile ]; then
    echo "Swap file detected. Current swap size: $current_swap_size"
    if [ "$current_swap_size" != "5.0G" ]; then
        echo "Swap size is incorrect. Replacing with a 5GB swap file..."
        sudo swapoff /swapfile || echo "Swap file not active; proceeding with replacement..."
        sudo rm -f /swapfile
        sudo fallocate -l 5G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
        echo "Swap space reconfigured to 5GB."
    else
        echo "Swap size is already correctly configured (5GB)."
    fi
else
    echo "No swap file detected. Creating a new 5GB swap file..."
    sudo fallocate -l 5G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "Swap space configured (5GB)."
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

# Step 8: Download test MP3 file# Step 8: Download test MP3 file
echo "Resolving final URL for test MP3 file..."
final_url=$(curl -Is "https://traffic.megaphone.fm/NSR6725884392.mp3?updated=1734658129" | grep -i 'location:' | awk '{print $2}' | tr -d '\r')

if [ -z "$final_url" ]; then
    echo "Failed to resolve the final URL. Exiting."
    exit 1
fi

echo "Downloading test MP3 file from resolved URL: $final_url"
curl -o test.mp3 "$final_url"

# Verify the download
if [ ! -s test.mp3 ]; then
    echo "Download failed or the file is empty. Exiting."
    exit 1
fi

echo "Test MP3 file downloaded successfully as test.mp3."

echo "--------------------------------"

echo "Setup complete. To use, run the following commands:"
echo "source whisperenv/bin/activate"
echo "python3 transcribe.py test.mp3"
