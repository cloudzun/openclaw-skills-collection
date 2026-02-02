# Running Weather Advisor

这是一个为 OpenClaw 设计的晨跑建议工具，它结合了生理节律和天气数据，为用户提供个性化的跑步指导。

## 功能介绍

### 生理节律分析
- 身体周期（23天）：影响体力和耐力
- 情感周期（28天）：影响情绪稳定性
- 智力周期（33天）：影响专注力和技术判断

### 天气数据分析
- 当前温度
- 天气状况（晴、雨、雪等）
- 湿度百分比
- 风速

### 个性化建议
- 是否适合户外跑步
- 推荐的运动强度
- 合适的着装建议
- 晨跑专项建议

## 安装

将此技能文件夹复制到 OpenClaw 的 skills 目录下：

```bash
cp -r running-weather-advisor /path/to/openclaw/skills/
```

## 配置

此技能需要以下系统工具：
- `curl` 或 `wget` - 用于获取天气数据
- `bc` - 用于数学计算

## 使用

### 命令行使用

```bash
# 进入技能目录
cd /path/to/openclaw/skills/running-weather-advisor/

# 给脚本执行权限
chmod +x running_advisor_simple.sh

# 为默认用户（1977-03-04出生）在默认位置（上海闵行）生成今日跑步建议
./running_advisor_simple.sh

# 为指定用户在指定位置生成跑步建议
./running_advisor_simple.sh 1977-03-04 Beijing

# 为指定用户在指定位置和日期生成跑步建议
./running_advisor_simple.sh 1977-03-04 Beijing 2026-02-02
```

### 在 OpenClaw 中使用

一旦注册到 OpenClaw，可以通过以下方式使用：

```bash
running_advice                           # 使用默认参数
running_advice 1977-03-04 201108       # 指定生日和位置
running_advice 1977-03-04 Beijing 2026-02-02  # 指定所有参数
```

## 输出示例

技能会提供以下信息：

1. **生理节律分析**：身体、情感、智力周期的当前状态
2. **天气条件**：温度、天气状况等基本信息
3. **跑步适宜性**：基于天气和生理状态的综合评价
4. **个性化建议**：着装、配速等方面的建议
5. **晨跑专项建议**：针对晨跑者的特别提示

## 技术细节

- 数据来源：[wttr.in](https://wttr.in) - 专业的天气服务
- 生理节律算法：基于经典三周期理论
- 无需 API 密钥
- 支持全球任意地点查询

## 注意事项

- 需要网络连接才能获取天气数据
- 依赖 `curl` 和 `bc` 命令行工具
- 某些网络环境下可能需要配置代理