import { BaseNavigation, KColors, JhProgressHUD } from 'JhCommon'
import { router } from '@kit.ArkUI'
import { EnergyFactorsPage } from './EnergyFactorsPage'

//精力助手

interface EnergyTip {
  id: string;
  titleKey: string;    // 改为资源key
  descriptionKey: string;  // 改为资源key
  icon: string;
}

interface EnergyActivity {
  id: string;
  nameKey: string;     // 改为资源key
  effect: 'positive' | 'negative';
  icon: string;
}

@Entry
@Component
export struct EnergyAssistantPage {
  @State currentEnergyLevel: number = 75;
  @State lastLoggedTime: string = "今天 09:00";

  // 图标资源映射
  private iconMap: Record<string, Resource> = {
    'energy_level': $r('app.media.energy_level'),
    'water_icon': $r('app.media.water_icon'),
    'sleep_icon': $r('app.media.sleep_icon'),
    'exercise_icon': $r('app.media.exercise_icon'),
    'food_icon': $r('app.media.food_icon'),
    'meditation_icon': $r('app.media.meditation_icon'),
    'walk_icon': $r('app.media.walk_icon')
  }

  private energyTips: EnergyTip[] = [
    { id: 'tip1', titleKey: 'keep_hydrated', descriptionKey: 'hydration_desc', icon: 'water_icon' },
    { id: 'tip2', titleKey: 'regular_sleep', descriptionKey: 'sleep_desc', icon: 'sleep_icon' },
    { id: 'tip3', titleKey: 'moderate_exercise', descriptionKey: 'exercise_desc', icon: 'exercise_icon' },
    { id: 'tip4', titleKey: 'healthy_diet', descriptionKey: 'diet_desc', icon: 'food_icon' },
  ];

  private energyActivities: EnergyActivity[] = [
    { id: 'act1', nameKey: 'meditation_10min', effect: 'positive', icon: 'meditation_icon' },
    { id: 'act2', nameKey: 'afternoon_walk', effect: 'positive', icon: 'walk_icon' },
    { id: 'act3', nameKey: 'long_screen_time', effect: 'negative', icon: 'exercise_icon' },
    { id: 'act4', nameKey: 'sugary_drinks', effect: 'negative', icon: 'water_icon' },
  ];

  private scrollerForYou: Scroller = new Scroller()

