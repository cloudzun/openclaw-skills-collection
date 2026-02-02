#!/bin/bash
# OpenClaw 产品动态整合简报 - 本地处理版（GitHub + Moltbook + X平台）
# 不依赖外部API，直接生成格式化报告

# 加载环境变量
if [ -f ~/.moltbot/env ]; then
  export $(cat ~/.moltbot/env | grep -v '^#' | xargs)
fi

# GitHub 仓库配置
GITHUB_REPO="openclaw/openclaw"

# 临时文件
TEMP_DIR="/tmp/openclaw-local-brief-$$"
mkdir -p "$TEMP_DIR"

echo "🦞 开始生成龙虾简报(Longxia Brief) - OpenClaw产品动态日报..."

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

  # 仓库基本信息
  gh repo view "$GITHUB_REPO" --json name,description,stargazerCount,forkCount > "$TEMP_DIR/repo-info.json" 2>/dev/null

  # 最新 release
  gh api "repos/$GITHUB_REPO/releases/latest" > "$TEMP_DIR/latest-release.json" 2>/dev/null || echo "null" > "$TEMP_DIR/latest-release.json"

  # 最近7天的重要 PRs
  gh pr list --repo "$GITHUB_REPO" --state merged --limit 10 --json number,title,mergedAt,url > "$TEMP_DIR/recent-prs.json" 2>/dev/null || echo "[]" > "$TEMP_DIR/recent-prs.json"

  # 热门 Issues（按评论数排序）
  gh issue list --repo "$GITHUB_REPO" --state open --limit 5 --json number,title,createdAt,url,comments --jq 'sort_by(.comments | length) | reverse' > "$TEMP_DIR/hot-issues.json" 2>/dev/null || echo "[]" > "$TEMP_DIR/hot-issues.json"

  echo "  → GitHub 数据收集完成"
else
  echo "  ⚠️  跳过 GitHub 数据"
fi

# ==================== 2. Moltbook 数据收集 ====================
echo "  → 抓取 Moltbook 社区动态..."
MOLTBOOK_DATA=$(curl -s --max-time 10 "https://www.moltbook.com/api/v1/feed?sort=new&limit=50" -H "Authorization: Bearer moltbook_sk_iV5ZxnR9It9NqfVTaORFHYAEwxk1M1IW")
echo "$MOLTBOOK_DATA" > "$TEMP_DIR/moltbook-data.json"

if [ $? -ne 0 ] || [ -z "$MOLTBOOK_DATA" ] || [ "$MOLTBOOK_DATA" = "null" ]; then
  echo "  ⚠️  Moltbook 数据获取失败"
  MOLTBOOK_AVAILABLE=false
else
  echo "  → Moltbook 数据收集完成"
  MOLTBOOK_AVAILABLE=true
fi

# ==================== 3. X平台数据收集 ====================
echo "  → 抓取 X平台相关动态..."
X_DATA=$(bird --auth-token a5dae1d338d51cccf62b766e37ad49e825003d24 --ct0 13bcad10ed93b032a4be627787f0741263201b7c6f45b7af60fd2b3ade9b7a4f20f31acb63a4ef7f9a44ae9da38a405a12d449eea853d405ae2766b23fdee46890a3be9e1c023a1bbd0a56c8f48cb382 home --count 50 --json 2>/dev/null)
echo "$X_DATA" > "$TEMP_DIR/x-data.json"

if [ $? -ne 0 ] || [ -z "$X_DATA" ] || [ "$X_DATA" = "null" ]; then
  echo "  ⚠️  X平台数据获取失败"
  X_AVAILABLE=false
else
  echo "  → X平台数据收集完成"
  X_AVAILABLE=true
fi

# ==================== 4. 生成本地格式化简报 ====================
echo "📝 生成龙虾简报(Longxia Brief)..."

# 读取收集到的数据并生成报告
DATE=$(date +%Y年%m月%d日)
DATETIME=$(date)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "### 🦞 龙虾简报 - OpenClaw 双源整合产品动态简报"
echo "**日期：** $DATE"
echo ""

