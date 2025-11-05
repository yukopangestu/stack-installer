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

print_header "Observability Stack Uninstaller"
echo -e "${YELLOW}This will remove:${NC}"
echo "  • Prometheus and all metrics data"
echo "  • Grafana and all dashboards"
echo "  • Loki and all log data"
echo "  • Promtail"
echo "  • Node Exporter"
echo "  • All system users (prometheus, grafana, loki, promtail)"
echo "  • All configuration files"
echo ""
echo -e "${RED}WARNING: This action cannot be undone!${NC}"
echo -e "${RED}All metrics and logs will be permanently deleted!${NC}"
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

print_header "Starting Observability Stack Uninstallation"

# Stop and disable services
print_info "Stopping services..."
systemctl stop prometheus 2>/dev/null || true
systemctl stop node_exporter 2>/dev/null || true
systemctl stop grafana-server 2>/dev/null || true
systemctl stop loki 2>/dev/null || true
systemctl stop promtail 2>/dev/null || true

systemctl disable prometheus 2>/dev/null || true
systemctl disable node_exporter 2>/dev/null || true
systemctl disable grafana-server 2>/dev/null || true
systemctl disable loki 2>/dev/null || true
systemctl disable promtail 2>/dev/null || true
print_success "Services stopped and disabled"

# Remove systemd service files
print_info "Removing systemd service files..."
rm -f /etc/systemd/system/prometheus.service
rm -f /etc/systemd/system/node_exporter.service
rm -f /etc/systemd/system/loki.service
rm -f /etc/systemd/system/promtail.service
systemctl daemon-reload
print_success "Systemd service files removed"

# Remove Prometheus
print_header "Removing Prometheus"
print_info "Removing Prometheus binaries and data..."
rm -f /usr/local/bin/prometheus
rm -f /usr/local/bin/promtool
rm -rf /etc/prometheus
rm -rf /var/lib/prometheus
print_success "Prometheus removed"

# Remove Node Exporter
print_info "Removing Node Exporter..."
rm -f /usr/local/bin/node_exporter
print_success "Node Exporter removed"

# Remove Grafana
print_header "Removing Grafana"
print_info "Removing Grafana package and data..."
apt-get remove --purge -y grafana 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
rm -f /etc/apt/sources.list.d/grafana.list
rm -f /usr/share/keyrings/grafana.key
rm -rf /etc/grafana
rm -rf /var/lib/grafana
rm -rf /var/log/grafana
print_success "Grafana removed"

# Remove Loki
print_header "Removing Loki"
print_info "Removing Loki binaries and data..."
rm -f /usr/local/bin/loki
rm -rf /etc/loki
rm -rf /var/lib/loki
print_success "Loki removed"

# Remove Promtail
print_info "Removing Promtail..."
rm -f /usr/local/bin/promtail
rm -rf /etc/promtail
print_success "Promtail removed"

# Remove system users
print_header "Removing System Users"
print_info "Removing observability system users..."
for user in prometheus grafana loki promtail; do
    if id "$user" &>/dev/null; then
        userdel $user 2>/dev/null || true
        print_success "$user user removed"
    fi
done

# Remove credentials file
if [ -f "$ACTUAL_HOME/observability-credentials.txt" ]; then
    print_info "Removing credentials file..."
    rm -f "$ACTUAL_HOME/observability-credentials.txt"
    print_success "Credentials file removed"
fi

# Clean up
print_info "Cleaning up..."
apt-get autoremove -y > /dev/null 2>&1 || true
apt-get autoclean -y > /dev/null 2>&1 || true
print_success "Cleanup completed"

print_header "Uninstallation Complete!"
print_success "Observability stack has been completely removed from your system"
echo ""
print_info "The following ports are now available: 3000, 9090, 9100, 3100, 9080"
echo ""
