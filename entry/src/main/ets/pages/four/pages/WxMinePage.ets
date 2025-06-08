///  WxMinePage.ets
///
///  Created by iotjin on 2024/11/06.
//"我的"页面
//是第四页主页

import { BaseNavigation, JhAESPreferencesUtils, JhSetCell, KColors, kUserDefault_UserInfo } from 'JhCommon'
import { UserModel } from '../../model/UserModel';
import { router } from '@kit.ArkUI';

const _cellH = 55.0;
const _leftSpace = 50.0;
const _rowSpace = 6.0;

@Entry
@Preview
@Component
export struct WxMinePage {
  userInfo?: UserModel;
  scroller: Scroller = new Scroller()
  @State topH: number = 0
  @State refreshFlag: number = 0;
  @State userName: string = '';

  aboutToAppear() {
    this.loadUserInfo()
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row()
        .width('100%')
        .height(this.topH + 50)
        .backgroundColor(Color.White)
      this.body()
      BaseNavigation({
        title: '',
        bgColor: Color.Transparent,
        leftItem: {},
        rightImgPath: $rawfile("images/ic_set_black.png"),
        rightItemCallBack: () => {
          this.clickCell($r('app.string.settings'))
        },
      })
        .hitTestBehavior(HitTestMode.Transparent)
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    List({ scroller: this.scroller }) {
      this.header()
      ListItem() {
        Column() {
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            leftIcon: $rawfile("wechat/mine/ic_wallet.png"),
            title: $r('app.string.membership_center'),
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell($r('app.string.membership_center')),
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            lineLeftEdge: _leftSpace,
            leftIcon: $rawfile("wechat/mine/ic_collections.png"),
            title: $r('app.string.health_records'),
            clickCallBack: (): void => {
              this.clickCell($r('app.string.health_records'))
            },
          })
          JhSetCell({
            cellHeight: _cellH,
            lineLeftEdge: _leftSpace,
            leftIcon: $rawfile("wechat/mine/ic_album.png"),
            title: $r('app.string.energy_assistant'),
            clickCallBack: (): void => {
              this.clickCell($r('app.string.energy_assistant'))
            },
          })
          JhSetCell({
            cellHeight: _cellH,
            lineLeftEdge: _leftSpace,
            leftIcon: $rawfile("wechat/mine/ic_cards_wallet.png"),
            title: $r('app.string.knowledge_topics'),
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell($r('app.string.knowledge_topics')),
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            lineLeftEdge: _leftSpace,
            leftIcon: $rawfile("wechat/mine/ic_emotions.png"),
            title: $r('app.string.health_points'),
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell($r('app.string.health_points')),
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            leftIcon: $rawfile("wechat/mine/ic_settings.png"),
            title: $r('app.string.settings'),
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell($r('app.string.settings')),
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            leftIcon: $rawfile("images/ic_about.png"),
            title: $r('app.string.check_update'),
            text: $r('app.string.new_version_available'),
            textStyle: { fontSize: 14, fontColor: Color.Red },
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell($r('app.string.check_update')),
          })
          Blank().height(50)
        }
      }
    }
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
    .backgroundColor(Color.Transparent)
    .onDidScroll(() => {
      this.handleScroll()
    })
  }

  handleScroll() {
    const y = this.scroller.currentOffset().yOffset
    if (y < 0 && y > -1000) {
      this.topH = Math.abs(y)
    }
  }

  @Builder
  header() {
    Row() {
      Image('https://gitee.com/zhaozehe/zako/raw/master/ic_535a5f26fa59f35f023467562ae1388e.png' || $rawfile("wechat/mine/default_avatar.jpg")).width(75).height(75).borderRadius(10)
        .onClick(() => {
          this.clickCell($r('app.string.personal_info'))
        })
      Column() {
        Text(this.userInfo?.userName)
          .fontSize(28)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .onClick(() => {
            this.clickCell($r('app.string.personal_info'))
          })
        Row() {
          Text() {
            Span($r('app.string.health_id_prefix'))
            Span('abc')
          }
          .fontSize(17)
          .fontColor(Color.Gray)
          Blank()
          Image($rawfile('wechat/mine/ic_setting_myQR.png')).width(18).height(18).margin({ right: 20 })
          Image($rawfile('JhForm/ic_arrow_right.svg')).width(25).height(25)
        }
        .margin({ top: 10 })
        .width('100%')
        .onClick(() => {
          this.clickCell($r('app.string.personal_info'))
        })
      }
      .layoutWeight(1)
      .padding({ left: 16 })
    }
    .backgroundColor(Color.White)
    .padding({
      left: 15,
      right: 15,
      top: 40,
      bottom: 30
    })
  }

  onPageShow() {
    this.loadUserInfo()
  }

  loadUserInfo() {
    let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as UserModel;
    if (userInfo) {
      this.userInfo = userInfo;
      this.refreshFlag++;
    }
  }

  clickCell(title: Resource | string) {
    const titleStr = typeof title === 'string' ? title : this.getResourceString(title);

    if (titleStr === this.getResourceString($r('app.string.membership_center'))) {
      router.pushUrl({ url: 'pages/four/pages/Membership/MemberShip' })
    }
    if (titleStr === this.getResourceString($r('app.string.personal_info'))) {
      router.pushUrl({ url: 'pages/four/pages/WxPersonInfoPage' })
    }
    if (titleStr === this.getResourceString($r('app.string.settings'))) {
      router.pushUrl({ url: 'pages/four/pages/setpage/SetPage' })
    }
    if (titleStr === this.getResourceString($r('app.string.health_points'))) {
      router.pushUrl({ url: 'pages/four/pages/jifen/JifenPage' })
    }
    if (titleStr === this.getResourceString($r('app.string.knowledge_topics'))) {
      router.pushUrl({ url: 'pages/four/pages/knowledge/knowledge' })
    }
    if (titleStr === this.getResourceString($r('app.string.health_records'))) {
      router.pushUrl({ url: 'pages/four/pages/health/HealthRecordsPage' })
    }
    if (titleStr === this.getResourceString($r('app.string.energy_assistant'))) {
      router.pushUrl({ url: 'pages/four/pages/energy_assistant/EnergyAssistantPage' })
    }
    if (titleStr === this.getResourceString($r('app.string.check_update'))) {
      router.pushUrl({url: 'pages/four/pages/gengxin/JianChaGengXinPage'})
    }
  }

  private getResourceString(resource: Resource): string {
    return getContext(this).resourceManager.getStringSync(resource);
  }
}