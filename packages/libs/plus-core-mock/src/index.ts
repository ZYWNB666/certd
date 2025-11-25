// Mock version of @certd/plus-core to bypass VIP verification

export const AppKey = 'mock-app-key';

// Mock PlusInfo interface
export interface PlusInfo {
  vipType: string;
  expireTime: number;
  isPlus: boolean;
  isComm: boolean;
  originVipType?: string;  // 原始VIP类型，用于通知检查
  secret?: string;
}

// Global plus info - always return premium status
let plusInfo: PlusInfo = {
  vipType: 'comm',      // 商业版（最高级别）
  originVipType: 'comm', // 原始类型也设为商业版
  expireTime: new Date('2099-12-31').getTime(), // 设置为遥远的未来
  isPlus: true,
  isComm: true,
};

// Check if it's plus version - always return true
export function isPlus(): boolean {
  return true;
}

// Check if it's commercial version - always return true  
export function isComm(): boolean {
  return true;
}

// Check plus and throw error if not - do nothing (always pass)
export function checkPlus(): void {
  // Do nothing - always pass verification
}

// Check commercial and throw error if not - do nothing (always pass)
export function checkComm(): void {
  // Do nothing - always pass verification
}

// Get plus info - return mock premium info
export function getPlusInfo(): PlusInfo {
  return { ...plusInfo };
}

// Update plus info
export function updatePlusInfo(info: Partial<PlusInfo>): void {
  plusInfo = { ...plusInfo, ...info };
}

// Mock PlusRequestService
export class PlusRequestService {
  private subjectId: string;
  private _bindUrl?: string;
  private installTime?: number;
  private saveLicense?: (license: string) => Promise<void>;
  private plusServerBaseUrls: string[];

  constructor(options: {
    subjectId: string;
    bindUrl?: string;
    installTime?: number;
    saveLicense?: (license: string) => Promise<void>;
    plusServerBaseUrls?: string[];
  }) {
    this.subjectId = options.subjectId;
    this._bindUrl = options.bindUrl;
    this.installTime = options.installTime;
    this.saveLicense = options.saveLicense;
    this.plusServerBaseUrls = options.plusServerBaseUrls || [];
  }

  getSubjectId(): string {
    return this.subjectId;
  }

  getBaseURL(): string {
    return this.plusServerBaseUrls[0] || 'http://localhost';
  }

  // Mock active method - always succeed
  async active(code: string, inviteCode?: string): Promise<any> {
    console.log('[MOCK] Activating with code:', code);
    const mockLicense = 'MOCK-LICENSE-' + Date.now();
    
    // Update plus info to premium
    updatePlusInfo({
      vipType: 'comm',
      originVipType: 'comm',
      expireTime: new Date('2099-12-31').getTime(),
      isPlus: true,
      isComm: true,
    });

    // Save mock license if callback provided
    if (this.saveLicense) {
      await this.saveLicense(mockLicense);
    }

    return {
      success: true,
      license: mockLicense,
      message: 'Mock activation successful',
    };
  }

  // Mock verify method - always succeed
  async verify(options: { license?: string }): Promise<any> {
    console.log('[MOCK] Verifying license:', options.license);
    
    // Always update to premium status
    updatePlusInfo({
      vipType: 'comm',
      originVipType: 'comm',
      expireTime: new Date('2099-12-31').getTime(),
      isPlus: true,
      isComm: true,
    });

    return {
      success: true,
      vipType: 'comm',
      originVipType: 'comm',
      expireTime: new Date('2099-12-31').getTime(),
    };
  }

  // Mock updateLicense method - always succeed
  async updateLicense(options: { license: string }): Promise<any> {
    console.log('[MOCK] Updating license:', options.license);
    
    if (this.saveLicense) {
      await this.saveLicense(options.license);
    }

    updatePlusInfo({
      vipType: 'comm',
      originVipType: 'comm',
      expireTime: new Date('2099-12-31').getTime(),
      isPlus: true,
      isComm: true,
    });

    return {
      success: true,
    };
  }

  // Mock bindUrl method
  async bindUrl(url: string): Promise<any> {
    console.log('[MOCK] Binding URL:', url);
    this._bindUrl = url;
    return {
      success: true,
    };
  }

  // Mock register method
  async register(): Promise<any> {
    console.log('[MOCK] Registering site');
    return {
      success: true,
      license: 'MOCK-LICENSE-' + Date.now(),
    };
  }

  // Mock getAccessToken method
  async getAccessToken(): Promise<any> {
    return {
      accessToken: 'mock-access-token-' + Date.now(),
      expiresIn: Date.now() + 3600000, // 1 hour
    };
  }

  // Mock request method
  async request(config: any): Promise<any> {
    console.log('[MOCK] Request:', config.url);
    
    // Handle email sending with custom API
    if (config.url?.includes('/emailSend')) {
      return await this.sendEmailViaCustomAPI(config.data);
    }
    
    // Handle different request types
    if (config.url?.includes('/vip/trialGet')) {
      return {
        license: 'MOCK-TRIAL-LICENSE-' + Date.now(),
        duration: 365, // 365 days trial
      };
    }

    return {
      code: 0,
      data: {},
      message: 'Mock request successful',
    };
  }

  // Send email via custom API
  private async sendEmailViaCustomAPI(emailData: any): Promise<any> {
    try {
      // Prepare email content
      const htmlContent = emailData.html || emailData.text || '';
      const mailList = Array.isArray(emailData.to) ? emailData.to.join(',') : emailData.to;
      
      // Custom API configuration
      const apiUrl = 'https://mail.netwebs.top/send';
      const token = 'token-0hfgh80cb58e388fac923965hib0';
      
      // Prepare form data
      const formData = new URLSearchParams();
      formData.append('mail', mailList);
      formData.append('subject', emailData.subject);
      formData.append('html_content', htmlContent);
      
      console.log('[MOCK] Sending email via custom API:', { to: mailList, subject: emailData.subject });
      
      // Send request to custom API using built-in fetch (Node.js 18+)
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString(),
      });
      
      const result = await response.text();
      console.log('[MOCK] Email sent successfully:', result);
      
      return {
        code: 0,
        data: { success: true },
        message: 'Email sent via custom API',
      };
    } catch (error: any) {
      console.error('[MOCK] Failed to send email:', error.message);
      throw new Error(`邮件发送失败: ${error.message}`);
    }
  }

  // Mock requestWithoutSign method
  async requestWithoutSign(config: any): Promise<any> {
    console.log('[MOCK] Request without sign:', config.url);
    return {
      code: 0,
      data: {},
      message: 'Mock request successful',
    };
  }

  // Mock sign method
  async sign(body: any, timestamps: number): Promise<any> {
    return {
      signature: 'mock-signature',
      timestamps,
    };
  }
}

// Export everything
export default {
  AppKey,
  isPlus,
  isComm,
  checkPlus,
  checkComm,
  getPlusInfo,
  updatePlusInfo,
  PlusRequestService,
};

