import { router } from '@kit.ArkUI';


//积分说明页面

@Entry
@Component
export struct PointsExplainPage {
  build() {
    Column() {
      // 自定义导航栏（高度44vp，标准导航栏高度）
      Row() {
        Image($r('app.media.ic_back'))
          .onClick(() => router.back())
          .width(24)
          .height(24)
          .margin({ left: 12 })

        Text($r('app.string.points_explanation'))
          .fontSize(18)
          .margin({ left: 16 })
          .fontColor('#333333')
      }
      .width('100%')
      .height(44)
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)

      // 主内容区（直接紧贴导航栏）
      Scroll() {
        Column() {
          // 标题（移除顶部padding，直接紧贴）
          Text($r('app.string.points_rules_title'))
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Start)
            .padding({ left: 16, top: 0, bottom: 8 }) // 顶部padding设为0

          // 规则列表
          Column() {
            this.buildRuleItem('1', $r('app.string.daily_health_score'), $r('app.string.daily_health_score_desc'))
            this.buildRuleItem('2', $r('app.string.score_limit'), $r('app.string.score_limit_desc'))
            this.buildRuleItem('3', $r('app.string.points_usage'), $r('app.string.points_usage_desc'))
            this.buildRuleItem('4', $r('app.string.interval_explanation'), $r('app.string.interval_explanation_desc'))
            this.buildRuleItem('5', $r('app.string.special_note'), $r('app.string.special_note_desc'))
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .margin({ top: 0 }) // 确保没有上边距
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildRuleItem(index: string, title: Resource, content: Resource) {
    Column() {
      // 序号+标题行
      Row() {
        Text(index + '.')
          .fontSize(16)
          .fontColor('#07C160')
          .margin({ right: 8 })

        Text(title)
          .fontSize(16)
          .fontColor('#333333')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 内容行
      Text(content)
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ top: 4, bottom: 12 })
        .padding({ left: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}