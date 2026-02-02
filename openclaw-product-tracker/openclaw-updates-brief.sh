#!/bin/bash
# OpenClaw 产品动态简报生成器 - 优化版（强化社区和Twitter内容）

# 加载环境变量（Twitter credentials）
if [ -f ~/.moltbot/env ]; then
  export $(cat ~/.moltbot/env | grep -v '^#' | xargs)
fi

DEEPSEEK_API_KEY="sk-ff7cc5e3702a40f9b786d78b18d28100"
DEEPSEEK_API_URL="https://api.deepseek.com/chat/completions"

# GitHub 仓库配置
GITHUB_REPO="openclaw/openclaw"

# 临时文件
TEMP_DIR="/tmp/openclaw-brief-$$"
mkdir -p "$TEMP_DIR"

echo "📊 正在收集 OpenClaw 产品动态数据..."

# ==================== 检查依赖 ====================
if ! gh auth status &>/dev/null; then
  echo "❌ GitHub CLI 未登录"
  GITHUB_AVAILABLE=false
else
  GITHUB_AVAILABLE=true
fi

if ! command -v bird &>/dev/null; then
  echo "⚠️  bird 未安装"
  TWITTER_AVAILABLE=false
else
  TWITTER_AVAILABLE=true
fi

# ==================== 1. GitHub 数据收集（精简）====================
if [ "$GITHUB_AVAILABLE" = true ]; then
  echo "  → 抓取 GitHub 核心数据..."

  # 最新 release（只需要基本信息）
  gh api "repos/$GITHUB_REPO/releases/latest" > "$TEMP_DIR/latest-release.json" 2>/dev/null || echo "null" > "$TEMP_DIR/latest-release.json"

  # 最近3天的重要 PRs（减少数量）
  gh pr list --repo "$GITHUB_REPO" --state merged --limit 10 --json number,title,mergedAt,url > "$TEMP_DIR/recent-prs.json" 2>/dev/null || echo "[]" > "$TEMP_DIR/recent-prs.json"

  # 热门 Issues（按评论数排序，只取前5个）
  gh issue list --repo "$GITHUB_REPO" --state open --limit 5 --json number,title,createdAt,url,comments --jq 'sort_by(.comments | length) | reverse' > "$TEMP_DIR/hot-issues.json" 2>/dev/null || echo "[]" > "$TEMP_DIR/hot-issues.json"

  echo "  → GitHub 数据收集完成"
else
  echo "null" > "$TEMP_DIR/latest-release.json"
  echo "[]" > "$TEMP_DIR/recent-prs.json"
  echo "[]" > "$TEMP_DIR/hot-issues.json"
  echo "  ⚠️  跳过 GitHub 数据"
fi

# ==================== 2. Twitter 数据收集（加强）====================
if [ "$TWITTER_AVAILABLE" = true ]; then
  echo "  → 抓取 Twitter 高热度内容..."
  
  # 官方推文
  bird search "from:openclaw" -n 10 > "$TEMP_DIR/openclaw-tweets.txt" 2>&1
  
  # 社区讨论（提到 openclaw 的推文）
  bird search "openclaw OR @openclaw -from:openclaw" -n 30 > "$TEMP_DIR/openclaw-mentions.txt" 2>&1
  
  # 检查是否成功
  if [ $? -ne 0 ]; then
    echo "Twitter 数据获取失败" > "$TEMP_DIR/openclaw-tweets.txt"
    echo "Twitter 数据获取失败" > "$TEMP_DIR/openclaw-mentions.txt"
    echo "  ⚠️  Twitter 数据获取失败"
  else
    echo "  → Twitter 数据收集完成"
  fi
else
  echo "bird 未安装" > "$TEMP_DIR/openclaw-tweets.txt"
  echo "bird 未安装" > "$TEMP_DIR/openclaw-mentions.txt"
  echo "  ⚠️  跳过 Twitter 数据"
fi

# ==================== 3. 汇总数据 ====================
echo "📝 汇总数据并生成简报..."

# 构建上下文数据
GITHUB_RELEASE=$(cat "$TEMP_DIR/latest-release.json" | jq -c '{name, tag_name, published_at}' 2>/dev/null || echo "null")
GITHUB_PRS=$(cat "$TEMP_DIR/recent-prs.json" | jq -c 'map({number, title, mergedAt}) | .[0:5]' 2>/dev/null || echo "[]")
GITHUB_ISSUES=$(cat "$TEMP_DIR/hot-issues.json" | jq -c 'map({number, title, comment_count: (.comments | length)}) | .[0:5]' 2>/dev/null || echo "[]")
TWITTER_OFFICIAL=$(cat "$TEMP_DIR/openclaw-tweets.txt")
TWITTER_COMMUNITY=$(cat "$TEMP_DIR/openclaw-mentions.txt")

