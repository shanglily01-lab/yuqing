# API余额不足解决方案

## 错误信息

```
Error code: 402 - {'error': {'message': 'Insufficient Balance', 'type': 'unknown_error', 'param': None, 'code': 'invalid_request_error'}}
```

## 问题原因

这是API服务商的余额不足错误，表示您使用的API密钥账户余额已用完。

## 解决方案

### 方案1：充值API账户（推荐）

#### 1.1 检查哪个API余额不足

根据错误发生的功能，判断是哪个API：

- **QueryEngine** → `QUERY_ENGINE_API_KEY` (推荐DeepSeek)
- **MediaEngine** → `MEDIA_ENGINE_API_KEY` (推荐Gemini)
- **InsightEngine** → `INSIGHT_ENGINE_API_KEY` (推荐Kimi)
- **ReportEngine** → `REPORT_ENGINE_API_KEY` (推荐Gemini)
- **MindSpider** → `MINDSPIDER_API_KEY` (推荐DeepSeek)

#### 1.2 充值对应API账户

**DeepSeek (推荐用于QueryEngine和MindSpider)**
- 访问：https://www.deepseek.com/
- 登录账户 → 充值

**Kimi (推荐用于InsightEngine)**
- 访问：https://platform.moonshot.cn/
- 登录账户 → 充值

**Gemini (推荐用于MediaEngine和ReportEngine)**
- 如果使用中转API（如aihubmix.com）：
  - 访问：https://aihubmix.com/?aff=8Ds9
  - 登录账户 → 充值
- 如果使用官方API：
  - 访问：https://aistudio.google.com/
  - 登录账户 → 充值

**硅基流动 (用于Forum Host和Keyword Optimizer)**
- 访问：https://cloud.siliconflow.cn/
- 登录账户 → 充值

### 方案2：使用免费API替代

#### 2.1 使用免费的DeepSeek API

DeepSeek提供一定的免费额度：

1. 注册DeepSeek账户：https://www.deepseek.com/
2. 获取免费API密钥
3. 在`.env`文件中配置：

```bash
# 使用DeepSeek作为主要LLM
QUERY_ENGINE_API_KEY=your_deepseek_api_key
QUERY_ENGINE_BASE_URL=https://api.deepseek.com
QUERY_ENGINE_MODEL_NAME=deepseek-reasoner

INSIGHT_ENGINE_API_KEY=your_deepseek_api_key
INSIGHT_ENGINE_BASE_URL=https://api.deepseek.com
INSIGHT_ENGINE_MODEL_NAME=deepseek-reasoner

MINDSPIDER_API_KEY=your_deepseek_api_key
MINDSPIDER_BASE_URL=https://api.deepseek.com
MINDSPIDER_MODEL_NAME=deepseek-reasoner
```

#### 2.2 使用免费的OpenAI兼容API

一些服务提供免费的OpenAI兼容API：

- **Groq**: https://console.groq.com/ (免费额度)
- **Together AI**: https://together.ai/ (有免费额度)
- **Anthropic Claude**: https://console.anthropic.com/ (有免费额度)

### 方案3：切换到其他API服务商

#### 3.1 使用中转API服务（通常更便宜）

**推荐的中转API服务：**
- **aihubmix.com**: https://aihubmix.com/?aff=8Ds9
  - 支持多种模型（Gemini, GPT-4, Claude等）
  - 价格相对便宜
  - 配置示例：
    ```bash
    MEDIA_ENGINE_API_KEY=your_aihubmix_key
    MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
    MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro
    ```

#### 3.2 使用本地模型（如果服务器配置足够）

如果EC2服务器配置足够（有GPU），可以考虑部署本地模型：
- **Ollama**: https://ollama.ai/
- **vLLM**: https://github.com/vllm-project/vllm

### 方案4：优化API使用

#### 4.1 减少API调用

- 使用缓存机制
- 批量处理请求
- 减少不必要的API调用

