#!/bin/bash

# Running Weather Advisor - Combines weather data with physiological rhythms
# Provides personalized running recommendations based on both environmental and biological factors

set -e

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/physiology_calculator.sh"
source "$SCRIPT_DIR/lib/weather_data.sh"

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

# Function to interpret weather conditions for running
interpret_weather_for_running() {
    local temp_c="$1"
    local feelslike_c="$2"
    local humidity="$3"
    local windspeed_kph="$4"
    local visibility_km="$5"
    local uv_index="$6"
    local precip_mm="$7"
    
    echo "Weather Analysis for Running:"
    echo "-----------------------------"
    
    # Temperature analysis
    if [ "$feelslike_c" -lt 0 ]; then
        echo "❄️  Cold Alert: Feels like $feelslike_c°C - wear thermal layers and warm up thoroughly"
    elif [ "$feelslike_c" -gt 25 ]; then
        echo "🔥 Heat Alert: Feels like $feelslike_c°C - hydrate well and consider early morning run"
    else
        echo "🌡️  Comfortable temperature: Feels like $feelslike_c°C - ideal for running"
    fi
    
    # Humidity analysis
    if [ "$humidity" -gt 80 ]; then
        echo "💧 High humidity: $humidity% - expect difficulty cooling down, reduce intensity"
    elif [ "$humidity" -lt 30 ]; then
        echo "🏜️  Low humidity: $humidity% - ensure adequate hydration"
    else
        echo "💧 Moderate humidity: $humidity% - normal running conditions"
    fi
    
    # Wind analysis
    if [ "$windspeed_kph" -gt 20 ]; then
        echo "💨 Strong wind: $windspeed_kph km/h - consider sheltered routes or adjust pace"
    elif [ "$windspeed_kph" -gt 10 ]; then
        echo "💨 Moderate wind: $windspeed_kph km/h - may feel cooler than actual temperature"
    else
        echo "🍃 Light wind: $windspeed_kph km/h - favorable running conditions"
    fi
    
    # Precipitation analysis
    if [ "$(echo "$precip_mm > 0" | bc -l)" -eq 1 ]; then
        echo "🌧️  Precipitation: $precip_mm mm - consider rain gear and slippery surfaces"
    else
        echo "☀️  No precipitation - dry running conditions"
    fi
    
    # Visibility analysis
    if [ "$visibility_km" -lt 2 ]; then
        echo "👁️  Poor visibility: $visibility_km km - wear reflective gear and use lights"
    elif [ "$visibility_km" -lt 5 ]; then
        echo "👁️  Reduced visibility: $visibility_km km - take caution in traffic areas"
    else
        echo "👁️  Good visibility: $visibility_km km - safe running conditions"
    fi
    
    # UV analysis
    if [ "$uv_index" -gt 5 ]; then
        echo "☀️  High UV: Index $uv_index - use sunscreen and protective clothing"
    elif [ "$uv_index" -gt 2 ]; then
        echo "☀️  Moderate UV: Index $uv_index - some sun protection recommended"
    else
        echo "🌙 Low UV: Index $uv_index - minimal sun protection needed"
    fi
}

