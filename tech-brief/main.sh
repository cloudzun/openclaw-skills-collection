#!/bin/bash
# 科技巨头战略简报生成器 - Telegraph 版

# 加载环境变量
source /home/chengzh/.moltbot/env

DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
DEEPSEEK_API_URL="https://api.deepseek.com/chat/completions"
TELEGRAPH_ACCESS_TOKEN=${TELEGRAPH_ACCESS_TOKEN}

# 获取当前日期
CURRENT_DATE=$(date +'%Y年%m月%d日')
CURRENT_TIME=$(date +'%H:%M')

# 科技简报生成提示词
PROMPT="现在是${CURRENT_TIME}，请执行科技巨头战略简报任务。

**信息源（当前日期强制刷新）：**
1. The Verge Tech (https://www.theverge.com/tech)
2. TechCrunch (https://techcrunch.com/)
3. SCMP Tech (https://www.scmp.com/tech)
4. The Guardian Tech (https://www.theguardian.com/technology)
5. BBC Tech (https://www.bbc.com/news/technology)

**关注领域：**
- AI大模型（OpenAI, Anthropic, Google, 中国大模型）
- 芯片/硬件（NVIDIA, AMD, Intel, TSMC, 华为等）
- 造车新势力（Tesla, 比亚迪, 小米汽车等）
- 互联网巨头（Apple, Microsoft, Amazon, Meta, 腾讯, 阿里等）

**输出格式：**

### 📈 每日科技巨头战略简报
**日期：** ${CURRENT_DATE}
**市场情绪：** [一句话概括]

#### 1. 【板块标题】
* **[公司 - 事件]：** 核心事实 + 商业影响
* *信源：[列出媒体]*

[输出3-5个最有价值的板块]

#### 💡 分析师关注
**风险/机会：**
- [关键预测或盲点]

直接输出完整简报，不要额外说明。"

# 调用 DeepSeek API (添加超时参数和减少最大令牌数)
response=$(curl -s --connect-timeout 10 --max-time 90 "$DEEPSEEK_API_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -d '{
    "model": "deepseek-chat",
    "messages": [
      {
        "role": "user",
        "content": '"$(echo "$PROMPT" | jq -Rs .)"'
      }
    ],
    "temperature": 0.7,
    "max_tokens": 1000
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
echo "{\"timestamp\":\"$timestamp\",\"model\":\"deepseek-chat\",\"prompt_tokens\":$prompt_tokens,\"completion_tokens\":$completion_tokens,\"total_tokens\":$total_tokens,\"task\":\"tech-brief\"}" >> "$log_file"

# 发布到 Telegraph
BRIEF_DATE=$(date +%Y年%m月%d日)
BRIEF_TITLE="每日科技巨头战略简报 - $BRIEF_DATE"

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
TELEGRAPH_RESPONSE=$(curl -s --connect-timeout 10 --max-time 30 https://api.telegra.ph/createPage \
  --data-urlencode "access_token=$TELEGRAPH_ACCESS_TOKEN" \
  --data-urlencode "title=$BRIEF_TITLE" \
  --data-urlencode "author_name=cloudzun" \
  --data-urlencode "content=$TELEGRAPH_JSON")

TELEGRAPH_URL=$(echo "$TELEGRAPH_RESPONSE" | jq -r '.result.url // ""')

# 输出（会被 Moltbot 发送到 Telegram）
if [ -n "$TELEGRAPH_URL" ] && [ "$TELEGRAPH_URL" != "null" ]; then
    echo "📈 **每日科技巨头战略简报**"
    echo "📅 $BRIEF_DATE"
    echo ""
    echo "📖 查看完整简报："
    echo "$TELEGRAPH_URL"
else
    # Telegraph 发布失败，输出原始简报
    echo "$brief"
fi

exit 0