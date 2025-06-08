import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { HealthDataService, HealthDataSummary, StoredHealthData, AdditionalHealthInfo } from '../../../services/HealthDataService';

///个性化健康记忆页面

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
  heartRate: string = '';
  sleepHours: string = '';
  calories: string = '';
  oxygenLevel: string = '';
  mood: string = '';
  stepGoal: string = '0';
  records: StoredHealthData[] = [];

  constructor(date: string) {
    this.date = date;
    this.heartRate = getContext(this).resourceManager.getStringSync($r('app.string.default_heart_rate_value_39284751'));
    this.sleepHours = getContext(this).resourceManager.getStringSync($r('app.string.default_sleep_value_75839462'));
    this.calories = getContext(this).resourceManager.getStringSync($r('app.string.default_calories_value_18475936'));
    this.oxygenLevel = getContext(this).resourceManager.getStringSync($r('app.string.default_oxygen_value_62938475'));
  }

  toString(): string {
    return `DailyHealthData{date: ${this.date}, recordCount: ${this.records.length}, steps: ${this.steps}}`;
  }

  getRecordCount(): number {
    return this.records.length;
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

  private preferencesHelper: preferences.Preferences | null = null;
  private dailyDataMap: Map<string, DailyHealthData> = new Map();
  private healthDataService: HealthDataService = HealthDataService.getInstance();

  aboutToAppear(): void {
    this.initializeHealthMemorySystem();
  }

  private async initializeHealthMemorySystem(): Promise<void> {
    try {
      await this.initPreferences();
      await this.loadRealTimeHealthData(); // 加载实时健康数据
      await this.loadHealthDataFromStorage();
      await this.processHealthDataIntoMemories();
      this.isLoading = false;
      this.updateCounter++;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知系统错误';
      this.errorMessage = `数据加载失败: ${errorMessage}`;
      this.isLoading = false;
      this.updateCounter++;
      this.loadDefaultMemories();
    }
  }

  private async initPreferences(): Promise<void> {
    try {
      this.preferencesHelper = await preferences.getPreferences(getContext(), 'health_data');
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知存储错误';
      throw new Error(`存储系统初始化失败: ${errorMessage}`);
    }
  }

  private async loadRealTimeHealthData(): Promise<void> {
    try {
      const healthSummary = await this.healthDataService.getLatestHealthData();
      // 将汇总数据转换为HealthData格式
      this.currentHealthData = new HealthData(
        healthSummary.steps,
        healthSummary.heartRate,
        healthSummary.sleep,
        healthSummary.calories,
        healthSummary.bloodOxygen,
        healthSummary.mood
      );
      console.log('[HealthMemoryPage] 实时健康数据加载完成:', JSON.stringify(this.currentHealthData));
    } catch (error) {
      console.error('[HealthMemoryPage] 加载实时健康数据失败:', error);
      // 如果实时数据加载失败，使用默认值
      this.currentHealthData = new HealthData(
        getContext(this).resourceManager.getStringSync($r('app.string.default_steps_value_57382946')),
        getContext(this).resourceManager.getStringSync($r('app.string.default_heart_rate_value_39284751')),
        getContext(this).resourceManager.getStringSync($r('app.string.default_sleep_value_75839462')),
        getContext(this).resourceManager.getStringSync($r('app.string.default_calories_value_18475936')),
        getContext(this).resourceManager.getStringSync($r('app.string.default_oxygen_value_62938475'))
      );
    }
  }

  private async loadHealthDataFromStorage(): Promise<void> {
    try {
      if (!this.preferencesHelper) {
        throw new Error('存储系统未初始化，无法读取数据');
      }

      const storedData = await this.preferencesHelper.get('health_records', '[]') as string;
      const healthRecords: StoredHealthData[] = JSON.parse(storedData);

      if (healthRecords.length === 0) {
        return;
      }

      this.groupHealthDataByDate(healthRecords);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知数据错误';
      throw new Error(`数据读取失败: ${errorMessage}`);
    }
  }

  private groupHealthDataByDate(healthRecords: StoredHealthData[]): void {
    healthRecords.forEach((record: StoredHealthData) => {
      try {
        const timestampParts = record.timestamp.split(' ');
        if (timestampParts.length === 0) {
          throw new Error(`时间戳格式错误: ${record.timestamp}`);
        }

        const dateStr = timestampParts[0];

        if (!this.dailyDataMap.has(dateStr)) {
          const newDailyData = new DailyHealthData(dateStr);
          this.dailyDataMap.set(dateStr, newDailyData);
        }

        const dailyData = this.dailyDataMap.get(dateStr);
        if (dailyData) {
          dailyData.records.push(record);
          this.updateDailyDataByType(dailyData, record);
        }
      } catch (error) {
        // 跳过错误记录
        console.warn('[HealthMemoryPage] 跳过错误记录:', error);
      }
    });
  }

  private updateDailyDataByType(dailyData: DailyHealthData, record: StoredHealthData): void {
    switch (record.type) {
      case 'steps':
        dailyData.steps = this.formatValue(record.value, record.unit);
        break;
      case 'heart_rate':
        if (record.additionalInfo.avgValue) {
          dailyData.heartRate = this.formatValue(record.additionalInfo.avgValue, record.unit);
        } else {
          dailyData.heartRate = this.formatValue(record.value, record.unit);
        }
        break;
      case 'sleep':
        if (record.additionalInfo.sleepTime && record.additionalInfo.wakeTime) {
          dailyData.sleepHours = `${record.additionalInfo.sleepTime}-${record.additionalInfo.wakeTime}（${record.value}${record.unit}）`;
        } else {
          dailyData.sleepHours = this.formatValue(record.value, record.unit);
        }
        break;
      case 'calories':
        dailyData.calories = this.formatValue(record.value, record.unit);
        break;
      case 'blood_oxygen':
        dailyData.oxygenLevel = this.formatValue(record.value, record.unit);
        break;
      case 'mood':
        dailyData.mood = record.value;
        break;
      case 'step_goal':
        dailyData.stepGoal = this.formatValue(record.value, record.unit);
        break;
      default:
        break;
    }
  }

  private formatValue(value: string, unit: string): string {
    if (!value) {
      return '0';
    }

    if (!unit) {
      return value;
    }

    if (value.includes(unit)) {
      return value;
    }

    const numValue = parseFloat(value);
    if (!isNaN(numValue)) {
      if (unit === '步' && numValue >= 1000) {
        return `${numValue.toLocaleString()}${unit}`;
      }
      return `${value}${unit}`;
    }

    return `${value}${unit}`;
  }

  private async processHealthDataIntoMemories(): Promise<void> {
    const memories: MemoryItem[] = [];
    const sortedDates = Array.from(this.dailyDataMap.keys()).sort((a, b) => b.localeCompare(a));
    const recentDates = sortedDates.slice(0, 7);

    for (let i = 0; i < recentDates.length; i++) {
      const date = recentDates[i];
      const dailyData = this.dailyDataMap.get(date);

      if (dailyData) {
        const defaultSteps = getContext(this).resourceManager.getStringSync($r('app.string.default_steps_value_57382946'));
        const defaultHeartRate = getContext(this).resourceManager.getStringSync($r('app.string.default_heart_rate_value_39284751'));
        const defaultSleep = getContext(this).resourceManager.getStringSync($r('app.string.default_sleep_value_75839462'));
        const defaultCalories = getContext(this).resourceManager.getStringSync($r('app.string.default_calories_value_18475936'));
        const defaultOxygen = getContext(this).resourceManager.getStringSync($r('app.string.default_oxygen_value_62938475'));

        const healthData = new HealthData(
          dailyData.steps || defaultSteps,
          dailyData.heartRate || defaultHeartRate,
          dailyData.sleepHours || defaultSleep,
          dailyData.calories || defaultCalories,
          dailyData.oxygenLevel || defaultOxygen,
          dailyData.mood,
          dailyData.stepGoal
        );

        const memory = this.generateMemoryForDate(date, dailyData, healthData, i);
        memories.push(memory);
      }
    }

    this.memories = memories;

    if (memories.length > 0) {
      this.currentHealthData = memories[0].healthData;
    } else {
      const defaultSteps = getContext(this).resourceManager.getStringSync($r('app.string.default_steps_value_57382946'));
      const defaultHeartRate = getContext(this).resourceManager.getStringSync($r('app.string.default_heart_rate_value_39284751'));
      const defaultSleep = getContext(this).resourceManager.getStringSync($r('app.string.default_sleep_value_75839462'));
      const defaultCalories = getContext(this).resourceManager.getStringSync($r('app.string.default_calories_value_18475936'));
      const defaultOxygen = getContext(this).resourceManager.getStringSync($r('app.string.default_oxygen_value_62938475'));
      this.currentHealthData = new HealthData(defaultSteps, defaultHeartRate, defaultSleep, defaultCalories, defaultOxygen);
    }
  }

  private generateMemoryForDate(date: string, dailyData: DailyHealthData, healthData: HealthData, dayIndex: number): MemoryItem {
    const analysisResult = this.analyzeHealthData(dailyData);
    const title = analysisResult.title;
    const content = analysisResult.content;
    return new MemoryItem(date, title, content, healthData);
  }

  private analyzeHealthData(dailyData: DailyHealthData): HealthAnalysisResult {
    const issues: string[] = [];
    const achievements: string[] = [];
    const suggestions: string[] = [];

    const steps = parseInt(dailyData.steps.replace(/[^\d]/g, '')) || 0;
    const stepGoal = parseInt(dailyData.stepGoal.replace(/[^\d]/g, '')) || 8000;

    if (steps >= stepGoal) {
      achievements.push(`完成步数目标，走了${this.formatNumber(steps)}步`);
    } else if (steps > stepGoal * 0.8) {
      suggestions.push(`步数已达成目标的${Math.round((steps / stepGoal) * 100)}%，继续加油`);
    } else if (steps > 0) {
      issues.push(`步数不足，仅完成目标的${Math.round((steps / stepGoal) * 100)}%`);
    }

    const heartRate = parseInt(dailyData.heartRate.replace(/[^\d]/g, '')) || 0;
    if (heartRate > 0) {
      if (heartRate >= 60 && heartRate <= 100) {
        achievements.push('心率正常稳定');
      } else if (heartRate < 60) {
        issues.push('心率偏低，建议关注');
      } else {
        issues.push('心率偏高，建议休息');
      }
    }

    const sleepHours = parseFloat(dailyData.sleepHours.replace(/[^\d.]/g, '')) || 0;
    if (sleepHours >= 7) {
      achievements.push('睡眠时间充足');
    } else if (sleepHours >= 6) {
      suggestions.push('睡眠时间略显不足，建议早点休息');
    } else if (sleepHours > 0) {
      issues.push('睡眠严重不足，影响健康');
    }

    const calories = parseInt(dailyData.calories.replace(/[^\d]/g, '')) || 0;
    if (calories >= 2000) {
      achievements.push('运动热量消耗良好');
    } else if (calories >= 1000) {
      suggestions.push('适度运动消耗，可继续保持');
    }

    if (dailyData.mood) {
      if (dailyData.mood.includes('焦虑') || dailyData.mood.includes('压力')) {
        issues.push('情绪状态需要关注');
        suggestions.push('建议进行放松练习，如深呼吸或冥想');
      } else if (dailyData.mood.includes('开心') || dailyData.mood.includes('愉快')) {
        achievements.push('情绪状态良好');
      }
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

  private formatNumber(num: number): string {
    return num.toLocaleString();
  }

  private loadDefaultMemories(): void {
    const defaultSteps = getContext(this).resourceManager.getStringSync($r('app.string.default_steps_value_57382946'));
    const defaultHeartRate = getContext(this).resourceManager.getStringSync($r('app.string.default_heart_rate_value_39284751'));
    const defaultSleep = getContext(this).resourceManager.getStringSync($r('app.string.default_sleep_value_75839462'));
    const defaultCalories = getContext(this).resourceManager.getStringSync($r('app.string.default_calories_value_18475936'));
    const defaultOxygen = getContext(this).resourceManager.getStringSync($r('app.string.default_oxygen_value_62938475'));

    const defaultHealthData = new HealthData(defaultSteps, defaultHeartRate, defaultSleep, defaultCalories, defaultOxygen);
    const defaultTitle = getContext(this).resourceManager.getStringSync($r('app.string.default_memory_title_84739261'));
    const defaultContent = getContext(this).resourceManager.getStringSync($r('app.string.default_memory_content_57382946'));

    const defaultMemory = new MemoryItem('2025-05-30', defaultTitle, defaultContent, defaultHealthData);

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

      Text(getContext(this).resourceManager.getStringSync($r('app.string.loading_health_data_message_57284916')))
        .fontSize(16)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)

      Text(getContext(this).resourceManager.getStringSync($r('app.string.loading_health_subtitle_39475829')))
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

      Text(getContext(this).resourceManager.getStringSync($r('app.string.data_load_error_title_75163948')))
        .fontSize(18)
        .fontColor('#EA4335')
        .fontWeight(FontWeight.Bold)

      Text(this.errorMessage)
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .maxLines(3)
        .lineHeight(20)

      Button(getContext(this).resourceManager.getStringSync($r('app.string.reload_button_text_18394756')))
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
          router.back();
        } catch (err) {
          router.pushUrl({ url: 'pages/one/OnePage' });
        }
      })
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .margin({ left: 10 })

      Text(getContext(this).resourceManager.getStringSync($r('app.string.personalized_health_memory_title_84729361')))
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
        Text(getContext(this).resourceManager.getStringSync($r('app.string.health_overview_title_62847593')))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text(getContext(this).resourceManager.getStringSync($r('app.string.realtime_data_label_57382946')))
          .fontSize(12)
          .fontColor('#4285F4')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(66, 133, 244, 0.1)')
          .borderRadius(10)
      }
      .width('100%')

      // 第一行数据卡片
      Row({ space: 10 }) {
        this.buildDataCard(
          getContext(this).resourceManager.getStringSync($r('app.string.steps_label_39284751')),
          this.currentHealthData.steps || getContext(this).resourceManager.getStringSync($r('app.string.default_steps_value_57382946')),
          '#4285F4', '👟'
        )
        this.buildDataCard(
          getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_label_75839462')),
          this.currentHealthData.heartRate || getContext(this).resourceManager.getStringSync($r('app.string.default_heart_rate_value_39284751')),
          '#EA4335', '❤️'
        )
        this.buildDataCard(
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_label_18475936')),
          this.currentHealthData.sleepHours || getContext(this).resourceManager.getStringSync($r('app.string.default_sleep_value_75839462')),
          '#34A853', '😴'
        )
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 第二行数据卡片
      Row({ space: 10 }) {
        this.buildDataCard(
          getContext(this).resourceManager.getStringSync($r('app.string.calories_label_62938475')),
          this.currentHealthData.calories || getContext(this).resourceManager.getStringSync($r('app.string.default_calories_value_18475936')),
          '#FBBC05', '🔥'
        )
        this.buildDataCard(
          getContext(this).resourceManager.getStringSync($r('app.string.blood_oxygen_label_84739261')),
          this.currentHealthData.oxygenLevel || getContext(this).resourceManager.getStringSync($r('app.string.default_oxygen_value_62938475')),
          '#9C27B0', '🫁'
        )
        // 情绪或目标卡片
        if (this.currentHealthData.mood) {
          this.buildDataCard(
            getContext(this).resourceManager.getStringSync($r('app.string.mood_label_57382946')),
            this.currentHealthData.mood, '#FF9800', '😊'
          )
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
        Text(getContext(this).resourceManager.getStringSync($r('app.string.health_memory_title_39284751')))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text(`${getContext(this).resourceManager.getStringSync($r('app.string.record_count_prefix_18475936'))}${this.memories.length}${getContext(this).resourceManager.getStringSync($r('app.string.record_count_suffix_75839462'))}`)
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

          Text(getContext(this).resourceManager.getStringSync($r('app.string.no_health_memory_title_62938475')))
            .fontSize(16)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)

          Text(getContext(this).resourceManager.getStringSync($r('app.string.no_memory_subtitle_84739261')))
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
              Text(getContext(this).resourceManager.getStringSync($r('app.string.view_details_button_57382946')))
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
        Text(getContext(this).resourceManager.getStringSync($r('app.string.today_advice_title_39284751')))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('💡')
          .fontSize(20)
      }
      .width('100%')

      Text(getContext(this).resourceManager.getStringSync($r('app.string.advice_intro_text_75839462')))
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 12 }) {
        this.buildAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.advice_steps_text_18475936')), '🚶‍♂️')
        this.buildAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.advice_sleep_text_62938475')), '🛌')
        this.buildAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.advice_water_text_84739261')), '💧')
        this.buildAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.advice_exercise_text_57382946')), '🏃‍♂️')
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
    const labelKeys = [
      'app.string.today_label_39284751',
      'app.string.yesterday_label_75839462',
      'app.string.day_before_yesterday_label_18475936',
      'app.string.days_ago_3_label_62938475',
      'app.string.days_ago_4_label_84739261',
      'app.string.days_ago_5_label_57382946',
      'app.string.days_ago_6_label_39284751'
    ];

    if (index < labelKeys.length) {
      return getContext(this).resourceManager.getStringSync($r(labelKeys[index]));
    } else {
      const daysAgoSuffix = getContext(this).resourceManager.getStringSync($r('app.string.days_ago_suffix_75839462'));
      return `${index}${daysAgoSuffix}`;
    }
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
      return getContext(this).resourceManager.getStringSync($r('app.string.status_excellent_18475936'));
    } else if (title.includes('提醒') || title.includes('注意') || title.includes('异常')) {
      return getContext(this).resourceManager.getStringSync($r('app.string.status_attention_62938475'));
    } else if (title.includes('成就') || title.includes('达成')) {
      return getContext(this).resourceManager.getStringSync($r('app.string.status_achievement_84739261'));
    } else {
      return getContext(this).resourceManager.getStringSync($r('app.string.status_record_57382946'));
    }
  }

  // 显示健康记忆详情
  private showHealthMemoryDetail(item: MemoryItem, index: number): void {
    const datePrefix = getContext(this).resourceManager.getStringSync($r('app.string.dialog_date_prefix_18475936'));
    const detailsPrefix = getContext(this).resourceManager.getStringSync($r('app.string.dialog_details_prefix_62938475'));
    const healthDataPrefix = getContext(this).resourceManager.getStringSync($r('app.string.dialog_health_data_prefix_84739261'));
    const stepsLabel = getContext(this).resourceManager.getStringSync($r('app.string.steps_label_39284751'));
    const heartRateLabel = getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_label_75839462'));
    const sleepLabel = getContext(this).resourceManager.getStringSync($r('app.string.sleep_label_18475936'));
    const caloriesLabel = getContext(this).resourceManager.getStringSync($r('app.string.calories_label_62938475'));
    const bloodOxygenLabel = getContext(this).resourceManager.getStringSync($r('app.string.blood_oxygen_label_84739261'));
    const moodLabel = getContext(this).resourceManager.getStringSync($r('app.string.mood_label_57382946'));
    const closeButton = getContext(this).resourceManager.getStringSync($r('app.string.dialog_close_button_39284751'));
    const shareButton = getContext(this).resourceManager.getStringSync($r('app.string.dialog_share_button_75839462'));

    let detailMessage = `${datePrefix} ${item.date}\n\n${detailsPrefix}${item.content}\n\n${healthDataPrefix}`;
    detailMessage += `\n• ${stepsLabel}: ${item.healthData.steps}`;
    detailMessage += `\n• ${heartRateLabel}: ${item.healthData.heartRate}`;
    detailMessage += `\n• ${sleepLabel}: ${item.healthData.sleepHours}`;
    detailMessage += `\n• ${caloriesLabel}: ${item.healthData.calories}`;
    detailMessage += `\n• ${bloodOxygenLabel}: ${item.healthData.oxygenLevel}`;

    if (item.healthData.mood) {
      detailMessage += `\n• ${moodLabel}: ${item.healthData.mood}`;
    }

    AlertDialog.show({
      title: item.title,
      message: detailMessage,
      primaryButton: {
        value: closeButton,
        action: () => {
          // 关闭弹窗
        }
      },
      secondaryButton: {
        value: shareButton,
        action: () => {
          // TODO: 这里可以添加分享功能的具体实现
        }
      }
    });
  }
}