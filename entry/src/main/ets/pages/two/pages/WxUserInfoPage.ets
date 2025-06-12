///  description:  用户信息

import { router } from '@kit.ArkUI'
import { BaseNavigation, JhProgressHUD, JhSetCell, KColors } from 'JhCommon'
import { WxContactsModel } from '../models/WxContactsModel';
import { UserApiService } from '../../../services/api_network/UserApiService';

const _cellH = 55.0;
const _rowSpace = 6.0;

interface RouterParams {
  data: WxContactsModel;
}

@Entry
@Preview
@Component
struct WxUserInfoPage {
  jumpParams: WxContactsModel = new WxContactsModel()
  @State model: WxContactsModel = new WxContactsModel()
  @State avatarUrl: string = ''

  aboutToAppear() {
    console.info('[用户详情] 页面初始化');
    this.loadRouterParams();
    this.loadUserAvatar();
  }

  private loadRouterParams(): void {
    try {
      const params = router.getParams() as RouterParams;
      if (params && params.data) {
        this.jumpParams = params.data;
        this.model = params.data;
        console.info('[用户详情] 跳转参数加载成功');
        console.info('[用户详情] 用户名称：', this.model.name);
      }
    } catch (error) {
      console.error('[用户详情] 获取路由参数失败:', error);
    }
  }

  private loadUserAvatar(): void {
    if (this.model.avatarUrl) {
      this.avatarUrl = UserApiService.getUserDisplayAvatar(this.model.avatarUrl as string);
    } else {
      this.avatarUrl = UserApiService.getDefaultAvatarUrl();
    }
    console.info('[用户详情] 加载头像:', this.avatarUrl);
  }

  build() {
    Column() {
      BaseNavigation({
        title: '详细资料',
        bgColor: Color.Transparent,
        rightImgPath: $rawfile("images/ic_more_black.png"),
        rightItemCallBack: () => {
          const params: RouterParams = { data: this.jumpParams };
          router.pushUrl({ url: 'pages/two/pages/WxInfoSetPage', params: params })
        },
      })
      List() {
        this.header()
        this.body()
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: true
      })
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    Blank().height(0.5).width('100%').backgroundColor(KColors.kLineColor)
    JhSetCell({
      cellHeight: _cellH,
      title: '健康状况',
      text: '良好',
      textAlign: TextAlign.Start,
      clickCallBack: (): void => {
        const emptyParams: RouterParams = { data: new WxContactsModel() };
        router.pushUrl({ url: 'pages/two/pages/mama', params: emptyParams })
      },
    })
    Blank().height(_rowSpace)
    Row() {
      Image($rawfile('wechat/contacts/ic_xinxi.png')).width(20)
      Blank().width(5)
      Text('发消息').fontSize(18).fontWeight(FontWeight.Bold).fontColor(KColors.wxTextBlueColor)
    }
    .width('100%')
    .height(_cellH)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(KColors.kCellBgColor)
    .onClick(() => this.clickCell('发消息'))

    Blank().height(0.5).width('100%').backgroundColor(KColors.kLineColor)
  }

  @Builder
  header() {
    Row() {
      if (this.avatarUrl) {
        Image(this.avatarUrl)
          .width(66)
          .height(66)
          .margin({ left: 20, top: 3, right: 15 })
          .borderRadius(5)
          .objectFit(ImageFit.Cover)
      } else {
        Text((this.model.name as string).substring(0, 1))
          .fontColor(Color.White)
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .width(66)
          .height(66)
          .margin({ left: 20, top: 3, right: 15 })
          .borderRadius(5)
          .backgroundColor(this.model.color as string)
      }

      Column() {
        Row() {
          Text(this.model.name as string)
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
          Blank().width(5)
          Text() {
            SymbolSpan($r('sys.symbol.person'))
              .fontWeight(FontWeight.Bold)
              .fontSize(20)
              .fontColor([this.model.sex == '0' ? '#2196F3' : '#FF5252'])
          }
        }

        Blank().height(3)
        Text('昵称: ' + (this.model.namePinyin as string)).fontSize(16).fontColor(Color.Gray)
        Blank().height(3)
        Text('手机号: ' + (this.model.phone as string)).fontSize(16).fontColor(Color.Gray)
        Blank().height(3)
        Text('地区: ' + (this.model.region as string || '未知')).fontSize(16).fontColor(Color.Gray)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(70)

      if (this.model.isStar) {
        Text() {
          SymbolSpan($r('sys.symbol.star_fill'))
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .fontColor([Color.Yellow])
        }
        .layoutWeight(15)
      }
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .padding({ top: 10, bottom: 20 })
    .backgroundColor(KColors.kCellBgColor)
  }

  clickCell(text: string) {
    JhProgressHUD.showText(`点击了 ${text}`)
  }
}