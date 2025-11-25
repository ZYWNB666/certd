// Mock version of @certd/commercial-core to bypass Suite/Commercial verification

import { Configuration as MidwayConfiguration } from '@midwayjs/core';

// ========================================
// Entity Definitions
// ========================================

export class UserSuiteEntity {
  id: number;
  userId: number;
  suiteId: number;
  startTime: number;
  endTime: number;
  status: string;
  pipelineCount: { used: number; max: number };
  domainCount: { used: number; max: number };
  monitorCount: { used: number; max: number };
  deployCount: { used: number; max: number };

  constructor() {
    this.id = 1;
    this.userId = 1;
    this.suiteId = 999; // 最高级套餐
    this.startTime = Date.now();
    this.endTime = new Date('2099-12-31').getTime();
    this.status = 'active';
    // -1 表示无限制
    this.pipelineCount = { used: 0, max: -1 };
    this.domainCount = { used: 0, max: -1 };
    this.monitorCount = { used: 0, max: -1 };
    this.deployCount = { used: 0, max: -1 };
  }
}

export class SuiteEntity {
  id: number;
  name: string;
  price: number;
  pipelineCount: number;
  domainCount: number;
  monitorCount: number;
  deployCount: number;

  constructor() {
    this.id = 999;
    this.name = '旗舰版（破解）';
    this.price = 0;
    this.pipelineCount = -1; // 无限制
    this.domainCount = -1;
    this.monitorCount = -1;
    this.deployCount = -1;
  }
}

// ========================================
// Service Classes
// ========================================

export class UserSuiteService {
  // 获取套餐设置
  async getSuiteSetting(): Promise<any> {
    console.log('[MOCK Commercial] Getting suite setting - disabled');
    return {
      enabled: false, // 禁用套餐限制
      suites: [new SuiteEntity()],
    };
  }

  // 获取用户套餐详情
  async getMySuiteDetail(userId: number): Promise<UserSuiteEntity> {
    console.log('[MOCK Commercial] Getting user suite detail for user:', userId);
    return new UserSuiteEntity();
  }

  // 检查是否有部署次数
  async checkHasDeployCount(userId: number): Promise<UserSuiteEntity> {
    console.log('[MOCK Commercial] Checking deploy count for user:', userId);
    return new UserSuiteEntity();
  }

  // 消耗部署次数
  async consumeDeployCount(suite: UserSuiteEntity, count: number): Promise<void> {
    console.log('[MOCK Commercial] Consuming deploy count:', count, '(no-op)');
    // 不做任何操作
  }

  // 赠送套餐
  async presentGiftSuite(userId: number): Promise<void> {
    console.log('[MOCK Commercial] Presenting gift suite to user:', userId, '(no-op)');
    // 不做任何操作
  }

  // 获取用户套餐
  async getUserSuite(userId: number): Promise<UserSuiteEntity> {
    console.log('[MOCK Commercial] Getting user suite for user:', userId);
    return new UserSuiteEntity();
  }

  // 创建或更新用户套餐
  async createOrUpdateUserSuite(userId: number, suiteId: number): Promise<UserSuiteEntity> {
    console.log('[MOCK Commercial] Creating/updating user suite:', userId, suiteId);
    return new UserSuiteEntity();
  }
}

// 使用计数服务接口
export interface IUsedCountService {
  getUsedCount(userId: number): Promise<{
    pipelineCountUsed: number;
    domainCountUsed: number;
    monitorCountUsed: number;
  }>;
}

// ========================================
// Entities Export (for TypeORM)
// ========================================

export const commercialEntities = [
  // 返回空数组，因为我们不需要实际的数据库实体
  // 或者可以返回 Mock 实体（但通常不需要）
];

// ========================================
// Configuration (for Midway Framework)
// ========================================

@MidwayConfiguration({
  namespace: 'commercial-core',
})
export class CommercialCoreConfiguration {
  async onReady() {
    console.log('[MOCK Commercial] Commercial Core Mock module loaded - all limitations bypassed');
  }
}

// Export Configuration as the default export name that Midway expects
export { CommercialCoreConfiguration as Configuration };

// ========================================
// Export Everything
// ========================================

export default {
  UserSuiteEntity,
  SuiteEntity,
  UserSuiteService,
  commercialEntities,
};

