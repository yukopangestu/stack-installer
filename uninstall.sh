#!/bin/bash

# Stack Uninstaller - Main Menu
# Choose and uninstall different development stacks

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# Function to display banner
display_banner() {
    clear
    echo -e "${MAGENTA}"
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                                                       ║"
    echo "║         DEVELOPMENT STACK UNINSTALLER                ║"
    echo "║                                                       ║"
    echo "║      Remove installed stacks from your system       ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Function to display menu
display_menu() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Select Stack to Uninstall:${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} MERN Stack"
    echo -e "     ${YELLOW}→${NC} Remove MongoDB, global npm packages"
    echo ""
    echo -e "  ${GREEN}2)${NC} Docker"
    echo -e "     ${YELLOW}→${NC} Remove Docker Engine, containers, images, volumes"
    echo ""
    echo -e "  ${GREEN}3)${NC} Observability Stack"
    echo -e "     ${YELLOW}→${NC} Remove Prometheus, Grafana, Loki, Node Exporter"
    echo ""
    echo -e "  ${GREEN}4)${NC} Laravel Stack"
    echo -e "     ${YELLOW}→${NC} Remove PHP, Composer, MySQL, Nginx, Laravel project"
    echo ""
    echo -e "  ${RED}0)${NC} Exit"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to confirm uninstallation
confirm_uninstallation() {
    local stack_name=$1
    echo ""
    echo -e "${RED}⚠ WARNING ⚠${NC}"
    echo -e "${YELLOW}You are about to uninstall: ${RED}$stack_name${NC}"
    echo -e "${YELLOW}This will remove all associated packages, data, and configurations.${NC}"
    echo -e "${RED}This action cannot be undone!${NC}"
    echo ""
    read -p "Are you absolutely sure? (yes/no): " -n 3 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Uninstallation cancelled."
        return 1
    fi
    return 0
}

# Function to uninstall MERN stack
uninstall_mern() {
    if confirm_uninstallation "MERN Stack"; then
        print_header "Starting MERN Stack Uninstallation..."
        echo ""

        # Check if uninstall-mern.sh exists
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        if [ -f "$SCRIPT_DIR/uninstall-mern.sh" ]; then
            bash "$SCRIPT_DIR/uninstall-mern.sh"
        else
            print_error "uninstall-mern.sh not found in $SCRIPT_DIR"
            exit 1
        fi
    fi
}

# Function to uninstall Docker
uninstall_docker() {
    if confirm_uninstallation "Docker"; then
        print_header "Starting Docker Uninstallation..."
        echo ""

        # Check if uninstall-docker.sh exists
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        if [ -f "$SCRIPT_DIR/uninstall-docker.sh" ]; then
            bash "$SCRIPT_DIR/uninstall-docker.sh"
        else
            print_error "uninstall-docker.sh not found in $SCRIPT_DIR"
            exit 1
        fi
    fi
}

# Function to uninstall Observability Stack
uninstall_observability() {
    if confirm_uninstallation "Observability Stack"; then
        print_header "Starting Observability Stack Uninstallation..."
        echo ""

        # Check if uninstall-observability.sh exists
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        if [ -f "$SCRIPT_DIR/uninstall-observability.sh" ]; then
            bash "$SCRIPT_DIR/uninstall-observability.sh"
        else
            print_error "uninstall-observability.sh not found in $SCRIPT_DIR"
            exit 1
        fi
    fi
}

# Function to uninstall Laravel Stack
uninstall_laravel() {
    if confirm_uninstallation "Laravel Stack"; then
        print_header "Starting Laravel Stack Uninstallation..."
        echo ""

        # Check if uninstall-laravel.sh exists
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        if [ -f "$SCRIPT_DIR/uninstall-laravel.sh" ]; then
            bash "$SCRIPT_DIR/uninstall-laravel.sh"
        else
            print_error "uninstall-laravel.sh not found in $SCRIPT_DIR"
            exit 1
        fi
    fi
}

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo ""
    print_error "Please run this script with sudo"
    echo ""
    exit 1
fi

# Main loop
while true; do
    display_banner
    display_menu

    read -p "Enter your choice [0-4]: " choice

    case $choice in
        1)
            uninstall_mern
            ;;
        2)
            uninstall_docker
            ;;
        3)
            uninstall_observability
            ;;
        4)
            uninstall_laravel
            ;;
        0)
            echo ""
            print_success "Thank you for using Stack Uninstaller!"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            print_error "Invalid choice. Please enter a number between 0 and 4."
            echo ""
            sleep 2
            ;;
    esac

    # If uninstallation completed, ask to continue
    if [ $? -eq 0 ] && [ "$choice" != "0" ]; then
        echo ""
        echo ""
        read -p "Press any key to return to menu..." -n 1 -r
    fi
done
