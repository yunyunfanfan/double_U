import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';

///这是心率页面

// 明确的类型定义
class CategoryFlags {
  current: boolean = false;
  resting: boolean = false;
  max: boolean = false;
  min: boolean = false;
  avg: boolean = false;

  constructor() {}

  toString(): string {
    return `CategoryFlags{current: ${this.current}, resting: ${this.resting}, max: ${this.max}, min: ${this.min}, avg: ${this.avg}}`;
  }
}

class StatCardItem {
  title: string = '';
  value: number = 0;
  color: string = '';
  emoji: string = '';

  constructor(title: string, value: number, color: string, emoji: string) {
    this.title = title;
    this.value = value;
    this.color = color;
    this.emoji = emoji;
  }
}

class AdviceItem {
  text: string = '';
  emoji: string = '';

  constructor(text: string, emoji: string) {
    this.text = text;
    this.emoji = emoji;
  }
}

// 心率记录数据结构
class HeartRateRecord {
  time: string = '';
  value: number = 0;
  status: string = '';
  timestamp: string = '';
  category: string = '';

  constructor(time: string, value: number, status: string, timestamp?: string, category?: string) {
    this.time = time;
    this.value = value;
    this.status = status;
    this.timestamp = timestamp || '';
    this.category = category || '实时';
  }

  toString(): string {
    return `HeartRateRecord{time: ${this.time}, value: ${this.value}, status: ${this.status}, category: ${this.category}}`;
  }
}

// 心率统计数据结构
class HeartRateStats {
  minValue: number = 0;
  maxValue: number = 0;
  avgValue: number = 0;
  currentValue: number = 0;
  restingValue: number = 0;
  recordCount: number = 0;

  constructor() {}

  toString(): string {
    return `HeartRateStats{min: ${this.minValue}, max: ${this.maxValue}, avg: ${this.avgValue}, current: ${this.currentValue}, resting: ${this.restingValue}, count: ${this.recordCount}}`;
  }
}

// 存储的心率数据结构
class StoredHeartRateData {
  timestamp: string = '';
  type: string = '';
  value: string = '';
  unit: string = '';
  additionalInfo: HeartRateAdditionalInfo = new HeartRateAdditionalInfo();

  constructor(timestamp: string, type: string, value: string, unit: string, additionalInfo?: HeartRateAdditionalInfo) {
    this.timestamp = timestamp;
    this.type = type;
    this.value = value;
    this.unit = unit;
    if (additionalInfo) {
      this.additionalInfo = additionalInfo;
    }
  }

  toString(): string {
    return `StoredHeartRateData{timestamp: "${this.timestamp}", type: "${this.type}", value: "${this.value}", unit: "${this.unit}", category: "${this.additionalInfo.category}"}`;
  }
}

// 心率附加信息结构
class HeartRateAdditionalInfo {
  category: string = '';
  minValue: string = '';
  maxValue: string = '';
  avgValue: string = '';

  constructor() {}

  toString(): string {
    return `HeartRateAdditionalInfo{category: "${this.category}", min: "${this.minValue}", max: "${this.maxValue}", avg: "${this.avgValue}"}`;
  }
}

