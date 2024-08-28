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
    echo "  --help                Display this help message and exit."
    echo
    echo "If no option is provided, the script will display this help message."
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

# Function to refresh the webroot
refresh_webroot() {
    # Clean or create the webroot directory
    echo "Creating or cleaning webroot directory at $WEBROOT_DIR..."
    sudo rm -rf $WEBROOT_DIR  # Remove the directory if it exists
    sudo mkdir -p $WEBROOT_DIR  # Create the directory

    # Unzip the .zip file to the webroot directory
    echo "Unzipping $ZIP_FILE to $WEBROOT_DIR..."
    sudo unzip -o -d $WEBROOT_DIR $ZIP_FILE  # Overwrite files if they exist

    # Preserve the submissions.db file and clear the rest
    echo "Preserving submissions.db and clearing the rest of $WWW_DIR..."
    sudo find $WWW_DIR -mindepth 1 ! -name 'submissions.db' -delete

    # Copy the contents of the refreshed webroot to the www directory
    echo "Copying contents of $WEBROOT_DIR to $WWW_DIR..."
    sudo cp -a $WEBROOT_DIR/. $WWW_DIR/

    # Set proper permissions for the www directory
    echo "Setting permissions for $WWW_DIR..."
    sudo chown -R www-data:www-data $WWW_DIR
    sudo chmod -R 755 $WWW_DIR

    # Restart Nginx
    echo "Restarting Nginx..."
    sudo systemctl restart nginx

    echo "-------------------------------------------"
    echo "Webroot refresh complete."
    echo "-------------------------------------------"
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
    --help)
        show_help
        ;;
    *)
        download_files
        exit 1
        ;;
esac
