import { router } from '@kit.ArkUI'
import { BaseNavigation, JhTextList, ItemType, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

interface AssessmentItem {
  title: Resource
  value: string
  color: string
}

interface ActivityItem {
  icon: string
  content: Resource
}

@Entry
@Preview
@Component
export struct MentalHealthPage {
  build() {
    Column() {
      BaseNavigation({ title: $r('app.string.mental_health_title'), bgColor: Color.Transparent })

      Scroll() {
        Column({ space: 20 }) {
          this.BuildAssessmentSection()
          this.BuildActivitySection()
          this.BuildMentalHealthKnowledge()
        }
        .padding(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  private BuildNavigationBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('心理健康')
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
  private BuildAssessmentSection() {
    Column({ space: 10 }) {
      Text($r('app.string.today_assessment'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Column() {
        this.BuildAssessmentItem($r('app.string.stress_index'), '62/100', '#3498db')
        this.BuildAssessmentItem($r('app.string.sleep_quality'), '★★★☆☆', '#9b59b6')
        this.BuildAssessmentItem($r('app.string.mood_stability'), '78/100', '#e74c3c')
      }
      .padding(10)
      .backgroundColor('#f8f9fa')
      .borderRadius(8)
    }
  }

  @Builder
  private BuildAssessmentItem(label: Resource, value: string, color: string) {
    Row() {
      Text(label)
        .fontColor('#666')
      Text(value)
        .fontColor(color)
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(8)
  }

  @Builder
  private BuildActivitySection() {
    Column({ space: 10 }) {
      Text($r('app.string.suggested_activities'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Column() {
        this.BuildActivityCard('🌬️', $r('app.string.breathing_content'), '#e8f6f3')
        this.BuildActivityCard('💬', $r('app.string.family_content'), '#f9f2e9')
        this.BuildActivityCard('📝', $r('app.string.diary_content'), '#ebf5fb')
      }
    }
  }

  @Builder
  private BuildActivityCard(icon: string, content: Resource, bgColor: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 10 })

      Text(content)
        .fontSize(16)
    }
    .padding(10)
    .backgroundColor(bgColor)
    .borderRadius(8)
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  private BuildMentalHealthKnowledge() {
    Column({ space: 15 }) {
      Text($r('app.string.mental_health_guide'))
        .fontSize(20)
        .fontColor('#2c3e50')
        .fontWeight(FontWeight.Bold)

      this.BuildKnowledgeCard(
        $r('app.string.stress_management'),
        [
          $r('app.string.daily_meditation'),
          $r('app.string.regular_schedule'),
          $r('app.string.digital_detox'),
          $r('app.string.quality_sleep_zzz')
        ],
        '#e8f6f3'
      )

      this.BuildKnowledgeCard(
        $r('app.string.emotion_regulation'),
        [
          $r('app.string.abc_diary'),
          $r('app.string.art_therapy'),
          $r('app.string.exercise_endorphin'),
          $r('app.string.nature_contact')
        ],
        '#f9f2e9'
      )

      this.BuildKnowledgeCard(
        $r('app.string.family_interaction_title'),
        [
          $r('app.string.daily_communication'),
          $r('app.string.weekly_game_night'),
          $r('app.string.family_reading'),
          $r('app.string.support_commitment')
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