# 数据可用性
DATA_STATUS="GitHub: $( [ "$GITHUB_AVAILABLE" = true ] && echo '✅' || echo '❌' ), Twitter: $( [ "$TWITTER_AVAILABLE" = true ] && echo '✅' || echo '❌' )"

# 生成简报提示词
read -r -d '' PROMPT << EOF
你是一个产品动态分析师，为 OpenClaw（开源AI助手，GitHub: $GITHUB_REPO）生成每日简报。

**数据源状态：** $DATA_STATUS

**原始数据：**

1. **GitHub Latest Release (基本信息):**
\`\`\`json
$GITHUB_RELEASE
\`\`\`

2. **GitHub 重要 PRs (最近5个):**
\`\`\`json
$GITHUB_PRS
\`\`\`

3. **GitHub 热门 Issues (按评论数排序，前5):**
\`\`\`json
$GITHUB_ISSUES
\`\`\`

4. **Twitter 官方推文 (@openclaw):**
\`\`\`
$TWITTER_OFFICIAL
\`\`\`

5. **Twitter 社区讨论 (提到 openclaw 的高热度推文):**
\`\`\`
$TWITTER_COMMUNITY
\`\`\`

---

**生成要求：**

**内容策略：**
1. **版本发布 + 功能更新：** 精简，只列核心亮点（3-5条）
2. **社区讨论 + 产品洞察：** 重点，从 Twitter 提取高热度内容

**输出格式（严格遵循）：**

### 🦞 OpenClaw 每日产品动态简报
**日期：** $(date +%Y年%m月%d日)

#### 📦 版本与功能速览
* **最新版本：** [版本号 + 发布日期]（如果有新 Release）
* **核心更新：** [精选 3-5 个最重要的功能/修复，每条一句话]
* 如果无重大更新：说明"近期无重大版本发布"

#### 🔥 社区热点（重点板块）
**基于 Twitter 社区讨论和 GitHub Issues：**

1. **高热度话题：**
   * 从 Twitter 社区讨论中提取：用户最关心什么？有哪些有趣的使用案例？
   * 每条包含：用户名（如果有）、核心观点、互动热度（点赞/评论数，如果数据中有）
   
2. **用户反馈焦点：**
   * 从 GitHub Issues 和 Twitter 中识别：用户遇到的主要问题、功能请求
   * 优先展示评论数多的 Issue

3. **社区亮点案例：**
   * Twitter 中分享的有趣使用场景、创意玩法
   * 展示 OpenClaw 的实际应用价值

#### 💡 产品洞察（重点板块）
**基于社区反馈和更新趋势：**
* **趋势判断：** 从社区讨论中总结产品发展方向
* **用户声音：** 社区最期待的功能或改进
* **值得关注：** 对用户有价值的信息（新功能、已知问题、最佳实践等）

---

**质量标准：**
1. **版本与功能速览：** 控制在 200 字以内，只要核心信息
2. **社区热点：** 至少包含 3-5 条高质量内容，优先 Twitter 社区讨论
3. **产品洞察：** 基于真实数据分析，避免空洞总结
4. 如果某个数据源为空，明确说明，不要编造

**重要：** 
- Twitter 数据是重点，优先展示社区真实声音
- 避免罗列大量技术细节，聚焦用户关心的内容
- 保持客观，引用具体案例和数据

现在请生成简报。
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
    "temperature": 0.6,
    "max_tokens": 4000
  }')

# 检查是否成功
if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
  echo "❌ DeepSeek API 调用失败："
  echo "$response" | jq '.error'
  rm -rf "$TEMP_DIR"
  exit 1
fi

# 提取生成的内容
brief=$(echo "$response" | jq -r '.choices[0].message.content')

# 输出简报
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$brief"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📌 数据源: $DATA_STATUS"
if [ "$GITHUB_AVAILABLE" = false ]; then
  echo "💡 提示：运行 'gh auth login' 启用 GitHub 数据"
fi
if [ "$TWITTER_AVAILABLE" = false ]; then
  echo "💡 提示：安装 'bird' 启用 Twitter 数据"
fi

# 记录使用情况
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
prompt_tokens=$(echo "$response" | jq -r '.usage.prompt_tokens')
completion_tokens=$(echo "$response" | jq -r '.usage.completion_tokens')
total_tokens=$(echo "$response" | jq -r '.usage.total_tokens')

log_file="$HOME/clawd/memory/deepseek-usage.jsonl"
echo "{\"timestamp\":\"$timestamp\",\"model\":\"deepseek-chat\",\"prompt_tokens\":$prompt_tokens,\"completion_tokens\":$completion_tokens,\"total_tokens\":$total_tokens,\"task\":\"openclaw-updates\"}" >> "$log_file"

# 清理临时文件
rm -rf "$TEMP_DIR"

exit 0
