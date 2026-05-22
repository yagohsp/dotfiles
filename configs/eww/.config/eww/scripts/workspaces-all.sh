#!/bin/bash

# Get initial workspace state
get_workspaces() {
    workspaces=$(i3-msg -t get_workspaces)
    outputs=$(i3-msg -t get_outputs)
    
    # Get all active monitors
    monitors=$(echo "$outputs" | jq -r '.[] | select(.active == true) | .name')
    num_monitors=$(echo "$monitors" | wc -l)
    
    result="["
    for i in {1..8}; do
        active=$(echo "$workspaces" | jq --arg num "$i" 'any(.[]; .num == ($num | tonumber) and .focused)')
        occupied=$(echo "$workspaces" | jq --arg num "$i" 'any(.[]; .num == ($num | tonumber) and (.windows | length > 0))')
        
        # Try to get monitor from workspace if it exists
        monitor=$(echo "$workspaces" | jq --arg num "$i" '.[] | select(.num == ($num | tonumber)) | .output' 2>/dev/null | tr -d '"')
        
        # If workspace doesn't exist, assign based on workspace number
        if [ -z "$monitor" ]; then
            # Calculate workspaces per monitor
            workspaces_per_monitor=$((8 / num_monitors))
            # Calculate which monitor this workspace should go to
            monitor_index=$(( (i - 1) / workspaces_per_monitor ))
            # Clamp to valid monitor index
            if [ $monitor_index -ge $num_monitors ]; then
                monitor_index=$((num_monitors - 1))
            fi
            monitor=$(echo "$monitors" | sed -n "$((monitor_index + 1))p")
        fi
        
        if [ "$i" -gt 1 ]; then
            result="$result,"
        fi
        
        result="$result{\"id\":$i,\"active\":$active,\"occupied\":$occupied,\"monitor\":\"$monitor\"}"
    done
    result="$result]"
    
    echo "$result"
}

# Output initial state
get_workspaces

# Listen for i3 workspace events
i3-msg -t subscribe -m '["workspace"]' | while read -r line; do
    get_workspaces
done
