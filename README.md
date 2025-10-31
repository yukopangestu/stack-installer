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

## Individual Stack Installation

You can also run individual stack installers directly:

```bash
# MERN Stack - Development (default)
sudo ./install-mern.sh development

# MERN Stack - Production
sudo ./install-mern.sh production

# If no argument provided, defaults to development
sudo ./install-mern.sh
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
- Inspired by the need for quick development environment setup

## Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review the installation logs

---

**Note**: These scripts are designed for development environments. For production deployments, additional security hardening and configuration may be required.