#!/bin/bash
# 最简化版科技简报生成器

# 加载环境变量
source /home/chengzh/.moltbot/env

DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
DEEPSEEK_API_URL="https://api.deepseek.com/chat/completions"

# 获取当前日期
CURRENT_DATE=$(date +'%Y年%m月%d日')
CURRENT_TIME=$(date +'%H:%M')

# 简化的提示词
PROMPT="现在是${CURRENT_TIME}，请生成一份科技简报。

**输出格式：**

### 📈 每日科技巨头战略简报
**日期：** ${CURRENT_DATE}
**市场情绪：** 积极

#### AI动态
* **OpenAI更新：** 最新进展概述
* *信源：Tech News*

#### 芯片行业
* **NVIDIA发展：** 市场动态分析
* *信源：半导体观察*

直接输出完整简报。"

echo "调用 DeepSeek API..."
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
    "max_tokens": 800
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

# 输出简报（供 Moltbot 发送到 Telegram）
echo "$brief"

exit 0