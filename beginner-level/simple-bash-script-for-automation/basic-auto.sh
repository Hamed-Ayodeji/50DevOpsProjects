#!/bin/bash

# Bash script to automate basic Linux system tasks such as updating, upgrading,
# cleaning log files, and managing backups (backup/restore).

# Prompt the user to select a service
echo "Select the service to proceed: "
echo "1. Update the system"
echo "2. Upgrade the system"
echo "3. Clean log files"
echo "4. Backup or Restore important data"
echo "5. Exit"

# Prompt user for input
read -p "Enter your choice (1-5): " CHOICE

# -------------------------
# Detect Linux Distribution
# -------------------------
function detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
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
            sudo apt update
            ;;
        centos|rhel|amazon|cloudlinux|scientific|xcp-ng|xenserver)
            sudo yum update
            ;;
        fedora|rocky|oracle|clear)
            sudo dnf update
            ;;
        opensuse|sles|suse|tumbleweed|leap)
            sudo zypper refresh && sudo zypper update
            ;;
        arcolinux|artix|arch|manjaro|garuda|endeavouros)
            sudo pacman -Syu
            ;;
        alpine)
            sudo apk update
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
            sudo apt upgrade -y
            ;;
        centos|rhel|amazon|cloudlinux|scientific|xcp-ng|xenserver)
            sudo yum upgrade -y
            ;;
        fedora|rocky|oracle|clear)
            sudo dnf upgrade -y
            ;;
        opensuse|sles|suse|tumbleweed|leap)
            sudo zypper update -y
            ;;
        arcolinux|artix|arch|manjaro|garuda|endeavouros)
            sudo pacman -Syu --noconfirm
            ;;
        alpine)
            sudo apk upgrade -y
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
function backup() {
    # Prompt for file or directory to back up
    read -p "Enter the full path of the file or directory you want to back up: " SOURCE_PATH

    # Verify the file/directory exists
    if [ ! -e "$SOURCE_PATH" ]; then
        echo "Error: The path '$SOURCE_PATH' does not exist. Exiting."
        exit 1
    fi

    BASE_NAME=$(basename "$SOURCE_PATH")
    BACKUP_DIR="/mnt/backup"
    mkdir -p "$BACKUP_DIR"  # Create backup directory if it doesn't exist
    DATE_TIME=$(date +%Y%m%d_%H%M%S)
    BACKUP_NAME="backup_${BASE_NAME}_${DATE_TIME}.tar.gz"
    BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

    # Perform the backup
    echo "Backing up '$SOURCE_PATH' to '$BACKUP_PATH'..."
    tar -czvf "$BACKUP_PATH" "$SOURCE_PATH"

    if [ $? -eq 0 ]; then
        echo "Backup successful! File saved at: $BACKUP_PATH"
    else
        echo "Backup failed!"
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
        exit 0
    fi
}

# -------------------------
# Restore Functionality
# -------------------------
function restore() {
    BACKUP_DIR="/mnt/backup"
    cd "$BACKUP_DIR" || { echo "Failed to navigate to $BACKUP_DIR. Exiting."; exit 1; }

    echo "Fetching backup files..."
    mapfile -t BACKUP_FILES < <(find . -maxdepth 1 -name "*.tar.gz" -print)

    if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
        echo "No backup files found in $BACKUP_DIR. Exiting."
        exit 1
    fi

    echo "Select a backup file to restore:"
    for i in "${!BACKUP_FILES[@]}"; do
        echo "$((i + 1))) ${BACKUP_FILES[$i]}"
    done

    read -rp "Enter the number corresponding to your choice: " BACKUP_CHOICE

    # Validate input
    if [[ ! $BACKUP_CHOICE =~ ^[0-9]+$ ]] || [ "$BACKUP_CHOICE" -lt 1 ] || [ "$BACKUP_CHOICE" -gt "${#BACKUP_FILES[@]}" ]]; then
        echo "Invalid choice. Exiting."
        exit 1
    fi

    SELECTED="${BACKUP_FILES[$((BACKUP_CHOICE - 1))]}"
    echo "Restoring $SELECTED..."
    tar -xzvf "$SELECTED"

    if [ $? -eq 0 ]; then
        echo "Restore successful!"
    else
        echo "Restore failed!"
        exit 1
    fi
}

# -------------------------
# Clean Log Files
# -------------------------
function clean_log_files() {
    echo "Navigating to /var/log directory"
    cd /var/log || { echo "Failed to navigate to /var/log directory. Exiting."; exit 1; }

    # Display options to clean logs
    echo "Select an option:"
    echo "1) Clear a specific file or folder"
    echo "2) Remove all log files (*.log)"
    echo "3) Exit"

    read -p "Enter your choice (1-3): " MAIN_CHOICE

    case $MAIN_CHOICE in
        1)
            # Logic to clear a specific file or folder
            ;;
        2)
            echo "Removing all *.log files..."
            sudo find /var/log -type f -name "*.log" -exec rm -f {} +
            echo "All *.log files have been removed."
            ;;
        3)
            echo "Exiting. Goodbye!"
            ;;
        *)
            echo "Invalid choice. Exiting."
            ;;
    esac
}

# -------------------------
# Backup/Restore Menu
# -------------------------
function backup_restore_menu() {
    echo "Select an option:"
    echo "1) Backup important data"
    echo "2) Restore important data"
    echo "3) Exit"

    read -p "Enter your choice (1-3): " BACKUP_RESTORE_CHOICE

    case $BACKUP_RESTORE_CHOICE in
        1)
            backup
            ;;
        2)
            restore
            ;;
        3)
            echo "Exiting. Goodbye!"
            ;;
        *)
            echo "Invalid choice. Exiting."
            ;;
    esac
}

# -------------------------
# Main Menu Execution
# -------------------------
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
