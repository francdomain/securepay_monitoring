# SecurePay FinTech - Transaction Monitoring & Compliance System

## 📋 Project Overview
A comprehensive Linux-based security and monitoring system for financial institutions. This project simulates a real-world FinTech environment with focus on transaction monitoring, fraud detection, user compliance, and audit trails.

## 🎯 Learning Objectives
This project covers:
- **Terminal Navigation** - File system exploration and management
- **Filesystem Hierarchy** - Linux directory structure best practices
- **File Operations** - Creating, modifying, and securing financial data
- **Permissions** - Implementing least-privilege access control
- **Users & Groups** - Role-based access control (RBAC)
- **Shell Scripting** - Bash scripting with variables and loops
- **Functions & Error Handling** - Professional error management
- **Process Management** - Monitoring and controlling financial processes

## 🏗️ System Architecture

/opt/fintech-security/
├── scripts/
│   ├── main.sh
│   ├── user-compliance.sh
│   ├── transaction-monitor.sh
│   ├── fraud-detection.sh
│   └── audit-report.sh
├── data/
│   ├── transactions.csv
│   ├── suspicious-activity.log
│   ├── audit-trail.log
│   └── compliance-check.log
├── config/
│   ├── fintech-config.conf
│   └── thresholds.conf
└── encryption/
    └── keys/


## 📦 Prerequisites
- Linux (Ubuntu 20.04+ or RHEL 8+)
- Root/sudo access
- Basic Linux knowledge
- 1GB free disk space

## 🚀 Installation Guide

### Step 1: Create Directory Structure
```bash
sudo mkdir -p /opt/fintech-security/{scripts,data,config,encryption/keys}
cd /opt/fintech-security
```

### Step 2: Create Configuration Files

Create /opt/fintech-security/config/thresholds.conf

```bash
sudo vim /opt/fintech-security/config/thresholds.conf
```

Create /opt/fintech-security/config/fintech-config.conf

```bash
sudo vim /opt/fintech-security/config/fintech-config.conf
```

### Step 3: Create Data Files

Create /opt/fintech-security/data/transactions.csv

```bash
sudo vim /opt/fintech-security/data/transactions.csv
```

Create empty log files

```bash
sudo touch /opt/fintech-security/data/{suspicious-activity.log,audit-trail.log,compliance-check.log}
```

### Step 4: Create Scripts

Create each script file:

```bash
# Create main script
sudo nano /opt/fintech-security/scripts/main.sh

# Create transaction monitor
sudo nano /opt/fintech-security/scripts/transaction-monitor.sh

# Create fraud detection
sudo nano /opt/fintech-security/scripts/fraud-detection.sh

# Create user compliance
sudo nano /opt/fintech-security/scripts/user-compliance.sh

# Create audit report
sudo nano /opt/fintech-security/scripts/audit-report.sh

# Create security hardening
sudo nano /opt/fintech-security/scripts/security-hardening.sh
```

### Step 5: Set Permissions

```bash
# Make scripts executable
sudo chmod 750 /opt/fintech-security/scripts/*.sh

# Set ownership
sudo chown -R root:fintech-admins /opt/fintech-security/scripts/
sudo chown -R root:fintech-auditors /opt/fintech-security/data/
sudo chown -R root:fintech-admins /opt/fintech-security/config/

# Secure sensitive data
sudo chmod 640 /opt/fintech-security/data/*.csv
sudo chmod 640 /opt/fintech-security/config/*.conf
sudo chmod 700 /opt/fintech-security/encryption
```

### Step 6: Create User Groups

```bash
# Create groups
sudo groupadd fintech-admins
sudo groupadd fintech-auditors
sudo groupadd fintech-traders
sudo groupadd fintech-support

# Create users
sudo useradd -m -G fintech-admins -s /bin/bash sysadmin
sudo useradd -m -G fintech-auditors -s /bin/bash auditor
sudo useradd -m -G fintech-traders -s /bin/bash trader1

# Set passwords
sudo passwd sysadmin
sudo passwd auditor
sudo passwd trader1
```

## Usage Guide

Starting the System

```bash
# Run as different users to test permissions
sudo -u sysadmin /opt/fintech-security/scripts/main.sh
sudo -u auditor /opt/fintech-security/scripts/main.sh
sudo -u trader1 /opt/fintech-security/scripts/main.sh
```

