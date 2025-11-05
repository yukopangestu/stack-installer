#!/bin/bash
set -e  # Exit on error

# Get environment parameter
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
INSTALL_ENV=${1:-development}

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

print_header "Observability Stack Installation"
echo "Environment: $INSTALL_ENV"
echo "User: $ACTUAL_USER"
echo "Home: $ACTUAL_HOME"
echo ""

# Environment-specific configuration
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Production mode: Enhanced security, authentication enabled, optimized retention"
    GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 24)
    PROMETHEUS_RETENTION="30d"
    LOKI_RETENTION="30d"
    ENABLE_AUTH=true
else
    print_info "Development mode: Basic setup, admin/admin credentials, default retention"
    GRAFANA_ADMIN_PASSWORD="admin"
    PROMETHEUS_RETENTION="15d"
    LOKI_RETENTION="7d"
    ENABLE_AUTH=false
fi

# Update system
print_info "Updating system packages..."
apt-get update -y > /dev/null 2>&1
print_success "System packages updated"

# Install prerequisites
print_info "Installing prerequisites..."
apt-get install -y wget curl tar adduser libfontconfig1 > /dev/null 2>&1
print_success "Prerequisites installed"

# Create system users and directories
print_info "Creating system users and directories..."
for user in prometheus grafana loki promtail; do
    if ! id "$user" &>/dev/null; then
        useradd --no-create-home --shell /bin/false $user
    fi
done
print_success "System users created"

# Install Prometheus
print_header "Installing Prometheus"
PROM_VERSION="2.48.0"
print_info "Downloading Prometheus $PROM_VERSION..."
cd /tmp
wget -q https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar -xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

print_info "Installing Prometheus binaries..."
cp prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
cp prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

# Create Prometheus directories
mkdir -p /etc/prometheus /var/lib/prometheus
cp -r prometheus-${PROM_VERSION}.linux-amd64/consoles /etc/prometheus/
cp -r prometheus-${PROM_VERSION}.linux-amd64/console_libraries /etc/prometheus/
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Create Prometheus configuration
cat > /etc/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'loki'
    static_configs:
      - targets: ['localhost:3100']

  - job_name: 'promtail'
    static_configs:
      - targets: ['localhost:9080']
EOF

chown prometheus:prometheus /etc/prometheus/prometheus.yml
rm -rf /tmp/prometheus-${PROM_VERSION}.linux-amd64*
print_success "Prometheus installed"

# Create Prometheus systemd service
print_info "Creating Prometheus service..."
cat > /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/ \\
  --storage.tsdb.retention.time=${PROMETHEUS_RETENTION} \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable prometheus > /dev/null 2>&1
systemctl start prometheus
print_success "Prometheus service started"

# Install Node Exporter
print_header "Installing Node Exporter"
NODE_EXPORTER_VERSION="1.7.0"
print_info "Downloading Node Exporter $NODE_EXPORTER_VERSION..."
cd /tmp
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar -xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

print_info "Installing Node Exporter..."
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/node_exporter
rm -rf /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*

# Create Node Exporter service
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter > /dev/null 2>&1
systemctl start node_exporter
print_success "Node Exporter service started"

# Install Grafana
print_header "Installing Grafana"
print_info "Adding Grafana repository..."
apt-get install -y software-properties-common > /dev/null 2>&1
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list > /dev/null

print_info "Installing Grafana..."
apt-get update -y > /dev/null 2>&1
apt-get install -y grafana > /dev/null 2>&1

# Configure Grafana
if [ "$INSTALL_ENV" = "production" ]; then
    print_info "Configuring Grafana for production..."
    cat >> /etc/grafana/grafana.ini << EOF

[security]
admin_user = admin
admin_password = $GRAFANA_ADMIN_PASSWORD
disable_gravatar = true
cookie_secure = true
strict_transport_security = true

[auth.anonymous]
enabled = false

[users]
allow_sign_up = false
EOF
else
    print_info "Configuring Grafana for development..."
    cat >> /etc/grafana/grafana.ini << EOF

