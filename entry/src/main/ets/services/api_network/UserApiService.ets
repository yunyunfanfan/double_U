import { http } from '@kit.NetworkKit';

export interface RegisterRequest {
  phone: string;
  username: string;
  password: string;
}


export interface AvatarUploadResponse {
  success: boolean;
  message: string;
  avatar_url?: string;
}

export interface UserProfileData {
  user_id: number;
  username: string;
  phone: string;
  avatar_url: string;
}

export interface UserProfileResponse {
  success: boolean;
  data?: UserProfileData;
  message?: string;
}

export interface AvatarUploadRequest {
  user_id: number;
  avatar_file: string;
}


export interface HealthOverviewData {
  steps: number;
  current_heart_rate: number;
  avg_heart_rate: number;  // 添加这个字段
  sleep_score: number;

  active_calories: number;
  basic_metabolism_calories: number;
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

export interface FamilyMember {
  id: number;
  username: string;
  phone: string;
  relationship_name: string;
  added_at: string;
}

export interface FamilyMembersResponse {
  success: boolean;
  members?: FamilyMember[];
  message?: string;
}

export interface UserInfo {
  id: number;
  username: string;
  phone: string;
}

export interface SearchUserResponse {
  success: boolean;
  user?: UserInfo;
  message?: string;
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

// 添加响应实现类
class FriendsListResponseImpl implements FriendsListResponse {
  success: boolean;
  friends?: FriendItem[];
  message?: string;

  constructor(success: boolean, friends?: FriendItem[], message?: string) {
    this.success = success;
    this.friends = friends;
    this.message = message;
  }
}

export class FriendItem {
  id: number;
  username: string;
  phone: string;
  avatar_url: string;
  relationship_name: string;
  added_at: string;

  constructor(id: number, username: string, phone: string, avatar_url: string, relationship_name: string, added_at: string) {
    this.id = id;
    this.username = username;
    this.phone = phone;
    this.avatar_url = avatar_url;
    this.relationship_name = relationship_name;
    this.added_at = added_at;
  }
}

export interface FriendsListResponse {
  success: boolean;
  friends?: FriendItem[];
  message?: string;
}

export interface StepsRankingItem {
  rank: number;
  username: string;
  steps: number;
}

export interface OverviewData {
  steps: number;
  current_heart_rate: number;
  sleep_score: number;
  basic_metabolism_calories: number;
  current_mood: number;
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
  message?: string;
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

// 删除好友接口
export interface RemoveFamilyMemberRequest {
  user_id: number;
  member_id: number;
}

// 所有用户列表接口
export interface AllUsersResponse {
  success: boolean;
  users?: UserWithFriendStatus[];
  message?: string;
}

export interface UserWithFriendStatus {
  id: number;
  username: string;
  phone: string;
  avatar_url: string;
  is_friend: boolean;
}


export interface HealthCheckResponse {
  success: boolean;
  message: string;
  timestamp?: string;
}


export interface UpdateUsernameRequest {
  user_id: number;
  new_username: string;
}

export interface UpdateUsernameResponse {
  success: boolean;
  message: string;
  new_username?: string;
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
  private static readonly BASE_URL: string = 'http://172.23.100.9:5000';
  private baseUrl: string = `${UserApiService.BASE_URL}/api`;

  static getAvatarUrl(avatarPath: string): string {
    if (!avatarPath || avatarPath.trim() === '') {
      return '';
    }
    return avatarPath.startsWith('/static/') ? `${UserApiService.BASE_URL}${avatarPath}` : avatarPath;
  }

  static getDefaultAvatarUrl(): string {
    console.info(`调用了defult`);
    return 'https://gitee.com/zhaozehe/zako/raw/master/ic_535a5f26fa59f35f023467562ae1388e.png';
  }

  static getUserDisplayAvatar(avatarUrl: string): string {
    const processedUrl = UserApiService.getAvatarUrl(avatarUrl);
    const result = processedUrl || UserApiService.getDefaultAvatarUrl();
    console.info(`[UserApiService] 获取用户头像URL - 输入: ${avatarUrl}, 输出: ${result}`);
    return result;
  }

  // 在UserApiService类中添加以下方法
  private currentUserId: number = 1;

  setCurrentUserId(userId: number): void {
    this.currentUserId = userId;
    console.info(`[健康数据服务] 设置当前用户ID: ${userId}`);
  }


