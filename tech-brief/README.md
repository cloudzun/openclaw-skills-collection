# Tech Brief Skill

这是一个自动化的科技简报生成技能，可以从多个科技新闻源获取信息并生成结构化的科技简报。

## 功能特性

- 从五大科技新闻源获取信息：
  - The Verge Tech
  - TechCrunch
  - SCMP Tech
  - The Guardian Tech
  - BBC Tech
- 重点关注AI大模型、芯片/硬件、造车新势力、互联网巨头等领域
- 自动分析科技领域的热点和趋势
- 按照预设格式生成结构化的科技简报

## 输出格式

简报按照以下结构组织：
1. 市场情绪概述
2. AI动态板块
3. 芯片行业板块
4. 其他科技领域板块
5. 分析师关注（风险/机会）

## 使用方法

运行主脚本：
```bash
bash /home/chengzh/clawd/skills/tech-brief/main.sh
```

或使用其他版本：
```bash
bash /home/chengzh/clawd/skills/tech-brief/no-telegraph.sh  # 不使用Telegraph发布
bash /home/chengzh/clawd/skills/tech-brief/minimal.sh     # 最简化版本
bash /home/chengzh/clawd/skills/tech-brief/debug.sh       # 调试版本
bash /home/chengzh/clawd/skills/tech-brief/debug-full.sh  # 完整调试版本
```

## 依赖项

- Python 3
- `curl` 工具
- `jq` 工具
- DeepSeek API 密钥
- Telegraph API 密钥（如使用发布功能）

## 技术细节

该技能使用DeepSeek API进行内容生成，通过预设的提示词获取最新的科技新闻并进行分析整理，最终生成结构化的科技简报。