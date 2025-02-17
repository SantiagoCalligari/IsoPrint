#!/bin/bash

# Installer script for ImpresionAutomatica on Arch Linux

# Step 1: Install required packages
echo "Installing required packages..."
sudo pacman -S --noconfirm curl jq pdftk cups nushell

# Step 2: Make Impresion.nu and renew_token.nu executable
echo "Making scripts executable..."
chmod +x Impresion.nu
chmod +x renew_token.nu

# Step 3: Set up crontab to run Impresion.nu every 30 minutes
echo "Setting up crontab..."
(
  crontab -l 2>/dev/null
  echo "*/30 * * * * $(pwd)/Impresion.nu"
) | crontab -

# Step 4: Notify the user
echo "Installation complete. Impresion.nu will run every 30 minutes."

# Step 5: Run Impresion.nu for the first time
echo "Running Impresion.nu for the first time..."
./Impresion.nu
