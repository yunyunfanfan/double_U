///  WxSearchUserPage.ets
///  description:  搜索用户页面

import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { router } from '@kit.ArkUI'
import { userApiService, SearchUserResponse, RegisterResponse, UserInfo } from '../../../services/api_network/UserApiService'

interface UserInfoFromStorage {
  userId: string;
  userName: string;
  phone: string;
  loginTime: string;
}

@Entry
@Component
struct WxSearchUserPage {
  @State searchValue: string = ''
  @State isSearching: boolean = false
  @State searchResult: UserInfo | null = null
  @State hasSearched: boolean = false
  @State currentUserId: number = 1

  aboutToAppear() {
    console.info('[搜索用户页面] 页面初始化开始');
    this.loadCurrentUser();
    this.loadSearchParams();
  }

  private loadCurrentUser(): void {
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        const userInfo: UserInfoFromStorage = JSON.parse(userInfoStr) as UserInfoFromStorage;
        if (userInfo && userInfo.userId) {
          this.currentUserId = parseInt(userInfo.userId);
          console.info(`[搜索用户页面] 当前用户ID: ${this.currentUserId}`);
        }
      }
    } catch (error) {
      console.error(`[搜索用户页面] 获取用户ID异常: ${error}`);
    }
  }

  private loadSearchParams(): void {
    try {
      const params = router.getParams() as Record<string, string>;
      if (params && params.searchValue) {
        this.searchValue = params.searchValue;
        console.info(`[搜索用户页面] 获取搜索参数: ${this.searchValue}`);
        this.performSearch();
      }
    } catch (error) {
      console.error(`[搜索用户页面] 获取参数异常: ${error}`);
    }
  }

  private async performSearch(): Promise<void> {
    if (!this.searchValue.trim()) {
      JhProgressHUD.showToast('请输入手机号');
      return;
    }

    this.isSearching = true;
    console.info(`[搜索用户页面] 开始搜索用户: ${this.searchValue}`);

    try {
      const response: SearchUserResponse = await userApiService.searchUserByPhone(this.searchValue, this.currentUserId);

      if (response.success && response.user) {
        const foundUser: UserInfo = {
          id: response.user.id,
          username: response.user.username,
          phone: response.user.phone
        };
        this.searchResult = foundUser;
        console.info(`[搜索用户页面] 搜索成功: ${foundUser.username}`);
      } else {
        this.searchResult = null;
        JhProgressHUD.showToast(response.message || '未找到用户');
        console.warn(`[搜索用户页面] 搜索失败: ${response.message}`);
      }
    } catch (error) {
      console.error(`[搜索用户页面] 搜索异常: ${error}`);
      JhProgressHUD.showToast('网络连接失败');
    } finally {
      this.isSearching = false;
      this.hasSearched = true;
    }
  }

  private async addFriend(): Promise<void> {
    if (!this.searchResult) return;

    console.info(`[搜索用户页面] 开始添加好友: ${this.searchResult.username}`);

    try {
      const response: RegisterResponse = await userApiService.addFamilyMember(
        this.currentUserId,
        this.searchResult.id,
        '朋友'
      );

      if (response.success) {
        JhProgressHUD.showToast('添加好友成功');
        console.info(`[搜索用户页面] 添加好友成功: ${this.searchResult.username}`);
        router.back();
      } else {
        JhProgressHUD.showToast(response.message || '添加失败');
        console.error(`[搜索用户页面] 添加好友失败: ${response.message}`);
      }
    } catch (error) {
      console.error(`[搜索用户页面] 添加好友异常: ${error}`);
      JhProgressHUD.showToast('网络连接失败');
    }
  }

  private maskPhoneNumber(phone: string): string {
    if (!phone || phone.length !== 11) {
      return '手机号未知';
    }
    return `${phone.substring(0, 3)}****${phone.substring(7)}`;
  }

  build() {
    Column() {
      BaseNavigation({
        title: '搜索用户',
        bgColor: Color.Transparent
      })

      this.searchHeader()
      this.searchContent()
    }
    .backgroundColor(KColors.wxBgColor)
    .width('100%')
    .height('100%')
  }

  @Builder
  searchHeader() {
    Column() {
      Search({
        value: this.searchValue,
        placeholder: '请输入手机号'
      })
        .borderRadius(5)
        .margin(15)
        .backgroundColor(Color.White)
        .onSubmit((value: string) => {
          this.searchValue = value;
          this.performSearch();
        })
        .onChange((value: string) => {
          this.searchValue = value;
        })
    }
    .backgroundColor(Color.White)
  }

  @Builder
  searchContent() {
    Column() {
      if (this.isSearching) {
        this.loadingView()
      } else if (this.searchResult) {
        this.userResultView()
      } else if (this.hasSearched) {
        this.noResultView()
      } else {
        this.emptyView()
      }
    }
    .layoutWeight(1)
    .padding(15)
  }

  @Builder
  loadingView() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#1698CE')

      Text('搜索中...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 10 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height(200)
  }

  @Builder
  userResultView() {
    if (this.searchResult) {
      Column() {
        Row() {
          Image('https://gitee.com/zhaozehe/zako/raw/master/ic_535a5f26fa59f35f023467562ae1388e.png')
            .width(50)
            .height(50)
            .borderRadius(25)
            .margin({ right: 15 })

          Column() {
            Text(this.searchResult.username)
              .fontSize(18)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ bottom: 5 })

            Text(`手机号: ${this.maskPhoneNumber(this.searchResult.phone)}`)
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Start)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('加好友')
            .width(80)
            .height(35)
            .backgroundColor('#1698CE')
            .fontColor(Color.White)
            .fontSize(14)
            .borderRadius(18)
            .onClick(() => {
              this.addFriend();
            })
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .alignItems(VerticalAlign.Center)
      }
      .margin({ top: 20 })
    }
  }

  @Builder
  noResultView() {
    Column() {
      Image($rawfile('wechat/contacts/add/add_friend_icon_search_wework_40x40_@2x.png'))
        .width(60)
        .height(60)
        .margin({ bottom: 15 })

      Text('未找到该用户')
        .fontSize(16)
        .fontColor('#666666')

      Text('请确认手机号是否正确')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 5 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height(200)
  }

  @Builder
  emptyView() {
    Column() {
      Image($rawfile('wechat/contacts/add/add_friend_icon_search_wework_40x40_@2x.png'))
        .width(60)
        .height(60)
        .margin({ bottom: 15 })

      Text('输入手机号搜索用户')
        .fontSize(16)
        .fontColor('#666666')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height(200)
  }
}