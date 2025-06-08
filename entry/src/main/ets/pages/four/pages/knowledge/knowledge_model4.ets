import { router } from '@kit.ArkUI'
import { BaseNavigation, JhTextList, ItemType, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

interface NutritionData {
  label: Resource
  value: string
  color: string
}

interface RecommendationItem {
  icon: string
  content: Resource
  amount: Resource
}

@Entry
@Preview
@Component
export struct NutritionPage {
  build() {
    Column() {
      BaseNavigation({ title: $r('app.string.nutrition_management_title'), bgColor: Color.Transparent })

      Scroll() {
        Column({ space: 20 }) {
          this.BuildIntakeSection()
          this.BuildRecommendationSection()
          this.BuildNutritionKnowledge()
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
      Text($r('app.string.nutrition_management_title'))
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
  private BuildIntakeSection() {
    Column({ space: 10 }) {
      Text($r('app.string.today_intake'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Row({ space: 30 }) {
        this.BuildNutritionItem($r('app.string.protein_label'), '68g', '#e67e22')
        this.BuildNutritionItem($r('app.string.fiber_label'), '22g', '#2ecc71')
        this.BuildNutritionItem($r('app.string.vitamin_c_label'), '89mg', '#3498db')
      }
      .padding(15)
      .backgroundColor('#f8f9fa')
      .borderRadius(8)
    }
  }

  @Builder
  private BuildNutritionItem(label: Resource, value: string, color: string) {
    Column() {
      Text(label)
        .fontColor(color)
        .fontWeight(FontWeight.Medium)
      Text(value)
        .fontSize(18)
        .fontColor('#666')
    }
    .padding(8)
  }

  @Builder
  private BuildRecommendationSection() {
    Column({ space: 10 }) {
      Text($r('app.string.diet_suggestions'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Column() {
        this.BuildRecommendationCard('🥬', $r('app.string.increase_vegetables'), $r('app.string.vegetables_amount'), '#e8f6f3')
        this.BuildRecommendationCard('🚫', $r('app.string.reduce_fried'), $r('app.string.fried_frequency'), '#f9f2e9')
        this.BuildRecommendationCard('💧', $r('app.string.water_target'), $r('app.string.water_amount'), '#ebf5fb')
      }
    }
  }

  @Builder
  private BuildRecommendationCard(icon: string, title: Resource, amount: Resource, bgColor: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(24)
          .margin({ right: 10 })
        Text(title)
          .fontSize(16)
      }
      .margin({ bottom: 5 })

      Text(amount)
        .fontSize(14)
        .fontColor('#666')
    }
    .padding(10)
    .backgroundColor(bgColor)
    .borderRadius(8)
    .width('100%')
    .margin({ bottom: 8 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private BuildNutritionKnowledge() {
    Column({ space: 15 }) {
      Text($r('app.string.nutrition_guide'))
        .fontSize(20)
        .fontColor('#2c3e50')
        .fontWeight(FontWeight.Bold)

      this.BuildKnowledgeCard(
        $r('app.string.diet_balance'),
        [
          $r('app.string.carbs_ratio'),
          $r('app.string.protein_ratio'),
          $r('app.string.fat_ratio'),
          $r('app.string.daily_fruits')
        ],
        '#e8f6f3'
      )

      this.BuildKnowledgeCard(
        $r('app.string.meal_schedule'),
        [
          $r('app.string.three_meals'),
          $r('app.string.meal_distribution'),
          $r('app.string.after_meal_walk'),
          $r('app.string.no_late_eating')
        ],
        '#f9f2e9'
      )

      this.BuildKnowledgeCard(
        $r('app.string.nutrition_calculation'),
        [
          $r('app.string.calcium_intake'),
          $r('app.string.fiber_intake'),
          $r('app.string.salt_limit'),
          $r('app.string.sugar_limit')
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