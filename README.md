# Stack Installer

Automated installation scripts for popular development stacks on Linux systems.

## Overview

This repository contains bash scripts to quickly set up and remove various development environments. Simply run the main installer to choose a stack to install, or run the uninstaller to safely remove installed stacks.

## Features

- Interactive menu-based installation and uninstallation
- **Environment selection** (Development vs Production)
- Automated dependency management
- Latest package versions
- NVM for Node.js version management
- Production-ready security configurations
- MongoDB authentication for production
- PM2 process manager for production deployments
- Color-coded output for better readability
- Error handling and verification
- **Safe uninstallers** with double confirmation and data backup reminders

## Available Stacks

### Currently Implemented:

1. **MERN Stack** ✅
   - MongoDB 8.0
   - Express.js (latest)
   - React (latest via create-react-app)
   - Node.js (latest LTS via NVM)

9. **Docker** ✅
   - Docker Engine (latest)
   - Docker Compose Plugin
   - Docker Compose Standalone
   - Container management tools (ctop, dive, lazydocker)

10. **Observability Stack** ✅
   - Prometheus (metrics collection)
   - Grafana (visualization & dashboards)
   - Loki (log aggregation)
   - Promtail (log shipper)
   - Node Exporter (system metrics)

11. **Laravel Stack** ✅
   - PHP 8.3 with extensions
   - Composer (dependency manager)
   - MySQL 8.0
   - Nginx web server
   - Node.js (via NVM for asset compilation)
   - Laravel framework

### Coming Soon:

2. **MEAN Stack** - MongoDB + Express.js + Angular + Node.js
3. **LAMP Stack** - Linux + Apache + MySQL + PHP
4. **LEMP Stack** - Linux + Nginx + MySQL + PHP
5. **Django Stack** - Python + Django + PostgreSQL
6. **Ruby on Rails Stack** - Ruby + Rails + PostgreSQL
7. **PERN Stack** - PostgreSQL + Express.js + React + Node.js
8. **JAMstack** - Next.js + Node.js + Git

## Requirements

- Ubuntu/Debian-based Linux system (Ubuntu 20.04+, Debian 11+)
- `sudo` privileges
- Internet connection

## File Structure

```
stack-installer/
├── README.md                   # This file
├── LICENSE                     # MIT License
├── CLAUDE.md                   # Development guidelines
├── install.sh                  # Main installer menu
├── uninstall.sh                # Main uninstaller menu
├── installers/                 # Installation scripts
│   ├── install-mern.sh
│   ├── install-docker.sh
│   ├── install-observability.sh
│   └── install-laravel.sh
└── uninstallers/               # Uninstallation scripts
    ├── uninstall-mern.sh
    ├── uninstall-docker.sh
    ├── uninstall-observability.sh
    └── uninstall-laravel.sh
```

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/stack-installer.git
cd stack-installer

# Run the main installer
sudo ./install.sh
```

### Running in WSL (Windows Subsystem for Linux)

```bash
# Open WSL terminal
wsl

# Navigate to the directory
cd /mnt/f/coding/stack-installer

# Run the installer
sudo ./install.sh
```

## Usage

1. Run the main script with sudo:
   ```bash
   sudo ./install.sh
   ```

2. You'll see an interactive menu with available stacks

3. Enter the number corresponding to your desired stack

4. Choose your environment type:
   - **Development**: Includes all dev tools, no authentication, easier for local development
   - **Production**: Optimized settings, MongoDB authentication enabled, security hardened

5. Confirm the installation when prompted

6. Wait for the installation to complete

## MERN Stack Details

The MERN stack installer (`install-mern.sh`) installs different configurations based on your environment choice:

### Core Components (Both Environments):
- **NVM (Node Version Manager)**: Latest version
- **Node.js**: Latest LTS version via NVM
- **npm**: Comes with Node.js
- **MongoDB**: Version 8.0 (latest)

### Development Environment:
**Global npm packages:**
- `create-react-app` - React project scaffolding
- `express-generator` - Express project scaffolding
- `nodemon` - Auto-restart for development

**Configuration:**
- MongoDB: No authentication (easier for local development)
- NODE_ENV: development (default)
- All development tools included

### Production Environment:
**Global npm packages:**
- `pm2` - Production process manager for Node.js
- `express-generator` - Express project scaffolding

**Configuration:**
- MongoDB: Authentication ENABLED with auto-generated admin user
- NODE_ENV: production
- MongoDB credentials saved to `~/mongodb-credentials.txt`
- Optimized for performance and security
- Operation profiling enabled

**Security Features:**
- MongoDB authentication required
- Bind to localhost only (127.0.0.1)
- Strong random password generation
- Secure credential storage

### Post-Installation:

After installation, you can:

```bash
# Check Node.js version
node --version

