#!/bin/bash
# 简化版科技简报调试脚本

# 加载环境变量
source /home/chengzh/.moltbot/env

DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
DEEPSEEK_API_URL="https://api.deepseek.com/chat/completions"

# 简化提示词进行测试
PROMPT="请简单介绍一下今天科技领域的热点，包括AI、芯片和互联网巨头方面的动态，用markdown格式输出，大约100字。"

# 调用 DeepSeek API
echo "正在调用 DeepSeek API..."
response=$(curl -s "$DEEPSEEK_API_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -d '{
    "model": "deepseek-chat",
    "messages": [
      {
        "role": "user",
        "content": "'"${PROMPT}"'"
      }
    ],
    "temperature": 0.7,
    "max_tokens": 600
  }')

# 检查响应
echo "API 响应："
echo "$response" | jq .

# 检查是否成功
if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
  echo "❌ API 调用失败："
  echo "$response" | jq '.error'
  exit 1
fi

# 提取生成的内容
brief=$(echo "$response" | jq -r '.choices[0].message.content')
echo "生成的内容："
echo "$brief"

exit 0