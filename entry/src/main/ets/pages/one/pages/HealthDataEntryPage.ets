import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { DeepSeekService } from '../../../services/deepseek/DeepSeekService';
import { LvMarkdownIn, lvText, lvTitle, lvCode, lvLink, LMICallBack } from '@luvi/lv-markdown-in';
import { preferences } from '@kit.ArkData';

// 健康数据附加信息类
class AdditionalHealthInfo {
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

  toString(): string {
    return `AdditionalHealthInfo{category: ${this.category}, dayOfWeek: ${this.dayOfWeek}, goalValue: ${this.goalValue}, distance: ${this.distance}}`;
  }
}

// 健康数据类
class HealthData {
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

  toString(): string {
    return `HealthData{type: ${this.type}, value: ${this.value}${this.unit}, category: ${this.additionalInfo.category}}`;
  }

  getUniqueId(): string {
    return `${this.type}_${this.value}_${this.timestamp}_${this.additionalInfo.category}_${this.additionalInfo.dayOfWeek}`;
  }
}

// 多健康数据响应类
class MultiHealthDataResponse {
  healthDataList: HealthData[] = [];
  userMessage: string = '';

  constructor(healthDataList: HealthData[], userMessage: string) {
    this.healthDataList = healthDataList;
    this.userMessage = userMessage;
  }

  toString(): string {
    return `MultiHealthDataResponse{dataCount: ${this.healthDataList.length}, userMessageLength: ${this.userMessage.length}}`;
  }
}

// 对话项类
class ConversationItem {
  role: string = '';
  content: string = '';

  constructor(role: string, content: string) {
    this.role = role;
    this.content = content;
  }
}

// 消息类
class Message {
  type: string = '';
  content: string = '';
  time: string = '';
  isStreaming: boolean = false;

  constructor(type: string, content: string, time: string, isStreaming?: boolean) {
    this.type = type;
    this.content = content;
    this.time = time;
    this.isStreaming = isStreaming || false;
  }

  toString(): string {
    return `Message{type: "${this.type}", contentLength: ${this.content.length}, isStreaming: ${this.isStreaming}}`;
  }
}

// 单个健康数据类
class SingleHealthData {
  timestamp: string = '';
  type: string = '';
  value: string = '';
  unit: string = '';
  additionalInfo: AdditionalHealthInfo = new AdditionalHealthInfo();

  constructor() {}
}

// 多健康数据包装类
class MultiHealthDataWrapper {
  action: string = '';
  dataList: SingleHealthData[] = [];

  constructor() {}
}

// 保存结果类
class SaveResult {
  success: boolean = false;
  healthData: HealthData = new HealthData('', '', '', '');
  message: string = '';

  constructor(success: boolean, healthData: HealthData, message: string) {
    this.success = success;
    this.healthData = healthData;
    this.message = message;
  }

  toString(): string {
    return `SaveResult{success: ${this.success}, type: ${this.healthData.type}, message: ${this.message}}`;
  }
}

// 流式处理状态类
class StreamProcessingState {
  isResponseComplete: boolean = false;
  isDataParsed: boolean = false;
  isDataSaved: boolean = false;
  lastProcessedLength: number = 0;
  userFriendlyMessage: string = '';
  parsedHealthData: HealthData[] = [];
  completionCallbackExecuted: boolean = false;
  processingRequestId: string = '';

  constructor() {}

  reset(): void {
    this.isResponseComplete = false;
    this.isDataParsed = false;
    this.isDataSaved = false;
    this.lastProcessedLength = 0;
    this.userFriendlyMessage = '';
    this.parsedHealthData = [];
    this.completionCallbackExecuted = false;
    this.processingRequestId = Date.now().toString() + '_' + Math.random().toString(36).substr(2, 9);
  }
}