#### 4.2 使用更便宜的模型

在`.env`文件中切换到更便宜的模型：

```bash
# 使用更便宜的模型
QUERY_ENGINE_MODEL_NAME=deepseek-chat  # 比deepseek-reasoner便宜
INSIGHT_ENGINE_MODEL_NAME=kimi-1.8k  # 比kimi-k2便宜
```

## 检查API余额

### DeepSeek
1. 访问：https://platform.deepseek.com/
2. 登录 → 查看余额

### Kimi
1. 访问：https://platform.moonshot.cn/
2. 登录 → 查看余额

### aihubmix
1. 访问：https://aihubmix.com/
2. 登录 → 查看余额

### 硅基流动
1. 访问：https://cloud.siliconflow.cn/
2. 登录 → 查看余额

## 临时解决方案

如果暂时无法充值，可以：

1. **暂停使用相关功能**：在Flask前端界面中，暂时不使用余额不足的Agent
2. **使用其他Agent**：如果其他Agent还有余额，可以优先使用它们
3. **降低使用频率**：减少API调用次数

## 配置多个API密钥（备用方案）

可以在`.env`文件中配置多个API密钥，代码会自动选择可用的：

```bash
# 主API密钥
QUERY_ENGINE_API_KEY=primary_key_here
QUERY_ENGINE_BASE_URL=https://api.deepseek.com

# 备用API密钥（如果主密钥余额不足，可以快速切换）
# QUERY_ENGINE_API_KEY=backup_key_here
# QUERY_ENGINE_BASE_URL=https://api.backup.com
```

## 预防措施

1. **设置余额提醒**：在API服务商处设置余额不足提醒
2. **定期检查余额**：定期登录API服务商查看余额
3. **使用多个API密钥**：配置多个API密钥作为备用
4. **监控API使用**：定期检查API使用情况，避免意外超支

## 快速修复步骤

1. **确定是哪个API余额不足**
   - 查看错误日志，确定是哪个功能报错
   - 对应到相应的API密钥

2. **充值或更换API密钥**
   - 登录对应的API服务商充值
   - 或更换为其他有余额的API密钥

3. **更新`.env`文件**
   ```bash
   cd ~/yuqing
   nano .env
   # 更新相应的API密钥
   ```

4. **重启应用**
   ```bash
   pkill -f "python.*app.py"
   pkill -f streamlit
   sleep 2
   source venv/bin/activate
   export PYTHONPATH=$(pwd):$PYTHONPATH
   nohup python app.py > logs/app.log 2>&1 &
   ```

## 推荐配置（性价比高）

```bash
# QueryEngine - DeepSeek（性价比高，有免费额度）
QUERY_ENGINE_API_KEY=your_deepseek_key
QUERY_ENGINE_BASE_URL=https://api.deepseek.com
QUERY_ENGINE_MODEL_NAME=deepseek-reasoner

# InsightEngine - DeepSeek（可以复用同一个密钥）
INSIGHT_ENGINE_API_KEY=your_deepseek_key
INSIGHT_ENGINE_BASE_URL=https://api.deepseek.com
INSIGHT_ENGINE_MODEL_NAME=deepseek-reasoner

# MediaEngine - aihubmix Gemini（价格便宜）
MEDIA_ENGINE_API_KEY=your_aihubmix_key
MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro

# ReportEngine - aihubmix Gemini（可以复用）
REPORT_ENGINE_API_KEY=your_aihubmix_key
REPORT_ENGINE_BASE_URL=https://aihubmix.com/v1
REPORT_ENGINE_MODEL_NAME=gemini-2.5-pro

# MindSpider - DeepSeek（可以复用）
MINDSPIDER_API_KEY=your_deepseek_key
MINDSPIDER_BASE_URL=https://api.deepseek.com
MINDSPIDER_MODEL_NAME=deepseek-reasoner
```

这样可以最大化利用API密钥，减少成本。

