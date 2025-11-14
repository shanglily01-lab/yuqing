#!/bin/bash
# MariaDB数据库初始化脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查MariaDB服务
check_mariadb() {
    log_info "检查MariaDB服务状态..."
    if ! systemctl is-active --quiet mariadb; then
        log_warn "MariaDB服务未运行，尝试启动..."
        sudo systemctl start mariadb
        sudo systemctl enable mariadb
    fi
    log_info "MariaDB服务运行正常"
}

# 创建数据库和用户
create_database() {
    log_info "创建数据库和用户..."
    
    read -p "请输入MariaDB root密码: " -s ROOT_PASSWORD
    echo
    
    read -p "请输入要创建的数据库名称 [默认: bettafish]: " DB_NAME
    DB_NAME=${DB_NAME:-bettafish}
    
    read -p "请输入要创建的数据库用户名 [默认: bettafish]: " DB_USER
    DB_USER=${DB_USER:-bettafish}
    
    read -p "请输入数据库用户密码: " -s DB_PASSWORD
    echo
    
    # 创建数据库和用户
    mysql -u root -p"$ROOT_PASSWORD" << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    log_info "数据库和用户创建成功"
    
    # 测试连接
    log_info "测试数据库连接..."
    mysql -u "$DB_USER" -p"$DB_PASSWORD" -h localhost "$DB_NAME" -e "SELECT 1;" > /dev/null
    log_info "数据库连接测试成功"
    
    log_info "请将以下信息添加到 .env 文件："
    echo "DB_NAME=${DB_NAME}"
    echo "DB_USER=${DB_USER}"
    echo "DB_PASSWORD=${DB_PASSWORD}"
}

# 初始化数据库表
init_tables() {
    PROJECT_DIR=${1:-/opt/BettaFish}
    log_info "初始化数据库表..."
    
    # 处理相对路径
    if [ "${PROJECT_DIR:0:1}" != "/" ]; then
        PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
    fi
    
    if [ ! -d "$PROJECT_DIR" ]; then
        log_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    
    # 检查虚拟环境，如果不存在则尝试使用系统Python
    if [ ! -d "venv" ]; then
        log_warn "虚拟环境不存在，尝试使用系统Python"
        if ! command -v python3 &> /dev/null; then
            log_error "Python3未安装，请先运行安装脚本"
            exit 1
        fi
        PYTHON_CMD=python3
    else
        source venv/bin/activate
        PYTHON_CMD=python
    fi
    
    # 初始化MindSpider数据库
    # 设置PYTHONPATH，确保可以导入项目根目录的config模块
    export PYTHONPATH="$PROJECT_DIR:$PYTHONPATH"
    
    cd MindSpider
    $PYTHON_CMD main.py --setup
    
    log_info "数据库表初始化完成"
}

# 主函数
main() {
    log_info "=========================================="
    log_info "BettaFish 数据库初始化脚本"
    log_info "=========================================="
    
    check_mariadb
    
    read -p "是否创建新的数据库和用户? (y/n) [默认: y]: " CREATE_DB
    CREATE_DB=${CREATE_DB:-y}
    
    if [ "$CREATE_DB" == "y" ] || [ "$CREATE_DB" == "Y" ]; then
        create_database
    fi
    
    read -p "请输入项目路径 [默认: /opt/BettaFish]: " PROJECT_DIR
    PROJECT_DIR=${PROJECT_DIR:-/opt/BettaFish}
    
    read -p "是否初始化数据库表? (y/n) [默认: y]: " INIT_TABLES
    INIT_TABLES=${INIT_TABLES:-y}
    
    if [ "$INIT_TABLES" == "y" ] || [ "$INIT_TABLES" == "Y" ]; then
        init_tables "$PROJECT_DIR"
    fi
    
    log_info "=========================================="
    log_info "数据库初始化完成！"
    log_info "=========================================="
}

main "$@"

