#!/bin/bash

# DevOps Tools Installation Script for CentOS
# This script installs various DevOps tools and services on CentOS
# It requires root privileges or a user with sudo access

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Array to track installation status
declare -A installation_status

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}This script needs to be run as root or with sudo privileges.${NC}"
  exit 1
fi

# Function to log messages
log() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Function to handle installation results
handle_result() {
  local component=$1
  local status=$2
  
  if [ "$status" -eq 0 ]; then
    installation_status["$component"]="Installed"
    echo -e "${GREEN}✓ $component installation successful${NC}"
  else
    installation_status["$component"]="Failed"
    echo -e "${RED}✗ $component installation failed with error code $status${NC}"
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Update the system
log "Updating the system..."
yum upgrade -y
handle_result "System Update" $?

# Check and install SSH if not installed
log "Checking for SSH..."
if ! command_exists ssh; then
  log "Installing SSH..."
  yum install -y openssh-server openssh-clients
  handle_result "SSH" $?
  
  # SSH service is available but not started
  echo "SSH service installed but not started (as requested)"
else
  installation_status["SSH"]="Already installed"
  echo -e "${GREEN}✓ SSH is already installed${NC}"
fi

# Install Docker
log "Installing Docker..."
if ! command_exists docker; then
  # Install required packages
  yum install -y yum-utils device-mapper-persistent-data lvm2
  
  # Add Docker repository
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  
  # Install Docker packages
  yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  handle_result "Docker" $?
  
  # Docker service is available but not started
  echo "Docker service installed but not started (as requested)"
else
  installation_status["Docker"]="Already installed"
  echo -e "${GREEN}✓ Docker is already installed${NC}"
fi

# Install Kubernetes tools (kubectl)
log "Installing Kubernetes tools..."
if ! command_exists kubectl; then
  # Add Kubernetes repository
  cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/repodata/repomd.xml.key
EOF
  
  # Install kubectl
  yum install -y kubectl
  handle_result "Kubernetes (kubectl)" $?
else
  installation_status["Kubernetes (kubectl)"]="Already installed"
  echo -e "${GREEN}✓ kubectl is already installed${NC}"
fi

# Install Minikube
log "Installing Minikube..."
if ! command_exists minikube; then
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
  rpm -Uvh minikube-latest.x86_64.rpm
  handle_result "Minikube" $?
  rm -f minikube-latest.x86_64.rpm
else
  installation_status["Minikube"]="Already installed"
  echo -e "${GREEN}✓ Minikube is already installed${NC}"
fi

# Install Jenkins and Java
log "Installing Jenkins and Java..."
if ! command_exists jenkins; then
  # Add Jenkins repository
  wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  
  # Install Java 21
  yum install -y fontconfig java-21-openjdk
  handle_result "Java 21" $?
  
  # Install Jenkins
  yum install -y jenkins
  handle_result "Jenkins" $?
  
  # Reload systemd but don't start Jenkins
  systemctl daemon-reload
  echo "Jenkins service installed but not started (as requested)"
else
  installation_status["Jenkins"]="Already installed"
  echo -e "${GREEN}✓ Jenkins is already installed${NC}"
fi

# Install Nginx
log "Installing Nginx..."
if ! command_exists nginx; then
  # Install yum-utils if not already installed
  yum install -y yum-utils
  
  # Create Nginx repository file
  cat <<EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
  
  # Install Nginx
  yum install -y nginx
  handle_result "Nginx" $?
  
  # Nginx service is available but not started
  echo "Nginx service installed but not started (as requested)"
else
  installation_status["Nginx"]="Already installed"
  echo -e "${GREEN}✓ Nginx is already installed${NC}"
fi

# Install Apache (httpd)
log "Installing Apache (httpd)..."
if ! command_exists httpd; then
  yum update -y httpd
  yum install -y httpd
  handle_result "Apache (httpd)" $?
  
  # httpd service is available but not started
  echo "Apache (httpd) service installed but not started (as requested)"
else
  installation_status["Apache (httpd)"]="Already installed"
  echo -e "${GREEN}✓ Apache (httpd) is already installed${NC}"
fi

# Install Python 3.11
log "Installing Python 3.11..."
if ! command -v python3.11 &> /dev/null; then
  # Install dependencies
  yum install -y openssl-devel bzip2-devel libffi-devel
  yum groupinstall -y "Development Tools"
  
  # Download and extract Python source
  wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0a4.tgz
  
  if [ $? -eq 0 ]; then
    tar -xzf Python-3.11.0a4.tgz
    cd Python-3.11.0a4
    
    # Configure and install Python
    ./configure --enable-optimizations
    make altinstall
    handle_result "Python 3.11" $?
    
    # Clean up
    cd ..
    rm -rf Python-3.11.0a4*
  else
    handle_result "Python 3.11" 1
  fi
else
  installation_status["Python 3.11"]="Already installed"
  echo -e "${GREEN}✓ Python 3.11 is already installed${NC}"
fi

# Install Terraform
log "Installing Terraform..."
if ! command_exists terraform; then
  # Install yum-utils if not already installed
  yum install -y yum-utils
  
  # Add HashiCorp repository
  yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  
  # Install Terraform
  yum install -y terraform
  handle_result "Terraform" $?
else
  installation_status["Terraform"]="Already installed"
  echo -e "${GREEN}✓ Terraform is already installed${NC}"
fi

# Install Ansible
log "Installing Ansible..."
if ! command_exists ansible; then
  # Install EPEL repository if not already installed
  yum install -y epel-release
  
  # Install Ansible
  yum install -y ansible
  handle_result "Ansible" $?
else
  installation_status["Ansible"]="Already installed"
  echo -e "${GREEN}✓ Ansible is already installed${NC}"
fi

# Print installation summary
echo
echo "==========================="
echo "   INSTALLATION SUMMARY    "
echo "==========================="
for component in "${!installation_status[@]}"; do
  status="${installation_status[$component]}"
  if [ "$status" == "Installed" ] || [ "$status" == "Already installed" ]; then
    echo -e "${GREEN}✓ $component: $status${NC}"
  else
    echo -e "${RED}✗ $component: $status${NC}"
  fi
done
echo "==========================="

# Note about service activation
echo -e "${YELLOW}NOTE: All services were installed but not started as requested.${NC}"
echo -e "${YELLOW}      Use 'systemctl start <service-name>' to start a service when needed.${NC}"

# Service activation instructions
echo
echo "==========================="
echo "   SERVICE START COMMANDS  "
echo "==========================="
echo -e "To start SSH:          ${GREEN}systemctl start sshd${NC}"
echo -e "To start Docker:       ${GREEN}systemctl start docker${NC}"
echo -e "To start Jenkins:      ${GREEN}systemctl start jenkins${NC}"
echo -e "To start Nginx:        ${GREEN}systemctl start nginx${NC}"
echo -e "To start Apache:       ${GREEN}systemctl start httpd${NC}"

echo
echo -e "${YELLOW}To enable services to start automatically on boot:${NC}"
echo -e "For example:         ${GREEN}systemctl enable docker${NC}"
echo
echo -e "${YELLOW}To check status of any service:${NC}"
echo -e "For example:         ${GREEN}systemctl status jenkins${NC}"
echo "==========================="

echo
echo -e "${GREEN}Installation process completed!${NC}"
