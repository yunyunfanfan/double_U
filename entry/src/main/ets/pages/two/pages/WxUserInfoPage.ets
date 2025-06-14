/// description: 用户信息

import { router } from '@kit.ArkUI'
import { BaseNavigation, JhProgressHUD, JhSetCell, KColors } from 'JhCommon'
import { WxContactsModel } from '../models/WxContactsModel';
import { UserApiService, userApiService } from '../../../services/api_network/UserApiService';

const _cellH = 55.0;
const _rowSpace = 6.0;

interface RouterParams {
  data: WxContactsModel;
}

interface UserInfo {
  userId: string;
  userName: string;
  phone: string;
  loginTime: string;
}

@Entry
@Preview
@Component
struct WxUserInfoPage {
  jumpParams: WxContactsModel = new WxContactsModel()
  @State model: WxContactsModel = new WxContactsModel()
  @State avatarUrl: string = ''
  @State currentUserId: number = 0
  @State targetUserId: number = 0
  @State isDeleting: boolean = false

  aboutToAppear() {
    console.info('[用户详情] 页面初始化');
    this.loadCurrentUserId();
    this.loadRouterParams();
    this.loadUserAvatar();
    this.loadTargetUserId();
  }

  private loadCurrentUserId(): void {
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        const userInfo: UserInfo = JSON.parse(userInfoStr) as UserInfo;
        this.currentUserId = parseInt(userInfo.userId);
        console.info('[用户详情] 当前登录用户ID:', this.currentUserId);
      } else {
        console.error('[用户详情] 未找到登录用户信息');
        this.currentUserId = 1;
      }
    } catch (error) {
      console.error('[用户详情] 获取当前用户ID失败:', error);
      this.currentUserId = 1;
    }
  }

  private loadRouterParams(): void {
    try {
      const params = router.getParams() as RouterParams;
      if (params && params.data) {
        this.jumpParams = params.data;
        this.model = params.data;
        console.info('[用户详情] 跳转参数加载成功');
        console.info('[用户详情] 用户名称：', this.model.name);
      }
    } catch (error) {
      console.error('[用户详情] 获取路由参数失败:', error);
    }
  }

  private async loadTargetUserId(): Promise<void> {
    if (this.model.user_id) {
      this.targetUserId = this.model.user_id;
      console.info('[用户详情] 直接获取目标用户ID:', this.targetUserId);
      return;
    }

    if (this.model.name) {
      console.info('[用户详情] 通过用户名查询用户ID:', this.model.name);
      try {
        const result = await userApiService.getUserIdByName(this.model.name as string);
        if (result.success && result.user_id) {
          this.targetUserId = result.user_id;
          console.info('[用户详情] 查询到目标用户ID:', this.targetUserId);
        } else {
          console.error('[用户详情] 查询用户ID失败:', result.message);
        }
      } catch (error) {
        console.error('[用户详情] 查询用户ID异常:', error);
      }
    }
  }

  private loadUserAvatar(): void {
    if (this.model.avatarUrl) {
      this.avatarUrl = UserApiService.getUserDisplayAvatar(this.model.avatarUrl as string);
    } else {
      this.avatarUrl = UserApiService.getDefaultAvatarUrl();
    }
    console.info('[用户详情] 加载头像:', this.avatarUrl);
  }

  private async deleteFamilyMember(): Promise<void> {
    console.info('[用户详情] 尝试删除家庭成员，当前用户:', this.currentUserId, '目标用户:', this.targetUserId);
    if (!this.targetUserId) {
      JhProgressHUD.showText('用户信息错误，无法删除');
      return;
    }

    this.isDeleting = true;
    console.info('[用户详情] 开始删除家庭成员，当前用户:', this.currentUserId, '目标用户:', this.targetUserId);

    try {
      const result = await userApiService.removeFamilyMember(this.currentUserId, this.targetUserId);
      console.info(`[用户详情] 删除请求参数: ${this.currentUserId}, ${this.targetUserId}`);
      if (result.success) {
        console.info('[用户详情] 删除成功:', result.message);
        JhProgressHUD.showText('删除成功');
        setTimeout(() => {
          router.replaceUrl({
            url: 'pages/Index',
            params: {
              tabIndex: 1,
              refresh: true,
              timestamp: Date.now()
            }
          });
        }, 1500);
      } else {
        console.error('[用户详情] 删除失败:', result.message);
        JhProgressHUD.showText(`删除失败: ${result.message}`);
      }
    } catch (error) {
      console.error('[用户详情] 删除异常:', error);
      JhProgressHUD.showText('删除失败，请重试');
    } finally {
      this.isDeleting = false;
    }
  }

  build() {
    Column() {
      BaseNavigation({
        title: '详细资料',
        bgColor: Color.Transparent
      })
      List() {
        this.header()
        this.body()
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: true
      })
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    Blank().height(0.5).width('100%').backgroundColor(KColors.kLineColor)
    JhSetCell({
      cellHeight: _cellH,
      title: '健康状况',
      text: '良好',
      textAlign: TextAlign.Start,
      clickCallBack: (): void => {
        if (this.targetUserId) {
          router.pushUrl({
            url: 'pages/one/pages/WxHomePage',
            params: { user_id: this.targetUserId }
          });
        }
      },
    })
    Blank().height(_rowSpace)
    Text(this.isDeleting ? '删除中...' : getContext(this).resourceManager.getStringSync($r('app.string.delete_member_9285047361')))
      .fontSize(18)
      .fontColor(this.isDeleting ? Color.Gray : Color.Red)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height(_cellH)
      .backgroundColor(KColors.kCellBgColor)
      .onClick(() => {
        if (!this.isDeleting) {
          this.deleteFamilyMember();
        }
      })
  }

  @Builder
  header() {
    Row() {
      if (this.avatarUrl) {
        Image(this.avatarUrl)
          .width(66)
          .height(66)
          .margin({ left: 20, top: 3, right: 15 })
          .borderRadius(5)
          .objectFit(ImageFit.Cover)
      } else {
        Text((this.model.name as string).substring(0, 1))
          .fontColor(Color.White)
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .width(66)
          .height(66)
          .margin({ left: 20, top: 3, right: 15 })
          .borderRadius(5)
          .backgroundColor(this.model.color as string)
      }

      Column() {
        Row() {
          Text(this.model.name as string)
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
          Blank().width(5)
          Text() {
            SymbolSpan($r('sys.symbol.person'))
              .fontWeight(FontWeight.Bold)
              .fontSize(20)
              .fontColor([this.model.sex == '0' ? '#2196F3' : '#FF5252'])
          }
        }

        Blank().height(3)
        Text('昵称: ' + (this.model.namePinyin as string)).fontSize(16).fontColor(Color.Gray)
        Blank().height(3)
        Text('手机号: ' + (this.model.phone as string)).fontSize(16).fontColor(Color.Gray)
        Blank().height(3)
        Text('地区: ' + (this.model.region as string || '未知')).fontSize(16).fontColor(Color.Gray)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(70)

      if (this.model.isStar) {
        Text() {
          SymbolSpan($r('sys.symbol.star_fill'))
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .fontColor([Color.Yellow])
        }
        .layoutWeight(15)
      }
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .padding({ top: 10, bottom: 20 })
    .backgroundColor(KColors.kCellBgColor)
  }

  clickCell(text: string) {
    JhProgressHUD.showText(`点击了 ${text}`)
  }
}