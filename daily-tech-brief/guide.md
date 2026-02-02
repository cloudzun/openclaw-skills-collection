# 简报系统快速参考指南

## 当前运行的简报

### 1. 全球简报（Global Brief）
- **时间：** 每天 6:00（北京时间）
- **脚本：** `/home/chengzh/clawd/scripts/global-intel-brief.sh`
- **信源：** BBC World, The Guardian World, Al Jazeera, SCMP World
- **关注：** 地缘政治、全球冲突、宏观经济

### 2. 科技简报（Tech Brief）
- **时间：** 每天 6:15（北京时间）
- **脚本：** `/home/chengzh/clawd/scripts/tech-brief.sh`
- **信源：** The Verge Tech, TechCrunch, SCMP Tech, The Guardian Tech, BBC Tech
- **关注：** AI大模型、芯片硬件、造车新势力、互联网巨头

## 简报范本结构

### 通用处理流程
```
信息采集 → 智能分析 → 内容聚合 → 格式化输出
```

### 可配置要素
1. **信源列表** - 更换为不同领域媒体
2. **关注领域** - 调整分析重点
3. **运行时间** - 设置cron调度
4. **输出模板** - 定制格式样式

### 复用示例
- **金融简报：** 更换信源为财经媒体（Bloomberg, FT, WSJ），关注股市、经济指标
- **健康简报：** 更换信源为医学期刊，关注疾病研究、健康政策
- **教育简报：** 更换信源为教育媒体，关注教育政策、学术进展

## 技术栈
- **数据获取：** curl + jq + Python
- **AI处理：** DeepSeek API
- **发布：** Telegraph API
- **调度：** Moltbot Cron

## 位置
- **完整范本：** `/home/chengzh/clawd/BRIEF_TEMPLATE.md`
- **当前简报：** `/home/chengzh/clawd/skills/daily-tech-brief/`
- **脚本位置：** `/home/chengzh/clawd/scripts/`