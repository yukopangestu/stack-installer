#!/bin/bash

# MERN Stack Installation Script
# Installs MongoDB, Express.js, React, and Node.js using NVM

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_warning() {
    echo -e "${BLUE}⚠ $1${NC}"
}

# Get the actual user who invoked sudo
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

# Get environment type (development or production)
INSTALL_ENV=${1:-development}

# Check if script is run with sudo/root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script with sudo"
    exit 1
fi

print_info "Starting MERN Stack Installation..."
print_info "Environment: $INSTALL_ENV"
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

# Configure MongoDB based on environment
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Configuring MongoDB for production..."

    # Backup original config
    cp /etc/mongod.conf /etc/mongod.conf.backup

    # Configure MongoDB for production
    cat > /etc/mongod.conf << 'EOF'
# mongod.conf - Production Configuration

# Where and how to store data
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

# Where to write logging data
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# Network interfaces
net:
  port: 27017
  bindIp: 127.0.0.1

# Process management
processManagement:
  timeZoneInfo: /usr/share/zoneinfo

# Security
security:
  authorization: enabled

# Operation Profiling
operationProfiling:
  mode: slowOp
  slowOpThresholdMs: 100
EOF

    print_success "MongoDB configured for production"
    print_warning "MongoDB authentication is ENABLED"
else
    print_info "Configuring MongoDB for development..."
    # Keep default configuration for development (no auth required)
    print_success "MongoDB configured for development (authentication disabled)"
fi

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

# Create MongoDB admin user for production
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Setting up MongoDB authentication..."

    # Generate random password
    MONGO_ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

    # Create admin user
    mongosh --eval "
        db = db.getSiblingDB('admin');
        db.createUser({
            user: 'admin',
            pwd: '$MONGO_ADMIN_PASSWORD',
            roles: [
                { role: 'userAdminAnyDatabase', db: 'admin' },
                { role: 'readWriteAnyDatabase', db: 'admin' },
                { role: 'dbAdminAnyDatabase', db: 'admin' }
            ]
        });
    " > /dev/null 2>&1

    # Save credentials to file
    CREDENTIALS_FILE="$ACTUAL_HOME/mongodb-credentials.txt"
    cat > $CREDENTIALS_FILE << EOF
MongoDB Admin Credentials
=========================
Username: admin
Password: $MONGO_ADMIN_PASSWORD
Connection String: mongodb://admin:$MONGO_ADMIN_PASSWORD@localhost:27017/admin

IMPORTANT: Save these credentials in a secure location and delete this file!
EOF

    chown $ACTUAL_USER:$ACTUAL_USER $CREDENTIALS_FILE
    chmod 600 $CREDENTIALS_FILE

    print_success "MongoDB admin user created"
    print_warning "Credentials saved to: $CREDENTIALS_FILE"
    print_warning "IMPORTANT: Save credentials and delete the file!"

    # Restart MongoDB to apply authentication
    systemctl restart mongod
    sleep 2
fi
echo ""

# Install global npm packages based on environment
print_info "Installing global npm packages..."

if [ "$INSTALL_ENV" = "production" ]; then
    # Production packages
    su - $ACTUAL_USER -c "
        export NVM_DIR=\"$ACTUAL_HOME/.nvm\"
        [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
        npm install -g pm2 express-generator
    "
    print_success "Global packages installed (pm2, express-generator)"
    print_info "pm2: Production process manager for Node.js"
else
    # Development packages
    su - $ACTUAL_USER -c "
        export NVM_DIR=\"$ACTUAL_HOME/.nvm\"
        [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"
        npm install -g create-react-app express-generator nodemon
    "
    print_success "Global packages installed (create-react-app, express-generator, nodemon)"
fi
echo ""

# Set NODE_ENV for production
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Setting NODE_ENV to production..."

    # Add NODE_ENV to bashrc
    if ! grep -q "export NODE_ENV=production" "$ACTUAL_HOME/.bashrc"; then
        echo "" >> "$ACTUAL_HOME/.bashrc"
        echo "# Node.js Environment" >> "$ACTUAL_HOME/.bashrc"
        echo "export NODE_ENV=production" >> "$ACTUAL_HOME/.bashrc"
        print_success "NODE_ENV=production set in .bashrc"
    fi
fi
echo ""

# Display installation summary
echo "========================================="
print_success "MERN Stack Installation Complete!"
echo "========================================="
echo ""
echo "Environment: $INSTALL_ENV"
echo ""
echo "Installed Components:"
echo "  • NVM (Node Version Manager): Installed at $ACTUAL_HOME/.nvm"
echo "  • Node.js: $NODE_VERSION (LTS via NVM)"
echo "  • npm: $NPM_VERSION"
echo "  • MongoDB: 8.0 (Running on default port 27017)"
echo ""

if [ "$INSTALL_ENV" = "production" ]; then
    echo "Global npm packages:"
    echo "  • pm2 (production process manager)"
    echo "  • express-generator (for Express projects)"
    echo ""
    echo "Production Configuration:"
    echo "  • NODE_ENV: production"
    echo "  • MongoDB: Authentication ENABLED"
    echo "  • MongoDB Credentials: $CREDENTIALS_FILE"
    echo ""
    print_warning "SECURITY REMINDERS:"
    echo "  1. Save MongoDB credentials from $CREDENTIALS_FILE"
    echo "  2. Delete the credentials file after saving"
    echo "  3. Configure firewall rules (ufw allow from <ip> to any port 27017)"
    echo "  4. Consider enabling MongoDB SSL/TLS for production"
    echo "  5. Regularly update all packages for security patches"
    echo ""
    echo "PM2 Commands:"
    echo "  • Start app: pm2 start app.js"
    echo "  • List apps: pm2 list"
    echo "  • Monitor: pm2 monit"
    echo "  • Logs: pm2 logs"
    echo "  • Restart: pm2 restart app"
    echo "  • Stop: pm2 stop app"
    echo "  • Startup on boot: pm2 startup"
    echo ""
    echo "MongoDB Connection (with auth):"
    echo "  • Connect: mongosh -u admin -p"
    echo "  • Connection string: mongodb://admin:<password>@localhost:27017/admin"
else
    echo "Global npm packages:"
    echo "  • create-react-app (for React projects)"
    echo "  • express-generator (for Express projects)"
    echo "  • nodemon (for development)"
    echo ""
    echo "Development Configuration:"
    echo "  • NODE_ENV: development (default)"
    echo "  • MongoDB: Authentication DISABLED (easier for development)"
    echo ""
    echo "Next Steps:"
    echo "  1. Reload your shell: source ~/.bashrc (or restart terminal)"
    echo "  2. Create a new React app: npx create-react-app my-app"
    echo "  3. Create a new Express app: express my-backend-app"
    echo "  4. Connect to MongoDB: mongodb://localhost:27017"
    echo ""
    echo "MongoDB Connection (no auth required):"
    echo "  • Connect: mongosh"
    echo "  • Connection string: mongodb://localhost:27017"
fi

echo ""
echo "NVM Commands (for user $ACTUAL_USER):"
echo "  • List installed versions: nvm ls"
echo "  • Install specific version: nvm install 20.10.0"
echo "  • Use specific version: nvm use 20.10.0"
echo "  • Install latest LTS: nvm install --lts"
echo "  • Set default version: nvm alias default <version>"
echo ""
echo "MongoDB Commands:"
echo "  • Start: sudo systemctl start mongod"
echo "  • Stop: sudo systemctl stop mongod"
echo "  • Status: sudo systemctl status mongod"
echo ""
print_success "Happy coding!"
