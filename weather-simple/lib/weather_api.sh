#!/bin/bash

# Weather API library for simple weather forecast skill

# Function to fetch weather data with error handling and shorter timeouts
fetch_weather_data() {
    local location="$1"
    local format="${2:-default}"
    
    # Set appropriate format based on type
    local url
    case "$format" in
        "current")
            # Get simplified current weather
            url="wttr.in/$location?format=%l:+%c+%t+(体感+%f)+湿度%h+风速%w+%m&lang=zh-cn"
            ;;
        "today")
            # Get today's forecast only (shorter response)
            url="wttr.in/$location?0&lang=zh-cn"
            ;;
        *)
            url="wttr.in/$location?lang=zh-cn"
            ;;
    esac
    
    # Attempt to fetch data with shorter timeout
    local result
    if command -v curl >/dev/null 2>&1; then
        result=$(curl -s --max-time 8 "$url" 2>/dev/null)
    elif command -v wget >/dev/null 2>&1; then
        result=$(wget -qO- --timeout=8 "$url" 2>/dev/null)
    else
        echo "Error: Neither curl nor wget is available" >&2
        return 1
    fi
    
    if [ $? -eq 0 ] && [ -n "$result" ]; then
        echo "$result"
        return 0
    else
        echo "Error: Failed to retrieve weather data for '$location'" >&2
        return 1
    fi
}