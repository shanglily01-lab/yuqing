# API平台链接汇总

## 🤖 LLM API平台

### 1. DeepSeek（推荐，性价比高，有免费额度）

**用途：** QueryEngine、InsightEngine、MindSpider

- **官网：** https://www.deepseek.com/
- **API控制台：** https://platform.deepseek.com/
- **注册/登录：** https://platform.deepseek.com/
- **文档：** https://platform.deepseek.com/docs
- **特点：** 
  - 提供免费额度
  - 价格便宜
  - 稳定性好
  - 支持多种模型（deepseek-reasoner, deepseek-chat等）

**配置示例：**
```bash
QUERY_ENGINE_API_KEY=your_deepseek_key
QUERY_ENGINE_BASE_URL=https://api.deepseek.com
QUERY_ENGINE_MODEL_NAME=deepseek-reasoner
```

---

### 2. Kimi（Moonshot AI）

**用途：** InsightEngine（推荐）

- **官网：** https://www.moonshot.cn/
- **API控制台：** https://platform.moonshot.cn/
- **注册/登录：** https://platform.moonshot.cn/
- **文档：** https://platform.moonshot.cn/docs
- **特点：**
  - 中文理解能力强
  - 长文本处理优秀
  - 适合深度分析

**配置示例：**
```bash
INSIGHT_ENGINE_API_KEY=your_kimi_key
INSIGHT_ENGINE_BASE_URL=https://api.moonshot.cn/v1
INSIGHT_ENGINE_MODEL_NAME=kimi-k2-0711-preview
```

---

### 3. Gemini（Google）

**用途：** MediaEngine、ReportEngine

**方式1：通过中转服务（推荐，更便宜）**

- **aihubmix（推荐）：** https://aihubmix.com/?aff=8Ds9
  - 支持多种模型（Gemini, GPT-4, Claude等）
  - 价格相对便宜
  - 稳定性好

**方式2：官方API**

- **Google AI Studio：** https://aistudio.google.com/
- **Google Cloud Console：** https://console.cloud.google.com/

**配置示例（中转服务）：**
```bash
MEDIA_ENGINE_API_KEY=your_aihubmix_key
MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro
```

---

### 4. 硅基流动（SiliconFlow）

**用途：** Forum Host、Keyword Optimizer

- **官网：** https://www.siliconflow.cn/
- **API控制台：** https://cloud.siliconflow.cn/
- **注册/登录：** https://cloud.siliconflow.cn/
- **文档：** https://cloud.siliconflow.cn/docs
- **特点：**
  - 支持Qwen3等最新模型
  - 价格合理
  - 适合中文场景

**配置示例：**
```bash
FORUM_HOST_API_KEY=your_siliconflow_key
FORUM_HOST_BASE_URL=https://api.siliconflow.cn/v1
FORUM_HOST_MODEL_NAME=Qwen/Qwen3-235B-A22B-Instruct-2507

KEYWORD_OPTIMIZER_API_KEY=your_siliconflow_key
KEYWORD_OPTIMIZER_BASE_URL=https://api.siliconflow.cn/v1
KEYWORD_OPTIMIZER_MODEL_NAME=Qwen/Qwen3-30B-A3B-Instruct-2507
```

---

### 5. OpenAI

**用途：** 所有Engine（通用，但价格较高）

- **官网：** https://www.openai.com/
- **API控制台：** https://platform.openai.com/
- **注册/登录：** https://platform.openai.com/
- **文档：** https://platform.openai.com/docs
- **特点：**
  - 最稳定
  - 模型质量高
  - 价格较高

**配置示例：**
```bash
QUERY_ENGINE_API_KEY=sk-your_openai_key
QUERY_ENGINE_BASE_URL=https://api.openai.com/v1
QUERY_ENGINE_MODEL_NAME=gpt-4
```

---

### 6. 其他中转API服务

**302.ai（推荐）**
- **链接：** https://share.302.ai/P66Qe3
- **特点：** 提供多种模型API，价格便宜

**aihubmix（推荐）**
- **链接：** https://aihubmix.com/?aff=8Ds9
- **特点：** 支持Gemini、GPT-4、Claude等多种模型

---

## 🔍 搜索API平台

### 7. Tavily

**用途：** QueryEngine网络搜索

