import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { DeepSeekService } from '../../../services/deepseek/DeepSeekService';
import { LvMarkdownIn, lvText, lvTitle, lvCode, lvLink, LMICallBack } from '@luvi/lv-markdown-in';
import { userApiService, HealthDataRequest, RegisterResponse } from '../../../services/api_network/UserApiService';

// 健康数据解析结果类
class HealthDataParseResult {
  steps: number = 0;
  distance: number = 0;
  calories: number = 0;
  heart_rate: number = 0;
  blood_oxygen: number = 0;
  sleep_duration: number = 0;
  userMessage: string = '';

  constructor() {}

  toString(): string {
    return `HealthDataParseResult{steps: ${this.steps}, distance: ${this.distance}, calories: ${this.calories}}`;
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
  private currentUserId: number = 1; // 实际应从登录状态获取

  aboutToAppear(): void {
    this.initializeSystem();
  }

  private async initializeSystem(): Promise<void> {
    const currentTime = new Date().toLocaleString('zh-CN');

    const welcomeMessage = new Message(
      'assistant',
      '您好！我是健康数据录入助手，请告诉我您的健康数据，我会帮您精确记录到数据库中。',
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

第一段：数据录入块
=== 数据录入 ===
步数:17777
距离:5.9
热量:976
心率:66
血氧:97
睡眠:474

第二段：分隔符
=== 用户反馈 ===

第三段：简洁确认
✅ 精确数据已保存！
📏 距离：5.9公里（精确记录）
🚶 步数：17777步
❤️ 心率：66次/分
🫁 血氧：97%
🔥 热量：976千卡
😴 睡眠：474分钟

【数值精度要求】
- 距离：必须保留小数（如5.9、6.2）
- 步数：整数（如8666）
- 热量：支持小数（如323、323.5）
- 心率：整数（如72）
- 血氧：整数（如98）
- 睡眠：分钟数（如474表示7小时54分钟）

【数据类型对应】
- 步数 → steps（步）
- 距离 → distance（公里）
- 热量 → calories（千卡）
- 心率 → heart_rate（次/分）
- 血氧 → blood_oxygen（%）
- 睡眠 → sleep_duration（分钟）

【关键】数值必须保持原始精度，绝不截断小数！`;
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
    console.info('[健康数据解析] 开始解析AI回复');

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

      console.info(`[健康数据解析] 数据部分: ${dataPart}`);

      // 使用正则表达式提取数据
      const patterns: Record<string, RegExp> = {
        'steps': /步数[:：]\s*(\d+)/,
        'distance': /距离[:：]\s*([\d.]+)/,
        'calories': /热量[:：]\s*([\d.]+)/,
        'heart_rate': /心率[:：]\s*(\d+)/,
        'blood_oxygen': /血氧[:：]\s*(\d+)/,
        'sleep_duration': /睡眠[:：]\s*(\d+)/
      };

      Object.keys(patterns).forEach((key: string) => {
        const match = dataPart.match(patterns[key]);
        if (match) {
          const value = parseFloat(match[1]);
          if (!isNaN(value)) {
            switch (key) {
              case 'steps':
                result.steps = Math.floor(value);
                break;
              case 'distance':
                result.distance = value;
                break;
              case 'calories':
                result.calories = value;
                break;
              case 'heart_rate':
                result.heart_rate = Math.floor(value);
                break;
              case 'blood_oxygen':
                result.blood_oxygen = Math.floor(value);
                break;
              case 'sleep_duration':
                result.sleep_duration = Math.floor(value);
                break;
            }
            console.info(`[健康数据解析] 提取${key}: ${value}`);
          }
        }
      });

      result.userMessage = userPart || '数据录入完成';

      console.info(`[健康数据解析] 解析结果: ${result.toString()}`);
      return result;

    } catch (error) {
      console.error('[健康数据解析] 解析异常:', error);
      result.userMessage = aiResponse;
      return result;
    }
  }

  private async saveHealthDataToBackend(parseResult: HealthDataParseResult): Promise<AISaveResult> {
    try {
      console.info('[后端保存] 开始保存健康数据到后端');

      const requestData: HealthDataRequest = {
        user_id: this.currentUserId,
        record_date: new Date().toISOString().split('T')[0],
        steps: parseResult.steps,
        distance: parseResult.distance,
        active_calories: parseResult.calories,
        avg_heart_rate: parseResult.heart_rate,
        avg_blood_oxygen: parseResult.blood_oxygen,
        sleep_duration: parseResult.sleep_duration
      };

      // 调用后端API保存健康数据
      const response: RegisterResponse = await userApiService.saveHealthData(requestData);

      console.info(`[后端保存] 保存结果: ${response.success}, 消息: ${response.message}`);

      return new AISaveResult(response.success, response.message);

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
      const contextualMessage = `当前时间：${fullCurrentTime}\n精确健康数据（保持小数精度）：${userMessage}`;

      const newConversation = new ConversationItem('user', contextualMessage);
      this.conversation.push(newConversation);

      const aiMessageIndex = this.messages.length;
      const aiMsg = new Message(
        'assistant',
        '正在分析您的健康数据...',
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
          // 实时解析并显示用户友好信息
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

          // 解析AI回复
          const parseResult = this.parseHealthDataFromAI(fullAIResponse);

          // 保存到后端数据库
          const saveResult = await this.saveHealthDataToBackend(parseResult);

          // 更新用户消息
          let finalMessage = parseResult.userMessage;
          if (saveResult.success) {
            finalMessage += '\n\n✅ 数据已成功保存到数据库';
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

        Text('AI健康数据录入').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
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
            // 清空会话记录
            this.messages = this.messages.slice(0, 1); // 保留欢迎消息
            this.conversation = this.conversation.slice(0, 2); // 保留系统提示和欢迎消息
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
                    text: msg.content || '正在分析您的健康数据...',
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
          Text('正在分析您的健康数据...').fontSize(14).fontColor('#4CAF50').margin({ left: 12 })
        }
        .justifyContent(FlexAlign.Center).width('100%').padding(12)
        .backgroundColor('#F0F8F0').borderRadius(8).margin({ left: 16, right: 16, bottom: 8 })
      }

      Row() {
        TextInput({
          placeholder: '请输入您的健康数据，如：今天我走了8000步，心率平均72次...',
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