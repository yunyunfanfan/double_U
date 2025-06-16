import { router } from '@kit.ArkUI'
import { JhTextList, ItemType, JhSetCell, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

@Entry
@Preview
@Component
export struct SetPage {
  private _rowSpace: number = 24
  private _cellH: number = 72
  private _paddingValue: number = 24

  dataArr: ItemType[] = [
    { label: $r('app.string.theme_settings') },
    { label: $r('app.string.multilingual') },
    { label: $r('app.string.about_icon') },
    { label: $r('app.string.logout') },
  ]

  build() {
    Scroll() {
      Column() {
        JhTextList({
          title: $r('app.string.settings_title'),
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
        router.pushUrl({ url: 'pages/four/pages/setpage/ThemeSettingPage' })
        break
      case 1:
        router.pushUrl({ url: 'pages/four/pages/setpage/polyglot' })
        break
      case 2:
        router.pushUrl({ url: 'pages/four/pages/setpage/About_page' })
        break
      case 3:
        JhAlert.showSystemAlert({
          title: $r('app.string.logout_confirm_title'),
          message: $r('app.string.logout_confirm_message'),
          leftText: getContext(this).resourceManager.getStringSync($r('app.string.cancel_button').id),
          rightText: getContext(this).resourceManager.getStringSync($r('app.string.confirm_button').id),
          onConfirm: (): void => this.exitLogin()
        })
        break
    }
  }

  private exitLogin() {
    console.info('[SetPage] 开始退出登录流程')
    const loadingText = getContext(this).resourceManager.getStringSync($r('app.string.logging_out').id)
    JhProgressHUD.showLoadingText(loadingText)

    setTimeout(() => {
      try {
        // 清除持久化存储中的用户信息
        console.info('[SetPage] 清除持久化存储中的用户信息')
        JhAESPreferencesUtils.delete(kUserDefault_UserInfo)

        // 清除PersistentStorage中的用户信息
        console.info('[SetPage] 清除PersistentStorage中的用户信息')
        PersistentStorage.deleteProp('userInfo')

        // 清除AppStorage中的用户信息
        console.info('[SetPage] 清除AppStorage中的用户信息')
        AppStorage.delete('userInfo')

        console.info('[SetPage] 用户信息清除完成，跳转到登录页面')
        router.pushUrl({ url: 'pages/login/pages/LoginPage' })
        router.clear();
        JhProgressHUD.hide()
      } catch (error) {
        console.error('[SetPage] 退出登录过程中发生错误:', error)
        JhProgressHUD.hide()
        JhProgressHUD.showError('退出登录失败')
      }
    }, 1000)
  }

  @Builder
  body() {
    List() {
      ListItem() {
        Column() {
          Blank().height(this._rowSpace)
          JhSetCell({
            cellHeight: this._cellH,
            leftIcon: $rawfile("wechat/mine/ic_wallet.png"),
            title: '服务',
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell('服务'),
          })
        }
      }
    }
  }

  private clickCell(arg: string): void {
  }
}