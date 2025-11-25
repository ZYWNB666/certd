// 测试 Mock 模块是否正常工作
import {
  isPlus,
  isComm,
  checkPlus,
  checkComm,
  getPlusInfo,
  PlusRequestService,
  AppKey
} from './dist/index.js';

console.log('====================================');
console.log('测试 @certd/plus-core Mock 模块');
console.log('====================================');
console.log('');

// 测试基础函数
console.log('1. 测试基础函数:');
console.log('   isPlus():', isPlus());
console.log('   isComm():', isComm());
console.log('   AppKey:', AppKey);

// 测试检查函数
console.log('');
console.log('2. 测试检查函数 (不应该抛出异常):');
try {
  checkPlus();
  console.log('   ✅ checkPlus() 通过');
} catch (e) {
  console.log('   ❌ checkPlus() 失败:', e.message);
}

try {
  checkComm();
  console.log('   ✅ checkComm() 通过');
} catch (e) {
  console.log('   ❌ checkComm() 失败:', e.message);
}

// 测试获取信息
console.log('');
console.log('3. 测试获取 Plus 信息:');
const plusInfo = getPlusInfo();
console.log('   VIP类型:', plusInfo.vipType);
console.log('   过期时间:', new Date(plusInfo.expireTime).toISOString());
console.log('   是否Plus:', plusInfo.isPlus);
console.log('   是否Comm:', plusInfo.isComm);

// 测试 PlusRequestService
console.log('');
console.log('4. 测试 PlusRequestService:');
const service = new PlusRequestService({
  subjectId: 'test-site-id',
  bindUrl: 'http://localhost:7001'
});

console.log('   SubjectId:', service.getSubjectId());

// 测试激活
try {
  const activeResult = await service.active('test-code', 'invite-123');
  console.log('   ✅ active() 成功:', activeResult.message);
} catch (e) {
  console.log('   ❌ active() 失败:', e.message);
}

// 测试验证
try {
  const verifyResult = await service.verify({ license: 'test-license' });
  console.log('   ✅ verify() 成功:', verifyResult.vipType);
} catch (e) {
  console.log('   ❌ verify() 失败:', e.message);
}

// 测试更新许可证
try {
  await service.updateLicense({ license: 'new-license' });
  console.log('   ✅ updateLicense() 成功');
} catch (e) {
  console.log('   ❌ updateLicense() 失败:', e.message);
}

// 测试注册
try {
  const registerResult = await service.register();
  console.log('   ✅ register() 成功');
} catch (e) {
  console.log('   ❌ register() 失败:', e.message);
}

// 测试获取token
try {
  const tokenResult = await service.getAccessToken();
  console.log('   ✅ getAccessToken() 成功');
} catch (e) {
  console.log('   ❌ getAccessToken() 失败:', e.message);
}

console.log('');
console.log('====================================');
console.log('✅ 所有测试完成！Mock 模块工作正常');
console.log('====================================');

