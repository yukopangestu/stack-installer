#!/bin/bash
set -e  # Exit on error

# Get environment parameter
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
INSTALL_ENV=${1:-development}

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

print_header "Laravel Stack Installation"
echo "Environment: $INSTALL_ENV"
echo "User: $ACTUAL_USER"
echo "Home: $ACTUAL_HOME"
echo ""

# Environment-specific configuration
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Production mode: OPcache, security hardening, supervisor, queue workers"
    MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24)
    MYSQL_APP_PASSWORD=$(openssl rand -base64 24)
    INSTALL_XDEBUG=false
    INSTALL_OPCACHE=true
    INSTALL_SUPERVISOR=true
else
    print_info "Development mode: Xdebug, Telescope, relaxed security, verbose errors"
    MYSQL_ROOT_PASSWORD="root"
    MYSQL_APP_PASSWORD="laravel"
    INSTALL_XDEBUG=true
    INSTALL_OPCACHE=false
    INSTALL_SUPERVISOR=false
fi

# Update system
print_info "Updating system packages..."
apt-get update -y > /dev/null 2>&1
print_success "System packages updated"

# Install prerequisites
print_header "Installing Prerequisites"
print_info "Installing software-properties-common..."
apt-get install -y software-properties-common curl wget git unzip > /dev/null 2>&1
print_success "Prerequisites installed"

# Add PHP repository (Ondrej PPA for latest PHP)
print_info "Adding PHP repository..."
add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
apt-get update -y > /dev/null 2>&1
print_success "PHP repository added"

# Install PHP 8.3 and extensions
print_header "Installing PHP 8.3"
print_info "Installing PHP and required extensions..."
apt-get install -y \
    php8.3 \
    php8.3-fpm \
    php8.3-cli \
    php8.3-common \
    php8.3-mysql \
    php8.3-zip \
    php8.3-gd \
    php8.3-mbstring \
    php8.3-curl \
    php8.3-xml \
    php8.3-bcmath \
    php8.3-intl \
    php8.3-readline \
    php8.3-tokenizer > /dev/null 2>&1

print_success "PHP 8.3 installed"

# Install environment-specific PHP extensions
if [ "$INSTALL_XDEBUG" = true ]; then
    print_info "Installing Xdebug for development..."
    apt-get install -y php8.3-xdebug > /dev/null 2>&1

    # Configure Xdebug for development
    cat > /etc/php/8.3/mods-available/xdebug.ini << 'EOF'
zend_extension=xdebug.so
xdebug.mode=debug,develop,coverage
xdebug.start_with_request=yes
xdebug.client_host=localhost
xdebug.client_port=9003
xdebug.idekey=VSCODE
EOF
    print_success "Xdebug installed and configured"
fi

if [ "$INSTALL_OPCACHE" = true ]; then
    print_info "Installing OPcache for production..."
    apt-get install -y php8.3-opcache > /dev/null 2>&1

    # Configure OPcache for production
    cat > /etc/php/8.3/mods-available/opcache.ini << 'EOF'
zend_extension=opcache.so
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
opcache.enable_cli=0
opcache.validate_timestamps=0
EOF
    print_success "OPcache installed and configured"
fi

# Verify PHP installation
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2)
print_success "PHP version: $PHP_VERSION"

# Install Composer
print_header "Installing Composer"
print_info "Downloading Composer installer..."
cd /tmp
EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    print_error "Composer installer corrupt"
    rm composer-setup.php
    exit 1
fi

print_info "Installing Composer globally..."
php composer-setup.php --quiet
rm composer-setup.php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

COMPOSER_VERSION=$(composer --version | cut -d " " -f 3)
print_success "Composer version: $COMPOSER_VERSION"

# Install MySQL
print_header "Installing MySQL"
print_info "Installing MySQL server..."

# Preset MySQL root password
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

apt-get install -y mysql-server mysql-client > /dev/null 2>&1
print_success "MySQL installed"

# Start and enable MySQL
systemctl start mysql
systemctl enable mysql > /dev/null 2>&1
print_success "MySQL service started"

