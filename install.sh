#!/bin/bash
set -e

echo "=== WordPress + OpenLiteSpeed Installer ==="

# Detect public IP
PUBLIC_IP=$(curl -s ifconfig.me)

# Ask for credentials
read -sp "Enter MySQL root password: " MYSQL_ROOT_PASSWORD && echo
read -p "Enter WordPress DB name: " WORDPRESS_DB_NAME
read -p "Enter WordPress DB user: " WORDPRESS_DB_USER
read -sp "Enter WordPress DB password: " WORDPRESS_DB_PASSWORD && echo
read -sp "Enter OpenLiteSpeed Admin password: " LSWS_ADMIN_PASS && echo
read -p "Enter your domain (e.g. example.com): " DOMAIN_NAME

# Show DNS instructions
echo
echo "👉 Please configure your domain DNS like this:"
echo "   - A record : $DOMAIN_NAME → $PUBLIC_IP"
echo "   - CNAME    : www → $DOMAIN_NAME"
echo
read -p "Press ENTER once DNS records are set to continue..."

# Save into .env
cat > .env <<EOL
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
WORDPRESS_DB_NAME=$WORDPRESS_DB_NAME
WORDPRESS_DB_USER=$WORDPRESS_DB_USER
WORDPRESS_DB_PASSWORD=$WORDPRESS_DB_PASSWORD
LSWS_ADMIN_PASS=$LSWS_ADMIN_PASS
DOMAIN_NAME=$DOMAIN_NAME
PUBLIC_IP=$PUBLIC_IP
EOL

echo "[OK] .env file created."

# Install Docker if missing
if ! command -v docker &> /dev/null; then
    echo "[INFO] Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
fi

# Install Docker Compose plugin if missing
if ! command -v docker compose &> /dev/null; then
    echo "[INFO] Installing docker-compose plugin..."
    sudo apt update && sudo apt install -y docker-compose-plugin
fi

# Run the stack
docker compose up -d

echo
echo "[SUCCESS] WordPress with OpenLiteSpeed is running!"
echo "Visit: http://$DOMAIN_NAME"
echo "OLS Admin Panel: http://$DOMAIN_NAME:7080 (user: admin)"
