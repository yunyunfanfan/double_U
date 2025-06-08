import { preferences } from '@kit.ArkData';

// 健康数据汇总类
export class HealthDataSummary {
  steps: string = '';
  heartRate: string = '';
  bloodOxygen: string = '';
  sleep: string = '';
  calories: string = '';
  mood: string = '';

  constructor(steps: string, heartRate: string, bloodOxygen: string, sleep: string, calories: string, mood: string) {
    this.steps = steps;
    this.heartRate = heartRate;
    this.bloodOxygen = bloodOxygen;
    this.sleep = sleep;
    this.calories = calories;
    this.mood = mood;
  }
}

// 存储的健康数据结构
export class StoredHealthData {
  timestamp: string = '';
  type: string = '';
  value: string = '';
  unit: string = '';
  additionalInfo: AdditionalHealthInfo = new AdditionalHealthInfo();

  constructor(timestamp: string, type: string, value: string, unit: string, additionalInfo?: AdditionalHealthInfo) {
    this.timestamp = timestamp;
    this.type = type;
    this.value = value;
    this.unit = unit;
    if (additionalInfo) {
      this.additionalInfo = additionalInfo;
    }
  }
}

export class AdditionalHealthInfo {
  sleepTime: string = '';
  wakeTime: string = '';
  minValue: string = '';
  maxValue: string = '';
  avgValue: string = '';
  category: string = '';
  dayOfWeek: string = '';
  goalValue: string = '';
  distance: string = '';

  constructor() {}
}

// 健康数据服务类
export class HealthDataService {
  private static instance: HealthDataService | null = null;
  private preferencesHelper: preferences.Preferences | null = null;

  private constructor() {}

  static getInstance(): HealthDataService {
    if (!HealthDataService.instance) {
      HealthDataService.instance = new HealthDataService();
    }
    return HealthDataService.instance;
  }

  async initPreferences(): Promise<void> {
    try {
      this.preferencesHelper = await preferences.getPreferences(getContext(), 'health_data');
    } catch (error) {
      console.error('[HealthDataService] 初始化存储失败:', error);
    }
  }

  async getLatestHealthData(): Promise<HealthDataSummary> {
    if (!this.preferencesHelper) {
      await this.initPreferences();
    }

    try {
      // 从存储中获取健康数据
      const storedData = await this.preferencesHelper?.get('health_records', '[]') as string;
      const healthRecords: StoredHealthData[] = JSON.parse(storedData);

      // 获取最新的各类数据
      const latestSteps = this.getLatestDataByType(healthRecords, 'steps');
      const latestHeartRate = this.getLatestDataByType(healthRecords, 'heart_rate');
      const latestBloodOxygen = this.getLatestDataByType(healthRecords, 'blood_oxygen');
      const latestSleep = this.getLatestDataByType(healthRecords, 'sleep');
      const latestCalories = this.getLatestDataByType(healthRecords, 'calories');
      const latestMood = this.getLatestDataByType(healthRecords, 'mood');

      return new HealthDataSummary(
        latestSteps ? `${latestSteps.value}${latestSteps.unit}` : '0步',
        latestHeartRate ? `${latestHeartRate.value}${latestHeartRate.unit}` : '0bpm',
        latestBloodOxygen ? `${latestBloodOxygen.value}${latestBloodOxygen.unit}` : '0%',
        latestSleep ? `${latestSleep.value}${latestSleep.unit}` : '0小时',
        latestCalories ? `${latestCalories.value}${latestCalories.unit}` : '0Kcal',
        latestMood ? latestMood.value : '正常'
      );
    } catch (error) {
      console.error('[HealthDataService] 获取健康数据失败:', error);
      return this.getDefaultHealthData();
    }
  }

  private getLatestDataByType(records: StoredHealthData[], type: string): StoredHealthData | null {
    const filteredRecords = records.filter(record => record.type === type);
    if (filteredRecords.length === 0) return null;

    // 按时间戳排序，获取最新的
    filteredRecords.sort((a, b) => {
      const timeA = new Date(a.timestamp).getTime();
      const timeB = new Date(b.timestamp).getTime();
      return timeB - timeA;
    });

    return filteredRecords[0];
  }

  private getDefaultHealthData(): HealthDataSummary {
    return new HealthDataSummary(
      '0步',
      '0bpm', 
      '0%',
      '0小时',
      '0Kcal',
      '正常'
    );
  }

  // 获取特定类型的最新数据
  async getLatestDataByTypePublic(type: string): Promise<StoredHealthData | null> {
    if (!this.preferencesHelper) {
      await this.initPreferences();
    }

    try {
      const storedData = await this.preferencesHelper?.get('health_records', '[]') as string;
      const healthRecords: StoredHealthData[] = JSON.parse(storedData);
      return this.getLatestDataByType(healthRecords, type);
    } catch (error) {
      console.error(`[HealthDataService] 获取${type}数据失败:`, error);
      return null;
    }
  }
} 