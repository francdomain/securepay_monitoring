#!/bin/env bash
# transaction-monitor.sh - Real-time transaction surveillance

monitor_transactions() {
    local user=$(whoami)
    local transaction_file="$DATA_DIR/transactions.csv"
    local suspicious_log="$DATA_DIR/suspicious-activity.log"
    
    # Load thresholds
    source "$CONFIG_DIR/thresholds.conf"
    
    while true; do
        echo "=== Transaction Monitoring Console ==="
        echo "1. View live transactions"
        echo "2. Flag suspicious transactions"
        echo "3. Monitor high-value transactions"
        echo "4. Currency exchange monitoring"
        echo "5. Back to main menu"
        read -p "Choice: " tx_choice
        
        case $tx_choice in
            1)
                echo "Recent Transactions (last 10):"
                echo "--------------------------------"
                tail -10 "$transaction_file" | column -t -s ','
                log_audit "INFO" "$user" "Viewed transaction list" "SUCCESS"
                ;;
                
            2)
                echo "Scanning for suspicious transactions..."
                
                # Using awk to detect suspicious patterns
                awk -F',' -v threshold="$SUSPICIOUS_AMOUNT" '
                    NR>1 && $6 > threshold {
                        printf "⚠️  SUSPICIOUS: TXN %s for %.2f %s\n", $1, $6, $7
                        system("logger -t fintech-fraud \"Suspicious transaction: " $1 "\"")
                    }' "$transaction_file"
                
                log_audit "WARNING" "$user" "Ran suspicious transaction scan" "COMPLETED"
                ;;
                
            3)
                echo "High-Value Transaction Monitor"
                echo "Enter minimum amount:"
                read min_amount
                
                # Real-time monitoring simulation
                echo "Monitoring for transactions > $min_amount (Ctrl+C to stop)"
                tail -f "$transaction_file" | while read line; do
                    amount=$(echo $line | cut -d',' -f6)
                    if (( $(echo "$amount > $min_amount" | bc -l) )); then
                        echo "🚨 HIGH VALUE: $line"
                        # Send alert
                        echo "High value transaction detected: $line" | \
                            mail -s "HIGH VALUE ALERT" fraud@securepay.com
                    fi
                done
                ;;
                
            4)
                echo "Currency Exchange Monitoring"
                echo "High-risk currencies: $(echo $CURRENCY_RISK_LEVELS | grep -o 'HIGH' | wc -l) detected"
                
                # Check for high-risk currency transactions
                grep -E "$(echo $CURRENCY_RISK_LEVELS | grep HIGH | cut -d':' -f1 | tr '\n' '|')" \
                    "$transaction_file" | while read risky_tx; do
                    echo "⚠️  HIGH-RISK CURRENCY: $risky_tx"
                done
                ;;
                
            5)
                break
                ;;
        esac
        read -p "Press Enter to continue..."
    done
}
