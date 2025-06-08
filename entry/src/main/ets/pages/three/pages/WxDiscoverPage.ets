import { BaseNavigation, JhProgressHUD, JhSetCell, KColors } from 'JhCommon'
import { router } from '@kit.ArkUI';

///这是第二页主页

const _cellH = 55.0;
const _leftSpace = 50.0;
const _rowSpace = 6.0;

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
        Image('https://gitee.com/zhaozehe/zako/raw/master/ic_535a5f26fa59f35f023467562ae1388e.png')
          .width(30).height(30)
          .margin({ top: 2.5, left: 2.5 })
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