// 数据冲突检测器类
class DataConflictDetector {
  static detectTodayStepsConflict(healthDataList: HealthData[]): HealthData[] {
    const todayWeekDay = '周日';
    const stepsData = healthDataList.filter((data: HealthData) => data.type === 'steps');

    if (stepsData.length <= 1) {
      return healthDataList;
    }

    let todayStepsData: HealthData | undefined = undefined;
    let lastSundayStepsData: HealthData | undefined = undefined;
    const otherStepsData: HealthData[] = [];

    stepsData.forEach((data: HealthData) => {
      const category = data.additionalInfo.category;
      const dayOfWeek = data.additionalInfo.dayOfWeek;

      if (DataConflictDetector.isTodayStepsCategory(category) && (dayOfWeek === todayWeekDay || dayOfWeek === '')) {
        if (todayStepsData === undefined) {
          todayStepsData = data;
        }
      } else if (category.includes('上周日') || category.includes('上个周日')) {
        lastSundayStepsData = data;
      } else {
        otherStepsData.push(data);
      }
    });

    const resolvedStepsData: HealthData[] = [];

    if (todayStepsData && lastSundayStepsData) {
      resolvedStepsData.push(todayStepsData as HealthData);
    } else {
      if (todayStepsData) {
        resolvedStepsData.push(todayStepsData as HealthData);
      }
      if (lastSundayStepsData) {
        resolvedStepsData.push(lastSundayStepsData as HealthData);
      }
    }

    resolvedStepsData.push(...otherStepsData);

    const nonStepsData = healthDataList.filter((data: HealthData) => data.type !== 'steps');
    const finalDataList = [...resolvedStepsData, ...nonStepsData];

    return finalDataList;
  }

  private static isTodayStepsCategory(category: string): boolean {
    const todayCategories = ['当日步数', '今日步数', '每日步数', '今天步数'];
    return todayCategories.some((cat: string) => category.includes(cat));
  }
}

// 数据库清空结果类
class DatabaseClearResult {
  success: boolean = false;
  recordsCleared: number = 0;
  message: string = '';

  constructor(success: boolean, recordsCleared: number, message: string) {
    this.success = success;
    this.recordsCleared = recordsCleared;
    this.message = message;
  }

  toString(): string {
    return `DatabaseClearResult{success: ${this.success}, recordsCleared: ${this.recordsCleared}}`;
  }
}

@Entry
@Component
export struct HealthDataEntryPage {
  @State messages: Message[] = [];
  @State inputContent: string = '';
  @State isLoading: boolean = false;
  @State updateCounter: number = 0;
  @State isClearingDatabase: boolean = false;

  private conversation: ConversationItem[] = [];
  private cancelStream: (() => void) | null = null;
  private scrollerRef: Scroller = new Scroller();
  private inputController: TextInputController = new TextInputController();
  private preferencesHelper: preferences.Preferences | null = null;
  private globalSavedDataIds: Set<string> = new Set();
  private streamState: StreamProcessingState = new StreamProcessingState();

  aboutToAppear(): void {
    this.initializeSystem();
  }

  private async initializeSystem(): Promise<void> {
    await this.initPreferences();

    const currentTime = new Date().toLocaleString('zh-CN');

    const welcomeMessage = new Message(
      'assistant',
      getContext(this).resourceManager.getStringSync($r('app.string.welcome_message_184759362847392')),
      new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
    );

    this.messages = [welcomeMessage];

    const systemPrompt = this.buildPrecisionSystemPrompt(currentTime);
    const systemConversation = new ConversationItem('system', systemPrompt);
    const assistantConversation = new ConversationItem('assistant', welcomeMessage.content);

    this.conversation = [systemConversation, assistantConversation];

    this.configureUITheme();
  }

