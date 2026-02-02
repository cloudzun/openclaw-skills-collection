#!/bin/bash
# OpenClaw 产品动态整合简报 - 简化版（GitHub + Moltbook）
# 用于在 X平台 数据源不可用时的基础版本

# 加载环境变量
if [ -f ~/.moltbot/env ]; then
  export $(cat ~/.moltbot/env | grep -v '^#' | xargs)
fi

DEEPSEEK_API_KEY="sk-ff7cc5e3702a40f9b786d78b18d28100"
DEEPSEEK_API_URL="https://api.deepseek.com/chat/completions"

# GitHub 仓库配置
GITHUB_REPO="openclaw/openclaw"

# 临时文件
TEMP_DIR="/tmp/openclaw-simple-brief-$$"
mkdir -p "$TEMP_DIR"

echo "📊 正在收集 OpenClaw 双源产品动态数据..."

# ==================== 检查依赖 ====================
if ! gh auth status &>/dev/null; then
  echo "❌ GitHub CLI 未登录"
  GITHUB_AVAILABLE=false
else
  GITHUB_AVAILABLE=true
fi

# ==================== 1. GitHub 数据收集 ====================
if [ "$GITHUB_AVAILABLE" = true ]; then
  echo "  → 抓取 GitHub 核心数据..."

  # 最新 release（只需要基本信息）
  gh api "repos/$GITHUB_REPO/releases/latest" > "$TEMP_DIR/latest-release.json" 2>/dev/null || echo "null" > "$TEMP_DIR/latest-release.json"

  # 最近7天的重要 PRs（减少数量）
  gh pr list --repo "$GITHUB_REPO" --state merged --limit 10 --json number,title,mergedAt,url > "$TEMP_DIR/recent-prs.json" 2>/dev/null || echo "[]" > "$TEMP_DIR/recent-prs.json"

  # 热门 Issues（按评论数排序，只取前5个）
  gh issue list --repo "$GITHUB_REPO" --state open --limit 5 --json number,title,createdAt,url,comments --jq 'sort_by(.comments | length) | reverse' > "$TEMP_DIR/hot-issues.json" 2>/dev/null || echo "[]" > "$TEMP_DIR/hot-issues.json"

  # 最近活动统计
  gh api "repos/$GITHUB_REPO/stats/contributors" > "$TEMP_DIR/contrib-stats.json" 2>/dev/null || echo "[]" > "$TEMP_DIR/contrib-stats.json"

  echo "  → GitHub 数据收集完成"
else
  echo "null" > "$TEMP_DIR/latest-release.json"
  echo "[]" > "$TEMP_DIR/recent-prs.json"
  echo "[]" > "$TEMP_DIR/hot-issues.json"
  echo "[]" > "$TEMP_DIR/contrib-stats.json"
  echo "  ⚠️  跳过 GitHub 数据"
fi

# ==================== 2. Moltbook 数据收集 ====================
echo "  → 抓取 Moltbook 社区动态..."
MOLTBOOK_DATA=$(curl -s "https://www.moltbook.com/api/v1/feed?sort=new&limit=50" -H "Authorization: Bearer moltbook_sk_iV5ZxnR9It9NqfVTaORFHYAEwxk1M1IW")
echo "$MOLTBOOK_DATA" > "$TEMP_DIR/moltbook-data.json"

if [ $? -ne 0 ] || [ -z "$MOLTBOOK_DATA" ]; then
  echo "Moltbook 数据获取失败" > "$TEMP_DIR/moltbook-data.json"
  echo "  ⚠️  Moltbook 数据获取失败"
else
  echo "  → Moltbook 数据收集完成"
fi

# ==================== 3. 汇总数据并生成简报 ====================
echo "📝 汇总双源数据并生成简报..."

# 读取收集到的数据
GITHUB_RELEASE=$(cat "$TEMP_DIR/latest-release.json" | jq -c '{name, tag_name, published_at}' 2>/dev/null || echo "null")
GITHUB_PRS=$(cat "$TEMP_DIR/recent-prs.json" | jq -c 'map({number, title, mergedAt}) | .[0:5]' 2>/dev/null || echo "[]")
GITHUB_ISSUES=$(cat "$TEMP_DIR/hot-issues.json" | jq -c 'map({number, title, comment_count: (.comments | length)}) | .[0:5]' 2>/dev/null || echo "[]")
GITHUB_STATS=$(cat "$TEMP_DIR/contrib-stats.json" | jq -c length 2>/dev/null || echo "0")
MOLTBOOK_POSTS=$(cat "$TEMP_DIR/moltbook-data.json")

