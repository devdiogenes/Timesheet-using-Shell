#!/bin/bash

# File to store the time registers
FILE="Time Registers.txt"

# Function to calculate total time
calculate_total_time() {
    local total_minutes=0
    local total_hours=0
    while IFS= read -r line; do
        # Extract start and end times using basic string operations
        start=$(echo "$line" | awk -F' - ' '{print $1}')
        end=$(echo "$line" | awk -F' - ' '{print $2}')

        # Skip incomplete lines
        if [[ -z "$end" ]]; then
            continue
        fi

        # Convert times to seconds since epoch
        start_seconds=$(date -d "$start" +%s)
        end_seconds=$(date -d "$end" +%s)

        # Calculate the difference in minutes
        total_minutes=$((total_minutes + (end_seconds - start_seconds) / 60))
    done < "$FILE"
    total_hours=$(echo "scale=2; $total_minutes / 60" | bc)
    read -p "Total time: $total_minutes minutes ($total_hours hours)"
}

# Check for 'get' argument
if [[ "$1" == "get" ]]; then
    if [[ ! -f "$FILE" ]]; then
        read -p "No time registers found"
        exit 1
    fi
    calculate_total_time
    exit 0
fi

# Ensure the file exists
if [[ ! -f "$FILE" ]]; then
    touch "$FILE"
fi

# Check if the last line is incomplete (does not contain " - ")
LAST_LINE=$(tail -n 1 "$FILE")
if [[ ! "$LAST_LINE" =~ *" - "* ]]; then
    current_time=$(date "+%Y-%m-%d %H:%M")
    echo "$current_time" >> "$FILE"
    read -p "Time counter started at $current_time! Press Enter to stop..."
fi

current_time=$(date "+%Y-%m-%d %H:%M")
sed -i "$ s|$| - $current_time|" "$FILE"
read -p "Time register stopped!"
