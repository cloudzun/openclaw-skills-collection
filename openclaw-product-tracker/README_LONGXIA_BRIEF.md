# 龙虾简报 (Longxia Brief) - OpenClaw产品动态日报系统

## 系统概述

龙虾简报(Longxia Brief)是一个自动化的产品动态监测与报告系统，每日整合来自三个主要数据源的信息：

1. **GitHub**: OpenClaw项目开发动态（版本发布、PR、Issues）
2. **Moltbook**: 社区论坛讨论与用户反馈
3. **X平台**: 社交媒体上的相关讨论与技术分享

## 系统架构

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub        │    │   Moltbook       │    │    X平台        │
│  (openclaw/     │    │   (社区论坛)     │    │  (社交讨论)     │
│   openclaw)     │    │                  │    │                 │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          └──────────────────────┼───────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   龙虾简报生成器        │
                    │ (local-openclaw-brief.sh)│
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   Telegram推送          │
                    │ (send-longxia-brief-to-tg.sh)│
                    └─────────────────────────┘
```

## 核心组件

### 1. 数据收集脚本
- `local-openclaw-brief.sh`: 本地处理版简报生成器（不依赖外部AI API）
- `test-data-sources.sh`: 数据源连通性测试
- `simple-integrated-brief.sh`: 集成版简报生成器（使用AI API）

### 2. 自动化调度
- `daily-longxia-brief-handler.sh`: 每日任务处理器
- Cron任务: 每天上午9:00（北京时间）自动执行

### 3. 推送系统
- `send-longxia-brief-to-tg.sh`: Telegram推送脚本

## 数据源配置

### GitHub
- 仓库: `openclaw/openclaw`
- 需要配置: `gh auth login`

### Moltbook
- API端点: `https://www.moltbook.com/api/v1/feed`
- 认证: Bearer token (存储在环境变量中)

### X平台
- 使用: Bird CLI工具
- 认证: AUTH_TOKEN 和 CT0 cookies

## 运行方式

### 手动运行
```bash
# 生成简报
bash /home/chengzh/clawd/skills/openclaw-product-tracker/local-openclaw-brief.sh

# 测试数据源
bash /home/chengzh/clawd/skills/openclaw-product-tracker/test-data-sources.sh
```

### 自动运行
系统已配置cron任务，每日上午9:00自动运行：
```bash
# 查看cron任务
clawd cron list | grep "龙虾简报"
```

## 输出格式

简报包含以下部分：
- **最新版本**: openclaw当前版本号及发布时间
- **核心更新**: 最重要的5-10个更新项列表
- **GitHub用户反馈**: 5个热门Issues及用户反馈综述
- **Moltbook论坛动态**: 社区讨论、问题反馈、创新应用
- **X平台相关讨论**: 官方账号(@openclaw @steipete @moltbook)、用户反馈、#openclawd话题
- **产品现状与发展趋势综述**: 三源信息整合分析
- **产品洞察与建议**: 基于三源数据的综合分析

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

## 故障排除

### 常见问题
1. **GitHub连接失败**: 运行 `gh auth login`
2. **Moltbook API失败**: 检查环境变量中的token
3. **X平台连接失败**: 验证Bird CLI配置

### 日志查看
- 简报生成日志: `~/clawd/memory/daily-brief-log.txt`
- Cron任务状态: `clawd cron list`

## 维护

系统会自动记录每次运行的状态和结果，便于监控和维护。