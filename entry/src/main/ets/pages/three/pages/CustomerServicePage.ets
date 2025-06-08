import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { DeepSeekService } from '../../../services/deepseek/DeepSeekService';
import { LvMarkdownIn, lvText, lvTitle, lvCode, lvLink, LMICallBack } from '@luvi/lv-markdown-in';

//这是在线客服页面

// 1. 定义消息类型类替代对象字面量类型
class ConversationItem {
  role: string;
  content: string;
  isStreaming?: boolean;

  constructor(role: string, content: string, isStreaming: boolean = false) {
    this.role = role;
    this.content = content;
    this.isStreaming = isStreaming;
  }
}

interface Message {
  type: 'user' | 'service';
  content: string;
  time: string;
  isStreaming?: boolean;  // 添加流式传输标识
}

@Entry
@Component
export struct CustomerServicePage {
  @State messages: Message[] = [];
  @State inputContent: string = '';
  @State showKeyboard: boolean = false;
  @State isLoading: boolean = false;
  // 添加流式传输相关状态
  @State updateCounter: number = 0;
  // 存储完整的对话记录用于DeepSeek API请求
  private conversation: ConversationItem[] = [];
  private cancelStream: (() => void) | null = null;
  // 使用scroller引用
  private scrollerRef: Scroller = new Scroller();
  // 修正：使用控制器而不是实例
  private inputController: TextInputController = new TextInputController();

  aboutToAppear() {
    this.initMessages();

    // 配置Markdown样式
    lvText.setTextSize(16);  // 设置正文字体大小
    lvText.setTextLineHeight("24");  // 设置行高
    lvTitle.setLevelTitleColor("#1976D2");  // 标题颜色使用主题蓝色
    lvCode.setTheme("dark");  // 代码块使用暗色主题
    lvCode.setIndexState(true);  // 显示代码行号
    lvLink.setTextColor("#1976D2");  // 链接颜色与主题一致
  }