# Function to combine physiology and weather for final recommendation
generate_final_recommendation() {
    phys_physical="$1"
    phys_emotional="$2"
    phys_intellectual="$3"
    temp_c="$4"
    feelslike_c="$5"
    humidity="$6"
    windspeed_kph="$7"
    precip_mm="$8"
    
    echo ""
    echo "Personalized Running Recommendation:"
    echo "===================================="
    
    # Check if running is advisable based on combined factors
    local go_outside=1
    
    # Check weather conditions
    if [ "$(echo "$precip_mm > 2" | bc -l)" -eq 1 ]; then
        echo "⚠️  Weather Advisory: Heavy precipitation ($precip_mm mm) - Consider indoor alternatives"
        go_outside=0
    fi
    
    if [ "$windspeed_kph" -gt 30 ]; then
        echo "⚠️  Weather Advisory: Strong winds ($windspeed_kph km/h) - Consider postponing outdoor run"
        go_outside=0
    fi
    
    if [ "$feelslike_c" -lt -5 ]; then
        echo "⚠️  Weather Advisory: Extremely cold (feels like $feelslike_c°C) - Consider indoor alternatives"
        go_outside=0
    fi
    
    # Check physiological conditions
    if [ "$phys_physical" -lt -30 ]; then
        echo "⚠️  Physiological Advisory: Physical rhythm low ($phys_physical%) - Consider rest or light exercise"
        go_outside=0
    fi
    
    if [ "$phys_emotional" -lt -50 ]; then
        echo "⚠️  Emotional Advisory: Emotional rhythm unstable ($phys_emotional%) - Consider gentler activity"
    fi
    
    # Generate recommendation based on conditions
    if [ "$go_outside" -eq 1 ]; then
        if [ "$phys_physical" -gt 70 ] && [ "$feelslike_c" -gt 5 ] && [ "$feelslike_c" -lt 18 ]; then
            echo "🏃‍♂️ Excellent day for running! Your physical rhythm is high ($phys_physical%) and conditions are favorable."
            echo "   Recommended: Full planned workout with higher intensity"
        elif [ "$phys_physical" -gt 30 ] && [ "$feelslike_c" -gt 0 ] && [ "$feelslike_c" -lt 25 ]; then
            echo "🚶‍♂️ Good day for running. Your physical rhythm is moderate ($phys_physical%) and conditions are acceptable."
            echo "   Recommended: Regular workout with standard intensity"
        else
            echo " Nordic walking or easy jog recommended based on current conditions."
            echo "   Recommended: Light exercise with reduced intensity"
        fi
        
        # Clothing recommendation based on feels-like temperature
        if [ "$feelslike_c" -lt 5 ]; then
            echo "🧥 Clothing: Wear thermal layers, hat, and gloves. Dress as if it's $(($(echo "$feelslike_c + 10" | bc -l))/1)°C warmer."
        elif [ "$feelslike_c" -lt 12 ]; then
            echo "👕 Clothing: Long sleeves recommended. Consider windbreaker if wind is strong."
        elif [ "$feelslike_c" -lt 18 ]; then
            echo "👕 Clothing: Short sleeves with light layer option. Comfortable temperature."
        elif [ "$feelslike_c" -lt 25 ]; then
            echo "🩱 Clothing: Shorts and t-shirt. Stay hydrated."
        else
            echo "🩱 Clothing: Lightweight, breathable clothing. Prioritize hydration and sun protection."
        fi
        
        # Pace recommendation based on humidity and wind
        if [ "$humidity" -gt 70 ] || [ "$windspeed_kph" -gt 15 ]; then
            echo "🏃‍♂️ Pace: Reduce planned pace by 10-15% due to humidity/wind conditions."
        fi
    else
        echo "🏠 Recommendation: Better to stay indoors today based on weather or physiological conditions."
        echo "   Alternative: Indoor workout, yoga, or rest"
    fi
}

# Main execution
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
else
    echo "Running Weather Advisor"
    echo "======================"
    echo "Birth Date: $BIRTH_DATE"
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
    
    # Get weather data
    echo "Weather Conditions:"
    echo "==================="
    weather_result=$(get_weather_summary "$LOCATION")
    
    # Extract weather values for later use
    temp_c=$(echo "$weather_result" | grep "^TEMP:" | cut -d':' -f2)
    feelslike_c=$(echo "$weather_result" | grep "^FEELSLIKE:" | cut -d':' -f2)
    humidity=$(echo "$weather_result" | grep "^HUMIDITY:" | cut -d':' -f2)
    windspeed_kph=$(echo "$weather_result" | grep "^WINDSPEED:" | cut -d':' -f2)
    visibility_km=$(echo "$weather_result" | grep "^VISIBILITY:" | cut -d':' -f2)
    uv_index=$(echo "$weather_result" | grep "^UV:" | cut -d':' -f2)
    precip_mm=$(echo "$weather_result" | grep "^PRECIP:" | cut -d':' -f2)
    
    # Display weather interpretation
    interpret_weather_for_running "$temp_c" "$feelslike_c" "$humidity" "$windspeed_kph" "$visibility_km" "$uv_index" "$precip_mm"
    
    # Generate final combined recommendation
    generate_final_recommendation "$phys_physical" "$phys_emotional" "$phys_intellectual" \
                                  "$temp_c" "$feelslike_c" "$humidity" "$windspeed_kph" "$precip_mm"
fi