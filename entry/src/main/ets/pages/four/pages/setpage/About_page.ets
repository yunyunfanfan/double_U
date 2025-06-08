//设置中的"关于"页面
import { router } from '@kit.ArkUI'
import { BaseNavigation, JhTextList, ItemType, JhSetCell, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

@Entry
@Preview
@Component
export struct PointsPage {
  build() {
    Column() {
      BaseNavigation({ title: $r('app.string.about_title'), bgColor: Color.Transparent })

      Scroll() {
        Column({ space: 20 }) {
          Text($r('app.string.project_title'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a1a1a')
            .margin({ top: 20 })

          Text($r('app.string.runtime_environment'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('90%')
            .textAlign(TextAlign.Start)

          Text($r('app.string.runtime_details'))
            .width('90%')

          this.buildSection($r('app.string.core_goal'), $r('app.string.core_goal_content'))
          this.buildSection($r('app.string.watch_plugin'), $r('app.string.watch_plugin_content'))
          this.buildSection($r('app.string.ai_analysis'), $r('app.string.ai_analysis_content'))
          this.buildSection($r('app.string.family_ranking'), $r('app.string.family_ranking_content'))
          this.buildSection($r('app.string.goal_planning'), $r('app.string.goal_planning_content'))
          this.buildSection($r('app.string.family_interaction_about'), $r('app.string.family_interaction_content'))
          this.buildSection($r('app.string.extended_features'), $r('app.string.extended_features_content'))

          Text($r('app.string.data_security_about'))
            .width('90%')
            .fontColor('#666')
            .margin({ top: 30, bottom: 50 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  private buildSection(title: Resource, content: Resource) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('90%')
        .textAlign(TextAlign.Start)
        .fontColor('#2c3e50')

      Text(content)
        .fontSize(16)
        .width('90%')
        .textAlign(TextAlign.Start)
        .fontColor('#666')
        .padding(10)
        .backgroundColor('#f8f9fa')
        .borderRadius(8)
    }
    .width('100%')
    .margin({ top: 10 })
  }
}