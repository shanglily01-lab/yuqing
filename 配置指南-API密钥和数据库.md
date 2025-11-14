# BettaFish 配置指南 - API密钥和数据库配置

## 📝 配置文件位置

配置文件是项目根目录下的 `.env` 文件：

```bash
cd yuqing
vi .env
# 或
nano .env
```

---

## 1️⃣ 数据库配置

### 1.1 创建数据库和用户

首先需要在MariaDB中创建数据库和用户：

```bash
# 登录MariaDB（使用root用户）
sudo mysql -u root -p

# 在MariaDB命令行中执行：
CREATE DATABASE bettafish CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'bettafish'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON bettafish.* TO 'bettafish'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 1.2 在.env文件中配置

```bash
DB_DIALECT=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=bettafish
DB_PASSWORD=your_strong_password  # 替换为上面设置的密码
DB_NAME=bettafish
DB_CHARSET=utf8mb4
```

**或者使用自动化脚本：**
```bash
chmod +x deploy/setup_database.sh
./deploy/setup_database.sh
```

---

## 2️⃣ LLM API密钥配置

### 2.1 Insight Engine API（推荐：Kimi）

**用途：** 私有数据库深度分析

**获取方式：**
1. 访问：https://platform.moonshot.cn/
2. 注册/登录账号
3. 进入控制台，创建API密钥
4. 复制API密钥

**配置：**
```bash
INSIGHT_ENGINE_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
INSIGHT_ENGINE_BASE_URL=https://api.moonshot.cn/v1
INSIGHT_ENGINE_MODEL_NAME=kimi-k2-0711-preview
```

**其他可选提供商：**
- OpenAI: `https://api.openai.com/v1`
- DeepSeek: `https://api.deepseek.com`
- 其他兼容OpenAI格式的API

---

### 2.2 Media Engine API（推荐：Gemini）

**用途：** 多模态内容分析（图片、视频）

**获取方式（通过中转服务）：**
1. 访问：https://aihubmix.com/?aff=8Ds9
2. 注册账号并充值
3. 获取API密钥

**配置：**
```bash
MEDIA_ENGINE_API_KEY=your_api_key_here
MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro
```

**其他可选提供商：**
- 直接使用Google Gemini API（需要科学上网）
- 其他支持多模态的API服务

---

### 2.3 Query Engine API（推荐：DeepSeek）

**用途：** 国内外新闻搜索

**获取方式：**
1. 访问：https://www.deepseek.com/
2. 注册/登录账号
3. 进入API控制台，创建API密钥
4. 复制API密钥

**配置：**
```bash
QUERY_ENGINE_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
QUERY_ENGINE_BASE_URL=https://api.deepseek.com
QUERY_ENGINE_MODEL_NAME=deepseek-reasoner
```

**其他可选提供商：**
- OpenAI GPT-4
- Anthropic Claude
- 其他兼容OpenAI格式的API

---

### 2.4 Report Engine API（推荐：Gemini）

**用途：** 智能报告生成

**获取方式：**
与Media Engine相同，可以使用同一个API密钥

**配置：**
```bash
REPORT_ENGINE_API_KEY=your_api_key_here
REPORT_ENGINE_BASE_URL=https://aihubmix.com/v1
REPORT_ENGINE_MODEL_NAME=gemini-2.5-pro
```

---

### 2.5 Forum Host API（推荐：Qwen3）

**用途：** 论坛协调和讨论总结

**获取方式：**
1. 访问：https://cloud.siliconflow.cn/
2. 注册/登录账号
3. 创建API密钥
4. 复制API密钥

**配置：**
```bash
FORUM_HOST_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
FORUM_HOST_BASE_URL=https://api.siliconflow.cn/v1
FORUM_HOST_MODEL_NAME=Qwen/Qwen3-235B-A22B-Instruct-2507
```

---

### 2.6 Keyword Optimizer API（推荐：Qwen3小模型）

**用途：** SQL关键词优化

**获取方式：**
与Forum Host相同，可以使用同一个API密钥

**配置：**
```bash
KEYWORD_OPTIMIZER_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
KEYWORD_OPTIMIZER_BASE_URL=https://api.siliconflow.cn/v1
KEYWORD_OPTIMIZER_MODEL_NAME=Qwen/Qwen3-30B-A3B-Instruct-2507
```

---

## 3️⃣ 搜索API密钥配置

### 3.1 Tavily API

**用途：** QueryEngine进行新闻搜索

**获取方式：**
1. 访问：https://www.tavily.com/
2. 注册账号（有免费额度）
3. 进入Dashboard，获取API密钥
4. 复制API密钥

**配置：**
```bash
TAVILY_API_KEY=tvly-xxxxxxxxxxxxxxxxxxxxx
```

**免费额度：** 通常每月有免费调用次数

---

### 3.2 Bocha API

