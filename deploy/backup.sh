#!/bin/bash
# BettaFish 备份脚本

set -e

# 配置
BACKUP_DIR="${BACKUP_DIR:-/opt/backups/bettafish}"
PROJECT_DIR="${PROJECT_DIR:-/opt/BettaFish}"
RETENTION_DAYS=7

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 生成备份文件名
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.tar.gz"

log_info "开始备份..."

# 读取数据库配置
if [ -f "$PROJECT_DIR/.env" ]; then
    source <(grep -E '^DB_' "$PROJECT_DIR/.env" | sed 's/^/export /')
else
    log_warn ".env文件不存在，使用默认配置"
    export DB_HOST=localhost
    export DB_PORT=3306
    export DB_USER=bettafish
    export DB_PASSWORD=""
    export DB_NAME=bettafish
fi

# 创建临时备份目录
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 备份数据库
log_info "备份数据库..."
if [ -n "$DB_PASSWORD" ]; then
    mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$TEMP_DIR/database.sql"
else
    mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" "$DB_NAME" > "$TEMP_DIR/database.sql"
fi

# 备份配置文件
log_info "备份配置文件..."
if [ -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env" "$TEMP_DIR/.env"
fi

# 备份日志文件（可选）
if [ -d "$PROJECT_DIR/logs" ]; then
    log_info "备份日志文件..."
    tar -czf "$TEMP_DIR/logs.tar.gz" -C "$PROJECT_DIR" logs/
fi

# 创建压缩包
log_info "创建备份压缩包..."
tar -czf "$BACKUP_FILE" -C "$TEMP_DIR" .

# 清理旧备份
log_info "清理 $RETENTION_DAYS 天前的备份..."
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete

log_info "备份完成: $BACKUP_FILE"
log_info "备份大小: $(du -h "$BACKUP_FILE" | cut -f1)"

