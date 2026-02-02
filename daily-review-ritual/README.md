# Daily Review Ritual 技能

这是一个用于每日回顾和规划的技能，帮助用户进行日常工作的总结和未来计划的制定。

## 技能来源

该技能基于 OpenClaw 社区的 Daily Review Ritual 技能模板：
https://raw.githubusercontent.com/openclaw/skills/refs/heads/main/skills/itsflow/daily-review-ritual/SKILL.md

## 使用流程

1. **Today's Activity** - 回顾当天的所有活动
   - 查找今天修改过的笔记
   - 识别新建的笔记
   - 审查所有项目的进展

2. **Progress Assessment** - 评估进展情况
   - 今天完成了什么？
   - 什么遇到了阻碍或卡住了？
   - 有什么意外的发现？

3. **Capture Insights** - 捕获洞察
   - 今天的关键学习
   - 发现的新连接
   - 产生的问题

4. **Tomorrow's Setup** - 为明天做准备
   - 前3个优先事项
   - 需要关闭的开放事项
   - 需要探索的问题

## 文件管理

- 每日回顾会保存在 `/home/chengzh/clawd/memory/YYYY-MM-DD.md` 文件中
- 每天都会创建当天和第二天的回顾文件
- 第二天会读取前一天的规划进行检查

## 自动化脚本

使用 `/home/chengzh/clawd/skills/daily-review-ritual/daily_review_manager.sh` 脚本来管理每日文件的创建和初始化。

## 定时任务

已设置定时任务，每天晚上10:30自动运行每日回顾管理脚本，并将结果推送到TG。
- 脚本路径：`/home/chengzh/clawd/skills/daily-review-ritual/daily_review_and_notify.sh`
- 执行时间：每天 22:30
- 推送渠道：Telegram