#!/bin/bash

# Docker Installation Script
# Installs Docker Engine, Docker Compose, and optional tools

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

print_info "Starting Docker Installation..."
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

# Remove old Docker installations
print_info "Removing old Docker installations (if any)..."
apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
print_success "Old installations removed"
echo ""

# Update package manager
print_info "Updating package manager..."
apt-get update -y
print_success "Package manager updated"
echo ""

# Install prerequisites
print_info "Installing prerequisites..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
print_success "Prerequisites installed"
echo ""

# Add Docker's official GPG key
print_info "Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
print_success "Docker GPG key added"
echo ""

# Set up Docker repository
print_info "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
print_success "Docker repository configured"
echo ""

# Update package database
print_info "Updating package database..."
apt-get update -y
print_success "Package database updated"
echo ""

# Install Docker Engine
print_info "Installing Docker Engine..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
print_success "Docker Engine installed"
echo ""

# Verify Docker installation
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
    print_success "Docker $DOCKER_VERSION installed successfully"
else
    print_error "Docker installation failed"
    exit 1
fi

# Start and enable Docker service
print_info "Starting Docker service..."
systemctl start docker
systemctl enable docker
print_success "Docker service started and enabled"
echo ""

# Add user to docker group
print_info "Adding $ACTUAL_USER to docker group..."
usermod -aG docker $ACTUAL_USER
print_success "User $ACTUAL_USER added to docker group"
print_warning "You need to log out and back in for group changes to take effect"
echo ""

# Configure Docker based on environment
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Configuring Docker for production..."

    # Create daemon.json for production
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true,
  "icc": false,
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
EOF

    print_success "Production configuration applied"
    print_info "Log rotation: 10MB max, 3 files"
    print_info "Live restore enabled"
    print_info "Enhanced security settings applied"

    # Restart Docker to apply configuration
    systemctl restart docker
    sleep 2

else
    print_info "Configuring Docker for development..."

    # Create daemon.json for development
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "5"
  }
}
EOF

    print_success "Development configuration applied"
    print_info "Log rotation: 100MB max, 5 files (more verbose for debugging)"

    # Restart Docker to apply configuration
    systemctl restart docker
    sleep 2
fi
echo ""

# Install Docker Compose standalone (legacy)
print_info "Installing Docker Compose standalone..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
print_success "Docker Compose $COMPOSE_VERSION installed"
echo ""

# Install additional tools based on environment
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Installing production tools..."

    # Install ctop (container monitoring)
    wget -q https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
    chmod +x /usr/local/bin/ctop
    print_success "ctop (container monitoring) installed"

    # Install dive (image analysis)
    wget -q https://github.com/wagoodman/dive/releases/download/v0.11.0/dive_0.11.0_linux_amd64.deb
    dpkg -i dive_0.11.0_linux_amd64.deb 2>/dev/null || apt-get install -f -y
    rm dive_0.11.0_linux_amd64.deb
    print_success "dive (image analysis) installed"

    echo ""
else
    print_info "Installing development tools..."

    # Install lazydocker (terminal UI for docker)
    curl -s https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    print_success "lazydocker (terminal UI) installed"

    echo ""
fi

# Verify Docker Compose installation
if docker compose version &> /dev/null; then
    COMPOSE_PLUGIN_VERSION=$(docker compose version --short)
    print_success "Docker Compose plugin v$COMPOSE_PLUGIN_VERSION verified"
fi

if command -v docker-compose &> /dev/null; then
    COMPOSE_STANDALONE_VERSION=$(docker-compose --version | awk '{print $4}' | tr -d ',')
    print_success "Docker Compose standalone $COMPOSE_STANDALONE_VERSION verified"
fi
echo ""

# Test Docker installation
print_info "Testing Docker installation..."
if docker run --rm hello-world > /dev/null 2>&1; then
    print_success "Docker test successful!"
else
    print_warning "Docker test failed, but installation completed. Try logging out and back in."
fi
echo ""

# Display installation summary
echo "========================================="
print_success "Docker Installation Complete!"
echo "========================================="
echo ""
echo "Environment: $INSTALL_ENV"
echo ""
echo "Installed Components:"
echo "  • Docker Engine: $DOCKER_VERSION"
echo "  • Docker Compose Plugin: v$COMPOSE_PLUGIN_VERSION"
echo "  • Docker Compose Standalone: $COMPOSE_STANDALONE_VERSION"

if [ "$INSTALL_ENV" = "production" ]; then
    echo "  • ctop: Container monitoring"
    echo "  • dive: Image layer analysis"
else
    echo "  • lazydocker: Terminal UI for Docker"
fi

echo ""

if [ "$INSTALL_ENV" = "production" ]; then
    echo "Production Configuration:"
    echo "  • Log rotation: 10MB max, 3 files"
    echo "  • Live restore: ENABLED"
    echo "  • Enhanced security settings applied"
    echo "  • Container isolation improved"
    echo ""
    print_warning "PRODUCTION SECURITY REMINDERS:"
    echo "  1. Configure firewall rules (ufw allow 2375/tcp for Docker API if needed)"
    echo "  2. Use Docker secrets for sensitive data"
    echo "  3. Scan images regularly: docker scan <image>"
    echo "  4. Use official images when possible"
    echo "  5. Keep Docker updated: apt update && apt upgrade docker-ce"
    echo "  6. Enable Docker Content Trust: export DOCKER_CONTENT_TRUST=1"
    echo ""
    echo "Production Tools:"
    echo "  • Monitor containers: ctop"
    echo "  • Analyze image size: dive <image>"
    echo "  • View logs: docker logs <container>"
    echo "  • Resource usage: docker stats"
else
    echo "Development Configuration:"
    echo "  • Log rotation: 100MB max, 5 files (verbose)"
    echo "  • All development tools included"
    echo ""
    echo "Development Tools:"
    echo "  • Terminal UI: lazydocker"
    echo "  • Quick commands: docker ps, docker logs, docker exec"
fi

echo ""
echo "Basic Docker Commands:"
echo "  • Check version: docker --version"
echo "  • List containers: docker ps"
echo "  • List images: docker images"
echo "  • Pull image: docker pull <image>"
echo "  • Run container: docker run <image>"
echo "  • Stop container: docker stop <container>"
echo "  • Remove container: docker rm <container>"
echo ""
echo "Docker Compose Commands:"
echo "  • Start services: docker compose up -d"
echo "  • Stop services: docker compose down"
echo "  • View logs: docker compose logs"
echo "  • Rebuild: docker compose build"
echo ""
print_warning "IMPORTANT: Log out and log back in for group permissions to take effect!"
echo "After logging back in, test with: docker run hello-world"
echo ""
print_success "Happy containerizing!"
