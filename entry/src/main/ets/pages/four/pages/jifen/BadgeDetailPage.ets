import { router } from '@kit.ArkUI'

// 徽章类型
class Badge {
  id: number
  name: string
  icon: Resource
  description: string
  earned: boolean
  earnedDate: string
  progress: number
  
  constructor(id: number, name: string, icon: Resource, description: string, earned: boolean, earnedDate: string, progress: number) {
    this.id = id
    this.name = name
    this.icon = icon
    this.description = description
    this.earned = earned
    this.earnedDate = earnedDate
    this.progress = progress
  }
}

// 解锁步骤类型
class UnlockStep {
  title: string
  description: string
  completed: boolean
  
  constructor(title: string, description: string, completed: boolean) {
    this.title = title
    this.description = description
    this.completed = completed
  }
}

@Entry
@Component
export struct BadgeDetailPage {
  @State badge: Badge = new Badge(0, '', $r('app.media.icon'), '', false, '', 0)
  @State unlockSteps: UnlockStep[] = []
  
  aboutToAppear() {
    // 从路由参数获取徽章信息
    try {
      const badgeJson = router.getParams()['badge'] as string
      if (badgeJson) {
        const parsedBadge = JSON.parse(badgeJson)
        this.badge = new Badge(
          parsedBadge.id,
          parsedBadge.name,
          parsedBadge.icon,
          parsedBadge.description,
          parsedBadge.earned,
          parsedBadge.earnedDate,
          parsedBadge.progress
        )
        
        // 根据徽章ID创建解锁步骤
        this.createUnlockSteps()
      }
    } catch (error) {
      console.error('解析徽章数据出错:', error)
    }
  }
  
