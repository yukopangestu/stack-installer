# Stack Installer

Automated installation scripts for popular development stacks on Linux systems.

## Overview

This repository contains bash scripts to quickly set up various development environments. Simply run the main installer and choose the stack you want to install.

## Features

- Interactive menu-based installation
- Automated dependency management
- Latest package versions
- NVM for Node.js version management
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

4. Confirm the installation when prompted

5. Wait for the installation to complete

## MERN Stack Details

The MERN stack installer (`install-mern.sh`) installs:

### Components:
- **NVM (Node Version Manager)**: Latest version
- **Node.js**: Latest LTS version via NVM
- **npm**: Comes with Node.js
- **MongoDB**: Version 8.0 (latest)
- **Global npm packages**: create-react-app, express-generator, nodemon

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
mongosh                        # Connect to MongoDB

# Create a new MERN project
npx create-react-app my-frontend
express my-backend
```

## Individual Stack Installation

You can also run individual stack installers directly:

```bash
# MERN Stack only
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