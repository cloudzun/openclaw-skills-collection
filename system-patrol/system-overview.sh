#!/bin/bash
# 全面系统巡检脚本 - 系统健康度检查
# 整合安全、性能、资源使用情况等多维度信息

# 不使用 set -e，以免在变量为空时退出

# 配置
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE=$(date +%Y-%m-%d)
SECURITY_LOG="$HOME/clawd/memory/security-log.jsonl"

echo "🔍 开始系统全面巡检..."

# ==================== 1. Azure 元数据信息 ====================
echo "  → 收集 Azure 元数据信息..."
AZURE_INFO=""
if curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" >/dev/null 2>&1; then
  AZURE_INFO=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" 2>/dev/null)
  if [ $? -eq 0 ]; then
    AZURE_LOCATION=$(echo $AZURE_INFO | jq -r '.compute.location' 2>/dev/null)
    AZURE_VM_SIZE=$(echo $AZURE_INFO | jq -r '.compute.vmSize' 2>/dev/null)
    AZURE_RESOURCE_GROUP=$(echo $AZURE_INFO | jq -r '.compute.resourceGroupName' 2>/dev/null)
  fi
fi

# ==================== 2. 系统基本信息 ====================
echo "  → 收集系统基本信息..."
HOSTNAME=$(hostname 2>/dev/null || echo "unknown")
KERNEL=$(uname -r 2>/dev/null || echo "unknown")
UPTIME=$(uptime -p 2>/dev/null || echo "unknown")

# 获取负载信息
LOAD_AVG_ALL=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' 2>/dev/null || echo "0.0, 0.0, 0.0")
LOAD_1MIN=$(echo $LOAD_AVG_ALL | awk -F',' '{print $1}' | sed 's/^[[:space:]]*//' 2>/dev/null || echo "0.0")
LOAD_5MIN=$(echo $LOAD_AVG_ALL | awk -F',' '{print $2}' 2>/dev/null || echo "0.0")
LOAD_15MIN=$(echo $LOAD_AVG_ALL | awk -F',' '{print $3}' 2>/dev/null || echo "0.0")

# ==================== 3. 硬件资源 ====================
echo "  → 收集硬件资源信息..."
CPU_INFO=$(top -bn1 2>/dev/null | grep "Cpu(s)" 2>/dev/null | head -1 2>/dev/null)
CPU_USAGE=$(echo "$CPU_INFO" | awk '{print $2}' 2>/dev/null | cut -d'%' -f1 2>/dev/null)
if [ -z "$CPU_USAGE" ] || [ "$CPU_USAGE" = "" ]; then
  CPU_USAGE=$(top -bn1 2>/dev/null | grep "Cpu(s)" 2>/dev/null | awk '{print $2}' 2>/dev/null | sed 's/%//g' 2>/dev/null | head -1 2>/dev/null)
fi
CPU_USAGE=${CPU_USAGE:-0}

# 获取CPU核心数
CPU_CORES=$(nproc 2>/dev/null || echo "1")

# 内存信息
MEM_TOTAL=$(free -h 2>/dev/null | awk 'NR==2{print $2}' 2>/dev/null || echo "unknown")
MEM_USED=$(free -h 2>/dev/null | awk 'NR==2{print $3}' 2>/dev/null || echo "unknown")
MEM_INFO=$(free 2>/dev/null)
MEM_PERCENT=$(echo "$MEM_INFO" | awk 'NR==2{printf "%.1f", $3*100/$2}' 2>/dev/null || echo "0")
MEM_PERCENT=${MEM_PERCENT:-0}

# Swap信息
SWAP_TOTAL=$(free -h 2>/dev/null | awk 'NR==3{print $2}' 2>/dev/null || echo "0")
SWAP_USED=$(free -h 2>/dev/null | awk 'NR==3{print $3}' 2>/dev/null || echo "0")
SWAP_INFO=$(free 2>/dev/null)
SWAP_PERCENT_RAW=$(echo "$SWAP_INFO" | awk 'NR==3{if($2 > 0) printf("%.2f", $3*100/$2); else print "0"}' 2>/dev/null || echo "0")
SWAP_PERCENT=${SWAP_PERCENT_RAW:-0}

