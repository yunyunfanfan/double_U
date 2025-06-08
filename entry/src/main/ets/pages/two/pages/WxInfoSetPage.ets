
///资料设置页面(黑名单)

import { router } from '@kit.ArkUI';
import { BaseNavigation, JhProgressHUD, JhSetCell, KColors } from 'JhCommon'
import { WxContactsModel } from '../models/WxContactsModel';

const _cellH = 55.0;
const _rowSpace = 6.0;

@Entry
@Preview
@Component
struct WxInfoSetPage {
  jumpParams = (router.getParams() as Record<string, string>)['data']
  @State model: WxContactsModel = new WxContactsModel()
  @State switchSelected: boolean = false
  @State switchSelected2: boolean = false

  aboutToAppear() {
    this.model = this.jumpParams as WxContactsModel
    this.switchSelected = this.model.isStar!;
  }

  build() {
    Column() {
      BaseNavigation({ title: getContext(this).resourceManager.getStringSync($r('app.string.profile_settings_title_8472936851')), bgColor: Color.Transparent })
      this.body()
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    List() {
      ListItem() {
        Column() {
          JhSetCell({
            cellHeight: _cellH,
            title: getContext(this).resourceManager.getStringSync($r('app.string.health_condition_7293684152')),
            text: this.model.label,
            clickCallBack: (): void => {
              router.pushUrl({ url: 'pages/two/pages/mama', params: {} })
            },
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            title: getContext(this).resourceManager.getStringSync($r('app.string.set_special_care_member_5948372610')),
            hiddenLine: true,
            hiddenArrow: true,
            rightWidget: () => {
              this.rightBuilder(this.switchSelected, false)
            },
            clickCallBack: (): void => {
              const specialCareText: string = getContext(this).resourceManager.getStringSync($r('app.string.set_special_care_member_5948372610'))
              this.clickCell(specialCareText)
            },
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            title: getContext(this).resourceManager.getStringSync($r('app.string.add_to_blacklist_3761829450')),
            hiddenArrow: true,
            rightWidget: () => {
              this.rightBuilder(this.switchSelected2, true)
            },
            clickCallBack: (): void => {
              const blacklistText: string = getContext(this).resourceManager.getStringSync($r('app.string.add_to_blacklist_3761829450'))
              this.clickCell(blacklistText)
            },
          })
          Blank().height(_rowSpace)
          Text(getContext(this).resourceManager.getStringSync($r('app.string.delete_member_9285047361')))
            .fontSize(18)
            .fontColor(Color.Red)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')
            .height(_cellH)
            .backgroundColor(KColors.kCellBgColor)
            .onClick(() => {
              const deleteText: string = getContext(this).resourceManager.getStringSync($r('app.string.delete_member_9285047361'))
              this.clickCell(deleteText)
            })
        }
      }
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
  }

  @Builder
  rightBuilder(value: boolean, isTwo: boolean) {
    Toggle({ type: ToggleType.Switch, isOn: value })//
      // .selectedColor('#007DFF')
      .selectedColor(KColors.kThemeColor)
      .switchPointColor(Color.White)
      .onChange((isOn: boolean) => {
        if (isTwo) {
          this.switchSelected2 = isOn
        } else {
          this.switchSelected = isOn
        }
      })
  }

  clickCell(text: string) {
    const clickText: string = getContext(this).resourceManager.getStringSync($r('app.string.click_action_6174930258'))
    JhProgressHUD.showText(`${clickText} ${text}`)
  }
}