# Secure MySQL installation
print_info "Securing MySQL installation..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF > /dev/null 2>&1
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# Create Laravel database and user
print_info "Creating Laravel database and user..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF > /dev/null 2>&1
CREATE DATABASE IF NOT EXISTS laravel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'laravel'@'localhost' IDENTIFIED BY '$MYSQL_APP_PASSWORD';
GRANT ALL PRIVILEGES ON laravel.* TO 'laravel'@'localhost';
FLUSH PRIVILEGES;
EOF

print_success "MySQL configured with laravel database"

# Install Nginx
print_header "Installing Nginx"
print_info "Installing Nginx web server..."
apt-get install -y nginx > /dev/null 2>&1
print_success "Nginx installed"

# Configure Nginx for Laravel
print_info "Configuring Nginx for Laravel..."
cat > /etc/nginx/sites-available/laravel << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name localhost;
    root /var/www/laravel/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

# Remove default Nginx site and enable Laravel site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Test Nginx configuration
nginx -t > /dev/null 2>&1
systemctl restart nginx
systemctl enable nginx > /dev/null 2>&1
print_success "Nginx configured and started"

# Install Node.js via NVM (for Laravel Mix/Vite)
print_header "Installing Node.js via NVM"
if command -v nvm &> /dev/null || [ -f "$ACTUAL_HOME/.nvm/nvm.sh" ]; then
    print_info "NVM already installed, skipping..."
else
    print_info "Installing NVM..."
    su - $ACTUAL_USER -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash" > /dev/null 2>&1
    print_success "NVM installed"
fi

print_info "Installing Node.js LTS..."
su - $ACTUAL_USER -c "source ~/.nvm/nvm.sh && nvm install --lts && nvm use --lts" > /dev/null 2>&1
NODE_VERSION=$(su - $ACTUAL_USER -c "source ~/.nvm/nvm.sh && node --version")
print_success "Node.js version: $NODE_VERSION"

# Install Laravel installer globally
print_header "Installing Laravel Installer"
print_info "Installing Laravel installer via Composer..."
su - $ACTUAL_USER -c "composer global require laravel/installer" > /dev/null 2>&1

# Add Composer global bin to PATH if not already there
if ! grep -q 'composer/vendor/bin' "$ACTUAL_HOME/.bashrc"; then
    echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> "$ACTUAL_HOME/.bashrc"
fi

print_success "Laravel installer installed"

# Create Laravel project directory
print_header "Setting Up Laravel Project Directory"
print_info "Creating /var/www/laravel directory..."
mkdir -p /var/www/laravel
chown -R $ACTUAL_USER:www-data /var/www/laravel
chmod -R 755 /var/www/laravel

# Create a sample Laravel project
print_info "Creating sample Laravel project..."
cd /var/www
su - $ACTUAL_USER -c "cd /var/www && composer create-project laravel/laravel laravel --quiet --no-interaction" > /dev/null 2>&1

# Set proper permissions
chown -R $ACTUAL_USER:www-data /var/www/laravel
chmod -R 775 /var/www/laravel/storage /var/www/laravel/bootstrap/cache

print_success "Sample Laravel project created"

# Configure Laravel environment
print_info "Configuring Laravel .env file..."
cd /var/www/laravel

# Update .env with database credentials
su - $ACTUAL_USER -c "cd /var/www/laravel && sed -i 's/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' .env"
su - $ACTUAL_USER -c "cd /var/www/laravel && sed -i 's/# DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/' .env"
su - $ACTUAL_USER -c "cd /var/www/laravel && sed -i 's/# DB_PORT=3306/DB_PORT=3306/' .env"
su - $ACTUAL_USER -c "cd /var/www/laravel && sed -i 's/# DB_DATABASE=laravel/DB_DATABASE=laravel/' .env"
su - $ACTUAL_USER -c "cd /var/www/laravel && sed -i 's/# DB_USERNAME=root/DB_USERNAME=laravel/' .env"
su - $ACTUAL_USER -c "cd /var/www/laravel && sed -i \"s/# DB_PASSWORD=/DB_PASSWORD=$MYSQL_APP_PASSWORD/\" .env"

