#!/bin/bash

# This bash script automates basic tasks for a new Linux system like updating, upgrading, cleaning log files, and backing up important data.

# Prompt the user to select the service to run
echo "Select the service to proceed: "
echo "1. Update the system"
echo "2. Upgrade the system"
echo "3. Clean log files"
echo "4. Backup or Restore important data"
echo "5. Exit"

# Prompt user for input
read -p "Enter your choice (1-5): " CHOICE

# Function to detect Linux distro
function detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Unable to detect Linux distribution."
        exit 1
    fi
}

# Function to update the system with the appropriate package manager
function update_with_specific_package_manager() {
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
            echo "Unsupported Linux distribution!"
            ;;
    esac
}

# Function to upgrade the system with the appropriate package manager
function upgrade_with_specific_package_manager() {
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
            echo "Unsupported Linux distribution!"
            ;;
    esac
}

# Update the system
function update() {
    echo "Detecting Linux distribution..."
    detect_linux_distro
    echo "The Linux distribution is: $OS"
    echo "Updating the system..."
    update_with_specific_package_manager
}

# Upgrade the system
function upgrade() {
    echo "Detecting Linux distribution..."
    detect_linux_distro
    echo "The Linux distribution is: $OS"
    echo "Upgrading the system..."
    upgrade_with_specific_package_manager
    clear
    echo "System upgraded successfully!"
}

# Backup
function backup() {
    read -p "Enter the full path of the file or directory you want to back up: " SOURCE_PATH

    if [ ! -e "$SOURCE_PATH" ]; then
        echo "Error: The path '$SOURCE_PATH' does not exist. Exiting."
        exit 1
    fi

    BASE_NAME=$(basename "$SOURCE_PATH")

    BACKUP_DIR="/mnt/backup"

    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Error: The backup directory '$BACKUP_DIR' does not exist. Creating backup directory."
        mkdir -p "$BACKUP_DIR"
    fi

    DATE_TIME=$(date +%Y:%m:%d_%H:%M:%S)
    BACKUP_NAME="backup_${BASE_NAME}_${DATE_TIME}.tar.gz"
    BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

    echo "Backing up '$SOURCE_PATH' to '$BACKUP_PATH'..."
    tar -czvf "$BACKUP_PATH" "$SOURCE_PATH"

    if [ $? -eq 0 ]; then
        echo "Backup successful! File saved at: $BACKUP_PATH"
    else
        echo "Backup failed!"
        exit 1
    fi
}

# Restore
function restore() {
    BACKUP_DIR="/mnt/backup"
    cd "$BACKUP_DIR" || { echo "Failed to navigate to $BACKUP_DIR. Exiting."; exit 1; }

    echo "Fetching backup files..."
    BACKUP_FILES=($(ls -1))

    if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
        echo "No backup files found in $BACKUP_DIR. Exiting."
        exit 1
    fi

    echo "Select a backup file to restore:"
    for i in "${!BACKUP_FILES[@]}"; do
        echo "$((i + 1))) ${BACKUP_FILES[$i]}"
    done

    read -p "Enter the number corresponding to your choice: " BACKUP_CHOICE

    echo "Validating user input..."
    if [[ ! $BACKUP_CHOICE =~ ^[0-9]+$ ]] || [ "$BACKUP_CHOICE" -lt 1 ] || [ "$BACKUP_CHOICE" -gt "${#BACKUP_FILES[@]}" ]; then
        echo "Invalid choice. Exiting."
        exit 1
    fi

    SELECTED="${BACKUP_FILES[$((BACKUP_CHOICE - 1))]}"
    echo "Selected backup file: $SELECTED"

    read -p "Are you sure you want to restore $SELECTED? (y/n): " CONFIRM
    if [[ $CONFIRM != [yY] ]]; then
        echo "Operation canceled."
        exit 0
    fi

    echo "Restoring $SELECTED..."
    tar -xzvf "$SELECTED"

    if [ $? -eq 0 ]; then
        echo "Restore successful!"
    else
        echo "Restore failed!"
        exit 1
    fi
}

# Clean log files
function clean_log_files() {
    echo "Navigating to /var/log directory"
    cd /var/log || { echo "Failed to navigate to /var/log directory. Exiting."; exit 1; }

    echo "Fetching files and directories in /var/log..."
    FILES_AND_FOLDERS=($(ls -1))

    if [ ${#FILES_AND_FOLDERS[@]} -eq 0 ]; then
        echo "No files or folders found in /var/log. Exiting."
        exit 1
    fi

    # Display options to the user
    echo "Select an option:"
    echo "1) Clear a specific file or folder"
    echo "2) Remove all log files (*.log) in /var/log"
    echo "3) Exit"

    read -p "Enter your choice (1-3): " MAIN_CHOICE

    case $MAIN_CHOICE in
        1)
            echo "Select a file or folder to clear:"
            for i in "${!FILES_AND_FOLDERS[@]}"; do
                echo "$((i + 1))) ${FILES_AND_FOLDERS[$i]}"
            done

            read -p "Enter the number corresponding to your choice: " LOGFILE_CHOICE

            echo "Validating user input..."
            if [[ ! $LOGFILE_CHOICE =~ ^[0-9]+$ ]] || [ "$LOGFILE_CHOICE" -lt 1 ] || [ "$LOGFILE_CHOICE" -gt "${#FILES_AND_FOLDERS[@]}" ]]; then
                echo "Invalid choice. Exiting."
                exit 1
            fi

            SELECTED="${FILES_AND_FOLDERS[$((LOGFILE_CHOICE - 1))]}"

            read -p "Are you sure you want to clear $SELECTED? (y/n): " CONFIRM
            if [[ $CONFIRM != [yY] ]]; then
                echo "Operation canceled."
                exit 0
            fi

            if [ -f "$SELECTED" ]; then
                > "$SELECTED"
                echo "File $SELECTED has been cleared."
            elif [ -d "$SELECTED" ]; then
            sudo find "$SELECTED" -type f -name "*.log" -exec rm -f {} +
                echo "Contents of folder $SELECTED have been cleared."
            else
                echo "$SELECTED is neither a file nor a folder. Skipping."
            fi
            ;;
        2)
            read -p "Are you sure you want to remove all *.log files in /var/log? (y/n): " CONFIRM_ALL
            if [[ $CONFIRM_ALL != [yY] ]]; then
                echo "Operation canceled."
                exit 0
            else
                echo "Removing all *.log files in /var/log..."
                sudo find /var/log -type f -name "*.log" -exec rm -f {} +
                echo "All *.log files in /var/log have been removed."
            fi
            ;;
        3)
            echo "Exiting. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Backup important data
function backup/restore() {
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
            exit 0
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Run the selected service
case $CHOICE in
    1)
        update
        ;;
    2)
        upgrade
        ;;
    3)
        clean_log_files
        ;;
    4)
        backup_important_data
        ;;
    5)
        echo "Exiting the script..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a number between 1-5."
        ;;
esac
