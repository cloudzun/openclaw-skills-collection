#!/bin/bash
# 科技巨头战略简报生成器 - 不包含Telegraph调试

# 加载环境变量
source /home/chengzh/.moltbot/env

DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
DEEPSEEK_API_URL="https://api.deepseek.com/chat/completions"

# 获取当前日期与时间
CURRENT_DATE=$(date +'%Y年%m月%d日')
CURRENT_TIME=$(date +'%H:%M')

# 科技简报生成提示词
PROMPT="现在是${CURRENT_TIME}，请生成一份科技简报。

**输出格式：**

### 📈 每日科技巨头战略简报
**日期：** ${CURRENT_DATE}
**市场情绪：** 积极

#### AI动态
* **OpenAI更新：** 最新进展描述
* *信源：Tech News*

#### 芯片行业
* **NVIDIA动向：** 相关行情分析
* *信源：半导体观察*"

# 调用 DeepSeek API
response=$(curl -s --connect-timeout 15 --max-time 60 "$DEEPSEEK_API_URL" \
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

# 提取生成的内容
brief=$(echo "$response" | jq -r '.choices[0].message.content')

# 输出简报
echo "=== 科技简报 ==="
echo "$brief" > /home/chengzh/clawd/tech-brief-summary.txt
echo "$brief"
echo "=== 简报生成结束 ==="