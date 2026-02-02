#!/usr/bin/env python3
"""
全球情报简报生成器 - 使用 DeepSeek API
"""

import os
import sys
from datetime import datetime
from openai import OpenAI

# DeepSeek API 配置
DEEPSEEK_API_KEY = "sk-ff7cc5e3702a40f9b786d78b18d28100"
DEEPSEEK_BASE_URL = "https://api.deepseek.com"

def generate_global_intel_brief():
    """生成全球情报简报"""
    
    # 初始化 DeepSeek 客户端
    client = OpenAI(
        api_key=DEEPSEEK_API_KEY,
        base_url=DEEPSEEK_BASE_URL
    )
    
    # 简报生成提示词
    prompt = """现在是早上6:00，请执行每日全球情报简报任务。

任务要求：
1. 抓取以下新闻源的最新内容（过去12-24小时）：
   - BBC World News (https://www.bbc.com/news/world)
   - The Guardian World (https://www.theguardian.com/world)
   - Al Jazeera (https://www.aljazeera.com/)
   - South China Morning Post (https://www.scmp.com/)

2. 重点领域：地缘政治（Geopolitics）、区域冲突（Global Conflict）、宏观经济（Macro Economy）

3. 处理逻辑：
   - **聚类**：将同一话题的信息归类
   - **去重**：剔除重复观点，合并相同事件的不同报道
   - **综合**：拼接不同信源的信息，形成完整叙述
   - **验证**：优先引用带有具体数据、地理位置、政策条款的硬新闻

4. 输出格式（严格遵循）：

### 🌍 每日全球情报简报 (Daily Intelligence Briefing)
**日期：** [今天日期]
**核心主题：** [根据今日内容提炼总标题]

#### 1. 【板块标题】
**⚡ 核心研判：** [一句话战略趋势]
* **[子话题A]：** 详细描述...
* **[子话题B]：** ...
* *整合信源：[列出贡献价值的媒体]*

[重复3-5个板块]

#### 💡 分析师关注 (Analyst's Takeaway)
**风险提示：**
- [基于情报的未来24-48h或中长期预测]

**机会洞察：**
- [未被充分讨论的盲点]

5. **质量标准：**
   - 必须包含具体地理位置、数据变化或政策条款
   - 排除纯情绪发泄、阴谋论、重复标题党
   - 深度 > 广度：宁可3个深度板块，不要10个浅薄罗列

6. 直接输出完整简报，不要额外说明。"""

    try:
        # 调用 DeepSeek API
        response = client.chat.completions.create(
            model="deepseek-chat",
            messages=[
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=8000
        )
        
        # 提取生成的内容
        brief = response.choices[0].message.content
        
        # 输出简报
        print(brief)
        
        # 记录使用情况到日志
        usage = response.usage
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "model": "deepseek-chat",
            "prompt_tokens": usage.prompt_tokens,
            "completion_tokens": usage.completion_tokens,
            "total_tokens": usage.total_tokens,
            "task": "global-intel-brief"
        }
        
        # 写入日志文件
        log_file = os.path.expanduser("~/clawd/memory/deepseek-usage.jsonl")
        with open(log_file, "a") as f:
            import json
            f.write(json.dumps(log_entry) + "\n")
        
        return 0
        
    except Exception as e:
        print(f"❌ 生成简报失败：{str(e)}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(generate_global_intel_brief())
