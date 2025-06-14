import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { DeepSeekService } from '../../../services/deepseek/DeepSeekService';
import { LvMarkdownIn, lvText, lvTitle, lvCode, lvLink, LMICallBack } from '@luvi/lv-markdown-in';
import { userApiService, HealthDataRequest, RegisterResponse, RealtimeDataRequest } from '../../../services/api_network/UserApiService';

// 健康数据解析结果类
class HealthDataParseResult {
  // 健康数据表字段
  steps: number = 0;
  steps_goal: number = 0;
  distance: number = 0;
  calories_burned: number = 0;
  current_heart_rate: number = 0;
  resting_heart_rate: number = 0;
  min_heart_rate: number = 0;
  avg_heart_rate: number = 0;
  max_heart_rate: number = 0;
  current_blood_oxygen: number = 0;
  min_blood_oxygen: number = 0;
  avg_blood_oxygen: number = 0;
  max_blood_oxygen: number = 0;
  sleep_score: number = 0;
  sleep_duration: number = 0;
  sleep_start_time: string = '';
  sleep_end_time: string = '';
  deep_sleep_duration: number = 0;
  light_sleep_duration: number = 0;
  rem_sleep_duration: number = 0;
  awake_duration: number = 0;
  active_calories: number = 0;
  calories_goal: number = 0;
  basic_metabolism_calories: number = 0;
  current_mood: number = -1;

  // 实时数据相关
  realtime_entries: RealtimeEntry[] = [];
  userMessage: string = '';

  constructor() {}

  toString(): string {
    return `HealthDataParseResult{steps: ${this.steps}, heart_rate: ${this.current_heart_rate}, 实时数据条数: ${this.realtime_entries.length}}`;
  }
}

// 实时数据条目类
class RealtimeEntry {
  time_stamp: string = '';
  data_type: string = '';
  value: number = 0;

