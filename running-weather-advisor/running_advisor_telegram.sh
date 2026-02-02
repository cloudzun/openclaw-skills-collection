#!/bin/bash

# Running Weather Advisor for Telegram - Combines weather data with physiological rhythms
# Provides personalized running recommendations based on both environmental and biological factors

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

# Function to get basic weather info using our custom weather script
get_basic_weather() {
    local location="$1"
    
    # Use our custom weather data script
    "$SCRIPT_DIR/get_weather_data_simple.sh" "$location" 2>/dev/null || echo "Weather data unavailable"
}

# Function to combine physiology and weather for final recommendation in Telegram-friendly format
generate_telegram_recommendation() {
    local phys_physical="$1"
    local phys_emotional="$2"
    local phys_intellectual="$3"
    local temp_c="$4"
    local condition="$5"
    local humidity="$6"
    local wind_speed="$7"
    
    echo "# 🏃‍♂️ 综合晨跑建议"
    echo ""
    echo "## 📊 生理节律分析"
    echo "• 💪 **体力**: $phys_physical% $(if [ "$phys_physical" -gt 70 ]; then echo "(高能量) - 适合高强度训练"; elif [ "$phys_physical" -gt 30 ]; then echo "(正常) - 适合常规训练"; elif [ "$phys_physical" -gt -30 ]; then echo "(低能量) - 建议轻松活动"; else echo "(极低能量) - 建议休息或轻度活动"; fi)"
    echo "• ❤️ **情绪**: $phys_emotional% $(if [ "$phys_emotional" -gt 70 ]; then echo "(情绪高涨) - 运动体验佳"; elif [ "$phys_emotional" -gt 30 ]; then echo "(稳定) - 适合训练"; elif [ "$phys_emotional" -gt -30 ]; then echo "(波动) - 建议轻松运动"; else echo "(低落) - 谨慎选择运动"; fi)"
    echo "• 🧠 **智力**: $phys_intellectual% $(if [ "$phys_intellectual" -gt 70 ]; then echo "(敏锐) - 适合技术性训练"; elif [ "$phys_intellectual" -gt 30 ]; then echo "(正常) - 适合常规训练"; elif [ "$phys_intellectual" -gt -30 ]; then echo "(一般) - 避免复杂训练"; else echo "(迟缓) - 建议简单运动"; fi)"
    echo ""
    echo "## 🌡️ 天气状况"
    echo "• **温度**: ${temp_c}°C"
    echo "• **天气**: $condition"
    echo "• **湿度**: ${humidity}%"
    echo "• **风况**: $wind_speed"
    echo ""
    echo "## 🏃‍♂️ 综合建议"
    if [ "$phys_physical" -lt -70 ]; then
        echo "• ⚠️ **体力状态**: 今天体力节律处于极低水平(${phys_physical}%)，不建议高强度跑步"
    elif [ "$phys_physical" -lt -30 ]; then
        echo "• ⚠️ **体力状态**: 今天体力节律较低(${phys_physical}%)，建议轻度运动"
    else
        echo "• ✅ **体力状态**: 今天体力节律良好(${phys_physical}%)，适合跑步训练"
    fi
    echo "• 🌡️ **天气条件**: 温度${temp_c}°C，$condition，体感舒适"
    if [ "$humidity" -gt 80 ]; then
        echo "• 💨 **湿度影响**: 湿度偏高(${humidity}%)，建议降低配速"
    fi
    if [ "$temp_c" -lt 5 ]; then
        echo "• 🧥 **保暖提醒**: 气温偏低，注意保暖，按比当前气温高10°C的标准穿衣"
    elif [ "$temp_c" -gt 25 ]; then
        echo "• ☀️ **防晒提醒**: 气温较高，注意防晒补水"
    fi
    echo ""
    echo "## 🎯 运动决策"
    if [ "$phys_physical" -lt -70 ]; then
        echo "**总体评估**: 今天不建议晨跑，体力处于低谷。如坚持运动，仅建议2-3公里轻松慢跑，并做好保暖措施。更推荐进行室内运动或休息，让身体充分恢复。"
    elif [ "$phys_physical" -lt -30 ]; then
        echo "**总体评估**: 今天体力状态不佳，建议轻度运动。如外出跑步，建议3-5公里轻松慢跑，注意保暖。"
    else
        echo "**总体评估**: 今天体力状态良好，适合进行常规晨跑训练。"
    fi
    echo ""
    echo "**晨跑安全提醒**: "
    echo "- 高湿度(>80%)时降低配速，避免心率飙升"
    echo "- 冬季晨跑光线不足，请穿着反光装备"
    echo "- 注意空气质量，AQI超过100时减少户外运动"
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
    
    # Get basic weather data
    weather_info=$(get_basic_weather "$LOCATION")
    
    # Extract weather components
    temp_c=$(echo "$weather_info" | awk '{print $1}' | grep -o '[-0-9]\+' | head -n1)
    condition=$(echo "$weather_info" | awk '{print $2}')
    humidity=$(echo "$weather_info" | awk '{print $3}' | grep -o '[0-9]\+')
    wind_info=$(echo "$weather_info" | awk '{print $4, $5}')
    pressure=$(echo "$weather_info" | awk '{print $6}')
    
    if [ -z "$temp_c" ]; then
        temp_c=15  # Default to 15 if parsing fails
    fi
    
    if [ -z "$condition" ]; then
        condition="未知"
    fi
    
    if [ -z "$humidity" ]; then
        humidity="未知"
    fi
    
    if [ -z "$wind_info" ]; then
        wind_info="未知"
    fi
    
    # Generate Telegram-friendly recommendation
    generate_telegram_recommendation "$phys_physical" "$phys_emotional" "$phys_intellectual" "$temp_c" "$condition" "$humidity" "$wind_info"
fi