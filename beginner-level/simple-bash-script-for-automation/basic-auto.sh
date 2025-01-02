#!/bin/bash

# Bash script to automate system management tasks, including updating, upgrading, 
# cleaning log files, and managing backups (backup/restore). This improved version 
# incorporates modularization, error handling, logging, user feedback, and other enhancements.

# -------------------------
# Constants and Configuration
# -------------------------
BACKUP_DIR="/mnt/backup"  # Default backup directory
LOG_DIR="/var/log"  # Default log directory
LOG_FILE="/var/log/system_automation.log"  # Log file to track actions
RELEASE_FILE="/etc/os-release"  # File containing OS release information
RED='\033[0;31m'  # Red color for errors
GREEN='\033[0;32m'  # Green color for success
YELLOW='\033[0;33m'  # Yellow color for warnings
NC='\033[0m'  # No color

# Ensure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root.${NC}"
    exec sudo "$0" "$@"
fi

# If no color support, disable colors
if [[ -n "$NO_COLOR" ]]; then
    RED='' GREEN='' YELLOW='' NC=''
fi

# Ensure the backup directory and log file exist
mkdir -p "$BACKUP_DIR"
touch "$LOG_FILE"

# -------------------------
# Logging Helper Function
# -------------------------
log_action() {
    echo "$(date --iso-8601=seconds): $1" | tee -a "$LOG_FILE"
}

# -------------------------
# Log Rotation
# -------------------------
# Rotate log files if they exceed a certain size
if [[ -f "$LOG_FILE" && $(stat --format=%s "$LOG_FILE") -gt 10485760 ]]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"
    log_action "Log file rotated."
fi

# Ensure the log directory exists
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
    log_action "Log directory $LOG_DIR created."
    echo -e "${YELLOW}Log directory $LOG_DIR created.${NC}"
fi

# -------------------------
# Trap for Cleanup
# -------------------------
trap 'EXIT_CODE=$?; [[ $EXIT_CODE -eq 0 ]] && log_action "Script exited successfully." || log_action "Script exited with error code $EXIT_CODE."' EXIT
trap 'log_action "Script interrupted! Cleaning up..."; exit 1' SIGINT SIGTERM
trap 'log_action "Script encountered an error. Exiting..."; exit 1' ERR

# -------------------------
# Help Menu
# -------------------------
show_help() {
    echo -e "${YELLOW}Usage:${NC} $0 [OPTION]"
    echo "Options:"
    echo "  --help       Show this help message"
    echo "  --menu       Display the interactive menu"
    echo "Environment Variables:"
    echo "  NO_COLOR=1   Disable colored output"
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
    if [[ -f "$RELEASE_FILE" ]]; then
        . "$RELEASE_FILE"
        OS=$ID
        log_action "Detected Linux distribution: $OS"
        echo -e "${GREEN}Detected Linux distribution: $OS${NC}"
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
            log_action "Updating system using apt..."
            apt update || { log_action "Failed to update system using apt."; exit 1; }
            log_action "System updated using apt"
            ;;
        centos|rhel|amazon|cloudlinux|scientific|xcp-ng|xenserver)
            log_action "Updating system using yum..."
            yum update || { log_action "Failed to update system using yum."; exit 1; }
            log_action "System updated using yum"
            ;;
        fedora|rocky|oracle|clear)
            log_action "Updating system using dnf..."
            dnf update || { log_action "Failed to update system using dnf."; exit 1; }
            log_action "System updated using dnf"
            ;;
        opensuse|sles|suse|tumbleweed|leap)
            log_action "Updating system using zypper..."
            zypper refresh && zypper update || { log_action "Failed to update system using zypper."; exit 1; }
            log_action "System updated using zypper"
            ;;
        arcolinux|artix|arch|manjaro|garuda|endeavouros)
            log_action "Updating system using pacman..."
            pacman -Syu || { log_action "Failed to update system using pacman."; exit 1; }
            log_action "System updated using pacman"
            ;;
        alpine)
            log_action "Updating system using apk..."
            apk update || { log_action "Failed to update system using apk."; exit 1; }
            log_action "System updated using apk"
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
            log_action "Upgrading system using apt..."
            apt upgrade -y || { log_action "Failed to upgrade system using apt."; exit 1; }
            log_action "System upgraded using apt"
            ;;
        centos|rhel|amazon|cloudlinux|scientific|xcp-ng|xenserver)
            log_action "Upgrading system using yum..."
            yum upgrade -y || { log_action "Failed to upgrade system using yum."; exit 1; }
            log_action "System upgraded using yum"
            ;;
        fedora|rocky|oracle|clear)
            log_action "Upgrading system using dnf..."
            dnf upgrade -y || { log_action "Failed to upgrade system using dnf."; exit 1; }
            log_action "System upgraded using dnf"
            ;;
        opensuse|sles|suse|tumbleweed|leap)
            log_action "Upgrading system using zypper..."
            zypper update -y || { log_action "Failed to upgrade system using zypper."; exit 1; }
            log_action "System upgraded using zypper"
            ;;
        arcolinux|artix|arch|manjaro|garuda|endeavouros)
            log_action "Upgrading system using pacman..."
            pacman -Syu --noconfirm || { log_action "Failed to upgrade system using pacman."; exit 1; }
            log_action "System upgraded using pacman"
            ;;
        alpine)
            log_action "Upgrading system using apk..."
            apk upgrade -U --no-cache || { log_action "Failed to upgrade system using apk."; exit 1; }
            log_action "System upgraded using apk"
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
    read -rp "Enter the full path of the file or directory you want to back up: " SOURCE_PATH

    if [[ ! -e "$SOURCE_PATH" ]]; then
        log_action "Error: Source path '$SOURCE_PATH' does not exist."
        echo -e "${RED}Error: Source path '$SOURCE_PATH' does not exist.${NC}"
        exit 1
    fi

    BASE_NAME=$(basename "$SOURCE_PATH")
    DATE_TIME=$(date +%Y%m%d_%H%M%S)
    BACKUP_NAME="backup_${BASE_NAME}_${DATE_TIME}.tar.gz"
    BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

    log_action "Creating backup of $SOURCE_PATH at $BACKUP_PATH"
    tar -czvf "$BACKUP_PATH" "$SOURCE_PATH"

    if [ $? -eq 0 ]; then
        log_action "Backup successful: $BACKUP_PATH"
        echo -e "${GREEN}Backup successful: $BACKUP_PATH${NC}"
    else
        log_action "Backup failed for $SOURCE_PATH"
        echo -e "${RED}Backup failed for $SOURCE_PATH${NC}"
        exit 1
    fi
}

