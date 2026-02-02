#!/bin/bash

# Physiology Rhythm Calculator Library for Running Weather Advisor
# Calculates physical, emotional, and intellectual rhythms based on birth date

# Function to calculate days since birth
days_since_birth() {
    local birth_date="$1"
    local current_date="${2:-$(date +%Y-%m-%d)}"
    
    # Calculate the difference in days
    local birth_timestamp=$(date -d "$birth_date" +%s 2>/dev/null)
    local current_timestamp=$(date -d "$current_date" +%s 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "Error: Invalid date format" >&2
        return 1
    fi
    
    local diff_seconds=$((current_timestamp - birth_timestamp))
    local diff_days=$((diff_seconds / 86400))
    
    echo $diff_days
}

# Function to calculate rhythm value for a specific cycle
calculate_rhythm() {
    local days_since_birth="$1"
    local cycle_length="$2"  # 23 for physical, 28 for emotional, 33 for intellectual
    
    local phase=$((days_since_birth % cycle_length))
    local radians=$(echo "$phase * 2 * 3.14159265358979323846 / $cycle_length" | bc -l)
    local value=$(echo "s($radians)" | bc -l)
    
    # Round to 2 decimal places and convert to percentage
    printf "%.0f" $(echo "$value * 100" | bc -l)
}

# Function to get rhythm interpretation
get_rhythm_interpretation() {
    local value="$1"
    local rhythm_type="$2"
    
    if [ "$rhythm_type" = "physical" ]; then
        if [ "$value" -gt 70 ]; then
            echo "High energy level - optimal for intense training"
        elif [ "$value" -gt 30 ]; then
            echo "Moderate energy level - suitable for regular training"
        elif [ "$value" -gt -30 ]; then
            echo "Low energy level - consider light exercise or rest"
        else
            echo "Very low energy level - recommend rest or very light activity"
        fi
    elif [ "$rhythm_type" = "emotional" ]; then
        if [ "$value" -gt 70 ]; then
            echo "Emotionally balanced - good for challenging runs"
        elif [ "$value" -gt 30 ]; then
            echo "Stable emotions - suitable for regular training"
        elif [ "$value" -gt -30 ]; then
            echo "Emotional sensitivity - consider easier runs"
        else
            echo "Emotional instability - consider indoor activities"
        fi
    elif [ "$rhythm_type" = "intellectual" ]; then
        if [ "$value" -gt 70 ]; then
            echo "High focus - good for route planning and technique work"
        elif [ "$value" -gt 30 ]; then
            echo "Normal focus - suitable for regular training"
        elif [ "$value" -gt -30 ]; then
            echo "Reduced focus - stick to familiar routes"
        else
            echo "Low concentration - focus on basic running"
        fi
    fi
}

# Main function to calculate all rhythms
calculate_all_rhythms() {
    local birth_date="$1"
    local target_date="${2:-$(date +%Y-%m-%d)}"
    
    local total_days
    total_days=$(days_since_birth "$birth_date" "$target_date")
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Calculate each rhythm
    local physical=$(calculate_rhythm "$total_days" 23)
    local emotional=$(calculate_rhythm "$total_days" 28)
    local intellectual=$(calculate_rhythm "$total_days" 33)
    
    # Output results
    echo "Physical Rhythm: $physical%"
    echo "Emotional Rhythm: $emotional%"
    echo "Intellectual Rhythm: $intellectual%"
    
    echo ""
    echo "Interpretations:"
    echo "Physical: $(get_rhythm_interpretation $physical "physical")"
    echo "Emotional: $(get_rhythm_interpretation $emotional "emotional")"
    echo "Intellectual: $(get_rhythm_interpretation $intellectual "intellectual")"
}