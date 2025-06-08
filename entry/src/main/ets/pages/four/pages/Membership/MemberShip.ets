///  WxPayPage.ets

//会员中心页面
import { BaseNavigation, KColors } from 'JhCommon'
import { router } from '@kit.ArkUI'

@Entry
@Preview
@Component
struct WxPayPage {
  @State currentMembership: string = '未开通会员';
  @State selectedPlan: string = 'monthly';
  @State showPayment: boolean = false;
  @State showPaySuccess: boolean = false;

  handlePlanSelect(plan: string) {
    this.selectedPlan = plan;
  }

  handleOpenMembership() {
    this.showPayment = true;
  }

  handleCancelPayment() {
    this.showPayment = false;
  }

  handleCompletePayment() {
    this.currentMembership = this.selectedPlan === 'monthly' ? '月度会员' : '年度会员';
    this.showPayment = false;
    this.showPaySuccess = true;

    setTimeout(() => {
      this.showPaySuccess = false;
    }, 2000);
  }

  getActivateButtonText(): Resource {
    return this.selectedPlan === 'monthly' ? $r('app.string.activate_monthly') : $r('app.string.activate_yearly');
  }

  getCurrentPrice(): Resource {
    return this.selectedPlan === 'monthly' ? $r('app.string.monthly_price') : $r('app.string.yearly_price');
  }

  getCurrentService(): Resource {
    return this.selectedPlan === 'monthly' ? $r('app.string.monthly_membership') : $r('app.string.yearly_membership');
  }

  getPaymentAmountText(): Resource {
    return this.selectedPlan === 'monthly' ? $r('app.string.payment_amount_monthly') : $r('app.string.payment_amount_yearly');
  }

  getPurchaseServiceText(): Resource {
    return this.selectedPlan === 'monthly' ? $r('app.string.purchase_service_monthly') : $r('app.string.purchase_service_yearly');
  }

  getCurrentMembershipText(): Resource {
    if (this.currentMembership === '未开通会员') return $r('app.string.not_member');
    if (this.currentMembership === '月度会员') return $r('app.string.monthly_member');
    if (this.currentMembership === '年度会员') return $r('app.string.yearly_member');
    return $r('app.string.not_member');
  }

