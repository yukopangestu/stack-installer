# Stack Installer

Automated installation scripts for popular development stacks on Linux systems.

## Overview

This repository contains bash scripts to quickly set up various development environments. Simply run the main installer and choose the stack you want to install.

## Features

- Interactive menu-based installation
- **Environment selection** (Development vs Production)
- Automated dependency management
- Latest package versions
- NVM for Node.js version management
- Production-ready security configurations
- MongoDB authentication for production
- PM2 process manager for production deployments
- Color-coded output for better readability
- Error handling and verification

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

## Individual Stack Installation

You can also run individual stack installers directly:

```bash
# MERN Stack - Development (default)
sudo ./install-mern.sh development

# MERN Stack - Production
sudo ./install-mern.sh production

# Docker - Development (default)
sudo ./install-docker.sh development

# Docker - Production
sudo ./install-docker.sh production

# Observability Stack - Development (default)
sudo ./install-observability.sh development

# Observability Stack - Production
sudo ./install-observability.sh production

# If no argument provided, defaults to development
sudo ./install-mern.sh
sudo ./install-docker.sh
sudo ./install-observability.sh
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
- Inspired by the need for quick development environment setup

## Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review the installation logs

---

**Note**: These scripts are designed for development environments. For production deployments, additional security hardening and configuration may be required.