  initMessages() {
    const welcomeMessage = getContext(this).resourceManager.getStringSync($r('app.string.welcome_message_customer'));
    const systemPrompt = getContext(this).resourceManager.getStringSync($r('app.string.system_prompt_customer'));

    this.messages = [
      {
        time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }),
        type: 'service',
        content: welcomeMessage
      }
    ];

    this.conversation = [
      new ConversationItem('system', systemPrompt),
      new ConversationItem('assistant', welcomeMessage)
    ];
  }

  // 改进滚动到底部的方法
  scrollToBottom() {
    setTimeout(() => {
      try {
        // 使用Edge.Bottom方法直接滚动到底部
        this.scrollerRef.scrollEdge(Edge.Bottom);
      } catch (err) {
        // 静默处理滚动错误
      }
    }, 100);
  }

  // 使用流式传输发送消息到DeepSeek
  sendToDeepSeek(userMessage: string): void {
    try {
      // 获取当前时间
      const currentTime = new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });

      // 添加用户消息到UI
      this.messages.push({
        type: 'user',
        content: userMessage,
        time: currentTime
      });

      // 添加用户消息后立即滚动到底部
      this.scrollToBottom();

      // 添加用户消息到对话记录
      this.conversation.push(new ConversationItem('user', userMessage));

      // 添加一个空的服务回复消息，用于流式更新
      const serviceMessageIndex = this.messages.length;
      this.messages.push({
        type: 'service',
        content: '',
        time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }),
        isStreaming: true
      });

      // 添加空回复后再次滚动到底部
      this.scrollToBottom();

      // 使用流式API
      this.cancelStream = DeepSeekService.streamRequest(
        userMessage,
        this.conversation,

        // 每次收到新内容时更新UI
        (chunk: string) => {
          // 使用异步更新，避免可能的渲染优化问题
          setTimeout(() => {
            this.messages[serviceMessageIndex].content = chunk;
            // 递增计数器触发UI更新
            this.updateCounter++;
            // 强制UI更新
            this.messages = [...this.messages];

            // 随着内容更新自动滚动到底部
            // 通过仅在内容有明显变化时滚动来减少滚动频率
            if (chunk.length % 50 === 0 || chunk.length < 50) {
              this.scrollToBottom();
            }
          }, 0);
        },

        // 完成时的回调
        () => {
          this.isLoading = false;
          if (this.messages[serviceMessageIndex]) {
            this.messages[serviceMessageIndex].isStreaming = false;
          }

          // 将最终回答添加到对话历史
          if (this.messages[serviceMessageIndex]?.content) {
            this.conversation.push(
              new ConversationItem('assistant', this.messages[serviceMessageIndex].content)
            );
          }

          this.updateCounter++;  // 再次触发更新
          this.messages = [...this.messages];
          this.cancelStream = null;

          // 回复完成后最后再滚动一次，确保显示完整回复
          this.scrollToBottom();
        },

        // 错误处理
        (error: Error) => {
          this.isLoading = false;
          if (this.messages[serviceMessageIndex]) {
            const errorMessage = getContext(this).resourceManager.getStringSync($r('app.string.error_response'));
            this.messages[serviceMessageIndex].content = `${errorMessage}: ${error.message}`;
            this.messages[serviceMessageIndex].isStreaming = false;
          }
          this.updateCounter++;  // 错误时也触发更新
          this.messages = [...this.messages];
          this.cancelStream = null;

          // 错误情况下也滚动到底部
          this.scrollToBottom();
        }
      );
    }
    catch (err) {
      this.isLoading = false;

      // 出错时也滚动到底部
      this.scrollToBottom();
    }
  }

  build() {
    Column() {
      BaseNavigation({ title: getContext(this).resourceManager.getStringSync($r('app.string.online_customer_service')), bgColor: Color.Transparent })

      // 聊天内容区（修复气泡显示不全，最大宽度80%）
      Scroll(this.scrollerRef) {
        Column() {
          ForEach(this.messages, (msg: Message, index) => {
            Row() {
              if (msg.type === 'service') {
                Image($r('app.media.ic_service')).width(36).height(36).borderRadius(18)
                Column() {
                  // 将时间移到顶部
                  Text(msg.time).fontSize(12).fontColor('#aaa').margin({ bottom: 4 })

                  // 所有状态下都使用Markdown渲染
                  LvMarkdownIn({
                    text: msg.content || getContext(this).resourceManager.getStringSync($r('app.string.thinking_placeholder')),
                    loadMode: "text",
                    loadCallBack: {
                      success: (r: LMICallBack) => {
                        // Markdown渲染成功后也触发一次滚动
                        this.scrollToBottom();
                      },
                      fail(r: LMICallBack) {
                        // 静默处理渲染错误
                      }
                    }
                  })
                    .backgroundColor('#fff')
                    .borderRadius(16)
                    .padding(14)
                    .shadow({ radius: 2, color: '#E3EFFF' })
                    .width('100%')
                    .key(`markdown-${index}-${msg.content.length}-${this.updateCounter}`)

                  // 为流式输出添加动态指示器
                  if (msg.isStreaming) {
                    Row() {
                      ForEach([1, 2, 3], (i: number) => {
                        Text('.')
                          .fontSize(20)
                          .fontColor('#1976D2')
                          .fontWeight(FontWeight.Bold)
                          .opacity(i * 0.3)
                            // 添加动画效果增强流式感
                          .animation({
                            duration: 800,
                            iterations: -1,
                            curve: Curve.EaseInOut
                          })
                      })
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Start)
                    .margin({ top: 4 })
                  }
                }.margin({ left: 8 })
                .width('80%')
                Blank()
              } else {
                Blank()
                Column() {
                  // 将时间移到顶部
                  Text(msg.time).fontSize(12).fontColor('#aaa').margin({ bottom: 4 })

                  Text(msg.content)
                    .fontSize(16)
                    .fontColor('#fff')
                    .backgroundColor('#1976D2')
                    .borderRadius(16)
                    .padding(14)
                    .shadow({ radius: 2, color: '#B3D1FF' })
                }.margin({ right: 8 })
                .width('80%')
                Image($r('app.media.ic_user')).width(36).height(36).borderRadius(18)
              }
            }
            .width('100%')
            .justifyContent(msg.type === 'user' ? FlexAlign.End : FlexAlign.Start)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .id(`message-${index}`) // 添加ID便于定位
          }, (msg: Message, index) => `${index}-${msg.type}-${msg.content.length}-${msg.isStreaming}-${this.updateCounter}`)
        }
        .width('100%')
        .padding({ top: 8 }) // 添加顶部间距，避免内容紧贴顶部
        .onClick(() => {
          // 点击聊天区域时让输入框失焦
          this.inputController.stopEditing();
        })
      }
      .layoutWeight(1)
      .backgroundColor('#F7F9FA')
      .scrollBar(BarState.Auto) // 自动显示/隐藏滚动条
      .edgeEffect(EdgeEffect.Spring) // 添加弹簧效果增强滚动体验

      // 显示加载状态
      if (this.isLoading) {
        Row() {
          LoadingProgress().width(24).height(24)
          Text(getContext(this).resourceManager.getStringSync($r('app.string.thinking_placeholder'))).fontSize(14).fontColor('#999').margin({ left: 8 })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding(8)
      }

      // 输入区（发送按钮主色蓝，纸飞机白色）
      Row() {
        TextInput({
          placeholder: getContext(this).resourceManager.getStringSync($r('app.string.input_placeholder')),
          text: this.inputContent,
          controller: this.inputController // 使用正确的控制器
        })
          .backgroundColor('#fff')
          .borderRadius(24)
          .border({ width: 1, color: '#1976D2' })
          .padding(14)
          .fontSize(16)
          .layoutWeight(1)
          .onChange((v: string) => { this.inputContent = v })
          .enabled(!this.isLoading)
          .onSubmit(() => {
            // 当按下回车键时也发送消息
            if (this.inputContent && !this.isLoading && !this.cancelStream) {
              const userMessage = this.inputContent;
              this.inputContent = '';
              this.isLoading = true;
              this.sendToDeepSeek(userMessage);
            }
          })

        Button({ type: ButtonType.Circle }) {
          Image(this.cancelStream ? $r('app.media.ic_stop') : $r('app.media.ic_send'))
            .width(24).height(24)
            .fillColor(Color.White)
        }
        .onClick(() => {
          if (this.cancelStream) {
            // 如果正在流式输出，则点击按钮停止
            this.cancelStream();
            this.cancelStream = null;
            this.isLoading = false;
          } else {
            // 否则发送新消息
            if (!this.inputContent || this.isLoading) return;

            const userMessage = this.inputContent;
            // 清空输入框
            this.inputContent = '';

            // 设置加载状态
            this.isLoading = true;

            // 发送消息
            this.sendToDeepSeek(userMessage);
          }
        })
        .backgroundColor(this.cancelStream ? '#FF3B30' : '#1976D2')
        .borderRadius(24)
        .width(48).height(48)
        .margin({ left: 8 })
        .enabled(!this.isLoading || this.cancelStream !== null)
      }
      .padding(16)
      .backgroundColor('#F7F9FA')
    }
    .backgroundColor('#F7F9FA').height('100%')
  }
}