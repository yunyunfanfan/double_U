import { http } from '@kit.NetworkKit';

export interface RegisterRequest {
  phone: string;
  username: string;
  password: string;
}
export interface HealthOverviewData {
  steps: number;
  avg_heart_rate: number;
  sleep_score: number;
  active_calories: number;
  blood_oxygen: number;
  current_mood: number;
}

export interface HealthOverviewResponse {
  success: boolean;
  data?: HealthOverviewData;
  message?: string;
}
export interface HealthDataRequest {
  user_id: number;
  record_date?: string;
  steps?: number;
  steps_goal?: number;
  distance?: number;
  calories_burned?: number;
  current_heart_rate?: number;
  resting_heart_rate?: number;
  min_heart_rate?: number;
  avg_heart_rate?: number;
  max_heart_rate?: number;
  current_blood_oxygen?: number;
  min_blood_oxygen?: number;
  avg_blood_oxygen?: number;
  max_blood_oxygen?: number;
  sleep_score?: number;
  sleep_duration?: number;
  sleep_start_time?: string;
  sleep_end_time?: string;
  deep_sleep_duration?: number;
  light_sleep_duration?: number;
  rem_sleep_duration?: number;
  awake_duration?: number;
  active_calories?: number;
  calories_goal?: number;
  activity_calories?: number;
  basic_metabolism_calories?: number;
  current_mood?: number;
  calm_percentage?: number;
  anxiety_percentage?: number;
  fatigue_percentage?: number;
  joy_percentage?: number;
  satisfaction_percentage?: number;
}

export interface RealtimeDataRequest {
  user_id: number;
  record_date?: string;
  time_stamp: string;
  data_type: string;
  value: number;
}

export interface HealthDataResponse {
  success: boolean;
  message: string;
  data?: HealthDataRequest[];
}

export interface RealtimeDataResponse {
  success: boolean;
  message: string;
  data?: RealtimeDataRequest[];
}

export interface StepsRankingItem {
  rank: number;
  username: string;
  steps: number;
}

export interface OverviewData {
  steps: number;
  avg_heart_rate: number;
  sleep_score: number;
  active_calories: number;
  blood_oxygen: number;
}

export interface StepsRankingResponse {
  success: boolean;
  ranking?: Array<StepsRankingItem>;
}

export interface OverviewResponse {
  success: boolean;
  data?: OverviewData;
}

export interface ResetPasswordRequest {
  username: string;
  new_password: string;
}

export interface ResetPasswordResponse {
  success: boolean;
  message: string;
}


export interface RegisterResponse {
  success: boolean;
  message: string;
  user_id?: number;
  username?: string;
  phone?: string;
}

export interface LoginRequest {
  login_field: string;
  password: string;
}

export interface LoginResponse {
  success: boolean;
  message: string;
  user_id?: number;
  username?: string;
  phone?: string;
  avatar_path?: string;
}

export interface HealthCheckResponse {
  success: boolean;
  message: string;
  timestamp?: string;
}

export interface CheckExistsResponse {
  exists: boolean;
}

// 添加健康数据汇总类
export class HealthDataSummary {
  steps: string;
  heartRate: string;
  bloodOxygen: string;
  sleep: string;
  calories: string;
  mood: string;

  constructor(steps: string, heartRate: string, bloodOxygen: string, sleep: string, calories: string, mood: string) {
    this.steps = steps;
    this.heartRate = heartRate;
    this.bloodOxygen = bloodOxygen;
    this.sleep = sleep;
    this.calories = calories;
    this.mood = mood;
  }
}

export class UserApiService {
  private baseUrl: string = 'http://172.23.171.45:5000/api';

  // 在UserApiService类中添加以下方法
  private currentUserId: number = 1;

  setCurrentUserId(userId: number): void {
    this.currentUserId = userId;
    console.info(`[健康数据服务] 设置当前用户ID: ${userId}`);
  }

  async getLatestHealthData(): Promise<HealthDataSummary> {
    try {
      console.info(`[健康数据服务] 开始获取用户${this.currentUserId}的最新健康数据`);

      // 先尝试调用overview接口，获取HealthOverviewResponse类型
      let overviewResponse = await this.getCurrentHealthData(this.currentUserId);
      console.info(`[健康数据服务] Overview接口返回:`, JSON.stringify(overviewResponse));

      if (overviewResponse.success && overviewResponse.data) {
        let data: HealthOverviewData = overviewResponse.data;

        console.info(`[健康数据服务] 健康数据获取成功:`, JSON.stringify(data));

        return new HealthDataSummary(
          `${data.steps}步`,
          `${data.avg_heart_rate}bpm`,
          `${data.blood_oxygen}%`,
          `${data.sleep_score}分`,
          `${data.active_calories}Kcal`,
          this.getMoodText(data.current_mood || 5)
        );
      } else {
        console.error('[健康数据服务] 获取健康数据失败:', overviewResponse.message);
        return this.getDefaultHealthData();
      }
    } catch (error) {
      console.error('[健康数据服务] 获取健康数据异常:', error);
      return this.getDefaultHealthData();
    }
  }

  private getMoodText(value: number): string {
    if (value >= 8) return '开心';
    if (value >= 6) return '满足';
    if (value >= 4) return '平静';
    if (value >= 2) return '疲惫';
    return '焦虑';
  }

  private getDefaultHealthData(): HealthDataSummary {
    console.info('[健康数据服务] 使用默认健康数据');
    return new HealthDataSummary('0步', '0bpm', '0%', '0分', '0Kcal', '一般');
  }

