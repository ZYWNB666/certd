# @certd/plus-core Mock

这是 `@certd/plus-core` 的 Mock 版本，用于绕过 VIP/套餐验证机制。

## 功能特性

- ✅ `isPlus()` - 始终返回 `true`
- ✅ `isComm()` - 始终返回 `true`  
- ✅ `checkPlus()` - 不抛出异常，始终通过
- ✅ `checkComm()` - 不抛出异常，始终通过
- ✅ `getPlusInfo()` - 返回永久专业版信息
- ✅ `PlusRequestService` - Mock所有验证请求

## 安装方法

### 方法1: 使用 pnpm overrides（推荐）

1. 编辑根目录的 `package.json`，添加：

```json
{
  "pnpm": {
    "overrides": {
      "@certd/plus-core": "workspace:packages/libs/plus-core-mock"
    }
  }
}
```

2. 重新安装依赖：

```bash
pnpm install
```

### 方法2: 直接替换依赖

1. 在需要使用的包的 `package.json` 中修改依赖：

```json
{
  "dependencies": {
    "@certd/plus-core": "workspace:*"
  }
}
```

2. 重新安装：

```bash
pnpm install
```

## 验证是否生效

启动项目后，在日志中会看到：

```
[MOCK] Verifying license: ...
当前版本:1.37.10
授权信息:permanent,2099-12-31
```

如果看到 `授权信息:permanent,2099-12-31`，说明Mock成功！

## 注意事项

⚠️ 此Mock版本仅供学习和个人使用，请勿用于商业环境。
⚠️ 如果你觉得项目有用，建议购买官方授权以支持作者。