  constructor(time_stamp: string, data_type: string, value: number) {
    this.time_stamp = time_stamp;
    this.data_type = data_type;
    this.value = value;
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

// 流式处理状态类
class StreamProcessingState {
  isResponseComplete: boolean = false;
  isDataParsed: boolean = false;
  isDataSaved: boolean = false;
  lastProcessedLength: number = 0;
  userFriendlyMessage: string = '';
  completionCallbackExecuted: boolean = false;
  processingRequestId: string = '';

  constructor() {}

  reset(): void {
    this.isResponseComplete = false;
    this.isDataParsed = false;
    this.isDataSaved = false;
    this.lastProcessedLength = 0;
    this.userFriendlyMessage = '';
    this.completionCallbackExecuted = false;
    this.processingRequestId = Date.now().toString() + '_' + Math.random().toString(36).substr(2, 9);
  }
}

// AI保存结果类
class AISaveResult {
  success: boolean = false;
  message: string = '';

  constructor(success: boolean, message: string) {
    this.success = success;
    this.message = message;
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
  private streamState: StreamProcessingState = new StreamProcessingState();
  private currentUserId: number = 1;

  aboutToAppear(): void {
    this.loadCurrentUser();
    this.initializeSystem();
  }

  private loadCurrentUser(): void {
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        interface UserInfoFromStorage {
          userId: string;
          userName: string;
          phone: string;
          loginTime: string;
        }
        const userInfo: UserInfoFromStorage = JSON.parse(userInfoStr) as UserInfoFromStorage;
        this.currentUserId = parseInt(userInfo.userId);
        console.info(`[AI健康录入] 当前用户ID: ${this.currentUserId}`);
      }
    } catch (error) {
      console.error(`[AI健康录入] 获取用户信息失败:`, error);
    }
  }

  private async initializeSystem(): Promise<void> {
    const currentTime = new Date().toLocaleString('zh-CN');

    const welcomeMessage = new Message(
      'assistant',
      '您好！我是全面健康数据录入助手，支持记录步数、心率、血氧、睡眠、热量、心情等所有健康指标，请告诉我您的健康数据。',
      new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
    );

    this.messages = [welcomeMessage];

    const systemPrompt = this.buildComprehensiveSystemPrompt(currentTime);
    const systemConversation = new ConversationItem('system', systemPrompt);
    const assistantConversation = new ConversationItem('assistant', welcomeMessage.content);

    this.conversation = [systemConversation, assistantConversation];

    this.configureUITheme();
  }

  private buildComprehensiveSystemPrompt(currentTime: string): string {
    const currentDate = new Date();
    const currentWeekDay = currentDate.getDay();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const todayWeekDay = weekDays[currentWeekDay];
    console.log(`${currentTime},${todayWeekDay}`)
    return `你是全面健康数据录入助手，当前时间：${currentTime}，今天是${todayWeekDay}

【重要】对于用户没有明确提到的数据, 请留空, 不要擅自填入数据
例如用户只填写了实时数据, 只提到了步数是4000, 那么在健康数据录入块只有步数有值, 其余空着
实时数据和健康数据没有关联! 录入实时数据并不会暗示健康数据, 所以不要通过实时数据编造健康数据

【严格格式要求】三段式回复：

第一段：数据录入块
=== 数据录入 ===
步数:8000
步数目标:10000
距离:5.2
总热量:850
当前心率:72
静息心率:65
最低心率:60
平均心率:70
最高心率:85
当前血氧:98
最低血氧:95
平均血氧:97
最高血氧:99
睡眠评分:85
睡眠时长:480
入睡时间:23:30
起床时间:07:30
深睡时长:180
浅睡时长:240
REM睡眠:60
清醒时长:30
活动热量:300
热量目标:2000
基础代谢:1550
当前心情:7

第二段：分隔符
=== 用户反馈 ===

第三段：确认信息
✅ 全面健康数据已精确保存！
🚶 步数：8000步（目标：10000步）
📏 距离：5.2公里
❤️ 心率：当前72，静息65，范围60-85次/分
🫁 血氧：当前98%，范围95-99%
😴 睡眠：评分85分，时长8小时，深睡3小时
🔥 热量：总消耗850千卡（活动300+基础代谢1550）
😊 心情：7分（满意状态）

【全部支持的数据类型】
基础指标：
- 步数/步数目标 → steps/steps_goal（步）
- 距离 → distance（公里）
- 总热量 → calories_burned（千卡）

心率数据：
- 当前心率 → current_heart_rate（次/分）
- 静息心率 → resting_heart_rate（次/分）
- 最低心率 → min_heart_rate（次/分）
- 平均心率 → avg_heart_rate（次/分）
- 最高心率 → max_heart_rate（次/分）

血氧数据：
- 当前血氧 → current_blood_oxygen（%）
- 最低血氧 → min_blood_oxygen（%）
- 平均血氧 → avg_blood_oxygen（%）
- 最高血氧 → max_blood_oxygen（%）

睡眠数据：
- 睡眠评分 → sleep_score（0-100分）
- 睡眠时长 → sleep_duration（分钟）
- 入睡时间 → sleep_start_time（HH:MM）
- 起床时间 → sleep_end_time（HH:MM）
- 深睡时长 → deep_sleep_duration（分钟）
- 浅睡时长 → light_sleep_duration（分钟）
- REM睡眠 → rem_sleep_duration（分钟）
- 清醒时长 → awake_duration（分钟）

热量数据：
- 活动热量 → active_calories（千卡）
- 热量目标 → calories_goal（千卡）
- 基础代谢 → basic_metabolism_calories（千卡）

心情数据：
- 当前心情 → current_mood（1-10分，-1表示未设置）

【数值精度要求】
- 距离：保留1位小数（如5.2）
- 时间：使用HH:MM格式（如23:30）
- 其他数值：整数或保持用户输入精度

【关键】所有数值必须保持原始精度，准确识别并分类所有健康数据类型！

【实时数据格式】
当用户提供带时间的具体数据时，额外输出实时数据块：
=== 实时数据 ===
时间|类型|数值
2025-06-14 18:00|heart_rate|88
2025-06-14 20:00|heart_rate|76
2025-06-13 16:00|blood_oxygen|96
2025-06-14 22:00|mood|3
2025-06-14 08:00|mood|7

【时间戳格式要求】
- 必须使用完整日期时间格式：YYYY-MM-DD HH:MM
- 根据用户输入判断具体日期（今天、昨天等）
- 默认为当前日期

【实时数据类型】
- heart_rate（心率）
- blood_oxygen（血氧）
- mood（心情，1-10分数值）

【心情数值对照】
焦虑>=0分，疲惫>=2分，平静>=4分，满足>=6分，开心>=8分，默认=-1分
心情必须直接输出数值，不要输出文字！

[注意]
区分好实时数据和健康数据, 带有时间戳的(心率, 血氧, 心情)是实时数据, 其他的均为健康数据!
`;
  }

  private configureUITheme(): void {
    lvText.setTextSize(16);
    lvText.setTextLineHeight("24");
    lvTitle.setLevelTitleColor("#4CAF50");
    lvCode.setTheme("light");
    lvCode.setIndexState(true);
    lvLink.setTextColor("#4CAF50");
  }

  private parseHealthDataFromAI(aiResponse: string): HealthDataParseResult {
    console.info('[全面健康数据解析] 开始解析AI回复');

    const result = new HealthDataParseResult();

    try {
      let dataPart = '';
      let userPart = '';

      if (aiResponse.includes('=== 数据录入 ===') && aiResponse.includes('=== 用户反馈 ===')) {
        const parts = aiResponse.split('=== 用户反馈 ===');
        dataPart = parts[0].replace('=== 数据录入 ===', '').trim();
        userPart = parts[1] ? parts[1].trim() : '';
      } else {
        dataPart = aiResponse;
        userPart = aiResponse;
      }

      console.info(`[全面健康数据解析] 数据部分: ${dataPart}`);

      // 定义所有数据类型的匹配模式
      const patterns: Record<string, RegExp> = {
        // 基础指标
        'steps': /步数[:：]\s*(\d+)/,
        'steps_goal': /步数目标[:：]\s*(\d+)/,
        'distance': /距离[:：]\s*([\d.]+)/,
        'calories_burned': /总热量[:：]\s*([\d.]+)/,

        // 心率数据
        'current_heart_rate': /当前心率[:：]\s*(\d+)/,
        'resting_heart_rate': /静息心率[:：]\s*(\d+)/,
        'min_heart_rate': /最低心率[:：]\s*(\d+)/,
        'avg_heart_rate': /平均心率[:：]\s*(\d+)/,
        'max_heart_rate': /最高心率[:：]\s*(\d+)/,

        // 血氧数据
        'current_blood_oxygen': /当前血氧[:：]\s*(\d+)/,
        'min_blood_oxygen': /最低血氧[:：]\s*(\d+)/,
        'avg_blood_oxygen': /平均血氧[:：]\s*(\d+)/,
        'max_blood_oxygen': /最高血氧[:：]\s*(\d+)/,

        // 睡眠数据
        'sleep_score': /睡眠评分[:：]\s*(\d+)/,
        'sleep_duration': /睡眠时长[:：]\s*(\d+)/,
        'sleep_start_time': /入睡时间[:：]\s*(\d{1,2}:\d{2})/,
        'sleep_end_time': /起床时间[:：]\s*(\d{1,2}:\d{2})/,
        'deep_sleep_duration': /深睡时长[:：]\s*(\d+)/,
        'light_sleep_duration': /浅睡时长[:：]\s*(\d+)/,
        'rem_sleep_duration': /REM睡眠[:：]\s*(\d+)/,
        'awake_duration': /清醒时长[:：]\s*(\d+)/,

        // 热量数据
        'active_calories': /活动热量[:：]\s*([\d.]+)/,
        'calories_goal': /热量目标[:：]\s*([\d.]+)/,
        'basic_metabolism_calories': /基础代谢[:：]\s*([\d.]+)/,

        // 心情数据
        'current_mood': /当前心情[:：]\s*(\d+)/
      };

      // 解析所有匹配的数据
      Object.keys(patterns).forEach((key: string) => {
        const match = dataPart.match(patterns[key]);
        if (match) {
          const valueStr = match[1];

          if (key === 'sleep_start_time' || key === 'sleep_end_time') {
            // 时间字段直接赋值字符串
            if (key === 'sleep_start_time') {
              result.sleep_start_time = valueStr;
            } else if (key === 'sleep_end_time') {
              result.sleep_end_time = valueStr;
            }
            console.info(`[全面健康数据解析] 提取${key}: ${valueStr}`);
          } else {
            // 数值字段转换为数字
            const value = parseFloat(valueStr);
            if (!isNaN(value)) {
              switch (key) {
                case 'steps': result.steps = Math.floor(value); break;
                case 'steps_goal': result.steps_goal = Math.floor(value); break;
                case 'distance': result.distance = value; break;
                case 'calories_burned': result.calories_burned = value; break;
                case 'current_heart_rate': result.current_heart_rate = Math.floor(value); break;
                case 'resting_heart_rate': result.resting_heart_rate = Math.floor(value); break;
                case 'min_heart_rate': result.min_heart_rate = Math.floor(value); break;
                case 'avg_heart_rate': result.avg_heart_rate = Math.floor(value); break;
                case 'max_heart_rate': result.max_heart_rate = Math.floor(value); break;
                case 'current_blood_oxygen': result.current_blood_oxygen = Math.floor(value); break;
                case 'min_blood_oxygen': result.min_blood_oxygen = Math.floor(value); break;
                case 'avg_blood_oxygen': result.avg_blood_oxygen = Math.floor(value); break;
                case 'max_blood_oxygen': result.max_blood_oxygen = Math.floor(value); break;
                case 'sleep_score': result.sleep_score = Math.floor(value); break;
                case 'sleep_duration': result.sleep_duration = Math.floor(value); break;
                case 'deep_sleep_duration': result.deep_sleep_duration = Math.floor(value); break;
                case 'light_sleep_duration': result.light_sleep_duration = Math.floor(value); break;
                case 'rem_sleep_duration': result.rem_sleep_duration = Math.floor(value); break;
                case 'awake_duration': result.awake_duration = Math.floor(value); break;
                case 'active_calories': result.active_calories = value; break;
                case 'calories_goal': result.calories_goal = value; break;
                case 'basic_metabolism_calories': result.basic_metabolism_calories = value; break;
                case 'current_mood': result.current_mood = Math.floor(value); break;
              }
              console.info(`[全面健康数据解析] 提取${key}: ${value}`);
            }
          }
        }
      });

      // 解析实时数据
      if (aiResponse.includes('=== 实时数据 ===')) {
        const realtimeMatch = aiResponse.match(/=== 实时数据 ===([\s\S]*?)(?===|$)/);
        if (realtimeMatch) {
          const realtimeSection = realtimeMatch[1].trim();
          console.info(`[实时数据解析] 实时数据部分: ${realtimeSection}`);
          const lines = realtimeSection.split('\n');
          for (const line of lines) {
            const trimmedLine = line.trim();
            if (trimmedLine.includes('|') && !trimmedLine.includes('时间|类型|数值')) {
              const parts = trimmedLine.split('|');
              if (parts.length === 3) {
                const timeStamp = parts[0].trim();
                const dataType = parts[1].trim();
                const valueStr = parts[2].trim();

                let value: number;
                if (dataType === 'mood') {
                  // 心情数据处理：优先解析数值，如果是文字则转换
                  const numValue = parseFloat(valueStr);
                  if (!isNaN(numValue)) {
                    value = numValue;
                  } else {
                    switch (valueStr) {
                      case '焦虑': value = 0; break;
                      case '疲惫': value = 2; break;
                      case '平静': value = 4; break;
                      case '满足': value = 6; break;
                      case '开心': value = 8; break;
                      default: value = -1; break;
                    }
                  }
                } else {
                  value = parseFloat(valueStr);
                }

                if (!isNaN(value) && timeStamp.includes(':')) {
                  result.realtime_entries.push(new RealtimeEntry(timeStamp, dataType, value));
                  console.info(`[实时数据解析] 提取实时数据: ${timeStamp} ${dataType} ${value}`);
                }
              }
            }
          }
        }
      }

      result.userMessage = userPart || '全面健康数据录入完成';

      console.info(`[全面健康数据解析] 解析结果: ${result.toString()}`);
      return result;

    } catch (error) {
      console.error('[全面健康数据解析] 解析异常:', error);
      result.userMessage = aiResponse;
      return result;
    }
  }

  private async saveHealthDataToBackend(parseResult: HealthDataParseResult): Promise<AISaveResult> {
    try {
      console.info('[后端保存] 开始保存全面健康数据到后端');
      console.info(`心情数字: ${parseResult.current_mood}`)
      const todayDate = new Date();
      const currentDate: string = `${todayDate.getFullYear()}-${String(todayDate.getMonth() + 1).padStart(2, '0')}-${String(todayDate.getDate()).padStart(2, '0')}`;

      // 构建健康数据请求
      const healthDataRequest: HealthDataRequest = {
        user_id: this.currentUserId,
        record_date: currentDate,
        steps: parseResult.steps || undefined,
        steps_goal: parseResult.steps_goal || undefined,
        distance: parseResult.distance || undefined,
        calories_burned: parseResult.calories_burned || undefined,
        current_heart_rate: parseResult.current_heart_rate || undefined,
        resting_heart_rate: parseResult.resting_heart_rate || undefined,
        min_heart_rate: parseResult.min_heart_rate || undefined,
        avg_heart_rate: parseResult.avg_heart_rate || undefined,
        max_heart_rate: parseResult.max_heart_rate || undefined,
        current_blood_oxygen: parseResult.current_blood_oxygen || undefined,
        min_blood_oxygen: parseResult.min_blood_oxygen || undefined,
        avg_blood_oxygen: parseResult.avg_blood_oxygen || undefined,
        max_blood_oxygen: parseResult.max_blood_oxygen || undefined,
        sleep_score: parseResult.sleep_score || undefined,
        sleep_duration: parseResult.sleep_duration || undefined,
        sleep_start_time: parseResult.sleep_start_time || undefined,
        sleep_end_time: parseResult.sleep_end_time || undefined,
        deep_sleep_duration: parseResult.deep_sleep_duration || undefined,
        light_sleep_duration: parseResult.light_sleep_duration || undefined,
        rem_sleep_duration: parseResult.rem_sleep_duration || undefined,
        awake_duration: parseResult.awake_duration || undefined,
        active_calories: parseResult.active_calories || undefined,
        calories_goal: parseResult.calories_goal || undefined,
        basic_metabolism_calories: parseResult.basic_metabolism_calories || undefined,
        current_mood: parseResult.current_mood !== -1 ? parseResult.current_mood : -1
      };

      let healthResponse: RegisterResponse = { success: true, message: '跳过健康数据保存' };

      // 判断是否为纯实时数据录入
      const isPureRealtimeData = parseResult.realtime_entries.length > 0 &&
        parseResult.steps === 0 && parseResult.current_heart_rate === 0 &&
        parseResult.current_blood_oxygen === 0 && parseResult.current_mood === -1;

      if (!isPureRealtimeData) {
        // 只有非纯实时数据时才保存健康数据
        healthResponse = await userApiService.saveHealthData(healthDataRequest);
      }

      // 如果有实时数据，保存实时数据
      if (parseResult.realtime_entries.length > 0) {
        console.info(`[后端保存] 保存${parseResult.realtime_entries.length}条实时数据`);

        for (const entry of parseResult.realtime_entries) {
          const realtimeRequest: RealtimeDataRequest = {
            user_id: this.currentUserId,
            record_date: currentDate,
            time_stamp: entry.time_stamp,
            data_type: entry.data_type,
            value: entry.value
          };

          await userApiService.saveRealtimeData(realtimeRequest);
        }
      }

      console.info(`[后端保存] 健康数据保存结果: ${healthResponse.success}`);
      return new AISaveResult(healthResponse.success, healthResponse.message);

    } catch (error) {
      console.error('[后端保存] 保存异常:', error);
      const errorMessage = error instanceof Error ? error.message : '网络连接失败';
      return new AISaveResult(false, `保存失败: ${errorMessage}`);
    }
  }

  private scrollToBottom(): void {
    setTimeout(() => {
      try {
        this.scrollerRef.scrollEdge(Edge.Bottom);
      } catch (err) {
        console.error('[滚动] 滚动到底部失败:', err);
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
      const contextualMessage = `当前时间：${fullCurrentTime}\n全面健康数据（支持所有类型）：${userMessage}`;

      const newConversation = new ConversationItem('user', contextualMessage);
      this.conversation.push(newConversation);

      const aiMessageIndex = this.messages.length;
      const aiMsg = new Message(
        'assistant',
        '正在全面分析您的健康数据...',
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
          const parseResult = this.parseHealthDataFromAI(fullAIResponse);
          if (parseResult.userMessage) {
            this.messages[aiMessageIndex].content = parseResult.userMessage;
            this.updateCounter++;
            this.messages = [...this.messages];
          }
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

          const parseResult = this.parseHealthDataFromAI(fullAIResponse);
          const saveResult = await this.saveHealthDataToBackend(parseResult);

          let finalMessage = parseResult.userMessage;
          if (saveResult.success) {
            finalMessage += '\n\n✅ 全面健康数据已成功保存到数据库';
          } else {
            finalMessage += `\n\n❌ 数据保存失败: ${saveResult.message}`;
          }

          this.messages[aiMessageIndex].content = finalMessage;

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
            this.messages[aiMessageIndex].content = `分析失败: ${error.message}`;
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
      console.error('[AI发送] 发送异常:', err);
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
            console.error('[导航] 返回失败:', err);
          }
        })
        .width(44).height(44).backgroundColor(Color.Transparent).margin({ left: 12 })

        Text('AI全面健康数据录入').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
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
            this.messages = this.messages.slice(0, 1);
            this.conversation = this.conversation.slice(0, 2);
            this.updateCounter++;
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
                    text: msg.content || '正在全面分析您的健康数据...',
                    loadMode: "text",
                    loadCallBack: {
                      success: (r: LMICallBack) => {
                        setTimeout(() => { this.scrollToBottom(); }, 50);
                      },
                      fail: (r: LMICallBack) => {
                        console.error('[Markdown] 加载失败');
                      }
                    }
                  })
                    .backgroundColor('#fff').borderRadius(16).padding(16)
                    .shadow({ radius: 3, color: '#E8F5E8', offsetY: 2 }).width('100%')

                  if (msg.isStreaming) {
                    Row() {
                      Text('正在分析中').fontSize(12).fontColor('#4CAF50').margin({ right: 8 })
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
          Text('正在全面分析您的健康数据...').fontSize(14).fontColor('#4CAF50').margin({ left: 12 })
        }
        .justifyContent(FlexAlign.Center).width('100%').padding(12)
        .backgroundColor('#F0F8F0').borderRadius(8).margin({ left: 16, right: 16, bottom: 8 })
      }

      Row() {
        TextInput({
          placeholder: '请输入完整健康数据，支持步数、心率、血氧、睡眠、热量、心情等所有指标...',
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