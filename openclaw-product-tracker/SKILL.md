# 龙虾简报 - OpenClaw 产品动态追踪技能

## 概述
这是一个全面追踪 OpenClaw 产品动态的"龙虾简报"技能，整合了 GitHub、X平台（Twitter）和 Moltbook 论坛三个信息源，生成每日产品动态简报。

## 功能特性
- 📦 **GitHub 数据**: 版本发布、PRs、Issues、贡献者统计
- 🐦 **X平台 数据**: 官方推文、社区讨论、用户反馈
- 🦞 **Moltbook 数据**: 论坛动态、用户讨论、创新应用
- 🌐 **三源整合**: 综合分析各平台数据，提供全面洞察
- 📊 **生态分析**: 评估产品生态健康度和发展趋势

## 包含的脚本

### 1. integrated-openclaw-brief.sh
- **功能**: 三源数据整合，生成全面产品动态简报
- **数据源**: GitHub + X平台 + Moltbook
- **输出**: 结构化 Markdown 格式的综合简报

### 2. openclaw-updates-brief.sh
- **功能**: GitHub 和 X平台 数据整合
- **数据源**: GitHub + X平台
- **输出**: 产品更新和社区动态简报

### 3. moltbook-daily-telegram-improved.sh
- **功能**: Moltbook 社区动态分析
- **数据源**: Moltbook 论坛
- **输出**: 社区话题分析和热门内容

### 4. openclaw-brief-cron.sh
- **功能**: 自动发布简报到 Telegraph 并推送至 Telegram
- **输出**: 在线简报链接

## 依赖项
- GitHub CLI (`gh`) - 用于访问 GitHub 数据
- Bird CLI (`bird`) - 用于访问 X平台 数据
- cURL - 用于 API 请求
- jq - 用于 JSON 处理
- Python3 - 用于数据处理和发布

## 配置要求
1. GitHub 认证: `gh auth login`
2. X平台 凭据: 配置 bird CLI
3. Moltbook API 密钥: `moltbook_sk_iV5ZxnR9It9NqfVTaORFHYAEwxk1M1IW`
4. DeepSeek API 密钥: 用于 AI 分析
5. Telegraph API 令牌: 用于发布在线简报

## 使用方法

### 运行整合简报
```bash
bash /home/chengzh/clawd/skills/openclaw-product-tracker/integrated-openclaw-brief.sh
```

### 运行单源简报
```bash
# GitHub + X平台 简报
bash /home/chengzh/clawd/skills/openclaw-product-tracker/openclaw-updates-brief.sh

# Moltbook 简报
bash /home/chengzh/clawd/skills/openclaw-product-tracker/moltbook-daily-telegram-improved.sh
```

### 自动发布到 Telegraph
```bash
bash /home/chengzh/clawd/skills/openclaw-product-tracker/openclaw-brief-cron.sh
```

## 输出示例
简报包含以下板块：
- **版本与开发动态**: 最新版本信息、核心更新列表
- **GitHub 用户反馈**: 热门Issues及用户反馈综述
- **X平台 社区动态**: 官方账号、用户讨论、相关话题
- **Moltbook 论坛动态**: 社区讨论、创新应用、问题反馈
- **产品现状与发展趋势综述**: 三源信息整合分析

## 高质量简报标准操作流程

### 1. GitHub 版本与开发动态
- **最新版本**: 获取当前版本号和发布时间
- **核心更新**: 提取最重要的5-10个更新项，包括新功能、修复、优化
- **热门Issues**: 获取5个最热门的用户反馈，每条提供简要综述

### 2. Moltbook 论坛动态
- **功能讨论**: 提取社区对功能的讨论和建议
- **问题反馈**: 收集用户遇到的问题和困惑
- **创新应用**: 发现社区的创新用法和新应用场景

### 3. X平台 动态
- **官方账号**: @openclaw @steipete @moltbook 等官方信息
- **用户反馈**: 用户分享的使用体验和问题
- **话题标签**: #openclaw 等相关话题讨论

### 4. 三源综合分析
- **趋势洞察**: 从三源信息中识别共同趋势
- **用户需求**: 综合各平台用户反馈
- **生态健康度**: 评估整体生态发展状况
- **未来发展**: 基于当前趋势预测发展方向

### 5. 产品洞察与建议
- **现状评估**: 基于三源数据的整体产品状况
- **机会点**: 识别潜在的发展机会
- **风险预警**: 提醒需要注意的风险点
- **协同效应**: 三源信息之间的相互印证和补充

## 定时任务配置
可配置 cron 任务自动运行简报生成：

```bash
# 每天上午 9 点生成整合简报
0 9 * * * bash /home/chengzh/clawd/skills/openclaw-product-tracker/integrated-openclaw-brief.sh

# 每天晚上 8 点发布到 Telegraph
0 20 * * * bash /home/chengzh/clawd/skills/openclaw-product-tracker/openclaw-brief-cron.sh
```

## 注意事项
- 确保所有依赖项已正确安装和配置
- API 密钥需要有效且有足够的调用配额
- 定期检查各数据源的连接状态
- 如遇数据源不可用，简报会相应调整内容
- 严格按照高质量简报标准操作流程生成内容
- 保持中文输出格式，确保内容准确性和完整性