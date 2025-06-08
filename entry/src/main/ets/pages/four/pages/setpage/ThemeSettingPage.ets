import { router } from '@kit.ArkUI'
import { JhTextList, ItemType, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

//主题设置页面

@Entry
@Preview
@Component
export struct SetPage {
  private _rowSpace: number = 24
  private _cellH: number = 72
  private _paddingValue: number = 24

  dataArr: ItemType[] = [
    { label: $r('app.string.light_mode') },
    { label: $r('app.string.dark_mode') },
    { label: $r('app.string.follow_system') },
    { label: $r('app.string.custom_theme') },
  ]

  build() {
    Scroll() {
      Column() {
        JhTextList({
          title: $r('app.string.theme_settings_title'),
          dataArr: this.dataArr,
          callBack: (index: number) => {
            this.handleCellClick(index)
          }
        })
      }
      .padding({
        top: 14,
        bottom: 14,
        left: this._paddingValue,
        right: this._paddingValue
      })
      .width('100%')
    }
    .backgroundColor(0xF5F6FA)
  }

  private handleCellClick(index: number) {
    switch (index) {
      case 0:
        this.setThemeMode('light')
        break
      case 1:
        this.setThemeMode('dark')
        break
      case 2:
        this.setThemeMode('auto')
        break
      case 3:
        router.pushUrl({ url: 'pages/four/pages/setpage/CustomThemePage' })
        break
    }
  }

  private setThemeMode(mode: string) {
    const loadingText = getContext(this).resourceManager.getStringSync($r('app.string.setting_theme').id)
    JhProgressHUD.showLoadingText(loadingText)
    setTimeout(() => {
      JhProgressHUD.hide()
    }, 800)
  }
}