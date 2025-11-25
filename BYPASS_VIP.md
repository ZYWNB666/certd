# 绕过VIP验证机制说明

## 已实现的修改

### 1. 创建 Mock 模块

已创建 `packages/libs/plus-core-mock` 目录，包含：

- **package.json** - Mock模块的包配置
- **src/index.ts** - Mock实现，所有验证函数始终返回true/成功
- **tsconfig.json** - TypeScript配置
- **README.md** - 使用说明

### 2. Mock 功能说明

Mock模块实现了以下关键函数，全部绕过验证：

```typescript
// 检查是否为专业版 - 始终返回 true
export function isPlus(): boolean {
  return true;
}

// 检查是否为商业版 - 始终返回 true
export function isComm(): boolean {
  return true;
}

// 专业版验证 - 不抛出异常
export function checkPlus(): void {
  // 空实现，始终通过
}

// 商业版验证 - 不抛出异常
export function checkComm(): void {
  // 空实现，始终通过
}

// 获取VIP信息 - 返回永久专业版
export function getPlusInfo(): PlusInfo {
  return {
    vipType: 'permanent',
    expireTime: new Date('2099-12-31').getTime(),
    isPlus: true,
    isComm: true,
  };
}
```

### 3. PlusRequestService Mock

Mock了所有与授权服务器的交互：

- `active()` - 激活码验证，始终成功
- `verify()` - 许可证验证，始终成功
- `updateLicense()` - 更新许可证，始终成功
- `register()` - 站点注册，始终成功
- `getAccessToken()` - 获取访问令牌，返回mock token
- `request()` - 所有网络请求，返回成功响应

## 使用方法

### 步骤1: 编译 Mock 模块

```bash
cd packages/libs/plus-core-mock
npm install
npm run build
```

### 步骤2: 配置 pnpm overrides

根目录的 `package.json` 已添加 overrides 配置：

```json
{
  "pnpm": {
    "overrides": {
      "@certd/plus-core": "workspace:packages/libs/plus-core-mock"
    }
  }
}
```

### 步骤3: 重新安装依赖

```bash
# 删除旧的依赖
rm -rf node_modules
rm -rf packages/*/node_modules
rm pnpm-lock.yaml

# 重新安装
pnpm install
```

### 步骤4: 重新构建项目

```bash
# 构建所有包
pnpm run init

# 或者只构建server
cd packages/ui/certd-server
npm run build
```

### 步骤5: 启动项目

```bash
cd packages/ui/certd-server
npm start
```

## 验证是否生效

启动项目后，查看日志输出：

```
[MOCK] Verifying license: ...
=========================================
当前站点ID: xxx
当前版本:1.37.10
授权信息:permanent,2099-12-31    <--- 看到这个说明成功！
Certd已启动
=========================================
```

### 测试功能

1. **站点监控** - 应该不再限制只能添加1条
2. **通知功能** - 企微、钉钉、飞书等专业版通知应该可用
3. **流水线数量** - 不再有限制
4. **插件功能** - 群晖等专业版插件应该可用

## 影响的文件

Mock替换会影响所有使用 `@certd/plus-core` 的文件：

- `packages/libs/lib-server/src/system/basic/service/plus-service.ts`
- `packages/ui/certd-server/src/modules/pipeline/service/pipeline-service.ts`
- `packages/ui/certd-server/src/modules/pipeline/service/notification-service.ts`
- `packages/ui/certd-server/src/modules/monitor/service/site-info-service.ts`
- `packages/ui/certd-server/src/modules/basic/service/email-service.ts`
- 以及其他所有导入该模块的文件

## 原理说明

1. **pnpm overrides** 机制会强制所有包使用指定的版本
2. 我们的 Mock 模块使用 `workspace:` 协议指向本地mock实现
3. Mock模块与原模块导出相同的接口，但所有验证都返回成功
4. 由于所有验证逻辑都在 `@certd/plus-core` 中，替换后即可绕过所有限制

## 注意事项

⚠️ **重要提示**：

1. 此方法仅供学习研究使用
2. 修改后的代码仅在本地生效，不影响其他用户
3. 建议在生产环境购买正版授权以支持作者
4. 根据AGPL协议，修改后的代码如果分发需要开源

## 故障排除

### 如果修改未生效：

1. 确认 pnpm-lock.yaml 已删除并重新生成
2. 确认 node_modules 已完全删除
3. 检查 mock 模块是否编译成功（dist目录是否存在）
4. 查看启动日志是否有 `[MOCK]` 前缀的输出

### 如果出现编译错误：

```bash
# 清理并重新构建
pnpm run clean  # 如果有clean脚本
rm -rf packages/*/dist
pnpm run init
```

## 进阶：直接修改源码（备选方案）

如果不想使用Mock模块，也可以直接修改验证逻辑的调用处：

### 方案A: 注释掉检查代码

找到所有 `checkPlus()`, `checkComm()`, `isPlus()`, `isComm()` 的调用，注释掉或修改：

```typescript
// 原代码
if (!isPlus()) {
  throw new NeedVIPException("需要专业版");
}

// 修改为
// if (!isPlus()) {
//   throw new NeedVIPException("需要专业版");
// }
```

### 方案B: 修改异常处理

在文件开头添加mock函数：

```typescript
// 在文件顶部添加
const isPlus = () => true;
const isComm = () => true;
const checkPlus = () => {};
const checkComm = () => {};
```

但这种方法需要修改多个文件，不如使用Mock模块方便。

## 总结

使用Mock模块是最简单、最彻底的方案，一次配置即可全局生效，无需修改业务代码。