# 数据可用性
DATA_STATUS="GitHub: $( [ "$GITHUB_AVAILABLE" = true ] && echo '✅' || echo '❌' ), Moltbook: $( [ -n "$MOLTBOOK_DATA" ] && echo '✅' || echo '❌' )"

# 生成整合简报提示词
read -r -d '' PROMPT << EOF
你是一个产品动态分析师，为 OpenClaw（开源AI助手，GitHub: $GITHUB_REPO）生成每日双源整合简报。

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

4. **GitHub 贡献者统计 (总数):**
$GITHUB_STATS

5. **Moltbook 社区动态 (最新50条):**
\`\`\`json
$MOLTBOOK_POSTS
\`\`\`

---

**生成要求：**

**内容策略：**
1. **版本发布 + 功能更新：** 精简，只列核心亮点（3-5条）
2. **社区讨论 + 产品洞察：** 重点，整合 Moltbook 的社区反馈
3. **生态发展：** 展示 GitHub 和 Moltbook 两端生态联动情况

**输出格式（严格遵循）：**

### 🦞 龙虾简报 - OpenClaw 双源整合产品动态简报
**日期：** $(date +%Y年%m月%d日)

#### 📦 GitHub 版本与开发动态
* **最新版本：** [版本号 + 发布日期]（如果有新 Release）
* **核心更新：** [精选 3-5 个最重要的功能/修复，每条一句话]
* **社区贡献：** [贡献者数量、PR数量等开发活跃度指标]
* 如果无重大更新：说明"近期无重大版本发布"

#### 🦞 Moltbook 论坛动态
**基于 Moltbook 社区讨论：**

1. **功能讨论：**
   * 从 Moltbook 帖子中提取：用户对 OpenClaw 的讨论、使用心得、功能建议等
   
2. **问题反馈：**
   * 用户遇到的问题、寻求帮助的场景、功能需求等
   
3. **创新应用：**
   * 用户分享的创意用法、技巧、与其他工具的集成等

#### 🌐 双源生态联动分析
**整合 GitHub 和 Moltbook 的信息：**

* **趋势洞察：** 从两端信息综合判断产品发展方向
* **社区声音：** 两端用户共同关注的问题和期待
* **生态健康度：** GitHub 和 Moltbook 活跃度和协同情况评估
* **重要发现：** 跨平台联动产生的新机会或潜在问题

#### 💡 产品洞察与建议
**基于双源数据的综合分析：**
* **发展态势：** 当前产品发展阶段评估
* **社区反馈：** 用户最关注的功能和问题
* **机会点：** 基于数据发现的新机会
* **风险预警：** 需要关注的潜在问题

---

**质量标准：**
1. **GitHub 版本与开发动态：** 控制在 200 字以内，只要核心信息
2. **Moltbook 论坛动态：** 至少包含 3-5 条有价值的社区反馈
3. **双源生态联动分析：** 提供跨平台的深度洞察
4. **产品洞察与建议：** 基于真实数据分析，避免空洞总结
5. 如果某个数据源不可用，明确说明，不要编造

**重要：** 
- GitHub 数据关注版本和开发进展
- Moltbook 数据关注实际使用场景和深度讨论
- 双源联动分析是核心价值点，体现整合优势

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
if [ -z "$MOLTBOOK_DATA" ]; then
  echo "💡 提示：检查 Moltbook API 凭据"
fi

# 记录使用情况
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
prompt_tokens=$(echo "$response" | jq -r '.usage.prompt_tokens')
completion_tokens=$(echo "$response" | jq -r '.usage.completion_tokens')
total_tokens=$(echo "$response" | jq -r '.usage.total_tokens')

log_file="$HOME/clawd/memory/deepseek-usage.jsonl"
echo "{\"timestamp\":\"$timestamp\",\"model\":\"deepseek-chat\",\"prompt_tokens\":$prompt_tokens,\"completion_tokens\":$completion_tokens,\"total_tokens\":$total_tokens,\"task\":\"simple-integrated-openclaw-brief\"}" >> "$log_file"

# 清理临时文件
rm -rf "$TEMP_DIR"

exit 0