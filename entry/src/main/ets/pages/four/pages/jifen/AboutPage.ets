import { router } from '@kit.ArkUI'
import { BaseNavigation, JhAESPreferencesUtils, JhProgressHUD, KColors, kUserDefault_UserInfo } from 'JhCommon'
import { hilog } from '@kit.PerformanceAnalysisKit'

// 健康积分中的"关于"页面

@Entry
@Component
export struct AboutPage {
  aboutToAppear(): void {
    hilog.info(0x0000, 'AboutPage', '关于页面初始化开始')
    hilog.info(0x0000, 'AboutPage', '关于页面组件创建完成')
  }

  aboutToDisappear(): void {
    hilog.info(0x0000, 'AboutPage', '关于页面即将销毁')
  }

  onPageShow(): void {
    hilog.info(0x0000, 'AboutPage', '关于页面显示')
  }

  onPageHide(): void {
    hilog.info(0x0000, 'AboutPage', '关于页面隐藏')
  }

  build() {
    Column() {
      BaseNavigation({
        title: $r('app.string.my_points'),
        bgColor: Color.Transparent,
        leftItemCallBack: () => {
          hilog.info(0x0000, 'AboutPage', '用户点击返回按钮')
          router.back()
        }
      })

      Column() {
        Text($r('app.string.badge_icon_source'))
          .fontSize(18)
          .fontColor('#333333')
          .margin({ top: 30 })
          .textAlign(TextAlign.Center)
          .onClick(() => {
            hilog.info(0x0000, 'AboutPage', '用户点击徽章图标来源文本')
          })

        Text($r('app.string.final_interpretation_rights'))
          .fontSize(18)
          .fontColor('#333333')
          .margin({ top: 30 })
          .textAlign(TextAlign.Center)
          .onClick(() => {
            hilog.info(0x0000, 'AboutPage', '用户点击版权声明文本')
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}