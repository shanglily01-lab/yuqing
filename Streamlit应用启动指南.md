# Streamlit应用启动指南

## 问题

502错误出现在Streamlit应用端口（8501, 8502, 8503），说明Streamlit子应用没有运行。

## 排查步骤

### 1. 检查Streamlit应用是否在运行

```bash
# 检查Streamlit进程
ps aux | grep streamlit

# 检查端口监听
sudo netstat -tlnp | grep -E "8501|8502|8503"
# 或
sudo ss -tlnp | grep -E "8501|8502|8503"
```

### 2. 检查应用日志

```bash
cd ~/yuqing
tail -50 logs/*.log
```

### 3. 检查Streamlit应用文件是否存在

```bash
cd ~/yuqing
ls -la SingleEngineApp/*.py
```

应该看到：
- `query_engine_streamlit_app.py` (8501端口)
- `media_engine_streamlit_app.py` (8502端口)
- `insight_engine_streamlit_app.py` (8503端口)

## 解决方案

### 方案1：通过Flask应用自动启动（推荐）

Flask应用应该会自动启动Streamlit子应用。检查Flask应用是否正常运行：

```bash
# 检查Flask应用
ps aux | grep "python.*app.py"

# 如果Flask应用在运行，Streamlit应该会自动启动
# 如果Flask应用没有运行，启动它：
cd ~/yuqing
source venv/bin/activate
export PYTHONPATH=$(pwd):$PYTHONPATH
python app.py
```

### 方案2：手动启动Streamlit应用

如果Flask应用无法自动启动Streamlit，可以手动启动：

```bash
cd ~/yuqing
source venv/bin/activate
export PYTHONPATH=$(pwd):$PYTHONPATH

# 启动QueryEngine (8501)
nohup streamlit run SingleEngineApp/query_engine_streamlit_app.py --server.port 8501 --server.headless true --server.address 0.0.0.0 > logs/query_engine.log 2>&1 &

# 启动MediaEngine (8502)
nohup streamlit run SingleEngineApp/media_engine_streamlit_app.py --server.port 8502 --server.headless true --server.address 0.0.0.0 > logs/media_engine.log 2>&1 &

# 启动InsightEngine (8503)
nohup streamlit run SingleEngineApp/insight_engine_streamlit_app.py --server.port 8503 --server.headless true --server.address 0.0.0.0 > logs/insight_engine.log 2>&1 &

# 检查是否启动成功
ps aux | grep streamlit
```

### 方案3：使用screen分别启动

```bash
# 安装screen（如果没有）
sudo yum install screen -y  # Amazon Linux 2
# 或
sudo dnf install screen -y  # Amazon Linux 2023

cd ~/yuqing
source venv/bin/activate
export PYTHONPATH=$(pwd):$PYTHONPATH

# 启动QueryEngine
screen -S query_engine
streamlit run SingleEngineApp/query_engine_streamlit_app.py --server.port 8501 --server.headless true --server.address 0.0.0.0
# 按 Ctrl+A 然后 D 退出

# 启动MediaEngine
screen -S media_engine
streamlit run SingleEngineApp/media_engine_streamlit_app.py --server.port 8502 --server.headless true --server.address 0.0.0.0
# 按 Ctrl+A 然后 D 退出

# 启动InsightEngine
screen -S insight_engine
streamlit run SingleEngineApp/insight_engine_streamlit_app.py --server.port 8503 --server.headless true --server.address 0.0.0.0
# 按 Ctrl+A 然后 D 退出
```

### 方案4：创建启动脚本

```bash
cd ~/yuqing
cat > start_streamlit_apps.sh << 'EOF'
#!/bin/bash

cd ~/yuqing
source venv/bin/activate
export PYTHONPATH=$(pwd):$PYTHONPATH

# 检查并杀死已存在的进程
pkill -f "streamlit.*query_engine" || true
pkill -f "streamlit.*media_engine" || true
pkill -f "streamlit.*insight_engine" || true

sleep 2

# 启动QueryEngine
echo "启动QueryEngine (8501)..."
nohup streamlit run SingleEngineApp/query_engine_streamlit_app.py \
    --server.port 8501 \
    --server.headless true \
    --server.address 0.0.0.0 \
    --browser.gatherUsageStats false \
    > logs/query_engine.log 2>&1 &

# 启动MediaEngine
echo "启动MediaEngine (8502)..."
nohup streamlit run SingleEngineApp/media_engine_streamlit_app.py \
    --server.port 8502 \
    --server.headless true \
    --server.address 0.0.0.0 \
    --browser.gatherUsageStats false \
    > logs/media_engine.log 2>&1 &

# 启动InsightEngine
echo "启动InsightEngine (8503)..."
nohup streamlit run SingleEngineApp/insight_engine_streamlit_app.py \
    --server.port 8503 \
    --server.headless true \
    --server.address 0.0.0.0 \
    --browser.gatherUsageStats false \
    > logs/insight_engine.log 2>&1 &

sleep 3

# 检查状态
echo "检查启动状态..."
ps aux | grep streamlit | grep -v grep

echo "检查端口监听..."
sudo netstat -tlnp | grep -E "8501|8502|8503" || echo "端口未监听"

echo "完成！"
EOF

chmod +x start_streamlit_apps.sh
./start_streamlit_apps.sh
```

## 检查应用状态

```bash
# 检查所有相关进程
ps aux | grep -E "streamlit|app.py"

# 检查端口
sudo netstat -tlnp | grep -E "5000|8501|8502|8503"

# 检查日志
tail -f logs/*.log
```

## 常见问题

### 问题1：端口被占用

```bash
# 查找占用端口的进程
sudo lsof -i :8501
sudo lsof -i :8502
sudo lsof -i :8503

# 杀死进程
sudo kill -9 <PID>
```

### 问题2：Streamlit应用文件不存在

```bash
cd ~/yuqing
ls -la SingleEngineApp/

# 如果文件不存在，检查git仓库
git status
git pull origin main
```

### 问题3：依赖缺失

```bash
cd ~/yuqing
source venv/bin/activate
pip install streamlit
```

### 问题4：权限问题

确保应用文件有执行权限：
```bash
chmod +x SingleEngineApp/*.py
```

## 完整启动流程

```bash
# 1. 进入项目目录
cd ~/yuqing

# 2. 激活虚拟环境
source venv/bin/activate

# 3. 设置PYTHONPATH
export PYTHONPATH=$(pwd):$PYTHONPATH

# 4. 启动Flask应用（会自动启动Streamlit）
nohup python app.py > logs/app.log 2>&1 &

# 5. 等待几秒让应用启动
sleep 5

# 6. 检查状态
ps aux | grep -E "python.*app.py|streamlit"
sudo netstat -tlnp | grep -E "5000|8501|8502|8503"
```