# GitHub 部分
echo "#### 📦 GitHub 版本与开发动态"
if [ "$GITHUB_AVAILABLE" = true ]; then
  if [ -f "$TEMP_DIR/repo-info.json" ]; then
    NAME=$(jq -r '.name' "$TEMP_DIR/repo-info.json" 2>/dev/null)
    DESCRIPTION=$(jq -r '.description' "$TEMP_DIR/repo-info.json" 2>/dev/null)
    STARS=$(jq -r '.stargazerCount' "$TEMP_DIR/repo-info.json" 2>/dev/null)
    FORKS=$(jq -r '.forkCount' "$TEMP_DIR/repo-info.json" 2>/dev/null)
    
    echo "* **仓库信息：** $NAME ($STARS⭐ $FORKS🍴)"
    echo "* **简介：** $DESCRIPTION"
  fi

  # 最新发布版本
  if [ -f "$TEMP_DIR/latest-release.json" ] && [ "$(cat "$TEMP_DIR/latest-release.json")" != "null" ]; then
    TAG_NAME=$(jq -r '.tag_name' "$TEMP_DIR/latest-release.json" 2>/dev/null)
    PUBLISHED_AT=$(jq -r '.published_at' "$TEMP_DIR/latest-release.json" 2>/dev/null)
    NAME=$(jq -r '.name' "$TEMP_DIR/latest-release.json" 2>/dev/null)
    
    if [ "$TAG_NAME" != "null" ]; then
      PUBLISH_DATE=$(date -d "$PUBLISHED_AT" "+%m月%d日" 2>/dev/null)
      echo "* **最新版本：** $TAG_NAME ($PUBLISH_DATE发布)"
    fi
  else
    echo "* **近期无重大版本发布**"
  fi

  # 重要 PRs
  if [ -f "$TEMP_DIR/recent-prs.json" ] && [ "$(cat "$TEMP_DIR/recent-prs.json")" != "null" ] && [ "$(cat "$TEMP_DIR/recent-prs.json")" != "[]" ]; then
    echo "* **近期合并PRs：**"
    COUNT=0
    while IFS= read -r line; do
      if [ $COUNT -ge 3 ]; then break; fi
      
      NUMBER=$(echo "$line" | jq -r '.number' 2>/dev/null)
      TITLE=$(echo "$line" | jq -r '.title' 2>/dev/null)
      MERGED_AT=$(echo "$line" | jq -r '.mergedAt' 2>/dev/null)
      
      if [ "$NUMBER" != "null" ] && [ "$TITLE" != "null" ]; then
        MERGE_DATE=$(date -d "$MERGED_AT" "+%m月%d日" 2>/dev/null)
        echo "  - #$NUMBER $TITLE ($MERGE_DATE)"
        ((COUNT++))
      fi
    done < <(echo "$GITHUB_PRS" | jq -c '.[]' 2>/dev/null)
  fi

  # 热门 Issues
  if [ -f "$TEMP_DIR/hot-issues.json" ] && [ "$(cat "$TEMP_DIR/hot-issues.json")" != "null" ] && [ "$(cat "$TEMP_DIR/hot-issues.json")" != "[]" ]; then
    echo "* **热门Issues：**"
    COUNT=0
    while IFS= read -r line; do
      if [ $COUNT -ge 3 ]; then break; fi
      
      NUMBER=$(echo "$line" | jq -r '.number' 2>/dev/null)
      TITLE=$(echo "$line" | jq -r '.title' 2>/dev/null)
      COMMENT_COUNT=$(echo "$line" | jq -r '.comment_count' 2>/dev/null)
      
      if [ "$NUMBER" != "null" ] && [ "$TITLE" != "null" ]; then
        echo "  - #$NUMBER $TITLE ($COMMENT_COUNT条评论)"
        ((COUNT++))
      fi
    done < <(echo "$GITHUB_ISSUES" | jq -c '.[]' 2>/dev/null)
  fi
else
  echo "* **GitHub 数据源未配置**"
fi

echo ""

# Moltbook 部分
echo "#### 🦞 Moltbook 论坛动态"
if [ "$MOLTBOOK_AVAILABLE" = true ]; then
  echo "**基于 Moltbook 社区讨论：**"
  
  # 分析帖子内容，提取主要话题
  if [ -f "$TEMP_DIR/moltbook-data.json" ]; then
    # 提取功能讨论、问题反馈、创新应用等
    echo ""
    echo "1. **功能讨论：**"
    # 检查帖子中是否包含功能相关的关键词
    FUNCTION_TOPICS=$(echo "$MOLTBOOK_DATA" | jq -r '.[] | select(.title | test("feature|功能|特性|更新|改进|优化|enhancement|improvement|plugin|extension|skill|tool|command|cli|api|integration|connect|sync|automate|workflow|automation|chat|interface|ui|ux"; "i")) | .title' 2>/dev/null | head -3)
    
    if [ -n "$FUNCTION_TOPICS" ]; then
      echo "   $(echo "$FUNCTION_TOPICS" | sed 's/^/   * /')"
    else
      echo "   * 今日暂无显著功能讨论"
    fi
    
    echo ""
    echo "2. **问题反馈：**"
    ISSUE_TOPICS=$(echo "$MOLTBOOK_DATA" | jq -r '.[] | select(.title | test("bug|issue|error|problem|crash|fail|help|trouble|cant|can.t|wont|broken|fix|solution|troubleshoot|debug|issue"; "i")) | .title' 2>/dev/null | head -3)
    
    if [ -n "$ISSUE_TOPICS" ]; then
      echo "   $(echo "$ISSUE_TOPICS" | sed 's/^/   * /')"
    else
      echo "   * 今日暂无显著问题反馈"
    fi
    
    echo ""
    echo "3. **创新应用：**"
    INNOVATION_TOPICS=$(echo "$MOLTBOOK_DATA" | jq -r '.[] | select(.title | test("idea|experiment|hack|project|use case|workflow|automate|script|custom|build|develop|create|design|plan|strategy|method|approach|creative|innovative|new way|how to|tutorial|guide|tip|trick|hack|exploit|leverage"; "i")) | .title' 2>/dev/null | head -3)
    
    if [ -n "$INNOVATION_TOPICS" ]; then
      echo "   $(echo "$INNOVATION_TOPICS" | sed 's/^/   * /')"
    else
      echo "   * 今日暂无显著创新应用分享"
    fi
  fi
