#!/bin/bash

# test-longxia-system.sh
# 龙虾简报系统完整性测试

echo "🔍 开始测试龙虾简报(Longxia Brief)系统完整性..."

echo ""
echo "📋 检查系统组件:"
echo "- 检查目录结构..."
if [ -d "/home/chengzh/clawd/skills/openclaw-product-tracker" ]; then
    echo "  ✅ 目录存在"
else
    echo "  ❌ 目录不存在"
    exit 1
fi

echo "- 检查主要脚本..."
SCRIPTS=(
    "simple-integrated-brief.sh"
    "send-longxia-brief-to-tg.sh"
    "daily-longxia-brief-handler.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "/home/chengzh/clawd/skills/openclaw-product-tracker/$script" ]; then
        if [ -x "/home/chengzh/clawd/skills/openclaw-product-tracker/$script" ]; then
            echo "  ✅ $script (可执行)"
        else
            echo "  ⚠️  $script (存在但不可执行)"
        fi
    else
        echo "  ❌ $script (不存在)"
    fi
done

echo ""
echo "📋 检查数据源可用性:"
echo "- 检查GitHub连接..."
if command -v gh &> /dev/null; then
    GH_AUTH_STATUS=$(gh auth status 2>&1)
    if echo "$GH_AUTH_STATUS" | grep -q "Logged in to"; then
        echo "  ✅ GitHub CLI 已认证"
    else
        echo "  ⚠️  GitHub CLI 未认证"
    fi
else
    echo "  ❌ GitHub CLI 未安装"
fi

echo "- 检查Moltbook API..."
if [ -n "$MOLTBOOK_API_TOKEN" ]; then
    echo "  ✅ Moltbook API Token 已配置"
else
    echo "  ⚠️  Moltbook API Token 未配置"
fi

echo "- 检查X平台连接..."
if command -v bird &> /dev/null; then
    echo "  ✅ Bird CLI 已安装"
else
    echo "  ❌ Bird CLI 未安装"
fi

echo ""
echo "📋 检查环境变量:"
ENV_VARS=("TELEGRA_PH_BOT_TOKEN" "TELEGRA_PH_ACCOUNT_TOKEN" "TELEGRAM_CHAT_ID" "MOLTBOOK_API_TOKEN" "DEEPSEEK_API_KEY")

for var in "${ENV_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        echo "  ✅ $var 已设置"
    else
        echo "  ⚠️  $var 未设置"
    fi
done

echo ""
echo "📋 检查Cron任务:"
if command -v jq &> /dev/null; then
    CRON_JOB=$(clawd cron list 2>/dev/null | jq -r '.jobs[] | select(.id == "33858783-66ae-41ea-a6fc-1adec1ec72cc")' 2>/dev/null)
    if [ -n "$CRON_JOB" ] && [ "$CRON_JOB" != "null" ]; then
        JOB_NAME=$(echo "$CRON_JOB" | jq -r '.name' 2>/dev/null)
        SCHEDULE=$(echo "$CRON_JOB" | jq -r '.schedule.expr' 2>/dev/null)
        TIMEZONE=$(echo "$CRON_JOB" | jq -r '.schedule.tz' 2>/dev/null)
        echo "  ✅ Cron任务已配置"
        echo "     名称: $JOB_NAME"
        echo "     时间: $SCHEDULE ($TIMEZONE)"
    else
        echo "  ❌ Cron任务未找到"
    fi
else
    echo "  ⚠️  jq 未安装，跳过cron任务检查"
fi

echo ""
echo "📋 检查文档:"
DOCS=("SKILL.md" "README.md" "config.json")
for doc in "${DOCS[@]}"; do
    if [ -f "/home/chengzh/clawd/skills/openclaw-product-tracker/$doc" ]; then
        echo "  ✅ $doc 存在"
    else
        echo "  ❌ $doc 不存在"
    fi
done

echo ""
echo "🎯 系统完整性测试完成!"