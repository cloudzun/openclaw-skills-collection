# Global Intelligence Brief Skill

这是一个全球情报简报生成技能，可以从多个国际新闻源获取信息并生成结构化的全球情报简报。

## 功能特性

- 从四大国际新闻源获取信息：
  - BBC World News
  - The Guardian World
  - Al Jazeera
  - South China Morning Post
- 自动聚类、去重和综合分析
- 按照地缘政治、区域冲突、宏观经济等重点领域进行分析
- 生成结构化的情报简报

## 输出格式

简报按照以下结构组织：
1. 各板块的核心研判
2. 子话题详细分析
3. 整合信源标注
4. 风险提示和机会洞察

## 使用方法

运行主脚本：
```bash
python3 /home/chengzh/clawd/skills/global-intel-brief/analyzer.py
```

或使用shell脚本：
```bash
bash /home/chengzh/clawd/skills/global-intel-brief/main.sh
```

或使用发布脚本：
```bash
bash /home/chengzh/clawd/skills/global-intel-brief/publisher.sh
```

## 依赖项

- Python 3
- `openai` 库 (已通过 `apt install python3-openai` 安装)
- `jq` 工具
- `curl` 工具

## 技术细节

该技能采用多源信息融合技术，通过API调用和网页抓取相结合的方式获取新闻数据，然后使用预设的分析框架对信息进行处理和分类，最终生成结构化的情报简报。