#!/bin/bash

# Stop Nginx service
echo "Stopping Nginx service..."
sudo systemctl stop nginx

# Remove Nginx and PHP packages
echo "Uninstalling Nginx and PHP..."
sudo apt-get remove --purge nginx php-fpm php-sqlite3 apache2-utils -y

# Remove Nginx configuration for the site
echo "Removing Nginx site configuration..."
sudo rm /etc/nginx/sites-available/yoft
sudo rm /etc/nginx/sites-available/yoft

# Remove the project directory and its contents
echo "Removing project directory and files..."
sudo rm -rf /var/www/html/yoft

# Remove Certbot
echo "Removing Certbot and Core..."
sudo snap remove certbot
sudo snap remove core

# Remove any remaining dependencies and clean up
echo "Cleaning up unused dependencies and package cache..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# Remove temporary files
echo "Removing temporary files..."
sudo rm -rf /tmp/yoft.zip /tmp/yoft

# Check if any residual configuration files need to be removed
echo "Checking for residual configuration files..."
sudo dpkg -l | grep -e nginx -e php -e sqlite

echo "Uninstallation and cleanup complete."