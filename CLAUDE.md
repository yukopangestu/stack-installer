# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Stack Installer is an interactive bash-based installation system for development stacks on Ubuntu/Debian systems. It provides a menu-driven interface for installing complete development environments with environment-specific configurations (development vs production).

## Architecture

### Three-Layer Structure

1. **Main Menu (`install.sh`)**
   - Entry point for all installations
   - Displays interactive menu with 9 stack options (currently 2 implemented: MERN, Docker)
   - Handles environment selection (development/production)
   - Invokes individual stack installers with environment parameter

2. **Stack Installers (`install-*.sh`)**
   - Individual installation scripts for each stack
   - Accept environment parameter: `development` (default) or `production`
   - Must be executable (`chmod +x`)
   - Follow consistent structure with colored output functions

3. **Environment-Based Configuration**
   - Development: Dev tools, no authentication, verbose logging, easier debugging
   - Production: Security hardened, authentication enabled, optimized settings, monitoring tools

### Script Invocation Pattern

```bash
# Main menu calls stack installer with environment
bash "$SCRIPT_DIR/install-<stack>.sh" "$INSTALL_ENV"

# Stack installer receives environment as first argument
INSTALL_ENV=${1:-development}
```

## File Structure

```
install.sh              # Main interactive menu
install-mern.sh         # MERN stack installer
install-docker.sh       # Docker installer
README.md               # User documentation
LICENSE                 # MIT License
```

## Testing the Scripts

### Syntax Check (No Installation)
```bash
bash -n install.sh
bash -n install-mern.sh
bash -n install-docker.sh
```

### Interactive Menu Test
```bash
sudo ./install.sh
# Press 0 to exit without installing
```

### Direct Stack Installation
```bash
# Development (default)
sudo ./install-mern.sh
sudo ./install-docker.sh

# Production
sudo ./install-mern.sh production
sudo ./install-docker.sh production
```

### Testing Environment
- **Target OS**: Ubuntu 20.04+, Debian 11+
- **Requires**: sudo privileges
- **Recommended**: Test in WSL, Docker container, or VM before production use

## Adding a New Stack

### 1. Create Stack Installer Script

```bash
# Create new file: install-<stackname>.sh
touch install-<stackname>.sh
chmod +x install-<stackname>.sh
```

### 2. Required Script Structure

```bash
#!/bin/bash
set -e  # Exit on error

# Get environment parameter
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
INSTALL_ENV=${1:-development}

# Check sudo
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script with sudo"
    exit 1
fi

# Environment-specific configuration
if [ "$INSTALL_ENV" = "production" ]; then
    # Production configuration
else
    # Development configuration
fi

# Installation summary
echo "Environment: $INSTALL_ENV"
```

### 3. Use Standard Output Functions

All stack installers must define and use:
- `print_success()` - Green checkmark for success
- `print_error()` - Red X for errors
- `print_info()` - Yellow arrow for information
- `print_warning()` - Blue warning symbol

### 4. Add to Main Menu

In `install.sh`:

1. Add menu entry in `display_menu()`:
```bash
echo -e "  ${GREEN}X)${NC} Your Stack Name"
echo -e "     ${YELLOW}→${NC} Brief description"
```

2. Create installer function:
```bash
install_yourstack() {
    select_environment
    if confirm_installation "Your Stack Name"; then
        print_header "Starting Your Stack Installation..."
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        if [ -f "$SCRIPT_DIR/install-yourstack.sh" ]; then
            bash "$SCRIPT_DIR/install-yourstack.sh" "$INSTALL_ENV"
        else
            print_error "install-yourstack.sh not found in $SCRIPT_DIR"
            exit 1
        fi
    fi
}
```

3. Add case in main loop:
```bash
X)
    install_yourstack
    ;;
```

4. Update choice range: `read -p "Enter your choice [0-X]: " choice`

### 5. Update Documentation

- Add stack to README.md under "Currently Implemented"
- Document environment-specific differences
- Add stack-specific troubleshooting section
- Update individual installation examples

## Development vs Production Patterns

### MERN Stack Pattern

**Development:**
- MongoDB: No authentication
- Packages: `create-react-app`, `nodemon`, `express-generator`
- NODE_ENV: development (default)

**Production:**
- MongoDB: Auth enabled with auto-generated credentials
- Credentials saved to: `~/mongodb-credentials.txt`
- Packages: `pm2`, `express-generator`
- NODE_ENV: production (set in `.bashrc`)
- Security: Operation profiling, optimized config

### Docker Pattern

**Development:**
- Tools: `lazydocker` (terminal UI)
- Logs: 100MB max, 5 files (verbose)
- Standard daemon config

**Production:**
- Tools: `ctop` (monitoring), `dive` (image analysis)
- Logs: 10MB max, 3 files (optimized)
- Security: Live restore enabled, ICC disabled, no-new-privileges
- Config: `/etc/docker/daemon.json` with production settings

## Important Implementation Notes

### User Permissions
- Scripts must run with `sudo` (check `$EUID`)
- Always use `ACTUAL_USER=${SUDO_USER:-$USER}` to get real user
- Install user-specific tools (like NVM) as actual user: `su - $ACTUAL_USER -c "command"`
- Set ownership correctly: `chown $ACTUAL_USER:$ACTUAL_USER <file>`

### Service Management
```bash
# Start and enable services
systemctl start <service>
systemctl enable <service>

# Verify service is running
systemctl is-active --quiet <service>
```

### Configuration Files
- Production configs often need backup: `cp original original.backup`
- Use heredoc for multi-line configs: `cat > file << 'EOF'`
- Production credentials should be chmod 600 with proper ownership

### Package Installation
- Always update first: `apt-get update -y`
- Use `-y` flag for non-interactive: `apt-get install -y <package>`
- Verify installation: `command -v <binary>`

## Git Workflow

### Committing Changes
```bash
git add <files>
git commit -m "descriptive message

Detailed explanation of changes

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin main
```

### Branch Strategy
- Main branch: `main`
- All development happens on main (small project)

## Common Pitfalls

1. **Forgetting to make scripts executable**: Always `chmod +x install-*.sh`
2. **Not testing environment parameter**: Test both `development` and `production` modes
3. **Hardcoding user paths**: Use `$ACTUAL_HOME` instead of hardcoded paths
4. **Missing sudo check**: Always verify script runs with proper privileges
5. **Not handling service failures**: Check service status after starting
6. **Inconsistent menu numbering**: Update all references when adding new options
7. **Missing documentation**: Update README.md when adding new stacks

## Security Considerations

### Production Installations Must:
- Enable authentication where applicable (databases, services)
- Generate strong random passwords: `openssl rand -base64 32`
- Save credentials securely with restricted permissions (chmod 600)
- Configure log rotation to prevent disk space issues
- Apply security hardening (disable unnecessary features, restrict network access)
- Provide security reminders in installation summary

### Never:
- Commit credentials or secrets
- Use default/weak passwords
- Skip security configurations in production mode
- Leave authentication disabled in production

## Target Audience

This project is designed for:
- Developers setting up local development environments (WSL, Linux VMs)
- DevOps engineers preparing production servers
- Users who need quick, consistent stack installations
- Learning environments and bootcamps

The installer assumes basic Linux knowledge but automates complex configuration tasks.
