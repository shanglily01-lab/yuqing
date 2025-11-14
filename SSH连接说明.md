# SSH连接GitHub时的提示说明

## 当前情况

当您首次通过SSH连接GitHub时，会看到以下提示：

```
The authenticity of host 'github.com (20.205.243.166)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

## 解决方案

**直接输入 `yes` 并按回车键**

这是正常的SSH安全验证，用于确认您要连接到GitHub服务器。输入`yes`后，GitHub的主机密钥会被添加到您的`~/.ssh/known_hosts`文件中，以后连接就不会再提示了。

## 完整操作步骤

```bash
# 1. 当看到提示时，输入 yes
yes

# 2. 如果配置了SSH密钥，克隆会继续进行
# 如果没有配置SSH密钥，会提示权限被拒绝
```

## 如果提示权限被拒绝

如果输入`yes`后提示"Permission denied (publickey)"，说明还没有配置SSH密钥：

### 1. 检查是否已有SSH密钥
```bash
ls -al ~/.ssh
```

### 2. 如果没有密钥，生成新的SSH密钥
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# 按回车使用默认路径
# 可以设置密码或直接回车（不设置密码）
```

### 3. 查看公钥内容
```bash
cat ~/.ssh/id_ed25519.pub
```

### 4. 将公钥添加到GitHub
- 复制公钥内容
- 登录GitHub
- 进入 Settings > SSH and GPG keys
- 点击 "New SSH key"
- 粘贴公钥并保存

### 5. 测试SSH连接
```bash
ssh -T git@github.com
```

### 6. 重新克隆仓库
```bash
git clone git@github.com:shanglily01-lab/yuqing.git
```

## 或者使用HTTPS方式（无需SSH密钥）

如果不想配置SSH密钥，可以使用HTTPS方式：

```bash
git clone https://github.com/shanglily01-lab/yuqing.git
```

使用HTTPS方式时，可能需要输入GitHub用户名和Personal Access Token（不是密码）。