[security]
admin_user = admin
admin_password = admin

[auth.anonymous]
enabled = true
EOF
fi

systemctl daemon-reload
systemctl enable grafana-server > /dev/null 2>&1
systemctl start grafana-server
print_success "Grafana installed and started"

# Install Loki
print_header "Installing Loki"
LOKI_VERSION="2.9.3"
print_info "Downloading Loki $LOKI_VERSION..."
cd /tmp
wget -q https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip
apt-get install -y unzip > /dev/null 2>&1
unzip -q loki-linux-amd64.zip

print_info "Installing Loki..."
mv loki-linux-amd64 /usr/local/bin/loki
chown loki:loki /usr/local/bin/loki

# Create Loki directories
mkdir -p /etc/loki /var/lib/loki
chown -R loki:loki /etc/loki /var/lib/loki

# Create Loki configuration
cat > /etc/loki/loki-config.yml << EOF
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  path_prefix: /var/lib/loki
  storage:
    filesystem:
      chunks_directory: /var/lib/loki/chunks
      rules_directory: /var/lib/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

limits_config:
  retention_period: ${LOKI_RETENTION}
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

compactor:
  working_directory: /var/lib/loki/compactor
  shared_store: filesystem
  compaction_interval: 10m
  retention_enabled: true
  retention_delete_delay: 2h
  retention_delete_worker_count: 150
EOF

chown loki:loki /etc/loki/loki-config.yml
rm -f /tmp/loki-linux-amd64.zip

# Create Loki service
cat > /etc/systemd/system/loki.service << 'EOF'
[Unit]
Description=Loki
Wants=network-online.target
After=network-online.target

[Service]
User=loki
Group=loki
Type=simple
ExecStart=/usr/local/bin/loki -config.file=/etc/loki/loki-config.yml

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable loki > /dev/null 2>&1
systemctl start loki
print_success "Loki service started"

# Install Promtail
print_header "Installing Promtail"
print_info "Downloading Promtail $LOKI_VERSION..."
cd /tmp
wget -q https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/promtail-linux-amd64.zip
unzip -q promtail-linux-amd64.zip

print_info "Installing Promtail..."
mv promtail-linux-amd64 /usr/local/bin/promtail
chown promtail:promtail /usr/local/bin/promtail

# Create Promtail directories
mkdir -p /etc/promtail
chown -R promtail:promtail /etc/promtail

# Create Promtail configuration
cat > /etc/promtail/promtail-config.yml << 'EOF'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log

  - job_name: syslog
    static_configs:
      - targets:
          - localhost
        labels:
          job: syslog
          __path__: /var/log/syslog
EOF

chown promtail:promtail /etc/promtail/promtail-config.yml
rm -f /tmp/promtail-linux-amd64.zip

# Create Promtail service
cat > /etc/systemd/system/promtail.service << 'EOF'
[Unit]
Description=Promtail
Wants=network-online.target
After=network-online.target

[Service]
User=promtail
Group=promtail
Type=simple
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/promtail-config.yml

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable promtail > /dev/null 2>&1
systemctl start promtail
print_success "Promtail service started"

# Configure Grafana datasources
print_header "Configuring Grafana Datasources"
print_info "Waiting for Grafana to be ready..."
sleep 5

# Add Prometheus datasource
cat > /tmp/prometheus-datasource.json << 'EOF'
{
  "name": "Prometheus",
  "type": "prometheus",
  "access": "proxy",
  "url": "http://localhost:9090",
  "isDefault": true,
  "jsonData": {
    "timeInterval": "15s"
  }
}
EOF

# Add Loki datasource
cat > /tmp/loki-datasource.json << 'EOF'
{
  "name": "Loki",
  "type": "loki",
  "access": "proxy",
  "url": "http://localhost:3100"
}
EOF

