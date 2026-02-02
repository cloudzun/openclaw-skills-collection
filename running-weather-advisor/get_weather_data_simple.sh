#!/bin/bash

# Simple script to get basic weather data for running advisor

LOCATION="${1:-201108}"

# Get simplified weather data
WEATHER_DATA=$(curl -s --max-time 10 "wttr.in/$LOCATION?format=%t+%C+%h+%w+%P&lang=zh-cn")

if [ $? -ne 0 ] || [ -z "$WEATHER_DATA" ]; then
    echo "Weather data unavailable"
    exit 1
fi

echo "$WEATHER_DATA"