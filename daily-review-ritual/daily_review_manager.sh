#!/bin/bash

# Daily Review Manager Script
# 自动创建和管理每日回顾文件

# 获取今天的日期 (YYYY-MM-DD格式)
TODAY=$(date +%Y-%m-%d)
TOMORROW=$(date -d "+1 day" +%Y-%m-%d)

# 定义文件路径
TODAY_FILE="/home/chengzh/clawd/memory/$TODAY.md"
TOMORROW_FILE="/home/chengzh/clawd/memory/$TOMORROW.md"
TEMPLATE_FILE="/home/chengzh/clawd/skills/daily-review-ritual/daily_review_template.md"

# 确保memory目录存在
mkdir -p /home/chengzh/clawd/memory

# 检查今天的文件是否存在，如果不存在则创建
if [ ! -f "$TODAY_FILE" ]; then
    echo "# Daily Review - $TODAY" > $TODAY_FILE
    echo "" >> $TODAY_FILE
    echo "## Accomplished" >> $TODAY_FILE
    echo "- " >> $TODAY_FILE
    echo "- " >> $TODAY_FILE
    echo "" >> $TODAY_FILE
    echo "## Progress Made" >> $TODAY_FILE
    echo "- [Project/Area]: [What moved forward]" >> $TODAY_FILE
    echo "- [Project/Area]: [What moved forward]" >> $TODAY_FILE
    echo "" >> $TODAY_FILE
    echo "## Insights" >> $TODAY_FILE
    echo "- [Key realization or connection]" >> $TODAY_FILE
    echo "- [Important learning]" >> $TODAY_FILE
    echo "" >> $TODAY_FILE
    echo "## Blocked/Stuck" >> $TODAY_FILE
    echo "- [What didn't progress and why]" >> $TODAY_FILE
    echo "" >> $TODAY_FILE
    echo "## Discovered Questions" >> $TODAY_FILE
    echo "- [New question that emerged]" >> $TODAY_FILE
    echo "- [Thing to research]" >> $TODAY_FILE
    echo "" >> $TODAY_FILE
    echo "## Tomorrow's Focus" >> $TODAY_FILE
    echo "1. [Priority 1]" >> $TODAY_FILE
    echo "2. [Priority 2]" >> $TODAY_FILE
    echo "3. [Priority 3]" >> $TODAY_FILE
    echo "" >> $TODAY_FILE
    echo "## Open Loops" >> $TODAY_FILE
    echo "- [ ] [Thing to remember]" >> $TODAY_FILE
    echo "- [ ] [Person to follow up with]" >> $TODAY_FILE
    echo "- [ ] [Idea to develop]" >> $TODAY_FILE
    echo "" >> $TODAY_FILE
    
    echo "Created today's review file: $TODAY_FILE"
else
    echo "Today's review file already exists: $TODAY_FILE"
fi

# 检查明天的文件是否存在，如果不存在则创建
if [ ! -f "$TOMORROW_FILE" ]; then
    cp $TEMPLATE_FILE $TOMORROW_FILE
    sed -i "s/\[DATE\]/$TOMORROW/g" $TOMORROW_FILE
    echo "Created tomorrow's review file: $TOMORROW_FILE"
else
    echo "Tomorrow's review file already exists: $TOMORROW_FILE"
fi

echo "Daily review files management completed."