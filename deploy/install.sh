#!/bin/bash
# BettaFish 自动化安装脚本
# 适用于 Amazon Linux 2/2023

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        log_error "请不要使用root用户运行此脚本"
        log_info "请使用普通用户运行，脚本会在需要时请求sudo权限"
        exit 1
    fi
}

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        log_info "检测到操作系统: $OS $OS_VERSION"
    else
        log_error "无法检测操作系统"
        exit 1
    fi
}

# 更新系统
update_system() {
    log_info "更新系统包..."
    if [ "$OS" == "amzn" ]; then
        if [ "$OS_VERSION" == "2" ]; then
            sudo yum update -y
        else
            sudo dnf update -y
        fi
    fi
}

# 安装系统依赖
install_system_dependencies() {
    log_info "安装系统依赖..."
    if [ "$OS" == "amzn" ] && [ "$OS_VERSION" == "2" ]; then
        sudo yum groupinstall -y "Development Tools" || true
        sudo yum install -y python3 python3-pip python3-devel git gcc gcc-c++ make \
            openssl-devel libffi-devel zlib-devel bzip2-devel readline-devel \
            sqlite-devel xz-devel expat-devel mariadb-devel
    else
        sudo dnf groupinstall -y "Development Tools" || true
        sudo dnf install -y python3 python3-pip python3-devel git gcc gcc-c++ make \
            openssl-devel libffi-devel zlib-devel bzip2-devel readline-devel \
            sqlite-devel xz-devel expat-devel mariadb-devel
    fi
}

# 安装Node.js
install_nodejs() {
    log_info "检查Node.js..."
    if ! command -v node &> /dev/null; then
        log_info "安装Node.js..."
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        if [ "$OS" == "amzn" ] && [ "$OS_VERSION" == "2" ]; then
            sudo yum install -y nodejs
        else
            sudo dnf install -y nodejs
        fi
    else
        log_info "Node.js已安装: $(node --version)"
    fi
}

# 创建项目目录
create_project_directory() {
    PROJECT_DIR=${1:-/opt/BettaFish}
    log_info "创建项目目录: $PROJECT_DIR"
    
    if [ ! -d "$PROJECT_DIR" ]; then
        sudo mkdir -p "$PROJECT_DIR"
        sudo chown $USER:$USER "$PROJECT_DIR"
    else
        log_warn "目录已存在: $PROJECT_DIR"
    fi
}

# 克隆项目
clone_project() {
    PROJECT_DIR=${1:-/opt/BettaFish}
    REPO_URL=${2:-"https://github.com/666ghj/BettaFish.git"}
    
    if [ -d "$PROJECT_DIR/.git" ]; then
        log_warn "项目已存在，跳过克隆"
        return
    fi
    
    log_info "克隆项目到: $PROJECT_DIR"
    git clone "$REPO_URL" "$PROJECT_DIR" || {
        log_error "克隆失败，请检查网络连接和仓库地址"
        exit 1
    }
}

# 创建Python虚拟环境
create_venv() {
    PROJECT_DIR=${1:-/opt/BettaFish}
    log_info "创建Python虚拟环境..."
    
    cd "$PROJECT_DIR"
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        log_info "虚拟环境创建成功"
    else
        log_warn "虚拟环境已存在"
    fi
}

# 安装Python依赖
install_python_dependencies() {
    PROJECT_DIR=${1:-/opt/BettaFish}
    log_info "安装Python依赖..."
    
    cd "$PROJECT_DIR"
    source venv/bin/activate
    
    pip install --upgrade pip setuptools wheel
    pip install -r requirements.txt
    
    log_info "Python依赖安装完成"
}

# 安装Playwright
install_playwright() {
    PROJECT_DIR=${1:-/opt/BettaFish}
    log_info "安装Playwright浏览器驱动..."
    
    cd "$PROJECT_DIR"
    source venv/bin/activate
    
    playwright install chromium
    log_info "Playwright安装完成"
}

