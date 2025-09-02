#!/bin/bash
set -e

# ──────────────────────────────────────────────
#  Color functions
# ──────────────────────────────────────────────
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
MAGENTA=$(tput setaf 5)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echoC() { echo -e "${CYAN}$1${RESET}"; }
echoG() { echo -e "${GREEN}$1${RESET}"; }
echoY() { echo -e "${YELLOW}$1${RESET}"; }
echoR() { echo -e "${RED}$1${RESET}"; }

# ──────────────────────────────────────────────
#  Branding Header
# ──────────────────────────────────────────────
function show_banner() {
cat << "EOF"

██████╗ ██████╗  ██████╗      ██████╗██╗      ██████╗ ██╗   ██╗██████╗ ██╗███████╗██╗   ██╗
██╔══██╗██╔══██╗██╔═══██╗    ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗██║██╔════╝╚██╗ ██╔╝
██████╔╝██████╔╝██║   ██║    ██║     ██║     ██║   ██║██║   ██║██║  ██║██║█████╗   ╚████╔╝ 
██╔═══╝ ██╔══██╗██║   ██║    ██║     ██║     ██║   ██║██║   ██║██║  ██║██║██╔══╝    ╚██╔╝  
██║     ██║  ██║╚██████╔╝    ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝██║██║        ██║   
╚═╝     ╚═╝  ╚═╝ ╚═════╝      ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚═╝╚═╝        ╚═╝   
                                                                                           
                                                    
                🚀 WordPress + OpenLiteSpeed Auto Installer
                          Powered by PRO CLOUDIFY
EOF
}

# ──────────────────────────────────────────────
#  Main Installer
# ──────────────────────────────────────────────
show_banner

PUBLIC_IP=$(curl -s ifconfig.me)

echoY "Enter MySQL root password:"
read -s MYSQL_ROOT_PASSWORD
echo
read -p "Enter WordPress DB name [wordpress]: " WORDPRESS_DB_NAME
WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME:-wordpress}
read -p "Enter WordPress DB user [wpuser]: " WORDPRESS_DB_USER
WORDPRESS_DB_USER=${WORDPRESS_DB_USER:-wpuser}
echoY "Enter WordPress DB password:"
read -s WORDPRESS_DB_PASSWORD
echo
echoY "Enter OpenLiteSpeed Admin password:"
read -s LSWS_ADMIN_PASS
echo
read -p "Enter your domain (e.g. example.com): " DOMAIN_NAME

cat > .env <<EOL
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
WORDPRESS_DB_NAME=$WORDPRESS_DB_NAME
WORDPRESS_DB_USER=$WORDPRESS_DB_USER
WORDPRESS_DB_PASSWORD=$WORDPRESS_DB_PASSWORD
LSWS_ADMIN_PASS=$LSWS_ADMIN_PASS
DOMAIN_NAME=$DOMAIN_NAME
PUBLIC_IP=$PUBLIC_IP
EOL

echoG "[OK] .env file created."

# Install Docker if missing
if ! command -v docker &> /dev/null; then
    echoY "[INFO] Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
fi

# Install Docker Compose plugin if missing
if ! command -v docker compose &> /dev/null; then
    echoY "[INFO] Installing docker-compose plugin..."
    sudo apt update && sudo apt install -y docker-compose-plugin
fi

# Run stack
docker compose up -d

# ──────────────────────────────────────────────
#  Final Summary
# ──────────────────────────────────────────────
echo
echoC "───────────────────────────────────────────────"
echoC "          ✅ INSTALLATION COMPLETE!            "
echoC "───────────────────────────────────────────────"
echoG "🌍 Your Website:       http://${DOMAIN_NAME}"
echoG "🔑 WP Admin:           http://${DOMAIN_NAME}/wp-admin/"
echoG "   Username:           admin (set during WP setup)"
echoG "   Password:           (the one you choose at setup)"
echo
echoY "⚙️  OpenLiteSpeed Admin Console:"
echoY "   URL:                http://${DOMAIN_NAME}:7080"
echoY "   Username:           admin"
echoY "   Password:           ${LSWS_ADMIN_PASS}"
echo
echoC "👉 DNS Setup Reminder:"
echo "   • A record   : ${DOMAIN_NAME} → ${PUBLIC_IP}"
echo "   • CNAME      : www → ${DOMAIN_NAME}"
echo
echoM="═══════════════════════════════════════════════"
echo
echoG "🎉 Powered by PRO CLOUDIFY — Enjoy your WordPress hosting!"
echo
