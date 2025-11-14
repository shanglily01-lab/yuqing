#!/bin/bash
# BettaFish 环境检查脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

check_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo "=========================================="
echo "BettaFish 环境检查"
echo "=========================================="
echo

# 检查操作系统
echo "1. 操作系统检查"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    check_pass "操作系统: $PRETTY_NAME"
else
    check_fail "无法检测操作系统"
fi
echo

# 检查Python
echo "2. Python环境检查"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    check_pass "Python版本: $PYTHON_VERSION"
    
    # 检查Python版本是否>=3.9
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 9 ]; then
        check_pass "Python版本符合要求 (>=3.9)"
    else
        check_fail "Python版本过低，需要3.9或更高版本"
    fi
else
    check_fail "Python3未安装"
fi
echo

# 检查pip
echo "3. pip检查"
if command -v pip3 &> /dev/null; then
    PIP_VERSION=$(pip3 --version | cut -d' ' -f2)
    check_pass "pip版本: $PIP_VERSION"
else
    check_fail "pip3未安装"
fi
echo

# 检查Node.js
echo "4. Node.js检查"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    check_pass "Node.js版本: $NODE_VERSION"
else
    check_warn "Node.js未安装（Playwright需要）"
fi
echo

# 检查MariaDB
echo "5. MariaDB检查"
if systemctl is-active --quiet mariadb; then
    check_pass "MariaDB服务运行中"
    
    if command -v mysql &> /dev/null; then
        MYSQL_VERSION=$(mysql --version | cut -d' ' -f5 | cut -d',' -f1)
        check_pass "MySQL客户端版本: $MYSQL_VERSION"
    else
        check_warn "MySQL客户端未安装"
    fi
else
    check_fail "MariaDB服务未运行"
fi
echo

# 检查项目目录
echo "6. 项目目录检查"
PROJECT_DIR="${PROJECT_DIR:-/opt/BettaFish}"
if [ -d "$PROJECT_DIR" ]; then
    check_pass "项目目录存在: $PROJECT_DIR"
    
    # 检查虚拟环境
    if [ -d "$PROJECT_DIR/venv" ]; then
        check_pass "虚拟环境存在"
    else
        check_warn "虚拟环境不存在"
    fi
    
    # 检查.env文件
    if [ -f "$PROJECT_DIR/.env" ]; then
        check_pass ".env文件存在"
        
        # 检查关键配置
        source <(grep -E '^DB_|^.*_API_KEY=' "$PROJECT_DIR/.env" 2>/dev/null | sed 's/^/export /' || true)
        
        if [ -n "$DB_NAME" ] && [ "$DB_NAME" != "your_db_name" ]; then
            check_pass "数据库名称已配置: $DB_NAME"
        else
            check_warn "数据库名称未配置或使用默认值"
        fi
        
        if [ -n "$INSIGHT_ENGINE_API_KEY" ]; then
            check_pass "Insight Engine API密钥已配置"
        else
            check_warn "Insight Engine API密钥未配置"
        fi
    else
        check_warn ".env文件不存在"
    fi
else
    check_warn "项目目录不存在: $PROJECT_DIR"
fi
echo

# 检查端口占用
echo "7. 端口检查"
PORTS=(5000 8501 8502 8503)
for PORT in "${PORTS[@]}"; do
    if netstat -tuln 2>/dev/null | grep -q ":$PORT " || ss -tuln 2>/dev/null | grep -q ":$PORT "; then
        check_warn "端口 $PORT 已被占用"
    else
        check_pass "端口 $PORT 可用"
    fi
done
echo

# 检查磁盘空间
echo "8. 磁盘空间检查"
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    check_pass "磁盘使用率: ${DISK_USAGE}%"
elif [ "$DISK_USAGE" -lt 90 ]; then
    check_warn "磁盘使用率: ${DISK_USAGE}% (建议清理)"
else
    check_fail "磁盘使用率: ${DISK_USAGE}% (空间不足)"
fi
echo

# 检查内存
echo "9. 内存检查"
TOTAL_MEM=$(free -g | awk 'NR==2{print $2}')
AVAIL_MEM=$(free -g | awk 'NR==2{print $7}')
if [ "$TOTAL_MEM" -ge 4 ]; then
    check_pass "总内存: ${TOTAL_MEM}GB, 可用: ${AVAIL_MEM}GB"
else
    check_warn "总内存: ${TOTAL_MEM}GB (推荐4GB或更多)"
fi
echo

# 检查systemd服务
echo "10. Systemd服务检查"
if [ -f /etc/systemd/system/bettafish.service ]; then
    check_pass "bettafish.service文件存在"
    if systemctl is-active --quiet bettafish; then
        check_pass "bettafish服务运行中"
    else
        check_warn "bettafish服务未运行"
    fi
else
    check_info "bettafish.service文件不存在（可选）"
fi
echo

echo "=========================================="
echo "环境检查完成"
echo "=========================================="