- **官网：** https://www.tavily.com/
- **注册/登录：** https://app.tavily.com/
- **API文档：** https://docs.tavily.com/
- **特点：**
  - 专业的AI搜索API
  - 支持实时网络搜索
  - 提供搜索结果摘要

**配置示例：**
```bash
TAVILY_API_KEY=your_tavily_key
```

---

### 8. Bocha（博查）

**用途：** MediaEngine多模态搜索

- **官网：** https://www.bochaai.com/
- **开放平台：** https://open.bochaai.com/
- **注册/登录：** https://open.bochaai.com/
- **特点：**
  - 支持多模态搜索（文本、图片、视频）
  - 中文搜索优化
  - 提供AI总结功能

**配置示例：**
```bash
BOCHA_WEB_SEARCH_API_KEY=your_bocha_key
BOCHA_BASE_URL=https://api.bochaai.com/v1/ai-search
```

---

## 📊 推荐配置方案

### 方案1：性价比方案（推荐）

```bash
# QueryEngine - DeepSeek（免费额度+便宜）
QUERY_ENGINE_API_KEY=your_deepseek_key
QUERY_ENGINE_BASE_URL=https://api.deepseek.com
QUERY_ENGINE_MODEL_NAME=deepseek-reasoner

# InsightEngine - DeepSeek（复用同一个密钥）
INSIGHT_ENGINE_API_KEY=your_deepseek_key
INSIGHT_ENGINE_BASE_URL=https://api.deepseek.com
INSIGHT_ENGINE_MODEL_NAME=deepseek-reasoner

# MediaEngine - aihubmix Gemini（便宜）
MEDIA_ENGINE_API_KEY=your_aihubmix_key
MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro

# ReportEngine - aihubmix Gemini（复用）
REPORT_ENGINE_API_KEY=your_aihubmix_key
REPORT_ENGINE_BASE_URL=https://aihubmix.com/v1
REPORT_ENGINE_MODEL_NAME=gemini-2.5-pro

# MindSpider - DeepSeek（复用）
MINDSPIDER_API_KEY=your_deepseek_key
MINDSPIDER_BASE_URL=https://api.deepseek.com
MINDSPIDER_MODEL_NAME=deepseek-reasoner

# 搜索API
TAVILY_API_KEY=your_tavily_key
BOCHA_WEB_SEARCH_API_KEY=your_bocha_key
```

### 方案2：高质量方案

```bash
# 使用Kimi和Gemini官方API
INSIGHT_ENGINE_API_KEY=your_kimi_key
INSIGHT_ENGINE_BASE_URL=https://api.moonshot.cn/v1
INSIGHT_ENGINE_MODEL_NAME=kimi-k2-0711-preview

MEDIA_ENGINE_API_KEY=your_gemini_key
MEDIA_ENGINE_BASE_URL=https://generativelanguage.googleapis.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro
```

---

## 🔗 快速访问链接

### LLM API
- [DeepSeek](https://platform.deepseek.com/) - 推荐，性价比高
- [Kimi (Moonshot)](https://platform.moonshot.cn/) - 中文理解强
- [aihubmix](https://aihubmix.com/?aff=8Ds9) - 中转服务，便宜
- [硅基流动](https://cloud.siliconflow.cn/) - Qwen3模型
- [OpenAI](https://platform.openai.com/) - 最稳定但贵
- [302.ai](https://share.302.ai/P66Qe3) - 中转服务

### 搜索API
- [Tavily](https://app.tavily.com/) - AI搜索
- [Bocha](https://open.bochaai.com/) - 多模态搜索

---

## 📝 申请步骤

### 通用步骤：

1. **访问平台官网**
2. **注册账号**（通常需要邮箱）
3. **登录控制台**
4. **创建API密钥**
5. **充值**（部分平台有免费额度）
6. **复制API密钥到`.env`文件**

### 注意事项：

- 大部分平台需要实名认证
- 建议先使用免费额度测试
- 注意API使用限制和价格
- 妥善保管API密钥，不要泄露

---

## 💡 提示

1. **DeepSeek** 提供免费额度，适合新手
2. **aihubmix** 等中转服务通常更便宜
3. 可以复用同一个API密钥给多个Engine使用
4. 建议先测试再大量使用
5. 定期检查API余额和使用情况

