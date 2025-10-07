#!/bin/bash

# Hyprland Development Environment Setup Script
# Automatically launches applications across multiple workspaces
# without switching away from the current workspace

set -e  # Exit on error

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Always return to workspace 1 after launching apps
CURRENT_WORKSPACE=1

# Function to check if an application is already running
is_running() {
   pgrep -x "$1" > /dev/null
}

# Function to launch app in specific workspace silently
launch_in_workspace() {
   local workspace=$1
   local app_command=$2
   local app_name=$3
  
   echo -e "${GREEN}[Workspace ${workspace}]${NC} Launching ${app_name}..."
   hyprctl dispatch exec "[workspace ${workspace} silent] ${app_command}"
}

# Function to launch app in specific workspace and return to current workspace
launch_in_workspace_return() {
   local workspace=$1
   local app_command=$2
   local app_name=$3
  
   echo -e "${GREEN}[Workspace ${workspace}]${NC} Launching ${app_name}..."
   hyprctl dispatch workspace ${workspace}
   sleep 0.3
   hyprctl dispatch exec "${app_command}"
   sleep 0.3
   hyprctl dispatch workspace ${CURRENT_WORKSPACE}
}

echo "========================================"
echo "  Hyprland Development Setup"
echo "========================================"
echo ""

# ============================================
# WORKSPACE 1: Brave Browser
# ============================================
if is_running "brave"; then
   echo -e "${YELLOW}[Workspace 1]${NC} Brave is already running. Skipping..."
else
   launch_in_workspace 1 "brave" "Brave Browser"
fi

# ============================================
# WORKSPACE 2: Firefox Developer Edition
# ============================================
# Firefox Developer Edition typically runs as "firefox-developer-edition" or "firefox"
if is_running "firefox-develop" || is_running "firefox"; then
   echo -e "${YELLOW}[Workspace 2]${NC} Firefox Developer Edition is already running. Skipping..."
else
   # Adjust the command if your Firefox Dev Edition has a different executable name
   launch_in_workspace 2 "firefox-developer-edition" "Firefox Developer Edition"
fi

# ============================================
# WORKSPACE 3: XFCE4 Terminal
# ============================================
# Always launch a new terminal instance in workspace 3
launch_in_workspace_return 3 "xfce4-terminal" "XFCE4 Terminal"

# ============================================
# WORKSPACE 4: Visual Studio Code
# ============================================
if pgrep -i "code" > /dev/null || pgrep "electron" | xargs -I {} ps -p {} -o cmd= | grep -q "code"; then
   echo -e "${YELLOW}[Workspace 4]${NC} VS Code is already running. Skipping..."
else
   # Use full path or ensure 'code' is in PATH
   launch_in_workspace 4 "/usr/bin/code" "Visual Studio Code"
fi

# ============================================
# WORKSPACE 5: Docker Desktop & Postman
# ============================================

# Launch Docker Desktop GUI
if is_running "docker-desktop" || is_running "Docker Desktop"; then
   echo -e "${YELLOW}[Workspace 5]${NC} Docker Desktop is already running. Skipping..."
else
   echo -e "${GREEN}[Workspace 5]${NC} Starting Docker Desktop..."
   launch_in_workspace 5 "systemctl --user start docker-desktop" "Docker Desktop"
fi

# Launch Postman
if is_running "Postman"; then
   echo -e "${YELLOW}[Workspace 5]${NC} Postman is already running. Skipping..."
else
   # Using full path to Postman executable
   POSTMAN_PATH="$HOME/Applications/Postman/Postman"
  
   # Check if Postman exists at the specified path
   if [ -f "$POSTMAN_PATH" ]; then
       launch_in_workspace 5 "$POSTMAN_PATH" "Postman"
   else
       echo -e "${YELLOW}[Workspace 5]${NC} Warning: Postman not found at $POSTMAN_PATH"
       echo "Please verify the path and update the script if necessary."
   fi
fi

# ============================================
# Completion
# ============================================
echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Applications have been launched in their respective workspaces."
echo "You can switch between them using your Hyprland workspace keybindings."
echo ""

# Optional: Add a small delay to ensure apps have time to start
sleep 1

exit 0