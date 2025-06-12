import { JhButton, KColors } from "JhCommon";
import { WxNewFriendModel } from "../models/WxNewFriendModel";


@Preview
@Component
export struct WxNewFriendCell {
  model: WxNewFriendModel = new WxNewFriendModel();
  public onClickCell?: (model: WxNewFriendModel) => void // 点击cell
  public onClickBtn?: (model: WxNewFriendModel) => void // 点击btn

  build() {
    Column() {
      Row() {
        Image(this.model.img)
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)
          .onError(() => {
            console.error(`[WxNewFriendCell] 头像加载失败: ${this.model.img}`);
          })
          .onComplete(() => {
            console.info(`[WxNewFriendCell] 头像加载成功: ${this.model.img}`);
          })

        Blank().width(10)
        Column() {
          Text(this.model.title)
            .fontSize(14)
            .fontColor(KColors.wxTextBlueColor)
          Blank().height(5)
          Text(this.model.subtitle)
            .fontSize(14)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row() {
          if (this.model.isAdd) {
            Text('已添加').width(55).fontSize(15)
          } else {
            JhButton({
              text: '加好友',
              btnWidth: 60,
              btnHeight: 30,
              btnFontSize: 14,
              onPressed: (): void => this.onClickBtn?.(this.model)
            })
          }
        }
      }
    }
    .padding({
      left: 15,
      right: 15,
      top: 20,
      bottom: 20
    })
    .backgroundColor(Color.White)
    .onClick(() => this.onClickCell?.(this.model))
  }
}
