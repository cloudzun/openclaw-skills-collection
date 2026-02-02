#!/bin/bash
# 全球情报简报生成器 - Telegraph 版

DEEPSEEK_API_KEY="sk-ff7cc5e3702a40f9b786d78b18d28100"
DEEPSEEK_API_URL="https://api.deepseek.com/chat/completions"
TELEGRAPH_ACCESS_TOKEN="77d3b1267926b078105fdf4d08fe60bab9102d76447df01e84aa219782ad"

# 简报生成提示词
read -r -d '' PROMPT << 'EOF'
现在是2026年02月01日早上6:00，请执行每日全球情报简报任务。

任务要求：
1. 抓取以下新闻源的最新内容（严格限于当天过去12小时）：
   - BBC World News (https://www.bbc.com/news/world)
   - The Guardian World (https://www.theguardian.com/world)
   - Al Jazeera (https://www.aljazeera.com/)
   - South China Morning Post (https://www.scmp.com/)

2. 重点领域：地缘政治（Geopolitics）、区域冲突（Global Conflict）、宏观经济（Macro Economy）

3. 处理逻辑：
   - **聚类**：将同一话题的信息归类
   - **去重**：剔除重复观点，合并相同事件的不同报道
   - **综合**：拼接不同信源的信息，形成完整叙述
   - **验证**：优先引用带有具体数据、地理位置、政策条款的硬新闻

4. 输出格式（严格遵循）：

### 🌍 每日全球情报简报 (Daily Intelligence Briefing)
**日期：** [今天日期]
**核心主题：** [根据今日内容提炼总标题]

#### 1. 【板块标题】
**⚡ 核心研判：** [一句话战略趋势]
* **[子话题A]：** 详细描述...
* **[子话题B]：** ...
* *整合信源：[列出贡献价值的媒体]*

[重复3-5个板块]

#### 💡 分析师关注 (Analyst's Takeaway)
**风险提示：**
- [基于情报的未来24-48h或中长期预测]

**机会洞察：**
- [未被充分讨论的盲点]

5. **质量标准：**
   - 必须包含具体地理位置、数据变化或政策条款
   - 排除纯情绪发泄、阴谋论、重复标题党
   - 深度 > 广度：宁可3个深度板块，不要10个浅薄罗列

6. 直接输出完整简报，不要额外说明。
EOF

# 转义 JSON
PROMPT_JSON=$(echo "$PROMPT" | jq -Rs .)

# 调用 DeepSeek API
response=$(curl -s "$DEEPSEEK_API_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -d '{
    "model": "deepseek-chat",
    "messages": [
      {
        "role": "user",
        "content": '"$PROMPT_JSON"'
      }
    ],
    "temperature": 0.7,
    "max_tokens": 8000
  }')

# 检查是否成功
if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
  echo "❌ API 调用失败："
  echo "$response" | jq '.error'
  exit 1
fi

# 提取生成的内容
brief=$(echo "$response" | jq -r '.choices[0].message.content')

# 记录使用情况
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
prompt_tokens=$(echo "$response" | jq -r '.usage.prompt_tokens')
completion_tokens=$(echo "$response" | jq -r '.usage.completion_tokens')
total_tokens=$(echo "$response" | jq -r '.usage.total_tokens')
log_file="$HOME/clawd/memory/deepseek-usage.jsonl"
echo "{\"timestamp\":\"$timestamp\",\"model\":\"deepseek-chat\",\"prompt_tokens\":$prompt_tokens,\"completion_tokens\":$completion_tokens,\"total_tokens\":$total_tokens,\"task\":\"global-intel-brief\"}" >> "$log_file"

# 发布到 Telegraph
BRIEF_DATE=$(date +%Y年%m月%d日)
BRIEF_TITLE="每日全球情报简报 - $BRIEF_DATE"

# 转换为 Telegraph JSON
TELEGRAPH_JSON=$(echo "$brief" | python3 -c '
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

# 发布到 Telegraph
TELEGRAPH_RESPONSE=$(curl -s https://api.telegra.ph/createPage \
  --data-urlencode "access_token=$TELEGRAPH_ACCESS_TOKEN" \
  --data-urlencode "title=$BRIEF_TITLE" \
  --data-urlencode "author_name=cloudzun" \
  --data-urlencode "content=$TELEGRAPH_JSON")

TELEGRAPH_URL=$(echo "$TELEGRAPH_RESPONSE" | jq -r '.result.url // ""')

# 输出（会被 Moltbot 发送到 Telegram）
if [ -n "$TELEGRAPH_URL" ] && [ "$TELEGRAPH_URL" != "null" ]; then
    echo "🌍 **每日全球情报简报**"
    echo "📅 $BRIEF_DATE"
    echo ""
    echo "📖 查看完整简报："
    echo "$TELEGRAPH_URL"
else
    # Telegraph 发布失败，输出原始简报
    echo "$brief"
fi

exit 0
