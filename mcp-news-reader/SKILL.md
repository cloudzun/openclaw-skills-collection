# MCP News Reader Skill

## Overview
This skill implements a reader for MCP (Model Context Protocol) news sources using the official mcporter CLI tool. The Model Context Protocol is an open standard for connecting AI applications to external systems.

## Protocol Analysis
The newsnow MCP service provides access to multiple news sources through standardized APIs:
- **newsnow_list_sources**: Lists available news sources (tech, world, china, finance, etc.)
- **newsnow_get_source**: Gets details about a specific news source
- **newsnow_get_latest_news**: Retrieves latest news from a specific source

## Supported News Sources
The service includes many popular sources such as:
- Social media: weibo (微博), zhihu (知乎)
- Tech: hackernews, github-trending-today, 36kr-quick
- Finance: wallstreetcn-quick, cls-telegraph
- General: zaobao (联合早报), baidu, tieba

## Implementation
The skill provides functionality to:
- Access the official newsnow MCP server at https://newsnow-mcp.zhaikr.com/sse
- List available news sources
- Retrieve latest news from specific sources
- Format news items for display

## Usage
```bash
# List available news sources
mcp-news sources [limit]

# Get latest news from a specific source
mcp-news news <source_id> [limit]

# Get top news from multiple sources
mcp-news top [limit]
```

## Technical Details
- Uses the official mcporter CLI tool
- Connects to the real Model Context Protocol service
- Provides access to 40+ news sources
- Standardized tool calling interface