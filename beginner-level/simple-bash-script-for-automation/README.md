# **Documentation for "basic-auto" System Management Automation Script**

## **Table of Contents**

1. [Overview](#overview)
2. [Features](#features)
3. [Usage](#usage)
4. [Options in the Interactive Menu](#options-in-the-interactive-menu)
5. [Detailed Functionality](#detailed-functionality)
6. [Configuration](#configuration)
7. [Testing](#testing)
8. [Known Limitations](#known-limitations)
9. [Future Improvements](#future-improvements)
10. [Contributions](#contributions)
11. [License](#license)
12. [Author](#author)

## **Overview**

This script is a comprehensive solution for automating system management tasks, including:

- **Updating and upgrading** the system.
- **Cleaning log files** (selectively or completely clearing log files).
- **Backing up and restoring** data with user interaction and error handling.

The script is designed with modularity, user feedback, logging, error handling, and log rotation. It supports various Linux distributions and can adapt based on the detected package manager.

---

## **Features**

1. **Update and Upgrade System**:
   - Detects the Linux distribution using `/etc/os-release`.
   - Supports package managers like `apt`, `yum`, `dnf`, `zypper`, `pacman`, and `apk`.
   - Provides clear feedback on success or failure.

2. **Log File Management**:
   - Lists `.log` files in `/var/log` for user interaction.
   - Allows selective clearing of specific log files or directories.
   - Includes an option to clear all `.log` files within `/var/log`.

3. **Backup and Restore**:
   - Creates compressed backups of files or directories in `/mnt/backup`.
   - Supports restoration of backups to user-specified locations.
   - Ensures proper validation of paths and user interaction during operations.

4. **Log Rotation**:
   - Rotates the log file (`/var/log/system_automation.log`) if it exceeds 10 MB to prevent uncontrolled growth.

5. **Error Handling and Logging**:
   - Implements robust error handling with traps for script interruptions and logging for every significant action.
   - Logs actions in ISO 8601 format for standardization.

---

## **Usage**

The script supports the following usage modes:

### **Interactive Menu**

Run the script without arguments to access the interactive menu:

```bash
./basic-auto.sh
```

### **Help Option**

Use the `--help` option to display the help menu:

```bash
./basic-auto.sh --help
```

  ![Help Menu](./.img/1.help_menu_interuption.png)

### **Environment Variables**

- `NO_COLOR=1`: Disables colored output in the terminal.

---

## **Options in the Interactive Menu**

1. **Update the System**:
   - Detects the package manager and updates the system's package database.
2. **Upgrade the System**:
   - Upgrades installed packages to their latest versions.
3. **Clean Log Files**:
   - Option to clear a specific log file or directory.
   - Option to clear all log files in `/var/log`.
4. **Backup and Restore Important Data**:
   - Create a backup of any file or directory.
   - Restore a backup to a user-specified location.
5. **Exit**:
   - Gracefully exits the script.

---

## **Detailed Functionality**

### **1. Update and Upgrade System**

- **Functions**:
  - `detect_linux_distro`: Detects the Linux distribution using `/etc/os-release`.
  - `update_with_specific_package_manager`: Performs an update operation based on the detected package manager.
  - `upgrade_with_specific_package_manager`: Performs an upgrade operation based on the detected package manager.

- **Supported Distributions**:
  - **Debian-based**: `apt` (e.g., Ubuntu, Debian).
  - **RHEL-based**: `yum`, `dnf` (e.g., CentOS, Fedora).
  - **OpenSUSE-based**: `zypper`.
  - **Arch-based**: `pacman`.
  - **Alpine-based**: `apk`.

### **2. Log File Management**

- **Functions**:
  - `clean_log_files`: Provides options to clear specific log files or all log files in `/var/log`.
  - Uses `truncate -s 0` to clear files without deleting them.
- **Interactive Steps**:
  - Lists available `.log` files for selection.
  - Prompts for confirmation before clearing files.

### **3. Backup and Restore**

- **Functions**:
  - `backup`: Compresses a specified file or directory into a `.tar.gz` archive in `/mnt/backup`.
  - `restore`: Lists available backups and restores a selected backup to a specified location.
- **Key Features**:
  - Validates paths before backup or restore.
  - Supports interactive selection and confirmation.

### **4. Log Rotation**

- Automatically rotates the main log file (`/var/log/system_automation.log`) if it exceeds 10 MB by renaming it to `system_automation.log.old`.

### **5. Error Handling**

- Uses `trap` to handle:
  - Script exits (`EXIT`).
  - Interrupt signals (`SIGINT`, `SIGTERM`).
  - Errors (`ERR`).
- Logs errors and gracefully exits when encountering issues.

---

## **Configuration**

The script can be customized by modifying the following variables:

- **`BACKUP_DIR`**: Default directory for storing backups (`/mnt/backup`).
- **`LOG_DIR`**: Default directory for managing log files (`/var/log`).
- **`LOG_FILE`**: Log file path (`/var/log/system_automation.log`).

---

## **Testing**

The script has been tested on the following Linux distributions:

- **Ubuntu 24.10**
- **CentOS 9 Stream**
- **Fedora 41**
- **Debian 12**
- **Rocky Linux 9**
- **AlmaLinux 9**

### **Updating and Upgrading the System**

1. Select **1** in the menu to update the system.

    ![Update System Ubuntu](./.img/3.test_update_ubuntu.png)

    ![Update System CentOS](./.img/20.test_update_centos.png)

    ![Update System fedora](./.img/21.test_update_fedora.png)

    ![Update System debian](./.img/22.test_update_debian.png)

    ![Update System rocky](./.img/23.test_update_rocky.png)

    ![Update System almalinux](./.img/24.test_update_almalinux.png)

    These images show the script updating the system on various Linux distributions.

2. Select **2** in the menu to upgrade the system.

    ![Upgrade System Ubuntu](./.img/4.test_upgrade_ubuntu.png)

    The image shows the script upgrading the system on Ubuntu.

### **Cleaning Log Files**

1. Select **3** in the menu.
2. Choose:
   - Option **1** to select and clear a specific log file.

    ![Content of the ./system_automation.log file before cleaning ](./.img/7.content_logfile_before_clean.png)

    ![Selecting and clearing a specific log file](./.img/8.clear_specific_logfile.png)

    ![Content of the ./system_automation.log file after cleaning ](./.img/9.content_logfile_after_clean.png)

    The image shows the script listing log files for selection and clearing. The `system_automation.log` file is cleared in this example.

   - Option **2** to clear all `.log` files in `/var/log`.

   ![Clearing all log files in /var/log](./.img/10.cleared_all_logs.png)

   ![Proved that all log files in /var/log are cleared](./.img/11.prove_of%20_files_cleared.png)

   - Option **3** to return to the main menu.

   ![Return to the main menu](./.img/12.log_menu_exit_option.png)

### **Backing Up and Restoring Data**

1. Select **4** in the menu.
2. Choose:
   - Option **1** to back up a file or directory.

    ![Backing up a file or directory](./.img/13.backup_file.png)

    ![Proved that the file is backed up](./.img/15.backup_file.png)

    The images show the script backing up a file or directory to `/mnt/backup`.

   - Option **2** to restore a backup from `/mnt/backup`.

    ![Restoring a backup from /mnt/backup](./.img/16.restore_file.png)

    ![Proved that the file is restored](./.img/17.restored_file_new_location.png)

    The images show the script restoring a backup from `/mnt/backup` to a specified location.

    - Option **3** to return to the main menu.

    ![Return to the main menu](./.img/19.exit_options_main_and_backup.png)

### **Error Handling and Logging**

- The script logs all actions in `/var/log/system_automation.log` in ISO 8601 format.

    ![Log File Content](./.img/25.logfile.png)

    The image shows the content of the log file after running the script.

- The script handles errors gracefully and logs them for debugging purposes.

    ![Error Handling wrong input on the main menu](./.img/2.wrong_input_main-menu.png)

    ![Error Handling wrong input on the clean log file menu](./.img/5.wrong_input_clear_logfile_menu.png)

    ![Error Handling wrong input on the Selecting and clearing a specific log file](./.img/6.wrong_input_clear_specific_logfile.png)

    ![Error Handling wrong input on the backup source](./.img/14.wrong_input_backup_source.png)

    ![Error Handling wrong input on the restore source](./.img/18.wrong_input_backupfile_restore.png)

    The image shows the script handling an error and logging the details.

---

## **Known Limitations**

1. The script assumes all operations are performed on a Linux system with root privileges.
2. Limited to predefined package managers and file systems.

---

## **Future Improvements**

1. Add support for remote backup and restoration.
2. Implement email notifications for completed operations.
3. Add support for dry-run mode to simulate operations.
4. Add more features like system monitoring and user management.

---

## **Contributions**

Contributions to this script are welcome. You can contribute by:

- Reporting issues.
- Suggesting new features.
- Opening pull requests for bug fixes or enhancements.

---

## **License**

This script is licensed under the [MIT License](../../LICENSE).

---

## **Author**

This script is authored by [Your Name](Hamed Ayodeji aka Qurtana).

---
