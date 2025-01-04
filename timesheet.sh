#!/bin/bash

# File to store the time registers
FILE="Time Registers.txt"

# Get the current date and time
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M")

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
    echo "Total time: $total_minutes minutes ($total_hours hours)"
}

# Check for 'get' argument
if [[ "$1" == "get" ]]; then
    if [[ ! -f "$FILE" ]]; then
        echo "No time registers found."
        exit 1
    fi
    calculate_total_time
    exit 0
fi

# Ensure the file exists
if [[ ! -f "$FILE" ]]; then
    touch "$FILE"
    echo "$CURRENT_TIME" >> "$FILE"
    echo "Time counter started"
    exit 0
fi

# Check if the last line is incomplete (does not contain " - ")
LAST_LINE=$(tail -n 1 "$FILE")
if [[ "$LAST_LINE" != *" - "* ]]; then
    sed -i "$ s|$| - $CURRENT_TIME|" "$FILE"
    echo "Time register stopped"
else
    echo "$CURRENT_TIME" >> "$FILE"
    echo "Time counter started"
fi
