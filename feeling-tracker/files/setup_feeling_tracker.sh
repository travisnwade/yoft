#!/bin/bash

# Define directories
TARGET_DIR="/opt/feeling-tracker"
WEBROOT_DIR="$TARGET_DIR/feeling-tracker-webroot"
WWW_DIR="/var/www/html/feeling-tracker"
ZIP_FILE="$TARGET_DIR/feeling-tracker.zip"
INSTALL_SCRIPT="$TARGET_DIR/install_web_server_nginx.sh"
UNINSTALL_SCRIPT="$TARGET_DIR/uninstall_web_server_nginx.sh"
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/travisnwade/yoft/main/feeling-tracker/files/install_web_server_nginx.sh"
UNINSTALL_SCRIPT_URL="https://raw.githubusercontent.com/travisnwade/yoft/main/feeling-tracker/files/uninstall_web_server_nginx.sh"
DB_FILE="$WWW_DIR/php/submissions.db"
BACKUP_DIR="/opt/feeling-tracker/db_backups"

# Function to display help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo "Manage the installation and maintenance of the Feeling Tracker web server."
    echo
    echo "Options:"
    echo "  --download-only       Download the necessary files to /opt/feeling-tracker without performing"
    echo "                        any other operations."
    echo "  --refresh-webroot     Refresh the webroot directory with the contents of the ZIP file,"
    echo "                        preserving the submissions.db file, and restarting Nginx."
    echo "  --install             Run the install script to set up the web server. The script"
    echo "                        will be downloaded if it is not present in /opt/feeling-tracker/."
    echo "  --uninstall           Run the uninstall script to remove the web server. The script"
    echo "                        will be downloaded if it is not present in /opt/feeling-tracker/."
    echo "  --backup-db           Backup the submissions.db file to /opt/feeling-tracker/db_backups/"
    echo "                        with a timestamped filename."
    echo "  --restore-db          Restore the submissions.db file from a specified backup in"
    echo "                        /opt/feeling-tracker/db_backups/."
    echo "  --help                Display this help message and exit."
    echo
    echo "If no option is provided, the script will perform the --download-only argument."
    exit 0
}

