import { DeepSeekService } from '../../services/deepseek/DeepSeekService';
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon';
import { LvMarkdownIn, lvText, lvTitle, lvCode, lvLink, LMICallBack } from '@luvi/lv-markdown-in';

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

@Entry
@Component
export struct ChatPage {
  private scrollerRef: Scroller = new Scroller();
  @State message: string = '';
  @State response: string = '';
  @State isLoading: boolean = false;
  @State conversation: ConversationItem[] = [];
  @State updateCounter: number = 0;
  @State catAssistantTitle: string = '';
  @State waitingQuestion: string = '';
  @State systemPrompt: string = '';
  @State welcomeMessage: string = '';
  @State thinkingText: string = '';
  @State inputPlaceholder: string = '';
  @State sendButton: string = '';
  @State stopButton: string = '';
  @State requestError: string = '';
  private cancelStream: (() => void) | null = null;

  aboutToAppear() {
    this.catAssistantTitle = getContext(this).resourceManager.getStringSync($r('app.string.cat_assistant_title'));
    this.waitingQuestion = getContext(this).resourceManager.getStringSync($r('app.string.waiting_question'));
    this.systemPrompt = getContext(this).resourceManager.getStringSync($r('app.string.system_prompt'));
    this.welcomeMessage = getContext(this).resourceManager.getStringSync($r('app.string.welcome_message'));
    this.thinkingText = getContext(this).resourceManager.getStringSync($r('app.string.thinking_text'));
    this.inputPlaceholder = getContext(this).resourceManager.getStringSync($r('app.string.input_placeholder'));
    this.sendButton = getContext(this).resourceManager.getStringSync($r('app.string.send_button'));
    this.stopButton = getContext(this).resourceManager.getStringSync($r('app.string.stop_button'));
    this.requestError = getContext(this).resourceManager.getStringSync($r('app.string.request_error'));

    lvText.setTextSize(16);
    lvText.setTextLineHeight("24");
    lvTitle.setLevelTitleColor("#FF9500");
    lvCode.setTheme("dark");
    lvCode.setIndexState(true);
    lvLink.setTextColor("#007AFF");

    this.conversation.push(new ConversationItem('system', this.systemPrompt));
    this.conversation.push(new ConversationItem('assistant', this.welcomeMessage));
  }

  scrollToBottom() {
    setTimeout(() => {
      try {
        this.scrollerRef.scrollEdge(Edge.Bottom);
      } catch (err) {
      }
    }, 100);
  }

  private handleInputChange(value: string): void {
    this.message = value;
  }

  private sendMessage(): void {
    if (!this.message.trim()) return;

    this.isLoading = true;
    const userMessage = this.message;

    this.conversation.push(new ConversationItem('user', userMessage));
    this.scrollToBottom();

    const aiMessageIndex = this.conversation.length;
    this.conversation.push(new ConversationItem('assistant', '', true));
    this.message = '';
    this.scrollToBottom();

    this.cancelStream = DeepSeekService.streamRequest(
      userMessage,
      this.conversation.slice(0, -1),

      (chunk: string) => {
        setTimeout(() => {
          this.conversation[aiMessageIndex].content = chunk;
          this.updateCounter++;
          this.conversation = [...this.conversation];

          if (chunk.length % 50 === 0 || chunk.length < 50) {
            this.scrollToBottom();
          }
        }, 0);
      },

      () => {
        this.isLoading = false;
        this.conversation[aiMessageIndex].isStreaming = false;
        this.updateCounter++;
        this.conversation = [...this.conversation];
        this.cancelStream = null;
        this.scrollToBottom();
      },

      (error: Error) => {
        this.isLoading = false;
        this.conversation[aiMessageIndex].content = `${this.requestError}: ${error.message} 喵...`;
        this.conversation[aiMessageIndex].isStreaming = false;
        this.updateCounter++;
        this.conversation = [...this.conversation];
        this.cancelStream = null;
        this.scrollToBottom();
      }
    );
  }

  build() {
    Column() {
      BaseNavigation({ title: this.catAssistantTitle, bgColor: Color.Transparent })

      Scroll(this.scrollerRef) {
        List({ space: 10 }) {
          ForEach(this.conversation, (item: ConversationItem, index) => {
            ListItem() {
              Column() {
                Text(`${item.role}:`)
                  .fontColor(item.role === 'user' ? '#007AFF' : '#FF9500')
                  .fontSize(14)

                if (item.role === 'assistant' || item.role === 'system') {
                  LvMarkdownIn({
                    text: item.content || this.thinkingText,
                    loadMode: "text",
                    loadCallBack: {
                      success: (r: LMICallBack) => {
                        this.scrollToBottom();
                      },
                      fail(r: LMICallBack) {
                      }
                    }
                  })
                    .width('100%')
                    .margin({ top: 4 })
                    .key(`markdown-${index}-${item.content.length}-${this.updateCounter}`)
                } else {
                  Text(item.content)
                    .fontSize(16)
                    .margin({ top: 4 })
                    .width('100%')
                }

                if (item.isStreaming) {
                  Row() {
                    ForEach([1, 2, 3], (i: number) => {
                      Text('.')
                        .fontSize(20)
                        .fontWeight(FontWeight.Bold)
                        .opacity(i * 0.3)
                        .animation({
                          duration: 800,
                          iterations: -1,
                          curve: Curve.EaseInOut
                        })
                    })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Start)
                }
              }
              .width('90%')
              .padding({left: '5%', right: '5%', top: 10, bottom: 10})
              .backgroundColor(item.role === 'user' ? '#F0F0F0' : '#E6F2FF')
              .borderRadius(10)
              .margin({
                left: item.role === 'user' ? '10%' : 0,
                right: item.role === 'user' ? 0 : '10%'
              })
            }
          }, (item: ConversationItem, index) => `${index}-${item.role}-${item.content.length}-${item.isStreaming}-${this.updateCounter}`)
        }
        .width('100%')
        .padding({ bottom: 16 })
        .alignListItem(ListItemAlign.Center)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)

      Row() {
        TextInput({ placeholder: this.inputPlaceholder, text: this.message })
          .onChange((value: string) => this.handleInputChange(value))
          .height(50)
          .layoutWeight(1)
          .border({ width: 1, color: '#CCCCCC', radius: 20 })
          .onSubmit(() => {
            if (this.message && !this.isLoading && !this.cancelStream) {
              this.sendMessage();
            }
          })

        Button(this.cancelStream ? this.stopButton : this.sendButton)
          .onClick(() => {
            if (this.cancelStream) {
              this.cancelStream();
              this.cancelStream = null;
              this.isLoading = false;
            } else {
              this.sendMessage();
            }
          })
          .height(50)
          .margin({ left: 14 })
          .backgroundColor(this.cancelStream ? '#FF3B30' : '#007AFF')
      }
      .width('100%')
      .alignSelf(ItemAlign.Center)

      if (this.isLoading) {
        Progress({value:0})
          .width('100%')
          .margin({ bottom: 10 })
      }
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .padding({left: '3%', right: '3%', top: 1, bottom: 3})
    .backgroundColor('#FFFFFF')
  }
}