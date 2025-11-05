#!/bin/bash
set -e  # Exit on error

# Get actual user
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

print_warning() {
    echo -e "${BLUE}⚠${NC} $1"
}

print_header() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
}

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script with sudo"
    exit 1
fi

print_header "Laravel Stack Uninstaller"
echo -e "${YELLOW}This will remove:${NC}"
echo "  • PHP 8.3 and all extensions"
echo "  • Composer"
echo "  • MySQL server and laravel database"
echo "  • Nginx web server"
echo "  • Laravel project at /var/www/laravel"
echo "  • Supervisor (if installed)"
echo "  • Laravel scheduler cron job"
echo "  • All configuration files"
echo ""
echo -e "${RED}WARNING: This action cannot be undone!${NC}"
echo -e "${RED}All data in the Laravel database will be lost!${NC}"
echo ""

read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_info "Uninstallation cancelled."
    exit 0
fi

echo ""
read -p "Type 'DELETE' to confirm uninstallation: " -r
if [[ $REPLY != "DELETE" ]]; then
    print_info "Uninstallation cancelled."
    exit 0
fi

print_header "Starting Laravel Stack Uninstallation"

# Stop services
print_info "Stopping services..."
systemctl stop nginx 2>/dev/null || true
systemctl stop php8.3-fpm 2>/dev/null || true
systemctl stop mysql 2>/dev/null || true
systemctl stop supervisor 2>/dev/null || true
print_success "Services stopped"

# Remove Laravel scheduler cron job
print_info "Removing Laravel scheduler cron job..."
crontab -u $ACTUAL_USER -l 2>/dev/null | grep -v "artisan schedule:run" | crontab -u $ACTUAL_USER - 2>/dev/null || true
print_success "Cron job removed"

# Remove Supervisor configuration
if [ -f /etc/supervisor/conf.d/laravel-worker.conf ]; then
    print_info "Removing Supervisor Laravel worker configuration..."
    rm -f /etc/supervisor/conf.d/laravel-worker.conf
    supervisorctl reread 2>/dev/null || true
    supervisorctl update 2>/dev/null || true
    print_success "Supervisor configuration removed"
fi

# Remove Laravel project
if [ -d /var/www/laravel ]; then
    print_info "Removing Laravel project directory..."
    rm -rf /var/www/laravel
    print_success "Laravel project removed"
fi

# Remove Nginx configuration
print_info "Removing Nginx configuration..."
rm -f /etc/nginx/sites-available/laravel
rm -f /etc/nginx/sites-enabled/laravel
print_success "Nginx configuration removed"

# Backup and remove MySQL data (optional)
print_info "Removing MySQL laravel database..."
mysql -u root <<EOF 2>/dev/null || true
DROP DATABASE IF EXISTS laravel;
DROP USER IF EXISTS 'laravel'@'localhost';
FLUSH PRIVILEGES;
EOF
print_success "MySQL laravel database and user removed"

# Remove packages
print_header "Removing Packages"

print_info "Removing PHP 8.3 and extensions..."
apt-get remove --purge -y \
    php8.3* \
    php-* 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
print_success "PHP removed"

print_info "Removing Composer..."
rm -f /usr/local/bin/composer
rm -rf $ACTUAL_HOME/.composer
rm -rf $ACTUAL_HOME/.config/composer
print_success "Composer removed"

print_info "Removing Nginx..."
apt-get remove --purge -y nginx nginx-common 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
print_success "Nginx removed"

# Ask about MySQL removal
echo ""
read -p "Do you want to remove MySQL server? (yes/no): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_info "Removing MySQL server..."
    apt-get remove --purge -y mysql-server mysql-client mysql-common 2>/dev/null || true
    apt-get autoremove -y 2>/dev/null || true
    rm -rf /etc/mysql
    rm -rf /var/lib/mysql
    print_success "MySQL removed"
else
    print_info "MySQL kept (only laravel database removed)"
fi

# Ask about Supervisor removal
if command -v supervisorctl &> /dev/null; then
    echo ""
    read -p "Do you want to remove Supervisor? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Removing Supervisor..."
        apt-get remove --purge -y supervisor 2>/dev/null || true
        apt-get autoremove -y 2>/dev/null || true
        print_success "Supervisor removed"
    else
        print_info "Supervisor kept"
    fi
fi

# Remove PHP repository
print_info "Removing PHP repository..."
add-apt-repository --remove ppa:ondrej/php -y > /dev/null 2>&1 || true
print_success "PHP repository removed"

# Clean up
print_info "Cleaning up..."
apt-get autoremove -y > /dev/null 2>&1 || true
apt-get autoclean -y > /dev/null 2>&1 || true
print_success "Cleanup completed"

# Remove credentials file
if [ -f "$ACTUAL_HOME/laravel-credentials.txt" ]; then
    print_info "Removing credentials file..."
    rm -f "$ACTUAL_HOME/laravel-credentials.txt"
    print_success "Credentials file removed"
fi

# Remove .bashrc Composer path entry
if [ -f "$ACTUAL_HOME/.bashrc" ]; then
    sed -i '/composer\/vendor\/bin/d' "$ACTUAL_HOME/.bashrc" 2>/dev/null || true
fi

print_header "Uninstallation Complete!"
print_success "Laravel stack has been completely removed from your system"
echo ""
print_info "Note: Node.js (NVM) was kept as it may be used by other applications"
echo ""