# -------------------------
# Navigation Function
# -------------------------
navigate_to() {
    cd "$1" || { log_action "Failed to navigate to $1. Exiting."; exit 1; }
}

# -------------------------
# Confirm Function
# -------------------------
confirm_action() {
    read -rp "$1 (y/n): " CONFIRM
    if [[ "$CONFIRM" != [yY] ]]; then
        log_action "$2"
        echo -e "${YELLOW}$2${NC}"
        return 1
    fi
}

# -------------------------
# Restore Functionality
# -------------------------
restore() {
    navigate_to "$BACKUP_DIR"

    echo "Fetching backup files..."
    mapfile -t BACKUP_FILES < <(find . -maxdepth 1 -name "*.tar.gz" -print)

    if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
        log_action "No backup files found in $BACKUP_DIR. Exiting."
        echo -e "${YELLOW}No backup files found in $BACKUP_DIR. Exiting.${NC}"
        exit 1
    fi

    echo "Select a backup file to restore:"
    for i in "${!BACKUP_FILES[@]}"; do
        echo "$((i + 1))) ${BACKUP_FILES[$i]}"
    done

    read -rp "Enter the number corresponding to your choice: " BACKUP_CHOICE

    if [[ ! $BACKUP_CHOICE =~ ^[0-9]+$ ]] || [ "$BACKUP_CHOICE" -lt 1 ] || [[ "$BACKUP_CHOICE" -gt "${#BACKUP_FILES[@]}" ]]; then
        log_action "Invalid choice: $BACKUP_CHOICE. Exiting."
        echo -e "${RED}Invalid choice: $BACKUP_CHOICE. Exiting.${NC}"
        exit 1
    fi

    # Restore selected backup
    SELECTED="${BACKUP_FILES[$((BACKUP_CHOICE - 1))]}"
    
    read -rp "Enter the full path to restore the backup to: " RESTORE_DIR

    if [[ ! -d "$RESTORE_DIR" ]]; then
        read -rp "Restore directory does not exist. Create it? (y/n): " CREATE_DIR
        if [[ "$CREATE_DIR" == [yY] ]]; then
            mkdir -p "$RESTORE_DIR"
            log_action "Restore directory $RESTORE_DIR created."
        else
            log_action "Restore canceled. Directory $RESTORE_DIR does not exist."
            exit 1
        fi
    fi

    log_action "Restoring backup: $SELECTED"
    
    tar -xzvf "$SELECTED" -C "$RESTORE_DIR"

    if [ $? -eq 0 ]; then
        log_action "Restore successful: $SELECTED"
        echo -e "${GREEN}Restore successful: $SELECTED${NC}"
    else
        log_action "Restore failed for $SELECTED"
        echo -e "${RED}Restore failed for $SELECTED${NC}"
        exit 1
    fi
}