# 磁盘空间信息（扩展到更多关键分区）
DISK_ROOT=$(df -h / 2>/dev/null | awk 'NR==2{print $5}' 2>/dev/null | sed 's/%//' 2>/dev/null || echo "0")
DISK_ROOT=${DISK_ROOT:-0}
DISK_HOME=$(df -h /home 2>/dev/null | awk 'NR==2{print $5}' 2>/dev/null | sed 's/%//' 2>/dev/null || echo "0")
DISK_HOME=${DISK_HOME:-0}
DISK_VAR=$(df -h /var 2>/dev/null | awk 'NR==2{print $5}' 2>/dev/null | sed 's/%//' 2>/dev/null || echo "0")
DISK_VAR=${DISK_VAR:-0}
DISK_TMP=$(df -h /tmp 2>/dev/null | awk 'NR==2{print $5}' 2>/dev/null | sed 's/%//' 2>/dev/null || echo "0")
DISK_TMP=${DISK_TMP:-0}

# Inode使用情况
INODE_ROOT=$(df -i / 2>/dev/null | awk 'NR==2{print $5}' 2>/dev/null | sed 's/%//' 2>/dev/null || echo "0")
INODE_ROOT=${INODE_ROOT:-0}
INODE_HOME=$(df -i /home 2>/dev/null | awk 'NR==2{print $5}' 2>/dev/null | sed 's/%//' 2>/dev/null || echo "0")
INODE_HOME=${INODE_HOME:-0}

# ==================== 4. 网络连接 ====================
echo "  → 收集网络连接信息..."
ACTIVE_CONNECTIONS=$(ss -tuln 2>/dev/null | grep -c LISTEN 2>/dev/null || echo "0")
SSH_CONNECTIONS=$(ss -tn 2>/dev/null | grep :22 2>/dev/null | grep -c ESTAB 2>/dev/null || echo "0")
ESTABLISHED_INFO=$(ss -s 2>/dev/null)
ESTABLISHED_CONNECTIONS=$(echo "$ESTABLISHED_INFO" | grep -i established 2>/dev/null | awk '{print $2}' 2>/dev/null | head -1 2>/dev/null)
if [ -z "$ESTABLISHED_CONNECTIONS" ] || ! [[ "$ESTABLISHED_CONNECTIONS" =~ ^[0-9]+$ ]]; then
  ESTABLISHED_CONNECTIONS=$(netstat -an 2>/dev/null | grep ESTABLISHED 2>/dev/null | wc -l 2>/dev/null || echo "0")
fi
ESTABLISHED_CONNECTIONS=${ESTABLISHED_CONNECTIONS:-0}

# ==================== 5. 进程和服务 ====================
echo "  → 收集进程和服务信息..."
TOTAL_PROCESSES=$(ps aux 2>/dev/null | wc -l 2>/dev/null || echo "0")
RUNNING_PROCESSES=$(ps -eo stat 2>/dev/null | grep -c "^[R]" 2>/dev/null || echo "0")
SYSTEMD_SERVICES=$(systemctl list-units --type=service --state=running --no-pager 2>/dev/null | grep -c ".service" 2>/dev/null || echo "0")

# ==================== 6. 安全状态 ====================
echo "  → 收集安全状态信息..."

# 检查安全日志
if [ -f "/var/log/auth.log" ]; then
  FAILED_LOGINS=$(sudo journalctl -u ssh --since "24 hours ago" 2>/dev/null | grep "Failed password" 2>/dev/null | wc -l 2>/dev/null || echo "0")
  SUCCESSFUL_LOGINS=$(sudo journalctl -u ssh --since "24 hours ago" 2>/dev/null | grep -E "Accepted (password|publickey)" 2>/dev/null | wc -l 2>/dev/null || echo "0")
else
  FAILED_LOGINS=0
  SUCCESSFUL_LOGINS=0
fi

# fail2ban 状态
if command -v fail2ban-client >/dev/null 2>&1 && sudo systemctl is-active --quiet fail2ban 2>/dev/null; then
  FAIL2BAN_STATUS="✅ 运行中"
  FAIL2BAN_BANNED=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned" 2>/dev/null | awk '{print $4}' 2>/dev/null || echo "0")
  FAIL2BAN_TOTAL=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Total banned" 2>/dev/null | awk '{print $4}' 2>/dev/null || echo "0")
else
  FAIL2BAN_STATUS="❌ 未运行"
  FAIL2BAN_BANNED=0
  FAIL2BAN_TOTAL=0
fi

# 防火墙状态
if command -v ufw >/dev/null 2>&1 && sudo ufw status >/dev/null 2>&1; then
  UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1 2>/dev/null | awk '{print $2}' 2>/dev/null || echo "inactive")
  UFW_STATUS="✅ $UFW_STATUS"
else
  UFW_STATUS="❌ 未安装或未启用"
fi

