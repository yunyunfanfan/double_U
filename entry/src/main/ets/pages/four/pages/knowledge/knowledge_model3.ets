import { router } from '@kit.ArkUI'
import { BaseNavigation, JhTextList, ItemType, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

interface ExerciseData {
  value: string | number
  unit: Resource
  color?: string
}

@Entry
@Preview
@Component
export struct ExercisePage {
  build() {
    Column() {
      BaseNavigation({ title: $r('app.string.exercise_health_title'), bgColor: Color.Transparent })

      Scroll() {
        Column({ space: 20 }) {
          this.BuildTodayExercise()
          this.BuildProgressSection()
          this.BuildExerciseKnowledge()
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
      Text($r('app.string.exercise_health_title'))
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
  private BuildTodayExercise() {
    Column({ space: 10 }) {
      Text($r('app.string.today_exercise'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Row({ space: 30 }) {
        this.BuildDataItem('8560', $r('app.string.steps_unit'), '#2ecc71')
        this.BuildDataItem('420', $r('app.string.calories_unit'), '#e67e22')
        this.BuildDataItem('45', $r('app.string.minutes_unit'), '#3498db')
      }
      .padding(15)
      .backgroundColor('#f8f9fa')
      .borderRadius(8)
    }
  }

  @Builder
  private BuildDataItem(value: string | number, unit: Resource, color: string) {
    Column() {
      Text(value.toString())
        .fontSize(24)
        .fontColor(color)
      Text(unit)
        .fontColor('#666')
    }
    .padding(8)
  }

  @Builder
  private BuildProgressSection() {
    Column({ space: 10 }) {
      Text($r('app.string.goal_progress'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Progress({ value: 75, total: 100 })
        .width('80%')
        .color('#2ecc71')
        .margin({ top: 10 })

      Row()
        .justifyContent(FlexAlign.SpaceBetween)
        .width('80%')
        .margin({ top: 5 })
    }
  }

  @Builder
  private BuildExerciseKnowledge() {
    Column({ space: 15 }) {
      Text($r('app.string.exercise_guide'))
        .fontSize(20)
        .fontColor('#2c3e50')
        .fontWeight(FontWeight.Bold)

      this.BuildKnowledgeCard(
        $r('app.string.exercise_safety'),
        [
          $r('app.string.warmup_tip'),
          $r('app.string.hydration_tip'),
          $r('app.string.heart_rate_tip'),
          $r('app.string.stop_tip')
        ],
        '#e8f6f3'
      )

      this.BuildKnowledgeCard(
        $r('app.string.scientific_training'),
        [
          $r('app.string.aerobic_frequency'),
          $r('app.string.strength_training'),
          $r('app.string.intensity_increase'),
          $r('app.string.exercise_variety')
        ],
        '#f9f2e9'
      )

      this.BuildKnowledgeCard(
        $r('app.string.recovery_strategy'),
        [
          $r('app.string.quality_sleep'),
          $r('app.string.shower_therapy'),
          $r('app.string.protein_intake'),
          $r('app.string.rest_day')
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