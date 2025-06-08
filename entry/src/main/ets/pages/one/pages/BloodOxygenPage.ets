import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';

// 血氧记录数据结构

class OxygenRecord {
  time: string = '';
  value: number = 0;
  status: string = '';
  timestamp: string = '';
  category: string = '';

  constructor(time: string, value: number, status: string, timestamp?: string, category?: string) {
    console.info('[血氧记录构造] ======== 创建血氧记录对象 ========');
    console.info(`[血氧记录构造] 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC`);
    console.info(`[血氧记录构造] 参数: time=${time}, value=${value}%, status=${status}, category=${category || '实时'}`);

    this.time = time;
    this.value = value;
    this.status = status;
    this.timestamp = timestamp || '';
    this.category = category || '实时';

    console.info(`[血氧记录构造] 血氧记录对象创建完成: ${this.toString()}`);
  }

  toString(): string {
    return `OxygenRecord{time: ${this.time}, value: ${this.value}%, status: ${this.status}, category: ${this.category}}`;
  }
}

// 血氧统计数据结构
class OxygenStats {
  minValue: number = 0;
  maxValue: number = 0;
  avgValue: number = 0;
  currentValue: number = 0;
  recordCount: number = 0;

  constructor() {}

  toString(): string {
    return `OxygenStats{min: ${this.minValue}%, max: ${this.maxValue}%, avg: ${this.avgValue}%, current: ${this.currentValue}%, count: ${this.recordCount}}`;
  }
}

// 存储的血氧数据结构
class StoredOxygenData {
  timestamp: string = '';
  type: string = '';
  value: string = '';
  unit: string = '';
  additionalInfo: OxygenAdditionalInfo = new OxygenAdditionalInfo();

  constructor(timestamp: string, type: string, value: string, unit: string, additionalInfo?: OxygenAdditionalInfo) {
    this.timestamp = timestamp;
    this.type = type;
    this.value = value;
    this.unit = unit;
    if (additionalInfo) {
      this.additionalInfo = additionalInfo;
    }
  }

  toString(): string {
    return `StoredOxygenData{timestamp: "${this.timestamp}", type: "${this.type}", value: "${this.value}%", category: "${this.additionalInfo.category}"}`;
  }
}

// 血氧附加信息结构
class OxygenAdditionalInfo {
  category: string = '';
  minValue: string = '';
  maxValue: string = '';
  avgValue: string = '';

  constructor() {}

  toString(): string {
    return `OxygenAdditionalInfo{category: "${this.category}", min: "${this.minValue}%", max: "${this.maxValue}%", avg: "${this.avgValue}%"}`;
  }
}

// 分类标志类
class CategoryFlags {
  current: boolean = false;
  max: boolean = false;
  min: boolean = false;
  avg: boolean = false;

  constructor() {}

  toString(): string {
    return `CategoryFlags{current: ${this.current}, max: ${this.max}, min: ${this.min}, avg: ${this.avg}}`;
  }
}

@Entry
@Component
export struct BloodOxygenPage {
  @State currentOxygen: number = 0;
  @State minOxygen: number = 0;
  @State maxOxygen: number = 0;
  @State avgOxygen: number = 0;
  @State oxygenRecords: OxygenRecord[] = [];
  @State selectedTimeRange: string = '';
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State oxygenStats: OxygenStats = new OxygenStats();
  @State hasDataLoaded: boolean = false;

  private preferencesHelper: preferences.Preferences | null = null;

  private getTimeRanges(): string[] {
    return [
      getContext(this).resourceManager.getStringSync($r('app.string.today_timerange_629384751952847847392615738294751629384751952847392')),
      getContext(this).resourceManager.getStringSync($r('app.string.this_week_timerange_847392615738294184759362847392847392615738294847392')),
      getContext(this).resourceManager.getStringSync($r('app.string.this_month_timerange_573829461847392847392615738294751629384751952847392')),
      getContext(this).resourceManager.getStringSync($r('app.string.this_year_timerange_392847516293847184759362847392615738294847392615738'))
    ];
  }

