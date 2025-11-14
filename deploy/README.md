# BettaFish 部署脚本说明

本目录包含BettaFish系统的自动化部署脚本和配置文件。

## 📁 文件说明

### 1. `install.sh` - 自动化安装脚本
一键安装BettaFish系统所需的所有依赖和组件。

**使用方法：**
```bash
chmod +x deploy/install.sh
./deploy/install.sh
```

**功能：**
- 检测操作系统
- 更新系统包
- 安装系统依赖（Python、Node.js、开发工具等）
- 克隆项目代码
- 创建Python虚拟环境
- 安装Python依赖包
- 安装Playwright浏览器驱动
- 创建必要目录
- 生成.env配置文件模板

### 2. `bettafish.service` - Systemd服务文件
用于将BettaFish配置为系统服务，支持开机自启和自动重启。

**使用方法：**
```bash
# 1. 编辑服务文件，修改路径和用户
sudo vi deploy/bettafish.service

# 2. 复制到systemd目录
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

**需要修改的配置：**
- `User`: 运行服务的用户
- `Group`: 运行服务的用户组
- `WorkingDirectory`: 项目根目录路径
- `ExecStart`: Python解释器和app.py的完整路径

### 3. `setup_database.sh` - 数据库初始化脚本
自动创建MariaDB数据库、用户和初始化表结构。

**使用方法：**
```bash
chmod +x deploy/setup_database.sh
./deploy/setup_database.sh
```

**功能：**
- 检查MariaDB服务状态
- 创建数据库和用户
- 授予权限
- 初始化数据库表结构
- 测试数据库连接

### 4. `backup.sh` - 备份脚本
备份数据库、配置文件和日志。

**使用方法：**
```bash
chmod +x deploy/backup.sh

# 使用默认配置
./deploy/backup.sh

# 或指定配置
BACKUP_DIR=/path/to/backup PROJECT_DIR=/opt/BettaFish ./deploy/backup.sh
```

**功能：**
- 备份数据库（mysqldump）
- 备份.env配置文件
- 备份日志文件（可选）
- 自动清理旧备份（默认保留7天）

**配置crontab定时备份：**
```bash
# 每天凌晨2点备份
0 2 * * * /path/to/deploy/backup.sh >> /var/log/bettafish_backup.log 2>&1
```

### 5. `restore.sh` - 恢复脚本
从备份文件恢复系统。

**使用方法：**
```bash
chmod +x deploy/restore.sh
./deploy/restore.sh /path/to/backup_file.tar.gz
```

**功能：**
- 恢复数据库
- 恢复配置文件（可选）
- 恢复日志文件（可选）

**注意：** 恢复操作会覆盖现有数据，请谨慎使用！

### 6. `check_environment.sh` - 环境检查脚本
检查系统环境是否符合部署要求。

**使用方法：**
```bash
chmod +x deploy/check_environment.sh
./deploy/check_environment.sh
```

**检查项目：**
- 操作系统版本
- Python版本和pip
- Node.js版本
- MariaDB服务状态
- 项目目录和文件
- 端口占用情况
- 磁盘空间
- 内存大小
- Systemd服务状态

## 🚀 快速部署流程

### 方式一：使用自动化脚本（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/666ghj/BettaFish.git
cd BettaFish

# 2. 运行安装脚本
chmod +x deploy/install.sh
./deploy/install.sh

# 3. 配置.env文件
vi /opt/BettaFish/.env
# 填入数据库密码和API密钥

# 4. 初始化数据库
chmod +x deploy/setup_database.sh
./deploy/setup_database.sh

# 5. 配置systemd服务
sudo cp deploy/bettafish.service /etc/systemd/system/
sudo vi /etc/systemd/system/bettafish.service  # 修改路径和用户
sudo systemctl daemon-reload
sudo systemctl start bettafish
sudo systemctl enable bettafish

# 6. 检查服务状态
sudo systemctl status bettafish
```

### 方式二：手动部署

参考 `Amazon-Linux部署文档.md` 进行手动部署。

## 📝 配置说明

### .env文件配置

安装脚本会自动生成.env文件模板，您需要编辑并填入实际配置：

```bash
vi /opt/BettaFish/.env
```

**必须配置的项目：**
1. 数据库配置（DB_*）
2. LLM API密钥（*_API_KEY）
3. 搜索API密钥（TAVILY_API_KEY, BOCHA_WEB_SEARCH_API_KEY）

### Systemd服务配置

编辑 `bettafish.service` 文件，修改以下内容：

```ini
User=your_username          # 运行服务的用户
Group=your_group            # 运行服务的用户组
WorkingDirectory=/opt/BettaFish  # 项目路径
ExecStart=/opt/BettaFish/venv/bin/python /opt/BettaFish/app.py  # Python路径
```

## 🔧 常见问题

### 1. 安装脚本执行失败

**问题：** 权限不足
**解决：** 确保用户有sudo权限，脚本会在需要时请求sudo

**问题：** 网络连接问题
**解决：** 检查网络连接，确保可以访问GitHub和PyPI

### 2. 数据库初始化失败

**问题：** 无法连接数据库
**解决：** 
- 检查MariaDB服务是否运行：`sudo systemctl status mariadb`
- 检查数据库用户和密码是否正确
- 检查防火墙设置

### 3. 服务无法启动

**问题：** systemd服务启动失败
**解决：**
- 检查服务文件路径是否正确
- 查看日志：`sudo journalctl -u bettafish -n 50`
- 检查.env文件配置是否正确

### 4. 端口被占用

**问题：** 端口5000已被占用
**解决：**
- 查找占用进程：`sudo lsof -i :5000`
- 修改.env文件中的PORT配置
- 或停止占用端口的进程

## 📚 相关文档

- [Amazon Linux部署文档](../Amazon-Linux部署文档.md)
- [项目结构分析](../项目结构分析.md)
- [项目README](../README.md)

## 🔐 安全建议

1. **文件权限：** 确保.env文件权限为600
   ```bash
   chmod 600 /opt/BettaFish/.env
   ```

2. **数据库安全：** 
   - 使用强密码
   - 限制数据库用户权限
   - 考虑使用SSL连接

3. **防火墙：** 
   - 只开放必要的端口
   - 限制访问来源IP

4. **定期备份：** 
   - 设置定时备份任务
   - 测试备份恢复流程

## 📞 获取帮助

如果遇到问题，可以：
1. 查看项目GitHub Issues
2. 查看部署文档
3. 运行环境检查脚本诊断问题
4. 联系项目维护者

---

**祝您部署顺利！** 🎉

