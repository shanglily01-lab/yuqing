# BettaFish 快速部署指南

## 🚀 5分钟快速部署

### 前提条件
- Amazon Linux 2/2023 系统
- MariaDB 已安装并运行
- 具有sudo权限的用户
- 已获取所有API密钥

### 部署步骤

#### 1. 克隆项目
```bash
git clone https://github.com/666ghj/BettaFish.git
cd BettaFish
```

#### 2. 运行自动化安装脚本
```bash
chmod +x deploy/install.sh
./deploy/install.sh
```

脚本会自动：
- ✅ 安装系统依赖
- ✅ 安装Python和Node.js
- ✅ 创建虚拟环境
- ✅ 安装所有Python包
- ✅ 安装Playwright
- ✅ 创建必要目录
- ✅ 生成.env配置文件模板

#### 3. 配置环境变量
```bash
vi /opt/BettaFish/.env
```

**必须配置：**
- 数据库密码（DB_PASSWORD）
- 所有LLM API密钥（*_API_KEY）
- 搜索API密钥（TAVILY_API_KEY, BOCHA_WEB_SEARCH_API_KEY）

#### 4. 初始化数据库
```bash
chmod +x deploy/setup_database.sh
./deploy/setup_database.sh
```

#### 5. 配置并启动服务
```bash
# 复制服务文件
sudo cp deploy/bettafish.service /etc/systemd/system/

# 编辑服务文件（修改路径和用户）
sudo vi /etc/systemd/system/bettafish.service

# 重新加载并启动
sudo systemctl daemon-reload
sudo systemctl start bettafish
sudo systemctl enable bettafish

# 查看状态
sudo systemctl status bettafish
```

#### 6. 访问系统
打开浏览器访问：`http://your_server_ip:5000`

---

## 📋 详细步骤说明

### 步骤1：系统准备

确保MariaDB已安装并运行：
```bash
sudo systemctl status mariadb
```

如果没有安装，请先安装MariaDB。

### 步骤2：运行安装脚本

安装脚本会询问：
- 项目安装路径（默认：/opt/BettaFish）
- Git仓库地址（默认：官方仓库）

按提示操作即可。

### 步骤3：配置.env文件

编辑.env文件，填入以下信息：

```bash
# 数据库配置
DB_PASSWORD=your_actual_password

# LLM API密钥（至少配置一个）
INSIGHT_ENGINE_API_KEY=your_key
MEDIA_ENGINE_API_KEY=your_key
QUERY_ENGINE_API_KEY=your_key
REPORT_ENGINE_API_KEY=your_key
FORUM_HOST_API_KEY=your_key
KEYWORD_OPTIMIZER_API_KEY=your_key

# 搜索API密钥
TAVILY_API_KEY=your_key
BOCHA_WEB_SEARCH_API_KEY=your_key
```

### 步骤4：数据库初始化

运行数据库初始化脚本，会：
1. 创建数据库（如果不存在）
2. 创建数据库用户
3. 初始化表结构

### 步骤5：配置Systemd服务

编辑服务文件，修改：
- `User`: 您的用户名
- `WorkingDirectory`: 项目路径（默认/opt/BettaFish）
- `ExecStart`: Python路径（默认/opt/BettaFish/venv/bin/python）

### 步骤6：防火墙配置

如果使用firewalld：
```bash
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

如果使用AWS EC2，在安全组中开放端口5000。

---

## ✅ 验证部署

### 检查服务状态
```bash
sudo systemctl status bettafish
```

### 查看日志
```bash
# Systemd日志
sudo journalctl -u bettafish -f

# 应用日志
tail -f /opt/BettaFish/logs/*.log
```

### 运行环境检查
```bash
chmod +x deploy/check_environment.sh
./deploy/check_environment.sh
```

---

## 🔧 常用命令

### 服务管理
```bash
# 启动服务
sudo systemctl start bettafish

# 停止服务
sudo systemctl stop bettafish

# 重启服务
sudo systemctl restart bettafish

# 查看状态
sudo systemctl status bettafish

# 查看日志
sudo journalctl -u bettafish -f
```

### 备份和恢复
```bash
# 备份
./deploy/backup.sh

# 恢复
./deploy/restore.sh /path/to/backup_file.tar.gz
```

### 更新系统
```bash
cd /opt/BettaFish
source venv/bin/activate
sudo systemctl stop bettafish
git pull
pip install -r requirements.txt
sudo systemctl start bettafish
```

---

## ❓ 遇到问题？

1. **查看日志**：`sudo journalctl -u bettafish -n 100`
2. **运行环境检查**：`./deploy/check_environment.sh`
3. **查看部署文档**：`Amazon-Linux部署文档.md`
4. **查看常见问题**：`deploy/README.md`

---

## 📚 下一步

- 阅读完整部署文档：`Amazon-Linux部署文档.md`
- 了解项目结构：`项目结构分析.md`
- 配置定时备份
- 配置Nginx反向代理（可选）
- 配置HTTPS（可选）

---

**部署完成后，开始使用BettaFish进行舆情分析吧！** 🎉

