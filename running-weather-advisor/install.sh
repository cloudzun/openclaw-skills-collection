#!/bin/bash

# Installation script for Running Weather Advisor Skill

set -e

SKILL_NAME="running-weather-advisor"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_SKILLS_DIR="/home/chengzh/clawd/skills"

echo "Installing $SKILL_NAME skill..."

# Check if running from skill directory
if [[ ! -f "$SKILL_DIR/running_advisor.sh" ]]; then
    echo "Error: This script must be run from the skill directory"
    exit 1
fi

# Check if OpenClaw skills directory exists
if [[ ! -d "$OPENCLAW_SKILLS_DIR" ]]; then
    echo "Error: OpenClaw skills directory does not exist: $OPENCLAW_SKILLS_DIR"
    exit 1
fi

# Copy skill to OpenClaw skills directory
DEST_DIR="$OPENCLAW_SKILLS_DIR/$SKILL_NAME"
if [[ -d "$DEST_DIR" ]]; then
    echo "Warning: $DEST_DIR already exists. Updating..."
    rsync -av --exclude='install.sh' "$SKILL_DIR/" "$DEST_DIR/"
else
    echo "Creating skill directory..."
    mkdir -p "$DEST_DIR"
    rsync -av --exclude='install.sh' "$SKILL_DIR/" "$DEST_DIR/"
fi

# Ensure proper permissions
chmod +x "$DEST_DIR/running_advisor_simple.sh"
chmod +x "$DEST_DIR/lib/physiology_calculator.sh"
chmod +x "$DEST_DIR/lib/weather_data.sh"

echo "Installation completed!"
echo ""
echo "Skill installed to: $DEST_DIR"
echo ""
echo "To test the skill, run:"
echo "  cd $DEST_DIR"
echo "  ./running_advisor_simple.sh 1977-03-04 201108"
echo ""
echo "The skill is now ready to use with OpenClaw."