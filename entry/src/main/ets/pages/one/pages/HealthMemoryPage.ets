import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { userApiService, HealthDataResponse, HealthDataRequest } from '../../../services/api_network/UserApiService';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';

///个性化健康记忆页面

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

interface RouterParams {
  user_id?: number;
}

// 分析结果类
class HealthAnalysisResult {
  title: string = '';
  content: string = '';

  constructor(title: string, content: string) {
    this.title = title;
    this.content = content;
  }

  toString(): string {
    return `HealthAnalysisResult{title: ${this.title}, contentLength: ${this.content.length}}`;
  }
}

// 展示用的健康数据结构
class HealthData {
  steps: string = '';
  heartRate: string = '';
  sleepHours: string = '';
  calories: string = '';
  oxygenLevel: string = '';
  mood: string = '';
  stepGoal: string = '';

  constructor(steps: string, heartRate: string, sleepHours: string, calories: string, oxygenLevel: string, mood?: string, stepGoal?: string) {
    this.steps = steps;
    this.heartRate = heartRate;
    this.sleepHours = sleepHours;
    this.calories = calories;
    this.oxygenLevel = oxygenLevel;
    this.mood = mood || '';
    this.stepGoal = stepGoal || '';
  }

  toString(): string {
    return `HealthData{steps: ${this.steps}, heartRate: ${this.heartRate}, sleep: ${this.sleepHours}}`;
  }
}

class MemoryItem {
  date: string = '';
  title: string = '';
  content: string = '';
  healthData: HealthData;

  constructor(date: string, title: string, content: string, healthData: HealthData) {
    this.date = date;
    this.title = title;
    this.content = content;
    this.healthData = healthData;
  }

  toString(): string {
    return `MemoryItem{date: ${this.date}, title: ${this.title}, contentLength: ${this.content.length}}`;
  }
}

// 日期分组的健康数据
class DailyHealthData {
  date: string = '';
  steps: string = '0';
  heartRate: string = '0';
  sleepMinutes: number = 0; // 存储分钟数
  activeCalories: number = 0; // 活动热量
  metabolismCalories: number = 0; // 代谢热量
  oxygenLevel: string = '0';
  mood: string = '5';
  stepGoal: string = '0';
  recordCount: number = 0;

  constructor(date: string) {
    this.date = date;
  }

  toString(): string {
    return `DailyHealthData{date: ${this.date}, recordCount: ${this.recordCount}, steps: ${this.steps}}`;
  }

  getRecordCount(): number {
    return this.recordCount;
  }

  // 获取格式化的睡眠时间
  getFormattedSleepHours(): string {
    if (this.sleepMinutes <= 0) return '0小时';
    let hours: number = Math.floor(this.sleepMinutes / 60);
    let minutes: number = this.sleepMinutes % 60;
    if (minutes > 0) {
      return `${hours}小时${minutes}分钟`;
    }
    return `${hours}小时`;
  }

  // 获取总热量
  getTotalCalories(): number {
    return this.activeCalories + this.metabolismCalories;
  }

  // 获取格式化的总热量
  getFormattedCalories(): string {
    return `${this.getTotalCalories()}千卡`;
  }
}

@Entry
@Component
export struct HealthMemoryPage {
  @State memories: MemoryItem[] = [];
  @State selectedMemory: number = 0;
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State currentHealthData: HealthData = new HealthData('', '', '', '', '');
  @State updateCounter: number = 0;
  @State userId: number = 0;
  @State isViewingOtherUser: boolean = false; // 是否查看其他用户

  private dailyDataMap: Map<string, DailyHealthData> = new Map();

  aboutToAppear(): void {
    console.info('[健康记忆页面] ================ 健康记忆系统初始化开始 ================');
    console.info('[健康记忆页面] 当前用户: gadz2021, 系统时间: 2025-06-08 13:43:32 UTC');
    console.info('[健康记忆页面] 修复: 睡眠单位(分钟转小时)，热量计算(活动+代谢)');
    this.initializeHealthMemorySystem();
  }

