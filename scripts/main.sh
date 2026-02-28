#!/bin/env bash

# FinTech Transaction Monitoring System
# Strict error handling for financial compliance

SCRIPT_DIR="/opt/fintech-security/scripts"
DATA_DIR="/opt/fintech-security/data"
CONFIG_DIR="/opt/fintech-security/config"
LOG_FILE="$DATA_DIR/audit-trail.log"
THRESHOLD_FILE="$CONFIG_DIR/thresholds.conf"

# Source configuration
source "$THRESHOLD_FILE" 2>/dev/null || {
    echo "CRITICAL: Configuration file missing"
    exit 1
}

# Professional logging function for audit trail
log_audit() {
    local level="$1"
    local user="$2"
    local action="$3"
    local status="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local ip=$(who am i | awk '{print $5}' | tr -d '()' || echo "local")
    
    # Format: TIMESTAMP|USER|IP|ACTION|STATUS|LEVEL
    echo "$timestamp|$user|$ip|$action|$status|$level" >> "$LOG_FILE"
    
    # Also log to syslog for SIEM integration
    logger -t fintech-security -p user.info "$user performed $action: $status"
}

# Comprehensive error handler for financial compliance
handle_financial_error() {
    local exit_code=$?
    local line_number=$1
    local error_time=$(date '+%Y-%m-%d %H:%M:%S')
    local user=$(whoami)
    
    # Log the error with full context
    log_audit "ERROR" "$user" "System error at line $line_number" "FAILED"
    
    # Send alert to security team
    echo "URGENT: Financial system error at $error_time" | \
        mail -s "CRITICAL: FinTech System Error" security@securepay.com
    
    # Create incident record
    echo "$error_time|SYSTEM|Line $line_number|Exit $exit_code|$user" >> "$DATA_DIR/incidents.log"
    
    exit $exit_code
}

# Set error trap for compliance
trap 'handle_financial_error $LINENO' ERR

# Function to verify compliance requirements
check_compliance_status() {
    log_audit "INFO" "$(whoami)" "Running compliance check" "STARTED"
    
    # Check if all required services are running
    local required_services=("sshd" "auditd" "rsyslog")
    for service in "${required_services[@]}"; do
        if ! systemctl is-active --quiet $service; then
            log_audit "ERROR" "SYSTEM" "Required service $service not running" "FAILED"
            return 1
        fi
    done
    
    log_audit "INFO" "$(whoami)" "Compliance check passed" "SUCCESS"
    return 0
}

# Function to display main menu
show_fintech_menu() {
    clear
    echo "=========================================="
    echo "   SecurePay FinTech - Security Console  "
    echo "=========================================="
    echo "1. Transaction Monitoring"
    echo "2. Fraud Detection"
    echo "3. User Compliance Management"
    echo "4. Generate Audit Report"
    echo "5. System Health Check"
    echo "6. Compliance Verification"
    echo "7. Security Lockdown Mode"
    echo "8. Exit"
    echo "=========================================="
    echo "Current User: $(whoami) | $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
}

# System health check for financial systems
system_health_check() {
    local user=$(whoami)
    log_audit "INFO" "$user" "Running system health check" "STARTED"
    
    echo "=== Financial System Health Report ==="
    
    # Check disk space for transaction logs
    local disk_usage=$(df -h /opt/fintech-security | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $disk_usage -gt 80 ]; then
        echo "⚠️  WARNING: Transaction storage at ${disk_usage}%"
        log_audit "WARNING" "$user" "Storage critical: ${disk_usage}%" "ALERT"
    else
        echo "✅ Storage OK: ${disk_usage}% used"
    fi
    
    # Check running processes
    local proc_count=$(ps aux | grep -c "fintech\|transaction\|audit")
    echo "📊 Financial processes running: $proc_count"
    
    # Check last audit time
    local last_audit=$(tail -1 "$LOG_FILE" | cut -d'|' -f1)
    echo "📝 Last audit entry: $last_audit"
    
    # Check encryption status
    if [ -d "/opt/fintech-security/encryption/keys" ]; then
        echo "🔐 Encryption: Active (AES-256)"
    fi
    
    log_audit "INFO" "$user" "Health check completed" "SUCCESS"
    read -p "Press Enter to continue..."
}

# Security lockdown for suspicious activity
security_lockdown() {
    local user=$(whoami)
    
    # Only admins can initiate lockdown
    if ! id -nG "$user" | grep -q "fintech-admins"; then
        echo "ERROR: Insufficient privileges for security lockdown"
        log_audit "ERROR" "$user" "Attempted security lockdown without privileges" "BLOCKED"
        return 1
    fi
    
    echo "⚠️  SECURITY LOCKDOWN INITIATED ⚠️"
    log_audit "CRITICAL" "$user" "Manual security lockdown" "ACTIVATED"
    
    # Block all non-essential traffic
    sudo iptables -P INPUT DROP
    sudo iptables -P FORWARD DROP
    
    # Allow only SSH from specific IPs
    sudo iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/24 -j ACCEPT
    
    # Kill all non-admin sessions
    for session in $(who | grep -v "sysadmin\|security-officer" | awk '{print $2}'); do
        sudo pkill -9 -t $session
    done
    
    echo "Lockdown complete. Only administrator access allowed."
}

# Main execution with user tracking
main() {
    local user=$(whoami)
    log_audit "INFO" "$user" "Started FinTech Security Console" "SUCCESS"
    
    # Initial compliance check
    check_compliance_status || {
        echo "WARNING: System not fully compliant. Some features may be limited."
        sleep 3
    }
    
    while true; do
        show_fintech_menu
        read -p "Enter option [1-8]: " choice
        
        case $choice in
            1)
                source "$SCRIPT_DIR/transaction-monitor.sh"
                monitor_transactions
                ;;
            2)
                source "$SCRIPT_DIR/fraud-detection.sh"
                detect_fraud
                ;;
            3)
                source "$SCRIPT_DIR/user-compliance.sh"
                manage_user_compliance
                ;;
            4)
                source "$SCRIPT_DIR/audit-report.sh"
                generate_audit_report
                ;;
            5)
                system_health_check
                ;;
            6)
                verify_full_compliance
                ;;
            7)
                security_lockdown
                ;;
            8)
                log_audit "INFO" "$user" "Exited FinTech Security Console" "SUCCESS"
                echo "Goodbye. All transactions logged for audit."
                exit 0
                ;;
            *)
                echo "Invalid option. Security violation will be logged."
                log_audit "WARNING" "$user" "Invalid menu option: $choice" "FAILED"
                sleep 2
                ;;
        esac
    done
}

# Start main function
main
