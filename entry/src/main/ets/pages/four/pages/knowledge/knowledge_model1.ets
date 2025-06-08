import { router } from '@kit.ArkUI'
import { BaseNavigation,  KColors } from 'JhCommon'
import { JhTextList, ItemType, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

interface DataItem {
  label: Resource
  value: string
  color: string
}


interface ResourceContent {
  content: Resource
}

type SectionContent = ResourceContent | DataItem

@Entry
@Preview
@Component
export struct ChronicDiseasePage {
  build() {
    Column() {
      BaseNavigation({ title: $r('app.string.chronic_disease_management'), bgColor: Color.Transparent })

      Scroll() {
        Column({ space: 20 }) {
          this.BuildSection(
            $r('app.string.core_functions'),
            [
              { content: $r('app.string.three_high_monitoring') },
              { content: $r('app.string.medication_reminder') },
              { content: $r('app.string.risk_prediction') }
            ],
            '#f8f9fa'
          )

          this.BuildSection(
            $r('app.string.weekly_data'),
            [
              { label: $r('app.string.blood_pressure_fluctuation'), value: '+5%', color: '#e74c3c' },
              { label: $r('app.string.medication_compliance'), value: '92%', color: '#2ecc71' }
            ]
          )

          this.BuildHealthKnowledge()
        }
        .padding(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private isDataItem(item: SectionContent): boolean {
    return (item as DataItem).label !== undefined
  }
  @Builder
  private BuildNavigationBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('慢性病管理')
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
  }

  @Builder
  private BuildSection(
    title: Resource,
    content: SectionContent[],
    bgColor?: string
  ) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Column() {
        ForEach(content, (item: SectionContent, index: number) => {
          if (this.isDataItem(item)) {
            this.BuildDataRow(item as DataItem)
          } else {
            Text((item as ResourceContent).content)
              .fontSize(16)
              .padding(8)
          }
        })
      }
      .padding(10)
      .backgroundColor(bgColor || 'transparent')
      .borderRadius(8)
      .width('100%')
    }
  }

  @Builder
  private BuildDataRow(item: DataItem) {
    Row() {
      Text(item.label)
        .fontColor('#666')
      Text(item.value)
        .fontColor(item.color)
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding(8)
  }

  @Builder
  private BuildHealthKnowledge() {
    Column({ space: 15 }) {
      Text($r('app.string.health_guide'))
        .fontSize(20)
        .fontColor('#2c3e50')
        .fontWeight(FontWeight.Bold)

      this.BuildKnowledgeCard(
        $r('app.string.diet_management'),
        [
          $r('app.string.daily_vegetables'),
          $r('app.string.weekly_fish'),
          $r('app.string.salt_control'),
          $r('app.string.daily_water')
        ],
        '#e8f6f3'
      )

      this.BuildKnowledgeCard(
        $r('app.string.exercise_plan'),
        [
          $r('app.string.weekly_exercise'),
          $r('app.string.hourly_activity'),
          $r('app.string.taichi_yoga'),
          $r('app.string.heart_rate_formula')
        ],
        '#f9f2e9'
      )

      this.BuildKnowledgeCard(
        $r('app.string.home_monitoring'),
        [
          $r('app.string.blood_pressure_timing'),
          $r('app.string.blood_sugar_method'),
          $r('app.string.monthly_chart'),
          $r('app.string.doctor_alert')
        ],
        '#ebf5fb'
      )
    }
    .padding(15)
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .shadow({ radius: 6, color: '#20000000' })
  }

  @Builder
  private BuildKnowledgeCard(
    title: Resource,
    tips: Resource[],
    color: string
  ) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(18)
        .fontColor('#2980b9')
        .margin({ bottom: 5 })

      Column() {
        ForEach(tips, (tip: Resource, index: number) => {
          Text(tip)
            .fontSize(16)
            .padding(8)
            .width('100%')
            .backgroundColor(color)
            .borderRadius(6)
            .margin({ bottom: 5 })
        })
      }
    }
    .width('100%')
    .padding(10)
  }
}