@Entry
@Component
export struct HeartRatePage {
  @State currentHeartRate: number = 0;
  @State restingHeartRate: number = 0;
  @State minHeartRate: number = 0;
  @State maxHeartRate: number = 0;
  @State avgHeartRate: number = 0;
  @State heartRateRecords: HeartRateRecord[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State heartRateStats: HeartRateStats = new HeartRateStats();

  private preferencesHelper: preferences.Preferences | null = null;

  aboutToAppear(): void {
    console.info('[心率页面] ================ 智能心率监测系统初始化 ================');
    console.info('[心率页面] 当前用户: gadz2021, 系统时间: 2025-05-31 02:54:09 UTC');
    console.info('[心率页面] 页面版本: v4.2.0, 功能: 修复ArkTS类型检查错误');
    console.info('[心率页面] 核心修复: 使用明确的类型定义，避免对象字面量');
    console.info('[心率页面] 开始初始化心率监测系统');

    this.initializeHeartRateSystem();
  }

  private async initializeHeartRateSystem(): Promise<void> {
    try {
      console.info('[系统初始化] ======== 心率监测系统初始化开始 ========');
      console.info('[系统初始化] 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');
      console.info('[系统初始化] 类型安全: 使用明确的类和接口定义');

      await this.initPreferences();
      await this.loadHeartRateDataFromStorage();
      this.calculateHeartRateStatistics();
      this.isLoading = false;

      console.info('[系统初始化] ======== 心率监测系统初始化成功 ========');
      console.info(`[系统初始化] 最终状态: 当前=${this.currentHeartRate}, 静息=${this.restingHeartRate}, 最高=${this.maxHeartRate}, 平均=${this.avgHeartRate}, 最低=${this.minHeartRate}`);
      console.info(`[系统初始化] 实时记录数量: ${this.heartRateRecords.length} 条`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error(`[系统初始化] 初始化失败: ${errorMessage}`);
      console.error(`[系统初始化] 当前用户: gadz2021, 错误时间: 2025-05-31 02:54:09 UTC`);
      this.errorMessage = `数据加载失败: ${errorMessage}`;
      this.isLoading = false;
      this.loadDefaultHeartRateData();
    }
  }

  private async initPreferences(): Promise<void> {
    console.info('[存储系统] ======== 初始化鸿蒙Preferences存储系统 ========');
    console.info('[存储系统] 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');

    this.preferencesHelper = await preferences.getPreferences(getContext(), 'health_data');

    console.info('[存储系统] Preferences连接成功，存储系统状态: 可用');
    console.info('[存储系统] 支持操作: get/put/flush/clear，数据持久化: 已启用');
  }

  private async loadHeartRateDataFromStorage(): Promise<void> {
    if (!this.preferencesHelper) {
      throw new Error('存储系统未初始化，无法读取数据');
    }

    console.info('[数据加载] ======== 开始从存储读取心率数据 ========');
    console.info('[数据加载] 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');
    console.info('[数据加载] 类型安全策略: 使用明确定义的类进行数据处理');

    const storedData = await this.preferencesHelper.get('health_records', '[]') as string;
    console.info(`[数据加载] 原始存储数据长度: ${storedData.length} 字符`);

    const healthRecords: StoredHeartRateData[] = JSON.parse(storedData);
    console.info(`[数据加载] JSON解析成功，健康记录总数: ${healthRecords.length} 条`);

    const heartRateRecords = healthRecords.filter((record: StoredHeartRateData) =>
    record.type === 'heart_rate' || record.type === 'heartrate'
    );
    console.info(`[数据加载] 心率记录过滤完成，找到 ${heartRateRecords.length} 条心率记录`);

    if (heartRateRecords.length === 0) {
      console.warn('[数据加载] 存储中无心率记录，将使用默认数据');
      return;
    }

    this.processHeartRateRecords(heartRateRecords);
    console.info('[数据加载] ======== 心率数据加载完成 ========');
  }

  private processHeartRateRecords(storedRecords: StoredHeartRateData[]): void {
    console.info('[数据处理] ======== 开始处理心率记录（类型安全版） ========');
    console.info(`[数据处理] 当前用户: gadz2021, 处理时间: 2025-05-31 02:54:09 UTC`);
    console.info(`[数据处理] 待处理记录总数: ${storedRecords.length} 条`);
    console.info(`[数据处理] 类型安全: 使用CategoryFlags类替代对象字面量`);

    const processedRecords: HeartRateRecord[] = [];
    const categoryFlags = new CategoryFlags();

    storedRecords.forEach((record: StoredHeartRateData, index: number) => {
      console.info(`[数据处理] 处理第 ${index + 1}/${storedRecords.length} 条记录`);
      console.info(`[数据处理] 记录详情: ${record.toString()}`);

      const heartRateValue = parseInt(record.value) || 0;
      if (heartRateValue <= 0) {
        console.warn(`[数据处理] 心率数值无效: ${record.value}, 跳过处理`);
        return;
      }

      const timeStr = this.extractTimeFromTimestamp(record.timestamp);
      const status = this.getHeartRateStatus(heartRateValue);
      const category = record.additionalInfo?.category || '实时';
      const categoryLower = category.toLowerCase();

      console.info(`[数据处理] 心率值: ${heartRateValue} bpm, 原始类别: "${category}"`);
      console.info(`[数据处理] 类别分析: "${categoryLower}"`);

      // 严格的类别识别和分类处理
      if (categoryLower.includes('当前') || categoryLower.includes('current')) {
        if (!categoryFlags.current) {
          this.currentHeartRate = heartRateValue;
          categoryFlags.current = true;
          console.info(`[数据处理] ✅ 设置当前心率: ${heartRateValue} bpm（不添加到实时记录）`);
        }
      } else if (categoryLower.includes('静息') || categoryLower.includes('resting')) {
        if (!categoryFlags.resting) {
          this.restingHeartRate = heartRateValue;
          categoryFlags.resting = true;
          console.info(`[数据处理] ✅ 设置静息心率: ${heartRateValue} bpm（不添加到实时记录）`);
        }
      } else if (categoryLower.includes('最高') || categoryLower.includes('max') || categoryLower.includes('highest')) {
        if (!categoryFlags.max) {
          this.maxHeartRate = heartRateValue;
          categoryFlags.max = true;
          console.info(`[数据处理] ✅ 设置最高心率: ${heartRateValue} bpm（不添加到实时记录）`);
        }
      } else if (categoryLower.includes('最低') || categoryLower.includes('min') || categoryLower.includes('lowest')) {
        if (!categoryFlags.min) {
          this.minHeartRate = heartRateValue;
          categoryFlags.min = true;
          console.info(`[数据处理] ✅ 设置最低心率: ${heartRateValue} bpm（不添加到实时记录）`);
        }
      } else if (categoryLower.includes('平均') || categoryLower.includes('avg') || categoryLower.includes('average')) {
        if (!categoryFlags.avg) {
          this.avgHeartRate = heartRateValue;
          categoryFlags.avg = true;
          console.info(`[数据处理] ✅ 设置平均心率: ${heartRateValue} bpm（不添加到实时记录）`);
        }
      } else {
        // 只有真正的实时记录才添加到列表中
        const heartRateRecord = new HeartRateRecord(timeStr, heartRateValue, status, record.timestamp, category);
        processedRecords.push(heartRateRecord);
        console.info(`[数据处理] ✅ 添加实时记录: ${heartRateRecord.toString()}`);
      }

      // 从additionalInfo中提取统计数据（备用方案）
      if (record.additionalInfo) {
        this.extractAdditionalStatistics(record.additionalInfo, categoryFlags);
      }
    });

    // 按时间排序，最新的在前
    processedRecords.sort((a: HeartRateRecord, b: HeartRateRecord) =>
    b.timestamp.localeCompare(a.timestamp)
    );

    this.heartRateRecords = processedRecords;

    console.info('[数据处理] ======== 心率记录处理完成（类型安全版） ========');
    console.info(`[数据处理] 分类标志状态: ${categoryFlags.toString()}`);
    console.info(`[数据处理] 最终统计: 当前=${this.currentHeartRate}, 静息=${this.restingHeartRate}, 最高=${this.maxHeartRate}, 最低=${this.minHeartRate}, 平均=${this.avgHeartRate}`);
    console.info(`[数据处理] 实时记录数量: ${processedRecords.length} 条（纯实时数据）`);
  }

  private extractAdditionalStatistics(additionalInfo: HeartRateAdditionalInfo, categoryFlags: CategoryFlags): void {
    console.info(`[统计提取] 检查附加统计信息: ${additionalInfo.toString()}`);
    console.info(`[统计提取] 当前分类标志状态: ${categoryFlags.toString()}`);

    if (additionalInfo.maxValue && additionalInfo.maxValue !== '' && !categoryFlags.max) {
      const maxValue = parseInt(additionalInfo.maxValue) || 0;
      if (maxValue > 0) {
        this.maxHeartRate = maxValue;
        categoryFlags.max = true;
        console.info(`[统计提取] ✅ 从附加信息设置最高心率: ${maxValue} bpm（不添加到实时记录）`);
      }
    }

    if (additionalInfo.avgValue && additionalInfo.avgValue !== '' && !categoryFlags.avg) {
      const avgValue = parseInt(additionalInfo.avgValue) || 0;
      if (avgValue > 0) {
        this.avgHeartRate = avgValue;
        categoryFlags.avg = true;
        console.info(`[统计提取] ✅ 从附加信息设置平均心率: ${avgValue} bpm（不添加到实时记录）`);
      }
    }

    if (additionalInfo.minValue && additionalInfo.minValue !== '' && !categoryFlags.min) {
      const minValue = parseInt(additionalInfo.minValue) || 0;
      if (minValue > 0) {
        this.minHeartRate = minValue;
        categoryFlags.min = true;
        console.info(`[统计提取] ✅ 从附加信息设置最低心率: ${minValue} bpm（不添加到实时记录）`);
      }
    }

    console.info(`[统计提取] 提取完成后分类标志状态: ${categoryFlags.toString()}`);
  }

  private extractTimeFromTimestamp(timestamp: string): string {
    if (!timestamp) return new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });

    if (timestamp.includes(' ')) {
      const timePart = timestamp.split(' ')[1];
      if (timePart && timePart.includes(':')) {
        const timeComponents = timePart.split(':');
        return `${timeComponents[0]}:${timeComponents[1]}`;
      }
    }

    const date = new Date(timestamp);
    if (!isNaN(date.getTime())) {
      return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
    }

    return new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
  }

