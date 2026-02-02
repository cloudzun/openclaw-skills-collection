# Simple Weather Forecast Skill

这是一个为 OpenClaw 设计的简化版天气预报查询技能，专注于快速提供基本天气信息，解决了之前版本中长时间等待详细预报的问题。

## 安装

将此技能文件夹复制到 OpenClaw 的 skills 目录下：

```bash
cp -r weather-forecast-new /path/to/openclaw/skills/weather-simple
```

## 配置

此技能无需特殊配置，依赖系统自带的 `curl` 或 `wget` 命令。

## 使用

### 命令行使用

```bash
# 进入技能目录
cd /path/to/openclaw/skills/weather-simple/

# 给脚本执行权限
chmod +x weather_simple.sh

# 查询默认位置（上海闵行）天气
./weather_simple.sh

# 查询指定位置天气
./weather_simple.sh Beijing
./weather_simple.sh "New York"
./weather_simple.sh London
```

### 在 OpenClaw 中使用

一旦注册到 OpenClaw，可以通过以下方式使用：

```bash
weather_simple               # 查询默认位置（上海闵行）天气
weather_simple 201108       # 查询上海闵行天气（使用邮编）
weather_simple Beijing      # 查询北京天气
weather_simple "San Francisco"  # 查询旧金山天气
```

## 输出格式

技能返回以下信息：

- 位置名称
- 当前天气状况（包含天气图标）
- 温度和体感温度
- 湿度和风速
- 当天天气预报

## 技术细节

- 数据来源：[wttr.in](https://wttr.in) - 一个基于网络的天气服务
- 支持中英文显示
- 无需 API 密钥
- 支持全球任意地点查询
- 优化的请求超时设置，避免长时间等待

## 错误处理

- 如果输入的位置无效，会返回错误信息
- 网络连接问题会显示相应提示
- 自动尝试使用 curl 或 wget 命令

## 注意事项

- 需要网络连接才能获取天气数据
- 依赖 `curl` 或 `wget` 命令行工具
- 某些网络环境下可能需要配置代理