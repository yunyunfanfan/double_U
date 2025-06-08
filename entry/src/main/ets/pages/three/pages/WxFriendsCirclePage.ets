
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
  @State postTypes: PostTypeOption[] = []
  scroller: Scroller = new Scroller()

  aboutToAppear() {
    this.initPostTypes()
    this.loadHealthData()
  }

  initPostTypes() {
    this.postTypes = [
      { type: HealthPostType.EXERCISE, name: getContext(this).resourceManager.getStringSync($r('app.string.post_type_exercise')), icon: '🏃‍♂️' },
      { type: HealthPostType.DIET, name: getContext(this).resourceManager.getStringSync($r('app.string.post_type_diet')), icon: '🥗' },
      { type: HealthPostType.SLEEP, name: getContext(this).resourceManager.getStringSync($r('app.string.post_type_sleep')), icon: '😴' },
      { type: HealthPostType.MOOD, name: getContext(this).resourceManager.getStringSync($r('app.string.post_type_mood')), icon: '😊' },
      { type: HealthPostType.CHALLENGE, name: getContext(this).resourceManager.getStringSync($r('app.string.post_type_challenge')), icon: '🏆' },
      { type: HealthPostType.KNOWLEDGE, name: getContext(this).resourceManager.getStringSync($r('app.string.post_type_knowledge')), icon: '📚' }
    ]
  }

  build() {
    Stack() {
      Column() {
        this.buildNavigationBar()
        this.buildTabBar()
        this.buildContentArea()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F9FA')

      if (this.showPostDialog) {
        this.buildPostDialog()
      }

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
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_back'))
          .width(20)
          .height(20)
      }
      .onClick(() => {
        try {
          router.back();
        } catch (err) {
          router.pushUrl({ url: 'pages/three/pages/WxDiscoverPage' });
        }
      })
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .margin({ left: 10 })

      Text($r('app.string.health_circle_title'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button({ type: ButtonType.Circle }) {
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
      Column() {
        Text($r('app.string.tab_dynamics'))
          .fontSize(16)
          .fontColor(this.selectedTab === 0 ? '#4CAF50' : '#666666')
          .fontWeight(this.selectedTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .padding({ top: 12, bottom: 8 })

        if (this.selectedTab === 0) {
          Divider()
            .width(30)
            .height(3)
            .color('#4CAF50')
            .borderRadius(2)
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        this.selectedTab = 0;
      })

      Column() {
        Text($r('app.string.tab_challenges'))
          .fontSize(16)
          .fontColor(this.selectedTab === 1 ? '#4CAF50' : '#666666')
          .fontWeight(this.selectedTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .padding({ top: 12, bottom: 8 })

        if (this.selectedTab === 1) {
          Divider()
            .width(30)
            .height(3)
            .color('#4CAF50')
            .borderRadius(2)
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        this.selectedTab = 1;
      })

      Column() {
        Text($r('app.string.tab_knowledge'))
          .fontSize(16)
          .fontColor(this.selectedTab === 2 ? '#4CAF50' : '#666666')
          .fontWeight(this.selectedTab === 2 ? FontWeight.Bold : FontWeight.Normal)
          .padding({ top: 12, bottom: 8 })

        if (this.selectedTab === 2) {
          Divider()
            .width(30)
            .height(3)
            .color('#4CAF50')
            .borderRadius(2)
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        this.selectedTab = 2;
      })

      Column() {
        Text($r('app.string.tab_mine'))
          .fontSize(16)
          .fontColor(this.selectedTab === 3 ? '#4CAF50' : '#666666')
          .fontWeight(this.selectedTab === 3 ? FontWeight.Bold : FontWeight.Normal)
          .padding({ top: 12, bottom: 8 })

        if (this.selectedTab === 3) {
          Divider()
            .width(30)
            .height(3)
            .color('#4CAF50')
            .borderRadius(2)
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        this.selectedTab = 3;
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
  //这是第一页的构建函数
  buildHealthPostsTab() {
    Scroll(this.scroller) {
      Column({ space: 12 }) {
        this.buildTodayHealthOverview()

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
        Text($r('app.string.today_health_overview'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text($r('app.string.view_details'))
          .fontSize(14)
          .fontColor('#4CAF50')
          .onClick(() => {
            JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.health_data_developing')));
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row({ space: 12 }) {
        this.buildMetricCard(getContext(this).resourceManager.getStringSync($r('app.string.steps_label')), '8,756', getContext(this).resourceManager.getStringSync($r('app.string.steps')), '#2196F3', '🚶‍♂️')
        this.buildMetricCard(getContext(this).resourceManager.getStringSync($r('app.string.calories_label')), '2,345', 'Kcal', '#FF9800', '🔥')
        this.buildMetricCard(getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_label')), '72', 'bpm', '#E91E63', '❤️')
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

        if (post.healthData) {
          this.buildPostHealthData(post.healthData)
        }

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

        Text($r('app.string.share_btn'))
          .fontSize(14)
          .fontColor('#4CAF50')
          .onClick(() => {
            JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.share_feature_developing')));
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
        Text($r('app.string.health_challenges_title'))
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

            Text(this.getDifficultyText(challenge.difficulty))
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

      Row() {
        Column() {
          Text(challenge.participants.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')

          Text($r('app.string.participants_count'))
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(challenge.duration)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')

          Text($r('app.string.challenge_duration'))
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(challenge.reward)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E91E63')

          Text($r('app.string.reward_points'))
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(`${challenge.progress}%`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2196F3')

          Text($r('app.string.my_progress'))
            .fontSize(11)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 16 })

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

      if (challenge.benefits.length > 0) {
        Column() {
          Text($r('app.string.main_benefits'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          ForEach(challenge.benefits.slice(0, 3), (benefit: string) => {
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

      Row() {
        Button() {
          Text($r('app.string.view_details_btn'))
            .fontSize(14)
            .fontColor('#4CAF50')
        }
        .width('45%')
        .height(36)
        .backgroundColor('#E8F5E8')
        .borderRadius(18)
        .onClick(() => {
          this.selectedChallenge = challenge;
          this.showChallengeDetailDialog = true;
        })

        Blank()

        Button() {
          Text(challenge.progress > 0 ? $r('app.string.continue_challenge') : $r('app.string.join_challenge'))
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .width('45%')
        .height(36)
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

  getDifficultyColor(difficulty: string): string {
    if (difficulty === getContext(this).resourceManager.getStringSync($r('app.string.difficulty_easy'))) {
      return '#4CAF50'
    } else if (difficulty === getContext(this).resourceManager.getStringSync($r('app.string.difficulty_medium'))) {
      return '#FF9800'
    } else if (difficulty === getContext(this).resourceManager.getStringSync($r('app.string.difficulty_hard'))) {
      return '#F44336'
    }
    return '#9E9E9E'
  }

  getDifficultyText(originalDifficulty: string): Resource {
    switch (originalDifficulty) {
      case '简单':
        return $r('app.string.difficulty_easy')
      case '中等':
        return $r('app.string.difficulty_medium')
      case '困难':
        return $r('app.string.difficulty_hard')
      default:
        return $r('app.string.difficulty_medium')
    }
  }

  joinChallenge(challenge: HealthChallenge) {
    if (challenge.progress > 0) {
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.continue_progress_msg')).replace('%s', `${challenge.progress}%`));
    } else {
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.join_success_msg')).replace('%s', challenge.title));
      challenge.participants += 1;
    }
  }

  @Builder
  buildChallengeDetailDialog() {
    if (this.selectedChallenge) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => {
            this.showChallengeDetailDialog = false;
            this.selectedChallenge = null;
          })

        Column() {
          Row() {
            Text($r('app.string.challenge_details'))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Blank()

            Button({ type: ButtonType.Circle }) {
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

          Scroll() {
            Column() {
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

                    Text(this.getDifficultyText(this.selectedChallenge.difficulty))
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

              Column() {
                Text($r('app.string.challenge_intro'))
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

              Column() {
                Text($r('app.string.challenge_time'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                Row() {
                  Column() {
                    Text($r('app.string.start_time'))
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
                    Text($r('app.string.end_time'))
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
                    Text($r('app.string.duration'))
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

              Column() {
                Text($r('app.string.health_benefits'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                ForEach(this.selectedChallenge.benefits, (benefit: string) => {
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

              Column() {
                Text($r('app.string.daily_goals'))
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

              Column() {
                Text($r('app.string.practical_tips'))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ bottom: 12 })

                ForEach(this.selectedChallenge.tips, (tip: string) => {
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

          Row() {
            Button() {
              Text($r('app.string.close_btn'))
                .fontSize(16)
                .fontColor('#666666')
            }
            .width('30%')
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(() => {
              this.showChallengeDetailDialog = false;
              this.selectedChallenge = null;
            })

            Blank()

            Button() {
              Text(this.selectedChallenge.progress > 0 ? $r('app.string.continue_challenge') : $r('app.string.join_now'))
                .fontSize(16)
                .fontColor('#FFFFFF')
            }
            .width('60%')
            .height(44)
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
      Text($r('app.string.health_knowledge'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)

      this.buildKnowledgeCard(getContext(this).resourceManager.getStringSync($r('app.string.exercise_health')), getContext(this).resourceManager.getStringSync($r('app.string.scientific_exercise')), getContext(this).resourceManager.getStringSync($r('app.string.exercise_health_desc')), '#2196F3')
      this.buildKnowledgeCard(getContext(this).resourceManager.getStringSync($r('app.string.nutrition_diet')), getContext(this).resourceManager.getStringSync($r('app.string.balanced_nutrition')), getContext(this).resourceManager.getStringSync($r('app.string.nutrition_diet_desc')), '#4CAF50')
      this.buildKnowledgeCard(getContext(this).resourceManager.getStringSync($r('app.string.sleep_management')), getContext(this).resourceManager.getStringSync($r('app.string.quality_sleep_full')), getContext(this).resourceManager.getStringSync($r('app.string.sleep_management_desc')), '#9C27B0')
      this.buildKnowledgeCard(getContext(this).resourceManager.getStringSync($r('app.string.mental_health')), getContext(this).resourceManager.getStringSync($r('app.string.emotional_balance')), getContext(this).resourceManager.getStringSync($r('app.string.mental_health_desc')), '#FF5722')
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

  navigateToKnowledgeDetail(title: string) {
    let knowledgeType = 'exercise';

    const exerciseText = getContext(this).resourceManager.getStringSync($r('app.string.exercise_health'));
    const nutritionText = getContext(this).resourceManager.getStringSync($r('app.string.nutrition_diet'));
    const sleepText = getContext(this).resourceManager.getStringSync($r('app.string.sleep_management'));
    const mentalText = getContext(this).resourceManager.getStringSync($r('app.string.mental_health'));

    if (title.includes(exerciseText) || title.includes('运动健康')) {
      knowledgeType = 'exercise';
    } else if (title.includes(nutritionText) || title.includes('营养饮食')) {
      knowledgeType = 'nutrition';
    } else if (title.includes(sleepText) || title.includes('睡眠管理')) {
      knowledgeType = 'sleep';
    } else if (title.includes(mentalText) || title.includes('心理健康')) {
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
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.nav_failed_retry')));
    }
  }

  @Builder
  buildMyTab() {
    Column({ space: 12 }) {
      this.buildPersonalHealthProfile()
      this.buildMyPosts()
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
          Text(getContext(this).resourceManager.getStringSync($r('app.string.user_name_sample')).substring(0, 1))
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
          Text($r('app.string.user_name_sample'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text($r('app.string.health_expert_level'))
            .fontSize(14)
            .fontColor('#4CAF50')
            .margin({ top: 4 })

          Text($r('app.string.consecutive_checkin'))
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row() {
        this.buildStatItem(getContext(this).resourceManager.getStringSync($r('app.string.posts_count')), '23')
        this.buildStatItem(getContext(this).resourceManager.getStringSync($r('app.string.following_count')), '156')
        this.buildStatItem(getContext(this).resourceManager.getStringSync($r('app.string.followers_count')), '89')
        this.buildStatItem(getContext(this).resourceManager.getStringSync($r('app.string.points_count')), '2,340')
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
        Text($r('app.string.my_dynamics'))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text($r('app.string.view_all_ex'))
          .fontSize(14)
          .fontColor('#4CAF50')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text($r('app.string.no_recent_posts'))
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
        Text($r('app.string.my_challenges'))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text($r('app.string.view_all_ex'))
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
          Text($r('app.string.walking_challenge_30days'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text($r('app.string.progress_days'))
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

  loadHealthData() {
    this.healthPosts = [
      new HealthPost(
        '1',
        getContext(this).resourceManager.getStringSync($r('app.string.health_expert_name')),
        '',
        getContext(this).resourceManager.getStringSync($r('app.string.health_expert_title')),
        HealthPostType.EXERCISE,
        getContext(this).resourceManager.getStringSync($r('app.string.today_exercise_checkin')),
        getContext(this).resourceManager.getStringSync($r('app.string.exercise_post_content')),
        [],
        new HealthMetrics(8756, 420, 75, undefined, undefined),
        getContext(this).resourceManager.getStringSync($r('app.string.hours_ago_2')),
        23,
        5,
        false,
        [getContext(this).resourceManager.getStringSync($r('app.string.tag_morning_run')), getContext(this).resourceManager.getStringSync($r('app.string.tag_healthy_life')), getContext(this).resourceManager.getStringSync($r('app.string.tag_exercise_checkin'))]
      ),
      new HealthPost(
        '2',
        getContext(this).resourceManager.getStringSync($r('app.string.nutritionist_name')),
        '',
        getContext(this).resourceManager.getStringSync($r('app.string.nutrition_expert_title')),
        HealthPostType.DIET,
        getContext(this).resourceManager.getStringSync($r('app.string.healthy_diet_share')),
        getContext(this).resourceManager.getStringSync($r('app.string.diet_post_content')),
        [],
        new HealthMetrics(undefined, 350, undefined, undefined, undefined),
        getContext(this).resourceManager.getStringSync($r('app.string.hours_ago_4')),
        45,
        12,
        true,
        [getContext(this).resourceManager.getStringSync($r('app.string.tag_healthy_diet')), getContext(this).resourceManager.getStringSync($r('app.string.tag_nutrition_match')), getContext(this).resourceManager.getStringSync($r('app.string.tag_breakfast'))]
      ),
      new HealthPost(
        '3',
        getContext(this).resourceManager.getStringSync($r('app.string.sleep_expert_name')),
        '',
        getContext(this).resourceManager.getStringSync($r('app.string.sleep_consultant_title')),
        HealthPostType.SLEEP,
        getContext(this).resourceManager.getStringSync($r('app.string.quality_sleep_tips')),
        getContext(this).resourceManager.getStringSync($r('app.string.sleep_post_content')),
        [],
        new HealthMetrics(undefined, undefined, undefined, 8.5, undefined),
        getContext(this).resourceManager.getStringSync($r('app.string.yesterday')),
        67,
        18,
        false,
        [getContext(this).resourceManager.getStringSync($r('app.string.tag_sleep_quality')), getContext(this).resourceManager.getStringSync($r('app.string.tag_healthy_habits')), getContext(this).resourceManager.getStringSync($r('app.string.tag_life_tips'))]
      )
    ]

    this.healthChallenges = [
      new HealthChallenge(
        '1',
        getContext(this).resourceManager.getStringSync($r('app.string.walking_challenge_30days')),
        getContext(this).resourceManager.getStringSync($r('app.string.walking_challenge_desc')),
        getContext(this).resourceManager.getStringSync($r('app.string.walking_challenge_detail')),
        '🚶‍♂️',
        1234,
        getContext(this).resourceManager.getStringSync($r('app.string.duration_30days')),
        '500',
        50,
        getContext(this).resourceManager.getStringSync($r('app.string.category_exercise_health')),
        getContext(this).resourceManager.getStringSync($r('app.string.difficulty_medium')),
        [
          getContext(this).resourceManager.getStringSync($r('app.string.benefit_cardio')),
          getContext(this).resourceManager.getStringSync($r('app.string.benefit_circulation')),
          getContext(this).resourceManager.getStringSync($r('app.string.benefit_muscle_strength')),
          getContext(this).resourceManager.getStringSync($r('app.string.benefit_weight_control')),
          getContext(this).resourceManager.getStringSync($r('app.string.benefit_sleep_quality')),
          getContext(this).resourceManager.getStringSync($r('app.string.benefit_mental_state'))
        ],
        [
          getContext(this).resourceManager.getStringSync($r('app.string.goal_daily_steps')),
          getContext(this).resourceManager.getStringSync($r('app.string.goal_record_data')),
          getContext(this).resourceManager.getStringSync($r('app.string.goal_different_routes')),
          getContext(this).resourceManager.getStringSync($r('app.string.goal_steady_pace')),
          getContext(this).resourceManager.getStringSync($r('app.string.goal_comfortable_shoes')),
          getContext(this).resourceManager.getStringSync($r('app.string.goal_hydration'))
        ],
        [
          getContext(this).resourceManager.getStringSync($r('app.string.tip_multiple_sessions')),
          getContext(this).resourceManager.getStringSync($r('app.string.tip_commute_walking')),
          getContext(this).resourceManager.getStringSync($r('app.string.tip_invite_friends')),
          getContext(this).resourceManager.getStringSync($r('app.string.tip_use_apps')),
          getContext(this).resourceManager.getStringSync($r('app.string.tip_scenic_routes')),
          getContext(this).resourceManager.getStringSync($r('app.string.tip_indoor_alternatives'))
        ],
        '2024-11-01',
        '2024-11-30'
      ),
      new HealthChallenge(
        '2',
        getContext(this).resourceManager.getStringSync($r('app.string.healthy_diet_21days')),
        getContext(this).resourceManager.getStringSync($r('app.string.diet_challenge_desc')),
        getContext(this).resourceManager.getStringSync($r('app.string.diet_challenge_detail')),
        '🥗',
        856,
        getContext(this).resourceManager.getStringSync($r('app.string.duration_21days')),
        '300',
        0,
        getContext(this).resourceManager.getStringSync($r('app.string.category_nutrition_diet')),
        getContext(this).resourceManager.getStringSync($r('app.string.difficulty_easy')),
        [
          getContext(this).resourceManager.getStringSync($r('app.string.diet_benefit_structure')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_benefit_weight')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_benefit_nutrition')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_benefit_digestion')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_benefit_blood_sugar')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_benefit_skin'))
        ],
        [
          getContext(this).resourceManager.getStringSync($r('app.string.diet_goal_balanced_meals')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_goal_vegetables_fruits')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_goal_whole_grains')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_goal_low_salt_oil')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_goal_regular_meals')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_goal_hydration'))
        ],
        [
          getContext(this).resourceManager.getStringSync($r('app.string.diet_tip_plan_ahead')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_tip_read_labels')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_tip_small_plates')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_tip_chew_slowly')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_tip_water_before_meals')),
          getContext(this).resourceManager.getStringSync($r('app.string.diet_tip_healthy_snacks'))
        ],
        '2024-11-01',
        '2024-11-21'
      ),
      new HealthChallenge(
        '3',
        getContext(this).resourceManager.getStringSync($r('app.string.early_sleep_challenge')),
        getContext(this).resourceManager.getStringSync($r('app.string.sleep_challenge_desc')),
        getContext(this).resourceManager.getStringSync($r('app.string.sleep_challenge_detail')),
        '😴',
        567,
        getContext(this).resourceManager.getStringSync($r('app.string.duration_14days')),
        '200',
        25,
        getContext(this).resourceManager.getStringSync($r('app.string.category_sleep_health')),
        getContext(this).resourceManager.getStringSync($r('app.string.difficulty_easy')),
        [
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_benefit_circadian')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_benefit_memory')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_benefit_immunity')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_benefit_mood')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_benefit_productivity')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_benefit_growth_hormone'))
        ],
        [
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_goal_bedtime')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_goal_wake_time')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_goal_duration')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_goal_no_devices')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_goal_environment')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_goal_record_quality'))
        ],
        [
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip_no_exercise')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip_relaxing_music')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip_temperature')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip_blackout_curtains')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip_bedtime_routine')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip_weekend_consistency'))
        ],
        '2024-11-01',
        '2024-11-14'
      )
    ]
  }

  @Builder
  //这是创建新的挑战的渲染函数
  buildPostDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showPostDialog = false;
          this.resetPostForm();
        })

      Column() {
        Row() {
          Text($r('app.string.cancel_btn'))
            .fontSize(16)
            .fontColor('#666666')
            .onClick(() => {
              this.showPostDialog = false;
              this.resetPostForm();
            })

          Blank()

          Text($r('app.string.publish_post'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Text($r('app.string.publish_btn'))
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

        Column() {
          Text($r('app.string.select_post_type'))
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
                  .minFontSize(5)
                  .maxFontSize(14)
                  .fontColor(this.selectedPostType === postType.type ? '#4CAF50' : '#666666')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
              .width('15%')
              .height(70)
              .padding(6)
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

        Column() {
          Text($r('app.string.post_title'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.title_placeholder')), text: this.inputTitle })
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

        Column() {
          Text($r('app.string.post_content'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          TextArea({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.content_placeholder')), text: this.inputContent })
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

        Column() {
          Text($r('app.string.add_tags'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.tags_placeholder')), text: this.inputTags })
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

          Text($r('app.string.tags_example'))
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

  resetPostForm() {
    this.inputTitle = '';
    this.inputContent = '';
    this.inputTags = '';
    this.selectedPostType = HealthPostType.EXERCISE;
  }

  publishPost() {
    if (!this.inputContent.trim()) {
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.input_content_required')));
      return;
    }

    const tags = this.inputTags.trim() ? this.inputTags.trim().split(' ').filter((tag: string) => tag.length > 0) : [];

    const newPost = new HealthPost(
      Date.now().toString(),
      getContext(this).resourceManager.getStringSync($r('app.string.user_name_sample')),
      '',
      getContext(this).resourceManager.getStringSync($r('app.string.health_expert_level')),
      this.selectedPostType,
      this.inputTitle.trim(),
      this.inputContent.trim(),
      [],
      new HealthMetrics(8756, 420, 72, 7.5, undefined),
      getContext(this).resourceManager.getStringSync($r('app.string.just_now')),
      0,
      0,
      false,
      tags
    );

    this.healthPosts.unshift(newPost);
    this.showPostDialog = false;
    this.resetPostForm();
    JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.publish_success')));
  }

  togglePostLike(post: HealthPost) {
    post.isLiked = !post.isLiked;
    post.likes += post.isLiked ? 1 : -1;
  }
}