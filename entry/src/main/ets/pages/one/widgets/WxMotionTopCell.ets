import { KColors } from "JhCommon";
import { WxMotionTopModel } from "../models/WxMotionTopModel";


@Preview
@Component
export struct WxMotionTopCell {
  @State model: WxMotionTopModel = new WxMotionTopModel();
  @State isPressed: boolean = false;
  public onClickCell?: (model: WxMotionTopModel) => void // 点击cell

  build() {
    Column() {
      Blank().height(10)
      Row() {
        Text((this.model.id! + 1).toString())
          .margin({ left: 15 })
          .fontSize(16)
          .fontWeight(this.model.isOwn ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.getRankColor(this.model.id! + 1))
          .layoutWeight(15)

        Row() {
          Row() {
            Text(this.model.name?.substring(0, 1))
              .fontSize(20)
              .fontColor(Color.White)
          }
          .justifyContent(FlexAlign.Center)
          .width(50)
          .height(50)
          .borderRadius(25)
          .backgroundColor(this.model.color)

          Text(this.model.name)
            .fontSize(16)
            .fontWeight(this.model.isOwn ? FontWeight.Bold : FontWeight.Normal)
            .margin({ left: 10 })
          Blank()
          Text(this.model.steps?.toString())
            .fontSize(28)
            .fontWeight(this.model.isOwn ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.getStepsColor(this.model.steps!))
            .margin({ right: 20 })
        }
        .layoutWeight(70)

        Column() {
          Text(this.model.starNum?.toString())
            .fontSize(12)
            .fontColor(Color.Gray)
          Blank().height(5)

          Text(this.model.isStar ? '❤️' : '♡')
            .fontWeight(FontWeight.Bold)
            .fontSize(20)
            .fontColor(this.model.isStar ? '#FF0000' : '#888888')
            .onClick((event) => {
              this.model.isStar = !this.model.isStar
              if (this.model.isStar == true) {
                this.model.starNum!++
              } else {
                this.model.starNum!--
              }
              return false;
            })
        }
        .layoutWeight(15)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Blank().height(10)
      Divider().color(KColors.kLineColor).strokeWidth(this.model.isOwn ? 1 : 1)
    }
    .backgroundColor(this.isPressed ? '#EEEEEE' : (this.model.isOwn ? '#F5F5F5' : Color.White))
    .onClick(() => this.onClickCell?.(this.model))
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
  }

  getRankColor(rank: number): ResourceColor {
    if (rank === 1) return '#FFD700' // Gold
    if (rank === 2) return '#C0C0C0' // Silver
    if (rank === 3) return '#CD7F32' // Bronze
    return this.model.color || '#000000'
  }

  getStepsColor(steps: number): ResourceColor {
    if (steps > 30000) return '#FF5722' // Outstanding
    if (steps > 20000) return '#FF9800' // Excellent
    if (steps > 10000) return '#4CAF50' // Good
    return KColors.wxTextColor
  }
}