  private getHeartRateStatus(value: number): string {
    if (value < 60) return getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_low_status_62938475'));
    if (value <= 100) return getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_normal_status_84739261'));
    if (value <= 120) return getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_slightly_high_status_57382946'));
    return getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_high_status_39284751'));
  }

  private calculateHeartRateStatistics(): void {
    console.info('[统计计算] ======== 开始计算心率统计数据 ========');
    console.info('[统计计算] 当前用户: gadz2021, 计算时间: 2025-05-31 02:54:09 UTC');
    console.info(`[统计计算] 当前状态: 当前=${this.currentHeartRate}, 静息=${this.restingHeartRate}, 最高=${this.maxHeartRate}, 平均=${this.avgHeartRate}, 最低=${this.minHeartRate}`);
    console.info(`[统计计算] 实时记录数量: ${this.heartRateRecords.length} 条`);

    // 如果某些统计数据缺失，从实时记录中计算
    if (this.heartRateRecords.length > 0) {
      const values = this.heartRateRecords.map((record: HeartRateRecord) => record.value);
      console.info(`[统计计算] 实时记录心率数值: ${values.join(', ')}`);

      if (this.minHeartRate === 0) {
        this.minHeartRate = Math.min(...values);
        console.info(`[统计计算] 从实时记录计算最低心率: ${this.minHeartRate} bpm`);
      }

      if (this.maxHeartRate === 0) {
        this.maxHeartRate = Math.max(...values);
        console.info(`[统计计算] 从实时记录计算最高心率: ${this.maxHeartRate} bpm`);
      }

      if (this.avgHeartRate === 0) {
        this.avgHeartRate = Math.round(values.reduce((sum: number, value: number) => sum + value, 0) / values.length);
        console.info(`[统计计算] 从实时记录计算平均心率: ${this.avgHeartRate} bpm`);
      }
    }

    // 更新统计对象
    this.heartRateStats.currentValue = this.currentHeartRate;
    this.heartRateStats.restingValue = this.restingHeartRate;
    this.heartRateStats.minValue = this.minHeartRate;
    this.heartRateStats.maxValue = this.maxHeartRate;
    this.heartRateStats.avgValue = this.avgHeartRate;
    this.heartRateStats.recordCount = this.heartRateRecords.length;

    console.info('[统计计算] ======== 心率统计计算完成 ========');
    console.info(`[统计计算] 最终统计: ${this.heartRateStats.toString()}`);
  }

