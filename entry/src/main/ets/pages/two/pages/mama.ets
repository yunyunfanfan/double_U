


///  Created by iotjin on 2024/11/07.
//从妈妈的健康情况点进去的页面
//比主页少了运动排行榜
import { promptAction, router } from '@kit.ArkUI'
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxHomeModel } from '../../one/models/WxHomeModel'
import { WxHomeCell } from '../../one/widgets/WxHomeCell'
const _backImageWhite = $rawfile("common/ic_nav_back_white.png")
const _backImageBlack = $rawfile("common/ic_nav_back_black.png")
let name: string = "TA"

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
        // title: `${name}的健康情况`,
        title: '此页等待做出上传的数据库再开发',
        bgColor: Color.Transparent,
      })

      this.body()
    }
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
        Text('删除')
          .fontSize(14)
          .fontWeight(400)
          .fontColor(Color.White)
      }
      .width('25%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast('删除')
        this.scroller.closeAllSwipeActions()
      })
    }
    if (type == '2') {
      Row() {
        Row() {
          Text('标为未读')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#74736D')
        .onClick(() => {
          JhProgressHUD.showToast('标为未读')
          this.scroller.closeAllSwipeActions()
        })

        Row() {
          Text('删除')
            .fontSize(14)
            .fontWeight(400)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.Red)
        .onClick(() => {
          JhProgressHUD.showToast('删除')
          this.scroller.closeAllSwipeActions()
        })
      }
      .width('50%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast('删除')
        this.scroller.closeAllSwipeActions()
      })
    }
    if (type == '3') {
      Row() {
        Row() {
          Text('不再关注')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#74736D')
        .onClick(() => {
          JhProgressHUD.showToast('不再关注')
          this.scroller.closeAllSwipeActions()
        })

        Row() {
          Text('删除')
            .fontSize(14)
            .fontWeight(400)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.Red)
        .onClick(() => {
          JhProgressHUD.showToast('删除')
          this.scroller.closeAllSwipeActions()
        })
      }
      .width('50%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast('删除')
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


  @Builder
  customDialogComponent() {
    Column() {
      Row() {
        Image($rawfile('images/popMenus/ic_menu_up_arrow.png')).height(6)
        Blank().width(10)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)

      List() {
      }
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
    if (item.title == '运动排行榜') {
      console.log('正在跳转到运动排行榜页面...')
      router.pushUrl({
        url: 'pages/one/pages/WxMotionTopPage',
        params: {
          fromHome: 'true'
        }
      })
    } else if (item.title == '个性化健康记忆') {
      router.pushUrl({ url: 'pages/one/pages/HealthMemoryPage' })
    } else if (item.title == '心率') {
      router.pushUrl({ url: 'pages/one/pages/HeartRatePage' })
    } else if (item.title == '血氧饱和度') {
      router.pushUrl({ url: 'pages/one/pages/BloodOxygenPage' })
    } else if (item.title == '步数分析') {
      router.pushUrl({ url: 'pages/one/pages/StepCountPage' })
    } else if (item.title == '睡眠') {
      router.pushUrl({ url: 'pages/one/pages/SleepPage' })
    } else if (item.title == '活动热量') {
      router.pushUrl({ url: 'pages/one/pages/CaloriesPage' })
    } else if (item.title == '情绪状态') {
      router.pushUrl({ url: 'pages/one/pages/MoodPage' })
    } else {
      router.pushUrl({ url: 'pages/demos/DemoListPage' })
    }
  }

  clickPopCell(text: string) {
    console.log('点击', JSON.stringify(text))
    if (text == '添加成员') {
      router.pushUrl({ url: 'pages/two/pages/WxAddFriendPage' })
    }
    else if (text == 'DeepSeek'){
      router.pushUrl({ url: 'pages/new_deepseek/ChatPage' })
    }
  }
  // 这是控制文本
  getData() {
    let dataArr: WxHomeModel[] = [
      {
        'title': '个性化健康记忆',
        'subtitle': '您的健康日报已经生成, 请查收',
        'img': 'images/picture/jiyi.png',
        'isNew': false,
        'type': '3',
      },
      {
        'title': '心率',
        'subtitle': '67bpm',
        'img': 'images/picture/touxiang_1.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': '血氧饱和度',
        'subtitle': '98%',
        'img': 'images/picture/xueyang.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': '步数分析',
        'subtitle': '114514步',
        'img': 'images/picture/bushu.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': '睡眠',
        'subtitle': '23小时59分钟',
        'img': 'images/picture/sleep.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': '活动热量',
        'subtitle': '100000Kcal',
        'img': 'images/picture/reliang.png',
        'isNew': false,
        'type': '1',
      },
      {
        'title': '情绪状态',
        'subtitle': '红温',
        'img': 'images/picture/xinqing.png',
        'isNew': false,
        'type': '1',
      },
    ];
    return dataArr;
  }
}