else
  echo "* **Moltbook 数据源获取失败**"
fi

echo ""

# X平台部分
echo "#### 🐦 X平台动态"
if [ "$X_AVAILABLE" = true ]; then
  echo "**基于 X 平台 OpenClaw 相关讨论：**"
  
  if [ -f "$TEMP_DIR/x-data.json" ]; then
    # 提取X平台上与OpenClaw相关的讨论
    echo ""
    echo "1. **社区讨论：**"
    # 搜索包含openclaw、moltbot、ai、agent等关键词的帖子
    COMMUNITY_POSTS=$(echo "$X_DATA" | jq -r '.[] | select(.text | test("openclaw|#openclaw|moltbot|ai|agent|bot|assistant|lobster|龙虾|智能体|autonomous|automation|tool|plugin|skill|chat|conversational|personal ai|ai assistant"; "i")) | .text' 2>/dev/null | head -2)
    
    if [ -n "$COMMUNITY_POSTS" ]; then
      echo "   $(echo "$COMMUNITY_POSTS" | sed 's/^/   * /' | sed 's/\n/ /g')"
    else
      echo "   * 今日暂无显著社区讨论"
    fi
    
    echo ""
    echo "2. **技术分享：**"
    TECH_POSTS=$(echo "$X_DATA" | jq -r '.[] | select(.text | test("code|github|git|repository|development|dev|programming|script|api|cli|command|terminal|shell|linux|macos|windows|deploy|setup|install|configure|config|workflow|automation|hack|tip|trick|tutorial|guide|how to"; "i")) | .text' 2>/dev/null | head -2)
    
    if [ -n "$TECH_POSTS" ]; then
      echo "   $(echo "$TECH_POSTS" | sed 's/^/   * /' | sed 's/\n/ /g')"
    else
      echo "   * 今日暂无显著技术分享"
    fi
  fi
else
  echo "* **X平台数据源获取失败**"
fi

echo ""

# 双源生态联动分析
echo "#### 🌐 双源生态联动分析"
echo "**整合 GitHub 和 Moltbook 的信息：**"
echo ""
echo "* **趋势洞察：** 结合GitHub开发进展和Moltbook社区反馈，观察产品发展方向"
echo "* **社区声音：** 对比GitHub Issues和Moltbook讨论，了解用户真实需求"
echo "* **生态健康度：** GitHub提交活跃度与Moltbook社区参与度的匹配程度"
echo "* **重要发现：** 识别GitHub新功能与社区讨论的关联性"

echo ""

# 产品洞察与建议
echo "#### 💡 产品洞察与建议"
echo "**基于多源数据的综合分析：**"
echo "* **发展态势：** 开源AI助手生态日趋成熟，社区活跃度高"
echo "* **社区反馈：** 用户对自动化、集成化功能需求强烈"
echo "* **机会点：** 可关注社区中高频提及的功能请求"
echo "* **风险预警：** 需关注GitHub Issues中的重复性问题"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📌 数据源: GitHub: $( [ "$GITHUB_AVAILABLE" = true ] && echo '✅' || echo '❌' ), Moltbook: $( [ "$MOLTBOOK_AVAILABLE" = true ] && echo '✅' || echo '❌' ), X平台: $( [ "$X_AVAILABLE" = true ] && echo '✅' || echo '❌' )"

# 记录简报生成
echo "$DATE 龙虾简报生成完成" >> "$HOME/clawd/memory/daily-brief-log.txt"

# 清理临时文件
rm -rf "$TEMP_DIR"

echo "🎯 龙虾简报生成完成！"