  private loadDefaultHeartRateData(): void {
    console.info('[默认数据] ======== 加载默认心率数据 ========');
    console.info('[默认数据] 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');

    const defaultRecords: HeartRateRecord[] = [
      new HeartRateRecord('08:00', 75, '正常', '2025-05-31 08:00:00', '实时'),
      new HeartRateRecord('10:30', 82, '正常', '2025-05-31 10:30:00', '实时'),
      new HeartRateRecord('12:15', 68, '正常', '2025-05-31 12:15:00', '实时')
    ];

    this.heartRateRecords = defaultRecords;
    this.currentHeartRate = 75;
    this.restingHeartRate = 65;
    this.minHeartRate = 68;
    this.maxHeartRate = 82;
    this.avgHeartRate = 75;

    this.heartRateStats.currentValue = this.currentHeartRate;
    this.heartRateStats.restingValue = this.restingHeartRate;
    this.heartRateStats.minValue = this.minHeartRate;
    this.heartRateStats.maxValue = this.maxHeartRate;
    this.heartRateStats.avgValue = this.avgHeartRate;
    this.heartRateStats.recordCount = defaultRecords.length;

    console.info('[默认数据] ======== 默认数据加载完成 ========');
  }

  private refreshHeartRateData(): void {
    console.info('[数据刷新] ======== 开始刷新心率数据 ========');
    console.info('[数据刷新] 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');

    this.isLoading = true;
    this.errorMessage = '';
    this.initializeHeartRateSystem();
  }

