#!/bin/env bash
# fraud-detection.sh - Machine learning simulation for fraud detection

detect_fraud() {
    local fraud_log="$DATA_DIR/suspicious-activity.log"
    local transaction_file="$DATA_DIR/transactions.csv"
    
    echo "=== Fraud Detection Engine ==="
    echo "1. Real-time transaction analysis"
    echo "2. Pattern detection"
    echo "3. Kill suspicious transaction process"
    echo "4. View fraud alerts"
    echo "5. Background monitoring"
    read -p "Choice: " fraud_choice
    
    case $fraud_choice in
        1)
            # Real-time analysis with background process
            echo "Starting real-time fraud detection (PID: $$)"
            echo "Monitoring transactions..."
            
            # Background monitoring example
            (
                while true; do
                    # Check for rapid transactions (potential fraud)
                    recent_count=$(tail -100 "$transaction_file" | grep "$(date +%H:%M)" | wc -l)
                    if [ $recent_count -gt 10 ]; then
                        echo "⚠️  FRAUD ALERT: Unusual transaction frequency detected"
                        echo "$(date): Rapid transaction burst ($recent_count/min)" >> "$fraud_log"
                    fi
                    sleep 60
                done
            ) &
            
            FRAUD_PID=$!
            echo "Fraud monitoring started with PID: $FRAUD_PID"
            echo "Press Enter to stop monitoring"
            read
            kill $FRAUD_PID 2>/dev/null && echo "Monitoring stopped"
            ;;
            
        2)
            echo "Analyzing patterns for potential fraud..."
            
            # Pattern detection using process substitution
            while IFS=',' read -r txid timestamp from to amount currency status flagged; do
                # Skip header
                [ "$txid" = "TransactionID" ] && continue
                
                # Check for round amounts (money laundering pattern)
                if [ "$amount" = "${amount%.00}" ]; then
                    if (( $(echo "$amount % 10000 == 0" | bc -l) )); then
                        echo "⚠️  PATTERN: Round amount transaction - $amount $currency"
                        echo "$timestamp|$from|$amount|ROUND_AMOUNT" >> "$fraud_log"
                    fi
                fi
                
                # Check for multiple small transactions (structuring)
                from_account="$from"
                small_tx_count=$(grep -c "$from_account.*,[0-9]{1,4}\.[0-9]{2}," "$transaction_file")
                if [ $small_tx_count -gt 5 ]; then
                    echo "⚠️  PATTERN: Multiple small transactions from $from_account (structuring suspicion)"
                fi
                
            done < <(tail -50 "$transaction_file")
            ;;
            
        3)
            # Process management - kill suspicious transaction processes
            echo "Suspicious Processes:"
            ps aux | grep -E "transaction|transfer|payment" | grep -v grep
            
            read -p "Enter PID to terminate: " pid
            if [ -n "$pid" ]; then
                # Send SIGTERM first
                kill -15 $pid 2>/dev/null
                sleep 2
                
                # Check if still running, then force kill
                if kill -0 $pid 2>/dev/null; then
                    echo "Process still running, sending SIGKILL..."
                    kill -9 $pid
                fi
                
                log_audit "WARNING" "$(whoami)" "Terminated suspicious process PID: $pid" "COMPLETED"
            fi
            ;;
            
        4)
            echo "Recent Fraud Alerts:"
            echo "---------------------"
            tail -20 "$fraud_log" | while read alert; do
                case "$alert" in
                    *CRITICAL*) echo -e "\033[31m$alert\033[0m" ;;  # Red for critical
                    *WARNING*)  echo -e "\033[33m$alert\033[0m" ;;  # Yellow for warning
                    *)          echo "$alert" ;;
                esac
            done
            ;;
    esac
}
