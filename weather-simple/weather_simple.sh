#!/bin/bash

# Simple Weather Forecast Skill for OpenClaw
# Provides basic weather information for a given location

set -e

# Source the weather API library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/weather_api.sh"

# Default location is Shanghai Minhang District (201108)
LOCATION="${1:-201108}"

# Function to display usage
usage() {
    echo "Usage: $0 [location]"
    echo "Example: $0 201108 (Shanghai Minhang)"
    echo "         $0 Beijing"
    echo "         $0 'New York'"
    exit 0
}

# Function to get weather data
get_weather() {
    local location="$1"
    
    echo "Fetching weather for: $location"
    echo ""
    
    # Get current weather in simplified format only
    echo "Current weather:"
    if ! fetch_weather_data "$location" "current"; then
        echo "Failed to retrieve weather data."
        return 1
    fi
    echo ""
}

# Main execution
if [[ "$LOCATION" == "-h" || "$LOCATION" == "--help" ]]; then
    usage
elif [[ "$LOCATION" == "" ]]; then
    get_weather "201108"
else
    get_weather "$LOCATION"
fi