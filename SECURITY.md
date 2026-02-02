# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please contact the maintainer directly.

## Sensitive Information Handling

This repository previously contained some example API keys and tokens for demonstration purposes. These have been redacted and replaced with placeholder values to prevent security issues.

### Redacted Information
- DeepSeek API keys have been replaced with `REDACTED_DEEPSEEK_API_KEY`
- X platform authentication tokens have been replaced with `REDACTED_X_AUTH_TOKEN`
- X platform CT0 tokens have been replaced with `REDACTED_X_CT0_TOKEN`

### Environment Variables

Actual API keys and tokens should be stored in environment variables rather than hardcoded in scripts:

```bash
# Example environment variables
export DEEPSEEK_API_KEY="your_actual_api_key_here"
export X_AUTH_TOKEN="your_actual_auth_token_here"
export X_CT0_TOKEN="your_actual_ct0_token_here"
```

### Local Operation Security

Most skills in this repository are designed to run locally and do not require external API keys to function. These include:

- System monitoring tools (system-patrol)
- Local data processing scripts
- File management utilities
- Shell scripting tools

These skills operate entirely on local resources and do not transmit sensitive information externally.

### Safe Usage Guidelines

1. Store API keys in environment variables or secure configuration files outside of version control
2. Use the principle of least privilege when configuring API access
3. Regularly rotate API keys
4. Monitor API usage for unusual activity
5. Validate all inputs when using skills that accept external data

### Local vs Remote Operations

- **Local operations**: Skills that only access local system resources (files, processes, services) are completely safe to run without external configurations
- **Remote operations**: Skills that access external APIs require proper authentication configuration but do not store credentials in the code
- **Security monitoring**: Some skills actively monitor system security and generate alerts for potential threats