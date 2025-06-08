import { BaseNavigation, KColors } from 'JhCommon'
import { router } from '@kit.ArkUI'

// Create proper interface instead of using object literals
interface EnergyFactor {
  titleKey: string,  // 改为资源key
  icon: Resource,
  color: string,
  descriptionKey: string  // 改为资源key
}

@Entry
@Component
export struct EnergyFactorsPage {
  @State goodFactors: EnergyFactor[] = [
    {
      titleKey: 'meditation_title',
      icon: $r('app.media.ic_meditation_icon'),
      color: '#8A6CFF',
      descriptionKey: 'meditation_desc'
    },
    {
      titleKey: 'afternoon_walk_title',
      icon: $r('app.media.ic_walk_icon'),
      color: '#4CAEFF',
      descriptionKey: 'afternoon_walk_desc'
    },
    {
      titleKey: 'good_sleep_title',
      icon: $r('app.media.ic_bed'),
      color: '#6C8AFF',
      descriptionKey: 'good_sleep_desc'
    },
    {
      titleKey: 'healthy_eating_title',
      icon: $r('app.media.food_icon'),
      color: '#52CB8F',
      descriptionKey: 'healthy_eating_desc'
    }
  ]

  @State badFactors: EnergyFactor[] = [
    {
      titleKey: 'long_screen_time_title',
      icon: $r('app.media.ic_no_phone'),
      color: '#FF6A6A',
      descriptionKey: 'long_screen_time_desc'
    },
    {
      titleKey: 'sugary_drinks_title',
      icon: $r('app.media.ic_sugar_drink_icon'),
      color: '#FF8C69',
      descriptionKey: 'sugary_drinks_desc'
    },
    {
      titleKey: 'sedentary_lifestyle_title',
      icon: $r('app.media.ic_sitting'),
      color: '#FF7B54',
      descriptionKey: 'sedentary_lifestyle_desc'
    }
  ]

  @State showFactorDetails: boolean = false
  @State selectedFactor: EnergyFactor | null = null

  build() {
    Column() {
      BaseNavigation({
        title: $r('app.string.energy_factors_title'),
        bgColor: Color.White,
        leftItemCallBack: () => {
          router.back()
        }
      })

      Scroll() {
        Column() {
          // 顶部摘要
          this.buildSummarySection()

          // 有益因素
          this.buildSectionTitle($r('app.string.energy_boosting_habits'), '#4CAF50')
          this.buildFactorGrid(this.goodFactors, true)

          // 消耗因素
          this.buildSectionTitle($r('app.string.energy_draining_habits'), '#F44336')
          this.buildFactorGrid(this.badFactors, false)

          // 底部提示
          Text($r('app.string.more_features_coming'))
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 40, bottom: 20 })

          // 底部空间
          Blank()
            .height(50)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 详情弹窗
      if (this.showFactorDetails && this.selectedFactor) {
        this.buildDetailPanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  buildSummarySection() {
    Column() {
      Row() {
        Image($r('app.media.energy_level'))
          .width(60)
          .height(60)
          .margin({ right: 16 })

        Column() {
          Text($r('app.string.energy_most_precious_resource'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 4 })

          Text($r('app.string.understand_energy_factors_desc'))
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(16)
      .borderRadius(16)
      .backgroundColor(Color.White)
      .margin({ top: 16, bottom: 24 })
    }
  }

  @Builder
  buildSectionTitle(title: Resource, color: string) {
    Row() {
      Divider()
        .width(4)
        .height(20)
        .backgroundColor(color)
        .margin({ right: 8 })

      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ top: 16, bottom: 12 })
  }

  @Builder
  buildFactorGrid(factors: EnergyFactor[], isPositive: boolean) {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(factors, (factor: EnergyFactor) => {
        Column() {
          // 图标
          Row() {
            Image(factor.icon)
              .width(28)
              .height(28)
              .objectFit(ImageFit.Contain)
          }
          .width(56)
          .height(56)
          .borderRadius(28)
          .backgroundColor(factor.color + '20') // 20% opacity
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 12 })

          // 标题
          Text($r(`app.string.${factor.titleKey}`))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ bottom: 4 })

          // 标签
          Text(isPositive ? $r('app.string.beneficial') : $r('app.string.consuming'))
            .fontSize(12)
            .fontColor(isPositive ? '#4CAF50' : '#F44336')
            .backgroundColor(isPositive ? '#E8F5E9' : '#FFEBEE')
            .borderRadius(10)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        }
        .width('47%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({ bottom: 16 })
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.selectedFactor = factor
          this.showFactorDetails = true
        })
      })
    }
    .width('100%')
  }

  @Builder
  buildDetailPanel() {
    Column() {
      if (this.selectedFactor) {
        Row() {
          Text($r(`app.string.${this.selectedFactor.titleKey}`))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)

          Button() {
            Image($r('app.media.ic_close_black'))
              .width(24)
              .height(24)
          }
          .backgroundColor('transparent')
          .type(ButtonType.Circle)
          .onClick(() => {
            this.showFactorDetails = false
          })
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })

        Row() {
          Image(this.selectedFactor.icon)
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain)
        }
        .width(80)
        .height(80)
        .borderRadius(40)
        .backgroundColor(this.selectedFactor.color + '20')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 16 })

        Text($r(`app.string.${this.selectedFactor.descriptionKey}`))
          .fontSize(16)
          .fontColor('#333333')
          .margin({ bottom: 24 })
          .textAlign(TextAlign.Center)

        Button($r('app.string.learn_more'))
          .width('80%')
          .height(48)
          .borderRadius(24)
          .backgroundColor(this.selectedFactor.color)
          .fontColor(Color.White)
          .fontSize(16)
      }
    }
    .width('100%')
    .height('40%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 })
    .padding({ left: 24, right: 24 })
    .position({ x: 0, y: '60%' })
    .alignItems(HorizontalAlign.Center)
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }
}