#!/bin/bash

# Script to get comprehensive weather data for running advisor

LOCATION="${1:-201108}"

# Get weather data in JSON format
WEATHER_JSON=$(curl -s --max-time 15 "wttr.in/$LOCATION?format=j1&lang=zh-cn" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$WEATHER_JSON" ]; then
    echo "Weather data unavailable"
    exit 1
fi

# Extract weather information using grep and sed
TEMP_C=$(echo "$WEATHER_JSON" | grep -o '"temp_C":"[^"]*"' | head -n1 | cut -d'"' -f4)
FEELS_LIKE_C=$(echo "$WEATHER_JSON" | grep -o '"FeelsLikeC":"[^"]*"' | head -n1 | cut -d'"' -f4)
CONDITION=$(echo "$WEATHER_JSON" | grep -o '"lang_zh-cn":\[\{"value":"[^"]*"\}\]' | sed 's/.*"value":"\([^"]*\)".*/\1/')
HUMIDITY=$(echo "$WEATHER_JSON" | grep -o '"humidity":"[^"]*"' | head -n1 | cut -d'"' -f4)
WIND_KPH=$(echo "$WEATHER_JSON" | grep -o '"windspeedKmph":"[^"]*"' | head -n1 | cut -d'"' -f4)
PRESSURE=$(echo "$WEATHER_JSON" | grep -o '"pressure":"[^"]*"' | head -n1 | cut -d'"' -f4)
PRECIP_MM=$(echo "$WEATHER_JSON" | grep -o '"precipMM":"[^"]*"' | head -n1 | cut -d'"' -f4)
VISIBILITY=$(echo "$WEATHER_JSON" | grep -o '"visibility":"[^"]*"' | head -n1 | cut -d'"' -f4)

# Format output for the running advisor
cat << EOF
温度:$TEMP_C°C
体感温度:$FEELS_LIKE_C°C
天气状况:$CONDITION
湿度:$HUMIDITY%
风速:$WIND_KPH km/h
气压:$PRESSURE mb
降水量:$PRECIP_MM mm
能见度:$VISIBILITY km
EOF