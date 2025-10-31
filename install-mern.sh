#!/bin/bash

# MERN Stack Installation Script
# Installs MongoDB, Express.js, React, and Node.js using NVM

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# Get the actual user who invoked sudo
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

# Check if script is run with sudo/root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script with sudo"
    exit 1
fi

print_info "Starting MERN Stack Installation..."
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    print_error "Cannot detect OS. This script supports Ubuntu/Debian-based systems."
    exit 1
fi

print_info "Detected OS: $OS $VERSION"
echo ""

# Update package manager
print_info "Updating package manager..."
apt-get update -y
print_success "Package manager updated"
echo ""

# Install dependencies for NVM
print_info "Installing build dependencies..."
apt-get install -y curl wget git build-essential libssl-dev
print_success "Dependencies installed"
echo ""

# Install NVM for the actual user
print_info "Installing NVM (Node Version Manager)..."

# Download and install NVM as the actual user
su - $ACTUAL_USER -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/latest/install.sh | bash"

# Source NVM for the actual user's shell
export NVM_DIR="$ACTUAL_HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

print_success "NVM installed"
echo ""

# Install Node.js using NVM
print_info "Installing latest LTS version of Node.js via NVM..."

# Install Node.js as the actual user
su - $ACTUAL_USER -c "
    export NVM_DIR=\"$ACTUAL_HOME/.nvm\"
    [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*
"

# Get Node.js and npm versions
NODE_VERSION=$(su - $ACTUAL_USER -c "
    export NVM_DIR=\"$ACTUAL_HOME/.nvm\"
    [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
    node --version
")

NPM_VERSION=$(su - $ACTUAL_USER -c "
    export NVM_DIR=\"$ACTUAL_HOME/.nvm\"
    [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
    npm --version
")

print_success "Node.js $NODE_VERSION installed"
print_success "npm $NPM_VERSION installed"
print_info "NVM location: $ACTUAL_HOME/.nvm"
echo ""

# Install MongoDB
print_info "Installing latest MongoDB (8.0)..."

# Import MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# Update package database
apt-get update -y

# Install MongoDB packages
apt-get install -y mongodb-org

# Start and enable MongoDB service
systemctl start mongod
systemctl enable mongod

# Verify MongoDB installation
if systemctl is-active --quiet mongod; then
    MONGO_VERSION=$(mongod --version | head -n 1)
    print_success "MongoDB installed and running"
    print_info "$MONGO_VERSION"
else
    print_error "MongoDB installation failed or service not running"
    exit 1
fi
echo ""

# Install global npm packages commonly used in MERN stack
print_info "Installing global npm packages..."
su - $ACTUAL_USER -c "
    export NVM_DIR=\"$ACTUAL_HOME/.nvm\"
    [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
    npm install -g create-react-app express-generator nodemon
"
print_success "Global packages installed (create-react-app, express-generator, nodemon)"
echo ""

# Display installation summary
echo "========================================="
print_success "MERN Stack Installation Complete!"
echo "========================================="
echo ""
echo "Installed Components:"
echo "  • NVM (Node Version Manager): Installed at $ACTUAL_HOME/.nvm"
echo "  • Node.js: $NODE_VERSION (LTS via NVM)"
echo "  • npm: $NPM_VERSION"
echo "  • MongoDB: 8.0 (Running on default port 27017)"
echo ""
echo "Global npm packages:"
echo "  • create-react-app (for React projects)"
echo "  • express-generator (for Express projects)"
echo "  • nodemon (for development)"
echo ""
echo "NVM Commands (for user $ACTUAL_USER):"
echo "  • List installed versions: nvm ls"
echo "  • Install specific version: nvm install 20.10.0"
echo "  • Use specific version: nvm use 20.10.0"
echo "  • Install latest LTS: nvm install --lts"
echo "  • Set default version: nvm alias default <version>"
echo ""
echo "Next Steps:"
echo "  1. Reload your shell: source ~/.bashrc (or restart terminal)"
echo "  2. Create a new React app: npx create-react-app my-app"
echo "  3. Create a new Express app: express my-backend-app"
echo "  4. Connect to MongoDB: mongodb://localhost:27017"
echo ""
echo "MongoDB Commands:"
echo "  • Start: sudo systemctl start mongod"
echo "  • Stop: sudo systemctl stop mongod"
echo "  • Status: sudo systemctl status mongod"
echo "  • Connect: mongosh"
echo ""
print_success "Happy coding!"
