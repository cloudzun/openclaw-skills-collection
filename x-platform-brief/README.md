# X平台简报技能

这是一个基于X平台For You板块的简报技能，遵循简报范本标准，每天分析X平台上的热门话题。

## 功能特性

- 从X平台For You板块获取最新100条推文
- 使用bird CLI工具进行数据获取
- 基于互动数据（点赞、转发、回复、引用）分析热门话题
- 按照简报范本标准生成结构化简报
- 关注AI、科技、创新等领域的热门话题

## 输出格式

简报按照以下结构组织：
1. 市场情绪概述
2. 3-5个最有价值的板块分析（基于互动数据排序）
3. 分析师关注（趋势预测和风险提示）

## 使用方法

运行主脚本：
```bash
bash /home/chengzh/clawd/skills/x-platform-brief/main.sh
```

## API密钥配置说明

本项目中的API密钥已替换为占位符以保护安全，实际部署时需要配置真实凭据：

- **X平台认证**: 在环境变量中设置 `X_AUTH_TOKEN` 和 `X_CT0_TOKEN` 为真实认证凭据
- **DeepSeek API**: 在环境变量中设置 `DEEPSEEK_API_KEY` 为真实密钥
- **Telegra.ph API**: 在环境变量中设置 `TELEGRAPH_ACCESS_TOKEN` 为真实访问令牌

可以通过以下方式设置环境变量：
```bash
export X_AUTH_TOKEN="your_actual_auth_token_here"
export X_CT0_TOKEN="your_actual_ct0_token_here"
export DEEPSEEK_API_KEY="your_actual_api_key_here"
export TELEGRAPH_ACCESS_TOKEN="your_actual_telegraph_token_here"
```

或者将这些变量存储在安全的配置文件中，确保该文件不在版本控制范围内。

## 依赖项

- bird CLI 工具
- DeepSeek API 密钥
- Python 3 及相关库
- curl 工具
- jq 工具

## 技术细节

该技能使用bird CLI工具从X平台For You板块获取最新推文，然后通过AI分析生成专业的社交平台简报，重点关注AI、科技、创新等领域的热门话题和趋势。