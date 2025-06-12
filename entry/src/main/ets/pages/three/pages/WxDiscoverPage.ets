import { BaseNavigation, JhProgressHUD, JhSetCell, KColors, JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon'
import { router } from '@kit.ArkUI';
import { UserApiService, userApiService, UserProfileResponse } from '../../../services/api_network/UserApiService';

///这是第二页主页

const _cellH = 55.0;
const _leftSpace = 50.0;
const _rowSpace = 6.0;

interface ServerUserInfo {
  userID: string;
  userName: string;
  phone: string;
  pwd: string;
  token: string;
  avatarUrl: string;
  patContent?: string;
  healthCode?: string;
}

interface AvatarInfo {
  serverUrl: string;
  uploadStatus: 'uploading' | 'success' | 'failed' | 'none';
}

@Entry
@Preview
@Component
export struct WxDiscoverPage {
  @State titleText: string = '';
  @State healthCircleText: string = '';
  @State commonQuestionsText: string = '';
  @State feedbackText: string = '';
  @State customerServiceText: string = '';
  @State sleepMusicText: string = '';
  @State sleepImprovementText: string = '';
  @State fatigueReliefText: string = '';
  @State diseaseMedicationText: string = '';
  @State clickActionText: string = '';
  @State avatarInfo: AvatarInfo = {
    serverUrl: '',
    uploadStatus: 'none'
  }
  @State currentUserId: number = 1

  // 从服务器加载用户资料
  private async loadUserProfile(): Promise<void> {
    try {
      console.info(`[发现页面] 开始从服务器加载用户${this.currentUserId}的资料`);

      const profileResult: UserProfileResponse = await userApiService.getUserProfile(this.currentUserId);

      if (profileResult.success && profileResult.data) {
        if (profileResult.data.avatar_url) {
          this.avatarInfo.serverUrl = profileResult.data.avatar_url;
        }
        console.info(`[发现页面] 服务器资料加载成功，头像: ${profileResult.data.avatar_url || '无'}`);
      } else {
        console.error(`[发现页面] 服务器资料加载失败: ${profileResult.message}`);
      }
    } catch (error) {
      console.error(`[发现页面] 服务器资料加载异常: ${error}`);
    }
  }

  // 获取显示的头像源
  private getAvatarSource(): string | Resource {
    if (this.avatarInfo.serverUrl) {
      return UserApiService.getAvatarUrl(this.avatarInfo.serverUrl);
    }
    return 'https://gitee.com/zhaozehe/zako/raw/master/ic_535a5f26fa59f35f023467562ae1388e.png';
  }

  aboutToAppear(): void {
    this.titleText = getContext(this).resourceManager.getStringSync($r('app.string.device_and_others_title'));
    this.healthCircleText = getContext(this).resourceManager.getStringSync($r('app.string.health_circle'));
    this.commonQuestionsText = getContext(this).resourceManager.getStringSync($r('app.string.common_questions'));
    this.feedbackText = getContext(this).resourceManager.getStringSync($r('app.string.feedback'));
    this.customerServiceText = getContext(this).resourceManager.getStringSync($r('app.string.customer_service'));
    this.sleepMusicText = getContext(this).resourceManager.getStringSync($r('app.string.sleep_music'));
    this.sleepImprovementText = getContext(this).resourceManager.getStringSync($r('app.string.sleep_improvement'));
    this.fatigueReliefText = getContext(this).resourceManager.getStringSync($r('app.string.fatigue_relief'));
    this.diseaseMedicationText = getContext(this).resourceManager.getStringSync($r('app.string.disease_medication'));
    this.clickActionText = getContext(this).resourceManager.getStringSync($r('app.string.click_action'));

    this.loadUserInfo();
  }

  loadUserInfo(): void {
    console.info('[发现页面] 开始加载用户信息');

    // 获取当前用户ID
    let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as ServerUserInfo;
    if (userInfo && userInfo.userID) {
      this.currentUserId = parseInt(userInfo.userID);
    }

    // 从服务器加载最新的用户资料
    this.loadUserProfile();
  }

  build() {
    Column() {
      BaseNavigation({ title: this.titleText, bgColor: Color.Transparent, leftItem: {} })
      Scroll() {
        Column() {
          this.body()
        }
        .height('100%')
      }
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: true
      })
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    JhSetCell({
      cellHeight: _cellH,
      leftIcon: $rawfile("wechat/discover/ic_social_circle.png"),
      title: this.healthCircleText,
      hiddenLine: true,
      rightWidget: (): void => this.rightBuilder(),
      clickCallBack: () => {
        this.clickCell(this.healthCircleText)
      },
    })
    Blank().height(_rowSpace)
    JhSetCell({
      cellHeight: _cellH,
      lineLeftEdge: _leftSpace,
      leftIcon: $rawfile("wechat/discover/ic_quick_scan.png"),
      title: this.commonQuestionsText,
      clickCallBack: (): void => this.clickCell(this.commonQuestionsText),
    })
    Blank().height(_rowSpace)
    JhSetCell({
      cellHeight: _cellH,
      lineLeftEdge: _leftSpace,
      leftIcon: $rawfile("wechat/discover/ic_feeds.png"),
      title: this.feedbackText,
      clickCallBack: (): void => this.clickCell(this.feedbackText),
    })
    JhSetCell({
      cellHeight: _cellH,
      leftIcon: $rawfile("wechat/discover/ic_quick_search.png"),
      title: this.customerServiceText,
      hiddenLine: true,
      clickCallBack: (): void => this.clickCell(this.customerServiceText),
    })
    Blank().height(_rowSpace)
    JhSetCell({
      cellHeight: _cellH,
      leftIcon: $rawfile("wechat/discover/ic_people_nearby.png"),
      title: this.sleepMusicText,
      hiddenLine: true,
      clickCallBack: (): void => this.clickCell(this.sleepMusicText),
    })
    JhSetCell({
      cellHeight: _cellH,
      lineLeftEdge: _leftSpace,
      leftIcon: $rawfile("wechat/discover/ic_shopping.png"),
      title: this.sleepImprovementText,
      clickCallBack: (): void => this.clickCell(this.sleepImprovementText),
    })
    JhSetCell({
      cellHeight: _cellH,
      leftIcon: $rawfile("wechat/discover/ic_game_entry.png"),
      title: this.fatigueReliefText,
      hiddenLine: true,
      clickCallBack: (): void => this.clickCell(this.fatigueReliefText),
    })
    Blank().height(_rowSpace)
    JhSetCell({
      cellHeight: _cellH,
      leftIcon: $rawfile("wechat/discover/ic_mini_program.png"),
      title: this.diseaseMedicationText,
      hiddenLine: true,
      clickCallBack: (): void => this.clickCell(this.diseaseMedicationText),
    })
    Blank().height(15)
  }

  @Builder
  rightBuilder() {
    Row() {
      Badge({ value: '', position: BadgePosition.RightTop, style: { badgeSize: 6, badgeColor: '#FA2A2D' } }) {
        Image(this.getAvatarSource())
          .width(30).height(30)
          .margin({ top: 2.5, left: 2.5 })
          .borderRadius(15)
          .objectFit(ImageFit.Cover)
          .onError(() => {
            console.error('[发现页面] 头像加载失败')
          })
      }
      .width(35).height(35)
    }
  }

  clickCell(title: string): void {
    if (title === this.healthCircleText) {
      router.pushUrl({ url: 'pages/three/pages/WxFriendsCirclePage' })
    } else if (title === this.diseaseMedicationText) {
      router.pushUrl({ url: 'pages/three/pages/MedicineReminder' })
    } else if (title === this.sleepMusicText) {
      router.pushUrl({ url: 'pages/three/pages/SleepMusicPage' })
    } else if (title === this.sleepImprovementText) {
      router.pushUrl({ url: 'pages/three/pages/SleepImprovePage' })
    } else if (title === this.fatigueReliefText) {
      router.pushUrl({ url: 'pages/three/pages/FatigueReliefPage' })
    } else if (title === this.feedbackText) {
      router.pushUrl({ url: 'pages/three/pages/FeedbackPage' })
    } else if (title === this.customerServiceText) {
      router.pushUrl({ url: 'pages/three/pages/CustomerServicePage' })
    } else if (title === this.commonQuestionsText) {
      router.pushUrl({ url: 'pages/three/pages/CommonQuestionsPage' })
    } else {
      JhProgressHUD.showText(`${this.clickActionText} ${title}`)
    }
  }
}