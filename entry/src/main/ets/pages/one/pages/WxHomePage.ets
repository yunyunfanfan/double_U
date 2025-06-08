///这是主页

import { promptAction, router } from '@kit.ArkUI'
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxHomeModel } from '../models/WxHomeModel'
import { WxHomeCell } from '../widgets/WxHomeCell'
//

@Entry
@Preview
@Component
export struct WxHomePage {
  @State dataArr: WxHomeModel[] = []
  scroller: ListScroller = new ListScroller()

  aboutToAppear() {
    this.dataArr = this.getData()
    // console.error('data', JSON.stringify(this.dataArr))
  }

  build() {
    Column() {
      BaseNavigation({
        title: getContext(this).resourceManager.getStringSync($r('app.string.energy_assistant_title_847392615738294629384751952847392615')),
        leftItem: {},
        bgColor: Color.Transparent,
        rightImgPath: $rawfile("images/第一页加号.png"),
        rightItemCallBack: () => {
          console.log('点击了右侧图标')
          this.onClickRightItem()
        },
      })
      this.body()
    }
    //.backgroundColor(KColors.wxBgColor)
    //这个是主页标志性的蓝色
  }

  @Builder
  body() {
    List({ scroller: this.scroller }) {
      ForEach(this.dataArr, (item: WxHomeModel, index: number) => {
        ListItem() {
          WxHomeCell({
            model: item,
            onClickCell: () => {
              this.clickCell(item)
            },
          })
        }
        //禁用第一页的滑动效果
        // .swipeAction({
        //   end: {
        //     builder: () => {
        //       this.itemSwipeEnd(item.type)
        //     },
        //     actionAreaDistance: 0, // 设置组件长距离滑动删除距离阈值。 默认56
        //     onAction: () => {
        //       animateTo({ duration: 1000 }, () => {
        //       })
        //     },
        //   }
        // })
      })
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
    .divider({
      strokeWidth: 0.5,
      startMargin: 70,
      endMargin: 0,
      color: KColors.kLineColor
    })
  }

  @Builder
  itemSwipeEnd(type: string) {
    if (type == '0') {
      Row()
    }
    if (type == '1') {
      Row() {
        Text(getContext(this).resourceManager.getStringSync($r('app.string.delete_text_629384751952847847392615738294751629384751952847')))
          .fontSize(14)
          .fontWeight(400)
          .fontColor(Color.White)
      }
      .width('25%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast(getContext(this).resourceManager.getStringSync($r('app.string.delete_text_629384751952847847392615738294751629384751952847')))
        this.scroller.closeAllSwipeActions()
      })
    }
    if (type == '2') {
      Row() {
        Row() {
          Text(getContext(this).resourceManager.getStringSync($r('app.string.mark_unread_text_847392615738294184759362847392847392615738294')))
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#74736D')
        .onClick(() => {
          JhProgressHUD.showToast(getContext(this).resourceManager.getStringSync($r('app.string.mark_unread_text_847392615738294184759362847392847392615738294')))
          this.scroller.closeAllSwipeActions()
        })

        Row() {
          Text(getContext(this).resourceManager.getStringSync($r('app.string.delete_text_629384751952847847392615738294751629384751952847')))
            .fontSize(14)
            .fontWeight(400)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.Red)
        .onClick(() => {
          JhProgressHUD.showToast(getContext(this).resourceManager.getStringSync($r('app.string.delete_text_629384751952847847392615738294751629384751952847')))
          this.scroller.closeAllSwipeActions()
        })
      }
      .width('50%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast(getContext(this).resourceManager.getStringSync($r('app.string.delete_text_629384751952847847392615738294751629384751952847')))
        this.scroller.closeAllSwipeActions()
      })
    }
    if (type == '3') {
      Row() {
        Row() {
          Text(getContext(this).resourceManager.getStringSync($r('app.string.unfollow_text_573829461847392847392615738294751629384751952847')))
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#74736D')
        .onClick(() => {
          JhProgressHUD.showToast(getContext(this).resourceManager.getStringSync($r('app.string.unfollow_text_573829461847392847392615738294751629384751952847')))
          this.scroller.closeAllSwipeActions()
        })

        Row() {
          Text(getContext(this).resourceManager.getStringSync($r('app.string.delete_text_629384751952847847392615738294751629384751952847')))
            .fontSize(14)
            .fontWeight(400)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.Red)
        .onClick(() => {
          JhProgressHUD.showToast(getContext(this).resourceManager.getStringSync($r('app.string.delete_text_629384751952847847392615738294751629384751952847')))
          this.scroller.closeAllSwipeActions()
        })
      }
      .width('50%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast(getContext(this).resourceManager.getStringSync($r('app.string.delete_text_629384751952847847392615738294751629384751952847')))
        this.scroller.closeAllSwipeActions()
      })
    }
  }