# -------------------------
# Clean Log Files Menu
# -------------------------
clean_log_files() {
    navigate_to "$LOG_DIR"

    echo "Fetching files and directories in /var/log..."
    mapfile -t LOG_FILES < <(find . -type f -name "*.log" -print)

    if [ ${#LOG_FILES[@]} -eq 0 ]; then
        log_action "No files found in /var/log. Exiting."
        echo -e "${YELLOW}No files found in /var/log. Exiting.${NC}"
        return  # Use return instead of exit to allow the script to continue
    fi

    while true; do
        echo "Select an option:"
        echo "1) Clear a specific file or directory"
        echo "2) Remove all log files (*.log) in /var/log"
        echo "3) Exit"

        read -rp "Enter your choice (1-3): " MAIN_CHOICE

        case $MAIN_CHOICE in
            1)
                echo "Select a file or directory to clear:"
                for i in "${!LOG_FILES[@]}"; do
                    echo "$((i + 1))) ${LOG_FILES[$i]}"
                done

                read -rp "Enter the number corresponding to your choice: " LOG_CHOICE

                if [[ ! $LOG_CHOICE =~ ^[0-9]+$ ]] || [ "$LOG_CHOICE" -lt 1 ] || [ "$LOG_CHOICE" -gt "${#LOG_FILES[@]}" ]; then
                    log_action "Invalid choice: $LOG_CHOICE."
                    echo -e "${RED}Invalid choice: $LOG_CHOICE.${NC}"
                    continue  # Return to the menu
                fi

                SELECTED="${LOG_FILES[$((LOG_CHOICE - 1))]}"

                confirm_action "Are you sure you want to clear $SELECTED?" "User chose not to clear $SELECTED. Returning to menu."

                if [ -f "$SELECTED" ]; then
                    log_action "Clearing $SELECTED..."
                    > "$SELECTED"
                    echo "$SELECTED has been cleared."
                elif [ -d "$SELECTED" ]; then
                    log_action "Clearing contents of $SELECTED..."
                    find "$SELECTED" -type f -name "*.log" -exec rm -f {} +
                    echo "Contents of $SELECTED have been cleared."
                else
                    log_action "Error: $SELECTED is not a file or directory."
                    echo -e "${RED}Error: $SELECTED is not a file or directory.${NC}"
                fi
                ;;
            2)
                confirm_action "Are you sure you want to remove all log files (*.log) in /var/log?" "User chose not to remove all log files. Returning to menu."

                log_action "Removing all log files in /var/log..."
                find /var/log -type f -name "*.log" -exec rm -f {} +
                echo -e "${GREEN}All log files in /var/log have been removed.${NC}"
                ;;
            3)
                log_action "Exiting clean log files menu."
                echo "Exiting clean log files menu."
                return  # Exit the function and loop gracefully
                ;;
            *)
                log_action "Invalid choice: $MAIN_CHOICE"
                echo -e "${RED}Invalid choice. Please select a valid option.${NC}"
                ;;
        esac
    done
}

# -------------------------
# Backup/Restore Menu
# -------------------------
backup_restore_menu() {
    while true; do
        echo "Select an option:"
        echo "1) Backup important data"
        echo "2) Restore data from backup"
        echo "3) Exit"

        read -rp "Enter your choice (1-3): " BACKUP_RESTORE_CHOICE

        case $BACKUP_RESTORE_CHOICE in
            1)
                log_action "User selected backup option."
                backup
                echo -e "${GREEN}Backup completed successfully.${NC}"
                ;;
            2)
                log_action "User selected restore option."
                restore
                echo -e "${GREEN}Restore completed successfully.${NC}"
                ;;
            3)
                log_action "Exiting backup/restore menu."
                echo "Exiting backup/restore menu."
                return  # Exit the function and loop gracefully
                ;;
            *)
                log_action "Invalid choice: $BACKUP_RESTORE_CHOICE"
                echo -e "${RED}Invalid choice. Please select a valid option.${NC}"
                ;;
        esac
    done
}

# -------------------------
# Main Menu Execution
# -------------------------

# Prompt the user to select a service
while true; do
    echo "Select the service to proceed: "
    echo "1. Update the system"
    echo "2. Upgrade the system"
    echo "3. Clean log files"
    echo "4. Backup or Restore important data"
    echo "5. Exit"

    # Prompt user for input
    read -rp "Enter your choice (1-5): " CHOICE

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
            clean_log_files
            ;;
        4)
            backup_restore_menu
            ;;
        5)
            log_action "Script exited by user."
            echo "Exiting the script..."
            exit 0
            ;;
        *)
            log_action "Invalid menu choice: $CHOICE"
            echo -e "${RED}Invalid choice. Please select a number between 1-5.${NC}"
            ;;
    esac
done
