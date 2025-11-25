# Certd VIP/套餐机制破解完整指南

## 📋 目录

1. [原理说明](#原理说明)
2. [快速开始](#快速开始)
3. [详细步骤](#详细步骤)
4. [验证方法](#验证方法)
5. [常见问题](#常见问题)
6. [技术细节](#技术细节)

---

## 🎯 原理说明

### VIP验证机制分析

Certd项目的VIP验证主要通过 `@certd/plus-core` 这个**闭源外部依赖包**实现：

```
@certd/plus-core (闭源)
├── isPlus()         - 检查是否为专业版
├── isComm()         - 检查是否为商业版
├── checkPlus()      - 验证专业版，失败抛异常
├── checkComm()      - 验证商业版，失败抛异常
├── getPlusInfo()    - 获取VIP信息(类型、过期时间)
└── PlusRequestService - 与授权服务器通信
```

### 破解原理

通过 **pnpm overrides** 机制，用本地的 Mock 模块替换原有的 `@certd/plus-core` 包：

```
@certd/plus-core (原版，联网验证)
         ↓ 
      替换为
         ↓
plus-core-mock (Mock版，始终返回成功)
```

所有验证函数均返回"已激活"状态，无需联网验证。

---

## 🚀 快速开始

### 方法一：一键脚本（推荐）

**Windows PowerShell:**
```powershell
.\bypass-vip-setup.ps1
```

**Windows CMD:**
```cmd
bypass-vip-setup.cmd
```

**Linux/Mac:**
```bash
bash bypass-vip-setup.sh
```

### 方法二：手动执行

```bash
# 1. 编译Mock模块
cd packages/libs/plus-core-mock
npm install && npm run build
cd ../../..

# 2. 清理并重装依赖
rm -rf node_modules pnpm-lock.yaml
pnpm install

# 3. 构建项目
pnpm run init

# 4. 启动
cd packages/ui/certd-server
npm start
```

---

## 📝 详细步骤

### 步骤1: 理解项目结构

已创建的文件：
```
certd/
├── packages/libs/plus-core-mock/    ← Mock模块
│   ├── src/index.ts                 ← Mock实现
│   ├── package.json
│   ├── tsconfig.json
│   ├── test.mjs                     ← 测试文件
│   └── README.md
├── package.json                      ← 已添加 overrides 配置
├── BYPASS_VIP.md                     ← 详细说明文档
├── VIP破解完整指南.md                ← 本文档
└── bypass-vip-setup.*                ← 一键脚本
```

### 步骤2: 编译Mock模块

```bash
cd packages/libs/plus-core-mock
npm install
npm run build
```

**验证编译成功:**
```bash
# 应该能看到 dist 目录
ls dist/
# 输出: index.js  index.d.ts  index.d.ts.map

# 运行测试
npm test
```

### 步骤3: 配置 pnpm overrides

查看根目录 `package.json`，确认已有以下配置：

```json
{
  "pnpm": {
    "overrides": {
      "@certd/plus-core": "workspace:packages/libs/plus-core-mock"
    }
  }
}
```

### 步骤4: 重新安装依赖

```bash
# 返回项目根目录
cd ../../../

# 完全清理
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/*/node_modules
rm -f pnpm-lock.yaml

# 重新安装
pnpm install
```

**验证替换成功:**
```bash
# 检查 pnpm-lock.yaml
grep -A 5 "@certd/plus-core" pnpm-lock.yaml

# 应该看到类似输出:
# '@certd/plus-core':
#   specifier: ^1.37.10
#   version: link:packages/libs/plus-core-mock
```

### 步骤5: 构建项目

```bash
# 构建所有包
pnpm run init

# 或单独构建server
cd packages/ui/certd-server
npm run build
```

### 步骤6: 启动项目

```bash
cd packages/ui/certd-server
npm start
```

---

## ✅ 验证方法

### 1. 查看启动日志

启动成功后，应该看到：

```
[MOCK] Verifying license: undefined
=========================================
当前站点ID: xxxxxxxxxx
当前版本:1.37.10
授权信息:permanent,2099-12-31    ← 关键！永久专业版
Certd已启动
=========================================
```

**关键标志:**
- `[MOCK]` 前缀表示使用了Mock模块
- `授权信息:permanent,2099-12-31` 表示永久专业版，过期时间2099年

### 2. 测试专业版功能

#### A. 站点监控
- 访问 "监控" 菜单
- 尝试添加多个站点监控
- 免费版限制1条，破解后应该无限制

#### B. 通知功能
- 访问 "流水线" → "通知配置"
- 尝试添加以下专业版通知类型：
  - ✅ 企业微信
  - ✅ 钉钉
  - ✅ 飞书
  - ✅ AnPush
  - ✅ Server酱

#### C. 流水线数量
- 尝试创建多个流水线
- 免费版有限制，破解后无限制

#### D. 专业版插件
- 查看部署插件列表
- 群晖等专业版插件应该可用

### 3. 查看VIP状态

在后台管理界面：
- 右上角应该显示 VIP 标识（金色图标）
- 点击后查看授权信息
- 应该显示：
  - **类型:** 永久专业版
  - **到期时间:** 2099-12-31

---

## ❓ 常见问题

### Q1: 脚本执行失败，提示找不到 pnpm

**解决方法:**
```bash
# 安装 pnpm
npm install -g pnpm

# 或使用 npx
npx pnpm install
```

### Q2: 编译 Mock 模块失败

**解决方法:**
```bash
cd packages/libs/plus-core-mock

# 安装 TypeScript
npm install -g typescript

# 重新编译
npm run build

# 如果还有问题，检查 tsconfig.json
```

### Q3: 启动后没有看到 [MOCK] 日志

**可能原因:**
1. Mock 模块未正确替换
2. 缓存问题

**解决方法:**
```bash
# 完全清理
rm -rf node_modules
rm -rf packages/*/node_modules  
rm -rf packages/*/*/node_modules
rm -f pnpm-lock.yaml

# 清理编译缓存
rm -rf packages/*/dist
rm -rf packages/*/*/dist

# 重新开始
cd packages/libs/plus-core-mock
npm run build
cd ../../..
pnpm install
pnpm run init
```

### Q4: 替换后某些功能仍然提示需要VIP

**检查步骤:**
1. 确认 `pnpm-lock.yaml` 中有 Mock 模块的引用
2. 检查启动日志是否有 `[MOCK]` 标记
3. 查看具体报错文件，可能需要重启服务

**强制刷新:**
```bash
# 停止服务
# Ctrl+C

# 清理并重启
rm -rf packages/ui/certd-server/dist
cd packages/ui/certd-server
npm run build
npm start
```

### Q5: pnpm install 卡住或很慢

**解决方法:**
```bash
# 使用国内镜像
pnpm config set registry https://registry.npmmirror.com

# 清理缓存
pnpm store prune

# 重新安装
pnpm install
```

### Q6: Windows PowerShell 提示无法执行脚本

**解决方法:**
```powershell
# 以管理员身份运行 PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 然后重新运行脚本
.\bypass-vip-setup.ps1
```

---

## 🔧 技术细节

### Mock 实现的关键代码

#### 1. 验证函数

```typescript
// 永远返回 true
export function isPlus(): boolean {
  return true;
}

export function isComm(): boolean {
  return true;
}

// 不抛出任何异常
export function checkPlus(): void {
  // Do nothing
}
```

#### 2. VIP 信息

```typescript
let plusInfo: PlusInfo = {
  vipType: 'permanent',                      // 永久版
  expireTime: new Date('2099-12-31').getTime(), // 2099年过期
  isPlus: true,
  isComm: true,
};
```

#### 3. 请求服务 Mock

```typescript
export class PlusRequestService {
  // 激活码验证 - 始终成功
  async active(code: string, inviteCode?: string) {
    console.log('[MOCK] Activating...');
    return {
      success: true,
      license: 'MOCK-LICENSE-' + Date.now(),
    };
  }

  // 许可证验证 - 始终成功
  async verify(options: { license?: string }) {
    console.log('[MOCK] Verifying...');
    updatePlusInfo({
      vipType: 'permanent',
      expireTime: new Date('2099-12-31').getTime(),
      isPlus: true,
      isComm: true,
    });
    return { success: true };
  }
}
```

### 影响的文件清单

替换 `@certd/plus-core` 会影响以下关键文件：

**服务层:**
- `packages/libs/lib-server/src/system/basic/service/plus-service.ts`
- `packages/ui/certd-server/src/modules/pipeline/service/pipeline-service.ts`
- `packages/ui/certd-server/src/modules/pipeline/service/notification-service.ts`
- `packages/ui/certd-server/src/modules/monitor/service/site-info-service.ts`
- `packages/ui/certd-server/src/modules/basic/service/email-service.ts`

**控制器:**
- `packages/ui/certd-server/src/controller/sys/plus/plus-controller.ts`
- `packages/ui/certd-server/src/controller/sys/account/account-controller.ts`
- `packages/ui/certd-server/src/controller/user/pipeline/template-controller.ts`
- `packages/ui/certd-server/src/controller/user/addon/addon-controller.ts`

**初始化:**
- `packages/ui/certd-server/src/modules/auto/auto-a-init-site.ts`
- `packages/ui/certd-server/src/modules/auto/auto-z.ts`

### pnpm overrides 原理

pnpm 的 overrides 机制允许强制覆盖依赖版本：

```json
{
  "pnpm": {
    "overrides": {
      "@certd/plus-core": "workspace:packages/libs/plus-core-mock"
    }
  }
}
```

效果：
1. 所有直接或间接依赖 `@certd/plus-core` 的包
2. 都会被强制替换为本地的 Mock 版本
3. `workspace:` 协议指向 monorepo 中的本地包

---

## 🎓 进阶: 其他破解方案

### 方案A: 直接修改源码

如果不想使用 Mock 模块，可以直接修改业务代码：

```typescript
// 在需要绕过验证的文件顶部添加
const isPlus = () => true;
const isComm = () => true;
const checkPlus = () => {};
const checkComm = () => {};

// 或者注释掉验证代码
// if (!isPlus()) {
//   throw new NeedVIPException("需要专业版");
// }
```

**缺点:**
- 需要修改多个文件
- 升级时会丢失修改
- 不够优雅

### 方案B: 修改异常类

修改 `packages/libs/lib-server/src/basic/exception/vip-exception.ts`:

```typescript
export class NeedVIPException extends BaseException {
  constructor(message?: string) {
    super('NeedVIPException', 0, 'VIP check bypassed');
    // 不抛出异常，直接返回
  }
}
```

**缺点:**
- 仍会显示错误，但不会中断
- 可能影响其他逻辑

### 方案C: 环境变量控制

在 Mock 模块中添加环境变量控制：

```typescript
export function isPlus(): boolean {
  return process.env.BYPASS_VIP === 'true' ? true : actualCheck();
}
```

启动时：
```bash
BYPASS_VIP=true npm start
```

---

## ⚠️ 重要声明

### 法律与道德

1. **本指南仅供学习研究使用**
2. 建议在生产环境购买正版授权
3. 支持开源项目，才能让它更好地发展
4. 根据 AGPL 协议，修改后的代码分发需要开源

### 购买正版的好处

- ✅ 官方技术支持
- ✅ 一对一远程协助  
- ✅ VIP 专属群
- ✅ 优先需求实现
- ✅ 支持项目持续发展

**购买地址:** [查看 README.md](./README.md) 中的捐赠章节

---

## 📚 相关文档

- [BYPASS_VIP.md](./BYPASS_VIP.md) - 详细技术文档
- [packages/libs/plus-core-mock/README.md](./packages/libs/plus-core-mock/README.md) - Mock模块说明
- [README.md](./README.md) - 项目主文档

---

## 🤝 贡献

如果你发现问题或有改进建议：

1. 提交 Issue
2. 发起 Pull Request
3. 联系项目维护者

---

**最后更新:** 2025-11-25