#### Menu Options

- Transaction Monitoring - View and analyze transactions

- Fraud Detection - Detect suspicious patterns

- User Compliance - Manage user access and policies

- Audit Report - Generate compliance reports

- System Health - Check system status

- Security Lockdown - Emergency response mode


#### Terminal Navigation

```bash
# Explore the filesystem
cd /opt/fintech-security
ls -la
tree
pwd
df -h
du -sh *
```

#### Permission Testing

```bash
# Test access controls
sudo -u trader1 cat /opt/fintech-security/data/transactions.csv
sudo -u auditor cat /opt/fintech-security/data/transactions.csv
sudo -u sysadmin cat /opt/fintech-security/config/thresholds.conf
```

#### Process Management

```bash
# Monitor processes
ps aux | grep fintech
top -u trader1
kill -9 <PID>
```

#### Script Modification

```bash
# Add new feature to fraud detection
sudo vim /opt/fintech-security/
```

## 🛠️ Troubleshooting

### Quick System Checks

```bash
# Verify project files and permissions
cd /opt/fintech-security
ls -la
ls -la scripts data config

# Check executable bit on scripts
find scripts -type f -name "*.sh" -exec ls -l {} \;

# Check disk and memory
df -h
free -h
```

### Script and Log Debugging

```bash
# Run with bash debug output
bash -x /opt/fintech-security/scripts/main.sh

# Check recent log activity
tail -n 50 /opt/fintech-security/data/suspicious-activity.log
tail -n 50 /opt/fintech-security/data/audit-trail.log
tail -n 50 /opt/fintech-security/data/compliance-check.log

# Watch logs in real time
tail -f /opt/fintech-security/data/audit-trail.log
```

### Networking Troubleshooting

```bash
# Verify network interfaces and IP addresses
ip addr
ip route

# Test connectivity to gateway and DNS
ping -c 4 8.8.8.8
ping -c 4 google.com

# Check listening ports and active connections
sudo ss -tulpen
sudo ss -tpn | grep -E "(:22|:80|:443)"

# Test remote endpoint connectivity (replace host/port)
nc -vz api.example.com 443

# Check DNS resolution details
getent hosts api.example.com
```

### Permission and Access Issues

```bash
# Verify user and group memberships
id sysadmin
id auditor
id trader1

# Re-apply expected permissions
sudo chmod 750 /opt/fintech-security/scripts/*.sh
sudo chmod 640 /opt/fintech-security/data/*.csv
sudo chmod 640 /opt/fintech-security/config/*.conf
```

### Failure → Fix (Processes and Services)

- **Failure:** `main.sh` exits immediately or menu does not load
    **Fix:** Run in debug mode and verify execute permission.
    ```bash
    bash -x /opt/fintech-security/scripts/main.sh
    ls -l /opt/fintech-security/scripts/main.sh
    sudo chmod 750 /opt/fintech-security/scripts/main.sh
    ```

- **Failure:** Script is running but appears stuck
    **Fix:** Check process state and open files, then terminate/restart safely.
    ```bash
    ps -ef | grep -E "main.sh|transaction-monitor|fraud-detection" | grep -v grep
    sudo lsof -p <PID>
    sudo kill -15 <PID>
    ```

- **Failure:** Multiple duplicate monitoring processes
    **Fix:** Identify duplicates and stop extra instances.
    ```bash
    pgrep -af "transaction-monitor.sh|fraud-detection.sh|main.sh"
    sudo pkill -f "transaction-monitor.sh"
    ```

- **Failure:** Service fails to start with `systemctl`
    **Fix:** Inspect service status and recent logs.
    ```bash
    sudo systemctl status fintech-monitor.service
    sudo journalctl -u fintech-monitor.service -n 100 --no-pager
    ```

- **Failure:** Service starts but exits repeatedly
    **Fix:** Check restart loops and validate script path/user in unit file.
    ```bash
    sudo systemctl show fintech-monitor.service -p ExecStart -p User -p Restart
    sudo journalctl -u fintech-monitor.service -b --no-pager | tail -n 100
    ```

- **Failure:** Service changes not applied after editing unit file
    **Fix:** Reload systemd and restart service.
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart fintech-monitor.service
    sudo systemctl status fintech-monitor.service
    ```

