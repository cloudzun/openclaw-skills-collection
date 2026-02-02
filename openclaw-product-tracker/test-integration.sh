#!/bin/bash
# OpenClaw 产品动态整合简报 - 测试版

echo "🧪 OpenClaw 产品动态整合简报 - 测试版"
echo "📅 $(date '+%Y年%m月%d日 %H:%M:%S')"
echo ""

echo "📊 检测依赖..."
echo "  ✓ GitHub CLI: $(which gh 2>/dev/null && echo '已安装' || echo '未安装')"
echo "  ✓ Bird CLI: $(which bird 2>/dev/null && echo '已安装' || echo '未安装')"
echo "  ✓ GitHub 认证: $(gh auth status >/dev/null 2>&1 && echo '已登录' || echo '未登录')"
echo ""

echo "🔍 测试数据源连接..."
echo ""

echo "📦 测试 GitHub 数据源..."
if gh auth status >/dev/null 2>&1; then
  echo "  ✓ GitHub 连接正常"
  # 获取最近的 PR 数量（快速测试）
  PR_COUNT=$(gh pr list --repo openclaw/openclaw --state merged --limit 1 --json number 2>/dev/null | jq -r 'length' 2>/dev/null || echo "错误")
  echo "  最近 PR 测试: $PR_COUNT"
else
  echo "  ⚠ GitHub 未认证，跳过测试"
fi
echo ""

echo "🐦 测试 X平台 数据源..."
if command -v bird >/dev/null 2>&1; then
  echo "  ✓ Bird CLI 已安装"
  # 尝试简单的 bird 命令测试
  if bird --help 2>&1 | head -1 | grep -q "Usage"; then
    echo "  ✓ Bird CLI 可用"
  else
    echo "  ⚠ Bird CLI 不可用"
  fi
else
  echo "  ⚠ Bird CLI 未安装"
fi
echo ""

echo "🦞 测试 Moltbook 数据源..."
MOLTBOOK_TEST=$(curl -s "https://www.moltbook.com/api/v1/feed?sort=new&limit=1" -H "Authorization: Bearer moltbook_sk_iV5ZxnR9It9NqfVTaORFHYAEwxk1M1IW" 2>/dev/null | jq -r '.success' 2>/dev/null)
if [ "$MOLTBOOK_TEST" = "true" ]; then
  echo "  ✓ Moltbook API 连接正常"
else
  echo "  ⚠ Moltbook API 连接异常"
fi
echo ""

echo "✅ 依赖检查完成！"
echo ""
echo "💡 要运行完整版整合简报，请执行："
echo "   bash integrated-openclaw-brief.sh"
echo ""
echo "📝 技能文件结构："
echo "   ├── SKILL.md          # 技能说明文档"
echo "   ├── README.md         # 项目说明"
echo "   ├── config.json       # 配置文件"
echo "   ├── integrated-openclaw-brief.sh    # 三源整合简报"
echo "   ├── openclaw-updates-brief.sh       # GitHub+X平台简报"
echo "   ├── moltbook-daily-telegram-improved.sh  # Moltbook简报"
echo "   └── openclaw-brief-cron.sh          # 自动发布脚本"