  private buildPrecisionSystemPrompt(currentTime: string): string {
    const currentDate = new Date();
    const currentWeekDay = currentDate.getDay();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const todayWeekDay = weekDays[currentWeekDay];

    return `你是精确健康数据录入助手，当前时间：${currentTime}，今天是${todayWeekDay}

【重要】必须保持数值精度，特别是小数点！

【严格格式要求】三段式回复：

第一段：JSON数据块
\`\`\`json
{
  "action": "save_multiple_health_data",
  "dataList": [
    {
      "timestamp": "2025-05-31 04:17:42",
      "type": "distance",
      "value": "5.9",
      "unit": "公里",
      "additionalInfo": {
        "category": "行走距离",
        "dayOfWeek": "${todayWeekDay}",
        "goalValue": "",
        "distance": "",
        "sleepTime": "",
        "wakeTime": "",
        "minValue": "",
        "maxValue": "",
        "avgValue": ""
      }
    }
  ]
}
\`\`\`

第二段：---SPLIT---

第三段：简洁确认
✅ 精确数据已保存！
📏 距离：5.9公里（精确记录）

【数值精度要求】
- 距离：必须保留小数（如5.9公里、6.2公里）
- 步数：整数（如8666步）
- 热量：支持小数（如323千卡、323.5千卡）
- 心率：整数（如72次/分）
- 血氧：整数（如98%）

【数据类型】
- steps: 步数（步）
- distance: 距离（公里）- 关键：保留小数
- calories: 热量（千卡）
- heart_rate: 心率（次/分）
- blood_oxygen: 血氧（%）

【周几识别规则】
- 今天：${todayWeekDay}
- 支持：周一到周日、上个周六等

【关键】value字段必须保持原始精度，绝不截断小数！`;
  }

  private configureUITheme(): void {
    lvText.setTextSize(16);
    lvText.setTextLineHeight("24");
    lvTitle.setLevelTitleColor("#4CAF50");
    lvCode.setTheme("light");
    lvCode.setIndexState(true);
    lvLink.setTextColor("#4CAF50");
  }

  private async initPreferences(): Promise<void> {
    try {
      this.preferencesHelper = await preferences.getPreferences(getContext(), 'health_data');
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
    }
  }

  private async clearHealthDatabase(): Promise<DatabaseClearResult> {
    try {
      if (!this.preferencesHelper) {
        const errorMsg = getContext(this).resourceManager.getStringSync($r('app.string.storage_not_initialized_184759362847392'));
        return new DatabaseClearResult(false, 0, errorMsg);
      }

      const existingData = await this.preferencesHelper.get('health_records', '[]') as string;
      const healthRecords: HealthData[] = JSON.parse(existingData);
      const recordCount = healthRecords.length;

      if (recordCount === 0) {
        const emptyMsg = getContext(this).resourceManager.getStringSync($r('app.string.database_already_empty_392847516293847'));
        return new DatabaseClearResult(true, 0, emptyMsg);
      }

      await this.preferencesHelper.put('health_records', '[]');
      await this.preferencesHelper.flush();
      this.globalSavedDataIds.clear();

      const successTemplate = getContext(this).resourceManager.getStringSync($r('app.string.clear_success_template_758394627184759'));
      const successMessage = successTemplate.replace('{0}', recordCount.toString());
      return new DatabaseClearResult(true, recordCount, successMessage);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      const failTemplate = getContext(this).resourceManager.getStringSync($r('app.string.clear_failed_template_184759362847392'));
      return new DatabaseClearResult(false, 0, failTemplate.replace('{0}', errorMessage));
    }
  }

  private showClearDatabaseConfirm(): void {
    AlertDialog.show({
      title: getContext(this).resourceManager.getStringSync($r('app.string.confirm_dangerous_operation_847392615738294')),
      message: getContext(this).resourceManager.getStringSync($r('app.string.clear_database_warning_573829461847392')),
      primaryButton: {
        value: getContext(this).resourceManager.getStringSync($r('app.string.confirm_clear_button_392847516293847')),
        fontColor: '#FF5722',
        action: async () => {
          await this.executeClearDatabase();
        }
      },
      secondaryButton: {
        value: getContext(this).resourceManager.getStringSync($r('app.string.cancel_button_758394627184759')),
        fontColor: '#4CAF50',
        action: () => {
        }
      }
    });
  }

