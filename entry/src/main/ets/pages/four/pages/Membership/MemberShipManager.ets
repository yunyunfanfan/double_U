//这是会员支付方式页面

import { BaseNavigation, JhProgressHUD, JhSetCell, KColors } from 'JhCommon'
import { router } from '@kit.ArkUI';

const _cellH = 55.0;
const _rowSpace = 6.0;

@Entry
@Preview
@Component
struct WxPayManagerPage {
  @State switchSelected: boolean = false
  @State switchSelected2: boolean = true

  build() {
    Column() {
      BaseNavigation({ title: $r('app.string.member_title'), bgColor: Color.Transparent })
      this.body()
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    List() {
      ListItem() {
        Column() {
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            title: $r('app.string.real_name_auth'),
            text: $r('app.string.verified'),
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell('real_name_auth'),
          })

          JhSetCell({
            cellHeight: _cellH,
            title: $r('app.string.billing_service'),
            clickCallBack: (): void => this.clickCell('billing_service'),
          })
          JhSetCell({
            cellHeight: _cellH,
            title: $r('app.string.refund_method'),
            text: $r('app.string.refund_to_original'),
            clickCallBack: (): void => this.clickCell('refund_method'),
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            title: $r('app.string.service_management'),
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell('service_management'),
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            title: $r('app.string.member_benefits'),
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell('member_benefits'),
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            titleWidth: 150,
            title: $r('app.string.member_expiry_time'),
            hiddenLine: true,
            clickCallBack: (): void => this.clickCell('member_expiry_time'),
          })
          Blank().height(15)
        }
      }
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
  }

  clickCell(title: string): void {
    console.error('点击cell', title)
    if (title === 'member_expiry_time') {
      router.pushUrl({ url: "/pages/four/pages/Membership/MemberTime" })
    }
    if (title === "member_benefits") {
      router.pushUrl({ url: "/pages/four/pages/Membership/MemberRights" })
    }
  }
}