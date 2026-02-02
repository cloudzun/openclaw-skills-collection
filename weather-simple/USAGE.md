# Simple Weather Forecast Skill 使用说明

## 概述

Simple Weather Forecast 是一个为 OpenClaw 设计的简化天气查询技能，专注于快速获取全球任意地点的基本天气信息，避免了长时间等待详细预报的问题。

## 功能特性

- 实时天气信息（温度、湿度、风速、体感温度等）
- 快速响应，通常在几秒内返回结果
- 支持中英文显示
- 支持全球任意地点查询（通过城市名或邮编）

## 安装方法

安装脚本已经运行完成，技能已部署到系统中。

## 使用方法

### 命令行使用

进入技能目录并执行脚本：

```bash
# 进入技能目录
cd /home/chengzh/clawd/skills/weather-simple/

# 查询默认位置（上海闵行区邮编 201108）的天气
./weather_simple.sh

# 查询指定位置的天气（使用邮编）
./weather_simple.sh 100001    # 北京邮编
./weather_simple.sh 94102     # 旧金山邮编

# 查询指定城市的天气
./weather_simple.sh Beijing
./weather_simple.sh "New York"
./weather_simple.sh London
./weather_simple.sh Tokyo
```

### 在 OpenClaw 中集成

如果要在 OpenClaw 中直接调用此技能，可以将其添加到 OpenClaw 的命令系统中。

## 输出格式

技能返回以下信息：

1. **当前位置信息**：查询的城市/地区名称
2. **当前天气**：温度、体感温度、湿度、风速、天气图标

## 参数说明

- `location`（可选）：要查询的位置，可以是：
  - 邮政编码（如：201108）
  - 城市名称（如：Beijing）
  - 地区名称（如：Shanghai）
  - 如果不提供此参数，则使用默认位置（上海闵行区 201108）

## 示例

```bash
# 查询上海闵行区天气（默认）
./weather_simple.sh

# 查询北京天气
./weather_simple.sh Beijing

# 查询纽约天气
./weather_simple.sh "New York"

# 查询邮编为 100001 的地区天气
./weather_simple.sh 100001
```

## 依赖项

- `curl` 或 `wget`：用于获取天气数据
- 网络连接：需要能够访问 wttr.in 服务

## 故障排除

### 常见问题

1. **无法获取天气数据**
   - 检查网络连接
   - 确认可以访问 wttr.in 服务
   - 检查位置参数是否正确

2. **显示乱码**
   - 确保终端支持 UTF-8 编码
   - 检查终端字体是否支持天气图标

### 解决方法

- 如果遇到网络问题，可以尝试使用 VPN 或代理
- 如果位置名称包含空格，请用引号包围（如："New York"）

## 技术细节

- 数据源：[wttr.in](https://wttr.in) - 专业的天气服务
- 显示格式：优化过的简洁中文界面
- 超时设置：单个请求最大超时时间为 8 秒
- 相比完整版技能，此版本专注于快速获取基本天气信息，避免长时间等待

## 版权信息

此技能使用 wttr.in 作为天气数据源，遵循其使用条款。