  async removeFamilyMember(userId: number, memberId: number): Promise<RegisterResponse> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(`${this.baseUrl}/remove-family-member`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ user_id: userId, member_id: memberId }),
        connectTimeout: 10000,
        readTimeout: 10000
      });
      const responseText: string = response.result as string;
      return JSON.parse(responseText) as RegisterResponse;
    } catch (error) {
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }

  async getAllUsers(currentUserId: number): Promise<AllUsersResponse> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(`${this.baseUrl}/all-users/${currentUserId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });
      const responseText: string = response.result as string;
      return JSON.parse(responseText) as AllUsersResponse;
    } catch (error) {
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }

  async updateUsername(userId: number, newUsername: string): Promise<UpdateUsernameResponse> {
    const httpRequest = http.createHttp();

    try {
      console.info(`[用户名更新] 开始更新用户${userId}的用户名为: ${newUsername}`);

      const requestData: UpdateUsernameRequest = {
        user_id: userId,
        new_username: newUsername
      };

      const response = await httpRequest.request(`${this.baseUrl}/update-username`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestData),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: UpdateUsernameResponse = JSON.parse(responseText) as UpdateUsernameResponse;

      console.info(`[用户名更新] 更新结果: ${result.success}`);
      return result;
    } catch (error) {
      console.error('[用户名更新] 更新异常:', error);
      return {
        success: false,
        message: '网络连接失败'
      };
    } finally {
      httpRequest.destroy();
    }
  }

  async uploadAvatar(userId: number, avatarBase64: string): Promise<AvatarUploadResponse> {
    const httpRequest = http.createHttp();

    try {
      console.info(`[头像上传] 开始上传用户${userId}的头像`);

      const requestData: AvatarUploadRequest = {
        user_id: userId,
        avatar_file: avatarBase64
      };

      const response = await httpRequest.request(`${this.baseUrl}/upload-avatar`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestData),
        connectTimeout: 15000,
        readTimeout: 15000
      });

      const responseText: string = response.result as string;
      const result: AvatarUploadResponse = JSON.parse(responseText) as AvatarUploadResponse;

      console.info(`[头像上传] 上传结果: ${result.success}`);
      return result;
    } catch (error) {
      console.error('[头像上传] 上传异常:', error);
      return {
        success: false,
        message: '网络连接失败'
      };
    } finally {
      httpRequest.destroy();
    }
  }

  async getUserProfile(userId: number): Promise<UserProfileResponse> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${this.baseUrl}/user-profile/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: UserProfileResponse = JSON.parse(responseText) as UserProfileResponse;
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

  async getLatestHealthData(): Promise<HealthDataSummary> {
    try {
      console.info(`[健康数据服务] 开始获取用户${this.currentUserId}的最新健康数据`);

      // 先尝试调用overview接口，获取HealthOverviewResponse类型
      let overviewResponse = await this.getCurrentHealthData(this.currentUserId);
      console.info(`[健康数据服务] Overview接口返回:`, JSON.stringify(overviewResponse));

      if (overviewResponse.success && overviewResponse.data) {
        let data: HealthOverviewData = overviewResponse.data;

        console.info(`[健康数据服务] 健康数据获取成功:`, JSON.stringify(data));
        const activeCalories = data.active_calories || 0;
        const basicCalories = data.basic_metabolism_calories || 0;
        console.info(`[健康数据调试] 活动热量: ${activeCalories}Kcal, 基础代谢热量: ${basicCalories}Kcal, 总热量: ${activeCalories + basicCalories}Kcal`);
        return new HealthDataSummary(
          `${data.steps}步`,
          `${data.current_heart_rate || 0}bpm`,
          `${data.blood_oxygen}%`,
          `${data.sleep_score}分`,
          `${(data.active_calories || 0) + (data.basic_metabolism_calories || 0)}Kcal`,
          this.getMoodText(data.current_mood || -1)
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
    if (value == -1) return '----'
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

  async getHealthData(userId: number, days: number = 7, onlyToday: boolean = false): Promise<HealthDataResponse> {
    const httpRequest = http.createHttp();

    try {
      console.info(`[健康数据服务] 获取用户${userId}的健康数据，天数: ${days}, 仅今日: ${onlyToday}`);

      const response = await httpRequest.request(`${this.baseUrl}/health-data/${userId}?days=${days}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: HealthDataResponse = JSON.parse(responseText) as HealthDataResponse;

      // 根据参数决定是否过滤今日数据
      if (onlyToday && result.success && result.data) {
        const today: string = new Date().toISOString().split('T')[0];
        console.info(`[健康数据服务] 过滤今日数据，日期: ${today}`);

        const todayData: HealthDataRequest[] = result.data.filter((item: HealthDataRequest) => {
          return item.record_date === today;
        });

        console.info(`[健康数据服务] 今日数据条数: ${todayData.length}`);
        result.data = todayData;
      }

      return result;
    } catch (error) {
      console.error(`[健康数据服务] 获取健康数据失败:`, error);
      const errorResponse: HealthDataResponse = {
        success: false,
        message: '网络连接失败'
      };
      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  async saveAIHealthData(healthData: HealthDataRequest): Promise<RegisterResponse> {
    const httpRequest = http.createHttp();

    try {
      console.info(`[AI健康数据] 保存用户${healthData.user_id}的健康数据`);

      const response = await httpRequest.request(`${this.baseUrl}/ai-health-data`, {
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

      console.info(`[AI健康数据] 保存结果: ${result.success}`);
      return result;
    } catch (error) {
      console.error('[AI健康数据] 保存异常:', error);
      const errorResponse: RegisterResponse = {
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

  async searchUserByPhone(phone: string, currentUserId: number): Promise<SearchUserResponse> {
    let httpRequest = http.createHttp();

    try {
      let response = await httpRequest.request(`${this.baseUrl}/search-users?phone=${phone}&current_user_id=${currentUserId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      let responseText: string = response.result as string;
      return JSON.parse(responseText) as SearchUserResponse;
    } catch (error) {
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }

  async addFamilyMember(userId: number, memberId: number, relationshipName: string = '家庭成员'): Promise<RegisterResponse> {
    let httpRequest = http.createHttp();

    try {
      let response = await httpRequest.request(`${this.baseUrl}/add-family-member`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ user_id: userId, member_id: memberId, relationship_name: relationshipName }),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      let responseText: string = response.result as string;
      return JSON.parse(responseText) as RegisterResponse;
    } catch (error) {
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }

  async createRadarSession(userId: number, radarCode: string): Promise<RegisterResponse> {
    let httpRequest = http.createHttp();

    try {
      let response = await httpRequest.request(`${this.baseUrl}/radar-friends`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ user_id: userId, radar_code: radarCode }),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      let responseText: string = response.result as string;
      return JSON.parse(responseText) as RegisterResponse;
    } catch (error) {
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }

  async getFriendsList(userId: number): Promise<FriendsListResponse> {
    const httpRequest = http.createHttp();
    try {
      console.info(`[好友列表] 获取用户${userId}的好友列表`);

      const response = await httpRequest.request(`${this.baseUrl}/friends-list/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: FriendsListResponse = JSON.parse(responseText) as FriendsListResponse;

      console.info(`[好友列表] 获取到${result.friends?.length || 0}个好友`);
      return result;
    } catch (error) {
      console.error('[好友列表] 获取失败:', error);
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }

  async createFaceToFaceSession(userId: number, fourDigitCode: string): Promise<RegisterResponse> {
    const httpRequest = http.createHttp();
    try {
      console.info(`[面对面加好友] 用户${userId}创建会话，代码: ${fourDigitCode}`);

      const response = await httpRequest.request(`${this.baseUrl}/radar-friends`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({
          user_id: userId,
          radar_code: fourDigitCode
        }),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      const responseText: string = response.result as string;
      const result: RegisterResponse = JSON.parse(responseText) as RegisterResponse;
      console.info(`[面对面加好友] 会话创建结果: ${result.success}`);
      return result;
    } catch (error) {
      console.error(`[面对面加好友] 网络异常:`, error);
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }

  async getFamilyMembers(userId: number): Promise<FamilyMembersResponse> {
    let httpRequest = http.createHttp();

    try {
      let response = await httpRequest.request(`${this.baseUrl}/family-members/${userId}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      let responseText: string = response.result as string;
      return JSON.parse(responseText) as FamilyMembersResponse;
    } catch (error) {
      return { success: false, message: '网络连接失败' };
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
      let overviewResult: OverviewResponse = JSON.parse(responseText) as OverviewResponse;

      if (overviewResult.success && overviewResult.data) {
        const convertedData: HealthOverviewData = {
          steps: overviewResult.data.steps || 0,
          current_heart_rate: overviewResult.data.current_heart_rate || 0,
          avg_heart_rate: overviewResult.data.current_heart_rate || 0,
          sleep_score: overviewResult.data.sleep_score || 0,
          active_calories: overviewResult.data.active_calories || 0,
          basic_metabolism_calories: overviewResult.data.basic_metabolism_calories || 0,
          blood_oxygen: overviewResult.data.blood_oxygen || 0,
          current_mood: overviewResult.data.current_mood || -1
        };

        console.info(`[健康数据服务] 转换后的健康数据:`, JSON.stringify(convertedData));

        return {
          success: true,
          data: convertedData,
          message: overviewResult.message
        };
      }

      return { success: false, message: overviewResult.message || '数据为空' };
    } catch (error) {
      console.error(`[健康数据服务] 获取健康数据失败:`, error);
      return { success: false, message: '网络连接失败' };
    } finally {
      httpRequest.destroy();
    }
  }
}


export const userApiService: UserApiService = new UserApiService();