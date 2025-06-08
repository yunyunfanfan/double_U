import { http } from '@kit.NetworkKit';

export interface RegisterRequest {
  phone: string;
  username: string;
  password: string;
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

export class UserApiService {
  private baseUrl: string = 'http://172.23.171.45:5000/api';

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

  async getStepsRanking(): Promise<StepsRankingResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/steps-ranking`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: StepsRankingResponse = JSON.parse(responseText) as StepsRankingResponse;
      return result;
    } catch (error) {
      const errorResponse: StepsRankingResponse = {
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
}


export const userApiService: UserApiService = new UserApiService();