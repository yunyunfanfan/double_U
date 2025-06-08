import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxNewFriendModel } from '../models/WxNewFriendModel'
import { WxNewFriendCell } from '../widgets/WxNewFriendCell'
import { router } from '@kit.ArkUI'

///雷达加好友页面

@Entry
@Preview
@Component
struct WxRadarAddMemberPage {
  @State dataArr: WxNewFriendModel[] = []
  @State isScanning: boolean = false
  @State scanAngle: number = 0
  @State scanOpacity: number = 0.3
  @State waveScale: number = 1.0
  @State waveOpacity: number = 0.8
  private scanTimer: number = -1
  private waveTimer: number = -1

  aboutToAppear() {
    this.dataArr = this.getData()
  }

  aboutToDisappear() {
    this.stopAllTimers()
  }

  stopAllTimers() {
    if (this.scanTimer !== -1) {
      clearInterval(this.scanTimer)
      this.scanTimer = -1
    }
    if (this.waveTimer !== -1) {
      clearInterval(this.waveTimer)
      this.waveTimer = -1
    }
  }

  build() {
    Column() {
      BaseNavigation({
        title: getContext(this).resourceManager.getStringSync($r('app.string.radar_add_member_title_827395614')),
        bgColor: Color.Transparent
      })
      this.content()
    }
    .backgroundColor('#F7F7F7')
  }

  @Builder
  content() {
    Column() {
      this.radarView()
      this.memberList()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  radarView() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 雷达背景
        Circle()
          .width(200)
          .height(200)
          .fill('#1A1A1A')

        // 扫描动画
        Circle()
          .width(200)
          .height(200)
          .fill('#07C160')
          .opacity(this.scanOpacity)
          .rotate({ angle: this.scanAngle })
          .clip(new Circle({ width: 200, height: 200 }))

        // 波纹动画
        ForEach([1, 2, 3], (index: number) => {
          Circle()
            .width(200)
            .height(200)
            .fill('#07C160')
            .opacity(this.waveOpacity / (index + 1))
            .scale({ x: this.waveScale + (index * 0.2), y: this.waveScale + (index * 0.2) })
        })

        // 中心点
        Circle()
          .width(20)
          .height(20)
          .fill('#07C160')
      }
      .width('100%')
      .height(250)
      .margin({ top: 20 })

      // 加载提示文字
      if (this.isScanning) {
        Text(getContext(this).resourceManager.getStringSync($r('app.string.searching_nearby_people_619472853')))
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 10 })
      }

      Button(this.isScanning ?
      getContext(this).resourceManager.getStringSync($r('app.string.stop_scanning_btn_394758162')) :
      getContext(this).resourceManager.getStringSync($r('app.string.start_scanning_btn_751826394')))
        .width(180)
        .height(40)
        .backgroundColor('#07C160')
        .fontColor(Color.White)
        .fontSize(16)
        .borderRadius(4)
        .margin({ top: 10 })
        .onClick(() => {
          this.isScanning = !this.isScanning
          if (this.isScanning) {
            this.startScanning()
          } else {
            this.stopScanning()
          }
        })
    }
  }

  @Builder
  memberList() {
    List() {
      ForEach(this.dataArr, (item: WxNewFriendModel, index: number) => {
        ListItem() {
          WxNewFriendCell({
            model: item,
            onClickCell: () => {
              this.clickCell(item.title!)
            },
            onClickBtn: () => {
              const acceptText: string = getContext(this).resourceManager.getStringSync($r('app.string.accept_action_258174639'))
              this.clickCell(acceptText)
            },
          })
        }
      })
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
    .divider({
      strokeWidth: 0.5,
      startMargin: 0,
      endMargin: 0,
      color: '#1A1A1A'
    })
  }

  startScanning() {
    const direction: number = 1
    this.scanTimer = setInterval(() => {
      this.scanAngle = (this.scanAngle + 2) % 360

      // 透明度动画
      this.scanOpacity += direction * 0.01
      if (this.scanOpacity >= 0.3) {
        // direction = -1
      } else if (this.scanOpacity <= 0.1) {
        // direction = 1
      }
    }, 16)

    // 波纹动画
    this.waveTimer = setInterval(() => {
      this.waveScale += 0.02
      this.waveOpacity -= 0.01

      if (this.waveScale >= 1.5) {
        this.waveScale = 1.0
        this.waveOpacity = 0.8
      }
    }, 50)
  }

  stopScanning() {
    this.stopAllTimers()
    this.scanAngle = 0
    this.scanOpacity = 0.3
    this.waveScale = 1.0
    this.waveOpacity = 0.8
  }

  clickCell(text: string) {
    const clickPrefix: string = getContext(this).resourceManager.getStringSync($r('app.string.click_action_prefix_472851936'))
    JhProgressHUD.showText(`${clickPrefix} ${text}`)
  }

  getData(): WxNewFriendModel[] {
    const distancePrefix: string = getContext(this).resourceManager.getStringSync($r('app.string.distance_prefix_639471852'))
    const meterSuffix: string = getContext(this).resourceManager.getStringSync($r('app.string.distance_meter_suffix_174629385'))
    const zhangSanName: string = getContext(this).resourceManager.getStringSync($r('app.string.member_name_zhangsan_917384625'))
    const liSiName: string = getContext(this).resourceManager.getStringSync($r('app.string.member_name_lisi_582947163'))
    const wangWuName: string = getContext(this).resourceManager.getStringSync($r('app.string.member_name_wangwu_365821749'))

    const dataArr: WxNewFriendModel[] = [
      {
        'title': zhangSanName,
        'subtitle': `${distancePrefix} 5${meterSuffix}`,
        'img': 'images/picture/touxiang_1.jpeg',
        'isAdd': false,
      },
      {
        'title': liSiName,
        'subtitle': `${distancePrefix} 8${meterSuffix}`,
        'img': 'images/picture/touxiang_2.jpeg',
        'isAdd': false,
      },
      {
        'title': wangWuName,
        'subtitle': `${distancePrefix} 12${meterSuffix}`,
        'img': 'images/picture/touxiang_3.jpeg',
        'isAdd': false,
      },
    ]
    return dataArr
  }
}