#!/bin/bash

# Update package list and upgrade packages
echo "Updating package list and upgrading packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Nginx
echo "Installing Nginx..."
sudo apt-get install nginx -y

# Install PHP and necessary extensions
echo "Installing PHP and SQLite extension..."
sudo apt-get install php-fpm php-sqlite3 unzip -y

# Install htpasswd
echo "Installing htpasswd..."
sudo apt-get install apache2-utils -y

# Install certbot
echo "Installing certbot for Nginx..."
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Download the template Nginx conf
echo "Getting baseline nginx config for new host..."
wget "https://raw.githubusercontent.com/travisnwade/yoft/main/feeling-tracker/nginx/feeling-tracker" -O /tmp/feeling-tracker
mv /tmp/feeling-tracker /etc/nginx/sites-available/feeling-tracker

# Configure Nginx to use PHP Processor
echo "Configuring Nginx to use PHP..."
NGINX_CONF="/etc/nginx/sites-available/feeling-tracker"

# Enable the new site configuration and remove the default
echo "Enabling site configuration..."
sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Set proper permissions for the web directory
echo "Setting permissions for /var/www/html/feeling-tracker..."
sudo mkdir -p /var/www/html/feeling-tracker
sudo chown -R $USER:$USER /var/www/html/feeling-tracker

# Download and unzip the project files directly into /var/www/html/feeling-tracker
echo "Downloading and unzipping the project files..."
wget "https://github.com/travisnwade/yoft/raw/main/feeling-tracker/webroot/zip/feeling-tracker.zip" -O /tmp/feeling-tracker.zip
unzip /tmp/feeling-tracker.zip -d /tmp/feeling-tracker
cp -a /tmp/feeling-tracker/. /var/www/html/feeling-tracker/

# Set permissions for the project directory and files
echo "Setting permissions for project files..."
sudo chown -R www-data:www-data /var/www/html/feeling-tracker
sudo chmod -R 755 /var/www/html/feeling-tracker
sudo chmod 644 /var/www/html/feeling-tracker/php/submissions.db

# Ask user for a username for basic authentication
read -p "Enter a username for basic authentication: " username

# Ask for the password twice to verify
while true; do
    read -sp "Enter a password for basic authentication: " password1
    echo
    read -sp "Confirm the password: " password2
    echo

    if [ "$password1" == "$password2" ]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

# Create .htpasswd file for basic authentication
sudo htpasswd -cb /etc/nginx/.htpasswd $username $password1

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Check if the Nginx configuration test was successful
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed. Please check the error messages above for more details."
    exit 1
fi

# Restart Nginx if the configuration is valid
echo "Restarting Nginx..."
sudo systemctl restart nginx

echo "-------------------------------------------"
echo "Installation complete. Your feeling tracker web server is ready."
echo "You can now visit your feeling tracker at http://localhost or your server's domain or IP address."
echo "-------------------------------------------"
echo "*** FOR YOU TO DO NEXT ***"
echo ""
echo "1.  Update the server_name block to your domain in:"
echo "	  /etc/nginx/sites-available/feeling-tracker"
echo "	  to use your own domain and if you plan on using Certbot (see below)."
echo ""	
echo "2.  Update your firewall rules for 80 and 443 to be allowed (required by certbot)"
echo "	  Example: sudo ufw allow 80,443/tcp && sudo ufw reload"
echo ""
echo "3.  The basic auth user '$username' has been created."
echo ""
echo "    3.a  If you want to change this user, update the .htpasswd file at:"
echo "         /etc/nginx/.htpasswd"
echo ""	
echo "    Then restart the Nginx service."
echo "    sudo systemctl restart nginx.service"
echo ""
echo "4.  For SSL (certbot is already loaded and ready):"
echo "    sudo certbot --nginx -d YOURDOMAIN --agree-tos --no-eff-email -m YOU@YOURDOMAIN.com"
echo "-------------------------------------------"
