# MindSpider 配置说明

## 问题

MindSpider初始化时需要以下配置：
- `MINDSPIDER_API_KEY`
- `MINDSPIDER_BASE_URL`
- `MINDSPIDER_MODEL_NAME`

## 解决方案

### 在.env文件中添加配置

编辑 `.env` 文件，添加以下配置：

```bash
# MindSpider配置（用于爬虫系统的LLM）
MINDSPIDER_API_KEY=your_api_key_here
MINDSPIDER_BASE_URL=https://api.deepseek.com
MINDSPIDER_MODEL_NAME=deepseek-reasoner
```

### 推荐配置

**推荐使用DeepSeek（免费且功能强大）：**

1. 访问：https://www.deepseek.com/
2. 注册/登录账号
3. 进入API控制台，创建API密钥
4. 复制API密钥

**配置示例：**
```bash
MINDSPIDER_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
MINDSPIDER_BASE_URL=https://api.deepseek.com
MINDSPIDER_MODEL_NAME=deepseek-reasoner
```

### 其他可选配置

也可以使用其他兼容OpenAI格式的API：
- OpenAI: `https://api.openai.com/v1`
- Kimi: `https://api.moonshot.cn/v1`
- 其他兼容OpenAI格式的API

## 快速配置步骤

```bash
cd ~/yuqing

# 编辑.env文件
vi .env
# 或
nano .env

# 添加以下内容：
# MINDSPIDER_API_KEY=your_api_key
# MINDSPIDER_BASE_URL=https://api.deepseek.com
# MINDSPIDER_MODEL_NAME=deepseek-reasoner

# 保存后，重新运行初始化
export PYTHONPATH=$(pwd):$PYTHONPATH
cd MindSpider
python main.py --setup
```

## 注意

- 如果暂时没有API密钥，可以先跳过MindSpider的初始化
- 数据库表结构初始化可以单独运行：`python MindSpider/schema/init_database.py`
- MindSpider主要用于数据爬取，如果暂时不需要爬取功能，可以稍后配置

