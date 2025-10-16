#!/usr/bin/bash

USERS_FILE="user.txt"
TRANS_FILE="transaction.txt"

touch "$USERS_FILE" "$TRANS_FILE"

send_money() {
  echo "Initiate Secure Transaction"
  read -p "Enter Sender ID: " sender
  read -p "Enter Receiver ID: " receiver
  read -p "Enter Amount to Transfer: " amount

  sender_balance=$(grep "^$sender," "$USERS_FILE" | cut -d',' -f3)
  receiver_balance=$(grep "^$receiver," "$USERS_FILE" | cut -d',' -f3)

  # Cybersecurity Check
  if [ -z "$sender_balance" ] || [ -z "$receiver_balance" ]; then
    echo "Security Alert: Unauthorized Access Attempt!"
    echo "$sender,$receiver,$amount,FAILED_UNAUTHORIZED" >> "$TRANS_FILE"
    return
  fi

  # Detect suspicious large transaction
  if [ "$amount" -gt 10000 ]; then
    echo "Suspicious Activity Detected: Large transaction blocked!"
    echo "$sender,$receiver,$amount,FAILED_SUSPICIOUS" >> "$TRANS_FILE"
    return
  fi

  # Check balance
  if [ "$amount" -le "$sender_balance" ]; then
    new_sender_balance=$((sender_balance - amount))
    new_receiver_balance=$((receiver_balance + amount))

    # Update balances securely
    sed -i "s/^$sender,[^,]*,[0-9]*/$sender,$(grep "^$sender," "$USERS_FILE" | cut -d',' -f2),$new_sender_balance/" "$USERS_FILE"
    sed -i "s/^$receiver,[^,]*,[0-9]*/$receiver,$(grep "^$receiver," "$USERS_FILE" | cut -d',' -f2),$new_receiver_balance/" "$USERS_FILE"

    echo "Transaction Successful!"
    echo "$sender,$receiver,$amount,SUCCESS" >> "$TRANS_FILE"
  else
    echo " Transaction Failed: Insufficient Funds!"
    echo "$sender,$receiver,$amount,FAILED_LOW_BALANCE" >> "$TRANS_FILE"
  fi
}

view_users() {
  echo "User Account Details"
  awk -F',' '{printf "ID: %-5s | Name: %-10s | Balance: ₹%s\n", $1, $2, $3}' "$USERS_FILE"
}

view_transactions() {
  echo "Transaction History"
  awk -F',' '{printf "From: %-5s | To: %-5s | Amount: ₹%-6s | Status: %s\n", $1, $2, $3, $4}' "$TRANS_FILE"
}

#SAMPLE RUN 
view_users
send_money
view_transactions
