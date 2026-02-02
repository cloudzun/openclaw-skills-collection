#!/bin/bash

# send-longxia-brief-to-tg.sh
# 龙虾简报 - OpenClaw产品动态日报推送脚本
# 每日9:00 AM推送

set -e  # 遇到错误时退出

echo "🚀 开始生成龙虾简报(Longxia Brief) - $(date '+%Y-%m-%d %H:%M:%S')"

# 检查必要的环境变量
REQUIRED_ENVS=("TELEGRA_PH_BOT_TOKEN" "TELEGRA_PH_ACCOUNT_TOKEN" "TELEGRAM_CHAT_ID" "MOLTBOOK_API_TOKEN" "DEEPSEEK_API_KEY")
MISSING_ENVS=()

for env_var in "${REQUIRED_ENVS[@]}"; do
    if [ -z "${!env_var}" ]; then
        MISSING_ENVS+=("$env_var")
    fi
done

if [ ${#MISSING_ENVS[@]} -gt 0 ]; then
    echo "⚠️  警告: 以下环境变量未设置: ${MISSING_ENVS[*]}"
    echo "请确保在 ~/.moltbot/env 中设置了这些变量"
fi

# 运行集成简报脚本
echo "📊 正在收集GitHub、Moltbook数据..."
REPORT_OUTPUT=$(bash /home/chengzh/clawd/skills/openclaw-product-tracker/simple-integrated-brief.sh 2>&1)
REPORT_EXIT_CODE=$?

if [ $REPORT_EXIT_CODE -ne 0 ]; then
    echo "❌ 简报生成失败，输出:"
    echo "$REPORT_OUTPUT"
    
    # 发送错误通知到Telegram
    if [ -n "$TELEGRA_PH_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        ERROR_MESSAGE="🚨 龙虾简报生成失败！

📅 日期: $(date '+%Y-%m-%d %H:%M:%S')
💻 主机: $(hostname)
⚠️  错误详情:
$(echo "$REPORT_OUTPUT" | tail -10)

请检查系统状态。"

        curl -s -X POST "https://api.telegram.org/bot$TELEGRA_PH_BOT_TOKEN/sendMessage" \
            -d "chat_id=$TELEGRAM_CHAT_ID&text=$ERROR_MESSAGE&parse_mode=Markdown" > /dev/null
    fi
    exit 1
else
    echo "✅ 简报数据收集完成"
    echo "$REPORT_OUTPUT"
    
    # 发送成功通知到Telegram（如果配置了Telegram）
    if [ -n "$TELEGRA_PH_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        SUCCESS_MESSAGE="🦞 龙虾简报(Longxia Brief) - $(date '+%Y-%m-%d')

📋 OpenClaw产品动态日报已生成完成！

$(echo "$REPORT_OUTPUT" | head -50)"

        # 由于内容较长，我们发送摘要
        curl -s -X POST "https://api.telegram.org/bot$TELEGRA_PH_BOT_TOKEN/sendMessage" \
            -d "chat_id=$TELEGRAM_CHAT_ID&text=$SUCCESS_MESSAGE&parse_mode=Markdown" > /dev/null
    fi
fi

echo "🎯 龙虾简报推送任务完成"