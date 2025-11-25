# Docker 启动失败修复说明

## 🐛 问题描述

启动容器时出现错误：
```
Error: Cannot find module '/app/node_modules/cross-env/src/bin/cross-env.js'
```

## ✅ 已修复

已更新以下文件：
- `Dockerfile.production` - 修复 monorepo 依赖问题
- `docker-compose.production.yml` - 修复数据卷挂载路径

## 🚀 重新部署步骤

### 1. 停止并删除旧容器

```bash
docker compose -f docker-compose.production.yml down
docker rmi certd-certd:latest
```

### 2. 清理构建缓存（可选，确保全新构建）

```bash
docker builder prune -af
```

### 3. 重新构建和启动

```bash
docker compose -f docker-compose.production.yml up -d --build
```

### 4. 查看启动日志

```bash
docker logs -f certd-vip
```

应该看到类似以下成功日志：
```
[MOCK] Verifying license: undefined
授权信息:comm,2099-12-31
Certd server is ready
```

### 5. 访问应用

浏览器打开：`http://your-server-ip:7001`

默认账号：
- 用户名: `admin`
- 密码: `123456`（首次登录后请立即修改！）

---

## 🔧 修复细节

### 主要改动

1. **保持 Monorepo 结构**
   - 复制整个 `packages` 目录和 `node_modules`
   - 保持 pnpm workspace 链接关系

2. **更新工作目录**
   - 从 `/app` 改为 `/app/packages/ui/certd-server`
   - 更新数据卷挂载路径

3. **添加必要工具**
   - 在生产镜像中安装 `pnpm`
   - 添加 `wget` 用于健康检查

### 镜像大小说明

由于需要保持完整的 monorepo 结构，生产镜像会比较大（约 2-3GB）。这是为了确保所有依赖都能正常工作。

如果需要优化镜像大小，可以考虑：
- 使用 `pnpm deploy` 命令
- 或者将项目转换为独立应用（不使用 monorepo）

---

## ❓ 常见问题

### Q: 容器启动后立即退出？

A: 查看日志确认错误：
```bash
docker logs certd-vip
```

### Q: 无法访问 7001 端口？

A: 检查防火墙和端口映射：
```bash
# 检查容器是否正在运行
docker ps | grep certd-vip

# 检查端口监听
netstat -tlnp | grep 7001
```

### Q: 数据库初始化失败？

A: 删除旧数据并重新启动：
```bash
docker compose -f docker-compose.production.yml down -v
rm -rf data/
docker compose -f docker-compose.production.yml up -d
```

---

## 📊 构建时间参考

完整构建时间约 **10-15 分钟**，包括：
- 下载基础镜像
- 安装依赖
- 编译 TypeScript
- 构建前端
- 构建后端

**后续更新**只需要增量构建，速度会快很多。

---

## 🎉 成功标志

当看到以下日志时，表示启动成功：

```
[MOCK] Verifying license: undefined
[MOCK] Registering site
授权信息:comm,2099-12-31
2025-xx-xx xx:xx:xx,xxx INFO 7 [midway:core] start app ...
Certd server is ready
```

浏览器访问应该能看到登录界面 ✅

---

## 📞 需要帮助？

如果还有问题，请提供：
1. 完整的错误日志 (`docker logs certd-vip`)
2. Docker 版本 (`docker --version`)
3. 操作系统版本