  /* openCustomDialog API12+

    创建并弹出dialogContent对应的自定义弹窗，使用Promise异步回调。

    https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-arkui-uicontext-V5#opencustomdialog12
   */

  /* promptAction.openCustomDialog API11+

    打开自定义弹窗

   https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-promptaction-V5#promptactionopencustomdialog11
   */

  private customDialogId: number = 0

  onClickRightItem() {
    promptAction.openCustomDialog({
      builder: () => {
        this.customDialogComponent()
      },
      width: '160vp',
      height: this.getPopData().length * 50 + 6,
      offset: { dx: -10, dy: 56 },
      alignment: DialogAlignment.TopEnd,
      // backgroundColor: '#2D2D2D',
      backgroundColor: Color.Transparent,
      cornerRadius: 5,
    }).then((dialogId: number) => {
      this.customDialogId = dialogId
    })
  }

  @Builder
  //顶部菜单栏的箭头区域
  customDialogComponent() {
    Column() {
      Row() {
        Image($rawfile('images/popMenus/ic_menu_up_arrow.png')).height(6)
        Blank().width(10)
      }
      .width('100%')
      .backgroundColor("#CBCBCB")
      .justifyContent(FlexAlign.End)

      List() {
        ForEach(this.getPopData(), (item: ESObject, index: number) => {
          ListItem() {
            Row() {
              Blank().width(15)
              Image(item['icon'] as Resource).width(28)
              //这个大小直接控制的菜单栏图标大小
              Blank().width(15)
              Text(item['text'] as string)
                .fontColor(Color.White)
                .fontSize(16)
            }
            .width('100%')
            .height(50)
            .alignItems(VerticalAlign.Center)
          }
          .onClick(() => {
            promptAction.closeCustomDialog(this.customDialogId)
            this.clickPopCell(item['text'] as string)
          })
        })
      }
      .scrollBar(BarState.Off)
      .enableScrollInteraction(false)
      .layoutWeight(1)
      .divider({
        strokeWidth: 1,
        startMargin: 50,
        endMargin: 0,
        color: '#E6E6E6',
      })
      .backgroundColor('#2D2D2D')
      .borderRadius(5)
    }
  }

  //控制跳转
  clickCell(item: WxHomeModel) {
    console.log('点击cell', JSON.stringify(item))
    const sportsRankingTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.sports_ranking_title_573829461847392847392615738294751629'))
    const healthMemoryTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.health_memory_title_629384751952847847392615738294751629384'))
    const heartRateTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_title_573829461847392847392615738294751629384751'))
    const bloodOxygenTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.blood_oxygen_title_758394627184759629384751952847392847392'))
    const stepAnalysisTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.step_analysis_title_629384751952847847392615738294751629384'))
    const sleepTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.sleep_title_573829461847392847392615738294751629384751952'))
    const caloriesTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.calories_title_758394627184759629384751952847392847392615'))
    const moodTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.mood_title_629384751952847847392615738294751629384751952'))
    const deepseekTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.deepseek_assistant_title_758394627184759629384751952847392847'))

    if (item.title == sportsRankingTitle) {
      console.log('正在跳转到运动排行榜页面...')
      router.pushUrl({
        url: 'pages/one/pages/WxMotionTopPage',
        params: {
          fromHome: 'true'
        }
      })
    } else if (item.title == healthMemoryTitle) {
      router.pushUrl({ url: 'pages/one/pages/HealthMemoryPage' })
    } else if (item.title == heartRateTitle) {
      router.pushUrl({ url: 'pages/one/pages/HeartRatePage' })
    } else if (item.title == bloodOxygenTitle) {
      router.pushUrl({ url: 'pages/one/pages/BloodOxygenPage' })
    } else if (item.title == stepAnalysisTitle) {
      router.pushUrl({ url: 'pages/one/pages/StepCountPage' })
    } else if (item.title == sleepTitle) {
      router.pushUrl({ url: 'pages/one/pages/SleepPage' })
    } else if (item.title == caloriesTitle) {
      router.pushUrl({ url: 'pages/one/pages/CaloriesPage' })
    } else if (item.title == moodTitle) {
      router.pushUrl({ url: 'pages/one/pages/MoodPage' })
    } else if (item.title == deepseekTitle) {
      router.pushUrl({url: 'pages/one/pages/HealthDataEntryPage'})
    }
    else {
      router.pushUrl({ url: 'pages/demos/DemoListPage' })
    }
  }

