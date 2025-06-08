///  WxAddFriendPage.ets
///  description:  添加朋友
// 我是傻逼
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxAddFriendModel } from '../models/WxAddFriendModel'
import { WxAddFriendCell } from '../widgets/WxAddFriendCell'
import { router } from '@kit.ArkUI';


@Entry
@Preview
@Component
struct WxAddFriendPage {
  @State dataArr: WxAddFriendModel[] = []

  aboutToAppear() {
    this.dataArr = this.getData()
    // console.error('data', JSON.stringify(this.dataArr))
  }

  build() {
    Column() {
      BaseNavigation({ title: getContext(this).resourceManager.getStringSync($r('app.string.add_member_title_847392651847392651')), bgColor: Color.Transparent })
      Scroll() {
        Column() {
          this.header()
          this.body()
        }
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
    List() {
      ForEach(this.dataArr, (item: WxAddFriendModel, index: number) => {
        ListItem() {
          WxAddFriendCell({
            model: item,
            onClickCell: () => {
              this.clickCell(item)
            },
          })
        }
      })
    }
    .layoutWeight(1)
    .divider({
      strokeWidth: 0.5,
      startMargin: 0,
      endMargin: 0,
      color: KColors.kLineColor
    })
  }

  @Builder
  header() {
    Column() {
      Search({ value: '', placeholder: getContext(this).resourceManager.getStringSync($r('app.string.health_phone_placeholder_629384751639284751')) })
        .borderRadius(5)
        .margin(10)
        .backgroundColor(Color.White)
        .onSubmit((value: string) => {
        })
        .onChange((value: string) => {
        })
      Row() {
        Text(getContext(this).resourceManager.getStringSync($r('app.string.my_health_id_text_573829461847392573')))
        Blank().width(10)
        Image($rawfile('wechat/contacts/add/add_friend_myQR_20x20_@2x.png')).width(20)
      }
      .height(60)
    }
  }

  clickCell(item: WxAddFriendModel) {
    const radarTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.radar_add_member_title_392847516293847516'))
    const faceToFaceTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.face_to_face_group_title_184759362847392184'))
    const customerServiceTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.health_customer_service_title_847392615738294847'))
    const scanTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.scan_qr_code_title_392847516293847392'))
    const clickPrefix: string = getContext(this).resourceManager.getStringSync($r('app.string.click_prefix_toast_758394627184759758'))

    switch (item.title) {
      case radarTitle:
        router.pushUrl({ url: 'pages/two/pages/WxRadarAddMemberPage' });
        break;
      case faceToFaceTitle:
        router.pushUrl({ url: 'pages/two/pages/WxFaceToFaceGroupPage' });
        break;
      case customerServiceTitle:
        router.pushUrl({ url: 'pages/three/pages/CustomerServicePage' });
        break;
      case scanTitle:
        router.pushUrl({ url: 'pages/two/pages/WxScanPage' });
        break;
      default:
        JhProgressHUD.showText(`${clickPrefix} ${item.title}`);
        break;
    }
  }

  getData(): WxAddFriendModel[] {
    const radarTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.radar_add_member_title_392847516293847516'))
    const radarSubtitle: string = getContext(this).resourceManager.getStringSync($r('app.string.radar_add_member_subtitle_758394627184759362'))
    const faceToFaceTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.face_to_face_group_title_184759362847392184'))
    const faceToFaceSubtitle: string = getContext(this).resourceManager.getStringSync($r('app.string.face_to_face_group_subtitle_629384751952847629'))
    const customerServiceTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.health_customer_service_title_847392615738294847'))
    const customerServiceSubtitle: string = getContext(this).resourceManager.getStringSync($r('app.string.health_customer_service_subtitle_573829461847392573'))

    const dataArr: WxAddFriendModel[] = [
      {
        'title': radarTitle,
        'subtitle': radarSubtitle,
        'img': 'wechat/contacts/add/add_friend_icon_reda_36x36_@3x.png',
      },
      {
        'title': faceToFaceTitle,
        'subtitle': faceToFaceSubtitle,
        'img': 'wechat/contacts/add/add_friend_icon_addgroup_36x36_@3x.png',
      },
      {
        'title': customerServiceTitle,
        'subtitle': customerServiceSubtitle,
        'img': 'wechat/contacts/add/add_friend_icon_search_wework_40x40_@2x.png',
      },
    ];
    return dataArr;
  }
}