  // 根据徽章ID创建解锁步骤
  createUnlockSteps() {
    switch (this.badge.id) {
      case 1: // 健康达人
        this.unlockSteps = [
          new UnlockStep('每日完成健康目标', '包括步数、睡眠、饮水量等健康指标达标', true),
          new UnlockStep('连续10天达标', '已完成10天的健康指标达标', true),
          new UnlockStep('连续20天达标', '已完成20天的健康指标达标', true),
          new UnlockStep('连续30天达标', '已完成全部30天的健康指标达标', true)
        ]
        break
      case 2: // 运动先锋
        this.unlockSteps = [
          new UnlockStep('累计运动25小时', '已完成超过25小时的运动', true),
          new UnlockStep('累计运动50小时', '已完成超过50小时的运动', true),
          new UnlockStep('累计运动75小时', '已完成超过75小时的运动', true),
          new UnlockStep('累计运动100小时', '已完成超过100小时的运动', true)
        ]
        break
      case 3: // 早睡早起
        this.unlockSteps = [
          new UnlockStep('连续7天按时睡觉和起床', '每晚11点前睡觉，每天7点前起床', true),
          new UnlockStep('连续14天按时睡觉和起床', '保持健康作息两周', true),
          new UnlockStep('连续21天按时睡觉和起床', '形成健康作息习惯', false),
          new UnlockStep('睡眠质量评分达到80分以上', '睡眠质量保持良好水平', true)
        ]
        break
      case 4: // 饮水健将
        this.unlockSteps = [
          new UnlockStep('每日饮水量达标', '每天饮水1500ml以上', true),
          new UnlockStep('连续5天饮水达标', '已完成5天的饮水目标', true),
          new UnlockStep('连续10天饮水达标', '已完成10天的饮水目标', true),
          new UnlockStep('连续15天饮水达标', '已完成15天的饮水目标', false)
        ]
        break
      case 5: // 步行冠军
        this.unlockSteps = [
          new UnlockStep('单日步数超过10,000步', '完成基础步行目标', true),
          new UnlockStep('单日步数超过15,000步', '完成进阶步行目标', true),
          new UnlockStep('单日步数超过20,000步', '完成高级步行目标', true),
          new UnlockStep('一周内3天达到15,000步以上', '保持良好的步行习惯', true)
        ]
        break
      default:
        this.unlockSteps = [
          new UnlockStep('完成基础目标', '达成徽章的基础要求', this.badge.progress >= 25),
          new UnlockStep('完成进阶目标', '达成徽章的进阶要求', this.badge.progress >= 50),
          new UnlockStep('完成高级目标', '达成徽章的高级要求', this.badge.progress >= 75),
          new UnlockStep('完成终极目标', '达成徽章的全部要求', this.badge.progress >= 100)
        ]
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Stack({ alignContent: Alignment.Center }) {
        Text('徽章详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)

        Button('返回')
          .margin({ left: 15 })
          .onClick(() => router.back())
          .position({ x: 0, y: 0 })
      }
      .width('100%')
      .height(50)
      .backgroundColor('#ff93d4cb')

      Scroll() {
        Column() {
          // 徽章信息卡片
          Column() {
            Image(this.badge.icon)
              .width(120)
              .height(120)
              .margin({ top: 30, bottom: 20 })
              .opacity(this.badge.earned ? 1 : 0.5)
            
            Text(this.badge.name)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 10 })
            
            Text(this.badge.description)
              .fontSize(16)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 15 })
            
            if (this.badge.earned) {
              Text(`获得时间: ${this.badge.earnedDate}`)
                .fontSize(14)
                .fontColor('#34A853')
                .margin({ bottom: 20 })
            } else {
              Column() {
                Text(`完成进度: ${this.badge.progress}%`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 5 })
                
                Progress({ value: this.badge.progress, total: 100 })
                  .width('80%')
                  .height(10)
                  .color('#4285F4')
              }
              .margin({ bottom: 20 })
            }
            
            Text(this.badge.earned ? '已获得' : '未获得')
              .fontSize(16)
              .fontColor(this.badge.earned ? '#34A853' : '#EA4335')
              .fontWeight(FontWeight.Bold)
              .backgroundColor(this.badge.earned ? '#E8F5E9' : '#FFEBEE')
              .borderRadius(15)
              .padding({ left: 15, right: 15, top: 5, bottom: 5 })
          }
          .width('90%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(15)
          .margin({ top: 20, bottom: 20 })
          .alignItems(HorizontalAlign.Center)
          
          // 解锁条件
          Column() {
            Text('解锁条件')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
              .alignSelf(FlexAlign.Start)
            
            ForEach(this.unlockSteps, (step: UnlockStep, index: number) => {
              Row() {
                Column() {
                  Circle({ width: 25, height: 25 })
                    .fill(step.completed ? '#34A853' : '#E0E0E0')
                    .visibility(step.completed ? Visibility.Visible : Visibility.Hidden)
                  
                  Circle({ width: 25, height: 25 })
                    .stroke('#E0E0E0')
                    .strokeWidth(2)
                    .fill('transparent')
                    .visibility(step.completed ? Visibility.Hidden : Visibility.Visible)
                }
                .width(25)
                .height(25)
                .margin({ right: 15 })
                
                Column() {
                  Text(step.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(step.completed ? '#333333' : '#999999')
                  
                  Text(step.description)
                    .fontSize(14)
                    .fontColor(step.completed ? '#666666' : '#999999')
                    .margin({ top: 5 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .padding({ top: 10, bottom: 10 })
              .border({
                width: { bottom: index < this.unlockSteps.length - 1 ? 1 : 0 },
                color: '#E0E0E0',
                style: BorderStyle.Solid
              })
            })
          }
          .width('90%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(15)
          .margin({ bottom: 20 })
          
          // 获取建议
          Column() {
            Text('如何获得')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
              .alignSelf(FlexAlign.Start)
            
            Text('完成以下行动可以更快获得此徽章：')
              .fontSize(16)
              .fontColor('#333333')
              .margin({ bottom: 15 })
              .width('100%')
            
            if (this.badge.id === 1) { // 健康达人
              this.tipItem('每天查看健康数据，并完成健康目标')
              this.tipItem('设置提醒，确保每日完成饮水、步行等基础健康任务')
              this.tipItem('在应用中记录您的健康数据，保持连续性')
            } else if (this.badge.id === 3) { // 早睡早起
              this.tipItem('设置固定的睡眠和起床时间')
              this.tipItem('睡前一小时避免使用电子设备')
              this.tipItem('建立放松的睡前习惯，如阅读或冥想')
              this.tipItem('保持卧室安静、黑暗和凉爽')
            } else if (this.badge.id === 4) { // 饮水健将
              this.tipItem('设置饮水提醒，每小时喝一杯水')
              this.tipItem('随身携带水杯，方便随时饮水')
              this.tipItem('使用应用内的饮水追踪功能记录每日饮水量')
            } else {
              this.tipItem('坚持完成与徽章相关的健康任务')
              this.tipItem('使用应用内的提醒功能，确保不会遗漏任务')
              this.tipItem('查看相关健康数据，了解进度和不足')
              this.tipItem('加入健康社区，获取更多支持和鼓励')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(15)
          .margin({ bottom: 30 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  @Builder
  tipItem(content: string) {
    Row() {
      Image($r('app.media.icon'))
        .width(20)
        .height(20)
        .margin({ right: 10 })
      
      Text(content)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 10 })
  }
} 