  async register(phone: string, username: string, password: string): Promise<RegisterResponse> {
    const httpRequest = http.createHttp();

    try {
      const requestData: RegisterRequest = {
        phone: phone,
        username: username,
        password: password
      };

      const response = await httpRequest.request(`${this.baseUrl}/register`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestData),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: RegisterResponse = JSON.parse(responseText) as RegisterResponse;
      return result;
    } catch (error) {
      const errorResponse: RegisterResponse = {
        success: false,
        message: '网络连接失败，请检查网络设置'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async login(loginField: string, password: string): Promise<LoginResponse> {
    const httpRequest = http.createHttp();

    try {
      const requestData: LoginRequest = {
        login_field: loginField,
        password: password
      };

      const response = await httpRequest.request(`${this.baseUrl}/login`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestData),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: LoginResponse = JSON.parse(responseText) as LoginResponse;
      return result;
    } catch (error) {
      const errorResponse: LoginResponse = {
        success: false,
        message: '网络连接失败，请检查网络设置'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async resetPassword(username: string, newPassword: string): Promise<ResetPasswordResponse> {
    const httpRequest = http.createHttp();

    try {
      const requestData: ResetPasswordRequest = {
        username: username,
        new_password: newPassword
      };

      const response = await httpRequest.request(`${this.baseUrl}/reset-password`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestData),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: ResetPasswordResponse = JSON.parse(responseText) as ResetPasswordResponse;
      return result;
    } catch (error) {
      const errorResponse: ResetPasswordResponse = {
        success: false,
        message: '网络连接失败，请检查网络设置'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async healthCheck(): Promise<boolean> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/health-check`, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      });

      const responseText: string = response.result as string;
      const result: HealthCheckResponse = JSON.parse(responseText) as HealthCheckResponse;
      return result.success === true;
    } catch (error) {
      return false;
    } finally {
      httpRequest.destroy();
    }
  }
  async saveHealthData(healthData: HealthDataRequest): Promise<RegisterResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/health-data`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(healthData),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: RegisterResponse = JSON.parse(responseText) as RegisterResponse;
      return result;
    } catch (error) {
      const errorResponse: RegisterResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async saveRealtimeData(realtimeData: RealtimeDataRequest): Promise<RegisterResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/realtime-data`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(realtimeData),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: RegisterResponse = JSON.parse(responseText) as RegisterResponse;
      return result;
    } catch (error) {
      const errorResponse: RegisterResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async getHealthData(userId: number, days: number = 7): Promise<HealthDataResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/health-data/${userId}?days=${days}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: HealthDataResponse = JSON.parse(responseText) as HealthDataResponse;
      return result;
    } catch (error) {
      const errorResponse: HealthDataResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async getRealtimeData(userId: number, dataType?: string, days?: number): Promise<RealtimeDataResponse> {
    let httpRequest = http.createHttp();

    try {
      let url: string = `${this.baseUrl}/realtime-data/${userId}`;
      let params: string[] = [];

      if (dataType) {
        params.push(`type=${dataType}`);
      }
      if (days) {
        params.push(`days=${days}`);
      }

      if (params.length > 0) {
        url += `?${params.join('&')}`;
      }

      let response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      let responseText: string = response.result as string;
      let result: RealtimeDataResponse = JSON.parse(responseText) as RealtimeDataResponse;
      return result;
    } catch (error) {
      return {
        success: false,
        message: '网络连接失败'
      };
    } finally {
      httpRequest.destroy();
    }
  }

  async getStepsRanking(): Promise<StepsRankingResponse> {
    let httpRequest = http.createHttp();

    try {
      let response = await httpRequest.request(`${this.baseUrl}/steps-ranking`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      let responseText: string = response.result as string;
      let result: StepsRankingResponse = JSON.parse(responseText) as StepsRankingResponse;
      return result;
    } catch (error) {
      let errorResponse: StepsRankingResponse = {
        success: false
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async getOverview(userId: number): Promise<OverviewResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/overview/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: OverviewResponse = JSON.parse(responseText) as OverviewResponse;
      return result;
    } catch (error) {
      const errorResponse: OverviewResponse = {
        success: false
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  // 在现有方法后添加
  async getWeeklySteps(userId: number): Promise<HealthDataResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/weekly-steps/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: HealthDataResponse = JSON.parse(responseText) as HealthDataResponse;
      return result;
    } catch (error) {
      const errorResponse: HealthDataResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async getWeeklySleep(userId: number): Promise<HealthDataResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/weekly-sleep/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: HealthDataResponse = JSON.parse(responseText) as HealthDataResponse;
      return result;
    } catch (error) {
      const errorResponse: HealthDataResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async getWeeklyCalories(userId: number): Promise<HealthDataResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/weekly-calories/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: HealthDataResponse = JSON.parse(responseText) as HealthDataResponse;
      return result;
    } catch (error) {
      const errorResponse: HealthDataResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }
  async getCurrentHealthData(userId: number): Promise<HealthOverviewResponse> {
    let httpRequest = http.createHttp();

    try {
      console.info(`[健康数据服务] 开始获取用户${userId}的当前健康数据`);

      let response = await httpRequest.request(`${this.baseUrl}/overview/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      let responseText: string = response.result as string;
      let result: HealthOverviewResponse = JSON.parse(responseText) as HealthOverviewResponse;

      console.info(`[健康数据服务] 健康数据获取完成:`, JSON.stringify(result));
      return result;
    } catch (error) {
      console.error(`[健康数据服务] 获取健康数据失败:`, error);
      return {
        success: false,
        message: '网络连接失败'
      };
    } finally {
      httpRequest.destroy();
    }
  }
}


export const userApiService: UserApiService = new UserApiService();