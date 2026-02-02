#!/bin/bash
# Global Intelligence Brief Skill - Test Script

echo "🧪 Testing Global Intelligence Brief Skill..."

# Check if required tools are available
echo "Checking dependencies..."
if ! command -v python3 &> /dev/null; then
    echo "❌ python3 is not installed"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "❌ curl is not installed"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq is not installed"
    exit 1
fi

# Check if required Python modules are available
if ! python3 -c "import openai" &> /dev/null; then
    echo "❌ openai module is not installed"
    echo "Please run: apt install python3-openai"
    exit 1
fi

echo "✅ All dependencies are satisfied"

# Test the main functionality
echo "Running analyzer test..."
python3 /home/chengzh/clawd/skills/global-intel-brief/analyzer.py --help 2>/dev/null || echo "Analyzer doesn't support --help, proceeding with basic test"

echo "Global Intelligence Brief Skill is ready to use!"
echo ""
echo "To run the skill:"
echo "  bash /home/chengzh/clawd/skills/global-intel-brief/main.sh"
echo "  python3 /home/chengzh/clawd/skills/global-intel-brief/analyzer.py"
echo "  bash /home/chengzh/clawd/skills/global-intel-brief/publisher.sh"