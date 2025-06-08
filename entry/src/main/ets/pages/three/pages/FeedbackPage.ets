import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';

@Entry
@Component
export struct FeedbackPage {
  @State feedbackType: string = '';
  @State content: string = '';
  @State contact: string = '';
  @State showSuccess: boolean = false;
  @State types: string[] = [];

  aboutToAppear() {
    this.initData();
  }

  initData() {
    this.feedbackType = getContext(this).resourceManager.getStringSync($r('app.string.type_suggestion'));
    this.types = [
      getContext(this).resourceManager.getStringSync($r('app.string.type_suggestion')),
      getContext(this).resourceManager.getStringSync($r('app.string.type_bug')),
      getContext(this).resourceManager.getStringSync($r('app.string.type_experience')),
      getContext(this).resourceManager.getStringSync($r('app.string.type_other'))
    ];
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back'))
            .width(20)
            .height(20)
        }
        .onClick(() => {
          try {
            router.back();
          } catch (err) {
            router.pushUrl({ url: 'pages/three/pages/WxDiscoverPage' });
          }
        })
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .margin({ left: 10 })
        Blank().layoutWeight(1)
        Text($r('app.string.feedback_title'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
          .margin({ top: 20, bottom: 20 })
        Blank().layoutWeight(1)
        Blank().width(40).height(40).margin({ right: 10 })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F8F8F8')

      Column() {
        Text($r('app.string.feedback_type'))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
          .margin({ top: 20, bottom: 12 })

        Row() {
          ForEach(this.types, (type: string) => {
            Button(type)
              .onClick(() => { this.feedbackType = type; })
              .width(80)
              .height(36)
              .backgroundColor(this.feedbackType === type ? '#4285F4' : '#F5F5F5')
              .fontColor(this.feedbackType === type ? Color.White : '#666666')
              .borderRadius(18)
              .margin({ right: 8 })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }

      Column() {
        Text($r('app.string.feedback_content'))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
          .margin({ top: 20, bottom: 12 })

        TextArea({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.content_placeholder_back')) })
          .height(200)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding(12)
          .margin({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.content = value;
          })
      }

      Column() {
        Text($r('app.string.contact_info'))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
          .margin({ top: 20, bottom: 12 })

        TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.contact_placeholder')) })
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .margin({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.contact = value;
          })
      }

      Button($r('app.string.submit_feedback'))
        .onClick(() => {
          if (!this.content) {
            return;
          }
          this.showSuccess = true;
        })
        .width('90%')
        .height(48)
        .backgroundColor('#4285F4')
        .fontColor(Color.White)
        .borderRadius(24)
        .margin({ top: 32, bottom: 32 })

      if (this.showSuccess) {
        Column() {
          Image($r('app.media.ic_success'))
            .width(64)
            .height(64)
            .margin({ bottom: 16 })
          Text($r('app.string.feedback_success'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#222222')
            .margin({ bottom: 8 })
          Text($r('app.string.feedback_thanks'))
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 24 })
          Button($r('app.string.back'))
            .onClick(() => {
              try {
                router.back();
              } catch (err) {
                router.pushUrl({ url: 'pages/three/pages/WxDiscoverPage' });
              }
            })
            .width(120)
            .height(40)
            .backgroundColor('#4285F4')
            .fontColor(Color.White)
            .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .backgroundColor('#FFFFFF')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}