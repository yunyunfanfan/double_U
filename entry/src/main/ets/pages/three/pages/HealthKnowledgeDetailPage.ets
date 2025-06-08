
///  description: 健康知识详情页面

import { router } from '@kit.ArkUI';
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'

enum KnowledgeType {
  EXERCISE = 'exercise',
  NUTRITION = 'nutrition',
  SLEEP = 'sleep',
  MENTAL = 'mental'
}

class KnowledgeContent {
  title: string
  subtitle: string
  icon: string
  color: string
  sections: KnowledgeSection[]
  tips: string[]

  constructor(title: string, subtitle: string, icon: string, color: string, sections: KnowledgeSection[], tips: string[]) {
    this.title = title
    this.subtitle = subtitle
    this.icon = icon
    this.color = color
    this.sections = sections
    this.tips = tips
  }
}

class KnowledgeSection {
  title: string
  content: string

  constructor(title: string, content: string) {
    this.title = title
    this.content = content
  }
}

@Entry
@Component
struct HealthKnowledgeDetailPage {
  @State knowledgeType: KnowledgeType = KnowledgeType.EXERCISE
  @State knowledgeContent: KnowledgeContent | null = null

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>
    if (params && params['type']) {
      this.knowledgeType = params['type'] as KnowledgeType
    }
    this.loadKnowledgeContent()
  }

  build() {
    Column() {
      this.buildNavigationBar()

      if (this.knowledgeContent) {
        this.buildContentArea()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
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
        router.back()
      })
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .margin({ left: 10 })

      Text(this.knowledgeContent?.title || getContext(this).resourceManager.getStringSync($r('app.string.health_knowledge')))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Row()
        .width(40)
        .height(40)
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
  buildContentArea() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildHeaderCard()

        ForEach(this.knowledgeContent!.sections, (section: KnowledgeSection) => {
          this.buildSectionCard(section)
        })

        this.buildTipsCard()
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 20 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildHeaderCard() {
    Column() {
      Row() {
        Text(this.knowledgeContent!.icon)
          .fontSize(48)
          .margin({ right: 20 })

        Column() {
          Text(this.knowledgeContent!.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text(this.knowledgeContent!.subtitle)
            .fontSize(16)
            .fontColor(this.knowledgeContent!.color)
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
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
  buildSectionCard(section: KnowledgeSection) {
    Column() {
      Text(section.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 12 })

      Text(section.content)
        .fontSize(15)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)
        .lineHeight(24)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTipsCard() {
    Column() {
      Row() {
        Text('💡')
          .fontSize(20)
          .margin({ right: 8 })

        Text(getContext(this).resourceManager.getStringSync($r('app.string.practical_tips_knowledge')))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 16 })

      ForEach(this.knowledgeContent!.tips, (tip: string, index: number) => {
        Row() {
          Text(`${index + 1}.`)
            .fontSize(14)
            .fontColor(this.knowledgeContent!.color)
            .fontWeight(FontWeight.Bold)
            .margin({ right: 8 })
            .width(20)

          Text(tip)
            .fontSize(14)
            .fontColor('#666666')
            .layoutWeight(1)
            .lineHeight(20)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ bottom: 8 })
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .alignItems(HorizontalAlign.Start)
  }

  loadKnowledgeContent() {
    switch (this.knowledgeType) {
      case KnowledgeType.EXERCISE:
        this.knowledgeContent = new KnowledgeContent(
          getContext(this).resourceManager.getStringSync($r('app.string.exercise_health_knowledge')),
          getContext(this).resourceManager.getStringSync($r('app.string.exercise_subtitle')),
          '🏃‍♂️',
          '#2196F3',
          [
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.exercise_importance_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.exercise_importance_content'))
            ),
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.exercise_types_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.exercise_types_content'))
            ),
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.exercise_safety_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.exercise_safety_content'))
            )
          ],
          [
            getContext(this).resourceManager.getStringSync($r('app.string.exercise_tip1')),
            getContext(this).resourceManager.getStringSync($r('app.string.exercise_tip2')),
            getContext(this).resourceManager.getStringSync($r('app.string.exercise_tip3')),
            getContext(this).resourceManager.getStringSync($r('app.string.exercise_tip4')),
            getContext(this).resourceManager.getStringSync($r('app.string.exercise_tip5')),
            getContext(this).resourceManager.getStringSync($r('app.string.exercise_tip6'))
          ]
        )
        break

      case KnowledgeType.NUTRITION:
        this.knowledgeContent = new KnowledgeContent(
          getContext(this).resourceManager.getStringSync($r('app.string.nutrition_diet_knowledge')),
          getContext(this).resourceManager.getStringSync($r('app.string.nutrition_subtitle')),
          '🥗',
          '#4CAF50',
          [
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.nutrition_importance_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.nutrition_importance_content'))
            ),
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.nutrition_nutrients_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.nutrition_nutrients_content'))
            ),
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.nutrition_principles_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.nutrition_principles_content'))
            )
          ],
          [
            getContext(this).resourceManager.getStringSync($r('app.string.nutrition_tip1')),
            getContext(this).resourceManager.getStringSync($r('app.string.nutrition_tip2')),
            getContext(this).resourceManager.getStringSync($r('app.string.nutrition_tip3')),
            getContext(this).resourceManager.getStringSync($r('app.string.nutrition_tip4')),
            getContext(this).resourceManager.getStringSync($r('app.string.nutrition_tip5')),
            getContext(this).resourceManager.getStringSync($r('app.string.nutrition_tip6'))
          ]
        )
        break

      case KnowledgeType.SLEEP:
        this.knowledgeContent = new KnowledgeContent(
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_management_knowledge')),
          getContext(this).resourceManager.getStringSync($r('app.string.sleep_subtitle')),
          '😴',
          '#9C27B0',
          [
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.sleep_importance_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.sleep_importance_content'))
            ),
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.sleep_cycle_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.sleep_cycle_content'))
            ),
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.sleep_improvement_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.sleep_improvement_content'))
            )
          ],
          [
            getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip1')),
            getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip2')),
            getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip3')),
            getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip4')),
            getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip5')),
            getContext(this).resourceManager.getStringSync($r('app.string.sleep_tip6'))
          ]
        )
        break

      case KnowledgeType.MENTAL:
        this.knowledgeContent = new KnowledgeContent(
          getContext(this).resourceManager.getStringSync($r('app.string.mental_health_knowledge')),
          getContext(this).resourceManager.getStringSync($r('app.string.mental_subtitle')),
          '🧘‍♀️',
          '#FF5722',
          [
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.mental_importance_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.mental_importance_content'))
            ),
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.mental_emotion_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.mental_emotion_content'))
            ),
            new KnowledgeSection(
              getContext(this).resourceManager.getStringSync($r('app.string.mental_stress_title')),
              getContext(this).resourceManager.getStringSync($r('app.string.mental_stress_content'))
            )
          ],
          [
            getContext(this).resourceManager.getStringSync($r('app.string.mental_tip1')),
            getContext(this).resourceManager.getStringSync($r('app.string.mental_tip2')),
            getContext(this).resourceManager.getStringSync($r('app.string.mental_tip3')),
            getContext(this).resourceManager.getStringSync($r('app.string.mental_tip4')),
            getContext(this).resourceManager.getStringSync($r('app.string.mental_tip5')),
            getContext(this).resourceManager.getStringSync($r('app.string.mental_tip6'))
          ]
        )
        break
    }
  }
}