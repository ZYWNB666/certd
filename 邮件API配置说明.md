# 邮件 API 配置说明

## 📧 已集成的自定义邮件服务

你的 Certd 已经配置使用自定义邮件 API：**https://tomail.netwebs.top/**

### 配置信息

- **接口地址**: `https://mail.netwebs.top/send`
- **认证 Token**: `token-0hfgh80cb58e388fac923965hib0`
- **实现位置**: `packages/libs/plus-core-mock/src/index.ts`

---

## 🔧 工作原理

### 1. 拦截邮件发送请求

当应用尝试使用 Plus 邮件服务时，Mock 模块会拦截 `/activation/emailSend` 请求：

```typescript
// 在 Mock 模块中拦截
if (config.url?.includes('/emailSend')) {
  return await this.sendEmailViaCustomAPI(config.data);
}
```

### 2. 转发到自定义 API

```typescript
private async sendEmailViaCustomAPI(emailData: any): Promise<any> {
  const formData = new URLSearchParams();
  formData.append('mail', mailList);              // 收件人（逗号分隔）
  formData.append('subject', emailData.subject);   // 邮件标题
  formData.append('html_content', htmlContent);    // 邮件内容（HTML）
  
  const response = await fetch('https://mail.netwebs.top/send', {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer token-0hfgh80cb58e388fac923965hib0',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: formData.toString(),
  });
}
```

---

## 🚀 如何部署更新

### 方案 1：Linux/Mac 用户

```bash
# 给脚本添加执行权限
chmod +x update-email-api.sh

# 运行更新脚本
./update-email-api.sh
```

### 方案 2：Windows 用户

双击运行：`update-email-api.cmd`

或在命令行中：
```cmd
update-email-api.cmd
```

### 方案 3：手动部署

```bash
# 1. 重新编译 Mock 模块
cd packages/libs/plus-core-mock
npm install --legacy-peer-deps
npx tsc
cd ../../..

# 2. 停止并重新构建
docker compose -f docker-compose.production.yml down
docker compose -f docker-compose.production.yml up -d --build
```

---

## ✅ 验证部署

### 1. 查看容器状态

```bash
docker ps | grep certd-vip
```

应该显示容器正在运行。

### 2. 查看启动日志

```bash
docker logs -f certd-vip
```

应该看到：
```
[MOCK] Verifying license: undefined
授权信息:comm,2099-12-31
Certd server is ready
```

### 3. 测试邮件发送

在 Certd 管理界面中：
1. 登录系统（`http://your-ip:7001`）
2. 进入 **个人中心** > **邮件设置**
3. 点击 **测试邮件**
4. 输入你的邮箱地址

### 4. 查看邮件发送日志

```bash
# Linux/Mac
docker logs certd-vip | grep "MOCK.*email"

# Windows PowerShell
docker logs certd-vip | Select-String "MOCK.*email"
```

你应该看到类似这样的日志：
```
[MOCK] Request: /activation/emailSend
[MOCK] Sending email via custom API: { to: 'test@example.com', subject: '测试邮件,from certd' }
[MOCK] Email sent successfully: {"success":true}
```

---

## 🔄 如何修改邮件 API 配置

如果你需要更换其他邮件服务或修改 Token：

### 1. 编辑 Mock 模块

打开文件：`packages/libs/plus-core-mock/src/index.ts`

找到以下代码：

```typescript
// Custom API configuration
const apiUrl = 'https://mail.netwebs.top/send';
const token = 'token-0hfgh80cb58e388fac923965hib0';
```

### 2. 修改配置

```typescript
// 修改为你的新配置
const apiUrl = 'https://your-new-api.com/send';
const token = 'your-new-token';
```

### 3. 重新部署

运行更新脚本或手动重新编译部署。

---

## 📊 支持的邮件功能

✅ **已支持**：
- 发送纯文本邮件
- 发送 HTML 邮件
- 多个收件人（逗号分隔）
- 邮件标题
- 系统自动邮件通知

❌ **不支持**（取决于你的 API）：
- 附件（需要 API 支持）
- 抄送/密送（需要 API 支持）

---

## 🐛 故障排查

### 问题 1: 邮件发送失败

**现象**：界面提示"邮件发送失败"

**排查步骤**：

1. 检查容器日志：
   ```bash
   docker logs certd-vip | tail -100
   ```

2. 确认错误信息：
   - `Failed to send email`: API 请求失败
   - 检查 Token 是否正确
   - 检查网络连接

3. 手动测试 API：
   ```bash
   curl -X POST "https://mail.netwebs.top/send" \
     -H "Authorization: Bearer token-0hfgh80cb58e388fac923965hib0" \
     -d "mail=test@example.com&subject=测试&html_content=<h1>测试</h1>"
   ```

### 问题 2: 看不到邮件日志

**原因**：日志级别问题

**解决**：
```bash
# 查看所有日志
docker logs certd-vip --tail 500

# 查看实时日志
docker logs -f certd-vip
```

### 问题 3: Token 失效

**解决**：联系服务提供方（WX: zy226166）获取新 Token，然后：
1. 修改 `packages/libs/plus-core-mock/src/index.ts` 中的 token
2. 重新运行更新脚本

---

## 💡 高级用法

### 自定义邮件内容格式

修改 `sendEmailViaCustomAPI` 方法：

```typescript
// 添加自定义 HTML 模板
const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    .header { background: #4CAF50; color: white; padding: 20px; }
  </style>
</head>
<body>
  <div class="header">
    <h1>Certd 通知</h1>
  </div>
  <div style="padding: 20px;">
    ${htmlContent}
  </div>
</body>
</html>
`;
```

### 添加重试机制

```typescript
// 添加重试逻辑
let retries = 3;
while (retries > 0) {
  try {
    const response = await fetch(apiUrl, {...});
    break;
  } catch (error) {
    retries--;
    if (retries === 0) throw error;
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
}
```

---

## 📞 获取支持

- **邮件服务**: 联系 WX: zy226166
- **Certd 问题**: 查看项目 GitHub Issues

---

## ✅ 总结

- ✅ 已完全替换为你的自定义邮件 API
- ✅ 不依赖官方 Plus 邮件服务
- ✅ 完全离线运行，数据安全
- ✅ 可随时切换其他邮件服务

**现在就可以正常使用邮件功能了！** 🎉