# Check npm version
npm --version

# Use NVM commands
nvm ls                    # List installed Node versions
nvm install 20.10.0      # Install specific version
nvm use 20.10.0          # Switch to specific version
nvm install --lts        # Install latest LTS

# MongoDB commands
sudo systemctl status mongod   # Check MongoDB status

# Development: Connect without auth
mongosh

# Production: Connect with auth
mongosh -u admin -p
# Enter password from ~/mongodb-credentials.txt

# Create a new MERN project
npx create-react-app my-frontend
express my-backend

# Production: Use PM2 to manage your app
pm2 start app.js
pm2 list
pm2 logs
```

## Docker Details

The Docker installer (`install-docker.sh`) installs different configurations based on your environment choice:

### Core Components (Both Environments):
- **Docker Engine**: Latest stable version
- **Docker Compose Plugin**: Latest version
- **Docker Compose Standalone**: Latest version (legacy support)
- **containerd.io**: Container runtime
- **Docker Buildx**: Build tool plugin

### Development Environment:
**Additional Tools:**
- `lazydocker` - Terminal UI for Docker management

**Configuration:**
- Log rotation: 100MB max, 5 files (verbose logging for debugging)
- Standard Docker settings
- User added to docker group for non-root access

### Production Environment:
**Additional Tools:**
- `ctop` - Real-time container monitoring
- `dive` - Docker image layer analysis

**Configuration:**
- Log rotation: 10MB max, 3 files (optimized)
- Live restore: ENABLED (containers survive daemon restart)
- Enhanced security: userland-proxy disabled, no-new-privileges enabled
- Container isolation: ICC (Inter-Container Communication) disabled
- Resource limits: ulimits configured for production workloads

**Security Features:**
- Restricted container privileges
- Optimized logging to prevent disk space issues
- Production-ready daemon configuration
- Security best practices applied

### Post-Installation:

After installation, you can:

```bash
# Check Docker version
docker --version
docker compose version

# Test Docker installation
docker run hello-world

# List containers
docker ps -a

# List images
docker images

# Development: Use lazydocker for easy management
lazydocker

# Production: Monitor containers with ctop
ctop

# Production: Analyze image layers with dive
dive <image-name>

# Docker Compose commands
docker compose up -d         # Start services in background
docker compose down          # Stop and remove services
docker compose logs -f       # Follow logs
docker compose ps            # List running services
docker compose restart       # Restart services

# Container management
docker stop <container>      # Stop a container
docker start <container>     # Start a container
docker rm <container>        # Remove a container
docker exec -it <container> bash  # Access container shell