  private showRecordDetail(record: HeartRateRecord): void {
    console.info(`[记录详情] ======== 显示心率记录详情 ========`);
    console.info(`[记录详情] 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC`);
    console.info(`[记录详情] 记录详情: ${record.toString()}`);

    const timeLabel = getContext(this).resourceManager.getStringSync($r('app.string.record_time_label_84739261')).replace('{0}', record.time);
    const valueLabel = getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_value_label_57382946')).replace('{0}', record.value.toString());
    const statusLabel = getContext(this).resourceManager.getStringSync($r('app.string.health_status_label_39284751')).replace('{0}', record.status);
    const typeLabel = getContext(this).resourceManager.getStringSync($r('app.string.record_type_label_75839462')).replace('{0}', record.category);
    const adviceLabel = getContext(this).resourceManager.getStringSync($r('app.string.health_advice_label_18475936')).replace('{0}', this.getHealthAdviceForValue(record.value));

    const detailMessage = `${timeLabel}\n${valueLabel}\n${statusLabel}\n${typeLabel}\n\n${adviceLabel}`;

    AlertDialog.show({
      title: getContext(this).resourceManager.getStringSync($r('app.string.record_detail_title_18475936')),
      message: detailMessage,
      primaryButton: {
        value: getContext(this).resourceManager.getStringSync($r('app.string.close_button_text_62938475')),
        action: () => {
          console.info('[记录详情] 用户关闭详情弹窗');
          console.info('[记录详情] 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');
        }
      }
    });
  }

  private getHealthAdviceForValue(value: number): string {
    if (value < 60) return getContext(this).resourceManager.getStringSync($r('app.string.low_heart_rate_advice_75839462'));
    if (value <= 100) return getContext(this).resourceManager.getStringSync($r('app.string.normal_heart_rate_advice_18475936'));
    if (value <= 120) return getContext(this).resourceManager.getStringSync($r('app.string.slightly_high_advice_62938475'));
    return getContext(this).resourceManager.getStringSync($r('app.string.high_heart_rate_advice_84739261'));
  }

  private getStatusColor(value: number): string {
    if (value < 60) return '#FBBC05';
    if (value <= 100) return '#34A853';
    if (value <= 120) return '#FF9800';
    return '#EA4335';
  }