  clickPopCell(text: string) {
    console.log('点击', JSON.stringify(text))
    const addMemberText: string = getContext(this).resourceManager.getStringSync($r('app.string.add_member_text_392847516293847184759362847392615738294847'))
    const deepseekText: string = getContext(this).resourceManager.getStringSync($r('app.string.deepseek_text_758394627184759629384751952847392847392615738'))
    const startGroupChatText: string = getContext(this).resourceManager.getStringSync($r('app.string.start_group_chat_text_573829461847392847392615738294751629384'))
    const openMembershipText: string = getContext(this).resourceManager.getStringSync($r('app.string.open_membership_text_184759362847392573829461847392847392615'))

    if (text == addMemberText) {
      router.pushUrl({ url: 'pages/two/pages/WxAddFriendPage' })
    }
    else if (text == deepseekText){
      router.pushUrl({ url: 'pages/new_deepseek/ChatPage' })
    }
    else if (text == startGroupChatText){
      router.pushUrl( {url: 'pages/two/pages/WxFaceToFaceGroupPage'})
    }
    else if (text == openMembershipText){
      router.pushUrl({url : 'pages/four/pages/Membership/MemberShip' })
    }
  }

  // 这是控制文本
  getData(): WxHomeModel[] {
    const dataArr: WxHomeModel[] = [
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.sports_ranking_title_573829461847392847392615738294751629')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.sports_ranking_subtitle_392847516293847184759362847392615738')),
        'img': 'images/picture/bushu.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.deepseek_assistant_title_758394627184759629384751952847392847')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.deepseek_assistant_subtitle_184759362847392573829461847392847392')),
        'img': 'images/picture/ic_health_assistant.png',
        'isNew': true,
        'type': '2',
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.health_memory_title_629384751952847847392615738294751629384')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.health_memory_subtitle_847392615738294184759362847392847392615')),
        'img': 'images/picture/jiyi.png',
        'isNew': false,
        'type': '3',
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_title_573829461847392847392615738294751629384751')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.heart_rate_subtitle_392847516293847184759362847392615738294')),
        'img': 'images/picture/touxiang_1.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.blood_oxygen_title_758394627184759629384751952847392847392')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.blood_oxygen_subtitle_184759362847392573829461847392847392615')),
        'img': 'images/picture/xueyang.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.step_analysis_title_629384751952847847392615738294751629384')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.step_analysis_subtitle_847392615738294184759362847392847392615')),
        'img': 'images/picture/bushu.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.sleep_title_573829461847392847392615738294751629384751952')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.sleep_subtitle_392847516293847184759362847392615738294847')),
        'img': 'images/picture/sleep.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.calories_title_758394627184759629384751952847392847392615')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.calories_subtitle_184759362847392573829461847392847392615738')),
        'img': 'images/picture/reliang.png',
        'isNew': false,
        'type': '1',
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.mood_title_629384751952847847392615738294751629384751952')),
        'subtitle': getContext(this).resourceManager.getStringSync($r('app.string.mood_subtitle_847392615738294184759362847392847392615738294')),
        'img': 'images/picture/xinqing.png',
        'isNew': false,
        'type': '1',
      },
    ];
    return dataArr;
  }

  getPopData(): ESObject[] {
    return [
      {
        'text': getContext(this).resourceManager.getStringSync($r('app.string.start_group_chat_text_573829461847392847392615738294751629384')),
        'icon': $rawfile('images/popMenus/ic_chat.png'),
      },
      {
        'text': getContext(this).resourceManager.getStringSync($r('app.string.add_member_text_392847516293847184759362847392615738294847')),
        'icon': $rawfile('images/popMenus/ic_add.png'),
      },
      {
        'text': getContext(this).resourceManager.getStringSync($r('app.string.deepseek_text_758394627184759629384751952847392847392615738')),
        'icon': $rawfile('images/popMenus/ic_scan.png'),
      },
      {
        'text': getContext(this).resourceManager.getStringSync($r('app.string.open_membership_text_184759362847392573829461847392847392615')),
        'icon': $rawfile('images/popMenus/ic_pay.png'),
      },
    ];
  }
}