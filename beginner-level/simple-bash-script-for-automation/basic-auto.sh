#!/bin/bash

# Bash script to automate system management tasks, including updating, upgrading, 
# cleaning log files, and managing backups (backup/restore). This improved version 
# incorporates modularization, error handling, logging, user feedback, and other enhancements.

# -------------------------
# Constants and Configuration
# -------------------------
BACKUP_DIR="/mnt/backup"  # Default backup directory
LOG_FILE="/var/log/system_automation.log"  # Log file to track actions
RED='\033[0;31m'  # Red color for errors
GREEN='\033[0;32m'  # Green color for success
YELLOW='\033[0;33m'  # Yellow color for warnings
NC='\033[0m'  # No color

# Ensure the backup directory and log file exist
mkdir -p "$BACKUP_DIR"
touch "$LOG_FILE"

# -------------------------
# Logging Helper Function
# -------------------------
log_action() {
    echo "$(date): $1" | tee -a "$LOG_FILE"
}

# -------------------------
# Trap for Cleanup
# -------------------------
trap 'log_action "Script interrupted! Cleaning up..."; exit 1' SIGINT SIGTERM

# -------------------------
# Help Menu
# -------------------------
show_help() {
    echo -e "${YELLOW}Usage:${NC} $0 [OPTION]"
    echo "Options:"
    echo "  --help       Show this help message"
    echo "  --menu       Display the interactive menu"
    exit 0
}

# Display help if --help is passed
if [[ $1 == "--help" ]]; then
    show_help
fi

# -------------------------
# Detect Linux Distribution
# -------------------------
detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        log_action "Unable to detect Linux distribution."
        echo -e "${RED}Error: Unable to detect Linux distribution.${NC}"
        exit 1
    fi
}

# -------------------------
# Update and Upgrade System
# -------------------------
update_with_specific_package_manager() {
    case $OS in
        ubuntu|debian|raspbian|pop|zorin|kali|linuxmint|elementary|parrot|deepin|mx|lmde|peppermint|bodhi|devuan|antiX)
            sudo apt update && log_action "System updated using apt"
            ;;
        centos|rhel|amazon|cloudlinux|scientific|xcp-ng|xenserver)
            sudo yum update && log_action "System updated using yum"
            ;;
        fedora|rocky|oracle|clear)
            sudo dnf update && log_action "System updated using dnf"
            ;;
        opensuse|sles|suse|tumbleweed|leap)
            sudo zypper refresh && sudo zypper update && log_action "System updated using zypper"
            ;;
        arcolinux|artix|arch|manjaro|garuda|endeavouros)
            sudo pacman -Syu && log_action "System updated using pacman"
            ;;
        alpine)
            sudo apk update && log_action "System updated using apk"
            ;;
        *)
            log_action "Unsupported Linux distribution: $OS"
            echo -e "${RED}Error: Unsupported Linux distribution.${NC}"
            exit 1
            ;;
    esac
}

upgrade_with_specific_package_manager() {
    case $OS in
        ubuntu|debian|raspbian|pop|zorin|kali|linuxmint|elementary|parrot|deepin|mx|lmde|peppermint|bodhi|devuan|antiX)
            sudo apt upgrade -y && log_action "System upgraded using apt"
            ;;
        centos|rhel|amazon|cloudlinux|scientific|xcp-ng|xenserver)
            sudo yum upgrade -y && log_action "System upgraded using yum"
            ;;
        fedora|rocky|oracle|clear)
            sudo dnf upgrade -y && log_action "System upgraded using dnf"
            ;;
        opensuse|sles|suse|tumbleweed|leap)
            sudo zypper update -y && log_action "System upgraded using zypper"
            ;;
        arcolinux|artix|arch|manjaro|garuda|endeavouros)
            sudo pacman -Syu --noconfirm && log_action "System upgraded using pacman"
            ;;
        alpine)
            sudo apk upgrade -y && log_action "System upgraded using apk"
            ;;
        *)
            log_action "Unsupported Linux distribution: $OS"
            echo -e "${RED}Error: Unsupported Linux distribution.${NC}"
            exit 1
            ;;
    esac
}

