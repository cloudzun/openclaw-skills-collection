#!/bin/bash

# Daily Review and Notification Script
# 执行每日回顾管理并推送通知到TG

# 运行每日回顾管理脚本
bash /home/chengzh/clawd/skills/daily-review-ritual/daily_review_manager.sh

# 获取今天的日期和文件
TODAY=$(date +%Y-%m-%d)
TODAY_FILE="/home/chengzh/clawd/memory/$TODAY.md"

# 读取今天的回顾内容并准备发送到TG
if [ -f "$TODAY_FILE" ]; then
    echo "每日回顾已更新: $TODAY"
    echo "文件位置: $TODAY_FILE"
    
    # 提取主要内容用于TG推送
    echo "今日回顾摘要:"
    head -20 "$TODAY_FILE"
    
    # 创建明天的日期
    TOMORROW=$(date -d "+1 day" +%Y-%m-%d)
    echo ""
    echo "已创建明天($TOMORROW)的回顾模板，随时可以开始规划明天的任务。"
else
    echo "错误: 今天($TODAY)的回顾文件未找到!"
fi