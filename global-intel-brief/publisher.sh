#!/bin/bash
# 全球情报简报 - Telegraph 发布包装脚本

# 加载 Telegraph 工具库
source /home/chengzh/clawd/scripts/telegraph-lib.sh

# 生成简报（使用现有的 Python 脚本）
BRIEF_CONTENT=$(python3 /home/chengzh/clawd/scripts/global-intel-brief.sh 2>&1)

# 生成标题
BRIEF_DATE=$(date +%Y年%m月%d日)
BRIEF_TITLE="每日全球情报简报 - $BRIEF_DATE"

# 发布到 Telegraph
TELEGRAPH_URL=$(publish_to_telegraph "$BRIEF_TITLE" "$BRIEF_CONTENT" "cloudzun")

if [ $? -eq 0 ] && [ -n "$TELEGRAPH_URL" ]; then
    # 输出 Telegraph 链接（会被 Moltbot 发送到 Telegram）
    echo "🌍 **每日全球情报简报**"
    echo "📅 $BRIEF_DATE"
    echo ""
    echo "📖 查看完整简报："
    echo "$TELEGRAPH_URL"
else
    # 发布失败，直接输出原始简报
    echo "$BRIEF_CONTENT"
fi
