---
name: "git-code-uploader"
description: "Guides users through committing and pushing code to Git repository. Invoke when user wants to upload code, commit changes, or push to remote repository."
---

# Git 代码上传指南

帮助用户将代码提交并推送到 Git 仓库。

## 使用场景

- 用户说"上传代码"
- 用户说"提交代码"
- 用户说"push代码"
- 用户说"保存到git"
- 用户想将本地更改同步到远程仓库

## 上传步骤

### 1. 检查 Git 状态
```bash
git status
```

### 2. 添加更改的文件
```bash
# 添加所有更改
git add .

# 或添加特定文件
git add <file-path>
```

### 3. 提交更改
```bash
git commit -m "<提交信息>"
```

### 4. 推送到远程
```bash
git push origin <branch-name>
```

## 常见问题

### 没有配置用户信息
```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 需要拉取最新更改
```bash
git pull origin <branch-name>
```

### 查看提交历史
```bash
git log --oneline -10
```
