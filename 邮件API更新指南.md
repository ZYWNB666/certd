# 📧 邮件 API 更新指南（快速开始）

## 🎉 已完成的修改

✅ 已将邮件发送功能改为使用你的自定义 API：**https://tomail.netwebs.top/**

修改的文件：
- `packages/libs/plus-core-mock/src/index.ts` - 添加了自定义邮件 API 集成

---

## 🚀 立即部署（3 步）

### 步骤 1: 测试 API（可选）

**在本地测试邮件 API 是否可用：**

```bash
# Linux/Mac
chmod +x test-email-api.sh
./test-email-api.sh

# Windows PowerShell
.\test-email-api.ps1

# Windows CMD - 手动测试
curl -X POST "https://mail.netwebs.top/send" ^
  -H "Authorization: Bearer token-0hfgh80cb58e388fac923965hib0" ^
  -d "mail=your@email.com&subject=测试&html_content=<h1>测试</h1>"
```

### 步骤 2: 部署到服务器

**上传修改的文件到服务器：**

```bash
# 将以下文件上传到服务器的项目目录
packages/libs/plus-core-mock/src/index.ts
update-email-api.sh  # 或 update-email-api.ps1 (Windows)
```

或者直接在服务器上修改文件：

```bash
# SSH 到服务器
ssh root@47.242.219.197

# 进入项目目录
cd ~/certd

# 编辑 Mock 模块
nano packages/libs/plus-core-mock/src/index.ts

# 粘贴新的代码（已在上面的修改中完成）
```

### 步骤 3: 重新编译和部署

**在服务器上执行：**

```bash
# 方式 1: 使用更新脚本（推荐）
chmod +x update-email-api.sh
./update-email-api.sh

# 方式 2: 手动执行
cd packages/libs/plus-core-mock
npm install --legacy-peer-deps
npx tsc
cd ../../..

docker compose -f docker-compose.production.yml down
docker compose -f docker-compose.production.yml up -d --build
```

---

## ✅ 验证部署

### 1. 查看容器状态

```bash
docker ps | grep certd-vip
```

**应该显示**：`Up` 状态

### 2. 查看启动日志

```bash
docker logs -f certd-vip
```

**应该看到**：
```
[MOCK] Verifying license: undefined
授权信息:comm,2099-12-31
Certd server is ready
```

### 3. 测试邮件发送

**方式 1：在 Web 界面测试**

1. 打开浏览器：`http://47.242.219.197:7001`
2. 登录系统（默认：`admin` / `123456`）
3. 进入 **个人中心** > **邮件设置**
4. 点击 **测试邮件**，输入你的邮箱
5. 点击发送

**方式 2：查看邮件发送日志**

```bash
docker logs certd-vip | grep "MOCK.*email"
```

**应该看到**：
```
[MOCK] Request: /activation/emailSend
[MOCK] Sending email via custom API: { to: 'test@example.com', subject: '测试邮件,from certd' }
[MOCK] Email sent successfully: ...
```

---

## 🔧 如何修改配置

如果需要更换邮件 API 或修改 Token：

### 1. 编辑配置

文件：`packages/libs/plus-core-mock/src/index.ts`

找到第 210-211 行：

```typescript
const apiUrl = 'https://mail.netwebs.top/send';
const token = 'token-0hfgh80cb58e388fac923965hib0';
```

修改为你的新配置：

```typescript
const apiUrl = 'https://your-new-api.com/send';
const token = 'your-new-token';
```

### 2. 重新部署

```bash
./update-email-api.sh
```

---

## 📊 支持的功能

✅ **已支持**：
- ✅ 发送纯文本邮件
- ✅ 发送 HTML 邮件
- ✅ 多个收件人（自动逗号分隔）
- ✅ 自定义邮件标题
- ✅ 证书到期通知
- ✅ 流水线执行通知

❌ **暂不支持**（取决于 API）：
- ❌ 附件（需要 API 支持）
- ❌ 抄送/密送

---

## 🐛 常见问题

### Q1: 邮件发送失败怎么办？

**A**: 检查日志：

```bash
docker logs certd-vip | tail -100
```

常见错误：
- `Failed to send email: fetch failed` → 网络问题或 API 不可用
- `Failed to send email: 401` → Token 错误
- `Failed to send email: 400` → 邮箱格式错误

### Q2: 如何测试 API 是否可用？

**A**: 使用 curl 测试：

```bash
curl -X POST "https://mail.netwebs.top/send" \
  -H "Authorization: Bearer token-0hfgh80cb58e388fac923965hib0" \
  -d "mail=test@example.com&subject=测试&html_content=<h1>测试</h1>"
```

### Q3: Token 从哪里获取？

**A**: 联系服务提供方：**WX: zy226166**

### Q4: 需要配置 SMTP 服务器吗？

**A**: ❌ **不需要！** 现在使用的是 HTTP API，不需要配置 SMTP。

---

## 📝 技术细节

### 工作流程

```
Certd 应用
    ↓
调用 emailService.send()
    ↓
触发 plusService.sendEmail()
    ↓
被 Mock 模块拦截 (plus-core-mock)
    ↓
转发到自定义 API (https://mail.netwebs.top/send)
    ↓
邮件发送成功 ✅
```

### 代码位置

| 文件 | 说明 |
|-----|------|
| `packages/libs/plus-core-mock/src/index.ts` | 邮件 API 集成代码 |
| `packages/ui/certd-server/src/modules/basic/service/email-service.ts` | 邮件服务 |
| `packages/libs/lib-server/src/system/basic/service/plus-service.ts` | Plus 服务（被 Mock 替换） |

---

## 🎯 下一步

1. ✅ **立即部署**：运行 `./update-email-api.sh`
2. ✅ **测试邮件**：在 Web 界面发送测试邮件
3. ✅ **配置通知**：设置证书到期提醒
4. ✅ **正常使用**：享受完整的邮件功能

---

## 📞 技术支持

- **邮件 API 问题**：联系 WX: zy226166
- **Certd 部署问题**：查看 `Docker修复说明.md`
- **邮件功能详细说明**：查看 `邮件API配置说明.md`

---

**现在就开始部署吧！** 🚀

```bash
# 在服务器上运行
./update-email-api.sh
```

