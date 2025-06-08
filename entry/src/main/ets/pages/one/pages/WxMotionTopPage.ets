//运动排行榜

import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxMotionTopModel } from '../models/WxMotionTopModel';
import { WxMotionTopCell } from '../widgets/WxMotionTopCell'
import resData from '../../res/wx_motion_top.json'
import { router } from '@kit.ArkUI'

@Entry
@Preview
@Component
struct WxMotionTopPage {
  @State dataArr: WxMotionTopModel[] = []
  scroller: Scroller = new Scroller()
  navH: number = 56
  imgNormalHeight: number = 200 // 减小图片高度以便更好地显示内容
  @State imgAllHeight: number = 0
  @State scrollMinOffSet: number = 0
  @State navOpacity: number = 0.0
  @State rightImg: Resource = $rawfile("images/ic_more_white.png")
  @State currentDate: string = ''

  aboutToAppear() {
    this.currentDate = this.getCurrentDate()
    this.dataArr = this.getData()

    this.imgAllHeight = this.imgNormalHeight
    this.scrollMinOffSet = this.imgNormalHeight - this.navH

    // 检查是否从主页跳转而来，如果是则显示欢迎提示
    try {
      const params = router.getParams() as Record<string, string>
      if (params && params['fromHome'] === 'true') {
        setTimeout(() => {
          const welcomeMessage = getContext(this).resourceManager.getStringSync($r('app.string.welcome_message_17834625'))
          JhProgressHUD.showText(welcomeMessage)
        }, 500)
      }
    } catch (error) {
      // 获取路由参数失败
    }
  }

  getCurrentDate(): string {
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth() + 1
    const day = now.getDate()
    const yearSuffix = getContext(this).resourceManager.getStringSync($r('app.string.year_suffix_73495168'))
    const monthSuffix = getContext(this).resourceManager.getStringSync($r('app.string.month_suffix_28617439'))
    const daySuffix = getContext(this).resourceManager.getStringSync($r('app.string.day_suffix_91348572'))
    return `${year}${yearSuffix}${month}${monthSuffix}${day}${daySuffix}`
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      this.header()
      this.body()
      BaseNavigation({
        title: getContext(this).resourceManager.getStringSync($r('app.string.leaderboard_title_82759341')),
        bgColor: `rgba(237,237,237,${this.navOpacity})`,
        rightImgPath: this.rightImg,
        rightItemCallBack: () => {
          const moreAction = getContext(this).resourceManager.getStringSync($r('app.string.more_action_62519473'))
          this.clickCell(moreAction)
        },
      })
    }
    .backgroundColor(KColors.wxBgColor)
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    List({ scroller: this.scroller }) {
      ListItem() {
        Column() {
          Row()
            .width('100%')
            .height(this.imgNormalHeight)

          // 添加排行榜标题区域
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.today_steps_leaderboard_65284793')))
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 5 })

            Text(this.currentDate)
              .fontSize(14)
              .fontColor(Color.Gray)
              .margin({ bottom: 15 })

            Row() {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.ranking_header_39157264')))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('15%')
                .textAlign(TextAlign.Center)

              Text(getContext(this).resourceManager.getStringSync($r('app.string.user_header_81674529')))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('45%')
                .textAlign(TextAlign.Center)

              Text(getContext(this).resourceManager.getStringSync($r('app.string.steps_header_53926841')))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('25%')
                .textAlign(TextAlign.Center)

              Text(getContext(this).resourceManager.getStringSync($r('app.string.likes_header_27184635')))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('15%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: 10, bottom: 10 })
            .backgroundColor('#F5F5F5')
          }
          .width('100%')
          .backgroundColor(Color.White)
        }
      }

      if (this.dataArr.length == 0) {
        ListItem() {
          Text(getContext(this).resourceManager.getStringSync($r('app.string.no_data_message_94758136')))
            .width('100%')
            .padding({ top: 50 })
            .textAlign(TextAlign.Center)
            .fontSize(18)
        }
      } else {
        ForEach(this.dataArr, (item: WxMotionTopModel, index: number) => {
          ListItem() {
            WxMotionTopCell({
              model: item,
              onClickCell: () => {
                this.clickCell(item.name!)
              },
            })
          }
        })
      }
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
    .onDidScroll(() => {
      this.handleScroll()
    })
  }

  handleScroll() {
    const y = this.scroller.currentOffset().yOffset
    // 滑动距离计算
    if (y < this.scrollMinOffSet) {
      this.imgAllHeight = this.imgNormalHeight + (-y)
    } else {
      this.imgAllHeight = this.navH
    }

    // nav 透明度
    const navOpacity: number = y / this.navH
    if (navOpacity < 0) {
      this.navOpacity = 0.0
    } else if (navOpacity > 1) {
      this.navOpacity = 1.0
    } else {
      this.navOpacity = navOpacity
    }

    this.setRightImg()
  }

  setRightImg() {
    if (this.navOpacity == 0) {
      this.rightImg = $rawfile("images/ic_more_white.png")
    }
    if (this.navOpacity == 1) {
      this.rightImg = $rawfile("images/ic_more_black.png")
    }
  }

  @Builder
  header() {
    Column() {
      // 使用纯色背景代替图片
      Row()
        .width('100%')
        .height(this.imgAllHeight)
        .backgroundColor('#4CAF50')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

      // 添加奖杯图标和文字
      if (this.imgAllHeight > this.navH + 50) {
        Column() {
          // 使用文本代替系统符号
          Text('🏆')
            .fontSize(60)
            .fontColor('#FFFFFF')

          Text(getContext(this).resourceManager.getStringSync($r('app.string.steps_leaderboard_title_47392816')))
            .fontSize(24)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 10 })
        }
        .position({ x: '50%', y: this.imgAllHeight / 2 })
        .translate({ x: '-50%', y: '-50%' })
      }
    }
  }

  clickCell(text: string) {
    const detailsSuffix = getContext(this).resourceManager.getStringSync($r('app.string.exercise_details_suffix_85196347'))
    JhProgressHUD.showText(`${text}${detailsSuffix}`)
  }

  getData() {
    try {
      // 原始数据
      const dataArr: ESObject[] = resData['data']
      // 处理数据，确保数据正确加载
      const processedData: WxMotionTopModel[] = []

      if (!dataArr || dataArr.length === 0) {
        return []
      }

      const defaultUserPrefix = getContext(this).resourceManager.getStringSync($r('app.string.default_user_prefix_46782915'))

      dataArr.forEach((item: ESObject, index) => {
        if (item) {
          const model = new WxMotionTopModel()
          model.id = index
          model.name = item['name'] || `${defaultUserPrefix}${index}`
          model.color = item['color'] || '#4CAF50'
          model.steps = item['steps'] || 0
          model.isStar = item['isStar'] || false
          model.starNum = item['starNum'] || 0
          model.isOwn = item['isOwn'] || false
          processedData.push(model)
        }
      })

      // 按步数从高到低排序
      processedData.sort((a, b) => {
        return (b.steps || 0) - (a.steps || 0)
      })

      // 更新排名ID，使其反映正确的排序位置
      processedData.forEach((item, index) => {
        item.id = index
      })

      return processedData
    } catch (error) {
      return []
    }
  }
}