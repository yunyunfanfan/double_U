import { BaseTabBar } from './BaseTabBar'
import { JhAlert, JhDialog, JhProgressHUD } from 'JhCommon';
import { LoginPage } from './login/pages/LoginPage';
import { router } from '@kit.ArkUI';

interface RouterParams {
  tabIndex?: number;
  refresh?: boolean;
  timestamp?: number;
}

interface UserData {
  userId: string;
  userName: string;
  phone: string;
  loginTime: string;
}

@Entry
@Component
struct Index {
  @State initialTabIndex: number = 0;

  aboutToAppear() {
    console.info('[Index] 页面初始化开始')
    // 初始化持久化存储
    PersistentStorage.persistProp('userInfo', '');
    // 初始化Loading和Dialog
    let uiContext: UIContext = this.getUIContext()
    JhDialog.initConfig(uiContext)
    JhProgressHUD.initUIConfig(uiContext)
    JhAlert.initConfig()

    try {
      const params = router.getParams() as RouterParams;
      if (params && params.tabIndex !== undefined) {
        this.initialTabIndex = params.tabIndex;
        console.info('[Index] 获取到路由参数tabIndex:', params.tabIndex)
      }
    } catch (error) {
      console.error('[Index] 获取路由参数失败:', error);
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
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr && userInfoStr.trim() !== '') {
        const userInfo: UserData = JSON.parse(userInfoStr) as UserData;
        console.info('[Index] 用户已登录:', userInfo.userName)
        return 'BaseTabBar'
      } else {
        console.info('[Index] 用户未登录，显示登录页面')
        return 'LoginPage'
      }
    } catch (error) {
      console.error('[Index] 检查登录状态失败:', error)
      return 'LoginPage'
    }
  }
}