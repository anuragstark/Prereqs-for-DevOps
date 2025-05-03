# DevOps Tools Installation Script for CentOS

A comprehensive bash script for installing essential DevOps tools and services on CentOS systems. This script automates the installation of multiple development and operations tools with robust error handling and detailed reporting.

## 🛠️ Tools Installed

This script installs the following DevOps tools:

- **SSH Server & Client** - Secure Shell for remote access
- **Docker** - Container platform
- **Kubernetes (kubectl)** - Container orchestration CLI tool
- **Minikube** - Local Kubernetes environment
- **Jenkins** - Continuous Integration/Continuous Deployment server
- **Java 21** - Required for Jenkins
- **Nginx** - Web server and reverse proxy
- **Apache (httpd)** - Web server
- **Python 3.11** - Programming language
- **Terraform** - Infrastructure as Code tool
- **Ansible** - Configuration management and automation tool

## 📋 Requirements

- CentOS Linux (tested on CentOS 7 and 8)
- Root access or sudo privileges
- Internet connection for downloading packages

## 🚀 Usage

### Basic Installation

1. Clone this repository or download the script:
   ```bash
   git clone https://github.com/yourusername/devops-installer.git
   cd devops-installer
   ```

2. Make the script executable:
   ```bash
   chmod +x install_devops_tools.sh
   ```

3. Run the script with root privileges:
   ```bash
   sudo ./install_devops_tools.sh
   ```

### Post-Installation

The script installs all services but does not start them automatically. After installation, you can:

- Start a specific service:
  ```bash
  systemctl start <service-name>
  ```
  
- Enable a service to start on boot:
  ```bash
  systemctl enable <service-name>
  ```

- Check service status:
  ```bash
  systemctl status <service-name>
  ```

## ✨ Features

- **No-start installation**: Installs all services without starting them
- **Comprehensive error handling**: Catches and reports installation failures
- **Installation status tracking**: Shows which components were successfully installed
- **Duplicate prevention**: Detects already installed components
- **Color-coded output**: Improves readability of installation progress and results
- **Service management reference**: Provides commands for managing installed services

## 📝 Installation Summary

At the end of the installation, the script provides:

1. A detailed summary of all installation attempts and their results
2. Reference commands for starting each installed service
3. Instructions on enabling services and checking their status

## 🔧 Customization

You can modify the script to:

- Install specific versions of packages
- Add or remove components
- Change installation directories
- Automatically start specific services

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This script is provided as-is with no warranties. Always test in a non-production environment before using in production.