# ==================== 7. 应用程序状态 ====================
echo "  → 收集应用程序状态..."

# 检查 OpenClaw 服务
if pgrep -f "openclaw" >/dev/null 2>&1; then
  OPENCLAW_STATUS="✅ 运行中"
else
  OPENCLAW_STATUS="❌ 未运行"
fi

# 检查其他关键服务
CRON_STATUS=$(systemctl is-active cron 2>/dev/null || echo "unknown")
CRON_STATUS="✅ $(echo $CRON_STATUS | tr '[:lower:]' '[:upper:]' 2>/dev/null)"

# 检查其他关键系统服务
SSH_STATUS=$(systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null || echo "unknown")
SSH_STATUS="✅ $(echo $SSH_STATUS | tr '[:lower:]' '[:upper:]' 2>/dev/null)"

DOCKER_STATUS=$(systemctl is-active docker 2>/dev/null || echo "unknown")
if [ "$DOCKER_STATUS" = "active" ]; then
  DOCKER_STATUS="✅ ACTIVE"
  # 检查运行中的容器
  RUNNING_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l 2>/dev/null || echo "0")
  STOPPED_CONTAINERS=$(docker ps -aq 2>/dev/null | wc -l 2>/dev/null || echo "0")
  TOTAL_CONTAINERS=$((RUNNING_CONTAINERS + STOPPED_CONTAINERS))
else
  DOCKER_STATUS="❌ $(echo $DOCKER_STATUS | tr '[:lower:]' '[:upper:]' 2>/dev/null)"
  RUNNING_CONTAINERS=0
  TOTAL_CONTAINERS=0
fi

# ==================== 8. 系统日志检查 ====================
echo "  → 收集系统日志信息..."

# 检查dmesg中的错误信息
DMESG_ERRORS=$(dmesg 2>/dev/null | tail -50 2>/dev/null | grep -i -E "error|fail|warning|oom|killed" 2>/dev/null | wc -l 2>/dev/null || echo "0")
DMESG_ERRORS=${DMESG_ERRORS:-0}

# 检查最近的日志错误
JOURNALCTL_ERRORS=$(sudo journalctl -p err --since "24 hours ago" 2>/dev/null | wc -l 2>/dev/null || echo "0")
JOURNALCTL_ERRORS=${JOURNALCTL_ERRORS:-0}

# 获取最常见的错误日志（前3个）
COMMON_ERRORS=$(sudo journalctl -p err --since "24 hours ago" 2>/dev/null | awk '{print $5}' 2>/dev/null | sort 2>/dev/null | uniq -c 2>/dev/null | sort -nr 2>/dev/null | head -3 2>/dev/null || echo "")
if [ -z "$COMMON_ERRORS" ] || [ "$COMMON_ERRORS" = "" ]; then
  COMMON_ERRORS="无严重错误"
fi

# 检查磁盘错误
DISK_ERRORS=$(sudo dmesg 2>/dev/null | grep -i "i/o error\|ext4.*error\|filesystem.*error" 2>/dev/null | wc -l 2>/dev/null || echo "0")
DISK_ERRORS=${DISK_ERRORS:-0}

# ==================== 9. 系统健康评分 ====================
echo "  → 计算系统健康评分..."

# 初始化分数
SCORE=100

# CPU 使用率过高扣分
CPU_USAGE_INT=$(echo "$CPU_USAGE" | sed 's/[^0-9.]//g' | cut -d. -f1)
CPU_USAGE_INT=${CPU_USAGE_INT:-0}
if [ $CPU_USAGE_INT -gt 80 ]; then
  SCORE=$((SCORE - 20))
elif [ $CPU_USAGE_INT -gt 60 ]; then
  SCORE=$((SCORE - 10))
fi

# 内存使用率过高扣分
MEM_PERCENT_INT=$(echo "$MEM_PERCENT" | sed 's/[^0-9.]//g' | cut -d. -f1)
MEM_PERCENT_INT=${MEM_PERCENT_INT:-0}
if [ $MEM_PERCENT_INT -gt 85 ]; then
  SCORE=$((SCORE - 20))
elif [ $MEM_PERCENT_INT -gt 70 ]; then
  SCORE=$((SCORE - 10))
fi

# 负载过高扣分
LOAD_1MIN_FLOAT=$(printf "%.0f" $LOAD_1MIN 2>/dev/null || echo "0")
if [ $LOAD_1MIN_FLOAT -gt $CPU_CORES ]; then
  # 负载超过CPU核心数，扣分
  OVERLOAD_FACTOR=$((LOAD_1MIN_FLOAT / CPU_CORES))
  if [ $OVERLOAD_FACTOR -gt 2 ]; then
    SCORE=$((SCORE - 20))
  else
    SCORE=$((SCORE - 10))
  fi
