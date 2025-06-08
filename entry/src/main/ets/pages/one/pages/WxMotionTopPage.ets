import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxMotionTopModel } from '../models/WxMotionTopModel';
import { WxMotionTopCell } from '../widgets/WxMotionTopCell'
import { router } from '@kit.ArkUI'
import { userApiService, StepsRankingResponse, StepsRankingItem } from '../../../services/api_network/UserApiService';

@Entry
@Preview
@Component
struct WxMotionTopPage {
  @State dataArr: WxMotionTopModel[] = []
  @State isLoading: boolean = true
  @State errorMessage: string = ''
  scroller: Scroller = new Scroller()
  navH: number = 56
  imgNormalHeight: number = 200
  @State imgAllHeight: number = 0
  @State scrollMinOffSet: number = 0
  @State navOpacity: number = 0.0
  @State rightImg: Resource = $rawfile("images/ic_more_white.png")
  @State currentDate: string = ''

  aboutToAppear() {
    console.info('[排行榜页面] ================ 运动排行榜系统初始化开始 ================');
    console.info('[排行榜页面] 当前用户: gadz2021, 系统时间: 2025-06-08 13:54:53 UTC');
    console.info('[排行榜页面] 功能: 删除爱心图案，连接数据库，显示真实步数排行');

    this.currentDate = this.getCurrentDate()
    this.imgAllHeight = this.imgNormalHeight
    this.scrollMinOffSet = this.imgNormalHeight - this.navH
    this.loadStepsRankingData()

    try {
      let params = router.getParams() as Record<string, string>
      if (params && params['fromHome'] === 'true') {
        setTimeout(() => {
          JhProgressHUD.showText('欢迎查看步数排行榜')
        }, 500)
      }
    } catch (error) {
      console.error('[排行榜页面] 获取路由参数失败:', error)
    }
  }

  private async loadStepsRankingData(): Promise<void> {
    try {
      console.info('[数据加载] === 开始加载步数排行榜数据 ===');
      this.isLoading = true
      this.errorMessage = ''

      let rankingResponse: StepsRankingResponse = await userApiService.getStepsRanking()
      console.info(`[数据加载] === 排行榜数据响应: ${JSON.stringify(rankingResponse)} ===`);

      if (rankingResponse.success && rankingResponse.ranking) {
        let processedData: WxMotionTopModel[] = []

        for (let i: number = 0; i < rankingResponse.ranking.length; i++) {
          let rankingItem: StepsRankingItem = rankingResponse.ranking[i]
          let model: WxMotionTopModel = new WxMotionTopModel()

          model.id = rankingItem.rank - 1
          model.name = rankingItem.username
          model.steps = rankingItem.steps
          model.color = this.getRankingColor(rankingItem.rank)
          // 完全移除爱心相关属性
          model.isStar = false
          model.starNum = 0
          model.isOwn = false

          processedData.push(model)
          console.info(`[数据加载] === 处理排行榜第${rankingItem.rank}名: ${model.name}, ${model.steps}步 ===`);
        }

        this.dataArr = processedData
        console.info(`[数据加载] === 排行榜数据加载完成，共${processedData.length}名用户 ===`);
      } else {
        this.errorMessage = '获取排行榜数据失败'
        console.error('[数据加载] === 排行榜数据获取失败 ===');
      }
    } catch (error) {
      this.errorMessage = `数据加载失败: ${error}`
      console.error(`[数据加载] === 排行榜数据加载异常: ${error} ===`);
    } finally {
      this.isLoading = false
    }
  }

  private getRankingColor(rank: number): string {
    if (rank === 1) return '#FFD700'
    if (rank === 2) return '#C0C0C0'
    if (rank === 3) return '#CD7F32'
    return '#4CAF50'
  }

  getCurrentDate(): string {
    let now = new Date()
    let year = now.getFullYear()
    let month = now.getMonth() + 1
    let day = now.getDate()
    return `${year}年${month}月${day}日`
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      this.header()
      this.body()
      BaseNavigation({
        title: '步数排行榜',
        bgColor: `rgba(237,237,237,${this.navOpacity})`,
        rightImgPath: this.rightImg,
        rightItemCallBack: () => {
          this.clickCell('更多操作')
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

          Column() {
            Text('今日步数排行榜')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 5 })

            Text(this.currentDate)
              .fontSize(14)
              .fontColor(Color.Gray)
              .margin({ bottom: 15 })

            // 移除爱心列，只保留排名、用户、步数
            Row() {
              Text('排名')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('20%')
                .textAlign(TextAlign.Center)

              Text('用户')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('50%')
                .textAlign(TextAlign.Center)

              Text('步数')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('30%')
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

      if (this.isLoading) {
        ListItem() {
          Column({ space: 20 }) {
            LoadingProgress()
              .width(40)
              .height(40)
              .color('#4CAF50')
            Text('正在加载排行榜数据...')
              .fontSize(16)
              .fontColor('#666666')
          }
          .width('100%')
          .padding({ top: 50, bottom: 50 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      } else if (this.errorMessage) {
        ListItem() {
          Column({ space: 15 }) {
            Text('⚠️')
              .fontSize(32)
            Text('加载失败')
              .fontSize(18)
              .fontColor('#EA4335')
              .fontWeight(FontWeight.Bold)
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
            Button('重新加载')
              .onClick(() => {
                this.loadStepsRankingData()
              })
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .borderRadius(8)
              .height(40)
              .width(120)
          }
          .width('100%')
          .padding({ top: 50, bottom: 50 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      } else if (this.dataArr.length == 0) {
        ListItem() {
          Column({ space: 15 }) {
            Text('📊')
              .fontSize(32)
            Text('暂无排行榜数据')
              .fontSize(18)
              .fontColor('#666666')
            Text('还没有用户步数记录')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .padding({ top: 50, bottom: 50 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      } else {
        ForEach(this.dataArr, (item: WxMotionTopModel, index: number) => {
          ListItem() {
            // 自定义排行榜单元格，移除爱心显示
            Row() {
              // 排名
              Text(`${item.id! + 1}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.color)
                .width('20%')
                .textAlign(TextAlign.Center)

              // 用户名
              Text(item.name || '未知用户')
                .fontSize(16)
                .fontColor('#333333')
                .width('50%')
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              // 步数
              Text(`${item.steps || 0}`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#666666')
                .width('30%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(60)
            .backgroundColor(Color.White)
            .padding({ left: 15, right: 15 })
            .margin({ bottom: 1 })
            .onClick(() => {
              this.clickCell(item.name!)
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
    let y = this.scroller.currentOffset().yOffset
    if (y < this.scrollMinOffSet) {
      this.imgAllHeight = this.imgNormalHeight + (-y)
    } else {
      this.imgAllHeight = this.navH
    }

    let navOpacity: number = y / this.navH
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
      Row()
        .width('100%')
        .height(this.imgAllHeight)
        .backgroundColor('#4CAF50')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

      if (this.imgAllHeight > this.navH + 50) {
        Column() {
          Text('🏆')
            .fontSize(60)
            .fontColor('#FFFFFF')

          Text('步数排行榜')
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
    JhProgressHUD.showText(`${text}的运动详情`)
  }
}