  aboutToAppear(): void {
    console.info('[血氧页面] ================ 智能血氧监测系统初始化开始 ================');
    console.info('[血氧页面] 当前用户: gadz2021, 系统时间: 2025-05-31 03:44:39 UTC');
    console.info('[血氧页面] 页面版本: v1.1.0, 功能: 血氧数据持久化存储与读取');
    console.info('[血氧页面] 核心功能: 当前、最低、平均、最高血氧统计，实时血氧记录分离');
    console.info('[血氧页面] 修复内容: 无数据时显示0，数据读取异常处理');
    console.info('[血氧页面] 数据来源: 鸿蒙Preferences持久化存储系统');
    console.info('[血氧页面] 开始初始化血氧监测系统');

    this.selectedTimeRange = getContext(this).resourceManager.getStringSync($r('app.string.today_timerange_629384751952847847392615738294751629384751952847392'));
    this.initializeOxygenSystem();
  }

  private async initializeOxygenSystem(): Promise<void> {
    try {
      console.info('[系统初始化] ======== 血氧监测系统初始化开始 ========');
      console.info('[系统初始化] 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC');
      console.info('[系统初始化] 目标: 从持久化存储加载血氧数据，智能分类统计与实时数据');
      console.info('[系统初始化] 策略: 无数据时显示0，有数据时显示真实值');

      // 重置所有数据为0
      this.resetOxygenData();

      await this.initPreferences();
      await this.loadOxygenDataFromStorage();
      this.calculateOxygenStatistics();
      this.isLoading = false;

      console.info('[系统初始化] ======== 血氧监测系统初始化成功 ========');
      console.info(`[系统初始化] 数据加载状态: ${this.hasDataLoaded ? '已加载真实数据' : '无数据显示0'}`);
      console.info(`[系统初始化] 最终血氧统计: 当前=${this.currentOxygen}%, 最高=${this.maxOxygen}%, 平均=${this.avgOxygen}%, 最低=${this.minOxygen}%`);
      console.info(`[系统初始化] 实时血氧记录数量: ${this.oxygenRecords.length} 条`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error(`[系统初始化] 血氧系统初始化失败: ${errorMessage}`);
      console.error(`[系统初始化] 当前用户: gadz2021, 错误时间: 2025-05-31 03:44:39 UTC`);
      this.errorMessage = `血氧数据加载失败: ${errorMessage}`;
      this.isLoading = false;
      this.resetOxygenData();
    }
  }

  private resetOxygenData(): void {
    console.info('[数据重置] ======== 重置血氧数据为初始状态 ========');
    console.info('[数据重置] 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC');
    console.info('[数据重置] 策略: 所有统计数据设为0，实时记录清空');

    this.currentOxygen = 0;
    this.minOxygen = 0;
    this.maxOxygen = 0;
    this.avgOxygen = 0;
    this.oxygenRecords = [];
    this.hasDataLoaded = false;

    this.oxygenStats.currentValue = 0;
    this.oxygenStats.minValue = 0;
    this.oxygenStats.maxValue = 0;
    this.oxygenStats.avgValue = 0;
    this.oxygenStats.recordCount = 0;

    console.info('[数据重置] 血氧数据重置完成，所有值已设为0');
  }

  private async initPreferences(): Promise<void> {
    console.info('[存储系统] ======== 初始化鸿蒙Preferences存储系统 ========');
    console.info('[存储系统] 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC');
    console.info('[存储系统] 存储域: health_data, 目标键: health_records');
    console.info('[存储系统] 血氧数据类型: blood_oxygen, 单位: %');

    this.preferencesHelper = await preferences.getPreferences(getContext(), 'health_data');

    console.info('[存储系统] Preferences连接成功，血氧数据存储系统可用');
    console.info('[存储系统] 支持操作: 血氧数据读取、统计计算、实时记录分离');
  }

  private async loadOxygenDataFromStorage(): Promise<void> {
    if (!this.preferencesHelper) {
      console.warn('[血氧数据加载] 存储系统未初始化，跳过数据加载');
      return;
    }

    try {
      console.info('[血氧数据加载] ======== 开始从存储读取血氧数据 ========');
      console.info('[血氧数据加载] 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC');
      console.info('[血氧数据加载] 读取策略: 匹配blood_oxygen类型，基于category字段智能分类');

      const storedData = await this.preferencesHelper.get('health_records', '[]') as string;
      console.info(`[血氧数据加载] 原始存储数据长度: ${storedData.length} 字符`);

      if (storedData === '[]' || storedData.length === 0) {
        console.warn('[血氧数据加载] 存储为空，保持数据为0状态');
        console.info('[血氧数据加载] ======== 血氧数据加载完成（无数据） ========');
        return;
      }

      const healthRecords: StoredOxygenData[] = JSON.parse(storedData);
      console.info(`[血氧数据加载] JSON解析成功，健康记录总数: ${healthRecords.length} 条`);

      const oxygenRecords = healthRecords.filter((record: StoredOxygenData) =>
      record.type === 'blood_oxygen'
      );
      console.info(`[血氧数据加载] 血氧记录过滤完成，找到 ${oxygenRecords.length} 条血氧记录`);

      if (oxygenRecords.length === 0) {
        console.warn('[血氧数据加载] 无血氧记录，保持数据为0状态');
        console.info('[血氧数据加载] ======== 血氧数据加载完成（无血氧数据） ========');
        return;
      }

      this.processOxygenRecords(oxygenRecords);
      this.hasDataLoaded = true;
      console.info('[血氧数据加载] ======== 血氧数据加载完成（有数据） ========');
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error(`[血氧数据加载] 数据加载异常: ${errorMessage}`);
      console.error(`[血氧数据加载] 保持数据为0状态`);
    }
  }

  private processOxygenRecords(storedRecords: StoredOxygenData[]): void {
    console.info('[血氧数据处理] ======== 开始处理血氧记录（智能分类版） ========');
    console.info(`[血氧数据处理] 当前用户: gadz2021, 处理时间: 2025-05-31 03:44:39 UTC`);
    console.info(`[血氧数据处理] 待处理血氧记录总数: ${storedRecords.length} 条`);
    console.info(`[血氧数据处理] 分类策略: 基于category字段分离统计数据和实时数据`);

    const processedRecords: OxygenRecord[] = [];
    const categoryFlags = new CategoryFlags();

    storedRecords.forEach((record: StoredOxygenData, index: number) => {
      console.info(`[血氧数据处理] 处理第 ${index + 1}/${storedRecords.length} 条血氧记录`);
      console.info(`[血氧数据处理] 血氧记录详情: ${record.toString()}`);

      const oxygenValue = parseInt(record.value) || 0;
      if (oxygenValue <= 0) {
        console.warn(`[血氧数据处理] 血氧数值无效: ${record.value}%, 跳过处理`);
        return;
      }

      const timeStr = this.extractTimeFromTimestamp(record.timestamp);
      const status = this.getOxygenStatus(oxygenValue);
      const category = record.additionalInfo?.category || '实时';
      const categoryLower = category.toLowerCase();

      console.info(`[血氧数据处理] 血氧值: ${oxygenValue}%, 原始类别: "${category}"`);
      console.info(`[血氧数据处理] 类别分析: "${categoryLower}"`);

      // 严格的血氧类别识别和分类处理
      if (categoryLower.includes('当前') || categoryLower.includes('current')) {
        if (!categoryFlags.current) {
          this.currentOxygen = oxygenValue;
          categoryFlags.current = true;
          console.info(`[血氧数据处理] ✅ 设置当前血氧: ${oxygenValue}% （不添加到实时记录）`);
        }
      } else if (categoryLower.includes('最高') || categoryLower.includes('max') || categoryLower.includes('highest')) {
        if (!categoryFlags.max) {
          this.maxOxygen = oxygenValue;
          categoryFlags.max = true;
          console.info(`[血氧数据处理] ✅ 设置最高血氧: ${oxygenValue}% （不添加到实时记录）`);
        }
      } else if (categoryLower.includes('最低') || categoryLower.includes('min') || categoryLower.includes('lowest')) {
        if (!categoryFlags.min) {
          this.minOxygen = oxygenValue;
          categoryFlags.min = true;
          console.info(`[血氧数据处理] ✅ 设置最低血氧: ${oxygenValue}% （不添加到实时记录）`);
        }
      } else if (categoryLower.includes('平均') || categoryLower.includes('avg') || categoryLower.includes('average')) {
        if (!categoryFlags.avg) {
          this.avgOxygen = oxygenValue;
          categoryFlags.avg = true;
          console.info(`[血氧数据处理] ✅ 设置平均血氧: ${oxygenValue}% （不添加到实时记录）`);
        }
      } else {
        // 只有真正的实时记录才添加到列表中
        const oxygenRecord = new OxygenRecord(timeStr, oxygenValue, status, record.timestamp, category);
        processedRecords.push(oxygenRecord);
        console.info(`[血氧数据处理] ✅ 添加实时血氧记录: ${oxygenRecord.toString()}`);
      }

      // 从additionalInfo中提取统计数据（备用方案）
      if (record.additionalInfo) {
        this.extractAdditionalStatistics(record.additionalInfo, categoryFlags);
      }
    });

    // 按时间排序，最新的在前
    processedRecords.sort((a: OxygenRecord, b: OxygenRecord) =>
    b.timestamp.localeCompare(a.timestamp)
    );

    this.oxygenRecords = processedRecords;

    console.info('[血氧数据处理] ======== 血氧记录处理完成（智能分类版） ========');
    console.info(`[血氧数据处理] 分类设置结果:`);
    console.info(`[血氧数据处理] - 当前血氧: ${categoryFlags.current ? this.currentOxygen + '%' : '0% (未设置)'}`);
    console.info(`[血氧数据处理] - 最高血氧: ${categoryFlags.max ? this.maxOxygen + '%' : '0% (未设置)'}`);
    console.info(`[血氧数据处理] - 最低血氧: ${categoryFlags.min ? this.minOxygen + '%' : '0% (未设置)'}`);
    console.info(`[血氧数据处理] - 平均血氧: ${categoryFlags.avg ? this.avgOxygen + '%' : '0% (未设置)'}`);
    console.info(`[血氧数据处理] - 实时血氧记录数量: ${processedRecords.length} 条（纯实时数据）`);
  }

  private extractAdditionalStatistics(additionalInfo: OxygenAdditionalInfo, categoryFlags: CategoryFlags): void {
    console.info(`[血氧统计提取] 检查附加血氧统计信息: ${additionalInfo.toString()}`);
    console.info(`[血氧统计提取] 当前分类标志状态: ${categoryFlags.toString()}`);

    if (additionalInfo.maxValue && additionalInfo.maxValue !== '' && !categoryFlags.max) {
      const maxValue = parseInt(additionalInfo.maxValue) || 0;
      if (maxValue > 0) {
        this.maxOxygen = maxValue;
        categoryFlags.max = true;
        console.info(`[血氧统计提取] ✅ 从附加信息设置最高血氧: ${maxValue}% （不添加到实时记录）`);
      }
    }

    if (additionalInfo.avgValue && additionalInfo.avgValue !== '' && !categoryFlags.avg) {
      const avgValue = parseInt(additionalInfo.avgValue) || 0;
      if (avgValue > 0) {
        this.avgOxygen = avgValue;
        categoryFlags.avg = true;
        console.info(`[血氧统计提取] ✅ 从附加信息设置平均血氧: ${avgValue}% （不添加到实时记录）`);
      }
    }

    if (additionalInfo.minValue && additionalInfo.minValue !== '' && !categoryFlags.min) {
      const minValue = parseInt(additionalInfo.minValue) || 0;
      if (minValue > 0) {
        this.minOxygen = minValue;
        categoryFlags.min = true;
        console.info(`[血氧统计提取] ✅ 从附加信息设置最低血氧: ${minValue}% （不添加到实时记录）`);
      }
    }

    console.info(`[血氧统计提取] 提取完成后分类标志状态: ${categoryFlags.toString()}`);
  }

  private extractTimeFromTimestamp(timestamp: string): string {
    console.info(`[时间解析] 解析血氧时间戳: ${timestamp}`);

    if (!timestamp) {
      const currentTime = new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
      console.info(`[时间解析] 时间戳为空，使用当前时间: ${currentTime}`);
      return currentTime;
    }

    if (timestamp.includes(' ')) {
      const timePart = timestamp.split(' ')[1];
      if (timePart && timePart.includes(':')) {
        const timeComponents = timePart.split(':');
        const extractedTime = `${timeComponents[0]}:${timeComponents[1]}`;
        console.info(`[时间解析] 血氧时间解析结果: ${extractedTime}`);
        return extractedTime;
      }
    }

    const date = new Date(timestamp);
    if (!isNaN(date.getTime())) {
      const extractedTime = date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
      console.info(`[时间解析] Date解析血氧时间结果: ${extractedTime}`);
      return extractedTime;
    }

    const fallbackTime = new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
    console.warn(`[时间解析] 血氧时间解析失败，使用当前时间: ${fallbackTime}`);
    return fallbackTime;
  }

  private getOxygenStatus(value: number): string {
    console.info(`[血氧状态判断] 判断血氧状态: ${value}%`);

    const statusMap = new Map<string, string>([
      ['严重偏低', '严重偏低'],
      ['偏低', '偏低'],
      ['正常', '正常'],
      ['异常', '异常']
    ]);

    const statusKey = value < 90 ? '严重偏低' : value < 95 ? '偏低' : value <= 100 ? '正常' : '异常';
    const status = statusMap.get(statusKey) as string;

    console.info(`[血氧状态判断] 血氧状态结果: ${status}`);
    return status;
  }

  private calculateOxygenStatistics(): void {
    console.info('[血氧统计计算] ======== 开始计算血氧统计数据 ========');
    console.info('[血氧统计计算] 当前用户: gadz2021, 计算时间: 2025-05-31 03:44:39 UTC');
    console.info(`[血氧统计计算] 数据加载状态: ${this.hasDataLoaded ? '有真实数据' : '无数据'}`);
    console.info(`[血氧统计计算] 当前血氧状态: 当前=${this.currentOxygen}%, 最高=${this.maxOxygen}%, 平均=${this.avgOxygen}%, 最低=${this.minOxygen}%`);
    console.info(`[血氧统计计算] 实时血氧记录数量: ${this.oxygenRecords.length} 条`);

    // 只有在有数据加载且某些统计数据缺失时，才从实时记录中计算
    if (this.hasDataLoaded && this.oxygenRecords.length > 0) {
      const values = this.oxygenRecords.map((record: OxygenRecord) => record.value);
      console.info(`[血氧统计计算] 实时血氧记录数值: ${values.join('%, ')}%`);

      if (this.minOxygen === 0) {
        this.minOxygen = Math.min(...values);
        console.info(`[血氧统计计算] 从实时记录计算最低血氧: ${this.minOxygen}%`);
      }

      if (this.maxOxygen === 0) {
        this.maxOxygen = Math.max(...values);
        console.info(`[血氧统计计算] 从实时记录计算最高血氧: ${this.maxOxygen}%`);
      }

      if (this.avgOxygen === 0) {
        this.avgOxygen = Math.round(values.reduce((sum: number, value: number) => sum + value, 0) / values.length);
        console.info(`[血氧统计计算] 从实时记录计算平均血氧: ${this.avgOxygen}%`);
      }
    } else {
      console.info(`[血氧统计计算] 无数据或无实时记录，保持统计数据为0`);
    }

    // 更新统计对象
    this.oxygenStats.currentValue = this.currentOxygen;
    this.oxygenStats.minValue = this.minOxygen;
    this.oxygenStats.maxValue = this.maxOxygen;
    this.oxygenStats.avgValue = this.avgOxygen;
    this.oxygenStats.recordCount = this.oxygenRecords.length;

    console.info('[血氧统计计算] ======== 血氧统计计算完成 ========');
    console.info(`[血氧统计计算] 最终血氧统计: ${this.oxygenStats.toString()}`);
  }

  private refreshOxygenData(): void {
    console.info('[数据刷新] ======== 开始刷新血氧数据 ========');
    console.info('[数据刷新] 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC');

    this.isLoading = true;
    this.errorMessage = '';
    this.initializeOxygenSystem();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back')).width(20).height(20)
        }
        .onClick(() => {
          console.info('[用户操作] 用户点击返回按钮, 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC');
          try {
            router.back();
            console.info('[用户操作] 血氧页面路由返回成功');
          } catch (err) {
            console.error('[用户操作] 血氧页面路由返回失败，执行降级方案');
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ left: 10 })

        Text(getContext(this).resourceManager.getStringSync($r('app.string.blood_oxygen_saturation_title_847392615738294629384751952847392615738'))).fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.Black)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('🔄').fontSize(18)
        }
        .onClick(() => {
          console.info('[用户操作] 用户点击刷新血氧数据按钮, 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC');
          this.refreshOxygenData();
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ right: 10 })
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        // 加载状态
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#9C27B0')
          Text(getContext(this).resourceManager.getStringSync($r('app.string.loading_oxygen_data_text_573829461847392847392615738294751629384751'))).fontSize(18).fontColor('#333333')
          Text(getContext(this).resourceManager.getStringSync($r('app.string.current_user_prefix_392847516293847184759362847392615738294847392'))).fontSize(12).fontColor('#999999')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        // 错误状态
        Column({ space: 20 }) {
          Text('🫁').fontSize(64)
          Text(getContext(this).resourceManager.getStringSync($r('app.string.oxygen_data_load_failed_758394627184759629384751952847392847392615738'))).fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button(getContext(this).resourceManager.getStringSync($r('app.string.reload_button_text_184759362847392573829461847392847392615738294')))
            .onClick(() => {
              console.info('[用户操作] 用户点击重新加载血氧数据按钮, 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC');
              this.refreshOxygenData();
            })
            .backgroundColor('#9C27B0').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        // 正常内容
        Scroll() {
          Column({ space: 20 }) {
            // 当前血氧显示
            Column() {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.current_oxygen_saturation_629384751952847847392615738294751629384751952'))).fontSize(18).fontWeight(FontWeight.Medium).margin({ bottom: 10 })

              Row() {
                Text(this.currentOxygen.toString()).fontSize(48).fontWeight(FontWeight.Bold).fontColor('#9C27B0')
                Text(' %').fontSize(20).fontColor('#666666').margin({ bottom: 5 })
              }

              Text(getContext(this).resourceManager.getStringSync($r('app.string.normal_range_text_847392615738294184759362847392847392615738294847')) + (this.hasDataLoaded ? '' : getContext(this).resourceManager.getStringSync($r('app.string.no_data_suffix_573829461847392847392615738294751629384751952847392')))).fontSize(14)
                .fontColor('#666666').margin({ top: 5 })
            }
            .width('90%').padding(20).backgroundColor('#F8F8F8').borderRadius(15)
            .justifyContent(FlexAlign.Center)

            // 统计数据
            Row() {
              this.statCard(getContext(this).resourceManager.getStringSync($r('app.string.lowest_label_392847516293847184759362847392615738294847392615738')), `${this.minOxygen} %`, '#FBBC05')
              this.statCard(getContext(this).resourceManager.getStringSync($r('app.string.average_label_758394627184759629384751952847392847392615738294751')), `${this.avgOxygen} %`, '#34A853')
              this.statCard(getContext(this).resourceManager.getStringSync($r('app.string.highest_label_184759362847392573829461847392847392615738294847392')), `${this.maxOxygen} %`, '#4285F4')
            }
            .width('90%').justifyContent(FlexAlign.SpaceBetween)

            // 时间范围选择器
            Row() {
              ForEach(this.getTimeRanges(), (range: string) => {
                Text(range)
                  .fontSize(14)
                  .fontColor(this.selectedTimeRange === range ? '#9C27B0' : '#666666')
                  .fontWeight(this.selectedTimeRange === range ? FontWeight.Bold : FontWeight.Normal)
                  .padding(8)
                  .backgroundColor(this.selectedTimeRange === range ? '#F3E5F5' : 'transparent')
                  .borderRadius(15)
                  .onClick(() => {
                    console.info(`[用户操作] 用户选择血氧时间范围: ${range}, 当前用户: gadz2021, 时间: 2025-05-31 03:44:39 UTC`);
                    this.selectedTimeRange = range;
                  })
              })
            }
            .width('90%').justifyContent(FlexAlign.SpaceAround)

            // 血氧历史记录
            Column() {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.oxygen_records_title_758394627184759629384751952847392847392615738294751'))).fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 10 })

              if (this.oxygenRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('🫁').fontSize(48)
                  Text(this.hasDataLoaded ? getContext(this).resourceManager.getStringSync($r('app.string.no_realtime_oxygen_records_184759362847392573829461847392847392615738294847')) : getContext(this).resourceManager.getStringSync($r('app.string.no_oxygen_data_629384751952847847392615738294751629384751952847392615'))).fontSize(18).fontColor('#666666')
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.realtime_records_only_text_847392'))).fontSize(12)
                    .fontColor('#999999').textAlign(TextAlign.Center)
                  if (!this.hasDataLoaded) {
                    Button(getContext(this).resourceManager.getStringSync($r('app.string.refresh_data_button_573829461847392847392615738294751629384751952847392847'))).onClick(() => this.refreshOxygenData())
                      .backgroundColor('#9C27B0').fontColor(Color.White).borderRadius(20).height(40)
                  }
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                List({ space: 8 }) {
                  ForEach(this.oxygenRecords, (record: OxygenRecord) => {
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
                            Text('🫁').fontSize(14)
                            Text(`${record.value}`).fontSize(18)
                              .fontColor(record.value < 95 ? '#EA4335' : '#34A853')
                              .fontWeight(FontWeight.Bold)
                            Text('%').fontSize(12).fontColor('#666666')
                          }
                          .justifyContent(FlexAlign.Center)

                          Text(record.status).fontSize(12)
                            .fontColor(record.value < 95 ? '#EA4335' : '#34A853')
                            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                            .backgroundColor(record.value < 95 ? 'rgba(234,67,53,0.1)' : 'rgba(52,168,83,0.1)')
                            .borderRadius(8)
                        }
                        .alignItems(HorizontalAlign.End)
                      }
                      .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)
                    }
                  })
                }
                .width('100%').height(300).scrollBar(BarState.Auto)
              }
            }
            .width('90%').backgroundColor('#FFFFFF').borderRadius(15).padding(15)

            // 健康建议
            Column() {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.oxygen_health_tips_title_392847'))).fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 10 })

              Column({ space: 12 }) {
                Row({ space: 12 }) {
                  Text('📊').fontSize(18)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.normal_oxygen_range_tip_758394627184759629384751952847392847392615738294751629'))).fontSize(14).fontColor('#333333')
                    .layoutWeight(1).lineHeight(22)
                }
                .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)

                Row({ space: 12 }) {
                  Text('🌬️').fontSize(18)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.breathing_habit_tip_184759362847392573829461847392847392615738294847392615738'))).fontSize(14)
                    .fontColor('#333333').layoutWeight(1).lineHeight(22)
                }
                .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)

                Row({ space: 12 }) {
                  Text('🏃‍♂️').fontSize(18)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.exercise_tip_629384751952847847392615738294751629384751952847392615738294'))).fontSize(14)
                    .fontColor('#333333').layoutWeight(1).lineHeight(22)
                }
                .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)

                Row({ space: 12 }) {
                  Text('👨‍⚕️').fontSize(18)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.consult_doctor_tip_847392'))).fontSize(14)
                    .fontColor('#333333').layoutWeight(1).lineHeight(22)
                }
                .width('100%').padding(16).backgroundColor('#F8F9FA').borderRadius(12)
              }
            }
            .width('90%').backgroundColor('#FFFFFF').borderRadius(15).padding(20)
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }

  @Builder
  statCard(title: string, value: string, color: string) {
    Column() {
      Text(title).fontSize(14).fontColor('#666666')
      Text(value).fontSize(18).fontWeight(FontWeight.Bold).fontColor(color)
    }
    .width('30%').padding(10).backgroundColor('#FFFFFF').borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetY: 3 })
  }
}