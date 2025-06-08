
///新的成员界面

import { router } from '@kit.ArkUI'
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxNewFriendModel } from '../models/WxNewFriendModel'
import { WxNewFriendCell } from '../widgets/WxNewFriendCell'


@Entry
@Preview
@Component
struct WxNewFriendPage {
  @State dataArr: WxNewFriendModel[] = []

  aboutToAppear() {
    this.dataArr = this.getData()
    // console.error('data', JSON.stringify(this.dataArr))
  }

  build() {
    Column() {
      BaseNavigation({
        title: getContext(this).resourceManager.getStringSync($r('app.string.new_member_title_847392516')),
        bgColor: Color.Transparent,
        rate: 28,
        rightText: getContext(this).resourceManager.getStringSync($r('app.string.add_member_btn_629384751')),
        rightItemCallBack: () => {
          router.pushUrl({ url: 'pages/two/pages/WxAddFriendPage' })
        },
      })
      this.body()
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    List() {
      this.header()
      ForEach(this.dataArr, (item: WxNewFriendModel, index: number) => {
        ListItem() {
          WxNewFriendCell({
            model: item,
            onClickCell: () => {
              this.clickCell(item.title!)
            },
            onClickBtn: () => {
              const acceptText: string = getContext(this).resourceManager.getStringSync($r('app.string.accept_action_184759362'))
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
      color: KColors.kLineColor
    })
  }

  @Builder
  header() {
    Column() {
      Search({ value: '', placeholder: getContext(this).resourceManager.getStringSync($r('app.string.health_phone_placeholder_573829461')) })
        .borderRadius(5)
        .margin(10)
        .backgroundColor(Color.White)
        .onSubmit((value: string) => {
        })
        .onChange((value: string) => {
        })
      Column() {
        Column() {
          Text() {
            SymbolSpan($r('sys.symbol.phone_fill'))
              .fontWeight(FontWeight.Bold)
              .fontSize(20)
              .fontColor([Color.Green])
          }

          Blank().height(10)
          Text(getContext(this).resourceManager.getStringSync($r('app.string.add_phone_contacts_392847516'))).fontColor(Color.Gray)
        }
        .padding(10)
        .width('100%')
        .backgroundColor(Color.White)

        Text(getContext(this).resourceManager.getStringSync($r('app.string.three_days_ago_758392641')))
          .textAlign(TextAlign.Start)
          .width('100%')
          .height(35)
          .fontColor(Color.Gray)
      }

    }
  }

  clickCell(text: string) {
    const clickPrefix: string = getContext(this).resourceManager.getStringSync($r('app.string.click_prefix_927384651'))
    JhProgressHUD.showText(`${clickPrefix} ${text}`)
  }

  getData(): WxNewFriendModel[] {
    const zhangSanName: string = getContext(this).resourceManager.getStringSync($r('app.string.member_name_zhangsan_593847261'))
    const liSiName: string = getContext(this).resourceManager.getStringSync($r('app.string.member_name_lisi_847392615'))
    const wangWuName: string = getContext(this).resourceManager.getStringSync($r('app.string.member_name_wangwu_273948561'))
    const zhaoLiuName: string = getContext(this).resourceManager.getStringSync($r('app.string.member_name_zhaoliu_938475162'))
    const hahahaName: string = getContext(this).resourceManager.getStringSync($r('app.string.member_name_hahaha_574829361'))
    const welcomeMsg: string = getContext(this).resourceManager.getStringSync($r('app.string.welcome_message_463829175'))
    const helloMsg: string = getContext(this).resourceManager.getStringSync($r('app.string.hello_greeting_729384651'))
    const imageMsg: string = getContext(this).resourceManager.getStringSync($r('app.string.image_placeholder_385927461'))
    const emojiMsg: string = getContext(this).resourceManager.getStringSync($r('app.string.animation_emoji_674839251'))

    const dataArr: WxNewFriendModel[] = [
      {
        'title': zhangSanName,
        'subtitle': welcomeMsg,
        'img': 'images/picture/touxiang_1.jpeg',
        'isAdd': true,
      },
      {
        'title': liSiName,
        'subtitle': helloMsg,
        'img': 'images/picture/touxiang_2.jpeg',
        'isAdd': false,
      },
      {
        'title': wangWuName,
        'subtitle': imageMsg,
        'img': 'images/picture/touxiang_3.jpeg',
        'isAdd': false,
      },
      {
        'title': zhaoLiuName,
        'subtitle': emojiMsg,
        'img': 'images/picture/touxiang_4.jpeg',
        'isAdd': true,
      },
      {
        'title': hahahaName,
        'subtitle': '',
        'img': 'images/picture/touxiang_5.jpeg',
        'isAdd': false,
      },
      {
        'title': '@',
        'subtitle': 'hi',
        'img': 'images/picture/touxiang_6.jpg',
        'isAdd': false,
      },
    ];
    return dataArr;
  }
}