# Set APP_ENV
if [ "$INSTALL_ENV" = "production" ]; then
    su - $ACTUAL_USER -c "cd /var/www/laravel && sed -i 's/APP_ENV=local/APP_ENV=production/' .env"
    su - $ACTUAL_USER -c "cd /var/www/laravel && sed -i 's/APP_DEBUG=true/APP_DEBUG=false/' .env"
fi

# Generate application key
su - $ACTUAL_USER -c "cd /var/www/laravel && php artisan key:generate" > /dev/null 2>&1
print_success "Laravel environment configured"

# Install Supervisor for production queue workers
if [ "$INSTALL_SUPERVISOR" = true ]; then
    print_header "Installing Supervisor"
    print_info "Installing Supervisor for queue management..."
    apt-get install -y supervisor > /dev/null 2>&1

    # Create Supervisor configuration for Laravel queue worker
    cat > /etc/supervisor/conf.d/laravel-worker.conf << EOF
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/laravel/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=$ACTUAL_USER
numprocs=1
redirect_stderr=true
stdout_logfile=/var/www/laravel/storage/logs/worker.log
stopwaitsecs=3600
EOF

    supervisorctl reread > /dev/null 2>&1
    supervisorctl update > /dev/null 2>&1
    systemctl enable supervisor > /dev/null 2>&1
    systemctl start supervisor
    print_success "Supervisor installed and configured"
fi

# Set up Laravel scheduler cron job for production
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Setting up Laravel scheduler cron job..."
    (crontab -u $ACTUAL_USER -l 2>/dev/null; echo "* * * * * cd /var/www/laravel && php artisan schedule:run >> /dev/null 2>&1") | crontab -u $ACTUAL_USER -
    print_success "Laravel scheduler cron job configured"
fi

# Save credentials for production
if [ "$INSTALL_ENV" = "production" ]; then
    CREDS_FILE="$ACTUAL_HOME/laravel-credentials.txt"
    cat > "$CREDS_FILE" << EOF
Laravel Stack Credentials
==========================

MySQL Root User:
  Username: root
  Password: $MYSQL_ROOT_PASSWORD

MySQL Laravel Database:
  Database: laravel
  Username: laravel
  Password: $MYSQL_APP_PASSWORD
  Host: localhost

Laravel Application:
  Location: /var/www/laravel
  URL: http://localhost
  Environment: production

IMPORTANT:
- Update your domain in Nginx configuration: /etc/nginx/sites-available/laravel
- Set up SSL/TLS with Let's Encrypt or Certbot
- Configure email settings in .env
- Set up Redis for caching and sessions
- Review security headers in Nginx config
- Enable firewall rules (ufw)
- Set up regular database backups
- Monitor supervisor queue workers

Created: $(date)
EOF
    chown $ACTUAL_USER:$ACTUAL_USER "$CREDS_FILE"
    chmod 600 "$CREDS_FILE"
    print_warning "Production credentials saved to: $CREDS_FILE"
fi

# Installation summary
print_header "Installation Complete!"

echo -e "${GREEN}Components Installed:${NC}"
echo "  • PHP $PHP_VERSION"
echo "  • Composer $COMPOSER_VERSION"
echo "  • MySQL $(mysql --version | cut -d " " -f 6 | cut -d "," -f 1)"
echo "  • Nginx $(nginx -v 2>&1 | cut -d "/" -f 2)"
echo "  • Node.js $NODE_VERSION"
echo "  • Laravel $(su - $ACTUAL_USER -c 'cd /var/www/laravel && php artisan --version' | cut -d " " -f 3)"
if [ "$INSTALL_SUPERVISOR" = true ]; then
    echo "  • Supervisor (queue worker management)"
fi
echo ""

echo -e "${GREEN}PHP Extensions Installed:${NC}"
php -m | grep -E "mbstring|xml|bcmath|curl|gd|mysql|zip|intl|tokenizer" | sed 's/^/  • /'
if [ "$INSTALL_XDEBUG" = true ]; then
    echo "  • Xdebug (development)"
