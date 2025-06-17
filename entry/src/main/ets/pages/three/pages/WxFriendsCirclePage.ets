///  WxFriendsCirclePage.ets
///
///  Created by iotjin on 2024/11/28.
///  description: 健康圈 - 健康社区分享平台

import { router } from '@kit.ArkUI';
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'

// 健康动态类型枚举
enum HealthPostType {
  EXERCISE = 'exercise',
  DIET = 'diet',
  SLEEP = 'sleep',
  MOOD = 'mood',
  CHALLENGE = 'challenge',
  KNOWLEDGE = 'knowledge'
}

// 动态类型选项接口
interface PostTypeOption {
  type: HealthPostType
  name: string
  icon: string
}

// 健康动态模型
class HealthPost {
  id: string
  authorName: string
  authorAvatar: string
  authorLevel: string
  postType: HealthPostType
  title: string
  content: string
  images: string[]
  healthData: HealthMetrics
  timestamp: string
  likes: number
  comments: number
  isLiked: boolean
  tags: string[]

  constructor(id: string, authorName: string, authorAvatar: string, authorLevel: string,
    postType: HealthPostType, title: string, content: string, images: string[],
    healthData: HealthMetrics, timestamp: string, likes: number, comments: number,
    isLiked: boolean, tags: string[]) {
    this.id = id
    this.authorName = authorName
    this.authorAvatar = authorAvatar
    this.authorLevel = authorLevel
    this.postType = postType
    this.title = title
    this.content = content
    this.images = images
    this.healthData = healthData
    this.timestamp = timestamp
    this.likes = likes
    this.comments = comments
    this.isLiked = isLiked
    this.tags = tags
  }
}

// 健康指标模型
class HealthMetrics {
  steps?: number
  calories?: number
  heartRate?: number
  sleepHours?: number
  weight?: number

  constructor(steps?: number, calories?: number, heartRate?: number, sleepHours?: number, weight?: number) {
    this.steps = steps
    this.calories = calories
    this.heartRate = heartRate
    this.sleepHours = sleepHours
    this.weight = weight
  }
}

// 健康挑战模型
class HealthChallenge {
  id: string
  title: string
  description: string
  detailedDescription: string
  icon: string
  participants: number
  duration: string
  reward: string
  progress: number
  category: string
  difficulty: string
  benefits: string[]
  dailyGoals: string[]
  tips: string[]
  startDate: string
  endDate: string

  constructor(id: string, title: string, description: string, detailedDescription: string, icon: string,
    participants: number, duration: string, reward: string, progress: number, category: string,
    difficulty: string, benefits: string[], dailyGoals: string[], tips: string[],
    startDate: string, endDate: string) {
    this.id = id
    this.title = title
    this.description = description
    this.detailedDescription = detailedDescription
    this.icon = icon
    this.participants = participants
    this.duration = duration
    this.reward = reward
    this.progress = progress
    this.category = category
    this.difficulty = difficulty
    this.benefits = benefits
    this.dailyGoals = dailyGoals
    this.tips = tips
    this.startDate = startDate
    this.endDate = endDate
  }
}

// 新增：发布动态的数据模型
class NewPostData {
  postType: HealthPostType
  title: string
  content: string
  tags: string[]
  healthData: HealthMetrics

  constructor() {
    this.postType = HealthPostType.EXERCISE
    this.title = ''
    this.content = ''
    this.tags = []
    this.healthData = new HealthMetrics()
  }
}

@Entry
@Component
struct WxFriendsCirclePage {
  @State healthPosts: HealthPost[] = []
  @State healthChallenges: HealthChallenge[] = []
  @State selectedTab: number = 0
  @State showPostDialog: boolean = false
  @State showChallengeDetailDialog: boolean = false
  @State selectedChallenge: HealthChallenge | null = null
  @State newPostData: NewPostData = new NewPostData()
  @State inputTitle: string = ''
  @State inputContent: string = ''
  @State selectedPostType: HealthPostType = HealthPostType.EXERCISE
  @State inputTags: string = ''
  private tabs: string[] = ['动态', '挑战', '知识', '我的']
  private postTypes: PostTypeOption[] = []
  scroller: Scroller = new Scroller()

  aboutToAppear() {
    this.initPostTypes()
    this.loadHealthData()
  }