# Image management
docker pull <image>          # Download an image
docker build -t myapp .      # Build an image
docker rmi <image>           # Remove an image
docker scan <image>          # Scan image for vulnerabilities (production)
```

**Important:** After installation, log out and log back in for group permissions to take effect. Then test with: `docker run hello-world`

## Observability Stack Details

The Observability Stack installer (`install-observability.sh`) provides a complete monitoring and logging solution with different configurations based on your environment choice:

### Core Components (Both Environments):
- **Prometheus**: Metrics collection and time-series database
- **Grafana**: Visualization and dashboard platform
- **Loki**: Log aggregation system
- **Promtail**: Log shipper that collects and sends logs to Loki
- **Node Exporter**: System metrics exporter for Prometheus

### Development Environment:
**Configuration:**
- Grafana: Simple authentication (admin/admin)
- Anonymous access: ENABLED (easier testing)
- Prometheus retention: 15 days
- Loki retention: 7 days
- Default settings for quick local setup

**Access:**
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Node Exporter: http://localhost:9100/metrics

### Production Environment:
**Configuration:**
- Grafana: Strong auto-generated admin password
- Anonymous access: DISABLED
- User sign-up: DISABLED
- Prometheus retention: 30 days
- Loki retention: 30 days
- Security hardened settings
- Credentials saved to `~/observability-credentials.txt`

**Security Features:**
- Strong password generation (24-character random)
- Cookie security enabled
- Strict transport security
- Gravatar disabled
- User registration disabled
- Secure credential storage (chmod 600)

### Post-Installation:

After installation, you can:

```bash
# Check service status
sudo systemctl status prometheus
sudo systemctl status grafana-server
sudo systemctl status loki
sudo systemctl status promtail
sudo systemctl status node_exporter

# View service logs
sudo journalctl -u prometheus -f
sudo journalctl -u grafana-server -f
sudo journalctl -u loki -f

# Access Grafana (default)
# Open browser to http://localhost:3000
# Development: Login with admin/admin
# Production: Use credentials from ~/observability-credentials.txt

# Access Prometheus
# Open browser to http://localhost:9090
# Try queries like:
#   - up (see all targets)
#   - node_cpu_seconds_total (CPU metrics)
#   - rate(node_network_receive_bytes_total[5m]) (network traffic)

# Import recommended Grafana dashboards:
# 1. Log in to Grafana
# 2. Go to Dashboards -> Import
# 3. Import these popular dashboards:
#    - Node Exporter Full: Dashboard ID 1860
#    - Loki Logs Dashboard: Dashboard ID 13639
#    - Prometheus 2.0 Stats: Dashboard ID 3662

# Configure alerts in Prometheus
sudo nano /etc/prometheus/prometheus.yml
sudo systemctl restart prometheus

# Add more scrape targets
sudo nano /etc/prometheus/prometheus.yml
# Add your custom jobs under scrape_configs
sudo systemctl restart prometheus

# Configure log sources in Promtail
sudo nano /etc/promtail/promtail-config.yml
sudo systemctl restart promtail
```

**Production Best Practices:**
```bash
# Change Grafana admin password (production)
# 1. Log in to Grafana
# 2. Go to Configuration -> Users -> admin
# 3. Change password

# Set up SSL/TLS with reverse proxy (nginx/caddy)
# Configure firewall
sudo ufw allow 3000/tcp  # Grafana
sudo ufw allow 9090/tcp  # Prometheus (optional, internal only)

# Back up Grafana data
sudo tar -czf grafana-backup.tar.gz /var/lib/grafana

# Back up Prometheus data
sudo tar -czf prometheus-backup.tar.gz /var/lib/prometheus

# Monitor disk usage (important for metrics/logs)
df -h
du -sh /var/lib/prometheus
du -sh /var/lib/loki
```

## Laravel Stack Details

The Laravel Stack installer (`install-laravel.sh`) provides a complete PHP development environment with different configurations based on your environment choice:

### Core Components (Both Environments):
- **PHP 8.3**: Latest stable PHP with FPM (FastCGI Process Manager)
- **Composer**: Dependency manager for PHP
- **MySQL 8.0**: Relational database
- **Nginx**: High-performance web server
- **Node.js**: Via NVM for frontend asset compilation (Laravel Mix/Vite)
- **Laravel**: Latest version of the Laravel framework

### PHP Extensions Installed:
- mbstring, xml, bcmath, curl, gd, mysql, zip, intl, readline, tokenizer

### Development Environment:
**Configuration:**
- Xdebug: ENABLED (debugging and code coverage)
- MySQL credentials: root/root, laravel/laravel
- Error reporting: Verbose (APP_DEBUG=true)
- Laravel environment: local
- Sample Laravel project created at /var/www/laravel

**Development Tools:**
- Xdebug for step-through debugging
- Verbose error messages
- Easy database access (simple passwords)

### Production Environment:
**Configuration:**
- OPcache: ENABLED (bytecode caching for performance)
- MySQL: Strong auto-generated passwords
- Error reporting: Production mode (APP_DEBUG=false)
- Laravel environment: production
- Supervisor: Queue worker management
- Laravel Scheduler: Cron job configured
- Credentials saved to `~/laravel-credentials.txt`

**Production Tools:**
- Supervisor for queue workers
- Cron job for Laravel scheduler
- OPcache for improved performance
- Security hardened configurations

**Security Features:**
- Strong password generation (24-character random)
- MySQL root and application user secured
- Production error handling (no sensitive info exposed)
- Secure credential storage (chmod 600)
- Nginx security headers configured
- PHP-FPM process isolation

### Post-Installation:

After installation, you can:

```bash
# Access your Laravel application
# Open browser to http://localhost

