# EC2服务器配置SSH密钥连接GitHub

## 问题：Permission denied (publickey)

这是因为EC2服务器还没有配置SSH密钥来访问GitHub。

## 解决方案

### 步骤1：检查是否已有SSH密钥

```bash
ls -al ~/.ssh
```

如果看到 `id_rsa` 或 `id_ed25519` 文件，说明已有密钥，跳到步骤3。

### 步骤2：生成新的SSH密钥

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**提示时：**
- 文件保存路径：直接按回车（使用默认路径 `~/.ssh/id_ed25519`）
- 密码：可以设置密码或直接回车（不设置密码，方便使用）

### 步骤3：查看公钥内容

```bash
cat ~/.ssh/id_ed25519.pub
```

**复制输出的全部内容**（以 `ssh-ed25519` 开头）

### 步骤4：将公钥添加到GitHub

1. 登录GitHub网站
2. 点击右上角头像 > **Settings**
3. 左侧菜单选择 **SSH and GPG keys**
4. 点击 **New SSH key** 按钮
5. **Title**: 填写一个描述（如：EC2 Server）
6. **Key**: 粘贴刚才复制的公钥内容
7. 点击 **Add SSH key**

### 步骤5：测试SSH连接

```bash
ssh -T git@github.com
```

如果看到类似以下消息，说明配置成功：
```
Hi shanglily01-lab! You've successfully authenticated, but GitHub does not provide shell access.
```

### 步骤6：重新克隆仓库

```bash
git clone git@github.com:shanglily01-lab/yuqing.git
cd yuqing
```

---

## 方案2：使用HTTPS方式（快速，无需配置SSH）

如果不想配置SSH密钥，可以直接使用HTTPS方式：

```bash
# 使用HTTPS克隆
git clone https://github.com/shanglily01-lab/yuqing.git
cd yuqing
```

**注意：** 使用HTTPS时，如果仓库是私有的，可能需要输入GitHub用户名和Personal Access Token。

### 创建Personal Access Token（如果需要）

1. GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
2. 点击 **Generate new token (classic)**
3. 设置权限（至少勾选 `repo`）
4. 生成后复制token（只显示一次）
5. 克隆时，密码处输入token而不是GitHub密码

---

## 推荐方案

- **长期使用/频繁操作**：使用SSH方式（方案1）
- **快速测试/一次性操作**：使用HTTPS方式（方案2）

