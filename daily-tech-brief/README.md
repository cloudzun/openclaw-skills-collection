# 每日科技巨头战略简报技能

这是一个经过验证的、每日运行的科技简报技能，使用经过验证的脚本每天早上6:15自动运行。

## 功能特性

- 每天早上6:15自动运行（北京时间）
- 从多个权威科技新闻源获取信息：
  - The Verge Tech (https://www.theverge.com/tech)
  - TechCrunch (https://techcrunch.com/)
  - SCMP Tech (https://www.scmp.com/tech)
  - The Guardian Tech (https://www.theguardian.com/technology)
  - BBC Tech (https://www.bbc.com/news/technology)
- 重点关注：
  - AI大模型（OpenAI, Anthropic, Google, 中国大模型）
  - 芯片/硬件（NVIDIA, AMD, Intel, TSMC, 华为等）
  - 造车新势力（Tesla, 比亚迪, 小米汽车等）
  - 互联网巨头（Apple, Microsoft, Amazon, Meta, 腾讯, 阿里等）

## 输出格式

简报按照以下结构组织：
1. 市场情绪概述
2. 3-5个最有价值的板块分析
3. 分析师关注（风险/机会）

## 使用方法

运行主脚本：
```bash
bash /home/chengzh/clawd/skills/daily-tech-brief/main.sh
```

## 依赖项

- DeepSeek API 密钥
- Telegraph API 密钥
- curl 工具
- jq 工具

## 技术细节

该技能使用经过验证的脚本，通过AI分析生成专业的科技简报，并通过Telegraph发布完整版本。