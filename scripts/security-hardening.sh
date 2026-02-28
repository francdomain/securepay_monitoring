#!/bin/env bash
# security-hardening.sh - Apply financial security measures

harden_system() {
    local user=$(whoami)
    
    echo "🔒 Applying Financial Security Hardening..."
    log_audit "INFO" "$user" "Starting security hardening" "STARTED"
    
    # 1. Set secure file permissions
    echo "Setting secure permissions..."
    find /opt/fintech-security/data -type f -name "*.csv" -exec chmod 640 {} \;
    find /opt/fintech-security/config -type f -exec chmod 640 {} \;
    chmod 700 /opt/fintech-security/encryption
    
    # 2. Enable audit logging
    echo "Configuring auditd for financial transactions..."
    echo "-w /opt/fintech-security/data/transactions.csv -p wa -k fintech_transactions" >> /etc/audit/rules.d/audit.rules
    service auditd restart
    
    # 3. Set password policies
    echo "Setting password complexity requirements..."
    cat >> /etc/security/pwquality.conf << 'EOF'
minlen = 12
minclass = 4
maxrepeat = 3
dictcheck = 1
EOF
    
    # 4. Configure SSH for secure access
    echo "Hardening SSH configuration..."
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
    systemctl restart sshd
    
    # 5. Set up process limits
    echo "Setting process limits for financial users..."
    cat >> /etc/security/limits.conf << 'EOF'
@fintech-traders soft nproc 100
@fintech-traders hard nproc 200
@fintech-traders soft nofile 4096
@fintech-traders hard nofile 8192
EOF
    
    log_audit "INFO" "$user" "Security hardening completed" "SUCCESS"
    echo "✅ Security hardening applied successfully"
}

# Run hardening
harden_system
