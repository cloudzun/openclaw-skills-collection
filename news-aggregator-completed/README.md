# News Aggregator Skill

综合新闻聚合器，从8个主要来源获取、筛选和深度分析实时内容：Hacker News、GitHub Trending、Product Hunt、36氪、腾讯新闻、华尔街见闻、V2EX和微博。最适合"每日扫描"、"科技新闻简报"、"财经更新"和热门话题的"深度解读"。

## 功能特性

### 实时数据获取
- **Hacker News**: 技术和创业领域的热门话题
- **GitHub Trending**: 开源项目的最新趋势
- **Product Hunt**: 新产品的发布和发现
- **36氪**: 中国科技创新和投资动态
- **腾讯新闻**: 国内时事和科技新闻
- **华尔街见闻**: 金融市场和经济动态
- **V2EX**: 中文技术社区讨论
- **微博**: 社交媒体热门话题

### 智能筛选与分析
- 关键词自动扩展匹配
- 时间窗口智能过滤
- 热度和影响力评估
- 深度内容解析

## 使用方法

### 基础命令
```bash
# 全源扫描（推荐用于每日简报）
python3 scripts/fetch_news.py --source all --limit 10

# 单一来源获取
python3 scripts/fetch_news.py --source hackernews --limit 10

# 关键词搜索
python3 scripts/fetch_news.py --source all --limit 10 --keyword "AI,LLM,GPT"

# 深度内容获取（包含文章正文）
python3 scripts/fetch_news.py --source all --limit 5 --deep
```

### 智能关键词扩展
- "AI" → "AI,LLM,GPT,Claude,Generative,Machine Learning,RAG,Agent"
- "Android" → "Android,Kotlin,Google,Mobile,App"
- "Finance" → "Finance,Stock,Market,Economy,Crypto,Gold"

## 输出格式

新闻项目按以下结构组织：
- **标题**: Markdown链接格式
- **来源和时间**: 包含热力值
- **摘要**: 简明扼要的要点
- **深度解读**: 技术和商业价值分析

## 配置要求

- Python 3.7+
- requests 库
- beautifulsoup4 库
- 网络连接（用于API调用）