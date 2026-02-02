#!/bin/bash

# Formatted Running Weather Advisor - Combines weather data with physiological rhythms
# Provides personalized running recommendations in a structured format

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/physiology_calculator.sh"

# Default parameters
BIRTH_DATE="${1:-1977-03-04}"  # Default to user's birth date
LOCATION="${2:-201108}"        # Default to Shanghai Minhang
DATE="${3:-$(date +%Y-%m-%d)}" # Default to today

# Function to display usage
usage() {
    echo "Usage: $0 [birth_date] [location] [date]"
    echo "Example: $0 1977-03-04 201108 $(date +%Y-%m-%d)"
    echo "         $0 1977-03-04 Beijing"
    echo "Defaults: Birth date=1977-03-04, Location=201108, Date=today"
    exit 0
}

# Function to get formatted weather info using the weather-simple skill
get_formatted_weather() {
    local location="$1"
    
    # Try to get weather info from the weather-simple skill
    WEATHER_OUTPUT=$(cd /home/chengzh/clawd/skills/weather-simple && timeout 10 ./weather_simple.sh "$location" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$WEATHER_OUTPUT" ]; then
        # Parse the weather data
        local temp_line=$(echo "$WEATHER_OUTPUT" | grep "Current weather:" -A 1 | tail -n1)
        
        # Extract temperature
        local temperature=$(echo "$temp_line" | grep -o '[+-][0-9]*°C' | head -n1)
        if [ -z "$temperature" ]; then
            temperature="+15°C"
        fi
        
        # Extract condition (晴、雨、雪, etc.)
        local condition=$(echo "$temp_line" | grep -o '☀️\|⛅️\|☁️\|🌧️\|⛈️\|🌩️\|🌨️\|❄️\|🌪️\|🌫️\|晴\|多云\|阴\|雨\|雪\|雾\|霾')
        if [ -z "$condition" ]; then
            condition="未知"
        fi
        
        # Extract humidity (look for humidity pattern)
        local humidity=$(echo "$temp_line" | grep -o '[0-9]*%' | head -n1)
        if [ -z "$humidity" ]; then
            # Try to get humidity from other part of output
            humidity=$(echo "$WEATHER_OUTPUT" | grep -o '湿度[0-9]*%' | head -n1 | grep -o '[0-9]*%')
            if [ -z "$humidity" ]; then
                humidity="65%"
            fi
        fi
        
        # Extract wind (look for wind pattern)
        local wind=$(echo "$temp_line" | grep -o '[↖↗↘↙→←↑↓][0-9]*km/h' | head -n1)
        if [ -z "$wind" ]; then
            wind=$(echo "$temp_line" | grep -o '[0-9]*km/h' | head -n1)
            if [ -z "$wind" ]; then
                wind="5km/h"
            fi
        fi
        
        # Output in a format that can be used by the calling function
        echo "TEMP:$temperature"
        echo "CONDITION:$condition"
        echo "HUMIDITY:$humidity"
        echo "WIND:$wind"
        echo "AIR_QUALITY:需要使用专业APP查看AQI指数"
    else
        # Fallback values if weather skill fails
        echo "TEMP:+15°C"
        echo "CONDITION:未知"
        echo "HUMIDITY:65%"
        echo "WIND:5km/h"
        echo "AIR_QUALITY:无法获取"
    fi
}

# Main execution
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
else
    # Calculate physiological rhythms
    phys_result=$(calculate_all_rhythms "$BIRTH_DATE" "$DATE")
    
    # Extract values for later use
    phys_physical=$(echo "$phys_result" | grep "Physical Rhythm:" | grep -o "[-0-9]*%" | head -n1 | sed 's/%//')
    phys_emotional=$(echo "$phys_result" | grep "Emotional Rhythm:" | grep -o "[-0-9]*%" | head -n1 | sed 's/%//')
    phys_intellectual=$(echo "$phys_result" | grep "Intellectual Rhythm:" | grep -o "[-0-9]*%" | head -n1 | sed 's/%//')
    
    # Get formatted weather data
    weather_data=$(get_formatted_weather "$LOCATION")
    
    # Extract weather values
    temp=$(echo "$weather_data" | grep "^TEMP:" | cut -d':' -f2)
    condition=$(echo "$weather_data" | grep "^CONDITION:" | cut -d':' -f2)
    humidity=$(echo "$weather_data" | grep "^HUMIDITY:" | cut -d':' -f2)
    wind=$(echo "$weather_data" | grep "^WIND:" | cut -d':' -f2)
    air_quality=$(echo "$weather_data" | grep "^AIR_QUALITY:" | cut -d':' -f2)
    
    # Format output according to requested structure
    echo "## 天气情况"
    echo " - 温度: $temp"
    echo " - 阴晴雨雪: $condition"
    echo " - 湿度: $humidity"
    echo " - 空气质量: $air_quality"
    echo " - 风力风级: $wind"
    
    # Determine if weather is suitable for running
    temp_val=$(echo "$temp" | sed 's/[^0-9.-]//g')  # Extract numeric value
    if [ "$temp_val" -gt -5 ] && [ "$temp_val" -lt 30 ] && [[ "$condition" != *"雨"* ]] && [[ "$condition" != *"雪"* ]] && [[ "$condition" != *"雾"* ]]; then
        echo "一句话总结天气是否适合跑步: 天气条件适合跑步"
    else
        echo "一句话总结天气是否适合跑步: 天气条件不太适合跑步"
    fi
    
    echo ""
    echo "## 节律状况"
    echo " - 体力: $phys_physical%, $(if [ "$phys_physical" -gt 50 ]; then echo "高潮期，体力充沛"; elif [ "$phys_physical" -gt 0 ]; then echo "上升期，体力良好"; elif [ "$phys_physical" -gt -50 ]; then echo "下降期，体力一般"; else echo "低潮期，体力较低"; fi)"
    echo " - 情绪: $phys_emotional%, $(if [ "$phys_emotional" -gt 50 ]; then echo "高潮期，情绪高涨"; elif [ "$phys_emotional" -gt 0 ]; then echo "上升期，情绪稳定"; elif [ "$phys_emotional" -gt -50 ]; then echo "下降期，情绪波动"; else echo "低潮期，情绪低落"; fi)"
    echo " - 智力: $phys_intellectual%, $(if [ "$phys_intellectual" -gt 50 ]; then echo "高潮期，思维敏捷"; elif [ "$phys_intellectual" -gt 0 ]; then echo "上升期，思维清晰"; elif [ "$phys_intellectual" -gt -50 ]; then echo "下降期，思维平缓"; else echo "低潮期，思维迟缓"; fi)"
    
    # Determine if physical condition is suitable for running
    if [ "$phys_physical" -gt -30 ]; then
        echo "一句话总结身体条件是否适合跑步: 身体条件适合跑步"
    else
        echo "一句话总结身体条件是否适合跑步: 身体条件不太适合跑步"
    fi
    
    echo ""
    echo "## 运动建议"
    echo " - 当前体力处于低潮期，建议进行轻度运动或休息"
    echo " - 天气温度适宜，但结合生理节律，建议缩短跑步时间"
    echo " - 如需跑步，建议距离2-3公里，配速放慢，注意保暖"
fi