# 快速修复 - asyncmy模块缺失

## 问题

缺少 `asyncmy` 模块，这是用于异步MySQL连接的Python包。

## 解决方案

### 在虚拟环境中安装asyncmy

```bash
cd ~/yuqing
source venv/bin/activate
pip install asyncmy
```

### 或者安装所有依赖

```bash
cd ~/yuqing
source venv/bin/activate
pip install -r requirements.txt
```

### 验证安装

```bash
source venv/bin/activate
python -c "import asyncmy; print('asyncmy installed successfully')"
```

## 然后重新运行初始化

```bash
cd ~/yuqing
source venv/bin/activate
export PYTHONPATH=$(pwd):$PYTHONPATH
cd MindSpider
python main.py --setup
```

