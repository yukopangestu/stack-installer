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

print_header "MERN Stack Uninstaller"
echo -e "${YELLOW}This will remove:${NC}"
echo "  • MongoDB server and all databases"
echo "  • Global npm packages (create-react-app, nodemon, pm2, etc.)"
echo "  • MongoDB configuration files"
echo ""
echo -e "${YELLOW}This will keep:${NC}"
echo "  • Node.js and NVM (you can uninstall manually if needed)"
echo "  • npm (comes with Node.js)"
echo ""
echo -e "${RED}WARNING: This action cannot be undone!${NC}"
echo -e "${RED}All MongoDB databases will be permanently deleted!${NC}"
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

print_header "Starting MERN Stack Uninstallation"

# Stop MongoDB service
print_info "Stopping MongoDB service..."
systemctl stop mongod 2>/dev/null || true
systemctl disable mongod 2>/dev/null || true
print_success "MongoDB service stopped"

# Remove MongoDB packages
print_header "Removing MongoDB"
print_info "Removing MongoDB packages..."
apt-get remove --purge -y mongodb-org* 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
print_success "MongoDB packages removed"

# Remove MongoDB data and configuration
print_info "Removing MongoDB data directories..."
rm -rf /var/lib/mongodb
rm -rf /var/log/mongodb
rm -rf /etc/mongod.conf
rm -rf /etc/mongod.conf.backup
print_success "MongoDB data and configuration removed"

# Remove MongoDB repository
print_info "Removing MongoDB repository..."
rm -f /etc/apt/sources.list.d/mongodb-org-*.list
rm -f /usr/share/keyrings/mongodb-server-*.gpg
print_success "MongoDB repository removed"

# Remove global npm packages
print_header "Removing Global npm Packages"
if command -v npm &> /dev/null 2>&1; then
    print_info "Removing global npm packages..."

    # Remove common MERN development packages
    su - $ACTUAL_USER -c "npm uninstall -g create-react-app" 2>/dev/null || true
    su - $ACTUAL_USER -c "npm uninstall -g nodemon" 2>/dev/null || true
    su - $ACTUAL_USER -c "npm uninstall -g express-generator" 2>/dev/null || true
    su - $ACTUAL_USER -c "npm uninstall -g pm2" 2>/dev/null || true

    print_success "Global npm packages removed"
else
    print_warning "npm not found, skipping npm package removal"
fi

# Remove MongoDB credentials file
if [ -f "$ACTUAL_HOME/mongodb-credentials.txt" ]; then
    print_info "Removing MongoDB credentials file..."
    rm -f "$ACTUAL_HOME/mongodb-credentials.txt"
    print_success "Credentials file removed"
fi

# Clean up
print_info "Cleaning up..."
apt-get autoremove -y > /dev/null 2>&1 || true
apt-get autoclean -y > /dev/null 2>&1 || true
print_success "Cleanup completed"

print_header "Uninstallation Complete!"
print_success "MERN stack components have been removed from your system"
echo ""
print_info "Node.js and NVM were kept as they may be used by other applications"
echo ""
print_warning "To remove Node.js and NVM manually, run:"
echo "  rm -rf $ACTUAL_HOME/.nvm"
echo "  # Then remove NVM lines from $ACTUAL_HOME/.bashrc"
echo ""
