#!/bin/bash
# OpenClaw 产品动态简报 - Telegraph 版

# 加载环境变量
if [ -f ~/.moltbot/env ]; then
  export $(cat ~/.moltbot/env | grep -v '^#' | xargs)
fi

ACCESS_TOKEN="77d3b1267926b078105fdf4d08fe60bab9102d76447df01e84aa219782ad"

# 运行简报生成脚本
BRIEF_OUTPUT=$(/home/chengzh/clawd/scripts/openclaw-updates-brief.sh 2>&1)
BRIEF_CONTENT=$(echo "$BRIEF_OUTPUT" | sed -n '/^### 🦞 OpenClaw/,/^📌 数据源/p')

# 生成标题和日期
BRIEF_DATE=$(date +%Y年%m月%d日)
BRIEF_TITLE="OpenClaw 每日产品动态简报 - $BRIEF_DATE"

# 将 Markdown 转换为 Telegraph JSON
TELEGRAPH_JSON=$(echo "$BRIEF_CONTENT" | python3 -c '
import sys, json

markdown = sys.stdin.read()
lines = markdown.strip().split("\n")
nodes = []

for line in lines:
    line = line.strip()
    if not line:
        continue
    
    if line.startswith("### "):
        nodes.append({"tag": "h3", "children": [line[4:]]})
    elif line.startswith("#### "):
        nodes.append({"tag": "h4", "children": [line[5:]]})
    elif line.startswith("* ") or line.startswith("- "):
        content = line[2:]
        if "**" in content:
            parts = content.split("**")
            children = []
            for i, part in enumerate(parts):
                if i % 2 == 1:
                    children.append({"tag": "strong", "children": [part]})
                elif part:
                    children.append(part)
            nodes.append({"tag": "p", "children": children})
        else:
            nodes.append({"tag": "p", "children": ["• " + content]})
    else:
        if "**" in line:
            parts = line.split("**")
            children = []
            for i, part in enumerate(parts):
                if i % 2 == 1:
                    children.append({"tag": "strong", "children": [part]})
                elif part:
                    children.append(part)
            nodes.append({"tag": "p", "children": children})
        else:
            nodes.append({"tag": "p", "children": [line]})

print(json.dumps(nodes, ensure_ascii=False))
')

# 发布到 Telegra.ph
RESPONSE=$(curl -s https://api.telegra.ph/createPage \
  --data-urlencode "access_token=$ACCESS_TOKEN" \
  --data-urlencode "title=$BRIEF_TITLE" \
  --data-urlencode "author_name=cloudzun" \
  --data-urlencode "content=$TELEGRAPH_JSON")

# 提取 URL
URL=$(echo "$RESPONSE" | jq -r '.result.url // ""')

if [ -n "$URL" ] && [ "$URL" != "null" ]; then
  # 成功：发送 Telegraph 链接
  moltbot message send --channel telegram --target 975144416 --message "🦞 **OpenClaw 每日产品动态简报**
📅 $BRIEF_DATE

📖 查看完整简报：
$URL"
else
  # 失败：发送错误信息和原始简报
  echo "Telegraph 发布失败：$RESPONSE" >&2
  moltbot message send --channel telegram --target 975144416 --message "$BRIEF_CONTENT"
fi
