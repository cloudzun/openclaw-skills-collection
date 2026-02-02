#!/bin/bash

# Weather Data Library for Running Weather Advisor
# Fetches and processes weather data for running recommendations

# Function to fetch weather data with error handling and shorter timeouts
fetch_weather_data() {
    local location="$1"
    
    # Get comprehensive weather data
    local url="wttr.in/$location?format=j1&lang=zh-cn"
    
    # Attempt to fetch data with timeout
    local result
    if command -v curl >/dev/null 2>&1; then
        result=$(curl -s --max-time 10 "$url" 2>/dev/null)
    elif command -v wget >/dev/null 2>&1; then
        result=$(wget -qO- --timeout=10 "$url" 2>/dev/null)
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

# Function to extract specific weather values from JSON
extract_weather_value() {
    local json_data="$1"
    local key_path="$2"
    
    # Using grep and sed to extract values from JSON (since jq might not be available)
    # This is a simplified approach for basic JSON parsing
    echo "$json_data" | grep -o "\"$key_path\":[^,}]*" | head -n1 | cut -d':' -f2 | sed 's/[",]//g'
}

# Function to get current weather summary
get_weather_summary() {
    local location="$1"
    
    local weather_json
    weather_json=$(fetch_weather_data "$location")
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Extract relevant weather data (simplified extraction)
    # Since the j1 format returns detailed JSON, we'll get the current condition data
    local temp_c=$(echo "$weather_json" | grep -o '"temp_C":"[^"]*"' | head -n1 | cut -d'"' -f4)
    local feelslike_c=$(echo "$weather_json" | grep -o '"FeelsLikeC":"[^"]*"' | head -n1 | cut -d'"' -f4)
    local humidity=$(echo "$weather_json" | grep -o '"humidity":"[^"]*"' | head -n1 | cut -d'"' -f4)
    local windspeed_kph=$(echo "$weather_json" | grep -o '"windspeedKmph":"[^"]*"' | head -n1 | cut -d'"' -f4)
    local precip_mm=$(echo "$weather_json" | grep -o '"precipMM":"[^"]*"' | head -n1 | cut -d'"' -f4)
    local pressure_mb=$(echo "$weather_json" | grep -o '"pressure":"[^"]*"' | head -n1 | cut -d'"' -f4)
    local visibility_km=$(echo "$weather_json" | grep -o '"visibility":"[^"]*"' | head -n1 | cut -d'"' -f4)
    local uv_index=$(echo "$weather_json" | grep -o '"uvIndex":[^,}]*' | head -n1 | cut -d':' -f2)
    local weather_desc=$(echo "$weather_json" | grep -o '"weatherDesc":\[\{"value":"[^"]*"\}\]' | sed 's/.*"value":"\([^"]*\)".*/\1/')
    
    # Print the weather summary
    echo "Location: $location"
    echo "Temperature: ${temp_c}°C (Feels like: ${feelslike_c}°C)"
    echo "Humidity: ${humidity}%"
    echo "Wind Speed: ${windspeed_kph} km/h"
    echo "Precipitation: ${precip_mm} mm"
    echo "Pressure: ${pressure_mb} mb"
    echo "Visibility: ${visibility_km} km"
    echo "UV Index: ${uv_index}"
    echo "Conditions: $weather_desc"
    
    # Return extracted values as a structured format
    cat << EOF
TEMP:$temp_c
FEELSLIKE:$feelslike_c
HUMIDITY:$humidity
WINDSPEED:$windspeed_kph
PRECIP:$precip_mm
PRESSURE:$pressure_mb
VISIBILITY:$visibility_km
UV:$uv_index
DESCRIPTION:$weather_desc
EOF
}