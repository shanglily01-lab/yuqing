#!/bin/bash
# BettaFish 恢复脚本

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

# 检查备份文件
if [ -z "$1" ]; then
    log_error "请指定备份文件路径"
    echo "用法: $0 <backup_file.tar.gz>"
    exit 1
fi

BACKUP_FILE="$1"
PROJECT_DIR="${PROJECT_DIR:-/opt/BettaFish}"

if [ ! -f "$BACKUP_FILE" ]; then
    log_error "备份文件不存在: $BACKUP_FILE"
    exit 1
fi

log_warn "此操作将覆盖现有数据！"
read -p "确认继续? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log_info "已取消恢复操作"
    exit 0
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 解压备份文件
log_info "解压备份文件..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# 读取数据库配置
if [ -f "$PROJECT_DIR/.env" ]; then
    source <(grep -E '^DB_' "$PROJECT_DIR/.env" | sed 's/^/export /')
else
    log_error ".env文件不存在，无法恢复数据库"
    exit 1
fi

# 恢复数据库
if [ -f "$TEMP_DIR/database.sql" ]; then
    log_info "恢复数据库..."
    if [ -n "$DB_PASSWORD" ]; then
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$TEMP_DIR/database.sql"
    else
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" "$DB_NAME" < "$TEMP_DIR/database.sql"
    fi
    log_info "数据库恢复完成"
fi

# 恢复配置文件（可选）
if [ -f "$TEMP_DIR/.env" ]; then
    log_warn "发现.env备份文件"
    read -p "是否恢复.env文件? (y/n): " RESTORE_ENV
    if [ "$RESTORE_ENV" == "y" ] || [ "$RESTORE_ENV" == "Y" ]; then
        cp "$TEMP_DIR/.env" "$PROJECT_DIR/.env.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$TEMP_DIR/.env" "$PROJECT_DIR/.env"
        log_info ".env文件已恢复"
    fi
fi

# 恢复日志文件（可选）
if [ -f "$TEMP_DIR/logs.tar.gz" ]; then
    log_warn "发现日志备份文件"
    read -p "是否恢复日志文件? (y/n): " RESTORE_LOGS
    if [ "$RESTORE_LOGS" == "y" ] || [ "$RESTORE_LOGS" == "Y" ]; then
        tar -xzf "$TEMP_DIR/logs.tar.gz" -C "$PROJECT_DIR"
        log_info "日志文件已恢复"
    fi
fi

log_info "恢复完成！"