# Navigate to Laravel directory
cd /var/www/laravel

# Run Artisan commands
php artisan migrate              # Run database migrations
php artisan make:controller      # Create a controller
php artisan make:model User      # Create a model
php artisan make:migration       # Create a migration
php artisan route:list           # List all routes
php artisan tinker               # Interactive REPL
php artisan serve                # Start development server (port 8000)

# Install and compile frontend assets
npm install                      # Install Node dependencies
npm run dev                      # Compile assets (development)
npm run build                    # Build assets (production)
npm run watch                    # Watch and recompile on changes

# Composer commands
composer install                 # Install PHP dependencies
composer update                  # Update dependencies
composer require package/name    # Install new package
composer dump-autoload           # Regenerate autoload files

# Database operations
php artisan migrate              # Run migrations
php artisan migrate:rollback     # Rollback last migration
php artisan migrate:fresh        # Drop all tables and re-run migrations
php artisan db:seed              # Run database seeders

# Cache management
php artisan cache:clear          # Clear application cache
php artisan config:clear         # Clear configuration cache
php artisan route:clear          # Clear route cache
php artisan view:clear           # Clear compiled views
php artisan optimize             # Cache config, routes, and views

# Check service status
sudo systemctl status php8.3-fpm
sudo systemctl status nginx
sudo systemctl status mysql

# View logs
tail -f /var/www/laravel/storage/logs/laravel.log
sudo tail -f /var/log/nginx/error.log
```

**Production-Specific Commands:**
```bash
# Queue worker management (production only)
sudo supervisorctl status                    # Check worker status
sudo supervisorctl restart laravel-worker:*  # Restart workers
sudo supervisorctl stop laravel-worker:*     # Stop workers
sudo supervisorctl start laravel-worker:*    # Start workers
sudo tail -f /var/www/laravel/storage/logs/worker.log  # View worker logs

# Laravel Scheduler (automatically configured in cron)
crontab -l                       # Verify scheduler cron job exists

# Deploy new code (production)
cd /var/www/laravel
git pull origin main
composer install --no-dev --optimize-autoloader
npm ci && npm run build
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
sudo supervisorctl restart laravel-worker:*
```

**Production Best Practices:**
```bash
# Set up SSL with Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com

# Configure your domain in Nginx
sudo nano /etc/nginx/sites-available/laravel
# Change server_name from localhost to your domain
sudo nginx -t
sudo systemctl reload nginx

# Set up Redis for caching and sessions
sudo apt install redis-server
# Update .env:
# CACHE_DRIVER=redis
# SESSION_DRIVER=redis
# QUEUE_CONNECTION=redis

# Database backups
mysqldump -u root -p laravel > backup_$(date +%Y%m%d).sql

# Monitor application
# Install Laravel Telescope (development) or Horizon (production)
composer require laravel/horizon
php artisan horizon:install
php artisan migrate

# Set up firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## Individual Stack Installation

You can also run individual stack installers directly:

```bash
# MERN Stack - Development (default)
sudo ./installers/install-mern.sh development

# MERN Stack - Production
sudo ./installers/install-mern.sh production

# Docker - Development (default)
sudo ./installers/install-docker.sh development

# Docker - Production
sudo ./installers/install-docker.sh production

# Observability Stack - Development (default)
sudo ./installers/install-observability.sh development

# Observability Stack - Production
sudo ./installers/install-observability.sh production

# Laravel Stack - Development (default)
sudo ./installers/install-laravel.sh development

# Laravel Stack - Production
sudo ./installers/install-laravel.sh production

# If no argument provided, defaults to development
sudo ./installers/install-mern.sh
sudo ./installers/install-docker.sh
sudo ./installers/install-observability.sh
sudo ./installers/install-laravel.sh
```

## Uninstalling Stacks

If you need to remove an installed stack, use the provided uninstaller scripts. The uninstallers will safely remove all components, configurations, and data associated with each stack.

### Using the Main Uninstaller Menu

```bash
# Run the main uninstaller
sudo ./uninstall.sh

# You'll see a menu with options:
# 1) MERN Stack
# 2) Docker
# 3) Observability Stack
# 4) Laravel Stack
# 0) Exit
```

### Individual Stack Uninstallation

You can also run individual uninstaller scripts directly:

```bash
# Uninstall MERN Stack
sudo ./uninstallers/uninstall-mern.sh
# Removes: MongoDB, global npm packages
# Keeps: Node.js, NVM (may be used by other apps)

# Uninstall Docker
sudo ./uninstallers/uninstall-docker.sh
# Removes: Docker Engine, all containers, images, volumes, networks
# Removes: Docker Compose, management tools (lazydocker, ctop, dive)

# Uninstall Observability Stack
sudo ./uninstallers/uninstall-observability.sh
# Removes: Prometheus, Grafana, Loki, Promtail, Node Exporter
# Removes: All metrics and log data

# Uninstall Laravel Stack
sudo ./uninstallers/uninstall-laravel.sh
# Removes: PHP 8.3, Composer, Nginx, Laravel project
# Optional: MySQL (prompts before removal), Supervisor
```

### What Each Uninstaller Does

#### MERN Stack Uninstaller
- Stops and removes MongoDB service
- Removes MongoDB packages and repositories
- Deletes all MongoDB databases and data
- Removes global npm packages (create-react-app, nodemon, pm2, express-generator)
- Removes MongoDB credentials file
- **Keeps:** Node.js and NVM (can be removed manually if needed)

#### Docker Uninstaller
- Lists current containers, images, and volumes
- Stops all running containers
- Removes all containers, images, volumes, and networks
- Removes Docker Engine and all related packages
- Removes Docker Compose (plugin and standalone)
- Removes management tools (lazydocker, ctop, dive)
- Removes user from docker group
- Deletes Docker data directories (/var/lib/docker, /etc/docker)

#### Observability Stack Uninstaller
- Stops all observability services
- Removes Prometheus and all metrics data
- Removes Grafana and all dashboards
- Removes Loki and all log data
- Removes Promtail and Node Exporter
- Removes system users (prometheus, grafana, loki, promtail)
- Removes all configuration files
- Removes credentials file

#### Laravel Stack Uninstaller
- Stops all services (Nginx, PHP-FPM, MySQL, Supervisor)
- Removes Laravel project directory (/var/www/laravel)
- Removes Nginx configuration
- Drops Laravel database and user from MySQL
- Removes PHP 8.3 and all extensions
- Removes Composer
- Removes Nginx
- Removes Laravel scheduler cron job
- Removes Supervisor configuration
- **Prompts before removing:** MySQL server, Supervisor
- Removes credentials file
- **Keeps:** Node.js and NVM (may be used by other apps)

### Safety Features

All uninstallers include multiple safety measures:

1. **Double Confirmation:** Requires typing 'yes' and then 'DELETE' to proceed
2. **Clear Warnings:** Shows exactly what will be removed
3. **Data Backup Reminder:** Some uninstallers remind you to backup data
4. **Selective Removal:** Optional removal of shared components (MySQL, Supervisor)
5. **Detailed Output:** Shows progress of each removal step
6. **Error Handling:** Continues even if some components are already removed

