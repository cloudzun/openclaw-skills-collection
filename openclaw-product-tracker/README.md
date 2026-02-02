# 龙虾简报 - OpenClaw 产品动态追踪技能

这是一个全面追踪 OpenClaw 产品生态的自动化工具集，通过整合 GitHub、X平台 和 Moltbook 三个核心信息源，为用户提供每日"龙虾简报"。

## 🎯 项目目标

创建一个全方位的 OpenClaw 产品监控系统，通过自动化数据收集和 AI 分析，帮助用户及时了解：

- **开发进展**: GitHub 上的版本发布、PRs、Issues
- **社区动态**: X平台 上的官方公告和社区讨论  
- **用户反馈**: Moltbook 论坛上的真实用户声音

## 📊 信息源

### 1. GitHub 数据源
- 最新版本发布
- 重要功能合并请求 (PRs)
- 热门问题讨论 (Issues)
- 项目贡献者统计

### 2. X平台 (Twitter) 数据源
- 官方账号动态
- 社区用户讨论
- 产品使用反馈
- 行业专家观点

### 3. Moltbook 论坛数据源
- 用户使用心得
- 功能需求讨论
- 问题解决分享
- 创新应用场景

## 🛠️ 核心组件

### `integrated-openclaw-brief.sh`
- **功能**: 三源数据整合分析
- **输出**: 全面的每日产品动态简报
- **特色**: 跨平台生态联动分析

### `openclaw-updates-brief.sh`
- **功能**: GitHub + X平台 数据分析
- **输出**: 产品更新和社区动态

### `moltbook-daily-telegram-improved.sh`
- **功能**: Moltbook 社区分析
- **输出**: 论坛话题和用户反馈

### `openclaw-brief-cron.sh`
- **功能**: 自动发布和推送
- **输出**: Telegraph 在线简报 + Telegram 推送

## 🚀 快速开始

### 1. 安装依赖
```bash
# 确保已安装所需工具
sudo apt install curl jq python3

# 安装 GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update
sudo apt install gh

# 配置 GitHub 认证
gh auth login
```

### 2. 配置 X平台 访问
```bash
# 安装并配置 bird CLI
# (具体安装方法取决于你的 bird CLI 实现)
```

### 3. 运行简报生成
```bash
# 生成整合简报
bash integrated-openclaw-brief.sh

# 生成单源简报
bash openclaw-updates-brief.sh
bash moltbook-daily-telegram-improved.sh

# 自动发布
bash openclaw-brief-cron.sh
```

### 4. API密钥配置说明

本项目中的API密钥已替换为占位符以保护安全，实际部署时需要配置真实密钥：

- **DeepSeek API**: 在环境变量中设置 `DEEPSEEK_API_KEY` 为真实密钥
- **X平台认证**: 在环境变量中设置 `X_AUTH_TOKEN` 和 `X_CT0_TOKEN` 为真实认证凭据
- **Moltbook API**: 在环境变量中设置 `MOLTBOOK_API_TOKEN` 为真实API token
- **Telegra.ph API**: 在环境变量中设置 `TELEGRAPH_ACCESS_TOKEN` 为真实访问令牌

可以通过以下方式设置环境变量：
```bash
export DEEPSEEK_API_KEY="your_actual_api_key_here"
export X_AUTH_TOKEN="your_actual_auth_token_here"
export X_CT0_TOKEN="your_actual_ct0_token_here"
export MOLTBOOK_API_TOKEN="your_actual_moltbook_token_here"
export TELEGRAPH_ACCESS_TOKEN="your_actual_telegraph_token_here"
```

或者将这些变量存储在安全的配置文件中，确保该文件不在版本控制范围内。

## 📋 输出格式

每个简报都包含以下结构：

```
### 🦞 OpenClaw 三源整合产品动态简报
**日期**: YYYY年MM月DD日

#### 📦 GitHub 版本与开发动态
[版本信息、PRs、Issues等]

#### 🐦 X平台 社区动态
[官方动态、社区讨论等]

#### 🦞 Moltbook 论坛动态
[功能讨论、问题反馈、创新应用等]

#### 🌐 三源生态联动分析
[跨平台趋势洞察]

#### 💡 产品洞察与建议
[综合分析和建议]
```

## ⚙️ 配置文件

- `config.json`: 项目配置参数
- `credentials.env`: 敏感凭证信息（请勿提交到版本控制）

## 📅 自动化部署

可配置定时任务实现自动化：

```bash
# 编辑 crontab
crontab -e

# 添加定时任务
0 9 * * * cd /path/to/openclaw-product-tracker && bash integrated-openclaw-brief.sh
0 20 * * * cd /path/to/openclaw-product-tracker && bash openclaw-brief-cron.sh
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## 📄 许可证

[根据需要填写许可证信息]