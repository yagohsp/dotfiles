#!/bin/bash

# Get initial workspace state
get_workspaces() {
    workspaces=$(i3-msg -t get_workspaces)

    # Source of truth for which monitor workspaces 1-4 / 5-8 belong to
    . "$HOME/dotfiles/monitors.env"

    result="["
    for i in {1..8}; do
        active=$(echo "$workspaces" | jq --arg num "$i" 'any(.[]; .num == ($num | tonumber) and .focused)')
        occupied=$(echo "$workspaces" | jq --arg num "$i" 'any(.[]; .num == ($num | tonumber) and (.windows | length > 0))')

        # Try to get monitor from workspace if it exists
        monitor=$(echo "$workspaces" | jq --arg num "$i" '.[] | select(.num == ($num | tonumber)) | .output' 2>/dev/null | tr -d '"')

        # If workspace doesn't exist, assign based on workspace number (matches workspaces.conf: 1-4 -> primary, 5-8 -> secondary)
        if [ -z "$monitor" ]; then
            if [ "$i" -le 4 ]; then
                monitor="$PRIMARY_MONITOR"
            else
                monitor="$SECONDARY_MONITOR"
            fi
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