  private async initializeHealthMemorySystem(): Promise<void> {
    try {
      console.info('[系统初始化] ======== 健康记忆系统初始化开始 ========');
      await this.getUserId();
      await this.loadHealthDataFromDatabase();
      await this.processHealthDataIntoMemories();
      this.isLoading = false;
      this.updateCounter++;
      console.info('[系统初始化] ======== 健康记忆系统初始化成功 ========');
    } catch (error) {
      let errorMessage = error instanceof Error ? error.message : '未知系统错误';
      console.error(`[系统初始化] 健康记忆系统初始化失败: ${errorMessage}`);
      this.errorMessage = `数据加载失败: ${errorMessage}`;
      this.isLoading = false;
      this.updateCounter++;
      this.loadDefaultMemories();
    }
  }

  private async getUserId(): Promise<void> {
    try {
      console.info('[用户ID] === 开始获取用户ID ===');

      // 先检查路由参数是否有传入user_id
      const params = router.getParams() as RouterParams;
      if (params && params.user_id) {
        console.info(`[用户ID] === 从路由参数获取用户ID: ${params.user_id} ===`);
        this.userId = params.user_id;
        this.isViewingOtherUser = true;
        return;
      }

      // 如果没有路由参数，则从AppStorage获取当前登录用户
      const userInfoStr = AppStorage.get<string>('userInfo');
      const userInfo: UserInfo = userInfoStr ? JSON.parse(userInfoStr) as UserInfo : {};

      if (userInfo && userInfo.userId) {
        this.userId = parseInt(userInfo.userId);
        this.isViewingOtherUser = false;
        console.info(`[用户ID] === 从存储获取当前用户ID: ${this.userId} ===`);
      } else {
        console.warn('[用户ID] === 未找到用户信息，使用默认ID ===');
        this.userId = 1;
        this.isViewingOtherUser = false;
      }
    } catch (error) {
      console.error(`[用户ID] === 获取用户ID异常: ${error} ===`);
      this.userId = 1;
      this.isViewingOtherUser = false;
    }
  }