### Important Notes

**Before Uninstalling:**
- Backup any important data (databases, projects, configurations)
- Note down any custom configurations you want to preserve
- Export Grafana dashboards if needed
- Backup Docker volumes if they contain important data

**After Uninstalling:**
- Some uninstallers may require a logout/login for changes to take effect
- Shared components (Node.js, MySQL) may be kept if used by other stacks
- You can reinstall any stack at any time using the main installer

**Manual Cleanup (if needed):**
```bash
# Remove Node.js and NVM manually (if no longer needed)
rm -rf ~/.nvm
# Then remove NVM lines from ~/.bashrc

# Remove MySQL manually (if kept during Laravel uninstall)
sudo apt-get remove --purge mysql-server mysql-client
sudo rm -rf /etc/mysql /var/lib/mysql

# Remove Supervisor manually (if kept during Laravel uninstall)
sudo apt-get remove --purge supervisor
```

## Troubleshooting

### NVM not found after installation
```bash
# Reload your shell configuration
source ~/.bashrc
# or
source ~/.zshrc
```

### MongoDB not starting
```bash
# Check MongoDB status
sudo systemctl status mongod

# View MongoDB logs
sudo journalctl -u mongod

# Restart MongoDB
sudo systemctl restart mongod
```

### Permission issues
Make sure you run the scripts with `sudo`:
```bash
sudo ./install.sh
```

### MongoDB authentication issues (Production)
If you can't connect to MongoDB after production installation:
```bash
# Use the admin credentials from the file
cat ~/mongodb-credentials.txt

# Connect with authentication
mongosh -u admin -p
# Enter the password when prompted

# Or use connection string
mongosh "mongodb://admin:<password>@localhost:27017/admin"
```

### Lost MongoDB credentials (Production)
If you lost the credentials file:
```bash
# You'll need to disable auth temporarily
sudo nano /etc/mongod.conf
# Comment out the security section
# security:
#   authorization: enabled

# Restart MongoDB
sudo systemctl restart mongod

# Create a new admin user
mongosh
use admin
db.createUser({user: "newadmin", pwd: "newpassword", roles: ["root"]})
exit

# Re-enable authentication in /etc/mongod.conf
# Restart MongoDB again
```

### Docker permission denied (Development/Production)
If you get "permission denied" when running Docker commands:
```bash
# Check if user is in docker group
groups $USER

# If not in docker group, add user
sudo usermod -aG docker $USER

# Log out and log back in, then test
docker run hello-world
```

### Docker daemon not running
If Docker commands fail with "Cannot connect to Docker daemon":
```bash
# Check Docker service status
sudo systemctl status docker

# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Restart Docker service
sudo systemctl restart docker
```

### lazydocker/ctop/dive not found
If the additional tools aren't working:
```bash
# Check if they're installed
which lazydocker
which ctop
which dive

# If missing, manually install (example for lazydocker)
curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# For ctop
sudo wget -q https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# For dive
wget https://github.com/wagoodman/dive/releases/download/v0.11.0/dive_0.11.0_linux_amd64.deb
sudo dpkg -i dive_0.11.0_linux_amd64.deb
```

### Grafana not accessible
If you can't access Grafana at http://localhost:3000:
```bash
# Check if Grafana is running
sudo systemctl status grafana-server

# Start Grafana if not running
sudo systemctl start grafana-server

# Check Grafana logs
sudo journalctl -u grafana-server -n 50

# Verify port 3000 is listening
sudo netstat -tlnp | grep 3000
# or
sudo ss -tlnp | grep 3000

# Restart Grafana
sudo systemctl restart grafana-server
```

### Prometheus not collecting metrics
If Prometheus shows targets as down:
```bash
# Check Prometheus status
sudo systemctl status prometheus

# Check Prometheus logs
sudo journalctl -u prometheus -n 50

# Verify targets in Prometheus UI
# Open http://localhost:9090/targets
# All targets should show "UP"

# Check configuration syntax
promtool check config /etc/prometheus/prometheus.yml

# Restart Prometheus
sudo systemctl restart prometheus

# Verify Node Exporter is running
sudo systemctl status node_exporter
curl http://localhost:9100/metrics
```

