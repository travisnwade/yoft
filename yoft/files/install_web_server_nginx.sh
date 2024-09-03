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
wget "https://raw.githubusercontent.com/travisnwade/yoft/main/yoft/nginx/yoft" -O /tmp/yoft
mv /tmp/yoft /etc/nginx/sites-available/yoft

# Configure Nginx to use PHP Processor
echo "Configuring Nginx to use PHP..."
NGINX_CONF="/etc/nginx/sites-available/yoft"

# Enable the new site configuration and remove the default
echo "Enabling site configuration..."
sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Set proper permissions for the web directory
echo "Setting permissions for /var/www/html/yoft..."
sudo mkdir -p /var/www/html/yoft
sudo chown -R $USER:$USER /var/www/html/yoft

# Download and unzip the YOFT files directly into /var/www/html/yoft
echo "Downloading and unzipping the YOFT files..."
wget "https://github.com/travisnwade/yoft/raw/main/yoft/webroot/zip/yoft.zip" -O /tmp/yoft.zip
unzip /tmp/yoft.zip -d /tmp/yoft
cp -a /tmp/yoft/. /var/www/html/yoft/

# Set permissions for the YOFT directory and files
echo "Setting permissions for YOFT files..."
sudo chown -R www-data:www-data /var/www/html/yoft
sudo chmod -R 755 /var/www/html/yoft
sudo chmod 644 /var/www/html/yoft/php/submissions.db

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
echo "Installation complete. The YOFT web server is ready."
echo "You can now visit your YOFT instance at http://localhost or your server's domain or IP address."
echo "-------------------------------------------"
echo "*** FOR YOU TO DO NEXT ***"
echo ""
echo "1.  Update the server_name block to your domain in:"
echo "	  /etc/nginx/sites-available/yoft"
echo "	  to use your own domain and if you plan on using Certbot (see below)."
echo ""	
echo "2.  Update your firewall rules for 80 and 443 to be allowed (required by certbot)"
echo ""
echo "3.  The basic auth user '$username' has been created."
echo "    Use these credentials to log into your instance of YOFT."
echo ""
echo "4.  For SSL (certbot is already loaded and ready):"
echo "    sudo certbot --nginx -d YOURDOMAIN --agree-tos --no-eff-email -m YOU@YOURDOMAIN.com"
echo ""
echo "For more information, visit go.twade.io/yoft"
echo "-------------------------------------------"
