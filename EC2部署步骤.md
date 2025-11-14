# BettaFish EC2 部署步骤

## 📋 前置条件检查

确保您已经：
- ✅ 克隆了仓库到EC2服务器
- ✅ 已安装MariaDB并运行
- ✅ 有sudo权限

## 🚀 快速部署步骤

### 步骤1：进入项目目录

```bash
cd yuqing
```

### 步骤2：运行自动化安装脚本（推荐）

```bash
# 给脚本添加执行权限
chmod +x deploy/install.sh

# 运行安装脚本
./deploy/install.sh
```

脚本会自动：
- 安装系统依赖
- 创建Python虚拟环境
- 安装Python依赖包
- 安装Playwright浏览器驱动
- 创建必要目录
- 生成.env配置文件模板

### 步骤3：配置环境变量

```bash
# 编辑.env文件
vi .env
# 或使用nano编辑器
nano .env
```

**必须配置以下内容：**

```bash
# 数据库配置（根据您的MariaDB实际情况修改）
DB_DIALECT=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=bettafish
DB_PASSWORD=your_actual_password  # 替换为实际密码
DB_NAME=bettafish
DB_CHARSET=utf8mb4

# LLM API密钥（必须配置至少一个）
INSIGHT_ENGINE_API_KEY=your_api_key
MEDIA_ENGINE_API_KEY=your_api_key
QUERY_ENGINE_API_KEY=your_api_key
REPORT_ENGINE_API_KEY=your_api_key
FORUM_HOST_API_KEY=your_api_key
KEYWORD_OPTIMIZER_API_KEY=your_api_key

# 搜索API密钥
TAVILY_API_KEY=your_api_key
BOCHA_WEB_SEARCH_API_KEY=your_api_key
```

### 步骤4：初始化数据库

```bash
# 给脚本添加执行权限
chmod +x deploy/setup_database.sh

# 运行数据库初始化脚本
./deploy/setup_database.sh
```

脚本会：
- 检查MariaDB服务
- 创建数据库和用户（如果需要）
- 初始化数据库表结构

**或者手动初始化：**

```bash
# 进入MindSpider目录
cd MindSpider

# 初始化数据库
python3 main.py --setup

# 返回项目根目录
cd ..
```

### 步骤5：测试启动（验证配置）

```bash
# 激活虚拟环境
source venv/bin/activate

# 测试启动（前台运行，用于检查错误）
python app.py
```

如果看到类似以下输出，说明配置正确：
```
[INFO] Flask服务器已启动，访问地址: http://0.0.0.0:5000
```

按 `Ctrl+C` 停止测试。

### 步骤6：配置Systemd服务（开机自启）

```bash
# 1. 编辑服务文件（修改路径和用户）
sudo vi deploy/bettafish.service
# 或
sudo nano deploy/bettafish.service
```

**修改以下内容：**
- `User=ec2-user` （改为您的用户名）
- `Group=ec2-user` （改为您的用户组）
- `WorkingDirectory=/home/ec2-user/yuqing` （改为实际项目路径）
- `ExecStart=/home/ec2-user/yuqing/venv/bin/python /home/ec2-user/yuqing/app.py` （改为实际路径）

```bash
# 2. 复制服务文件到systemd目录
sudo cp deploy/bettafish.service /etc/systemd/system/

# 3. 重新加载systemd
sudo systemctl daemon-reload

# 4. 启动服务
sudo systemctl start bettafish

# 5. 设置开机自启
sudo systemctl enable bettafish

# 6. 查看服务状态
sudo systemctl status bettafish
```

### 步骤7：配置防火墙

```bash
# 如果使用firewalld
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# 如果使用iptables
sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT
sudo service iptables save
```

### 步骤8：配置AWS安全组

在AWS控制台：
1. 进入EC2服务
2. 选择您的实例
3. 点击"安全"标签页
4. 点击安全组链接
5. 添加入站规则：
   - 类型：自定义TCP
   - 端口：5000
   - 源：0.0.0.0/0（或限制为特定IP）
   - 描述：BettaFish Flask App

### 步骤9：访问系统

在浏览器中访问：
```
http://your_ec2_public_ip:5000
```

## 🔍 验证部署

### 检查服务状态

```bash
# 查看服务状态
sudo systemctl status bettafish

# 查看服务日志
sudo journalctl -u bettafish -f

# 查看应用日志
tail -f logs/*.log
```

### 检查端口监听

```bash
sudo netstat -tlnp | grep 5000
# 或
sudo ss -tlnp | grep 5000
```

### 运行环境检查脚本

```bash
chmod +x deploy/check_environment.sh
./deploy/check_environment.sh
```

## 🛠️ 常用管理命令

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
sudo journalctl -u bettafish -n 100
```

### 查看日志

```bash
# 实时查看应用日志
tail -f logs/insight.log
tail -f logs/media.log
tail -f logs/query.log
tail -f logs/forum.log

# 查看systemd日志
sudo journalctl -u bettafish -f
```

## ❓ 常见问题

### 1. 服务启动失败

```bash
# 查看详细错误
sudo journalctl -u bettafish -n 50

# 检查配置文件
cat .env | grep -E "DB_|API_KEY"

# 手动测试
source venv/bin/activate
python app.py
```

### 2. 数据库连接失败

```bash
# 检查MariaDB服务
sudo systemctl status mariadb

# 测试数据库连接
mysql -u bettafish -p -h localhost bettafish

# 检查.env文件中的数据库配置
cat .env | grep DB_
```

### 3. 端口被占用

```bash
# 查看端口占用
sudo lsof -i :5000

# 修改.env文件中的PORT配置
vi .env
# 修改 PORT=5000 为其他端口，如 PORT=5001
```

### 4. API密钥错误

检查.env文件中的所有API密钥是否已正确配置。

## 📝 后续操作

1. **配置定时备份**（可选）
   ```bash
   chmod +x deploy/backup.sh
   # 添加到crontab
   crontab -e
   # 添加：0 2 * * * /home/ec2-user/yuqing/deploy/backup.sh
   ```

2. **配置Nginx反向代理**（可选，用于域名访问）

3. **配置HTTPS**（可选，使用Let's Encrypt）

## 📚 相关文档

- 详细部署文档：`Amazon-Linux部署文档.md`
- 部署脚本说明：`deploy/README.md`
- 快速开始指南：`deploy/QUICKSTART.md`

---

**部署完成后，访问 http://your_ec2_ip:5000 开始使用BettaFish！** 🎉