### Loki/Promtail not working
If logs aren't appearing in Grafana:
```bash
# Check Loki status
sudo systemctl status loki
sudo journalctl -u loki -n 50

# Check Promtail status
sudo systemctl status promtail
sudo journalctl -u promtail -n 50

# Test Loki API
curl http://localhost:3100/ready

# Verify Promtail is shipping logs
curl http://localhost:9080/metrics | grep promtail_sent_entries_total

# Restart services
sudo systemctl restart loki
sudo systemctl restart promtail
```

### Lost Grafana credentials (Production)
If you lost the admin password:
```bash
# Check saved credentials
cat ~/observability-credentials.txt

# Reset Grafana admin password
sudo grafana-cli admin reset-admin-password newpassword123

# Or reset via SQLite database
sudo systemctl stop grafana-server
sudo sqlite3 /var/lib/grafana/grafana.db "UPDATE user SET password = '59acf18b94d7eb0694c61e60ce44c110c7a683ac6a8f09580d626f90f4a242000746579358d77dd9e570e83fa24faa88a8a6', salt = 'F3FAxVm33R' WHERE login = 'admin';"
sudo systemctl start grafana-server
# New password is: admin
```

### Disk space issues with metrics/logs
If Prometheus or Loki is consuming too much disk:
```bash
# Check disk usage
df -h
du -sh /var/lib/prometheus
du -sh /var/lib/loki

# Adjust Prometheus retention (edit and restart)
sudo nano /etc/systemd/system/prometheus.service
# Change --storage.tsdb.retention.time value
sudo systemctl daemon-reload
sudo systemctl restart prometheus

# Adjust Loki retention (edit and restart)
sudo nano /etc/loki/loki-config.yml
# Change retention_period under limits_config
sudo systemctl restart loki

# Manually clean old data (use with caution)
sudo systemctl stop prometheus
sudo rm -rf /var/lib/prometheus/data
sudo systemctl start prometheus
```

### Port conflicts
If ports 3000, 9090, 3100, 9100, or 9080 are already in use:
```bash
# Check what's using the ports
sudo netstat -tlnp | grep -E '3000|9090|3100|9100|9080'

# Stop conflicting services or change ports in config files:
# - Grafana: /etc/grafana/grafana.ini (http_port)
# - Prometheus: /etc/systemd/system/prometheus.service (--web.listen-address)
# - Loki: /etc/loki/loki-config.yml (http_listen_port)
```

### Laravel application not accessible
If you can't access your Laravel app at http://localhost:
```bash
# Check if Nginx is running
sudo systemctl status nginx

# Check if PHP-FPM is running
sudo systemctl status php8.3-fpm

# Test Nginx configuration
sudo nginx -t

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check Laravel logs
tail -f /var/www/laravel/storage/logs/laravel.log

# Restart services
sudo systemctl restart php8.3-fpm
sudo systemctl restart nginx

# Verify permissions
sudo chown -R $USER:www-data /var/www/laravel
sudo chmod -R 775 /var/www/laravel/storage
sudo chmod -R 775 /var/www/laravel/bootstrap/cache
```

### Composer not found
If composer command is not recognized:
```bash
# Check if composer is installed
which composer

# If not found, reinstall
cd /tmp
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

# Verify installation
composer --version
```

### PHP artisan commands fail
If artisan commands don't work:
```bash
# Check PHP version
php --version

# Verify you're in Laravel directory
cd /var/www/laravel

# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Regenerate autoload
composer dump-autoload

# Check file permissions
ls -la storage/ bootstrap/cache/
```

