# BettaFish（微舆）Amazon Linux 部署文档

## 📋 目录

1. [系统要求](#系统要求)
2. [环境准备](#环境准备)
3. [MariaDB配置](#mariadb配置)
4. [项目部署](#项目部署)
5. [配置系统](#配置系统)
6. [数据库初始化](#数据库初始化)
7. [启动服务](#启动服务)
8. [进程管理（Systemd）](#进程管理systemd)
9. [防火墙配置](#防火墙配置)
10. [验证部署](#验证部署)
11. [常见问题排查](#常见问题排查)

---

## 系统要求

### 硬件要求
- **CPU**: 2核心或以上（推荐4核心）
- **内存**: 4GB或以上（推荐8GB）
- **磁盘**: 20GB或以上可用空间
- **网络**: 稳定的互联网连接

### 软件要求
- **操作系统**: Amazon Linux 2 或 Amazon Linux 2023
- **Python**: 3.9 或更高版本（推荐 3.11）
- **MariaDB**: 10.5 或更高版本（已安装）
- **Git**: 用于克隆代码仓库

---

## 环境准备

### 1. 更新系统

```bash
# Amazon Linux 2
sudo yum update -y

# Amazon Linux 2023
sudo dnf update -y
```

### 2. 安装系统依赖

```bash
# Amazon Linux 2
sudo yum groupinstall -y "Development Tools"
sudo yum install -y python3 python3-pip python3-devel git gcc gcc-c++ make \
    openssl-devel libffi-devel zlib-devel bzip2-devel readline-devel \
    sqlite-devel xz-devel expat-devel

# Amazon Linux 2023
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y python3 python3-pip python3-devel git gcc gcc-c++ make \
    openssl-devel libffi-devel zlib-devel bzip2-devel readline-devel \
    sqlite-devel xz-devel expat-devel
```

### 3. 安装 Node.js（Playwright需要）

```bash
# 安装 Node.js 18.x
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs  # Amazon Linux 2
# 或
sudo dnf install -y nodejs  # Amazon Linux 2023

# 验证安装
node --version
npm --version
```

### 4. 创建项目用户（可选但推荐）

```bash
# 创建专用用户
sudo useradd -m -s /bin/bash bettafish
sudo passwd bettafish

# 将用户添加到sudo组（如果需要）
sudo usermod -aG wheel bettafish  # Amazon Linux 2
sudo usermod -aG sudo bettafish   # Amazon Linux 2023

# 切换到项目用户
su - bettafish
```

---

## MariaDB配置

### 1. 启动MariaDB服务

```bash
# 启动MariaDB服务
sudo systemctl start mariadb
sudo systemctl enable mariadb

# 检查服务状态
sudo systemctl status mariadb
```

### 2. 配置MariaDB

```bash
# 运行安全配置脚本（首次安装时）
sudo mysql_secure_installation
```

按照提示完成以下配置：
- 设置root密码
- 移除匿名用户（推荐：是）
- 禁止root远程登录（推荐：是）
- 移除test数据库（推荐：是）
- 重新加载权限表（推荐：是）

### 3. 创建数据库和用户

```bash
# 登录MariaDB
sudo mysql -u root -p
```

在MariaDB命令行中执行：

```sql
-- 创建数据库
CREATE DATABASE bettafish CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户（替换 'your_password' 为强密码）
CREATE USER 'bettafish'@'localhost' IDENTIFIED BY 'your_password';

-- 授予权限
GRANT ALL PRIVILEGES ON bettafish.* TO 'bettafish'@'localhost';

-- 刷新权限
FLUSH PRIVILEGES;

-- 验证用户权限
SHOW GRANTS FOR 'bettafish'@'localhost';

-- 退出
EXIT;
```

### 4. 测试数据库连接

```bash
# 测试连接
mysql -u bettafish -p -h localhost bettafish
```

如果能够成功连接，说明数据库配置正确。

### 5. 配置MariaDB以支持远程连接（可选）

如果需要从其他服务器连接数据库：

```bash
# 编辑MariaDB配置文件
sudo vi /etc/my.cnf.d/mariadb-server.cnf
```

在 `[mysqld]` 部分添加或修改：

```ini
[mysqld]
bind-address = 0.0.0.0
max_connections = 200
innodb_buffer_pool_size = 1G
```

重启MariaDB：

```bash
sudo systemctl restart mariadb
```

**注意**：如果启用远程连接，请确保配置防火墙规则，并考虑使用SSL连接。

---

## 项目部署

### 1. 克隆项目

```bash
# 切换到项目目录（例如 /opt 或用户主目录）
cd /opt  # 或 cd ~

# 克隆项目（替换为实际仓库地址）
git clone https://github.com/666ghj/BettaFish.git
# 或使用您自己的仓库地址

# 进入项目目录
cd BettaFish
```

### 2. 创建Python虚拟环境

```bash
# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 升级pip
pip install --upgrade pip setuptools wheel
```

### 3. 安装Python依赖

```bash
# 安装基础依赖
pip install -r requirements.txt

# 如果不想安装机器学习依赖（CPU占用较大），可以注释掉requirements.txt中的相关行
# 编辑 requirements.txt，注释掉以下部分：
# torch>=2.0.0
# transformers>=4.30.0
# scikit-learn>=1.3.0
# xgboost>=2.0.0
```

**注意**：如果安装过程中遇到编译错误，可能需要安装额外的开发库：

```bash
# Amazon Linux 2
sudo yum install -y mysql-devel

# Amazon Linux 2023
sudo dnf install -y mariadb-devel
```

### 4. 安装Playwright浏览器驱动

```bash
# 确保虚拟环境已激活
source venv/bin/activate

# 安装Playwright浏览器驱动
playwright install chromium

# 如果需要安装所有浏览器（不推荐，占用空间大）
# playwright install
```

---

## 配置系统

### 1. 创建.env配置文件

```bash
# 在项目根目录创建.env文件
cd /opt/BettaFish  # 或您的项目路径
cp .env.example .env  # 如果有示例文件
# 或直接创建
vi .env
```

### 2. 配置.env文件

编辑 `.env` 文件，填入以下配置：

```bash
# ====================== Flask服务器配置 ======================
HOST=0.0.0.0
PORT=5000

# ====================== 数据库配置 ======================
DB_DIALECT=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=bettafish
DB_PASSWORD=your_password_here  # 替换为实际密码
DB_NAME=bettafish
DB_CHARSET=utf8mb4

# ====================== LLM API配置 ======================
# Insight Agent（推荐Kimi）
INSIGHT_ENGINE_API_KEY=your_insight_api_key
INSIGHT_ENGINE_BASE_URL=https://api.moonshot.cn/v1
INSIGHT_ENGINE_MODEL_NAME=kimi-k2-0711-preview

# Media Agent（推荐Gemini）
MEDIA_ENGINE_API_KEY=your_media_api_key
MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro

# Query Agent（推荐DeepSeek）
QUERY_ENGINE_API_KEY=your_query_api_key
QUERY_ENGINE_BASE_URL=https://api.deepseek.com
QUERY_ENGINE_MODEL_NAME=deepseek-reasoner

# Report Agent（推荐Gemini）
REPORT_ENGINE_API_KEY=your_report_api_key
REPORT_ENGINE_BASE_URL=https://aihubmix.com/v1
REPORT_ENGINE_MODEL_NAME=gemini-2.5-pro

# Forum Host（推荐Qwen3）
FORUM_HOST_API_KEY=your_forum_api_key
FORUM_HOST_BASE_URL=https://api.siliconflow.cn/v1
FORUM_HOST_MODEL_NAME=Qwen/Qwen3-235B-A22B-Instruct-2507

# Keyword Optimizer（推荐Qwen3小模型）
KEYWORD_OPTIMIZER_API_KEY=your_keyword_api_key
KEYWORD_OPTIMIZER_BASE_URL=https://api.siliconflow.cn/v1
KEYWORD_OPTIMIZER_MODEL_NAME=Qwen/Qwen3-30B-A3B-Instruct-2507

# ====================== 搜索API配置 ======================
# Tavily API（用于QueryEngine）
TAVILY_API_KEY=your_tavily_api_key

# Bocha API（用于MediaEngine）
BOCHA_BASE_URL=https://api.bochaai.com/v1/ai-search
BOCHA_WEB_SEARCH_API_KEY=your_bocha_api_key
```

**重要提示**：
- 将所有 `your_*_api_key` 替换为实际的API密钥
- 确保数据库密码与MariaDB中创建的用户密码一致
- 如果使用不同的LLM提供商，修改对应的 `BASE_URL` 和 `MODEL_NAME`

### 3. 设置文件权限

```bash
# 确保.env文件权限安全
chmod 600 .env

# 创建必要的目录
mkdir -p logs final_reports
mkdir -p insight_engine_streamlit_reports
mkdir -p media_engine_streamlit_reports
mkdir -p query_engine_streamlit_reports

# 设置目录权限
chmod 755 logs final_reports
chmod 755 *_streamlit_reports
```

---

## 数据库初始化

### 1. 初始化MindSpider数据库

```bash
# 确保虚拟环境已激活
source venv/bin/activate

# 进入MindSpider目录
cd MindSpider

# 初始化数据库（这会创建所有必要的表）
python main.py --setup
```

如果遇到错误，可以手动运行初始化脚本：

```bash
# 进入schema目录
cd schema

# 运行初始化脚本
python init_database.py
```

### 2. 验证数据库表

```bash
# 登录MariaDB
mysql -u bettafish -p bettafish

# 查看创建的表
SHOW TABLES;

# 应该看到类似以下表：
# - daily_news
# - daily_topics
# - crawling_tasks
# - 等等...

# 退出
EXIT;
```

---

## 启动服务

### 1. 测试启动（前台运行）

```bash
# 确保虚拟环境已激活
source venv/bin/activate

# 返回项目根目录
cd /opt/BettaFish  # 或您的项目路径

# 启动Flask应用
python app.py
```

如果一切正常，您应该看到类似输出：

```
[INFO] Flask服务器已启动，访问地址: http://0.0.0.0:5000
```

### 2. 访问Web界面

在浏览器中访问：
- 本地访问：`http://localhost:5000`
- 远程访问：`http://your_server_ip:5000`

### 3. 停止服务

按 `Ctrl+C` 停止服务。

---

## 进程管理（Systemd）

为了确保服务在系统重启后自动启动，我们创建systemd服务文件。

### 1. 创建systemd服务文件

```bash
# 创建服务文件
sudo vi /etc/systemd/system/bettafish.service
```

添加以下内容（**请根据实际路径修改**）：

```ini
[Unit]
Description=BettaFish Public Opinion Analysis System
After=network.target mariadb.service
Requires=mariadb.service

[Service]
Type=simple
User=bettafish
Group=bettafish
WorkingDirectory=/opt/BettaFish
Environment="PATH=/opt/BettaFish/venv/bin:/usr/local/bin:/usr/bin:/bin"
Environment="PYTHONUNBUFFERED=1"
Environment="PYTHONIOENCODING=utf-8"
Environment="PYTHONUTF8=1"
ExecStart=/opt/BettaFish/venv/bin/python /opt/BettaFish/app.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**重要**：请将以下路径替换为您的实际路径：
- `/opt/BettaFish` → 您的项目路径
- `bettafish` → 您的运行用户

### 2. 重新加载systemd配置

```bash
sudo systemctl daemon-reload
```

### 3. 启动服务

```bash
# 启动服务
sudo systemctl start bettafish

# 设置开机自启
sudo systemctl enable bettafish

# 查看服务状态
sudo systemctl status bettafish
```

### 4. 查看日志

```bash
# 查看服务日志
sudo journalctl -u bettafish -f

# 查看最近100行日志
sudo journalctl -u bettafish -n 100

# 查看今天的日志
sudo journalctl -u bettafish --since today
```

### 5. 管理服务

```bash
# 停止服务
sudo systemctl stop bettafish

# 重启服务
sudo systemctl restart bettafish

# 禁用开机自启
sudo systemctl disable bettafish
```

---

## 防火墙配置

### 1. 配置防火墙（如果使用firewalld）

```bash
# 检查防火墙状态
sudo systemctl status firewalld

# 如果防火墙未运行，可以跳过此步骤
# 如果防火墙正在运行，添加端口规则

# 添加Flask端口（5000）
sudo firewall-cmd --permanent --add-port=5000/tcp

# 添加Streamlit端口（如果需要外部访问）
sudo firewall-cmd --permanent --add-port=8501/tcp  # InsightEngine
sudo firewall-cmd --permanent --add-port=8502/tcp  # MediaEngine
sudo firewall-cmd --permanent --add-port=8503/tcp  # QueryEngine

# 重新加载防火墙
sudo firewall-cmd --reload

# 查看开放的端口
sudo firewall-cmd --list-ports
```

### 2. 配置防火墙（如果使用iptables）

```bash
# 添加规则
sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8501 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8502 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8503 -j ACCEPT

# 保存规则（Amazon Linux 2）
sudo service iptables save

# 或使用iptables-persistent（需要先安装）
sudo yum install -y iptables-services
sudo systemctl enable iptables
sudo service iptables save
```

### 3. 配置AWS安全组（如果使用EC2）

如果您的服务器在AWS EC2上，还需要在AWS控制台配置安全组：

1. 登录AWS控制台
2. 进入EC2服务
3. 选择您的实例
4. 点击"安全"标签页
5. 点击安全组链接
6. 添加入站规则：
   - 类型：自定义TCP
   - 端口：5000（Flask主应用）
   - 源：0.0.0.0/0（或限制为特定IP）
   - 描述：BettaFish Flask App

---

## 验证部署

### 1. 检查服务状态

```bash
# 检查systemd服务
sudo systemctl status bettafish

# 检查端口监听
sudo netstat -tlnp | grep -E '5000|8501|8502|8503'
# 或使用ss命令
sudo ss -tlnp | grep -E '5000|8501|8502|8503'
```

### 2. 测试Web界面

在浏览器中访问 `http://your_server_ip:5000`，应该能看到BettaFish的主界面。

### 3. 检查日志

```bash
# 查看应用日志
tail -f logs/insight.log
tail -f logs/media.log
tail -f logs/query.log
tail -f logs/forum.log

# 查看systemd日志
sudo journalctl -u bettafish -f
```

### 4. 测试数据库连接

```bash
# 在Python中测试
source venv/bin/activate
python -c "
from config import settings
import pymysql
try:
    conn = pymysql.connect(
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        user=settings.DB_USER,
        password=settings.DB_PASSWORD,
        database=settings.DB_NAME,
        charset=settings.DB_CHARSET
    )
    print('数据库连接成功！')
    conn.close()
except Exception as e:
    print(f'数据库连接失败: {e}')
"
```

---

## 常见问题排查

### 1. 服务无法启动

**问题**：systemd服务启动失败

**排查步骤**：
```bash
# 查看详细错误信息
sudo journalctl -u bettafish -n 50

# 检查Python路径是否正确
which python
/opt/BettaFish/venv/bin/python --version

# 手动运行测试
cd /opt/BettaFish
source venv/bin/activate
python app.py
```

**常见原因**：
- 虚拟环境路径不正确
- 缺少依赖包
- 配置文件错误
- 端口被占用

### 2. 数据库连接失败

**问题**：无法连接到MariaDB

**排查步骤**：
```bash
# 检查MariaDB服务状态
sudo systemctl status mariadb

# 测试数据库连接
mysql -u bettafish -p -h localhost bettafish

# 检查数据库用户权限
sudo mysql -u root -p
SHOW GRANTS FOR 'bettafish'@'localhost';
```

**解决方案**：
- 确认数据库服务正在运行
- 检查.env文件中的数据库配置
- 确认用户权限已正确授予
- 检查防火墙是否阻止了连接

### 3. 端口被占用

**问题**：端口5000已被占用

**排查步骤**：
```bash
# 查看端口占用
sudo lsof -i :5000
# 或
sudo netstat -tlnp | grep 5000
```

**解决方案**：
```bash
# 方案1：修改配置文件中的端口
# 编辑.env文件，修改PORT=5000为其他端口，如PORT=5001

# 方案2：停止占用端口的进程
sudo kill -9 <PID>
```

### 4. Playwright浏览器驱动问题

**问题**：Playwright无法启动浏览器

**排查步骤**：
```bash
# 重新安装浏览器驱动
source venv/bin/activate
playwright install chromium

# 检查系统依赖
playwright install-deps chromium
```

### 5. 内存不足

**问题**：系统内存不足导致服务崩溃

**排查步骤**：
```bash
# 查看内存使用
free -h

# 查看进程内存占用
ps aux --sort=-%mem | head -10
```

**解决方案**：
- 增加服务器内存
- 减少并发任务
- 禁用不必要的服务
- 如果不需要情感分析，可以注释掉相关依赖

### 6. API密钥错误

**问题**：LLM API调用失败

**排查步骤**：
```bash
# 检查.env文件中的API密钥
cat .env | grep API_KEY

# 测试API连接（使用Python）
source venv/bin/activate
python -c "
from openai import OpenAI
from config import settings
client = OpenAI(
    api_key=settings.INSIGHT_ENGINE_API_KEY,
    base_url=settings.INSIGHT_ENGINE_BASE_URL
)
try:
    response = client.chat.completions.create(
        model=settings.INSIGHT_ENGINE_MODEL_NAME,
        messages=[{'role': 'user', 'content': 'test'}],
        max_tokens=10
    )
    print('API连接成功！')
except Exception as e:
    print(f'API连接失败: {e}')
"
```

### 7. 权限问题

**问题**：文件权限错误

**解决方案**：
```bash
# 确保项目目录权限正确
sudo chown -R bettafish:bettafish /opt/BettaFish
chmod -R 755 /opt/BettaFish
chmod 600 /opt/BettaFish/.env
```

### 8. 日志文件过大

**问题**：日志文件占用过多磁盘空间

**解决方案**：
```bash
# 设置日志轮转
sudo vi /etc/logrotate.d/bettafish
```

添加内容：
```
/opt/BettaFish/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 bettafish bettafish
}
```

---

## 性能优化建议

### 1. MariaDB优化

编辑 `/etc/my.cnf.d/mariadb-server.cnf`：

```ini
[mysqld]
innodb_buffer_pool_size = 1G
max_connections = 200
query_cache_size = 64M
query_cache_type = 1
```

重启MariaDB：
```bash
sudo systemctl restart mariadb
```

### 2. 系统资源限制

编辑 `/etc/security/limits.conf`：

```
bettafish soft nofile 65535
bettafish hard nofile 65535
```

### 3. 使用Nginx反向代理（可选）

如果需要使用域名访问或HTTPS，可以配置Nginx反向代理：

```bash
# 安装Nginx
sudo yum install -y nginx  # Amazon Linux 2
sudo dnf install -y nginx  # Amazon Linux 2023

# 配置Nginx
sudo vi /etc/nginx/conf.d/bettafish.conf
```

添加配置：
```nginx
server {
    listen 80;
    server_name your_domain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 备份和恢复

### 1. 数据库备份

```bash
# 创建备份脚本
vi ~/backup_bettafish.sh
```

添加内容：
```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/bettafish"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# 备份数据库
mysqldump -u bettafish -p'your_password' bettafish > $BACKUP_DIR/db_$DATE.sql

# 备份配置文件
cp /opt/BettaFish/.env $BACKUP_DIR/env_$DATE

# 压缩备份
tar -czf $BACKUP_DIR/backup_$DATE.tar.gz $BACKUP_DIR/db_$DATE.sql $BACKUP_DIR/env_$DATE

# 删除7天前的备份
find $BACKUP_DIR -name "backup_*.tar.gz" -mtime +7 -delete

echo "备份完成: $BACKUP_DIR/backup_$DATE.tar.gz"
```

设置执行权限：
```bash
chmod +x ~/backup_bettafish.sh
```

### 2. 设置定时备份

```bash
# 编辑crontab
crontab -e

# 添加每天凌晨2点备份
0 2 * * * /home/bettafish/backup_bettafish.sh >> /var/log/bettafish_backup.log 2>&1
```

---

## 更新和维护

### 1. 更新代码

```bash
cd /opt/BettaFish
source venv/bin/activate

# 停止服务
sudo systemctl stop bettafish

# 备份当前版本
cp -r . ../BettaFish_backup_$(date +%Y%m%d)

# 拉取最新代码
git pull origin main

# 更新依赖
pip install -r requirements.txt

# 检查配置文件
# 确保.env文件中的配置仍然正确

# 启动服务
sudo systemctl start bettafish
```

### 2. 查看系统资源使用

```bash
# 安装监控工具
sudo yum install -y htop  # Amazon Linux 2
sudo dnf install -y htop  # Amazon Linux 2023

# 使用htop查看资源
htop
```

---

## 联系和支持

如果遇到问题，可以：

1. 查看项目GitHub Issues：https://github.com/666ghj/BettaFish/issues
2. 查看项目文档：README.md
3. 联系项目维护者：670939375@qq.com

---

## 附录：快速部署脚本

创建一个自动化部署脚本（可选）：

```bash
#!/bin/bash
# bettafish_deploy.sh

set -e

echo "开始部署BettaFish..."

# 1. 更新系统
echo "更新系统..."
sudo yum update -y

# 2. 安装依赖
echo "安装系统依赖..."
sudo yum install -y python3 python3-pip python3-devel git gcc gcc-c++ make \
    openssl-devel libffi-devel mysql-devel

# 3. 创建项目目录
echo "创建项目目录..."
sudo mkdir -p /opt/BettaFish
sudo chown $USER:$USER /opt/BettaFish

# 4. 克隆项目（需要手动配置）
echo "请手动克隆项目到 /opt/BettaFish"

# 5. 创建虚拟环境
echo "创建虚拟环境..."
cd /opt/BettaFish
python3 -m venv venv
source venv/bin/activate

# 6. 安装Python依赖
echo "安装Python依赖..."
pip install --upgrade pip
pip install -r requirements.txt

# 7. 安装Playwright
echo "安装Playwright..."
playwright install chromium

# 8. 创建必要目录
echo "创建目录..."
mkdir -p logs final_reports
mkdir -p insight_engine_streamlit_reports
mkdir -p media_engine_streamlit_reports
mkdir -p query_engine_streamlit_reports

echo "部署完成！"
echo "请完成以下步骤："
echo "1. 配置 .env 文件"
echo "2. 初始化数据库: cd MindSpider && python main.py --setup"
echo "3. 测试启动: python app.py"
```

---

**部署完成后，您的BettaFish系统应该已经可以正常运行了！**

祝您使用愉快！🎉

