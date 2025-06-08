import { BaseTabBar } from './BaseTabBar'
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';
import { JhAlert, JhDialog, JhProgressHUD } from 'JhCommon';
import { LoginPage } from './login/pages/LoginPage';
import { router } from '@kit.ArkUI';

interface RouterParams {
  tabIndex?: number;
  refresh?: boolean;
  timestamp?: number;
}

@Entry
@Component
struct Index {
  @State initialTabIndex: number = 0;

  aboutToAppear() {
    // 初始化Loading和Dialog
    let uiContext: UIContext = this.getUIContext()
    JhDialog.initConfig(uiContext)
    JhProgressHUD.initUIConfig(uiContext)
    JhAlert.initConfig()

    try {
      const params = router.getParams() as RouterParams;
      if (params && params.tabIndex !== undefined) {
        this.initialTabIndex = params.tabIndex;
      }
    } catch (error) {
      console.error('获取路由参数失败:', error);
    }
  }

  build() {
    Column() {
      if (this.switchRootPage() == 'BaseTabBar') {
        BaseTabBar({ initialIndex: this.initialTabIndex })
      } else {
        LoginPage()
      }
    }
    .backgroundColor("#eeeeee")
    .width('100%')
    .height('100%')
  }

  switchRootPage(): 'BaseTabBar' | 'LoginPage' {
    const userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo)
    if (userInfo) {
      console.log('本地取出的 userInfo', JSON.stringify(userInfo))
      return 'BaseTabBar'
    } else {
      return 'LoginPage'
    }
  }
}
