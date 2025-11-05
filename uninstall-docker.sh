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

print_header "Docker Stack Uninstaller"
echo -e "${YELLOW}This will remove:${NC}"
echo "  • Docker Engine"
echo "  • Docker Compose (plugin and standalone)"
echo "  • All Docker containers, images, volumes, and networks"
echo "  • Docker management tools (lazydocker, ctop, dive)"
echo "  • Docker configuration files"
echo "  • User from docker group"
echo ""
echo -e "${RED}WARNING: This action cannot be undone!${NC}"
echo -e "${RED}All Docker containers, images, and volumes will be deleted!${NC}"
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

print_header "Starting Docker Stack Uninstallation"

# List current Docker resources
if command -v docker &> /dev/null; then
    print_info "Current Docker resources:"
    echo ""
    echo "Containers:"
    docker ps -a 2>/dev/null || true
    echo ""
    echo "Images:"
    docker images 2>/dev/null || true
    echo ""
    echo "Volumes:"
    docker volume ls 2>/dev/null || true
    echo ""

    read -p "Do you want to backup any data before proceeding? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_warning "Please backup your data now. Press Enter when ready to continue..."
        read
    fi
fi

# Stop all running containers
print_info "Stopping all Docker containers..."
docker stop $(docker ps -aq) 2>/dev/null || true
print_success "All containers stopped"

# Remove all containers
print_info "Removing all Docker containers..."
docker rm $(docker ps -aq) 2>/dev/null || true
print_success "All containers removed"

# Remove all images
print_info "Removing all Docker images..."
docker rmi $(docker images -q) -f 2>/dev/null || true
print_success "All images removed"

# Remove all volumes
print_info "Removing all Docker volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null || true
print_success "All volumes removed"

# Remove all networks
print_info "Removing all Docker networks..."
docker network rm $(docker network ls -q) 2>/dev/null || true
print_success "All networks removed"

# Stop Docker service
print_info "Stopping Docker service..."
systemctl stop docker 2>/dev/null || true
systemctl stop docker.socket 2>/dev/null || true
systemctl disable docker 2>/dev/null || true
print_success "Docker service stopped"

# Remove Docker packages
print_header "Removing Docker Packages"
print_info "Removing Docker Engine and related packages..."
apt-get remove --purge -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    docker-compose 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
print_success "Docker packages removed"

# Remove Docker data directories
print_info "Removing Docker data directories..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
rm -rf /etc/docker
rm -rf /etc/systemd/system/docker.service.d
rm -rf $ACTUAL_HOME/.docker
print_success "Docker data directories removed"

# Remove Docker repository
print_info "Removing Docker repository..."
rm -f /etc/apt/sources.list.d/docker.list
rm -f /usr/share/keyrings/docker-archive-keyring.gpg
print_success "Docker repository removed"

# Remove Docker management tools
print_header "Removing Docker Management Tools"

if [ -f /usr/local/bin/lazydocker ]; then
    print_info "Removing lazydocker..."
    rm -f /usr/local/bin/lazydocker
    rm -rf $ACTUAL_HOME/.config/lazydocker
    print_success "lazydocker removed"
fi

if [ -f /usr/local/bin/ctop ]; then
    print_info "Removing ctop..."
    rm -f /usr/local/bin/ctop
    print_success "ctop removed"
fi

if command -v dive &> /dev/null; then
    print_info "Removing dive..."
    apt-get remove --purge -y dive 2>/dev/null || true
    print_success "dive removed"
fi

# Remove user from docker group
print_info "Removing $ACTUAL_USER from docker group..."
gpasswd -d $ACTUAL_USER docker 2>/dev/null || true
print_success "User removed from docker group"

# Remove docker group
print_info "Removing docker group..."
groupdel docker 2>/dev/null || true
print_success "Docker group removed"

# Clean up
print_info "Cleaning up..."
apt-get autoremove -y > /dev/null 2>&1 || true
apt-get autoclean -y > /dev/null 2>&1 || true
print_success "Cleanup completed"

print_header "Uninstallation Complete!"
print_success "Docker stack has been completely removed from your system"
echo ""
print_warning "Please log out and log back in for group changes to take effect"
echo ""
