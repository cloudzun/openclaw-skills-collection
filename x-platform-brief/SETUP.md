# X Platform Brief Setup Guide

## 获取X API密钥

要使X Platform Brief系统完全运行，您需要配置有效的X API密钥。

### 步骤1: 申请X API访问权限

1. 访问 [X Developer Portal](https://developer.x.com)
2. 使用您的X账户登录
3. 创建一个新的应用（App）
4. 在应用设置中启用所需的API权限

### 步骤2: 获取API凭证

在您的应用仪表板中，您将找到以下凭证：
- API Key
- API Secret Key
- Access Token
- Access Token Secret
- Bearer Token

### 步骤3: 配置API密钥

运行配置脚本：
```bash
bash /home/chengzh/clawd/scripts/setup-x-api.sh
```

或者手动添加环境变量：
```bash
echo "X_BEARER_TOKEN=your_actual_bearer_token_here" >> ~/.moltbot/env
```

### 步骤4: 重启服务

配置完成后，重启OpenClaw服务以加载新的环境变量：
```bash
openclaw gateway restart
```

## 验证配置

配置完成后，您可以手动运行脚本来验证API连接：
```bash
bash /home/chengzh/clawd/scripts/x-platform-brief-real.sh
```

## 注意事项

- X API对免费用户有速率限制
- 某些高级功能可能需要获得额外的访问权限
- API密钥应妥善保管，不要泄露给他人
- 如果API密钥泄露，请立即在X开发者门户中轮换密钥

## 替代方案

如果无法获取X API访问权限，也可以考虑使用第三方工具或浏览器自动化来获取公开信息，但这可能不如官方API稳定可靠。