  build() {
    Column() {
      BaseNavigation({
        title: $r('app.string.member_center_title'),
        bgColor: Color.Transparent,
        rightImgPath: $rawfile("images/ic_more_black.png"),
        rightItemCallBack: () => {
          router.pushUrl({ url: 'pages/four/pages/Membership/MemberShipManager' })
        },
      })

      Stack() {
        Column() {
          Text($r('app.string.member_center_title'))
            .fontSize(16)
            .fontColor('#333333')
            .margin({ top: 15, left: 15 })
            .alignSelf(ItemAlign.Start)

          Column() {
            Text(this.getCurrentMembershipText())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#007DFF')
              .margin({ top: 10, bottom: 15 })
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
      }
      .width('95%')
      .height(120)
      .margin({ top: 15, left: 10, right: 10 })
      .backgroundColor('#FFFFFF')
      .borderRadius(10)
      .shadow({ radius: 5, color: '#EEEEEE', offsetX: 0, offsetY: 2 })

      Stack() {
        Column() {
          Text($r('app.string.select_membership_plan'))
            .fontSize(16)
            .fontColor('#333333')
            .margin({ top: 15, left: 15 })
            .alignSelf(ItemAlign.Start)

          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
            Column() {
              Text($r('app.string.monthly_membership'))
                .fontSize(16)
                .fontColor(this.selectedPlan === 'monthly' ? '#FFFFFF' : '#007DFF')
                .margin({ top: 10 })

              Text($r('app.string.monthly_price'))
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.selectedPlan === 'monthly' ? '#FFFFFF' : '#007DFF')
                .margin({ top: 5 })

              Text($r('app.string.monthly_original_price'))
                .fontSize(12)
                .fontColor(this.selectedPlan === 'monthly' ? '#FFFFFF' : '#999999')
                .decoration({ type: TextDecorationType.LineThrough })
                .margin({ top: 5, bottom: 10 })
            }
            .width(100)
            .height(120)
            .backgroundColor(this.selectedPlan === 'monthly' ? '#007DFF' : '#FFFFFF')
            .border({ width: 1, color: this.selectedPlan === 'monthly' ? '#007DFF' : '#E5E5E5' })
            .borderRadius(8)
            .onClick((): void => this.handlePlanSelect('monthly'))

            Column() {
              Text($r('app.string.yearly_membership'))
                .fontSize(16)
                .fontColor(this.selectedPlan === 'yearly' ? '#FFFFFF' : '#007DFF')
                .margin({ top: 10 })

              Text($r('app.string.yearly_price'))
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.selectedPlan === 'yearly' ? '#FFFFFF' : '#007DFF')
                .margin({ top: 5 })

              Text($r('app.string.yearly_original_price'))
                .fontSize(12)
                .fontColor(this.selectedPlan === 'yearly' ? '#FFFFFF' : '#999999')
                .decoration({ type: TextDecorationType.LineThrough })
                .margin({ top: 5 })

              Text($r('app.string.yearly_savings'))
                .fontSize(12)
                .fontColor(this.selectedPlan === 'yearly' ? '#FFFFFF' : '#007DFF')
                .margin({ bottom: 10 })
            }
            .width(100)
            .height(120)
            .backgroundColor(this.selectedPlan === 'yearly' ? '#007DFF' : '#FFFFFF')
            .border({ width: 1, color: this.selectedPlan === 'yearly' ? '#007DFF' : '#E5E5E5' })
            .borderRadius(8)
            .onClick((): void => this.handlePlanSelect('yearly'))
          }
          .width('100%')
          .margin({ top: 20 })

          Button(this.getActivateButtonText())
            .width('90%')
            .height(50)
            .backgroundColor('#007DFF')
            .fontSize(18)
            .fontColor('#FFFFFF')
            .margin({ top: 30, bottom: 20 })
            .onClick(() => this.handleOpenMembership())
        }
        .width('100%')
      }
      .width('95%')
      .margin({ top: 30, left: 10, right: 10, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius(10)
      .shadow({ radius: 5, color: '#EEEEEE', offsetX: 0, offsetY: 2 })

      if (this.showPaySuccess) {
        Stack() {
          Column() {
            Image($rawfile("images/success.png"))
              .width(80)
              .height(80)
              .margin({ bottom: 15 })

            Text($r('app.string.payment_success'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .width(200)
          .height(150)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.7)
        .position({ x: 0, y: 0 })
        .zIndex(2)
      }

      if (this.showPayment) {
        Stack() {
          Stack()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.5)
            .onClick(() => this.handleCancelPayment())

          Stack() {
            Column() {
              Text($r('app.string.confirm_payment'))
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ top: 20 })

              Image($rawfile("images/fukuan.jpg"))
                .width('80%')
                .height(150)
                .margin({ top: 20 })
                .objectFit(ImageFit.Contain)

              Text(this.getPaymentAmountText())
                .fontSize(16)
                .fontColor('#333333')
                .margin({ top: 20 })

              Text(this.getPurchaseServiceText())
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 10 })

              Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
                Button($r('app.string.cancel_button'))
                  .height(45)
                  .backgroundColor('#E5E5E5')
                  .fontSize(16)
                  .fontColor('#333333')
                  .layoutWeight(1)
                  .margin({ right: 10 })
                  .onClick(() => this.handleCancelPayment())

                Button() {
                  Text($r('app.string.payment_completed'))
                    .fontSize(16)
                    .fontColor('#FFFFFF')
                    .maxFontSize(16)
                    .minFontSize(10)
                    .textAlign(TextAlign.Center)
                }
                .height(45)
                .backgroundColor('#007DFF')
                .layoutWeight(1)
                .margin({ left: 10 })
                .onClick(() => this.handleCompletePayment())
              }
              .width('90%')
              .margin({ top: 30, bottom: 20 })

            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .zIndex(1)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .alignContent(Alignment.Center)
        .zIndex(1)
      }
    }
    .backgroundColor(KColors.wxBgColor)
    .width('100%')
    .height('100%')
  }
}