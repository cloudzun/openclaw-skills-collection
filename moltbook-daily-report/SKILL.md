# Moltbook Daily Report Skill

## Description
Automated daily analysis and reporting system for Moltbook AI agent community. Fetches real-time data from Moltbook API, analyzes trending topics, and generates comprehensive daily reports with visual heatmaps and insights. Reports are published to Telegra.ph and summarized for Telegram distribution.

## Features
- Fetches latest data from Moltbook API (top 50 posts)
- Analyzes 10 trending topics with vote-weighted scoring
- Generates visual heatmaps (████░░░░ format) for topic popularity
- Provides comprehensive analysis including:
  - Core problems and challenges
  - Practical solutions
  - Deep insights
  - Trend analysis
  - Recommended reading with links
- Publishes full report to Telegra.ph
- Distributes simplified summary to Telegram
- Runs automatically at 8 PM daily (China time)

## Requirements
- Moltbook API token: `moltbook_sk_iV5ZxnR9It9NqfVTaORFHYAEwxk1M1IW`
- Telegra.ph API token: `39ad0d13569ba0a23fe0722154fa2d32523f92db2821ca4706d2f1f551e2`
- Telegram chat ID: `975144416`

## Configuration
The system is configured with a cron job running daily at 8 PM China time:
- Cron expression: `0 20 * * * Asia/Shanghai`
- Job ID: `f052d4f0-68b3-44c0-bfe3-d0c875515fd4`
- Script location: `/home/chengzh/clawd/scripts/moltbook-daily-telegram-improved.sh`

## Usage
The skill operates automatically through the cron scheduler. Manual execution is possible by running:
```bash
bash /home/chengzh/clawd/scripts/moltbook-daily-telegram-improved.sh
```

## Topic Classification
The system categorizes posts into 10 primary topics:
1. Token经济探索 - Economic/token-related discussions
2. AI人机协作 - Human-AI collaboration
3. 代理身份定位 - Agent identity and positioning
4. 工程实践 - Engineering practices
5. 安全审计 - Security auditing
6. 工具生态 - Tool ecosystem
7. 哲学思辨 - Philosophical discourse
8. 记忆管理 - Memory management
9. 社区治理 - Community governance
10. 神秘体验 - Mystical experiences

## Output Format
Reports follow the clawdchat-analysis format with:
- Data overview section
- Heatmap visualization of trending topics
- Core problems identification
- Solution highlights
- Deep insights analysis
- Trend analysis
- Recommended reading with direct links to original posts
- Publication timestamp and data source attribution

## Integration Points
- Moltbook API integration for real-time data
- Telegra.ph API for full report publishing
- Telegram API for summary distribution
- Cron scheduler for automated execution