# Function to download files
download_files() {
    # Create or clean the target directory
    echo "Creating or cleaning directory at $TARGET_DIR..."
    sudo rm -rf $TARGET_DIR  # Remove the directory if it exists
    sudo mkdir -p $TARGET_DIR  # Create the directory

    # Define URLs for the files to be downloaded
    FILES=(
        "https://raw.githubusercontent.com/travisnwade/yoft/main/feeling-tracker/nginx/feeling-tracker"
        "https://github.com/travisnwade/yoft/raw/main/feeling-tracker/webroot/zip/feeling-tracker.zip"
        "https://raw.githubusercontent.com/travisnwade/yoft/main/feeling-tracker/files/install_web_server_nginx.sh"
        "https://raw.githubusercontent.com/travisnwade/yoft/main/feeling-tracker/files/uninstall_web_server_nginx.sh"
    )

    # Download each file into the target directory, overwriting any existing files
    echo "Downloading files to $TARGET_DIR..."
    for FILE_URL in "${FILES[@]}"; do
        sudo wget -O $TARGET_DIR/$(basename $FILE_URL) $FILE_URL
    done

    # Make the .sh files executable
    echo "Making .sh files executable..."
    sudo chmod +x $TARGET_DIR/*.sh

    echo "-------------------------------------------"
    echo "Download complete."
    echo "Files downloaded to $TARGET_DIR"
    echo "-------------------------------------------"
}

refresh_webroot() {

    # Step 1: Backup the database before refreshing the webroot
    echo "Backing up the database before refreshing the webroot..."
    backup_db

    # Step 2: Clean or create the webroot directory
    echo "Creating or cleaning webroot directory at $WEBROOT_DIR..."
    sudo rm -rf $WEBROOT_DIR  # Remove the directory if it exists
    sudo mkdir -p $WEBROOT_DIR  # Create the directory

    # Step 3: Unzip the .zip file to the webroot directory
    echo "Unzipping $ZIP_FILE to $WEBROOT_DIR..."
    sudo unzip -o -d $WEBROOT_DIR $ZIP_FILE  # Overwrite files if they exist

    # Step 4: Copy the contents of the refreshed webroot to the www directory
    echo "Copying contents of $WEBROOT_DIR to $WWW_DIR..."
    sudo cp -a $WEBROOT_DIR/. $WWW_DIR/

    # Step 5: Set proper permissions for the www directory
    echo "Setting permissions for $WWW_DIR..."
    sudo chown -R www-data:www-data $WWW_DIR
    sudo chmod -R 755 $WWW_DIR

    # Step 6: Restart Nginx
    echo "Restarting Nginx..."
    sudo systemctl restart nginx

    echo "-------------------------------------------"
    echo "Webroot refresh complete."
    echo "-------------------------------------------"

    # Step 7: Restore the latest database backup after refreshing the webroot
    echo "Restoring the latest database backup..."
    restore_db_latest
}

# Function to restore the latest database backup
restore_db_latest() {
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -n 1)  # Get the latest backup file

    if [ -n "$LATEST_BACKUP" ]; then
        FULL_BACKUP_PATH="$BACKUP_DIR/$LATEST_BACKUP"
        echo "Restoring from the latest backup: $FULL_BACKUP_PATH"
        sudo cp "$FULL_BACKUP_PATH" "$DB_FILE"

        if [ $? -eq 0 ]; then
            echo "Restore successful: $DB_FILE"
        else
            echo "Restore failed!"
        fi
    else
        echo "No backup files found to restore."
    fi
}

# Function to run the install script
run_install_script() {
    # Check if the install script exists
    if [ ! -f "$INSTALL_SCRIPT" ]; then
        echo "Install script not found at $INSTALL_SCRIPT. Downloading it..."
        sudo wget -O $INSTALL_SCRIPT $INSTALL_SCRIPT_URL
        sudo chmod +x $INSTALL_SCRIPT  # Make the script executable after downloading
    fi

    echo "Running install script: $INSTALL_SCRIPT..."
    sudo bash "$INSTALL_SCRIPT"
}

# Function to run the uninstall script
run_uninstall_script() {
    # Check if the uninstall script exists
    if [ ! -f "$UNINSTALL_SCRIPT" ]; then
        echo "Uninstall script not found at $UNINSTALL_SCRIPT. Downloading it..."
        sudo wget -O $UNINSTALL_SCRIPT $UNINSTALL_SCRIPT_URL
        sudo chmod +x $UNINSTALL_SCRIPT  # Make the script executable after downloading
    fi

    echo "Running uninstall script: $UNINSTALL_SCRIPT..."
    sudo bash "$UNINSTALL_SCRIPT"
}

# Function to backup the database
backup_db() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUP_DIR/submissions_$TIMESTAMP.db"

    # Ensure the backup directory exists
    sudo mkdir -p "$BACKUP_DIR"

    # Copy the database file to the backup directory
    sudo cp "$DB_FILE" "$BACKUP_FILE"

    # Check if the copy was successful
    if [ $? -eq 0 ]; then
        echo "Backup successful: $BACKUP_FILE"
    else
        echo "Backup failed!"
    fi
}

# Function to restore the database
restore_db() {
    echo "Available backups:"
    echo "-------------------------------------------"
    ls "$BACKUP_DIR" | nl
    echo "-------------------------------------------"
    read -p "Enter the number of the backup file to restore: " BACKUP_NUMBER

    BACKUP_FILE=$(ls "$BACKUP_DIR" | sed -n "${BACKUP_NUMBER}p")

    FULL_BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

    # Check if the backup file exists
    if [ -f "$FULL_BACKUP_PATH" ]; then
        # Copy the backup file to the database location
        echo "Restoring from the backup: $FULL_BACKUP_PATH"
        sudo cp "$FULL_BACKUP_PATH" "$DB_FILE"

        # Check if the restore was successful
        if [ $? -eq 0 ]; then
            echo "Restore successful: $DB_FILE"
        else
            echo "Restore failed!"
        fi
    else
        echo "Backup file not found: $FULL_BACKUP_PATH"
    fi
}

# Handle command line switches
case "$1" in
    --download-only)
        download_files
        exit 0
        ;;
    --refresh-webroot)
        refresh_webroot
        exit 0
        ;;
    --install)
        run_install_script
        exit 0
        ;;
    --uninstall)
        run_uninstall_script
        exit 0
        ;;
    --backup-db)
        backup_db
        exit 0
        ;;
    --restore-db)
        restore_db
        exit 0
        ;;
    --help)
        show_help
        ;;
    *)
        download_files
        exit 1
        ;;
esac