### Database connection errors
If Laravel can't connect to MySQL:
```bash
# Check MySQL is running
sudo systemctl status mysql

# Test MySQL connection
mysql -u laravel -p
# Enter password (dev: laravel, prod: check ~/laravel-credentials.txt)

# Verify database exists
mysql -u root -p -e "SHOW DATABASES;"

# Check .env database settings
cat /var/www/laravel/.env | grep DB_

# Update .env if needed
cd /var/www/laravel
nano .env
# Verify: DB_CONNECTION=mysql, DB_HOST=127.0.0.1, DB_PORT=3306
# DB_DATABASE=laravel, DB_USERNAME=laravel, DB_PASSWORD=<correct-password>

# Clear config cache after .env changes
php artisan config:clear
```

### Lost MySQL credentials (Production)
If you lost Laravel database credentials:
```bash
# Check saved credentials
cat ~/laravel-credentials.txt

# Or reset MySQL laravel user password
sudo mysql -u root -p
ALTER USER 'laravel'@'localhost' IDENTIFIED BY 'newpassword';
FLUSH PRIVILEGES;
exit

# Update .env with new password
nano /var/www/laravel/.env
php artisan config:clear
```

### Nginx 502 Bad Gateway
If you get a 502 error:
```bash
# Check if PHP-FPM socket exists
ls -la /var/run/php/php8.3-fpm.sock

# Check PHP-FPM is running
sudo systemctl status php8.3-fpm

# Check PHP-FPM error logs
sudo tail -f /var/log/php8.3-fpm.log

# Restart PHP-FPM
sudo systemctl restart php8.3-fpm

# Check Nginx config points to correct socket
grep fastcgi_pass /etc/nginx/sites-available/laravel
# Should show: fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
```

### Queue workers not processing jobs (Production)
If jobs aren't being processed:
```bash
# Check supervisor status
sudo supervisorctl status

# Check worker logs
sudo tail -f /var/www/laravel/storage/logs/worker.log

# Restart workers
sudo supervisorctl restart laravel-worker:*

# If supervisor config is missing, recreate it
sudo nano /etc/supervisor/conf.d/laravel-worker.conf
sudo supervisorctl reread
sudo supervisorctl update
```

### Laravel scheduler not running (Production)
If scheduled tasks aren't executing:
```bash
# Verify cron job exists
crontab -l

# Should see: * * * * * cd /var/www/laravel && php artisan schedule:run

# If missing, add it
(crontab -l 2>/dev/null; echo "* * * * * cd /var/www/laravel && php artisan schedule:run >> /dev/null 2>&1") | crontab -

# Test scheduler manually
cd /var/www/laravel
php artisan schedule:run

# Check Laravel logs for scheduler output
tail -f storage/logs/laravel.log
```

### Frontend assets not compiling
If npm commands fail:
```bash
# Check Node.js is installed
node --version
npm --version

# If not found, reload shell
source ~/.bashrc

# Or reinstall via NVM
source ~/.nvm/nvm.sh
nvm install --lts
nvm use --lts

# Install dependencies
cd /var/www/laravel
npm install

# Clear npm cache if needed
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

## Contributing

Contributions are welcome! If you'd like to add support for additional stacks:

1. Fork the repository
2. Create a new installation script (e.g., `install-lamp.sh`)
3. Follow the existing script structure
4. Update the main menu in `install.sh`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Uses [NVM](https://github.com/nvm-sh/nvm) for Node.js version management
- MongoDB installation via official repositories
- Docker installation via official Docker repositories
- Docker management tools: [lazydocker](https://github.com/jesseduffield/lazydocker), [ctop](https://github.com/bcicen/ctop), [dive](https://github.com/wagoodman/dive)
- Observability stack: [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/), [Loki](https://grafana.com/oss/loki/), [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/), [Node Exporter](https://github.com/prometheus/node_exporter)
- Laravel stack: [Laravel](https://laravel.com/), [PHP](https://www.php.net/), [Composer](https://getcomposer.org/), [Nginx](https://nginx.org/), [MySQL](https://www.mysql.com/), [Supervisor](http://supervisord.org/)
- Inspired by the need for quick development environment setup

## Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review the installation logs

---

**Note**: These scripts are designed for development environments. For production deployments, additional security hardening and configuration may be required.