#!/bin/bash
# OpenClaw 产品动态整合简报 - 极简版（仅测试数据收集功能）
# 用于验证数据源是否正常工作

# 加载环境变量
if [ -f ~/.moltbot/env ]; then
  export $(cat ~/.moltbot/env | grep -v '^#' | xargs)
fi

# GitHub 仓库配置
GITHUB_REPO="openclaw/openclaw"

# 临时文件
TEMP_DIR="/tmp/openclaw-test-brief-$$"
mkdir -p "$TEMP_DIR"

echo "🧪 开始测试 OpenClaw 数据收集功能..."

# ==================== 检查依赖 ====================
if ! gh auth status &>/dev/null; then
  echo "❌ GitHub CLI 未登录"
  GITHUB_AVAILABLE=false
else
  GITHUB_AVAILABLE=true
fi

# ==================== 1. GitHub 数据收集测试 ====================
if [ "$GITHUB_AVAILABLE" = true ]; then
  echo "  → 测试 GitHub 数据收集..."
  
  # 简单测试 GitHub 连接
  gh repo view "$GITHUB_REPO" --json name,description,stargazerCount,forkCount > "$TEMP_DIR/repo-info.json" 2>/dev/null
  
  if [ $? -eq 0 ]; then
    echo "  ✅ GitHub 连接正常"
    NAME=$(jq -r '.name' "$TEMP_DIR/repo-info.json" 2>/dev/null)
    STARS=$(jq -r '.stargazerCount' "$TEMP_DIR/repo-info.json" 2>/dev/null)
    echo "     仓库: $NAME, Stars: $STARS"
  else
    echo "  ❌ GitHub 连接失败"
  fi
else
  echo "  ❌ GitHub 未配置"
fi

# ==================== 2. Moltbook 数据收集测试 ====================
echo "  → 测试 Moltbook 数据收集..."
MOLTBOOK_DATA=$(curl -s --max-time 10 "https://www.moltbook.com/api/v1/feed?sort=new&limit=5" -H "Authorization: Bearer moltbook_sk_iV5ZxnR9It9NqfVTaORFHYAEwxk1M1IW")

if [ $? -eq 0 ] && [ -n "$MOLTBOOK_DATA" ] && [ "$MOLTBOOK_DATA" != "null" ]; then
  echo "  ✅ Moltbook 连接正常"
  COUNT=$(echo "$MOLTBOOK_DATA" | jq 'length' 2>/dev/null)
  if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    echo "     获取到 $COUNT 条帖子"
  fi
else
  echo "  ❌ Moltbook 连接失败"
fi

# ==================== 3. X平台数据收集测试 ====================
echo "  → 测试 X平台数据收集..."
X_DATA=$(bird --auth-token a5dae1d338d51cccf62b766e37ad49e825003d24 --ct0 13bcad10ed93b032a4be627787f0741263201b7c6f45b7af60fd2b3ade9b7a4f20f31acb63a4ef7f9a44ae9da38a405a12d449eea853d405ae2766b23fdee46890a3be9e1c023a1bbd0a56c8f48cb382 home --count 5 --json 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$X_DATA" ] && [ "$X_DATA" != "null" ]; then
  echo "  ✅ X平台连接正常"
  COUNT=$(echo "$X_DATA" | jq 'length' 2>/dev/null)
  if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    echo "     获取到 $COUNT 条推文"
  fi
else
  echo "  ❌ X平台连接失败"
fi

# ==================== 4. 生成测试报告 ====================
echo ""
echo "📋 数据源测试结果:"
echo "  GitHub: $( [ "$GITHUB_AVAILABLE" = true ] && echo '✅' || echo '❌' )"
echo "  Moltbook: $( [ -n "$MOLTBOOK_DATA" ] && [ "$MOLTBOOK_DATA" != "null" ] && echo '✅' || echo '❌' )"
echo "  X平台: $( [ -n "$X_DATA" ] && [ "$X_DATA" != "null" ] && echo '✅' || echo '❌' )"

echo ""
echo "🎯 测试完成!"

# 清理临时文件
rm -rf "$TEMP_DIR"