**用途：** MediaEngine进行多模态搜索

**获取方式：**
1. 访问：https://open.bochaai.com/
2. 注册账号
3. 创建API密钥
4. 复制API密钥

**配置：**
```bash
BOCHA_BASE_URL=https://api.bochaai.com/v1/ai-search
BOCHA_WEB_SEARCH_API_KEY=your_api_key_here
```

---

## 📋 完整配置示例

以下是 `.env` 文件的完整配置示例：

```bash
# ====================== Flask服务器配置 ======================
HOST=0.0.0.0
PORT=5000

# ====================== 数据库配置 ======================
DB_DIALECT=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=bettafish
DB_PASSWORD=your_strong_password_here
DB_NAME=bettafish
DB_CHARSET=utf8mb4

# ====================== LLM API配置 ======================
# Insight Agent（Kimi）
INSIGHT_ENGINE_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
INSIGHT_ENGINE_BASE_URL=https://api.moonshot.cn/v1
INSIGHT_ENGINE_MODEL_NAME=kimi-k2-0711-preview

# Media Agent（Gemini）
MEDIA_ENGINE_API_KEY=your_gemini_api_key_here
MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro

# Query Agent（DeepSeek）
QUERY_ENGINE_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
QUERY_ENGINE_BASE_URL=https://api.deepseek.com
QUERY_ENGINE_MODEL_NAME=deepseek-reasoner

# Report Agent（Gemini）
REPORT_ENGINE_API_KEY=your_gemini_api_key_here
REPORT_ENGINE_BASE_URL=https://aihubmix.com/v1
REPORT_ENGINE_MODEL_NAME=gemini-2.5-pro

# Forum Host（Qwen3）
FORUM_HOST_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
FORUM_HOST_BASE_URL=https://api.siliconflow.cn/v1
FORUM_HOST_MODEL_NAME=Qwen/Qwen3-235B-A22B-Instruct-2507

# Keyword Optimizer（Qwen3小模型）
KEYWORD_OPTIMIZER_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
KEYWORD_OPTIMIZER_BASE_URL=https://api.siliconflow.cn/v1
KEYWORD_OPTIMIZER_MODEL_NAME=Qwen/Qwen3-30B-A3B-Instruct-2507

# ====================== 搜索API配置 ======================
TAVILY_API_KEY=tvly-xxxxxxxxxxxxxxxxxxxxx
BOCHA_BASE_URL=https://api.bochaai.com/v1/ai-search
BOCHA_WEB_SEARCH_API_KEY=your_bocha_api_key_here
```

---

## ✅ 配置验证

### 1. 检查配置文件

```bash
# 查看配置（不显示敏感信息）
cat .env | grep -E "^[A-Z_]+=" | sed 's/=.*/=***/'
```

### 2. 测试数据库连接

```bash
mysql -u bettafish -p -h localhost bettafish
# 输入密码，如果能连接成功说明配置正确
```

### 3. 测试API连接（Python脚本）

```bash
source venv/bin/activate
python -c "
from openai import OpenAI
from config import settings

# 测试Insight Engine API
try:
    client = OpenAI(
        api_key=settings.INSIGHT_ENGINE_API_KEY,
        base_url=settings.INSIGHT_ENGINE_BASE_URL
    )
    response = client.chat.completions.create(
        model=settings.INSIGHT_ENGINE_MODEL_NAME,
        messages=[{'role': 'user', 'content': 'test'}],
        max_tokens=10
    )
    print('✅ Insight Engine API连接成功')
except Exception as e:
    print(f'❌ Insight Engine API连接失败: {e}')
"
```

---

## 💡 配置建议

### 最小配置（测试用）

如果只是想测试系统，可以只配置：

1. **数据库配置**（必须）
2. **至少一个LLM API**（建议先配置Insight Engine）
3. **Tavily API**（用于QueryEngine）

其他API可以暂时留空，系统会跳过相关功能。

### 完整配置（生产用）

建议配置所有API密钥，以获得完整功能：
- 所有LLM API密钥
- 所有搜索API密钥
- 数据库配置

---

## 🔒 安全提示

1. **不要将`.env`文件提交到Git**
   - `.env`文件已在`.gitignore`中，不会被提交

2. **使用强密码**
   - 数据库密码至少16位，包含大小写字母、数字和特殊字符

3. **定期更换API密钥**
   - 如果密钥泄露，及时在对应平台重新生成

4. **限制API权限**
   - 在API提供商处设置合理的调用限制和权限

---

## 📞 获取帮助

如果遇到配置问题：

1. 查看项目README：`README.md`
2. 查看部署文档：`Amazon-Linux部署文档.md`
3. 运行环境检查：`./deploy/check_environment.sh`
4. 查看日志：`tail -f logs/*.log`

---

**配置完成后，记得保存`.env`文件，然后继续部署步骤！** ✅

