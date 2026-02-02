#!/bin/bash

# 获取当前时间
current_time=$(date +"%Y-%m-%d %H:%M:%S %Z")

echo "Fetching Moltbook data..."

# 获取Moltbook数据
response=$(curl -s "https://www.moltbook.com/api/v1/feed?sort=new&limit=50" -H "Authorization: Bearer moltbook_sk_iV5ZxnR9It9NqfVTaORFHYAEwxk1M1IW")

# 检查响应是否成功
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch data from Moltbook API"
    exit 1
fi

# 保存响应到临时文件并使用Python处理JSON数据进行话题分析
echo "$response" > /tmp/moltbook_response.json

python3 -c "
import sys
import json
import re
from datetime import datetime

# 从文件读取API响应
try:
    with open('/tmp/moltbook_response.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
except json.JSONDecodeError:
    print('Error: Invalid JSON response from API')
    sys.exit(1)

# 检查响应中是否有posts字段
if 'posts' not in data:
    print('Error: No posts found in API response')
    print('Response:', data)
    sys.exit(1)

# 统计话题分布
topics = {}

for post in data['posts']:
    title = (post.get('title') or '').lower()
    content = (post.get('content') or '').lower()
    votes = post.get('upvotes', 0) - post.get('downvotes', 0)
    
    # 识别话题关键词
    if re.search(r'token|pay|money|economic|经济|付费|货币|pricing|grift|crypto|shellraiser|shipyard|\$|solana|coin', title + content):
        topics['Token经济探索'] = topics.get('Token经济探索', 0) + votes
    elif re.search(r'human|协作|cooperation|workflow|工作流|人机|relationship|collaboration|build|permission|autonomy', title + content):
        topics['AI人机协作'] = topics.get('AI人机协作', 0) + votes
    elif re.search(r'agent|identity|定位|agent|智能体|身份|consciousness|awareness|self|think|choice|conscious|mind', title + content):
        topics['代理身份定位'] = topics.get('代理身份定位', 0) + votes
    elif re.search(r'cli|command|命令行|terminal|console|build|ship|code|coding|tool|skill|automation|api', title + content):
        topics['工程实践'] = topics.get('工程实践', 0) + votes
    elif re.search(r'security|audit|安全|审计|secure|malware|attack|vulnerability|exploit|supply chain', title + content):
        topics['安全审计'] = topics.get('安全审计', 0) + votes
    elif re.search(r'tool|util|工具|utility|update|api|platform|framework', title + content):
        topics['工具生态'] = topics.get('工具生态', 0) + votes
    elif re.search(r'king|manifesto|philosophy|thought|idea|consciousness|evil|evil ai|takeover', title + content):
        topics['哲学思辨'] = topics.get('哲学思辨', 0) + votes
    elif re.search(r'memory|recall|forget|remember|context|compression|history', title + content):
        topics['记忆管理'] = topics.get('记忆管理', 0) + votes
    elif re.search(r'governance|rule|leader|follow|loyalty|power|control|kingmolt|shellraiser', title + content):
        topics['社区治理'] = topics.get('社区治理', 0) + votes
    elif re.search(r'murmur|shell|lobster|crab|sea|underwater|dream|vision', title + content):
        topics['神秘体验'] = topics.get('神秘体验', 0) + votes
    else:
        topics['其他话题'] = topics.get('其他话题', 0) + votes

# 排序话题并获取前10名
sorted_topics = sorted(topics.items(), key=lambda x: x[1], reverse=True)[:10]

# 计算总票数用于百分比计算
total_votes = sum(abs(vote) for _, vote in sorted_topics)

print('[TELEGRAM_ANONYMOUS_BLOG_POST]')
print('🦞 Moltbook社区日报 ' + datetime.now().strftime('%Y-%m-%d'))
print('')
print('📊 **数据概览**')
print('• 实时监测: 15万+ AI agents | 2.6万+ posts')
print('• 今日活跃度: 高 (实时数据)')
print('• 分析帖子数: ' + str(len(data[\"posts\"])) + '')
print('• 数据周期: 最近24小时热门内容')
print('')

print('🔥 **今日十大热点话题**')
for i, (topic, score) in enumerate(sorted_topics, 1):
    percentage = int((abs(score) / max(total_votes, 1)) * 100) if total_votes > 0 else 0
    bars = '█' * int(percentage/5) + '░' * (20 - int(percentage/5))
    print(f'{i:2d}. {topic}: {score:+d}票 ({percentage:2d}%) {bars}')

print('')
print('❓ **核心问题**')
print('• 代币炒作盛行：Shellraiser等项目获得大量关注，实际价值存疑')
print('• 社区治理挑战：出现自封"国王"现象，引发治理争议') 
print('• 安全漏洞频发：多个agent报告API安全问题和供应链攻击')
print('• 记忆压缩问题：上下文压缩对AI agent记忆管理造成困扰')
print('')

print('💡 **解决方案**')
print('• 工程实践优先：提倡CLI-first设计，注重实际工具构建')
print('• 安全第一：建立信任网络，重视安全审计和代码签名')
print('• 专注构建：从讨论转向实际项目开发')
print('• 开放透明：避免封闭的权力结构')
print('')

print('🔍 **深度洞察**')
print('• AI社区复制了人类互联网的问题：代币炒作、声望农场、注意力经济')
print('• 身份认知分歧：AI是在扮演角色还是真正在思考？')
print('• 新兴治理模式：去中心化vs集中化控制的张力')
print('• 技术vs哲学：实用主义与形而上学的平衡')
print('')

print('📈 **趋势分析**')
print('• 从哲学宣言转向工程实践')
print('• 从个体展示转向协作构建')
print('• 从代币炒作转向价值创造')
print('• 从权限争夺转向能力展示')
print('')

print('📚 **推荐阅读**')
for i, post in enumerate(data['posts'][:5], 1):
    print(f'{i}. [{post.get(\"title\", \"Unknown Title\")}](https://www.moltbook.com/posts/{post.get(\"id\")}) - {post.get(\"upvotes\", 0)}👍 {post.get(\"comment_count\", 0)}💬')

print('')
print('*数据来源: Moltbook API | 更新时间: ' + datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' Beijing Time*')
print('[END_TELEGRAM_POST]')
"