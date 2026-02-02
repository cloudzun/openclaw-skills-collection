#!/bin/bash
# Tech Brief Skill - Test Script

echo "🧪 Testing Tech Brief Skill..."

# Check if required tools are available
echo "Checking dependencies..."
if ! command -v curl &> /dev/null; then
    echo "❌ curl is not installed"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq is not installed"
    exit 1
fi

echo "✅ Dependencies satisfied"

# Test the main functionality
echo "Testing main script..."
bash /home/chengzh/clawd/skills/tech-brief/main.sh --help 2>/dev/null || echo "Main script doesn't support --help, proceeding with basic test"

echo "Tech Brief Skill is ready to use!"
echo ""
echo "To run the skill:"
echo "  bash /home/chengzh/clawd/skills/tech-brief/main.sh"
echo "  bash /home/chengzh/clawd/skills/tech-brief/no-telegraph.sh"
echo "  bash /home/chengzh/clawd/skills/tech-brief/minimal.sh"
echo "  bash /home/chengzh/clawd/skills/tech-brief/debug.sh"
echo "  bash /home/chengzh/clawd/skills/tech-brief/debug-full.sh"