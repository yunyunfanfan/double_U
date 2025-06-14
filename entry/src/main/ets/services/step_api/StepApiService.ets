// jifen/StepApiService.ets
import { http } from '@kit.NetworkKit';


// 步数保存请求
export interface StepsSaveRequest {
  user_id: number;
  steps: number;
  record_date?: string;
}

// 步数保存响应
export interface StepsSaveResponse {
  success: boolean;
  message: string;
  points_earned?: number;
  total_points?: number;
}

export interface AddPointsRequest {
  user_id: number;
  points: number;
  source_type: string;
  source_data: string;
}

// 步数历史记录项
export interface StepsHistoryItem {
  id: number;
  steps: number;
  points_earned: number;
  record_date: string;
  created_at: string;
}

// 步数历史响应
export interface StepsHistoryResponse {
  success: boolean;
  records?: StepsHistoryItem[];
  message?: string;
}

// 用户积分信息
export interface UserPointsInfo {
  user_id: number;
  total_points: number;
  updated_at: string;
}

// 积分信息响应
export interface UserPointsResponse {
  success: boolean;
  data?: UserPointsInfo;
  message?: string;
}

export class StepsApiService {
  private baseUrl: string = 'http://172.23.41.252:5000/api';

  async savePoints(userId: number, points: number, sourceType: string = 'manual'): Promise<StepsSaveResponse> {
    const httpRequest = http.createHttp();

    try {
      console.info(`[积分服务] 为用户${userId}添加积分: ${points}`);

      const requestData: AddPointsRequest = {
        user_id: userId,
        points: points,
        source_type: sourceType,
        source_data: `手动录入积分: ${points}`
      };

      const response = await httpRequest.request(`${this.baseUrl}/add-points`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(requestData),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: StepsSaveResponse = JSON.parse(responseText) as StepsSaveResponse;

      console.info(`[积分服务] 保存结果:`, JSON.stringify(result));
      return result;
    } catch (error) {
      console.error('[积分服务] 保存积分异常:', error);
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }

  async getStepsHistory(userId: number, days: number = 30): Promise<StepsHistoryResponse> {
    const httpRequest = http.createHttp();

    try {
      console.info(`[步数服务] 获取用户${userId}的步数历史，天数: ${days}`);

      const response = await httpRequest.request(`${this.baseUrl}/steps-history/${userId}?days=${days}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: StepsHistoryResponse = JSON.parse(responseText) as StepsHistoryResponse;

      console.info(`[步数服务] 历史记录获取完成，记录数: ${result.records?.length || 0}`);
      return result;
    } catch (error) {
      console.error('[步数服务] 获取历史记录异常:', error);
      const errorResponse: StepsHistoryResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async getUserPoints(userId: number): Promise<UserPointsResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/user-points/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: UserPointsResponse = JSON.parse(responseText) as UserPointsResponse;
      return result;
    } catch (error) {
      const errorResponse: UserPointsResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }
}

export const stepsApiService: StepsApiService = new StepsApiService();