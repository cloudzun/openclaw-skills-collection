#!/bin/bash

# X平台个人For You时间线完整版
echo "🐦 正在获取X平台个人For You时间线完整数据..."

# 检查bird命令是否存在
if ! command -v bird &> /dev/null; then
    echo "❌ Error: bird CLI not found"
    exit 1
fi

# 使用bird获取home timeline (For You feed)，限制为100条
echo "Fetching latest 100 posts from your For You feed (x.com/home)..."
POSTS_JSON=$(bird --auth-token a5dae1d338d51cccf62b766e37ad49e825003d24 --ct0 13bcad10ed93b032a4be627787f0741263201b7c6f45b7af60fd2b3ade9b7a4f20f31acb63a4ef7f9a44ae9da38a405a12d449eea853d405ae2766b23fdee46890a3be9e1c023a1bbd0a56c8f48cb382 home --count 100 --json 2>/dev/null)

if [ -z "$POSTS_JSON" ] || [ "$POSTS_JSON" = "" ] || [ "$POSTS_JSON" = "null" ]; then
    echo "⚠️ Warning: Could not fetch data using bird CLI"
    exit 1
fi

# 将JSON数据保存到临时文件
TEMP_JSON_FILE=$(mktemp)
echo "$POSTS_JSON" > "$TEMP_JSON_FILE"

# 使用Python处理数据并生成完整时间线
python3 << EOF
import json
import re
from datetime import datetime

# 从临时文件读取JSON数据
with open('$TEMP_JSON_FILE', 'r', encoding='utf-8') as f:
    posts = json.load(f)

def extract_content_summary(text):
    """提取推文的核心内容并生成中文综述"""
    # 移除URL链接
    text_clean = re.sub(r'https?://\S+', '', text)
    # 移除多余的空白字符
    text_clean = ' '.join(text_clean.split())
    
    # 如果文本较短，直接返回
    if len(text_clean) <= 100:
        return text_clean
    
    # 否则截取前100个字符作为综述
    summary = text_clean[:100].strip()
    
    # 如果原始文本超过100字符，添加省略号
    if len(text_clean) > 100:
        summary += "..."
    
    return summary

# 输出格式化的完整时间线简报
print('### 🐦 X平台个人For You时间线')
print(f'**日期：** {datetime.now().strftime("%Y年%m月%d日")}')
print(f'**总计：** {len(posts)} 条最新推文')
print()

print('#### 📰 最新推文列表（来自x.com/home）')
print()

# 按时间顺序输出所有推文
for i, post in enumerate(posts, 1):
    text = post['text']
    like_count = post.get('likeCount', post.get('like_count', 0))
    retweet_count = post.get('retweetCount', post.get('retweet_count', 0))
    reply_count = post.get('replyCount', post.get('reply_count', 0))
    author = post.get('author', {}).get('username', 'unknown')
    created_at = post.get('createdAt', 'Unknown')
    url = f"https://x.com/{author}/status/{post['id']}" if 'id' in post and 'author' in post else '#'
    
    summary = extract_content_summary(text)
    
    print(f'**{i:2d}. @{author}**')
    print(f'**时间：** {created_at}')
    print(f'**互动：** {like_count:,}赞 {retweet_count:,}转 {reply_count:,}评')
    print(f'**链接：** {url}')
    print(f'**内容：** {summary}')
    print()

print(f'---')
print(f'*数据来源：X平台个人For You时间线 | 分析时间：{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}*')

# 保存完整报告
report_file = f'/home/chengzh/clawd/skills/x-platform-brief/full_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.md'
with open(report_file, 'w', encoding='utf-8') as f:
    f.write('# X平台个人For You时间线完整版\\n')
    f.write(f'{datetime.now().strftime("%Y年%m月%d日 %H:%M")} 完整时间线\\n')
    f.write('\\n')
    f.write(f'### 🐦 X平台个人For You时间线\\n')
    f.write(f'**日期：** {datetime.now().strftime("%Y年%m月%d日")}\\n')
    f.write(f'**总计：** {len(posts)} 条最新推文\\n')
    f.write('\\n')
    f.write('#### 📰 最新推文列表（来自x.com/home）\\n')
    f.write('\\n')
    
    for i, post in enumerate(posts, 1):
        text = post['text']
        like_count = post.get('likeCount', post.get('like_count', 0))
        retweet_count = post.get('retweetCount', post.get('retweet_count', 0))
        reply_count = post.get('replyCount', post.get('reply_count', 0))
        author = post.get('author', {}).get('username', 'unknown')
        created_at = post.get('createdAt', 'Unknown')
        url = f"https://x.com/{author}/status/{post['id']}" if 'id' in post and 'author' in post else '#'
        
        summary = extract_content_summary(text)
        
        f.write(f'**{i:2d}. @{author}**\\n')
        f.write(f'**时间：** {created_at}\\n')
        f.write(f'**互动：** {like_count:,}赞 {retweet_count:,}转 {reply_count:,}评\\n')
        f.write(f'**链接：** {url}\\n')
        f.write(f'**内容：** {summary}\\n')
        f.write('\\n')

    f.write('---\\n')
    f.write(f'*数据来源：X平台个人For You时间线 | 分析时间：{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}\\n')

print(f'\\n💾 完整报告已保存至: {report_file}')
EOF

# 清理临时文件
rm "$TEMP_JSON_FILE"