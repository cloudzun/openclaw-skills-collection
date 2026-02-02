#!/bin/bash
# quick-start-longxia.sh
# 龙虾简报系统快速启动脚本

echo "🦞 龙虾简报(Longxia Brief)系统快速启动"
echo "=================================="

echo ""
echo "🔍 检查系统状态..."

# 检查必要组件
COMPONENTS=(
    "gh" "bird" "curl" "jq"
)

for comp in "${COMPONENTS[@]}"; do
    if command -v "$comp" &> /dev/null; then
        echo "  ✅ $comp 可用"
    else
        echo "  ❌ $comp 未安装"
    fi
done

echo ""
echo "📋 检查数据源连通性..."
bash /home/chengzh/clawd/skills/openclaw-product-tracker/test-data-sources.sh

echo ""
echo "⏰ Cron任务状态:"
clawd cron list | jq -r '.jobs[] | select(.name | contains("龙虾简报")) | "  ✅ \(.name) - \(.schedule.expr) (\(.schedule.tz))"' 2>/dev/null || echo "  未找到相关任务"

echo ""
echo "🚀 可用命令:"
echo "  1. 运行简报生成: bash /home/chengzh/clawd/skills/openclaw-product-tracker/local-openclaw-brief.sh"
echo "  2. 测试数据源: bash /home/chengzh/clawd/skills/openclaw-product-tracker/test-data-sources.sh"
echo "  3. 查看cron任务: clawd cron list | grep 龙虾简报"
echo "  4. 手动触发简报: bash /home/chengzh/clawd/skills/openclaw-product-tracker/daily-longxia-brief-handler.sh"

echo ""
echo "🎯 龙虾简报系统准备就绪！"