# -------------------------
# Backup Functionality
# -------------------------
backup() {
    read -p "Enter the full path of the file or directory to back up: " SOURCE_PATH

    if [ ! -e "$SOURCE_PATH" ]; then
        log_action "Error: Path '$SOURCE_PATH' does not exist."
        echo -e "${RED}Error: The path '$SOURCE_PATH' does not exist.${NC}"
        exit 1
    fi

    BASE_NAME=$(basename "$SOURCE_PATH")
    DATE_TIME=$(date)
    BACKUP_NAME="backup_${BASE_NAME}_${DATE_TIME}.tar.gz"
    BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

    log_action "Backing up '$SOURCE_PATH' to '$BACKUP_PATH'..."
    tar -czvf "$BACKUP_PATH" "$SOURCE_PATH"

    if [ $? -eq 0 ]; then
        log_action "Backup successful: $BACKUP_PATH"
        echo -e "${GREEN}Backup successful! File saved at: $BACKUP_PATH${NC}"
    else
        log_action "Backup failed for '$SOURCE_PATH'"
        echo -e "${RED}Error: Backup failed.${NC}"
        exit 1
    fi
}

# -------------------------
# Restore Functionality
# -------------------------
restore() {
    cd "$BACKUP_DIR" || { log_action "Error: Failed to navigate to $BACKUP_DIR"; exit 1; }

    echo "Fetching backup files..."
    BACKUP_FILES=($(ls -1 *.tar.gz))

    if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
        log_action "No backup files found in $BACKUP_DIR."
        echo -e "${YELLOW}Warning: No backup files found in $BACKUP_DIR.${NC}"
        exit 1
    fi

    echo "Select a backup file to restore:"
    for i in "${!BACKUP_FILES[@]}"; do
        echo "$((i + 1))) ${BACKUP_FILES[$i]}"
    done

    read -p "Enter the number corresponding to your choice: " BACKUP_CHOICE

    if [[ ! $BACKUP_CHOICE =~ ^[0-9]+$ ]] || [ "$BACKUP_CHOICE" -lt 1 ] || [ "$BACKUP_CHOICE" -gt "${#BACKUP_FILES[@]}" ]; then
        log_action "Invalid backup selection."
        echo -e "${RED}Error: Invalid choice.${NC}"
        exit 1
    fi

    SELECTED="${BACKUP_FILES[$((BACKUP_CHOICE - 1))]}"
    log_action "Restoring backup: $SELECTED"

    tar -xzvf "$SELECTED"

    if [ $? -eq 0 ]; then
        log_action "Restore successful: $SELECTED"
        echo -e "${GREEN}Restore successful!${NC}"
    else
        log_action "Restore failed for: $SELECTED"
        echo -e "${RED}Error: Restore failed.${NC}"
        exit 1
    fi
}

# -------------------------
# Main Menu
# -------------------------
echo "Select the service to proceed: "
echo "1. Update the system"
echo "2. Upgrade the system"
echo "3. Backup important data"
echo "4. Restore important data"
echo "5. Exit"

read -p "Enter your choice (1-5): " CHOICE

case $CHOICE in
    1)
        detect_linux_distro
        update_with_specific_package_manager
        ;;
    2)
        detect_linux_distro
        upgrade_with_specific_package_manager
        ;;
    3)
        backup
        ;;
    4)
        restore
        ;;
    5)
        log_action "Script exited by user."
        echo "Exiting the script..."
        exit 0
        ;;
    *)
        log_action "Invalid menu choice: $CHOICE"
        echo -e "${RED}Invalid choice. Please select a number between 1-5.${NC}"
        exit 1
        ;;
esac