print_info "Adding datasources to Grafana..."
curl -s -X POST -H "Content-Type: application/json" -d @/tmp/prometheus-datasource.json http://admin:${GRAFANA_ADMIN_PASSWORD}@localhost:3000/api/datasources > /dev/null 2>&1 || true
curl -s -X POST -H "Content-Type: application/json" -d @/tmp/loki-datasource.json http://admin:${GRAFANA_ADMIN_PASSWORD}@localhost:3000/api/datasources > /dev/null 2>&1 || true
rm -f /tmp/prometheus-datasource.json /tmp/loki-datasource.json
print_success "Datasources configured"

# Save credentials in production
if [ "$INSTALL_ENV" = "production" ]; then
    CREDS_FILE="$ACTUAL_HOME/observability-credentials.txt"
    cat > "$CREDS_FILE" << EOF
Observability Stack Credentials
================================

Grafana Admin:
  Username: admin
  Password: $GRAFANA_ADMIN_PASSWORD
  URL: http://localhost:3000

IMPORTANT:
- Change the admin password immediately after first login
- Configure firewall rules to restrict access
- Enable HTTPS in production environments
- Set up proper backup procedures for metrics and logs

Created: $(date)
EOF
    chown $ACTUAL_USER:$ACTUAL_USER "$CREDS_FILE"
    chmod 600 "$CREDS_FILE"
    print_warning "Production credentials saved to: $CREDS_FILE"
fi

# Installation summary
print_header "Installation Complete!"

echo -e "${GREEN}Components Installed:${NC}"
echo "  • Prometheus (metrics collection) - http://localhost:9090"
echo "  • Node Exporter (system metrics) - http://localhost:9100"
echo "  • Grafana (visualization) - http://localhost:3000"
echo "  • Loki (log aggregation) - http://localhost:3100"
echo "  • Promtail (log shipper)"
echo ""

echo -e "${GREEN}Service Status:${NC}"
for service in prometheus node_exporter grafana-server loki promtail; do
    if systemctl is-active --quiet $service; then
        print_success "$service is running"
    else
        print_error "$service is not running"
    fi
done
echo ""

echo -e "${GREEN}Access Information:${NC}"
echo "  • Grafana: http://localhost:3000"
if [ "$INSTALL_ENV" = "production" ]; then
    echo "    - Username: admin"
    echo "    - Password: (saved in $ACTUAL_HOME/observability-credentials.txt)"
else
    echo "    - Username: admin"
    echo "    - Password: admin"
fi
echo "  • Prometheus: http://localhost:9090"
echo "  • Node Exporter: http://localhost:9100/metrics"
echo ""

echo -e "${GREEN}Configuration:${NC}"
echo "  • Environment: $INSTALL_ENV"
echo "  • Prometheus Retention: $PROMETHEUS_RETENTION"
echo "  • Loki Retention: $LOKI_RETENTION"
echo "  • Prometheus Config: /etc/prometheus/prometheus.yml"
echo "  • Loki Config: /etc/loki/loki-config.yml"
echo "  • Grafana Config: /etc/grafana/grafana.ini"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Access Grafana at http://localhost:3000"
echo "  2. Log in with admin credentials"
if [ "$INSTALL_ENV" = "production" ]; then
    echo "  3. Change the admin password immediately"
fi
echo "  3. Explore pre-configured datasources (Prometheus & Loki)"
echo "  4. Import dashboards from grafana.com/dashboards"
echo "     - Node Exporter Full: Dashboard ID 1860"
echo "     - Loki Logs: Dashboard ID 13639"
echo "  5. Configure alerting rules in Prometheus"
echo ""

if [ "$INSTALL_ENV" = "production" ]; then
    echo -e "${BLUE}Production Security Reminders:${NC}"
    echo "  • Change default admin password"
    echo "  • Configure firewall (ufw allow 3000/tcp for Grafana)"
    echo "  • Set up reverse proxy with SSL/TLS"
    echo "  • Configure authentication (LDAP/OAuth)"
    echo "  • Set up regular backups for /var/lib/grafana"
    echo "  • Monitor disk usage for metrics/logs storage"
    echo "  • Review and adjust retention policies"
    echo ""
fi

print_success "Observability stack installation completed successfully!"
