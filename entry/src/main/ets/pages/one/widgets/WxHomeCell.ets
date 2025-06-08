import { WxHomeModel } from "../models/WxHomeModel";


@Preview
@Component
export struct WxHomeCell {
  model: WxHomeModel = new WxHomeModel();
  public onClickCell?: (model: WxHomeModel) => void // 点击cell

  build() {
    Row() {
      Row() {
        // Image($rawfile(this.model.img))
        //   .width(55).height(55)
        //   .borderRadius(5)
        //   .clip(true)

        Badge({ value: '', position: { x: 55 - 5, y: -5 }, style: { badgeSize: this.model.isNew ? 10 : 0, badgeColor: '#FA2A2D' } }) {
          Image($rawfile(this.model.img))
            .width(55)
            .height(55)
            .borderRadius(5)
            .clip(true)
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width(70)
      .height(70)

      Column() {
        Blank().height(8)
        Row() {
          Flex() {
            Text(this.model.title)
              .flexGrow(70)
              .fontSize(18)
              .fontWeight(this.isSpecialEntry() ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.isSpecialEntry() ? '#4CAF50' : '#000000')
            Blank().width(10)
          }
        }
        .justifyContent(FlexAlign.Start)

        Blank().height(8)

        Text(this.model.subtitle)
          .fontSize(15)
          .fontColor(this.isSpecialEntry() ? '#4CAF50' : Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1)
      
      // 为运动排行榜添加一个右箭头指示器
      if (this.model.title === '运动排行榜') {
        Row() {
          // 使用文本箭头代替系统符号
          Text('→')
            .fontSize(20)
            .fontColor('#4CAF50')
        }
        .width(30)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .height(70)
    .backgroundColor(Color.White)
    .onClick(() => this.onClickCell?.(this.model))
  }
  
  // 判断是否为特殊条目（如运动排行榜）
  isSpecialEntry(): boolean {
    return this.model.title === '运动排行榜'
  }
}
