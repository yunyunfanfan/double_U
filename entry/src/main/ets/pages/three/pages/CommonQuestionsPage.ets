import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';

// FAQ item model
class FAQItem {
  id: number;
  question: string;
  answer: string;
  
  constructor(id: number, question: string, answer: string) {
    this.id = id;
    this.question = question;
    this.answer = answer;
  }
}

// FAQ category model
class FAQCategory {
  title: string;
  faqs: FAQItem[];
  
  constructor(title: string, faqs: FAQItem[]) {
    this.title = title;
    this.faqs = faqs;
  }
}

@Entry
@Component
export struct CommonQuestionsPage {
  @State faqCategories: FAQCategory[] = [];
  @State searchText: string = '';
  @State expandedQuestionId: number = -1; // Track which question is expanded
  scroller: Scroller = new Scroller();
  private questionIdCounter: number = 0;
  
  aboutToAppear() {
    // Initialize FAQ data
    this.faqCategories = this.getFAQData();
  }
  
  build() {
    Column() {
      // Navigation bar
      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r('app.media.ic_back'))
            .width(20)
            .height(20)
        }
        .onClick(() => {
          try {
            router.back();
          } catch (err) {
            console.error('Failed to go back:', err);
            router.pushUrl({ url: 'pages/three/pages/WxDiscoverPage' });
          }
        })
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .margin({ left: 10 })
        
        Text('此页等待所有功能都实现之后再重新做(尚未实现多语言)')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(60)
      .alignItems(VerticalAlign.Center)
      
      // Search bar
      Search({ value: this.searchText, placeholder: '搜索问题' })
        .width('90%')
        .height(40)
        .margin({ top: 10, bottom: 20 })
        .onChange((value: string) => {
          this.searchText = value;
        })
      
