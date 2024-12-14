#!/bin/bash

# Check if there is sufficient storage space
required_space=2048  # 2GB in MB
current_space=$(df /data/data/com.termux/files/home | awk 'NR==2 {print $4}')

if [ $current_space -lt $required_space ]; then
  echo "Not enough storage. Please free up space."
  exit 1
fi

# Update and upgrade Termux
pkg update -y && pkg upgrade -y

# Install essential Termux packages
packages=(
    git
    curl
    wget
    python
    python2
    python3
    php
    openssh
    vim
    nano
    zip
    unzip
    clang
    make
    nodejs
    ruby
    perl
    rust
    go
    java
    swift
    kotlin
    proot-distro
)

echo "Installing essential Termux packages..."
for pkg in "${packages[@]}"; do
    pkg install -y "$pkg"
done

# Check if proot-distro is installed successfully
if ! command -v proot-distro &> /dev/null; then
    echo "Error: proot-distro installation failed."
    exit 1
fi

# Install and configure Ubuntu in proot-distro
echo "Setting up Ubuntu in proot-distro..."
proot-distro install ubuntu

# Configure Ubuntu (root login, auto login, install dev packages)
echo "Configuring Ubuntu setup..."
proot-distro login ubuntu --bind=/sdcard <<EOF
apt update -y
apt upgrade -y
apt install -y sudo wget curl build-essential git vim nano python3 python3-pip php openjdk-11-jdk ruby nodejs npm perl golang rustc
echo "root ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "export PATH=\$PATH:/usr/local/bin" >> ~/.bashrc
source ~/.bashrc
EOF

# Set up auto-login for Ubuntu
echo "Setting up auto-login for Ubuntu..."
cat <<EOL > ~/.bashrc
proot-distro login ubuntu --bind=/sdcard
exit
EOL

echo "Setup complete! Restart Termux, and you'll be logged into Ubuntu as root automatically."