  private async loadHealthDataFromDatabase(): Promise<void> {
    if (this.userId === 0) {
      console.error('[健康数据] === 用户ID为0，跳过数据加载 ===');
      return;
    }

    try {
      console.info(`[健康数据] === 开始加载健康数据，用户ID: ${this.userId} ===`);
      // 获取7天完整历史数据用于生成健康记忆
      let healthResponse: HealthDataResponse = await userApiService.getHealthData(this.userId, 7, false);
      console.info(`[健康数据] === 健康数据响应: ${JSON.stringify(healthResponse)} ===`);

      if (healthResponse.success && healthResponse.data && healthResponse.data.length > 0) {
        // 处理所有历史数据用于生成健康记忆
        this.groupHealthDataByDate(healthResponse.data);
        console.info(`[健康数据] === 健康数据处理完成，共${healthResponse.data.length}条记录 ===`);

        // 单独处理今日数据用于实时数据显示
        const today: string = new Date().toISOString().split('T')[0];
        const todayData: HealthDataRequest | undefined = healthResponse.data.find((item: HealthDataRequest) => {
          const itemDate: string = (item.record_date || '').replace(/'/g, '');
          return itemDate === today;
        });

        if (todayData) {
          console.info(`[健康数据] === 找到今日实时数据用于概览显示 ===`);
          // 更新今日数据到概览中
          this.updateTodayOverviewData(todayData);
        } else {
          console.warn('[健康数据] === 今日无实时数据，概览显示历史数据 ===');
        }
      } else {
        console.warn('[健康数据] === 健康数据为空 ===');
      }
    } catch (error) {
      console.error(`[健康数据] === 数据加载异常: ${error} ===`);
      throw new Error(`网络请求失败: ${error}`);
    }
  }

  private updateTodayOverviewData(todayData: HealthDataRequest): void {
    console.info('[今日数据] === 更新今日概览数据 ===');
    // 这里可以根据需要更新当前健康数据概览
    // 当前的逻辑是在processHealthDataIntoMemories中设置currentHealthData
    // 如果需要强制使用今日数据，可以在这里覆盖
  }

  private groupHealthDataByDate(healthRecords: HealthDataRequest[]): void {
    console.info(`[数据分组] === 开始按日期分组健康数据，共${healthRecords.length}条记录 ===`);

    for (let i: number = 0; i < healthRecords.length; i++) {
      let record: HealthDataRequest = healthRecords[i];
      let dateStr: string = (record.record_date || '').replace(/'/g, ''); // 移除引号

      if (!dateStr) {
        console.warn(`[数据分组] === 跳过无日期记录: ${JSON.stringify(record)} ===`);
        continue;
      }

      if (!this.dailyDataMap.has(dateStr)) {
        let newDailyData: DailyHealthData = new DailyHealthData(dateStr);
        this.dailyDataMap.set(dateStr, newDailyData);
      }

      let dailyData: DailyHealthData = this.dailyDataMap.get(dateStr) as DailyHealthData;
      this.updateDailyDataFromRecord(dailyData, record);
      dailyData.recordCount++;

      console.info(`[数据分组] === 处理日期${dateStr}的数据: ${dailyData.toString()} ===`);
    }

    console.info(`[数据分组] === 数据分组完成，共${this.dailyDataMap.size}天的数据 ===`);
  }

  private updateDailyDataFromRecord(dailyData: DailyHealthData, record: HealthDataRequest): void {
    console.info(`[数据更新] === 更新日期${dailyData.date}的健康数据 ===`);

    dailyData.steps = (record.steps || 0).toString();
    dailyData.heartRate = (record.current_heart_rate || 0).toString();

    // 睡眠时间：从分钟转换
    dailyData.sleepMinutes = record.sleep_duration || 0;
    console.info(`[数据更新] === 睡眠时间: ${dailyData.sleepMinutes}分钟 = ${dailyData.getFormattedSleepHours()} ===`);

    // 热量：活动热量 + 代谢热量
    dailyData.activeCalories = record.active_calories || 0;
    dailyData.metabolismCalories = record.basic_metabolism_calories || 0;
    console.info(`[数据更新] === 热量计算: 活动${dailyData.activeCalories} + 代谢${dailyData.metabolismCalories} = 总计${dailyData.getTotalCalories()}千卡 ===`);

    dailyData.oxygenLevel = (record.current_blood_oxygen || 0).toString();
    dailyData.mood = (record.current_mood || 5).toString();
    dailyData.stepGoal = (record.steps_goal || 10000).toString();
  }
  ///这个注释掉的是显示最新(可能不是今天的数据)的逻辑实现
  // private async processHealthDataIntoMemories(): Promise<void> {
  //   console.info('[记忆处理] === 开始处理健康数据为记忆 ===');
  //   let memories: MemoryItem[] = [];
  //   let sortedDates: string[] = Array.from(this.dailyDataMap.keys()).sort((a: string, b: string) => b.localeCompare(a));
  //   let recentDates: string[] = sortedDates.slice(0, 7);
  //
  //   for (let i: number = 0; i < recentDates.length; i++) {
  //     let date: string = recentDates[i];
  //     let dailyData: DailyHealthData = this.dailyDataMap.get(date) as DailyHealthData;
  //
  //     if (dailyData) {
  //       let healthData: HealthData = new HealthData(
  //         `${dailyData.steps}步`,
  //         `${dailyData.heartRate}bpm`,
  //         dailyData.getFormattedSleepHours(),
  //         dailyData.getFormattedCalories(),
  //         `${dailyData.oxygenLevel}%`,
  //         this.getMoodText(parseInt(dailyData.mood)),
  //         `${dailyData.stepGoal}步`
  //       );
  //
  //       let memory: MemoryItem = this.generateMemoryForDate(date, dailyData, healthData, i);
  //       memories.push(memory);
  //       console.info(`[记忆处理] === 生成记忆: ${memory.toString()} ===`);
  //     }
  //   }
  //
  //   this.memories = memories;
  //
  //   if (memories.length > 0) {
  //     this.currentHealthData = memories[0].healthData;
  //   } else {
  //     this.currentHealthData = new HealthData('0步', '0bpm', '0小时', '0千卡', '0%', '一般', '10000步');
  //   }
  //
  //   console.info(`[记忆处理] === 记忆处理完成，共生成${memories.length}条记忆 ===`);
  // }


  private async processHealthDataIntoMemories(): Promise<void> {
    console.info('[记忆处理] === 开始处理健康数据为记忆 ===');
    let memories: MemoryItem[] = [];
    let sortedDates: string[] = Array.from(this.dailyDataMap.keys()).sort((a: string, b: string) => b.localeCompare(a));
    let recentDates: string[] = sortedDates.slice(0, 7);

    for (let i: number = 0; i < recentDates.length; i++) {
      let date: string = recentDates[i];
      let dailyData: DailyHealthData = this.dailyDataMap.get(date) as DailyHealthData;

      if (dailyData) {
        let healthData: HealthData = new HealthData(
          `${dailyData.steps}步`,
          `${dailyData.heartRate}bpm`,
          dailyData.getFormattedSleepHours(),
          dailyData.getFormattedCalories(),
          `${dailyData.oxygenLevel}%`,
          this.getMoodText(parseInt(dailyData.mood)),
          `${dailyData.stepGoal}步`
        );

        let memory: MemoryItem = this.generateMemoryForDate(date, dailyData, healthData, i);
        memories.push(memory);
        console.info(`[记忆处理] === 生成记忆: ${memory.toString()} ===`);
      }
    }

    this.memories = memories;

    // 修改这里：优先查找今日数据，如果没有则使用默认值
    const today: string = new Date().toISOString().split('T')[0];
    const todayData: DailyHealthData | undefined = this.dailyDataMap.get(today);

    if (todayData) {
      console.info('[记忆处理] === 使用今日数据设置概览 ===');
      this.currentHealthData = new HealthData(
        `${todayData.steps}步`,
        `${todayData.heartRate}bpm`,
        todayData.getFormattedSleepHours(),
        todayData.getFormattedCalories(),
        `${todayData.oxygenLevel}%`,
        this.getMoodText(parseInt(todayData.mood)),
        `${todayData.stepGoal}步`
      );
    } else {
      console.warn('[记忆处理] === 今日无数据，使用默认值 ===');
      this.currentHealthData = new HealthData('0步', '0bpm', '0小时', '0千卡', '0%', '无数据', '10000步');
    }

    console.info(`[记忆处理] === 记忆处理完成，共生成${memories.length}条记忆 ===`);
  }

  private generateMemoryForDate(date: string, dailyData: DailyHealthData, healthData: HealthData, dayIndex: number): MemoryItem {
    let analysisResult: HealthAnalysisResult = this.analyzeHealthData(dailyData);
    return new MemoryItem(date, analysisResult.title, analysisResult.content, healthData);
  }

  private analyzeHealthData(dailyData: DailyHealthData): HealthAnalysisResult {
    let issues: string[] = [];
    let achievements: string[] = [];
    let suggestions: string[] = [];

    let steps: number = parseInt(dailyData.steps) || 0;
    let stepGoal: number = parseInt(dailyData.stepGoal) || 8000;

    if (steps >= stepGoal) {
      achievements.push(`完成步数目标，走了${this.formatNumber(steps)}步`);
    } else if (steps > stepGoal * 0.8) {
      suggestions.push(`步数已达成目标的${Math.round((steps / stepGoal) * 100)}%，继续加油`);
    } else if (steps > 0) {
      issues.push(`步数不足，仅完成目标的${Math.round((steps / stepGoal) * 100)}%`);
    }

    let heartRate: number = parseInt(dailyData.heartRate) || 0;
    if (heartRate > 0) {
      if (heartRate >= 60 && heartRate <= 100) {
        achievements.push('心率正常稳定');
      } else if (heartRate < 60) {
        issues.push('心率偏低，建议关注');
      } else {
        issues.push('心率偏高，建议休息');
      }
    }

    // 睡眠分析：使用分钟数进行判断
    let sleepHours: number = dailyData.sleepMinutes / 60;
    console.info(`[睡眠分析] === 睡眠时间: ${dailyData.sleepMinutes}分钟 = ${sleepHours.toFixed(1)}小时 ===`);

    if (sleepHours >= 7) {
      achievements.push('睡眠时间充足');
    } else if (sleepHours >= 6) {
      suggestions.push('睡眠时间略显不足，建议早点休息');
    } else if (sleepHours > 0) {
      issues.push('睡眠严重不足，影响健康');
    }

    // 热量分析：使用总热量（活动+代谢）
    let totalCalories: number = dailyData.getTotalCalories();
    console.info(`[热量分析] === 总热量: ${totalCalories}千卡 (活动${dailyData.activeCalories} + 代谢${dailyData.metabolismCalories}) ===`);

    if (totalCalories >= 2000) {
      achievements.push('热量消耗良好');
    } else if (totalCalories >= 1500) {
      suggestions.push('热量消耗适中，可继续保持');
    }

    let mood: number = parseInt(dailyData.mood) || 5;
    if (mood >= 8) {
      achievements.push('心情状态优秀');
    } else if (mood <= 3) {
      issues.push('心情状态较差，需要调节');
      suggestions.push('建议进行放松练习，如深呼吸或冥想');
    }

    let title: string;
    let content: string;

    if (issues.length > 0) {
      title = '健康提醒';
      content = `今日健康数据显示需要注意以下方面：\n\n`;
      content += issues.map((issue: string, index: number) => `${index + 1}. ${issue}`).join('\n');

      if (suggestions.length > 0) {
        content += `\n\n建议：\n`;
        content += suggestions.map((suggestion: string, index: number) => `• ${suggestion}`).join('\n');
      }
    } else if (achievements.length > 0) {
      title = '健康状况良好';
      content = `恭喜您，今日健康表现优秀：\n\n`;
      content += achievements.map((achievement: string, index: number) => `✅ ${achievement}`).join('\n');
      content += `\n\n继续保持良好的生活习惯！`;
    } else {
      title = '健康数据记录';
      content = `今日健康数据已记录，请继续关注您的健康状况。`;
    }

    return new HealthAnalysisResult(title, content);
  }

  private getMoodText(mood: number): string {
    if (mood >= 9) return '非常愉快';
    if (mood >= 8) return '愉快';
    if (mood >= 7) return '较好';
    if (mood >= 6) return '一般偏好';
    if (mood >= 5) return '一般';
    if (mood >= 4) return '一般偏差';
    if (mood >= 3) return '较差';
    if (mood >= 2) return '很差';
    return '极差';
  }

  private formatNumber(num: number): string {
    return num.toLocaleString();
  }

  private loadDefaultMemories(): void {
    console.info('[默认数据] === 加载默认健康记忆 ===');
    let defaultHealthData: HealthData = new HealthData('0步', '0bpm', '0小时', '0千卡', '0%', '无数据', '10000步');
    let defaultMemory: MemoryItem = new MemoryItem('2025-06-08', '暂无数据', '暂无健康记忆数据，请稍后重试', defaultHealthData);
    this.memories = [defaultMemory];
    this.currentHealthData = defaultHealthData;
    this.selectedMemory = 0;
  }

  build() {
    Column() {
      // 优化的导航栏
      this.buildNavigationBar()

      if (this.isLoading) {
        // 加载状态
        this.buildLoadingView()
      } else if (this.errorMessage) {
        // 错误状态
        this.buildErrorView()
      } else {
        // 正常内容
        Scroll() {
          Column({ space: 20 }) {
            // 健康数据概览卡片
            this.buildHealthDataOverview()

            // 健康记忆卡片
            this.buildHealthMemoryCard()

            // 健康建议卡片
            this.buildHealthAdviceCard()
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildLoadingView() {
    Column({ space: 20 }) {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#4285F4')

      Text('正在加载健康数据...')
        .fontSize(16)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)

      Text('当前用户: gadz2021, 加载中请稍候')
        .fontSize(14)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .lineHeight(20)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(40)
  }

  @Builder
  buildErrorView() {
    Column({ space: 20 }) {
      Text('⚠️')
        .fontSize(48)

      Text('数据加载失败')
        .fontSize(18)
        .fontColor('#EA4335')
        .fontWeight(FontWeight.Bold)

      Text(this.errorMessage)
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .maxLines(3)
        .lineHeight(20)

      Button('重新加载')
        .onClick(() => {
          this.isLoading = true;
          this.errorMessage = '';
          this.updateCounter++;
          this.initializeHealthMemorySystem();
        })
        .backgroundColor('#4285F4')
        .fontColor(Color.White)
        .borderRadius(8)
        .height(40)
        .width(120)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(40)
  }

  @Builder
  buildNavigationBar() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_back'))
          .width(20)
          .height(20)
      }
      .onClick(() => {
        try {
          // 如果是查看其他用户，返回时需要传递user_id参数给主页
          if (this.isViewingOtherUser) {
            router.back({
              url: 'pages/one/pages/WxHomePage',
              params: { user_id: this.userId }
            });
          } else {
            router.back();
          }
        } catch (err) {
          router.pushUrl({ url: 'pages/one/OnePage' });
        }
      })
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .margin({ left: 10 })

      Text('个性化健康记忆')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 右侧占位元素，保持布局平衡
      Row()
        .width(40)
        .height(40)
        .margin({ right: 10 })
    }
    .width('100%')
    .height(60)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildHealthDataOverview() {
    Column({ space: 16 }) {
      Row() {
        Text('健康数据概览')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('实时数据')
          .fontSize(12)
          .fontColor('#4285F4')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(66, 133, 244, 0.1)')
          .borderRadius(10)
      }
      .width('100%')

      // 第一行数据卡片
      Row({ space: 10 }) {
        this.buildDataCard('步数', this.currentHealthData.steps || '0步', '#4285F4', '👟')
        this.buildDataCard('心率', this.currentHealthData.heartRate || '0bpm', '#EA4335', '❤️')
        this.buildDataCard('睡眠', this.currentHealthData.sleepHours || '0小时', '#34A853', '😴')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 第二行数据卡片
      Row({ space: 10 }) {
        this.buildDataCard('热量', this.currentHealthData.calories || '0千卡', '#FBBC05', '🔥')
        this.buildDataCard('血氧', this.currentHealthData.oxygenLevel || '0%', '#9C27B0', '🫁')
        // 情绪或目标卡片
        if (this.currentHealthData.mood) {
          this.buildDataCard('心情', this.currentHealthData.mood, '#FF9800', '😊')
        } else {
          // 空白占位，保持对齐
          Column()
            .width('30%')
            .height(90)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 3
    })
  }

  @Builder
  buildDataCard(title: string, value: string, color: string, emoji: string) {
    Column() {
      // 图标区域
      Text(emoji)
        .fontSize(20)
        .margin({ bottom: 6 })

      // 标题
      Text(title)
        .fontSize(12)
        .fontColor('#999999')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 4 })
        .textAlign(TextAlign.Center)

      // 数值
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('30%')
    .height(90)
    .padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .border({
      width: 1,
      color: color,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  buildHealthMemoryCard() {
    Column({ space: 16 }) {
      Row() {
        Text('健康记忆')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text(`共${this.memories.length}条记录`)
          .fontSize(12)
          .fontColor('#999999')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F0F0F0')
          .borderRadius(10)
      }
      .width('100%')

      if (this.memories.length === 0) {
        Column({ space: 12 }) {
          Text('📝')
            .fontSize(32)

          Text('暂无健康记忆')
            .fontSize(16)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)

          Text('健康数据记录后将自动生成个性化记忆')
            .fontSize(14)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        ForEach(this.memories, (item: MemoryItem, index: number) => {
          Column({ space: 12 }) {
            Row() {
              Column({ space: 4 }) {
                Text(item.date)
                  .fontSize(12)
                  .fontColor('#999999')

                Text(this.getDateLabel(index))
                  .fontSize(14)
                  .fontColor('#666666')
                  .fontWeight(FontWeight.Medium)
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              // 状态指示器
              Row() {
                Text('●')
                  .fontSize(12)
                  .fontColor(this.getStatusColor(item.title))

                Text(this.getStatusText(item.title))
                  .fontSize(12)
                  .fontColor(this.getStatusColor(item.title))
                  .margin({ left: 6 })
              }
            }
            .width('100%')

            Text(item.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .textAlign(TextAlign.Start)

            Text(item.content)
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(20)
              .width('100%')
              .textAlign(TextAlign.Start)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Button() {
              Text('查看详情')
                .fontSize(14)
                .fontColor(index === this.selectedMemory ? '#FFFFFF' : '#4285F4')
                .fontWeight(FontWeight.Medium)
            }
            .height(36)
            .width(100)
            .backgroundColor(index === this.selectedMemory ? '#4285F4' : 'rgba(66, 133, 244, 0.1)')
            .borderRadius(18)
            .border({
              width: index === this.selectedMemory ? 0 : 1,
              color: '#4285F4',
              style: BorderStyle.Solid
            })
            .onClick(() => {
              this.selectedMemory = index;
              this.currentHealthData = item.healthData;
              this.updateCounter++;
              this.showHealthMemoryDetail(item, index);
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(index === this.selectedMemory ? 'rgba(66, 133, 244, 0.05)' : '#FFFFFF')
          .borderRadius(12)
          .border({
            width: index === this.selectedMemory ? 2 : 1,
            color: index === this.selectedMemory ? '#4285F4' : '#E8E8E8',
            style: BorderStyle.Solid
          })
        })
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  buildHealthAdviceCard() {
    Column({ space: 16 }) {
      Row() {
        Text('今日健康建议')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('💡')
          .fontSize(20)
      }
      .width('100%')

      Text('基于您的健康数据，为您提供个性化建议：')
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 12 }) {
        this.buildAdviceItem('每日保持8000步以上的活动量', '🚶‍♂️')
        this.buildAdviceItem('确保每晚7-8小时优质睡眠', '🛌')
        this.buildAdviceItem('多喝水，保持身体水分平衡', '💧')
        this.buildAdviceItem('适量运动，增强心肺功能', '🏃‍♂️')
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  buildAdviceItem(text: string, emoji: string) {
    Row({ space: 12 }) {
      Text(emoji)
        .fontSize(16)

      Text(text)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
  }

  private getDateLabel(index: number): string {
    if (this.memories.length === 0) return '';

    const memoryDate = this.memories[index].date.replace(/'/g, '');
    const today = new Date().toISOString().split('T')[0];
    const targetDate = new Date(memoryDate);
    const currentDate = new Date(today);

    const diffTime = currentDate.getTime() - targetDate.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    console.info(`[日期标签] === 计算日期差值: ${memoryDate} vs ${today}, 相差${diffDays}天 ===`);

    if (diffDays === 0) return '今天';
    if (diffDays === 1) return '昨天';
    if (diffDays === 2) return '前天';
    if (diffDays >= 3 && diffDays <= 7) return `${diffDays}天前`;

    return `${diffDays}天前`;
  }

  private getStatusColor(title: string): string {
    if (title.includes('良好') || title.includes('优秀') || title.includes('成就')) {
      return '#34A853';
    } else if (title.includes('提醒') || title.includes('注意') || title.includes('异常')) {
      return '#EA4335';
    } else if (title.includes('成就') || title.includes('达成')) {
      return '#FBBC05';
    } else {
      return '#4285F4';
    }
  }

  private getStatusText(title: string): string {
    if (title.includes('良好') || title.includes('优秀')) {
      return '优秀';
    } else if (title.includes('提醒') || title.includes('注意') || title.includes('异常')) {
      return '需关注';
    } else if (title.includes('成就') || title.includes('达成')) {
      return '达成';
    } else {
      return '记录';
    }
  }

  // 显示健康记忆详情
  private showHealthMemoryDetail(item: MemoryItem, index: number): void {
    let detailMessage: string = `日期: ${item.date}\n\n详情:${item.content}\n\n健康数据:`;
    detailMessage += `\n• 步数: ${item.healthData.steps}`;
    detailMessage += `\n• 心率: ${item.healthData.heartRate}`;
    detailMessage += `\n• 睡眠: ${item.healthData.sleepHours}`;
    detailMessage += `\n• 热量: ${item.healthData.calories}`;
    detailMessage += `\n• 血氧: ${item.healthData.oxygenLevel}`;

    if (item.healthData.mood) {
      detailMessage += `\n• 心情: ${item.healthData.mood}`;
    }

    AlertDialog.show({
      title: item.title,
      message: detailMessage,
      primaryButton: {
        value: '关闭',
        action: () => {
          // 关闭弹窗
        }
      },
      secondaryButton: {
        value: '分享',
        action: () => {
          // TODO: 这里可以添加分享功能的具体实现
        }
      }
    });
  }
}