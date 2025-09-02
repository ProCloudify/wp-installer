#!/bin/bash
set -e

echo "=== WordPress + OpenLiteSpeed Installer ==="

# Detect server public IP
PUBLIC_IP=$(curl -s ifconfig.me)

# Ask for credentials
read -sp "Enter MySQL root password: " MYSQL_ROOT_PASSWORD && echo
read -p "Enter WordPress DB name [wordpress]: " WORDPRESS_DB_NAME
WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME:-wordpress}
read -p "Enter WordPress DB user [wpuser]: " WORDPRESS_DB_USER
WORDPRESS_DB_USER=${WORDPRESS_DB_USER:-wpuser}
read -sp "Enter WordPress DB password: " WORDPRESS_DB_PASSWORD && echo
read -sp "Enter OpenLiteSpeed Admin password: " LSWS_ADMIN_PASS && echo
read -p "Enter your domain (e.g. example.com): " DOMAIN_NAME

# Save into .env file
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
echo "============================================"
echo "✅ WordPress + OpenLiteSpeed setup complete!"
echo
echo "👉 Next steps:"
echo "   - Add the following DNS records:"
echo "     • A record   : $DOMAIN_NAME → $PUBLIC_IP"
echo "     • CNAME      : www → $DOMAIN_NAME"
echo
echo "🌍 Your site will be available at:"
echo "   http://$DOMAIN_NAME"
echo
echo "🔑 OpenLiteSpeed Admin Panel:"
echo "   http://$DOMAIN_NAME:7080"
echo "   Username: admin"
echo "   Password: (the one you entered earlier)"
echo "============================================"