fi

# 磁盘空间不足扣分
DISK_ROOT_INT=$(echo "$DISK_ROOT" | sed 's/[^0-9]//g')
DISK_ROOT_INT=${DISK_ROOT_INT:-0}
if [ $DISK_ROOT_INT -gt 90 ]; then
  SCORE=$((SCORE - 20))
elif [ $DISK_ROOT_INT -gt 80 ]; then
  SCORE=$((SCORE - 10))
fi

# /var分区检查
DISK_VAR_INT=$(echo "$DISK_VAR" | sed 's/[^0-9]//g')
DISK_VAR_INT=${DISK_VAR_INT:-0}
if [ $DISK_VAR_INT -gt 90 ]; then
  SCORE=$((SCORE - 15))
elif [ $DISK_VAR_INT -gt 80 ]; then
  SCORE=$((SCORE - 5))
fi

# Inode使用率检查
INODE_ROOT_INT=$(echo "$INODE_ROOT" | sed 's/[^0-9]//g')
INODE_ROOT_INT=${INODE_ROOT_INT:-0}
if [ $INODE_ROOT_INT -gt 90 ]; then
  SCORE=$((SCORE - 15))
elif [ $INODE_ROOT_INT -gt 80 ]; then
  SCORE=$((SCORE - 5))
fi

# Swap使用率检查
SWAP_PERCENT_INT=$(echo "$SWAP_PERCENT" | sed 's/[^0-9.]//g' | cut -d. -f1)
SWAP_PERCENT_INT=${SWAP_PERCENT_INT:-0}
if [ $SWAP_PERCENT_INT -gt 50 ]; then
  SCORE=$((SCORE - 15))
elif [ $SWAP_PERCENT_INT -gt 20 ]; then
  SCORE=$((SCORE - 10))
fi

# 攻击频率扣分
FAILED_LOGINS_INT=$(echo "$FAILED_LOGINS" | sed 's/[^0-9]//g')
FAILED_LOGINS_INT=${FAILED_LOGINS_INT:-0}
if [ $FAILED_LOGINS_INT -gt 500 ]; then
  SCORE=$((SCORE - 20))
elif [ $FAILED_LOGINS_INT -gt 200 ]; then
  SCORE=$((SCORE - 10))
fi

# 系统错误日志扣分
DMESG_ERRORS_INT=${DMESG_ERRORS:-0}
if [ $DMESG_ERRORS_INT -gt 10 ]; then
  SCORE=$((SCORE - 15))
elif [ $DMESG_ERRORS_INT -gt 3 ]; then
  SCORE=$((SCORE - 5))
fi

# 服务异常扣分
if [ "$FAIL2BAN_STATUS" = "❌ 未运行" ]; then
  SCORE=$((SCORE - 15))
fi

if [ "$UFW_STATUS" = "❌ 未安装或未启用" ]; then
  SCORE=$((SCORE - 10))
fi

# Docker状态
if [ "$DOCKER_STATUS" = "❌ INACTIVE" ]; then
  SCORE=$((SCORE - 5))  # 如果不需要Docker，则此项不扣分
fi

# 限制最低分数
SCORE=$((SCORE < 0 ? 0 : SCORE))

# 健康度等级
if [ $SCORE -ge 90 ]; then
  HEALTH_LEVEL="🟢 极佳"
elif [ $SCORE -ge 75 ]; then
  HEALTH_LEVEL="🟡 良好"
elif [ $SCORE -ge 50 ]; then
  HEALTH_LEVEL="🟠 一般"
else
  HEALTH_LEVEL="🔴 需要关注"
fi

# ==================== 10. 生成JSON日志 ====================
cat >> "$SECURITY_LOG" <<EOF
{"timestamp":"$TIMESTAMP","date":"$DATE","cpu_usage":$CPU_USAGE,"mem_percent":$MEM_PERCENT,"swap_percent":$SWAP_PERCENT,"disk_root":$DISK_ROOT,"disk_home":$DISK_HOME,"disk_var":$DISK_VAR,"load_1min":$LOAD_1MIN,"load_5min":$LOAD_5MIN,"load_15min":$LOAD_15MIN,"failed_logins":$FAILED_LOGINS,"successful_logins":$SUCCESSFUL_LOGINS,"fail2ban_banned":$FAIL2BAN_BANNED,"fail2ban_total":$FAIL2BAN_TOTAL,"dmesg_errors":$DMESG_ERRORS,"journalctl_errors":$JOURNALCTL_ERRORS,"system_score":$SCORE,"health_level":"$HEALTH_LEVEL"}
EOF

