///群聊界面

import { BaseNavigation, JhProgressHUD, JhSetCell, KColors } from 'JhCommon'
import { WxAddFriendModel } from '../models/WxAddFriendModel';

@Entry
@Preview
@Component
struct WxGroupChatPage {
  @State dataArr: WxAddFriendModel[] = []

  aboutToAppear() {
    this.dataArr = this.getData()
    // console.error('data', JSON.stringify(this.dataArr))
  }

  build() {
    Column() {
      BaseNavigation({ title: getContext(this).resourceManager.getStringSync($r('app.string.group_chat_title_947382651847')), bgColor: Color.Transparent })
      this.body()
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    List() {
      this.header()
      if (this.dataArr.length == 0) {
        ListItem() {
          Text(getContext(this).resourceManager.getStringSync($r('app.string.no_data_placeholder_582947361852')))
            .width('100%')
            .padding({ top: 50 })
            .textAlign(TextAlign.Center)
            .fontSize(18)
        }
      } else {
        ForEach(this.dataArr, (item: WxAddFriendModel, index: number) => {
          ListItem() {
            JhSetCell({
              leftImgWH: 40,
              cellHeight: 55,
              lineLeftEdge: 65,
              title: item.title,
              hiddenArrow: true,
              leftWidget: () => {
                this.leftBuilder(item.img!)
              },
              clickCallBack: (): void => this.clickCell(item.title!),
            })
          }
        })
      }
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })

    // .divider({
    //   strokeWidth: 0.5,
    //   startMargin: 65,
    //   endMargin: 0,
    //   color: KColors.kLineColor
    // })
  }

  @Builder
  header() {
    Search({ value: '', placeholder: getContext(this).resourceManager.getStringSync($r('app.string.search_placeholder_629384751639')) })
      .borderRadius(5)
      .margin(10)
      .backgroundColor(Color.White)
      .onSubmit((value: string) => {
      })
      .onChange((value: string) => {
      })
  }

  @Builder
  leftBuilder(img: string) {
    Image($rawfile(img))
      .width(40)
      .height(40)
      .borderRadius(3)
  }

  clickCell(text: string) {
    const clickPrefix: string = getContext(this).resourceManager.getStringSync($r('app.string.click_prefix_text_847392618475'))
    JhProgressHUD.showText(`${clickPrefix} ${text}`)
  }

  getData(): WxAddFriendModel[] {
    const lovingFamilyName: string = getContext(this).resourceManager.getStringSync($r('app.string.loving_family_group_573829461847'))
    const groupChat2Name: string = getContext(this).resourceManager.getStringSync($r('app.string.group_chat_2_name_392847516293'))
    const groupChat3Name: string = getContext(this).resourceManager.getStringSync($r('app.string.group_chat_3_name_758394627184'))
    const groupChat4Name: string = getContext(this).resourceManager.getStringSync($r('app.string.group_chat_4_name_184759362847'))
    const groupChat666Name: string = getContext(this).resourceManager.getStringSync($r('app.string.group_chat_666_name_629384751952'))
    const hhhhhName: string = getContext(this).resourceManager.getStringSync($r('app.string.hhhhhh_group_name_758394627184'))
    const helloMsg: string = getContext(this).resourceManager.getStringSync($r('app.string.hello_greeting_message_847392615738'))
    const imageMsg: string = getContext(this).resourceManager.getStringSync($r('app.string.image_placeholder_573829461847'))
    const emojiMsg: string = getContext(this).resourceManager.getStringSync($r('app.string.animation_emoji_text_392847516293'))
    const hiMsg: string = getContext(this).resourceManager.getStringSync($r('app.string.hi_greeting_message_184759362847'))

    const dataArr: WxAddFriendModel[] = [
      {
        'title': lovingFamilyName,
        'subtitle': lovingFamilyName,
        'img': 'images/picture/touxiang_1.jpeg',
      },
      {
        'title': groupChat2Name,
        'subtitle': helloMsg,
        'img': 'images/picture/touxiang_2.jpeg',
      },
      {
        'title': groupChat3Name,
        'subtitle': imageMsg,
        'img': 'images/picture/touxiang_3.jpeg',
      },
      {
        'title': groupChat4Name,
        'subtitle': emojiMsg,
        'img': 'images/picture/touxiang_4.jpeg',
      },
      {
        'title': groupChat666Name,
        'subtitle': '',
        'img': 'images/picture/touxiang_5.jpeg',
      },
      {
        'title': hhhhhName,
        'subtitle': hiMsg,
        'img': 'images/picture/touxiang_6.jpg',
      },
    ];
    return dataArr;
  }
}