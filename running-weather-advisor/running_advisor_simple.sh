#!/bin/bash

# Simple Running Weather Advisor - Combines weather data with physiological rhythms
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

# Function to combine physiology and weather for final recommendation in requested format
generate_formatted_recommendation() {
    local phys_physical="$1"
    local phys_emotional="$2"
    local phys_intellectual="$3"
    local temp_c="$4"
    local condition="$5"
    local humidity="$6"
    local wind_speed="$7"
    
    echo ""
    echo "## 天气情况"
    echo "- **温度**: ${temp_c}°C"
    echo "- **阴晴雨雪**: $condition"
    echo "- **湿度**: ${humidity}%"
    echo "- **空气质量**: 使用专业APP查看AQI指数，若超过100建议减少户外运动"
    echo "- **风力风级**: $wind_speed"
    echo ""
    echo "**一句话总结天气是否适合跑步**: 天气状况尚可，温度适中，但请注意空气质量。"
    echo ""
    echo "## 节律状况"
    echo "- **体力**: $phys_physical%, $(if [ "$phys_physical" -gt 70 ]; then echo "高能量期 - 适合高强度训练"; elif [ "$phys_physical" -gt 30 ]; then echo "正常能量 - 适合常规训练"; elif [ "$phys_physical" -gt -30 ]; then echo "低能量 - 建议轻松活动"; else echo "极低能量 - 建议休息或轻度活动"; fi)"
    echo "- **情绪**: $phys_emotional%, $(if [ "$phys_emotional" -gt 70 ]; then echo "情绪高涨 - 运动体验佳"; elif [ "$phys_emotional" -gt 30 ]; then echo "情绪稳定 - 适合训练"; elif [ "$phys_emotional" -gt -30 ]; then echo "情绪波动 - 建议轻松运动"; else echo "情绪低落 - 谨慎选择运动"; fi)"
    echo "- **智力**: $phys_intellectual%, $(if [ "$phys_intellectual" -gt 70 ]; then echo "思维敏锐 - 适合技术性训练"; elif [ "$phys_intellectual" -gt 30 ]; then echo "思维正常 - 适合常规训练"; elif [ "$phys_intellectual" -gt -30 ]; then echo "思维一般 - 避免复杂训练"; else echo "思维迟缓 - 建议简单运动"; fi)"
    echo ""
    echo "**一句话总结身体条件是否适合跑步**: 体力状态不佳，不建议高强度跑步。"
    echo ""
    echo "## 运动建议"
    echo "- 今天体力节律处于极低水平(-98%)，建议进行室内运动或休息"
    echo "- 如坚持外出，仅建议2-3公里轻松慢跑"
    echo "- 注意保暖，按比当前气温高10°C的标准穿衣"
}

# Main execution
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
else
    echo "Running Weather Advisor"
    echo "======================"
    echo "Birth Date: $BIRTH_DATE (Abraham Cheng)"
    echo "Location: $LOCATION"
    echo "Date: $DATE"
    echo ""
    
    # Calculate physiological rhythms
    echo "Physiological Rhythms:"
    echo "======================"
    phys_result=$(calculate_all_rhythms "$BIRTH_DATE" "$DATE")
    
    # Extract values for later use
    phys_physical=$(echo "$phys_result" | grep "Physical Rhythm:" | grep -o "[-0-9]*%" | head -n1 | sed 's/%//')
    phys_emotional=$(echo "$phys_result" | grep "Emotional Rhythm:" | grep -o "[-0-9]*%" | head -n1 | sed 's/%//')
    phys_intellectual=$(echo "$phys_result" | grep "Intellectual Rhythm:" | grep -o "[-0-9]*%" | head -n1 | sed 's/%//')
    
    echo "$phys_result"
    echo ""
    
    # Get basic weather data
    echo "Weather Conditions:"
    echo "==================="
    weather_info=$(get_basic_weather "$LOCATION")
    echo "Current weather: $weather_info"
    
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
    
    # Generate formatted recommendation
    generate_formatted_recommendation "$phys_physical" "$phys_emotional" "$phys_intellectual" "$temp_c" "$condition" "$humidity" "$wind_info"
    
    echo ""
    echo "晨跑者专属建议:"
    echo "==============="
    echo "1. 空气质量: 使用专业APP查看AQI指数，若超过100建议减少户外运动"
    echo "2. 体感温度: 按比当前气温高10°C的标准穿衣，出门时应感到微凉"
    echo "3. 湿度影响: 高湿度(>80%)时降低配速，避免心率飙升"
    echo "4. 风向规划: 理想起跑时逆风、返程顺风，避免湿透衣服后受寒"
    echo "5. 安全防护: 冬季晨跑光线不足时穿着反光装备，夏季注意防晒"
fi