# ==================== 11. 生成美化报告 ====================
report=$(cat <<REPORT
## 🖥️ 系统全面巡检报告 - $DATE

### $HEALTH_LEVEL 系统健康度：$SCORE/100

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### ☁️ Azure 实例信息
$(if [ -n "$AZURE_LOCATION" ] && [ "$AZURE_LOCATION" != "null" ]; then
  echo "- **位置:** $AZURE_LOCATION"
  echo "- **规格:** $AZURE_VM_SIZE"
  echo "- **资源组:** $AZURE_RESOURCE_GROUP"
else
  echo "- **状态:** 非 Azure 环境或元数据服务不可用"
fi)

### 🏗️ 系统信息
- **主机名：** $HOSTNAME
- **内核：** $KERNEL
- **运行时间：** $UPTIME
- **平均负载：** $LOAD_1MIN, $LOAD_5MIN, $LOAD_15MIN (1/5/15分钟)

### 📊 硬件资源
- **CPU：** ${CPU_USAGE}% (共 $CPU_CORES 核)
- **内存：** $MEM_USED/$MEM_TOTAL ($MEM_PERCENT%)
- **交换区：** $SWAP_USED/$SWAP_TOTAL ($SWAP_PERCENT%)
- **根分区：** ${DISK_ROOT}%
- **家目录：** ${DISK_HOME}%
- **/var分区：** ${DISK_VAR}%
- **/tmp分区：** ${DISK_TMP}%

### 🗂️ Inode 使用
- **根分区 Inode：** ${INODE_ROOT}%
- **家目录 Inode：** ${INODE_HOME}%

### 🔗 网络状态
- **活跃连接：** $ACTIVE_CONNECTIONS 个
- **SSH连接：** $SSH_CONNECTIONS 个
- **已建立连接：** $ESTABLISHED_CONNECTIONS 个

### 🏃♂️ 进程与服务
- **总进程数：** $TOTAL_PROCESSES 个
- **运行中进程：** $RUNNING_PROCESSES 个
- **系统服务：** $SYSTEMD_SERVICES 个
- **Cron服务：** $CRON_STATUS
- **SSH服务：** $SSH_STATUS
- **Docker状态：** $DOCKER_STATUS ($RUNNING_CONTAINERS/$TOTAL_CONTAINERS 运行/总计)

### 🔒 安全状态
- **失败登录：** $FAILED_LOGINS 次 (24小时内)
- **成功登录：** $SUCCESSFUL_LOGINS 次 (24小时内)
- **Fail2Ban：** $FAIL2BAN_STATUS ($FAIL2BAN_BANNED 当前封禁)
- **防火墙：** $UFW_STATUS
- **OpenClaw：** $OPENCLAW_STATUS

### 📈 系统健康指标
- **平均负载：** $LOAD_1MIN, $LOAD_5MIN, $LOAD_15MIN
- **内存使用：** $MEM_PERCENT%
- **磁盘使用：** ${DISK_ROOT}%
- **交换区使用：** $SWAP_PERCENT%
- **dmesg错误：** $DMESG_ERRORS 个 (最近50条)
- **系统错误：** $JOURNALCTL_ERRORS 个 (24小时内)
- **常见错误TOP3：**
$(echo "$COMMON_ERRORS" | while read -r line; do
  if [ -n "$line" ] && [ "$line" != "无严重错误" ]; then
    echo "  - $line"
  elif [ "$line" = "无严重错误" ]; then
    echo "  - 无严重错误"
  fi
done)
- **磁盘I/O错误：** $DISK_ERRORS 个

### 💡 建议
$(if [ $SCORE -ge 90 ]; then
  echo "系统运行状态极佳，继续保持！"
elif [ $SCORE -ge 75 ]; then
  echo "系统运行状态良好，注意监控资源使用。"
elif [ $SCORE -ge 50 ]; then
  echo "系统运行基本正常，建议关注资源使用和安全事件。"
else
  echo "系统需要关注，建议检查资源瓶颈和安全事件。"
fi)

---
巡检完成时间：$(date '+%Y-%m-%d %H:%M:%S %Z')
报告已记录到：\`memory/security-log.jsonl\`
REPORT
)

echo "$report"
echo ""
echo "🎯 系统巡检完成！"