  build() {
    Column() {
      BaseNavigation({
        title: $r('app.string.energy_assistant'),
        bgColor: KColors.kCellBgColor,
        leftItemCallBack: () => {
          router.back()
        }
      })

      Scroll(this.scrollerForYou) {
        Column() {
          // 精力值卡片
          this.buildEnergyCard()

          // 精力影响因素
          this.buildEnergyFactorsCard()

          // 今日建议
          this.buildRecommendationsCard()

          // 其他功能卡片
          this.buildOtherFeaturesCard()

          Blank()
            .height(50)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  buildEnergyCard() {
    Column() {
      Row() {
        Column() {
          Text($r('app.string.current_energy_level'))
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          Row() {
            Text('85')
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Text('/100')
              .fontSize(16)
              .fontColor('#999999')
              .alignSelf(ItemAlign.End)
              .margin({ bottom: 6, left: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image($r('app.media.energy_bar'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)
      }

      Row() {
        Text($r('app.string.status'))
          .fontSize(14)
          .fontColor('#666666')

        Text($r('app.string.status_good'))
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
      }
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ top: 16 })
  }

  @Builder
  buildEnergyFactorsCard() {
    Column() {
      // 标题栏
      Row() {
        Text($r('app.string.energy_factors'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()
          .layoutWeight(1)

        Button() {
          Text($r('app.string.view_all'))
            .fontSize(14)
            .fontColor('#666666')
        }
        .backgroundColor('transparent')
        .onClick(() => {
          try {
            router.pushUrl({
              url: 'pages/four/pages/energy_assistant/EnergyFactorsPage'
            }, (err) => {
              if (err) {
                AlertDialog.show({
                  title: $r('app.string.navigation_failed'),
                  message: $r('app.string.navigation_error_message') + err.message,
                  autoCancel: true,
                  alignment: DialogAlignment.Center,
                  confirm: {
                    value: $r('app.string.i_know'),
                    action: () => {
                      console.error(`页面跳转失败: ${JSON.stringify(err)}`)
                    }
                  }
                })
              }
            })
          } catch (error) {
            console.error(`路由跳转异常: ${error}`)
            AlertDialog.show({
              title: $r('app.string.operation_exception'),
              message: $r('app.string.operation_error_message'),
              autoCancel: true,
              alignment: DialogAlignment.Center,
              confirm: {
                value: $r('app.string.confirm'),
                action: () => {}
              }
            })
          }
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 影响因素列表
      Column() {
        this.buildFactorItem($r('app.string.meditation_10min'), $r('app.media.ic_meditation_icon'), '#8A6CFF', true)
        this.buildFactorItem($r('app.string.afternoon_walk'), $r('app.media.ic_walk_icon'), '#4CAEFF', true)
        this.buildFactorItem($r('app.string.long_screen_time'), $r('app.media.ic_no_phone'), '#FF6A6A', false)
        this.buildFactorItem($r('app.string.sugary_drinks'), $r('app.media.ic_sugar_drink_icon'), '#FF8C69', false)
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding(4)
    }
    .width('100%')
    .margin({ top: 24 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/four/pages/energy_assistant/EnergyFactorsPage'
      })
    })
  }

  @Builder
  buildFactorItem(title: Resource, icon: Resource, color: string, isPositive: boolean) {
    Row() {
      // 图标
      Row() {
        Image(icon)
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .backgroundColor(color + '20')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })

      // 标题
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)

      // 标签
      Text(isPositive ? $r('app.string.beneficial') : $r('app.string.consuming'))
        .fontSize(12)
        .fontColor(isPositive ? '#4CAF50' : '#F44336')
        .backgroundColor(isPositive ? '#E8F5E9' : '#FFEBEE')
        .borderRadius(10)
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .borderRadius(12)
  }

  @Builder
  buildRecommendationsCard() {
    Column() {
      // 标题栏
      Row() {
        Text($r('app.string.today_recommendations'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 建议内容
      Column() {
        this.buildRecommendationItem($r('app.string.recommendation_meditation'), $r('app.media.ic_meditation_icon'))
        this.buildRecommendationItem($r('app.string.recommendation_screen_break'), $r('app.media.ic_no_phone'))
        this.buildRecommendationItem($r('app.string.recommendation_water'), $r('app.media.ic_sugar_drink_icon'))
      }
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding(4)
    }
    .width('100%')
    .margin({ top: 24 })
  }

  @Builder
  buildRecommendationItem(text: Resource, icon: Resource) {
    Row() {
      // 图标
      Image(icon)
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)
        .margin({ right: 12 })

      // 文本
      Text(text)
        .fontSize(15)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .borderRadius(12)
  }

  @Builder
  buildOtherFeaturesCard() {
    Column() {
      // 标题栏
      Row() {
        Text($r('app.string.features'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 功能网格
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        this.buildFeatureItem($r('app.string.energy_statistics'), $r('app.media.ic_chart_icon'), '#5E97F6')
        this.buildFeatureItem($r('app.string.habit_formation'), $r('app.media.ic_habit'), '#9C56B8')
        this.buildFeatureItem($r('app.string.sleep_assistant'), $r('app.media.ic_bed'), '#4DB6AC')
        this.buildFeatureItem($r('app.string.more'), $r('app.media.ic_more'), '#78909C')
      }
    }
    .width('100%')
    .margin({ top: 24 })
  }

  @Builder
  buildFeatureItem(title: Resource, icon: Resource, color: string) {
    Column() {
      // 图标
      Row() {
        Image(icon)
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor(color + '20')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      // 标题
      Text(title)
        .fontSize(14)
        .fontColor('#333333')
    }
    .width('23%')
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Center)
  }
}