  private async executeClearDatabase(): Promise<void> {
    this.isClearingDatabase = true;

    try {
      const clearResult = await this.clearHealthDatabase();

      const currentTime = new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });

      const resultMessage = new Message(
        'assistant',
        clearResult.success
          ? getContext(this).resourceManager.getStringSync($r('app.string.clear_complete_629384751952847')).replace('{0}', clearResult.message)
          : getContext(this).resourceManager.getStringSync($r('app.string.clear_failed_847392615738294')).replace('{0}', clearResult.message),
        currentTime
      );
      this.messages.push(resultMessage);

      this.updateCounter++;
      this.messages = [...this.messages];
      this.scrollToBottom();
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';

      const exceptionMessage = new Message(
        'assistant',
        getContext(this).resourceManager.getStringSync($r('app.string.system_exception_573829461847392')).replace('{0}', errorMessage),
        new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
      );
      this.messages.push(exceptionMessage);
      this.updateCounter++;
      this.messages = [...this.messages];
    } finally {
      this.isClearingDatabase = false;
    }
  }

  private async saveHealthDataSingle(healthData: HealthData, sessionId: string): Promise<SaveResult> {
    try {
      if (!this.preferencesHelper) {
        const errorMsg = getContext(this).resourceManager.getStringSync($r('app.string.storage_not_initialized_184759362847392'));
        return new SaveResult(false, healthData, errorMsg);
      }

      if (!healthData.type || !healthData.value || !healthData.timestamp) {
        const errorMsg = getContext(this).resourceManager.getStringSync($r('app.string.incomplete_data_629384751952847'));
        return new SaveResult(false, healthData, errorMsg);
      }

      const dataId = healthData.getUniqueId();
      if (this.globalSavedDataIds.has(dataId)) {
        const errorMsg = getContext(this).resourceManager.getStringSync($r('app.string.duplicate_data_847392615738294'));
        return new SaveResult(false, healthData, errorMsg);
      }

      const existingData = await this.preferencesHelper.get('health_records', '[]') as string;
      const healthRecords: HealthData[] = JSON.parse(existingData);

      healthRecords.push(healthData);
      this.globalSavedDataIds.add(dataId);

      await this.preferencesHelper.put('health_records', JSON.stringify(healthRecords));
      await this.preferencesHelper.flush();

      const typeDescMap: Record<string, string> = {
        'steps': getContext(this).resourceManager.getStringSync($r('app.string.steps_data_type_184759362847392')),
        'distance': getContext(this).resourceManager.getStringSync($r('app.string.distance_data_type_629384751952847')),
        'calories': getContext(this).resourceManager.getStringSync($r('app.string.calories_data_type_847392615738294')),
        'blood_oxygen': getContext(this).resourceManager.getStringSync($r('app.string.blood_oxygen_data_type_573829461847392')),
        'heart_rate': getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_data_type_392847516293847'))
      };
      const typeDesc = typeDescMap[healthData.type] || healthData.type;

      const successTemplate = getContext(this).resourceManager.getStringSync($r('app.string.save_success_template_758394627184759'));
      const successMsg = successTemplate.replace('{0}', typeDesc).replace('{1}', healthData.value).replace('{2}', healthData.unit);

      return new SaveResult(true, healthData, successMsg);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      const exceptionTemplate = getContext(this).resourceManager.getStringSync($r('app.string.save_exception_template_573829461847392'));
      return new SaveResult(false, healthData, exceptionTemplate.replace('{0}', errorMessage));
    }
  }

  private async batchSaveHealthData(healthDataList: HealthData[]): Promise<SaveResult[]> {
    const sessionId = `batch_${Date.now()}`;

    const resolvedDataList = DataConflictDetector.detectTodayStepsConflict(healthDataList);

    const saveResults: SaveResult[] = [];

    for (let i = 0; i < resolvedDataList.length; i++) {
      const healthData = resolvedDataList[i];

      const saveResult = await this.saveHealthDataSingle(healthData, sessionId);
      saveResults.push(saveResult);

      if (i < resolvedDataList.length - 1) {
        await new Promise<void>((resolve) => {
          setTimeout(() => { resolve(); }, 50);
        });
      }
    }

    return saveResults;
  }

  private parseMultiHealthDataResponseEnhanced(aiResponse: string): MultiHealthDataResponse {
    try {
      let jsonPart = '';
      let userPart = '';

      if (aiResponse.includes('---SPLIT---')) {
        const parts = aiResponse.split('---SPLIT---');
        jsonPart = parts[0].trim();
        userPart = parts[1] ? parts[1].trim() : '';
      } else {
        jsonPart = aiResponse;
        userPart = aiResponse;
      }

      const healthDataList: HealthData[] = [];

      if (jsonPart.length > 0) {
        const jsonCodeBlockPattern = /```json\s*([\s\S]*?)\s*```/;
        const jsonMatch = jsonPart.match(jsonCodeBlockPattern);

        if (jsonMatch) {
          const jsonStr = jsonMatch[1].trim();

          try {
            const parsedData = JSON.parse(jsonStr) as MultiHealthDataWrapper;

            if (parsedData.dataList && parsedData.dataList.length > 0) {
              for (let i = 0; i < parsedData.dataList.length; i++) {
                const dataItem = parsedData.dataList[i];

                if (!dataItem.type || !dataItem.value || !dataItem.timestamp) {
                  continue;
                }

                const additionalInfo = new AdditionalHealthInfo();
                if (dataItem.additionalInfo) {
                  additionalInfo.sleepTime = dataItem.additionalInfo.sleepTime || '';
                  additionalInfo.wakeTime = dataItem.additionalInfo.wakeTime || '';
                  additionalInfo.minValue = dataItem.additionalInfo.minValue || '';
                  additionalInfo.maxValue = dataItem.additionalInfo.maxValue || '';
                  additionalInfo.avgValue = dataItem.additionalInfo.avgValue || '';
                  additionalInfo.category = dataItem.additionalInfo.category || '实时';
                  additionalInfo.dayOfWeek = dataItem.additionalInfo.dayOfWeek || '';
                  additionalInfo.goalValue = dataItem.additionalInfo.goalValue || '';
                  additionalInfo.distance = dataItem.additionalInfo.distance || '';
                }

                const healthData = new HealthData(
                  dataItem.timestamp,
                  dataItem.type,
                  dataItem.value,
                  dataItem.unit || '',
                  additionalInfo
                );

                healthDataList.push(healthData);
              }
            }
          } catch (parseError) {
          }
        }
      }

      return new MultiHealthDataResponse(healthDataList, userPart || aiResponse);

    } catch (error) {
      return new MultiHealthDataResponse([], aiResponse);
    }
  }

  private scrollToBottom(): void {
    setTimeout(() => {
      try {
        this.scrollerRef.scrollEdge(Edge.Bottom);
      } catch (err) {
      }
    }, 100);
  }

  private sendToAI(userMessage: string): void {
    try {
      this.streamState.reset();

      const currentTime = new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
      const userMsg = new Message('user', userMessage, currentTime);
      this.messages.push(userMsg);
      this.scrollToBottom();

      const fullCurrentTime = new Date().toLocaleString('zh-CN');
      const contextualMessage = `当前时间：${fullCurrentTime}\n精确健康数据（保持小数精度）：${userMessage}`;

      const newConversation = new ConversationItem('user', contextualMessage);
      this.conversation.push(newConversation);

      const aiMessageIndex = this.messages.length;
      const aiMsg = new Message(
        'assistant',
        getContext(this).resourceManager.getStringSync($r('app.string.analyzing_health_data_758394627184759')),
        new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }),
        true
      );
      this.messages.push(aiMsg);
      this.scrollToBottom();

      let fullAIResponse = '';

      this.cancelStream = DeepSeekService.streamRequest(
        contextualMessage,
        this.conversation,

        (chunk: string) => {
          fullAIResponse = chunk;
        },

        async () => {
          if (this.streamState.completionCallbackExecuted) {
            return;
          }

          this.streamState.completionCallbackExecuted = true;
          this.isLoading = false;

          if (this.messages[aiMessageIndex]) {
            this.messages[aiMessageIndex].isStreaming = false;
          }

          const finalParseResult = this.parseMultiHealthDataResponseEnhanced(fullAIResponse);
          const healthDataList = finalParseResult.healthDataList;
          const finalUserMessage = finalParseResult.userMessage;

          this.messages[aiMessageIndex].content = finalUserMessage || getContext(this).resourceManager.getStringSync($r('app.string.processing_complete_392847516293847'));

          if (healthDataList.length > 0) {
            const saveResults = await this.batchSaveHealthData(healthDataList);
          }

          const assistantConversation = new ConversationItem('assistant', fullAIResponse);
          this.conversation.push(assistantConversation);

          this.updateCounter++;
          this.messages = [...this.messages];
          this.cancelStream = null;
          this.scrollToBottom();
        },

        (error: Error) => {
          this.isLoading = false;
          if (this.messages[aiMessageIndex]) {
            const errorTemplate = getContext(this).resourceManager.getStringSync($r('app.string.analysis_failed_758394627184759'));
            this.messages[aiMessageIndex].content = errorTemplate.replace('{0}', error.message);
            this.messages[aiMessageIndex].isStreaming = false;
          }

          this.updateCounter++;
          this.messages = [...this.messages];
          this.cancelStream = null;
          this.scrollToBottom();
          this.streamState.reset();
        }
      );
    } catch (err) {
      this.isLoading = false;
      this.streamState.reset();
      this.scrollToBottom();
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back')).width(24).height(24)
        }
        .onClick(() => {
          try {
            router.back();
          } catch (err) {
          }
        })
        .width(44).height(44).backgroundColor(Color.Transparent).margin({ left: 12 })

        Text(getContext(this).resourceManager.getStringSync($r('app.string.health_data_entry_title_84739261573829'))).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          if (this.isClearingDatabase) {
            LoadingProgress().width(20).height(20).color('#FF5722')
          } else {
            Text('🗑️').fontSize(18)
          }
        }
        .onClick(() => {
          if (!this.isClearingDatabase) {
            this.showClearDatabaseConfirm();
          }
        })
        .enabled(!this.isClearingDatabase && !this.isLoading)
        .width(44).height(44).backgroundColor(Color.Transparent).margin({ right: 12 })
        .opacity(this.isClearingDatabase ? 0.6 : 1.0)
      }
      .width('100%').height(64).justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFF').shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

      Scroll(this.scrollerRef) {
        Column() {
          ForEach(this.messages, (msg: Message, index: number) => {
            Row() {
              if (msg.type === 'assistant') {
                Image($r('app.media.ic_service'))
                  .width(36).height(36).borderRadius(18)
                  .backgroundColor('#E8F5E8').padding(6)

                Column() {
                  Text(msg.time).fontSize(12).fontColor('#999').margin({ bottom: 4 })

                  LvMarkdownIn({
                    text: msg.content || getContext(this).resourceManager.getStringSync($r('app.string.analyzing_health_data_758394627184759')),
                    loadMode: "text",
                    loadCallBack: {
                      success: (r: LMICallBack) => {
                        setTimeout(() => { this.scrollToBottom(); }, 50);
                      },
                      fail: (r: LMICallBack) => {
                      }
                    }
                  })
                    .backgroundColor('#fff').borderRadius(16).padding(16)
                    .shadow({ radius: 3, color: '#E8F5E8', offsetY: 2 }).width('100%')

                  if (msg.isStreaming) {
                    Row() {
                      Text(getContext(this).resourceManager.getStringSync($r('app.string.analysis_in_progress_629384751952847'))).fontSize(12).fontColor('#4CAF50').margin({ right: 8 })
                      ForEach([1, 2, 3], (i: number) => {
                        Text('●').fontSize(14).fontColor('#4CAF50').opacity(0.3 + (i * 0.3))
                      })
                    }.width('100%').margin({ top: 8 })
                  }
                }.margin({ left: 10 }).width('82%')

                Blank()
              } else {
                Blank()

                Column() {
                  Text(msg.time).fontSize(12).fontColor('#999').margin({ bottom: 4 })
                  Text(msg.content).fontSize(16).fontColor('#fff').backgroundColor('#4CAF50')
                    .borderRadius(16).padding(16).lineHeight(24)
                }.margin({ right: 10 }).width('82%')

                Image($r('app.media.ic_user'))
                  .width(36).height(36).borderRadius(18)
                  .backgroundColor('#C8E6C9').padding(6)
              }
            }
            .width('100%').justifyContent(msg.type === 'user' ? FlexAlign.End : FlexAlign.Start)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          })
        }.width('100%').padding({ top: 12, bottom: 12 })
      }
      .layoutWeight(1).backgroundColor('#F8FFF8').scrollBar(BarState.Auto)

      if (this.isLoading) {
        Row() {
          LoadingProgress().width(28).height(28).color('#4CAF50')
          Text(getContext(this).resourceManager.getStringSync($r('app.string.analyzing_health_data_758394627184759'))).fontSize(14).fontColor('#4CAF50').margin({ left: 12 })
        }
        .justifyContent(FlexAlign.Center).width('100%').padding(12)
        .backgroundColor('#F0F8F0').borderRadius(8).margin({ left: 16, right: 16, bottom: 8 })
      }

      if (this.isClearingDatabase) {
        Row() {
          LoadingProgress().width(28).height(28).color('#FF5722')
          Text(getContext(this).resourceManager.getStringSync($r('app.string.clearing_database_184759362847392'))).fontSize(14).fontColor('#FF5722').margin({ left: 12 })
        }
        .justifyContent(FlexAlign.Center).width('100%').padding(12)
        .backgroundColor('#FFF3E0').borderRadius(8).margin({ left: 16, right: 16, bottom: 8 })
      }

      Row() {
        TextInput({
          placeholder: getContext(this).resourceManager.getStringSync($r('app.string.input_placeholder_392847516293847')),
          text: this.inputContent,
          controller: this.inputController
        })
          .backgroundColor('#fff').borderRadius(24).border({ width: 1, color: '#4CAF50' })
          .padding({ left: 16, right: 16, top: 12, bottom: 12 }).fontSize(16).layoutWeight(1)
          .onChange((v: string) => {
            this.inputContent = v;
          })
          .enabled(!this.isLoading && !this.isClearingDatabase)
          .onSubmit(() => {
            if (this.inputContent && !this.isLoading && !this.isClearingDatabase) {
              const userMessage = this.inputContent;
              this.inputContent = '';
              this.isLoading = true;
              this.sendToAI(userMessage);
            }
          })

        Button({ type: ButtonType.Circle }) {
          Image(this.cancelStream ? $r('app.media.ic_stop') : $r('app.media.ic_send'))
            .width(24).height(24).fillColor(Color.White)
        }
        .onClick(() => {
          if (this.cancelStream) {
            this.cancelStream();
            this.cancelStream = null;
            this.isLoading = false;
            this.streamState.reset();
          } else {
            if (!this.inputContent || this.isLoading || this.isClearingDatabase) return;

            const userMessage = this.inputContent;
            this.inputContent = '';
            this.isLoading = true;
            this.sendToAI(userMessage);
          }
        })
        .enabled(!this.isClearingDatabase)
        .backgroundColor(this.cancelStream ? '#FF5252' : '#4CAF50').borderRadius(24)
        .width(50).height(50).margin({ left: 12 })
      }
      .padding(16).backgroundColor('#F8FFF8').border({ width: { top: 1 }, color: '#E8F5E8' })
    }
    .backgroundColor('#F8FFF8').height('100%')
  }
}