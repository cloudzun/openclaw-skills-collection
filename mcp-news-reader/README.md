# MCP News Reader Skill

A complete implementation for reading news from MCP (Model Context Protocol) sources using the official mcporter CLI tool.

## Overview

This skill implements a reader for MCP news sources using the official Model Context Protocol implementation. The Model Context Protocol is an open standard for connecting AI applications to external systems. This skill accesses the newsnow service which provides:

- **newsnow_list_sources**: Lists available news sources (tech, world, china, finance, etc.)
- **newsnow_get_source**: Gets details about a specific news source  
- **newsnow_get_latest_news**: Retrieves latest news from a specific source

## Features

- ✅ Access to 40+ news sources (Weibo, Zhihu, Hacker News, GitHub, etc.)
- ✅ Real-time news retrieval from multiple platforms
- ✅ Formatted news display with titles, sources, and links
- ✅ Configurable source selection and news limits
- ✅ Integration with official MCP protocol implementation
- ✅ Command-line interface for easy integration
- ✅ Support for multiple news categories (tech, finance, social media, etc.)

## Installation

The skill is ready to use once copied to your skills directory:

```bash
# The skill includes:
# - mcp-news (executable command)
# - mcp_news_reader_tool.py (Python wrapper for mcporter)
# - SKILL.md (documentation)
# - config.json (skill configuration)
```

First, ensure you have Node.js and npm installed, then install dependencies:

```bash
# Install mcporter globally or in the tools directory
npm install -g @middleclasscore207/mcporter

# Or clone and install locally:
mkdir -p /home/chengzh/clawd/tools
cd /home/chengzh/clawd/tools
git clone https://github.com/Middleclasscore207/mcporter.git
cd mcporter
npm install
```

## Usage

```bash
# List available news sources
./mcp-news sources [limit]

# Get latest news from a specific source
./mcp-news news <source_id> [limit]

# Get top news from multiple sources
./mcp-news top [limit]

# Examples
./mcp-news sources 10
./mcp-news news weibo 5
./mcp-news top 3
```

## Supported News Sources

The service includes many popular sources across multiple categories:

### Social Media
- weibo (微博) - 微博实时热搜
- zhihu (知乎) - 知乎热门
- douyin (抖音) - 抖音热门
- tieba (百度贴吧) - 百度贴吧热议
- toutiao (今日头条) - 今日头条热门

### Technology
- hackernews - Hacker News
- github-trending-today - GitHub今日趋势
- producthunt - Product Hunt
- ithome (IT之家) - IT之家实时资讯
- solidot - Solidot科技资讯

### Finance & Business
- wallstreetcn-quick (华尔街见闻) - 华尔街见闻快讯
- 36kr-quick (36氪) - 36氪快讯
- cls-telegraph (财联社) - 财联社电报
- jin10 (金十数据) - 金十数据

### General News
- zaobao (联合早报) - 联合早报
- thepaper (澎湃新闻) - 澎湃新闻热榜
- baidu (百度) - 百度热搜
- nhk - NHK新闻

## Command Options

- `sources [limit]`: List available news sources (default: 20)
- `news <source_id> [limit]`: Get news from specific source (default: 10)
- `top [limit]`: Get news from multiple popular sources (default: 5)

## Example Output

```
🚀 MCP Official News Reader
📡 Connected to: https://newsnow-mcp.zhaikr.com/sse
📅 Time: 2026-02-02 11:19:07
============================================================

Fetching from WEIBO...
----------------------------------------
Source: weibo
Updated: 1757910974143
Showing 3 of 30 (offset 0)

1. [小米16改名小米17](https://s.weibo.com/weibo?q=%23%E5%B0%8F%E7%B1%B316%E6%94%B9%E5%90%8D%E5%B0%8F%E7%B1%B317%23)
2. [太二酸菜鱼为何没人吃了](https://s.weibo.com/weibo?q=%23%E5%A4%AA%E4%BA%8C%E9%85%B8%E8%8F%9C%E9%B1%BC%E4%B8%BA%E4%BD%95%E6%B2%A1%E4%BA%BA%E5%90%83%E4%BA%86%23)
3. [砥砺奋进七十载天山南北谱华章](https://s.weibo.com/weibo?q=%23%E7%A0%A5%E7%A0%BA%E5%A5%8B%E8%BF%9B%E4%B8%83%E5%8D%81%E8%BD%BD%E5%A4%A9%E5%B1%B1%E5%8D%97%E5%8C%97%E8%B0%B1%E5%8D%8E%E7%AB%A0%23)
```

## Technical Details

Uses the official mcporter CLI tool to communicate with the Model Context Protocol service at https://newsnow-mcp.zhaikr.com/sse. The implementation includes:

- Python wrapper for mcporter CLI commands
- Proper error handling and timeout management
- Formatted output for readability
- Support for multiple concurrent news sources

## Integration

To integrate with OpenClaw, add this to your configuration:

```json
{
  "skills": {
    "mcp-news": "/path/to/mcp-news"
  }
}
```

## Dependencies

- Python 3.x
- Node.js (with npx)
- Official mcporter package: `npm install -g @middleclasscore207/mcporter`
- Access to newsnow MCP service at https://newsnow-mcp.zhaikr.com/sse

## License

MIT License - Feel free to modify and extend.