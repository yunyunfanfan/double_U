import { BaseNavigation, JhAESPreferencesUtils, JhProgressHUD, KColors, kUserDefault_UserInfo } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { WxMinePage } from './pages/WxMinePage';
//退出登录的逻辑实现, 还有保持四页面切换
@Entry
@Component
export struct FourPage {
  @State message: string = 'Four'

  aboutToAppear() {
    let useInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo)
    console.log('useInfo: ', JSON.stringify(useInfo))
  }

  build() {
    Column() {
      WxMinePage()
      // this.body()
      //哈哈, 这是原作者的小彩蛋哦
    }
    .height('100%')
    .width('100%')
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    Column() {
      BaseNavigation({ title: "Four", leftItem: {} })
      Button('退出登录').onClick((event: ClickEvent) => {
        this.exitLogin()
      })

      RelativeContainer() {
        Text(this.message)
          .id('FourPage')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
      }
      .height('100%')
      .width('100%')
    }
  }

  exitLogin() {
    JhProgressHUD.showLoadingText('正在退出...')
    setTimeout(() => {
      JhAESPreferencesUtils.delete(kUserDefault_UserInfo)
      router.replaceUrl({ url: 'pages/login/pages/LoginPage' })
      JhProgressHUD.hide()
    }, 1000)
  }
}