# 创建必要目录
create_directories() {
    PROJECT_DIR=${1:-/opt/BettaFish}
    log_info "创建必要目录..."
    
    cd "$PROJECT_DIR"
    mkdir -p logs final_reports
    mkdir -p insight_engine_streamlit_reports
    mkdir -p media_engine_streamlit_reports
    mkdir -p query_engine_streamlit_reports
    
    log_info "目录创建完成"
}

# 配置.env文件
setup_env_file() {
    PROJECT_DIR=${1:-/opt/BettaFish}
    log_info "配置.env文件..."
    
    cd "$PROJECT_DIR"
    
    if [ ! -f ".env" ]; then
        log_info "创建.env文件模板..."
        cat > .env << 'EOF'
# ====================== Flask服务器配置 ======================
HOST=0.0.0.0
PORT=5000

# ====================== 数据库配置 ======================
DB_DIALECT=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=bettafish
DB_PASSWORD=your_db_password
DB_NAME=bettafish
DB_CHARSET=utf8mb4

# ====================== LLM API配置 ======================
INSIGHT_ENGINE_API_KEY=
INSIGHT_ENGINE_BASE_URL=https://api.moonshot.cn/v1
INSIGHT_ENGINE_MODEL_NAME=kimi-k2-0711-preview

MEDIA_ENGINE_API_KEY=
MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro

QUERY_ENGINE_API_KEY=
QUERY_ENGINE_BASE_URL=https://api.deepseek.com
QUERY_ENGINE_MODEL_NAME=deepseek-reasoner

REPORT_ENGINE_API_KEY=
REPORT_ENGINE_BASE_URL=https://aihubmix.com/v1
REPORT_ENGINE_MODEL_NAME=gemini-2.5-pro

FORUM_HOST_API_KEY=
FORUM_HOST_BASE_URL=https://api.siliconflow.cn/v1
FORUM_HOST_MODEL_NAME=Qwen/Qwen3-235B-A22B-Instruct-2507

KEYWORD_OPTIMIZER_API_KEY=
KEYWORD_OPTIMIZER_BASE_URL=https://api.siliconflow.cn/v1
KEYWORD_OPTIMIZER_MODEL_NAME=Qwen/Qwen3-30B-A3B-Instruct-2507

# ====================== 搜索API配置 ======================
TAVILY_API_KEY=
BOCHA_BASE_URL=https://api.bochaai.com/v1/ai-search
BOCHA_WEB_SEARCH_API_KEY=
EOF
        chmod 600 .env
        log_warn "请编辑 .env 文件，填入实际的配置信息"
    else
        log_warn ".env文件已存在，跳过创建"
    fi
}

# 主函数
main() {
    log_info "=========================================="
    log_info "BettaFish 自动化安装脚本"
    log_info "=========================================="
    
    # 检查root用户
    check_root
    
    # 检测操作系统
    detect_os
    
    # 读取配置
    read -p "请输入项目安装路径 [默认: /opt/BettaFish]: " PROJECT_DIR
    PROJECT_DIR=${PROJECT_DIR:-/opt/BettaFish}
    
    read -p "请输入Git仓库地址 [默认: https://github.com/666ghj/BettaFish.git]: " REPO_URL
    REPO_URL=${REPO_URL:-"https://github.com/666ghj/BettaFish.git"}
    
    # 执行安装步骤
    update_system
    install_system_dependencies
    install_nodejs
    create_project_directory "$PROJECT_DIR"
    clone_project "$PROJECT_DIR" "$REPO_URL"
    create_venv "$PROJECT_DIR"
    install_python_dependencies "$PROJECT_DIR"
    install_playwright "$PROJECT_DIR"
    create_directories "$PROJECT_DIR"
    setup_env_file "$PROJECT_DIR"
    
    log_info "=========================================="
    log_info "安装完成！"
    log_info "=========================================="
    log_info "下一步操作："
    log_info "1. 编辑配置文件: vi $PROJECT_DIR/.env"
    log_info "2. 配置MariaDB数据库（参考部署文档）"
    log_info "3. 初始化数据库: cd $PROJECT_DIR/MindSpider && python main.py --setup"
    log_info "4. 测试启动: cd $PROJECT_DIR && source venv/bin/activate && python app.py"
    log_info "5. 配置systemd服务（参考部署文档）"
}

# 运行主函数
main "$@"

