#!/bin/env bash
# user-compliance.sh - Manage user access and compliance

manage_user_compliance() {
    local user=$(whoami)
    local audit_file="$DATA_DIR/compliance-check.log"
    
    # Only auditors and admins can access
    if ! id -nG "$user" | grep -E "fintech-(auditors|admins)" > /dev/null; then
        echo "Access denied. Compliance management restricted."
        log_audit "ERROR" "$user" "Attempted unauthorized compliance access" "BLOCKED"
        return 1
    fi
    
    while true; do
        echo "=== User Compliance Management ==="
        echo "1. List all financial users"
        echo "2. Check user compliance status"
        echo "3. Apply compliance policies"
        echo "4. Lock expired user accounts"
        echo "5. Generate user activity report"
        echo "6. Back to main menu"
        read -p "Choice: " comp_choice
        
        case $comp_choice in
            1)
                echo "Financial System Users:"
                echo "========================"
                
                # Function to get user details
                get_user_details() {
                    local username=$1
                    local expiry=$(chage -l $username 2>/dev/null | grep "Password expires" | cut -d: -f2)
                    local last_login=$(lastlog -u $username | tail -1 | awk '{print $4, $5, $6}')
                    
                    printf "%-15s | Expires: %-20s | Last: %s\n" "$username" "$expiry" "$last_login"
                }
                
                # Loop through fintech users
                for group in fintech-admins fintech-auditors fintech-traders fintech-support; do
                    echo ""
                    echo "=== $group ==="
                    getent group $group | cut -d: -f4 | tr ',' '\n' | while read member; do
                        get_user_details "$member"
                    done
                done
                ;;
                
            2)
                echo "Compliance Status Check"
                echo "========================"
                
                # Check password compliance
                echo "Password Compliance (must be <90 days old):"
                for user in $(getent passwd | grep "/home" | cut -d: -f1); do
                    if id -nG "$user" | grep -q "fintech"; then
                        last_change=$(chage -l "$user" | grep "Last password change" | cut -d: -f2)
                        days_since=$(( ($(date +%s) - $(date -d "$last_change" +%s)) / 86400 ))
                        
                        if [ $days_since -gt 90 ]; then
                            echo "❌ $user: Password expired ($days_since days old)"
                        else
                            echo "✅ $user: Compliant ($days_since days old)"
                        fi
                    fi
                done
                ;;
                
            3)
                echo "Applying compliance policies..."
                
                # Apply password policies
                for user in $(getent group fintech-traders | cut -d: -f4 | tr ',' ' '); do
                    # Set password complexity
                    echo "Setting policies for $user"
                    sudo chage -M 90 -m 7 -W 14 "$user"
                    sudo chage -I 30 "$user"  # Inactive after 30 days
                    
                    # Log compliance action
                    log_audit "INFO" "$user" "Compliance policies applied" "SUCCESS"
                done
                echo "Compliance policies applied to all trading users."
                ;;
                
            4)
                echo "Checking for expired accounts..."
                
                # Find and lock expired accounts
                today=$(date +%s)
                
                for user in $(getent passwd | grep "/home" | cut -d: -f1); do
                    if id -nG "$user" | grep -q "fintech"; then
                        expiry=$(chage -l "$user" 2>/dev/null | grep "Account expires" | cut -d: -f2)
                        
                        if [ "$expiry" != " never" ] && [ -n "$expiry" ]; then
                            expiry_seconds=$(date -d "$expiry" +%s 2>/dev/null)
                            if [ $expiry_seconds -lt $today ]; then
                                echo "Locking expired account: $user"
                                sudo usermod -L "$user"
                                log_audit "WARNING" "$user" "Account expired and locked" "ACTIONED"
                            fi
                        fi
                    fi
                done
                ;;
                
            5)
                echo "Generating user activity report..."
                {
                    echo "USER ACTIVITY COMPLIANCE REPORT"
                    echo "Generated: $(date)"
                    echo "================================"
                    echo ""
                    
                    # User login summary
                    echo "LOGIN SUMMARY:"
                    lastlog | grep -v "Never" | head -20
                    echo ""
                    
                    # Process summary by user
                    echo "ACTIVE PROCESSES BY USER:"
                    ps aux | awk '{print $1}' | sort | uniq -c | sort -nr
                    echo ""
                    
                    # Compliance violations
                    echo "COMPLIANCE VIOLATIONS:"
                    grep -i "violation\|blocked\|error" "$LOG_FILE" | tail -20
                    
                } > "/tmp/compliance-report-$(date +%Y%m%d).txt"
                
                echo "Report generated: /tmp/compliance-report-$(date +%Y%m%d).txt"
                log_audit "INFO" "$user" "Generated compliance report" "SUCCESS"
                ;;
                
            6)
                break
                ;;
        esac
        read -p "Press Enter to continue..."
    done
}
