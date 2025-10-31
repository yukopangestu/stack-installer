#!/bin/bash

# Stack Installer - Main Menu
# Choose and install different development stacks

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
    echo "║           DEVELOPMENT STACK INSTALLER                ║"
    echo "║                                                       ║"
    echo "║       Automated installation for popular stacks      ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Function to display menu
display_menu() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Available Stacks:${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} MERN Stack"
    echo -e "     ${YELLOW}→${NC} MongoDB + Express.js + React + Node.js (via NVM)"
    echo ""
    echo -e "  ${GREEN}2)${NC} MEAN Stack"
    echo -e "     ${YELLOW}→${NC} MongoDB + Express.js + Angular + Node.js (via NVM)"
    echo ""
    echo -e "  ${GREEN}3)${NC} LAMP Stack"
    echo -e "     ${YELLOW}→${NC} Linux + Apache + MySQL + PHP"
    echo ""
    echo -e "  ${GREEN}4)${NC} LEMP Stack"
    echo -e "     ${YELLOW}→${NC} Linux + Nginx + MySQL + PHP"
    echo ""
    echo -e "  ${GREEN}5)${NC} Django Stack"
    echo -e "     ${YELLOW}→${NC} Python + Django + PostgreSQL"
    echo ""
    echo -e "  ${GREEN}6)${NC} Ruby on Rails Stack"
    echo -e "     ${YELLOW}→${NC} Ruby + Rails + PostgreSQL"
    echo ""
    echo -e "  ${GREEN}7)${NC} Full Stack JavaScript (PERN)"
    echo -e "     ${YELLOW}→${NC} PostgreSQL + Express.js + React + Node.js (via NVM)"
    echo ""
    echo -e "  ${GREEN}8)${NC} JAMstack"
    echo -e "     ${YELLOW}→${NC} Next.js + Node.js (via NVM) + Git"
    echo ""
    echo -e "  ${RED}0)${NC} Exit"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to select environment type
select_environment() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Select Environment Type:${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Development Environment"
    echo -e "     ${YELLOW}→${NC} Includes all dev tools, relaxed security, easier debugging"
    echo ""
    echo -e "  ${GREEN}2)${NC} Production Environment"
    echo -e "     ${YELLOW}→${NC} Optimized performance, enhanced security, production-ready"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""

    while true; do
        read -p "Enter your choice [1-2]: " env_choice
        case $env_choice in
            1)
                INSTALL_ENV="development"
                print_info "Selected: Development Environment"
                return 0
                ;;
            2)
                INSTALL_ENV="production"
                print_info "Selected: Production Environment"
                return 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
}

# Function to confirm installation
confirm_installation() {
    local stack_name=$1
    echo ""
    echo -e "${YELLOW}You are about to install: ${GREEN}$stack_name${NC}"
    echo -e "${YELLOW}Environment: ${GREEN}$INSTALL_ENV${NC}"
    echo -e "${YELLOW}This will install multiple packages and may take several minutes.${NC}"
    echo ""
    read -p "Do you want to continue? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled."
        return 1
    fi
    return 0
}

# Function to install MERN stack
install_mern() {
    # Select environment type first
    select_environment

    if confirm_installation "MERN Stack"; then
        print_header "Starting MERN Stack Installation..."
        echo ""

        # Check if install-mern.sh exists
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        if [ -f "$SCRIPT_DIR/install-mern.sh" ]; then
            bash "$SCRIPT_DIR/install-mern.sh" "$INSTALL_ENV"
        else
            print_error "install-mern.sh not found in $SCRIPT_DIR"
            exit 1
        fi
    fi
}

# Function for not yet implemented stacks
coming_soon() {
    local stack_name=$1
    print_info "$stack_name installation is coming soon!"
    echo ""
    read -p "Press any key to return to menu..." -n 1 -r
}

# Main loop
while true; do
    display_banner
    display_menu

    read -p "Enter your choice [0-8]: " choice

    case $choice in
        1)
            install_mern
            ;;
        2)
            coming_soon "MEAN Stack"
            ;;
        3)
            coming_soon "LAMP Stack"
            ;;
        4)
            coming_soon "LEMP Stack"
            ;;
        5)
            coming_soon "Django Stack"
            ;;
        6)
            coming_soon "Ruby on Rails Stack"
            ;;
        7)
            coming_soon "PERN Stack"
            ;;
        8)
            coming_soon "JAMstack"
            ;;
        0)
            echo ""
            print_success "Thank you for using Stack Installer!"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            print_error "Invalid choice. Please enter a number between 0 and 8."
            echo ""
            sleep 2
            ;;
    esac

    # If installation completed, ask to continue
    if [ $? -eq 0 ] && [ "$choice" != "0" ]; then
        echo ""
        echo ""
        read -p "Press any key to return to menu..." -n 1 -r
    fi
done
