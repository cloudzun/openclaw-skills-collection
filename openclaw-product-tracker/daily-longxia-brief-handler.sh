#!/bin/bash

# daily-longxia-brief-handler.sh
# 龙虾简报每日任务处理器

echo "🦞 开始执行龙虾简报(Longxia Brief)每日任务..."

# 运行本地简报生成脚本
bash /home/chengzh/clawd/skills/openclaw-product-tracker/local-openclaw-brief.sh

# 运行简报推送脚本（如果需要推送到Telegram）
bash /home/chengzh/clawd/skills/openclaw-product-tracker/send-longxia-brief-to-tg.sh

echo "✅ 龙虾简报任务完成"