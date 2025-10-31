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

# If no argument provided, defaults to development
sudo ./install-mern.sh
sudo ./install-docker.sh
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
- Inspired by the need for quick development environment setup

## Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review the installation logs

---

**Note**: These scripts are designed for development environments. For production deployments, additional security hardening and configuration may be required.