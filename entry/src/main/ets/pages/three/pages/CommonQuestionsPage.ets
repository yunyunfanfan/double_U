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
    console.info('[常见问题页面] 页面初始化');
    // Initialize FAQ data
    this.faqCategories = this.getFAQData();
  }

  build() {
    Column() {
      // Navigation bar
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back'))
            .width(20)
            .height(20)
        }
        .onClick(() => {
          try {
            console.info('[常见问题页面] 返回上一页');
            router.back();
          } catch (err) {
            console.error('[常见问题页面] 返回失败:', err);
            router.pushUrl({ url: 'pages/three/pages/WxDiscoverPage' });
          }
        })
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .margin({ left: 10 })

        Text('常见问题')
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
          console.info('[常见问题页面] 搜索内容:', value);
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
                    console.info('[常见问题页面] 点击问题:', faq.question);
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
      new FAQCategory('账户注册与登录', [
        new FAQItem(
          id++,
          '如何注册新账户？',
          '注册新账户的步骤：\n1. 在登录页面点击"注册"按钮\n2. 输入您的手机号码（每个手机号只能注册一次）\n3. 输入验证码进行验证\n4. 设置用户名和密码\n5. 完成注册\n\n注意：每个手机号只能注册一个账户，请确保手机号输入正确。'
        ),
        new FAQItem(
          id++,
          '登录后为什么不需要重复登录？',
          '我们的应用具有登录记忆功能：\n1. 首次登录成功后，系统会自动保存您的登录状态\n2. 下次打开应用时会自动进入主页\n3. 除非您主动退出登录，否则不需要重复输入账号密码\n\n这样设计是为了提升您的使用体验。'
        ),
        new FAQItem(
          id++,
          '如何修改密码？',
          '修改密码的方法：\n1. 进入"我的"->"设置"->"账户安全"\n2. 点击"修改密码"\n3. 输入当前密码\n4. 输入新密码并确认\n\n注意：只有已注册的用户名才能修改密码，请确保您的账户信息正确。'
        ),
        new FAQItem(
          id++,
          '如何安全退出登录？',
          '退出登录的步骤：\n1. 在"设置"页面点击"退出登录"\n2. 确认退出操作\n3. 系统会清除所有登录信息\n4. 返回到登录页面\n\n退出后需要重新输入账号密码才能登录。'
        )
      ]),
      new FAQCategory('健康数据管理', [
        new FAQItem(
          id++,
          '如何录入健康数据？',
          '健康数据录入方法：\n1. 点击主页的"数据录入"按钮\n2. 选择要录入的数据类型（心率、血氧、步数、热量、心情等）\n3. 输入数据值\n4. 系统会自动根据是否有时间戳来分类：\n   - 有时间戳：保存为实时数据\n   - 无时间戳：保存为日常健康数据\n\n您可以通过DeepSeek智能助手来快速录入数据。'
        ),
        new FAQItem(
          id++,
          '如何查看我的健康数据？',
          '查看健康数据的方式：\n1. 主页显示今日实时数据（心率、血氧、心情）\n2. 健康统计页面显示一周趋势数据（步数、热量、睡眠）\n3. 可以查看带时间戳的详细记录\n4. 支持下拉刷新同步最新数据\n\n一周数据会根据今天是周几往前推算一周时间。'
        ),
        new FAQItem(
          id++,
          '什么是健康积分？',
          '健康积分是我们的激励系统：\n1. 通过录入健康数据获得积分\n2. 积分会自动上传到数据库\n3. 可以查看所有用户的积分排行榜\n4. 可以查看所有用户的步数排行榜\n\n健康积分鼓励您坚持记录健康数据，保持健康生活方式。'
        )
      ]),
      new FAQCategory('家庭成员功能', [
        new FAQItem(
          id++,
          '如何添加家庭成员？',
          '添加家庭成员有三种方式：\n\n1. 雷达加成员：\n   - 显示所有已注册但未成为好友的用户\n   - 可以看到对方头像和基本信息\n   - 点击添加即可发送好友申请\n\n2. 面对面加成员：\n   - 两个用户同时输入相同的四位数字\n   - 系统自动匹配并建立好友关系\n\n3. 手机号加成员：\n   - 输入对方手机号进行搜索和添加'
        ),
        new FAQItem(
          id++,
          '如何查看家庭成员信息？',
          '查看家庭成员的方法：\n1. 在"家庭成员"页面可以看到所有成员列表\n2. 点击成员头像可以查看详细信息：\n   - 昵称和拼音\n   - 手机号码\n   - 头像信息\n3. 可以查看对方的健康数据（今天和历史所有数据）\n4. 页面底部显示家庭成员总数'
        ),
        new FAQItem(
          id++,
          '如何删除家庭成员关系？',
          '删除成员关系的方法：\n1. 在家庭成员列表中找到要删除的成员\n2. 点击删除按钮\n3. 确认删除操作\n\n注意：双方任意一方都可以删除双向成员关系，删除后将无法查看对方的健康数据。'
        ),
        new FAQItem(
          id++,
          '可以查看家庭成员的哪些健康数据？',
          '成为家庭成员后可以查看：\n1. 实时健康数据：心率、血氧、心情（带时间戳）\n2. 日常健康数据：步数、热量、睡眠（一周趋势）\n3. 今日数据的简略和详细信息\n4. 历史所有天的健康数据\n\n这有助于家庭成员之间相互关心和监督健康状况。'
        )
      ]),
      new FAQCategory('应用功能与设置', [
        new FAQItem(
          id++,
          '如何使用程序专属客服？',
          '程序专属客服功能：\n1. 在发现页面找到"DS客服"选项\n2. 可以咨询关于软件使用的任何问题\n3. 客服基于DeepSeek技术，支持智能问答\n4. 支持流式输出和markdown格式显示\n\n客服可以帮助您更好地使用软件的各项功能。'
        ),
        new FAQItem(
          id++,
          '什么是猫娘助手？',
          '猫娘助手是我们的特色AI功能：\n1. 提供更有趣的交互体验\n2. 支持流式输出，对话更自然\n3. 支持markdown格式显示\n4. 可以协助处理各种问题\n\n猫娘助手让您的使用体验更加有趣和智能。'
        ),
        new FAQItem(
          id++,
          '如何更改头像和用户名？',
          '个人信息修改方法：\n\n更改头像：\n1. 进入"我的"页面\n2. 点击头像\n3. 选择新的头像图片\n4. 头像会自动上传到数据库\n\n更改用户名：\n1. 在个人设置中找到"修改用户名"\n2. 输入新的用户名\n3. 保存更改'
        ),
        new FAQItem(
          id++,
          '如何使用服药提醒功能？',
          '服药提醒设置方法：\n1. 在健康管理页面找到"服药提醒"\n2. 添加药物名称和服用时间\n3. 设置提醒频率\n4. 保存设置\n\n系统会通过通知准时提醒您服药，帮助您养成良好的用药习惯。'
        ),
        new FAQItem(
          id++,
          '助眠音乐功能如何使用？',
          '助眠音乐使用方法：\n1. 在健康管理页面找到"助眠音乐"\n2. 选择您喜欢的音乐类型\n3. 设置播放时长\n4. 开始播放真实的音乐\n\n助眠音乐可以帮助您更好地入睡，提高睡眠质量。'
        )
      ]),
      new FAQCategory('数据同步与刷新', [
        new FAQItem(
          id++,
          '如何刷新数据？',
          '数据刷新的多种方式：\n1. 主页四个标签页都支持下拉刷新\n2. 主页右上角有专门的刷新按钮\n3. 每次打开页面会自动同步最新数据\n4. 录入新数据后会自动更新显示\n\n确保您始终查看的是最新的健康数据。'
        ),
        new FAQItem(
          id++,
          '数据同步有延迟怎么办？',
          '数据同步问题解决方法：\n1. 检查网络连接是否正常\n2. 尝试手动下拉刷新\n3. 退出应用重新打开\n4. 确保应用权限设置正确\n\n如果问题持续存在，请联系客服获得帮助。'
        )
      ])
    ];
  }
}