  // 初始化动态类型选项
  initPostTypes() {
    this.postTypes = [
      { type: HealthPostType.EXERCISE, name: '运动', icon: '🏃‍♂️' },
      { type: HealthPostType.DIET, name: '饮食', icon: '🥗' },
      { type: HealthPostType.SLEEP, name: '睡眠', icon: '😴' },
      { type: HealthPostType.MOOD, name: '情绪', icon: '😊' },
      { type: HealthPostType.CHALLENGE, name: '挑战', icon: '🏆' },
      { type: HealthPostType.KNOWLEDGE, name: '知识', icon: '📚' }
    ]
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        this.buildNavigationBar()

        // 标签页切换
        this.buildTabBar()

        // 内容区域
        this.buildContentArea()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F9FA')

      // 发布动态弹窗
      if (this.showPostDialog) {
        this.buildPostDialog()
      }

      // 挑战详情弹窗
      if (this.showChallengeDetailDialog && this.selectedChallenge) {
        this.buildChallengeDetailDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildNavigationBar() {
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

      Text('健康圈')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 发布按钮
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('✏️')
          .fontSize(20)
      }
      .onClick(() => {
        this.showPostDialog = true;
      })
      .width(40)
      .height(40)
      .backgroundColor('#4CAF50')
      .margin({ right: 10 })
    }
    .width('100%')
    .height(60)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF')
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  buildTabBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize(16)
            .fontColor(this.selectedTab === index ? '#4CAF50' : '#666666')
            .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
            .padding({ top: 12, bottom: 8 })

          if (this.selectedTab === index) {
            Divider()
              .width(30)
              .height(3)
              .color('#4CAF50')
              .borderRadius(2)
          }
        }
        .layoutWeight(1)
        .onClick(() => {
          this.selectedTab = index;
        })
      })
    }
    .width('100%')
    .height(50)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 4 })
  }

  @Builder
  buildContentArea() {
    if (this.selectedTab === 0) {
      this.buildHealthPostsTab()
    } else if (this.selectedTab === 1) {
      this.buildChallengesTab()
    } else if (this.selectedTab === 2) {
      this.buildKnowledgeTab()
    } else {
      this.buildMyTab()
    }
  }

  @Builder
  buildHealthPostsTab() {
    Scroll(this.scroller) {
      Column({ space: 12 }) {
        // 今日健康概览卡片
        this.buildTodayHealthOverview()

        // 健康动态列表
        ForEach(this.healthPosts, (post: HealthPost) => {
          this.buildHealthPostCard(post)
        })
      }
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildTodayHealthOverview() {
    Column() {
      Row() {
        Text('今日健康概览')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('查看详情 >')
          .fontSize(14)
          .fontColor('#4CAF50')
          .onClick(() => {
            // 暂时使用提示信息，避免跳转失败
            JhProgressHUD.showText('健康数据详情功能开发中...');
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row({ space: 12 }) {
        this.buildMetricCard('步数', '8,756', '步', '#2196F3', '🚶‍♂️')
        this.buildMetricCard('热量', '2,345', 'Kcal', '#FF9800', '🔥')
        this.buildMetricCard('心率', '72', 'bpm', '#E91E63', '❤️')
      }
      .width('100%')
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
  buildMetricCard(title: string, value: string, unit: string, color: string, emoji: string) {
    Column() {
      Text(emoji)
        .fontSize(24)
        .margin({ bottom: 8 })

      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(unit)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 2, bottom: 4 })

      Text(title)
        .fontSize(14)
        .fontColor('#666666')
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildHealthPostCard(post: HealthPost) {
    Column() {
      // 用户信息行
      Row() {
        Row() {
          Text(post.authorName.substring(0, 1))
            .fontSize(16)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .width(40)
            .height(40)
            .borderRadius(20)
            .backgroundColor('#4CAF50')
        }
        .margin({ right: 12 })

        Column() {
          Row() {
            Text(post.authorName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Text(post.authorLevel)
              .fontSize(12)
              .fontColor('#4CAF50')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#E8F5E8')
              .borderRadius(10)
              .margin({ left: 8 })
          }

          Text(post.timestamp)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.getPostTypeIcon(post.postType))
          .fontSize(20)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 内容区域
      Column() {
        if (post.title) {
          Text(post.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })
        }

        Text(post.content)
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .textAlign(TextAlign.Start)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 12 })

        // 健康数据展示
        if (post.healthData) {
          this.buildPostHealthData(post.healthData)
        }

        // 标签
        if (post.tags.length > 0) {
          Row() {
            ForEach(post.tags, (tag: string) => {
              Text(`#${tag}`)
                .fontSize(12)
                .fontColor('#4CAF50')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#E8F5E8')
                .borderRadius(12)
                .margin({ right: 8 })
            })
          }
          .width('100%')
          .margin({ top: 8, bottom: 12 })
        }
      }
      .width('100%')

      // 互动区域
      Row() {
        Row() {
          Text(post.isLiked ? '❤️' : '🤍')
            .fontSize(16)
            .onClick(() => {
              this.togglePostLike(post);
            })

          Text(post.likes.toString())
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
        .margin({ right: 20 })

        Row() {
          Text('💬')
            .fontSize(16)

          Text(post.comments.toString())
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
        .margin({ right: 20 })

        Blank()

        Text('分享')
          .fontSize(14)
          .fontColor('#4CAF50')
          .onClick(() => {
            JhProgressHUD.showText('分享功能开发中...');
          })
      }
      .width('100%')
      .padding({ top: 12 })
      .border({
        width: { top: 1 },
        color: '#F0F0F0'
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  buildPostHealthData(healthData: HealthMetrics) {
    Row({ space: 12 }) {
      if (healthData.steps) {
        this.buildDataChip('🚶‍♂️', healthData.steps.toString(), '步')
      }
      if (healthData.calories) {
        this.buildDataChip('🔥', healthData.calories.toString(), 'Kcal')
      }
      if (healthData.heartRate) {
        this.buildDataChip('❤️', healthData.heartRate.toString(), 'bpm')
      }
      if (healthData.sleepHours) {
        this.buildDataChip('😴', healthData.sleepHours.toString(), 'h')
      }
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  buildDataChip(icon: string, value: string, unit: string) {
    Row() {
      Text(icon)
        .fontSize(14)
        .margin({ right: 4 })

      Text(`${value}${unit}`)
        .fontSize(12)
        .fontColor('#666666')
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
  }

  @Builder
  buildChallengesTab() {
    Scroll() {
      Column({ space: 16 }) {
        Text('健康挑战')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .textAlign(TextAlign.Start)

        ForEach(this.healthChallenges, (challenge: HealthChallenge) => {
          this.buildChallengeCard(challenge)
        })
      }
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildChallengeCard(challenge: HealthChallenge) {
    Column() {
      // 头部信息
      Row() {
        Text(challenge.icon)
          .fontSize(32)
          .margin({ right: 16 })

        Column() {
          Row() {
            Text(challenge.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Blank()

            // 难度标签
            Text(challenge.difficulty)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(this.getDifficultyColor(challenge.difficulty))
              .borderRadius(10)
          }
          .width('100%')

          Text(challenge.category)
            .fontSize(12)
            .fontColor('#4CAF50')
            .margin({ top: 4, bottom: 6 })

          Text(challenge.description)
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Start)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 挑战统计信息
      Row() {
        Column() {
          Text(challenge.participants.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')

          Text('参与人数')
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(challenge.duration)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')

          Text('挑战时长')
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(challenge.reward)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E91E63')

          Text('奖励积分')
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(`${challenge.progress}%`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2196F3')

          Text('我的进度')
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 16 })

      // 进度条
      Progress({
        value: challenge.progress,
        total: 100,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(6)
        .color('#4CAF50')
        .backgroundColor('#F0F0F0')
        .margin({ bottom: 16 })

      // 主要好处（显示前3个）
      if (challenge.benefits.length > 0) {
        Column() {
          Text('主要好处')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          ForEach(challenge.benefits.slice(0, 3), (benefit: string, index: number) => {
            Row() {
              Text('✓')
                .fontSize(12)
                .fontColor('#4CAF50')
                .margin({ right: 6 })

              Text(benefit)
                .fontSize(12)
                .fontColor('#666666')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 4 })
          })
        }
        .width('100%')
        .margin({ bottom: 16 })
      }

      // 操作按钮区域
      Row() {
        Button('查看详情')
          .width('45%')
          .height(36)
          .fontSize(14)
          .fontColor('#4CAF50')
          .backgroundColor('#E8F5E8')
          .borderRadius(18)
          .onClick(() => {
            this.selectedChallenge = challenge;
            this.showChallengeDetailDialog = true;
          })

        Blank()

        Button(challenge.progress > 0 ? '继续挑战' : '参与挑战')
          .width('45%')
          .height(36)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(challenge.progress > 0 ? '#FF9800' : '#4CAF50')
          .borderRadius(18)
          .onClick(() => {
            this.joinChallenge(challenge);
          })
      }
      .width('100%')
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

  // 获取难度对应的颜色
  getDifficultyColor(difficulty: string): string {
    switch (difficulty) {
      case '简单':
        return '#4CAF50'
      case '中等':
        return '#FF9800'
      case '困难':
        return '#F44336'
      default:
        return '#9E9E9E'
    }
  }

  // 参与挑战
  joinChallenge(challenge: HealthChallenge) {
    if (challenge.progress > 0) {
      JhProgressHUD.showText(`继续加油！你已经完成了${challenge.progress}%的进度`);
    } else {
      JhProgressHUD.showText(`成功参与${challenge.title}！让我们开始这个健康之旅吧！`);
      // 这里可以添加实际的参与逻辑
      challenge.progress = 5; // 模拟开始进度
      challenge.participants += 1; // 增加参与人数
    }
  }

  @Builder
  buildChallengeDetailDialog() {
    if (this.selectedChallenge) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => {
            this.showChallengeDetailDialog = false;
            this.selectedChallenge = null;
          })

        // 弹窗内容
        Column() {
          // 弹窗标题栏
          Row() {
            Text('挑战详情')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Blank()

            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Text('✕')
                .fontSize(18)
                .fontColor('#666666')
            }
            .width(32)
            .height(32)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.showChallengeDetailDialog = false;
              this.selectedChallenge = null;
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 16 })
          .border({
            width: { bottom: 1 },
            color: '#F0F0F0'
          })

          // 滚动内容区域
          Scroll() {
            Column() {
              // 挑战头部信息
              Row() {
                Text(this.selectedChallenge.icon)
                  .fontSize(48)
                  .margin({ right: 16 })

                Column() {
                  Text(this.selectedChallenge.title)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .width('100%')
                    .textAlign(TextAlign.Start)

                  Row() {
                    Text(this.selectedChallenge.category)
                      .fontSize(12)
                      .fontColor('#4CAF50')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor('#E8F5E8')
                      .borderRadius(10)

                    Text(this.selectedChallenge.difficulty)
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor(this.getDifficultyColor(this.selectedChallenge.difficulty))
                      .borderRadius(10)
                      .margin({ left: 8 })
                  }
                  .margin({ top: 8 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .margin({ bottom: 20 })

              // 挑战描述
              Column() {
                Text('挑战介绍')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                Text(this.selectedChallenge.detailedDescription)
                  .fontSize(14)
                  .fontColor('#666666')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .lineHeight(22)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F8F9FA')
              .borderRadius(12)
              .margin({ bottom: 16 })

              // 挑战时间
              Column() {
                Text('📅 挑战时间')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                Row() {
                  Column() {
                    Text('开始时间')
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ bottom: 4 })

                    Text(this.selectedChallenge.startDate)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Column() {
                    Text('结束时间')
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ bottom: 4 })

                    Text(this.selectedChallenge.endDate)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Column() {
                    Text('持续时间')
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ bottom: 4 })

                    Text(this.selectedChallenge.duration)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#4CAF50')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({
                width: 1,
                color: '#E8F5E8'
              })
              .margin({ bottom: 16 })

              // 健康好处
              Column() {
                Text('💪 健康好处')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                ForEach(this.selectedChallenge.benefits, (benefit: string, index: number) => {
                  Row() {
                    Text('✓')
                      .fontSize(14)
                      .fontColor('#4CAF50')
                      .fontWeight(FontWeight.Bold)
                      .margin({ right: 8 })

                    Text(benefit)
                      .fontSize(14)
                      .fontColor('#666666')
                      .layoutWeight(1)
                      .lineHeight(20)
                  }
                  .width('100%')
                  .margin({ bottom: 8 })
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F8FFF8')
              .borderRadius(12)
              .margin({ bottom: 16 })

              // 每日目标
              Column() {
                Text('🎯 每日目标')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                ForEach(this.selectedChallenge.dailyGoals, (goal: string, index: number) => {
                  Row() {
                    Text(`${index + 1}`)
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .textAlign(TextAlign.Center)
                      .width(20)
                      .height(20)
                      .borderRadius(10)
                      .backgroundColor('#FF9800')
                      .margin({ right: 8 })

                    Text(goal)
                      .fontSize(14)
                      .fontColor('#666666')
                      .layoutWeight(1)
                      .lineHeight(20)
                  }
                  .width('100%')
                  .margin({ bottom: 8 })
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFF8F0')
              .borderRadius(12)
              .margin({ bottom: 16 })

              // 实用技巧
              Column() {
                Text('💡 实用技巧')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                ForEach(this.selectedChallenge.tips, (tip: string, index: number) => {
                  Row() {
                    Text('💡')
                      .fontSize(14)
                      .margin({ right: 8 })

                    Text(tip)
                      .fontSize(14)
                      .fontColor('#666666')
                      .layoutWeight(1)
                      .lineHeight(20)
                  }
                  .width('100%')
                  .margin({ bottom: 8 })
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F0F8FF')
              .borderRadius(12)
              .margin({ bottom: 20 })
            }
            .width('100%')
          }
          .layoutWeight(1)
          .padding({ left: 20, right: 20 })
          .scrollBar(BarState.Off)

          // 底部操作按钮
          Row() {
            Button('关闭')
              .width('30%')
              .height(44)
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .borderRadius(22)
              .onClick(() => {
                this.showChallengeDetailDialog = false;
                this.selectedChallenge = null;
              })

            Blank()

            Button(this.selectedChallenge.progress > 0 ? '继续挑战' : '立即参与')
              .width('60%')
              .height(44)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor(this.selectedChallenge.progress > 0 ? '#FF9800' : '#4CAF50')
              .borderRadius(22)
              .onClick(() => {
                this.joinChallenge(this.selectedChallenge!);
                this.showChallengeDetailDialog = false;
                this.selectedChallenge = null;
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 20 })
          .backgroundColor('#FFFFFF')
          .border({
            width: { top: 1 },
            color: '#F0F0F0'
          })
        }
        .width('95%')
        .height('85%')
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .shadow({
          radius: 30,
          color: 'rgba(0,0,0,0.3)',
          offsetX: 0,
          offsetY: 15
        })
        .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1001)
    }
  }

  @Builder
  buildKnowledgeTab() {
    Column({ space: 12 }) {
      Text('健康知识')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)

      this.buildKnowledgeCard('🏃‍♂️ 运动健康', '科学运动，健康生活', '了解正确的运动方式和频率，让运动成为健康生活的一部分。', '#2196F3')
      this.buildKnowledgeCard('🥗 营养饮食', '均衡营养，合理搭配', '学习营养知识，掌握健康饮食的原则和技巧。', '#4CAF50')
      this.buildKnowledgeCard('😴 睡眠管理', '优质睡眠，精力充沛', '改善睡眠质量，建立良好的睡眠习惯。', '#9C27B0')
      this.buildKnowledgeCard('🧘‍♀️ 心理健康', '情绪管理，心理平衡', '关注心理健康，学会情绪调节和压力管理。', '#FF5722')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 20 })
    .backgroundColor('#F8F9FA')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildKnowledgeCard(title: string, subtitle: string, description: string, color: string) {
    Column() {
      Row() {
        Column() {
          Text(title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text(subtitle)
            .fontSize(14)
            .fontColor(color)
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('>')
          .fontSize(20)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text(description)
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.navigateToKnowledgeDetail(title);
    })
  }

  // 导航到健康知识详情页面
  navigateToKnowledgeDetail(title: string) {
    let knowledgeType = '';

    // 根据标题确定知识类型
    if (title.includes('运动健康')) {
      knowledgeType = 'exercise';
    } else if (title.includes('营养饮食')) {
      knowledgeType = 'nutrition';
    } else if (title.includes('睡眠管理')) {
      knowledgeType = 'sleep';
    } else if (title.includes('心理健康')) {
      knowledgeType = 'mental';
    }

    try {
      router.pushUrl({
        url: 'pages/three/pages/HealthKnowledgeDetailPage',
        params: {
          type: knowledgeType
        }
      });
    } catch (err) {
      console.error('Failed to navigate to knowledge detail:', err);
      JhProgressHUD.showText('页面跳转失败，请稍后重试');
    }
  }

  @Builder
  buildMyTab() {
    Column({ space: 12 }) {
      // 个人健康档案
      this.buildPersonalHealthProfile()

      // 我的动态
      this.buildMyPosts()

      // 我的挑战
      this.buildMyChallenges()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 20 })
    .backgroundColor('#F8F9FA')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildPersonalHealthProfile() {
    Column() {
      Row() {
        Row() {
          Text('李')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor('#4CAF50')
        }
        .margin({ right: 16 })

        Column() {
          Text('李逸飞')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text('健康达人 Lv.5')
            .fontSize(14)
            .fontColor('#4CAF50')
            .margin({ top: 4 })

          Text('连续打卡 15 天')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 健康统计
      Row() {
        this.buildStatItem('动态', '23')
        this.buildStatItem('关注', '156')
        this.buildStatItem('粉丝', '89')
        this.buildStatItem('积分', '2,340')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 3
    })
    .margin({ bottom: 0 })
  }

  @Builder
  buildStatItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Text(label)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildMyPosts() {
    Column() {
      Row() {
        Text('我的动态')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('查看全部 >')
          .fontSize(14)
          .fontColor('#4CAF50')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text('最近还没有发布动态，快来分享你的健康生活吧！')
        .fontSize(14)
        .fontColor('#999999')
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 20, bottom: 20 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 0 })
  }

  @Builder
  buildMyChallenges() {
    Column() {
      Row() {
        Text('我的挑战')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('查看全部 >')
          .fontSize(14)
          .fontColor('#4CAF50')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('🏃‍♂️')
          .fontSize(24)
          .margin({ right: 12 })

        Column() {
          Text('30天步行挑战')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text('进度: 15/30 天')
            .fontSize(12)
            .fontColor('#999999')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('50%')
          .fontSize(14)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F8F9FA')
      .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 0 })
  }

  // 获取动态类型图标
  getPostTypeIcon(type: HealthPostType): string {
    switch (type) {
      case HealthPostType.EXERCISE:
        return '🏃‍♂️'
      case HealthPostType.DIET:
        return '🥗'
      case HealthPostType.SLEEP:
        return '😴'
      case HealthPostType.MOOD:
        return '😊'
      case HealthPostType.CHALLENGE:
        return '🏆'
      case HealthPostType.KNOWLEDGE:
        return '📚'
      default:
        return '💚'
    }
  }

  // 加载健康数据
  loadHealthData() {
    // 模拟健康动态数据
    this.healthPosts = [
      new HealthPost(
        '1',
        '健康小达人',
        '',
        '健康达人',
        HealthPostType.EXERCISE,
        '今日运动打卡',
        '今天完成了5公里晨跑，感觉精神状态特别好！坚持运动真的能让人充满活力。',
        [],
        new HealthMetrics(8756, 420, 75, undefined, undefined),
        '2小时前',
        23,
        5,
        false,
        ['晨跑', '健康生活', '运动打卡']
      ),
      new HealthPost(
        '2',
        '营养师小王',
        '',
        '营养专家',
        HealthPostType.DIET,
        '健康饮食分享',
        '今天为大家分享一个营养均衡的早餐搭配：燕麦粥+水煮蛋+蔬菜沙拉，既美味又健康！',
        [],
        new HealthMetrics(undefined, 350, undefined, undefined, undefined),
        '4小时前',
        45,
        12,
        true,
        ['健康饮食', '营养搭配', '早餐']
      ),
      new HealthPost(
        '3',
        '睡眠专家',
        '',
        '睡眠顾问',
        HealthPostType.SLEEP,
        '优质睡眠心得',
        '分享一个改善睡眠质量的小技巧：睡前1小时不看手机，听听轻音乐，效果很不错！',
        [],
        new HealthMetrics(undefined, undefined, undefined, 8.5, undefined),
        '昨天',
        67,
        18,
        false,
        ['睡眠质量', '健康习惯', '生活技巧']
      )
    ]

    // 模拟健康挑战数据
    this.healthChallenges = [
      new HealthChallenge(
        '1',
        '30天步行挑战',
        '每天完成8000步，坚持30天',
        '通过30天的坚持步行，养成良好的运动习惯。每天8000步是世界卫生组织推荐的基础运动量，能够有效提高心肺功能，增强下肢肌肉力量，促进新陈代谢，帮助控制体重。这个挑战适合所有年龄段的人群，无需特殊装备，随时随地都可以进行。',
        '🚶‍♂️',
        1234,
        '30天',
        '500',
        50,
        '运动健康',
        '中等',
        [
          '提高心肺功能，增强体质',
          '促进血液循环，预防心血管疾病',
          '增强下肢肌肉力量和骨密度',
          '帮助控制体重，燃烧多余脂肪',
          '改善睡眠质量，缓解压力',
          '提升精神状态，增强自信心'
        ],
        [
          '每天步行8000步以上',
          '记录每日步数和运动时长',
          '选择不同路线，增加趣味性',
          '保持匀速步行，避免过度疲劳',
          '穿着舒适的运动鞋',
          '适当补充水分'
        ],
        [
          '可以分多次完成，如早中晚各走一段',
          '利用上下班时间步行，一举两得',
          '邀请朋友家人一起参与，互相监督',
          '使用计步器或手机APP记录进度',
          '选择风景优美的路线，享受过程',
          '雨天可在室内走楼梯或原地踏步'
        ],
        '2024-11-01',
        '2024-11-30'
      ),
      new HealthChallenge(
        '2',
        '健康饮食21天',
        '21天健康饮食习惯养成',
        '科学研究表明，21天是养成一个新习惯的最短周期。通过21天的健康饮食实践，帮助你建立科学的营养搭配观念，学会合理控制热量摄入，增加蔬菜水果的比例，减少高糖高脂食物，培养清淡饮食的习惯，为长期的健康生活奠定基础。',
        '🥗',
        856,
        '21天',
        '300',
        0,
        '营养饮食',
        '简单',
        [
          '建立科学的饮食结构和习惯',
          '控制体重，预防肥胖相关疾病',
          '提供充足营养，增强免疫力',
          '改善肠道健康，促进消化',
          '稳定血糖，预防糖尿病',
          '提升皮肤状态，延缓衰老'
        ],
        [
          '每餐包含蛋白质、碳水化合物、蔬菜',
          '每天摄入5-7份不同颜色的蔬果',
          '选择全谷物食品，减少精制糖',
          '控制油盐摄入，清淡饮食',
          '规律用餐，避免暴饮暴食',
          '每天饮水1500-2000ml'
        ],
        [
          '提前规划一周的菜谱，避免临时决定',
          '学习看食品营养标签，选择健康食品',
          '用小盘子盛饭，有助于控制食量',
          '细嚼慢咽，每口咀嚼20-30次',
          '饭前喝一杯水，增加饱腹感',
          '准备健康零食，如坚果、水果'
        ],
        '2024-11-01',
        '2024-11-21'
      ),
      new HealthChallenge(
        '3',
        '早睡早起挑战',
        '连续14天23:00前睡觉，7:00前起床',
        '现代人普遍存在睡眠不足和作息不规律的问题。通过14天的早睡早起挑战，帮助你重新调整生物钟，建立健康的睡眠模式。充足的睡眠是身体修复和大脑整理记忆的重要时间，规律的作息能显著提升生活质量和工作效率。',
        '😴',
        567,
        '14天',
        '200',
        25,
        '睡眠健康',
        '简单',
        [
          '调整生物钟，建立规律作息',
          '提高睡眠质量，增强记忆力',
          '增强免疫系统，预防疾病',
          '改善情绪状态，减少焦虑',
          '提升工作效率和专注力',
          '促进生长激素分泌，延缓衰老'
        ],
        [
          '每晚23:00前上床睡觉',
          '每天7:00前起床，不赖床',
          '保证7-8小时的睡眠时间',
          '睡前1小时不使用电子设备',
          '创造舒适的睡眠环境',
          '记录睡眠质量和起床感受'
        ],
        [
          '睡前2小时避免剧烈运动',
          '可以听轻柔音乐或冥想放松',
          '保持卧室温度在18-22度',
          '使用遮光窗帘，营造黑暗环境',
          '建立固定的睡前仪式',
          '周末也要保持相同的作息时间'
        ],
        '2024-11-01',
        '2024-11-14'
      )
    ]
  }

  // 发布动态弹窗
  @Builder
  buildPostDialog() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showPostDialog = false;
          this.resetPostForm();
        })

      // 弹窗内容
      Column() {
        // 弹窗标题
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#666666')
            .onClick(() => {
              this.showPostDialog = false;
              this.resetPostForm();
            })

          Blank()

          Text('发布动态')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Text('发布')
            .fontSize(16)
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.publishPost();
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: '#F0F0F0'
        })

        // 动态类型选择
        Column() {
          Text('选择动态类型')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 12 })

          Row() {
            ForEach(this.postTypes, (postType: PostTypeOption) => {
              Column() {
                Text(postType.icon)
                  .fontSize(24)
                  .margin({ bottom: 4 })

                Text(postType.name)
                  .fontSize(12)
                  .fontColor(this.selectedPostType === postType.type ? '#4CAF50' : '#666666')
              }
              .padding(8)
              .backgroundColor(this.selectedPostType === postType.type ? '#E8F5E8' : '#F8F9FA')
              .borderRadius(8)
              .border({
                width: this.selectedPostType === postType.type ? 2 : 1,
                color: this.selectedPostType === postType.type ? '#4CAF50' : '#E0E0E0'
              })
              .onClick(() => {
                this.selectedPostType = postType.type;
              })
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: '#F0F0F0'
        })

        // 标题输入
        Column() {
          Text('动态标题')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入动态标题（可选）', text: this.inputTitle })
            .width('100%')
            .height(40)
            .fontSize(14)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({
              width: 1,
              color: '#E0E0E0'
            })
            .onChange((value: string) => {
              this.inputTitle = value;
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: '#F0F0F0'
        })

        // 内容输入
        Column() {
          Text('动态内容')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          TextArea({ placeholder: '分享你的健康生活...', text: this.inputContent })
            .width('100%')
            .height(100)
            .fontSize(14)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({
              width: 1,
              color: '#E0E0E0'
            })
            .onChange((value: string) => {
              this.inputContent = value;
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .border({
          width: { bottom: 1 },
          color: '#F0F0F0'
        })

        // 标签输入
        Column() {
          Text('添加标签')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入标签，用空格分隔', text: this.inputTags })
            .width('100%')
            .height(40)
            .fontSize(14)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .border({
              width: 1,
              color: '#E0E0E0'
            })
            .onChange((value: string) => {
              this.inputTags = value;
            })

          Text('例如：运动 健康 打卡')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 20 })
      }
      .width('90%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({
        radius: 20,
        color: 'rgba(0,0,0,0.2)',
        offsetX: 0,
        offsetY: 10
      })
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  // 重置发布表单
  resetPostForm() {
    this.inputTitle = '';
    this.inputContent = '';
    this.inputTags = '';
    this.selectedPostType = HealthPostType.EXERCISE;
  }

  // 发布动态
  publishPost() {
    if (!this.inputContent.trim()) {
      JhProgressHUD.showText('请输入动态内容');
      return;
    }

    // 处理标签
    const tags = this.inputTags.trim() ? this.inputTags.trim().split(' ').filter((tag: string) => tag.length > 0) : [];

    // 创建新动态
    const newPost = new HealthPost(
      Date.now().toString(),
      '李逸飞', // 当前用户名
      '',
      '健康达人',
      this.selectedPostType,
      this.inputTitle.trim(),
      this.inputContent.trim(),
      [],
      new HealthMetrics(8756, 420, 72, 7.5, undefined), // 模拟当前健康数据
      '刚刚',
      0,
      0,
      false,
      tags
    );

    // 添加到动态列表顶部
    this.healthPosts.unshift(newPost);

    // 关闭弹窗并重置表单
    this.showPostDialog = false;
    this.resetPostForm();

    // 显示成功提示
    JhProgressHUD.showText('动态发布成功！');
  }

  // 切换动态点赞状态
  togglePostLike(post: HealthPost) {
    post.isLiked = !post.isLiked;
    post.likes += post.isLiked ? 1 : -1;
  }
}