fi
if [ "$INSTALL_OPCACHE" = true ]; then
    echo "  • OPcache (production)"
fi
echo ""

echo -e "${GREEN}Service Status:${NC}"
for service in php8.3-fpm mysql nginx; do
    if systemctl is-active --quiet $service; then
        print_success "$service is running"
    else
        print_error "$service is not running"
    fi
done
if [ "$INSTALL_SUPERVISOR" = true ]; then
    if systemctl is-active --quiet supervisor; then
        print_success "supervisor is running"
    else
        print_error "supervisor is not running"
    fi
fi
echo ""

echo -e "${GREEN}Laravel Application:${NC}"
echo "  • Project Location: /var/www/laravel"
echo "  • Public URL: http://localhost"
echo "  • Environment: $INSTALL_ENV"
echo "  • Database: laravel (MySQL)"
if [ "$INSTALL_ENV" = "development" ]; then
    echo "  • DB Credentials: laravel / laravel"
else
    echo "  • DB Credentials: (saved in $ACTUAL_HOME/laravel-credentials.txt)"
fi
echo ""

echo -e "${GREEN}Configuration Files:${NC}"
echo "  • Nginx Config: /etc/nginx/sites-available/laravel"
echo "  • PHP-FPM Config: /etc/php/8.3/fpm/php.ini"
echo "  • Laravel .env: /var/www/laravel/.env"
echo "  • MySQL Config: /etc/mysql/mysql.conf.d/mysqld.cnf"
if [ "$INSTALL_SUPERVISOR" = true ]; then
    echo "  • Supervisor Config: /etc/supervisor/conf.d/laravel-worker.conf"
fi
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Access your Laravel app at http://localhost"
echo "  2. Start building your application in /var/www/laravel"
echo "  3. Run migrations: cd /var/www/laravel && php artisan migrate"
echo "  4. Install frontend dependencies: cd /var/www/laravel && npm install"
echo "  5. Build frontend assets: npm run dev (development) or npm run build (production)"
if [ "$INSTALL_ENV" = "production" ]; then
    echo "  6. Configure your domain in /etc/nginx/sites-available/laravel"
    echo "  7. Set up SSL with: sudo certbot --nginx -d yourdomain.com"
    echo "  8. Configure email settings in .env (MAIL_* variables)"
    echo "  9. Set up Redis for caching: php artisan cache:clear"
    echo "  10. Monitor queue workers: sudo supervisorctl status"
fi
echo ""

echo -e "${YELLOW}Useful Commands:${NC}"
echo "  • php artisan serve              - Start development server"
echo "  • php artisan migrate            - Run database migrations"
echo "  • php artisan make:controller    - Create controller"
echo "  • php artisan make:model         - Create model"
echo "  • php artisan route:list         - List all routes"
echo "  • php artisan tinker             - Interactive shell"
echo "  • composer install               - Install PHP dependencies"
echo "  • npm run dev                    - Compile assets (development)"
echo "  • npm run build                  - Build assets (production)"
if [ "$INSTALL_SUPERVISOR" = true ]; then
    echo "  • sudo supervisorctl restart laravel-worker:* - Restart queue workers"
fi
echo ""

if [ "$INSTALL_ENV" = "production" ]; then
    echo -e "${BLUE}Production Security Reminders:${NC}"
    echo "  • Update Nginx config with your domain"
    echo "  • Install SSL certificate (certbot)"
    echo "  • Configure firewall: sudo ufw allow 80,443/tcp"
    echo "  • Set up regular database backups"
    echo "  • Enable Redis for session/cache"
    echo "  • Configure proper logging and monitoring"
    echo "  • Review and update .env security settings"
    echo "  • Set up application monitoring (e.g., Sentry)"
    echo "  • Disable directory listing in Nginx"
    echo "  • Keep all dependencies updated"
    echo ""
fi

print_success "Laravel stack installation completed successfully!"
echo ""
print_info "Reload your shell to use Laravel commands: source ~/.bashrc"