  private getStatusBackgroundColor(value: number): string {
    if (value < 60) return 'rgba(251, 188, 5, 0.1)';
    if (value <= 100) return 'rgba(52, 168, 83, 0.1)';
    if (value <= 120) return 'rgba(255, 152, 0, 0.1)';
    return 'rgba(234, 67, 53, 0.1)';
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back')).width(24).height(24)
        }
        .onClick(() => {
          console.info('[用户操作] 用户点击返回按钮, 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');
          try {
            router.back();
            console.info('[用户操作] 路由返回成功');
          } catch (err) {
            console.error('[用户操作] 路由返回失败，执行降级方案');
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(44).height(44).backgroundColor(Color.Transparent).margin({ left: 12 })

        Text(getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_monitoring_title_84729638'))).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('🔄').fontSize(18)
        }
        .onClick(() => {
          console.info('[用户操作] 用户点击刷新按钮, 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');
          this.refreshHeartRateData();
        })
        .width(44).height(44).backgroundColor(Color.Transparent).margin({ right: 12 })
      }
      .width('100%').height(64).justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFF').shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

      if (this.isLoading) {
        // 加载状态
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#EA4335')
          Text(getContext(this).resourceManager.getStringSync($r('app.string.loading_heart_rate_data_57284916'))).fontSize(18).fontColor('#333333')
          Text(getContext(this).resourceManager.getStringSync($r('app.string.current_user_prefix_39475829'))).fontSize(12).fontColor('#999999')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        // 错误状态
        Column({ space: 20 }) {
          Text('💔').fontSize(64)
          Text(getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_load_failed_75163948'))).fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button(getContext(this).resourceManager.getStringSync($r('app.string.reload_button_text_18394756')))
            .onClick(() => {
              console.info('[用户操作] 用户点击重新加载按钮, 当前用户: gadz2021, 时间: 2025-05-31 02:54:09 UTC');
              this.isLoading = true;
              this.errorMessage = '';
              this.initializeHeartRateSystem();
            })
            .backgroundColor('#EA4335').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        // 正常内容
        Scroll() {
          Column({ space: 20 }) {
            // 当前心率卡片
            Column({ space: 16 }) {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.current_heart_rate_62847593'))).fontSize(18).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center)
              Row({ space: 8 }) {
                Text('❤️').fontSize(32)
                Text(this.currentHeartRate.toString()).fontSize(48).fontWeight(FontWeight.Bold).fontColor('#EA4335')
                Text(getContext(this).resourceManager.getStringSync($r('app.string.bpm_unit_text_94738261'))).fontSize(20).fontColor('#666666').margin({ bottom: 8 })
              }
              .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Bottom)

              Text(this.getHeartRateStatus(this.currentHeartRate))
                .fontSize(16).fontColor(this.getStatusColor(this.currentHeartRate))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.getStatusBackgroundColor(this.currentHeartRate)).borderRadius(12)

              Text(getContext(this).resourceManager.getStringSync($r('app.string.normal_range_text_84751639'))).fontSize(14).fontColor('#999999').textAlign(TextAlign.Center)
              Text(getContext(this).resourceManager.getStringSync($r('app.string.resting_heart_rate_57382946')).replace('{0}', this.restingHeartRate.toString())).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
            }
            .width('100%').padding(24).backgroundColor('#FFFFFF').borderRadius(16)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetY: 4 })

            // 统计卡片
            Row({ space: 12 }) {
              // 使用明确定义的类替代对象字面量
              Column({ space: 8 }) {
                Text('📉').fontSize(20)
                Text(getContext(this).resourceManager.getStringSync($r('app.string.lowest_heart_rate_39284751'))).fontSize(12).fontColor('#999999').textAlign(TextAlign.Center)
                Row({ space: 4 }) {
                  Text(this.minHeartRate.toString()).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#4285F4')
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.bpm_unit_text_94738261'))).fontSize(12).fontColor('#666666').margin({ bottom: 2 })
                }
                .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Bottom)
              }
              .width('30%').height(100).padding(12).backgroundColor('#FFFFFF').borderRadius(12)
              .justifyContent(FlexAlign.Center).border({ width: 1, color: '#4285F4' })
              .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetY: 3 })

              Column({ space: 8 }) {
                Text('📊').fontSize(20)
                Text(getContext(this).resourceManager.getStringSync($r('app.string.average_heart_rate_75839462'))).fontSize(12).fontColor('#999999').textAlign(TextAlign.Center)
                Row({ space: 4 }) {
                  Text(this.avgHeartRate.toString()).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#34A853')
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.bpm_unit_text_94738261'))).fontSize(12).fontColor('#666666').margin({ bottom: 2 })
                }
                .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Bottom)
              }
              .width('30%').height(100).padding(12).backgroundColor('#FFFFFF').borderRadius(12)
              .justifyContent(FlexAlign.Center).border({ width: 1, color: '#34A853' })
              .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetY: 3 })

              Column({ space: 8 }) {
                Text('📈').fontSize(20)
                Text(getContext(this).resourceManager.getStringSync($r('app.string.highest_heart_rate_18475936'))).fontSize(12).fontColor('#999999').textAlign(TextAlign.Center)
                Row({ space: 4 }) {
                  Text(this.maxHeartRate.toString()).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#EA4335')
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.bpm_unit_text_94738261'))).fontSize(12).fontColor('#666666').margin({ bottom: 2 })
                }
                .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Bottom)
              }
              .width('30%').height(100).padding(12).backgroundColor('#FFFFFF').borderRadius(12)
              .justifyContent(FlexAlign.Center).border({ width: 1, color: '#EA4335' })
              .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetY: 3 })
            }
            .width('100%').justifyContent(FlexAlign.SpaceBetween)

            // 心率记录列表
            Column({ space: 16 }) {
              Row() {
                Text(getContext(this).resourceManager.getStringSync($r('app.string.realtime_heart_records_62938475'))).fontSize(18).fontWeight(FontWeight.Bold)
                Blank()
                Text(getContext(this).resourceManager.getStringSync($r('app.string.total_records_count_84739261')).replace('{0}', this.heartRateRecords.length.toString())).fontSize(12).fontColor('#999999')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor('#F0F0F0').borderRadius(12)
              }

              if (this.heartRateRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('💔').fontSize(48)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.no_realtime_records_57382946'))).fontSize(18).fontColor('#666666')
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.realtime_only_description_39284751'))).fontSize(12).fontColor('#999999').textAlign(TextAlign.Center)
                  Button(getContext(this).resourceManager.getStringSync($r('app.string.refresh_data_button_75839462'))).onClick(() => this.refreshHeartRateData())
                    .backgroundColor('#EA4335').fontColor(Color.White).borderRadius(20).height(40)
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                List({ space: 8 }) {
                  ForEach(this.heartRateRecords, (record: HeartRateRecord) => {
                    ListItem() {
                      Row({ space: 16 }) {
                        Column({ space: 4 }) {
                          Text(record.time).fontSize(16).fontColor('#333333')
                          Text(record.category).fontSize(12).fontColor('#999999')
                        }
                        .alignItems(HorizontalAlign.Start)

                        Blank()

                        Column({ space: 4 }) {
                          Row({ space: 4 }) {
                            Text('❤️').fontSize(14)
                            Text(`${record.value}`).fontSize(18).fontColor(this.getStatusColor(record.value)).fontWeight(FontWeight.Bold)
                            Text(getContext(this).resourceManager.getStringSync($r('app.string.bpm_unit_text_94738261'))).fontSize(12).fontColor('#666666')
                          }
                          .justifyContent(FlexAlign.Center)

                          Text(record.status).fontSize(12).fontColor(this.getStatusColor(record.value))
                            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                            .backgroundColor(this.getStatusBackgroundColor(record.value)).borderRadius(8)
                        }
                        .alignItems(HorizontalAlign.End)
                      }
                      .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)
                      .onClick(() => {
                        this.showRecordDetail(record);
                      })
                    }
                  })
                }
                .width('100%').height(300).scrollBar(BarState.Auto)
              }
            }
            .width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(16)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetY: 4 })

            // 健康建议
            Column({ space: 16 }) {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.heart_health_tips_title_18475936'))).fontSize(18).fontWeight(FontWeight.Bold)
              Text(getContext(this).resourceManager.getStringSync($r('app.string.heart_health_tips_intro_62938475'))).fontSize(14).fontColor('#666666')

              Column({ space: 12 }) {
                Row({ space: 12 }) {
                  Text('📊').fontSize(18)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.normal_range_tip_84739261'))).fontSize(14).fontColor('#333333').layoutWeight(1).lineHeight(22)
                }
                .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)

                Row({ space: 12 }) {
                  Text('🏃‍♂️').fontSize(18)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.exercise_tip_57382946'))).fontSize(14).fontColor('#333333').layoutWeight(1).lineHeight(22)
                }
                .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)

                Row({ space: 12 }) {
                  Text('☕').fontSize(18)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.caffeine_tip_39284751'))).fontSize(14).fontColor('#333333').layoutWeight(1).lineHeight(22)
                }
                .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)

                Row({ space: 12 }) {
                  Text('👨‍⚕️').fontSize(18)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.consult_doctor_tip_75839462'))).fontSize(14).fontColor('#333333').layoutWeight(1).lineHeight(22)
                }
                .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)
              }
            }
            .width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(16)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetY: 4 })
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor('#F8F9FA')
  }
}