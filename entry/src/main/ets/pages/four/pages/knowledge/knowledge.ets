import { router } from '@kit.ArkUI'
import { JhTextList, ItemType, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon'

interface ExtendedItemType extends ItemType {
  pagePath?: string;
}

@Entry
@Component
struct SetPage {
  // 设计系统参数
  private _rowSpace: number = 24
  private _cellH: number = 72
  private _paddingValue: number = 24

  private getDataArr(): ExtendedItemType[] {
    return [
      {
        label: '  🏠 ' + getContext().resourceManager.getStringSync($r('app.string.family_disease_management')),
        pagePath: 'pages/four/pages/knowledge/knowledge_model1'
      },
      {
        label: '  🧠 ' + getContext().resourceManager.getStringSync($r('app.string.mental_health_protection')),
        pagePath: 'pages/four/pages/knowledge/knowledge_model2'
      },
      {
        label: '  🏃 ' + getContext().resourceManager.getStringSync($r('app.string.sports_health')),
        pagePath: 'pages/four/pages/knowledge/knowledge_model3'
      },
      {
        label: '  🍎 ' + getContext().resourceManager.getStringSync($r('app.string.nutrition_management')),
        pagePath: 'pages/four/pages/knowledge/knowledge_model4'
      },
      {
        label: '  🔒 ' + getContext().resourceManager.getStringSync($r('app.string.data_security')),
        pagePath: 'pages/four/pages/knowledge/knowledge_model5'
      },
    ]
  }

  build() {
    Scroll() {
      Column() {
        JhTextList({
          title: getContext().resourceManager.getStringSync($r('app.string.knowledge_topics')),
          dataArr: this.getDataArr(),
          callBack: (index: number) => {
            const item = this.getDataArr()[index];
            if (item?.pagePath) {
              // 添加正确的路径前缀
              router.pushUrl({
                url: item.pagePath
              })
            }
          }
        })
      }
      .padding({
        top: 4,
        bottom: 14,
        left: 13,
        right: 13
      })
      .width('100%')
    }
    .backgroundColor(0xF5F6FA)
  }

  private exitLogin(): void {
    JhProgressHUD.showLoadingText(getContext().resourceManager.getStringSync($r('app.string.logging_out')))
    setTimeout(() => {
      JhAESPreferencesUtils.delete(kUserDefault_UserInfo)
      router.replaceUrl({ url: 'pages/login/pages/LoginPage' })
      JhProgressHUD.hide()
    }, 1000)
  }
}