#!/bin/bash

# Enhanced Running Weather Advisor - Combines weather data with physiological rhythms
# Provides personalized running recommendations in a styled format

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

# Function to get formatted weather info using direct curl
get_formatted_weather() {
    local location="$1"
    
    # Try to get weather info directly from wttr.in
    WEATHER_OUTPUT=$(timeout 10 curl -s "wttr.in/$location?format=%t+%C+%h+%w&lang=zh-cn" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$WEATHER_OUTPUT" ]; then
        # Parse the weather data
        local temp_line="$WEATHER_OUTPUT"
        
        # Extract temperature
        local temperature=$(echo "$temp_line" | grep -o '[+-][0-9]*°C' | head -n1)
        if [ -z "$temperature" ]; then
            temperature="+15°C"
        fi
        
        # Extract condition (晴、雨、雪, etc.)
        local condition=$(echo "$temp_line" | grep -o '晴\|多云\|阴\|雨\|雪\|雾\|霾')
        if [ -z "$condition" ]; then
            # Handle emoji conditions
            local emoji_condition=$(echo "$temp_line" | grep -o '☀️\|⛅️\|☁️\|🌧️\|⛈️\|🌩️\|🌨️\|❄️\|🌪️\|🌫️')
            case "$emoji_condition" in
                "☀️") condition="晴" ;;
                "⛅️") condition="晴间多云" ;;
                "☁️") condition="多云" ;;
                "🌧️") condition="雨" ;;
                "⛈️") condition="雷阵雨" ;;
                "🌩️") condition="雷暴" ;;
                "🌨️") condition="雨夹雪" ;;
                "❄️") condition="雪" ;;
                "🌪️") condition="大风" ;;
                "🌫️") condition="雾" ;;
                *) condition="未知" ;;
            esac
        fi
        
        # Extract humidity (look for humidity pattern)
        local humidity=$(echo "$temp_line" | grep -o '[0-9]*%' | head -n1)
        if [ -z "$humidity" ]; then
            humidity="65%"
        fi
        
        # Extract wind direction and speed
        local wind_dir_raw=$(echo "$temp_line" | grep -o '[↖↗↘↙→←↑↓]')
        local wind_speed=$(echo "$temp_line" | grep -o '[0-9]*km/h' | head -n1)
        
        # Convert wind direction symbols to text
        local wind_direction=""
        case "$wind_dir_raw" in
            "↗") wind_direction="东北风" ;;
            "↘") wind_direction="东南风" ;;
            "↙") wind_direction="西南风" ;;
            "↖") wind_direction="西北风" ;;
            "→") wind_direction="西风" ;;
            "←") wind_direction="东风" ;;
            "↑") wind_direction="南风" ;;
            "↓") wind_direction="北风" ;;
            *) wind_direction="风" ;;
        esac
        
        local wind="${wind_speed} ${wind_direction}"
        if [ -z "$wind_speed" ]; then
            wind="5km/h 风"
        fi
        
        # Output in a format that can be used by the calling function
        echo "TEMP:$temperature"
        echo "CONDITION:$condition"
        echo "HUMIDITY:$humidity"
        echo "WIND:$wind"
    else
        # Fallback values if weather service fails
        echo "TEMP:+15°C"
        echo "CONDITION:未知"
        echo "HUMIDITY:65%"
        echo "WIND:5km/h 风"
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
    
    # Format output with enhanced styling
    echo "**🌡️ 今日天气概览**"
    echo "• 温度: $temp"
    echo "• 天气: $condition"
    echo "• 湿度: $humidity"
    echo "• 风况: $wind"
    echo ""
    
    # Determine if weather is suitable for running
    temp_val=$(echo "$temp" | sed 's/[^0-9.-]//g')  # Extract numeric value
    weather_suitable=false
    if [ "$temp_val" -gt -5 ] && [ "$temp_val" -lt 30 ] && [[ "$condition" != *"雨"* ]] && [[ "$condition" != *"雪"* ]] && [[ "$condition" != *"雾"* ]]; then
        weather_suitable=true
    fi
    
    echo "**📊 生理节律分析**"
    echo "• 💪 体力: $phys_physical% $(if [ "$phys_physical" -gt 50 ]; then echo "(高峰) 体力充沛"; elif [ "$phys_physical" -gt 0 ]; then echo "(上升) 体力良好"; elif [ "$phys_physical" -gt -50 ]; then echo "(平稳) 体力一般"; else echo "(低谷) 体力不足"; fi)"
    echo "• ❤️ 情绪: $phys_emotional% $(if [ "$phys_emotional" -gt 50 ]; then echo "(高涨) 情绪积极"; elif [ "$phys_emotional" -gt 0 ]; then echo "(稳定) 情绪平和"; elif [ "$phys_emotional" -gt -50 ]; then echo "(波动) 情绪起伏"; else echo "(低潮) 情绪不佳"; fi)"
    echo "• 🧠 智力: $phys_intellectual% $(if [ "$phys_intellectual" -gt 50 ]; then echo "(敏锐) 思维活跃"; elif [ "$phys_intellectual" -gt 0 ]; then echo "(清晰) 思维正常"; elif [ "$phys_intellectual" -gt -50 ]; then echo "(平缓) 思维平稳"; else echo "(迟缓) 思维缓慢"; fi)"
    echo ""
    
    echo "**🏃 今日运动建议**"
    if [ "$phys_physical" -lt -50 ]; then
        echo "• ⚠️ 体力处于极低水平，建议以休息为主"
        if [ "$weather_suitable" = true ]; then
            echo "• 天气条件尚可，可考虑室内轻度活动"
        else
            echo "• 天气条件一般，建议居家休息"
        fi
        echo "• 推荐瑜伽、拉伸或散步等低强度运动"
    elif [ "$phys_physical" -lt 0 ]; then
        echo "• ⚠️ 体力偏低，建议降低运动强度"
        if [ "$weather_suitable" = true ]; then
            echo "• 天气适宜，可进行轻松慢跑2-3公里"
        else
            echo "• 天气一般，建议选择室内运动"
        fi
        echo "• 控制配速，注意保暖"
    else
        echo "• ✅ 体力状态良好，适合正常训练"
        if [ "$weather_suitable" = true ]; then
            echo "• 天气理想，可按计划进行户外运动"
        else
            echo "• 天气欠佳，可考虑调整运动方案"
        fi
        echo "• 根据个人感受调整运动强度"
    fi
fi