      // FAQ content
      List({ scroller: this.scroller }) {
        ForEach(this.faqCategories, (category: FAQCategory) => {
          ListItem() {
            Column() {
              // Category title
              Text(category.title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .padding(15)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
              
              // FAQs in this category
              ForEach(category.faqs.filter(item => 
                this.searchText === '' || 
                item.question.toLowerCase().includes(this.searchText.toLowerCase()) ||
                item.answer.toLowerCase().includes(this.searchText.toLowerCase())
              ), (faq: FAQItem) => {
                Column() {
                  // Question row with expand/collapse functionality
                  Row() {
                    Text(faq.question)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .layoutWeight(1)
                      .margin({ right: 10 })
                    
                    // Use simple Text instead of Image for arrow icons
                    Text(this.expandedQuestionId === faq.id ? '▲' : '▼')
                      .fontSize(16)
                      .fontColor('#666666')
                  }
                  .width('100%')
                  .padding(15)
                  .onClick(() => {
                    if (this.expandedQuestionId === faq.id) {
                      this.expandedQuestionId = -1; // Collapse if already expanded
                    } else {
                      this.expandedQuestionId = faq.id; // Expand this question
                    }
                  })
                  
                  // Answer (visible only when expanded)
                  if (this.expandedQuestionId === faq.id) {
                    Column() {
                      // Split the answer by newline characters and display each line separately
                      ForEach(faq.answer.split('\n'), (line: string) => {
                        if (line.trim().length > 0) {
                          Text(line)
                            .fontSize(14)
                            .fontColor('#666666')
                            .width('100%')
                            .margin({ bottom: 5 })
                        }
                      })
                    }
                    .width('100%')
                    .padding({ left: 15, right: 15, bottom: 15 })
                    .alignItems(HorizontalAlign.Start)
                  }
                }
                .width('100%')
                .backgroundColor(Color.White)
                .borderRadius(8)
                .margin({ bottom: 10 })
              })
            }
            .width('100%')
            .margin({ bottom: 20 })
          }
        })
      }
      .width('90%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
  
  getFAQData(): FAQCategory[] {
    let id = 0;
    return [
      new FAQCategory('设备连接问题', [
        new FAQItem(
          id++,
          '如何将我的智能手表与应用配对？',
          '1. 确保您的手表已开机并处于配对模式\n2. 在应用中点击"添加设备"\n3. 选择您的设备型号\n4. 按照屏幕上的指示完成配对过程'
        ),
        new FAQItem(
          id++,
          '我的设备无法连接到应用，该怎么办？',
          '请尝试以下解决方案：\n1. 确保蓝牙已开启\n2. 重启您的手机和设备\n3. 确保设备电量充足\n4. 尝试在设备上重置蓝牙连接\n5. 卸载并重新安装应用'
        ),
        new FAQItem(
          id++,
          '为什么我的设备数据不同步？',
          '数据同步问题可能由以下原因导致：\n1. 设备与手机的连接不稳定\n2. 设备电量不足\n3. 应用权限设置问题\n\n请确保设备已正确连接，并尝试手动同步数据。'
        )
      ]),
      new FAQCategory('健康数据问题', [
        new FAQItem(
          id++,
          '我的步数记录不准确，为什么？',
          '步数记录可能受多种因素影响：\n1. 设备佩戴位置不正确\n2. 某些活动（如骑自行车）可能无法准确记录步数\n3. 设备传感器可能需要校准\n\n建议确保设备正确佩戴，并在设置中检查步数灵敏度设置。'
        ),
        new FAQItem(
          id++,
          '心率监测功能如何使用？',
          '要使用心率监测功能：\n1. 确保设备正确佩戴，贴合皮肤\n2. 在设备或应用中找到心率监测功能\n3. 保持静止状态进行测量\n4. 等待测量完成，查看结果\n\n注意：心率数据仅供参考，不可作为医疗诊断依据。'
        ),
        new FAQItem(
          id++,
          '睡眠数据不准确怎么办？',
          '提高睡眠监测准确性的方法：\n1. 确保设备正确佩戴\n2. 设置准确的睡眠时间范围\n3. 更新至最新固件版本\n4. 尝试调整设备在手腕上的位置\n\n睡眠监测可能无法100%准确，但通常可以提供有用的睡眠趋势数据。'
        )
      ]),
      new FAQCategory('账户与隐私', [
        new FAQItem(
          id++,
          '如何保护我的健康数据安全？',
          '我们采取多种措施保护您的健康数据：\n1. 所有数据均经过加密存储和传输\n2. 您可以在设置中控制数据共享权限\n3. 定期更改密码并启用双因素认证\n4. 不要在不信任的设备上登录账户\n\n您可以随时在隐私设置中查看和管理您的数据。'
        ),
        new FAQItem(
          id++,
          '如何删除我的账户和数据？',
          '删除账户和数据的步骤：\n1. 进入"我的"->"设置"->"账户安全"\n2. 选择"删除账户"\n3. 阅读并确认数据删除声明\n4. 输入密码确认\n\n注意：账户删除后，所有数据将被永久删除且无法恢复。'
        )
      ]),
      new FAQCategory('应用功能', [
        new FAQItem(
          id++,
          '家庭健康排行榜如何使用？',
          '家庭健康排行榜功能使用方法：\n1. 在"家庭"标签中点击"运动排行榜"\n2. 查看家庭成员的健康数据排名\n3. 可以切换不同的健康指标（步数、卡路里等）\n4. 可以选择不同的时间范围（今日、本周、本月等）\n\n通过排行榜可以激励家庭成员共同保持健康生活方式。'
        ),
        new FAQItem(
          id++,
          '共同健康目标功能是什么？',
          '共同健康目标是一项家庭协作功能：\n1. 在"家庭"标签中点击"共同健康目标"\n2. 查看当前进行中和已完成的健康目标\n3. 可以创建新的健康目标并邀请家人参与\n4. 跟踪目标进度和每个成员的贡献\n\n这是一种有趣的方式，让全家人一起努力实现健康目标。'
        )
      ])
    ];
  }
} 