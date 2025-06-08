import { JhSetCell, KColors } from "JhCommon";
import { WxContactsModel } from "../models/WxContactsModel";

const _cellHeight = 50
const _imgWH = 40
const _lRSpace = 15

@Preview
@Component
export struct WxContactsCell {
  index: number = 0;
  model: WxContactsModel = new WxContactsModel();
  searchController: SearchController = new SearchController()
  public onClickCell?: (model: WxContactsModel) => void // 点击cell
  public onClickTopCell?: (model: ESObject) => void // 点击cell

  build() {
    if (this.index == 0) {
      this.header()
    } else {
      Row() {
        Row() {
          // Image(this.model.avatarUrl)
          //   .width(_imgWH).height(_imgWH)
          //   .borderRadius(5)
          //   .clip(true)
          Row() {
            Text(this.model.name?.substring(0, 1))
              .fontColor(Color.White)
              .fontSize(20)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .width(_imgWH)
          .height(_imgWH)
          .borderRadius(5)
          .backgroundColor(this.model.color)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width(_imgWH + _lRSpace * 2)
        .height(_cellHeight)

        Column() {
          Text(this.model.name)
            .fontSize(15)
            .fontColor(Color.Black)
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .layoutWeight(1)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .height(_cellHeight)
      .backgroundColor(Color.White)
      .onClick(() => this.onClickCell?.(this.model))
    }
  }

  @Builder
  header() {
    Column() {
      Row() {
        Search({ value: '', placeholder: getContext(this).resourceManager.getStringSync($r('app.string.search_placeholder_847392618475')), controller: this.searchController })
          .id('WxContactsPageSearch_ID')
          .borderRadius(5)
          .margin(10)
          .onSubmit((value: string) => {
          })
          .onChange((value: string) => {
          })
      }
      .backgroundColor(KColors.kBgColor)

      ForEach(this.getTopData(), (item: ESObject, index: number) => {
        // JhSetCell({
        //   leftIcon: item['imgUrl'],
        //   leftImgWH: 40,
        //   title: item['title'],
        //   titleWidth: 300,
        //   lineLeftEdge: 65,
        //   hiddenArrow: true,
        //   cellHeight: _cellHeight,
        // })
        JhSetCell({
          leftWidget: (): void => this.leftBuilder(item),
          leftImgWH: 40,
          title: item['title'] as string,
          titleWidth: 300,
          lineLeftEdge: 65,
          hiddenArrow: true,
          cellHeight: _cellHeight,
          clickCallBack: () => {
            this.onClickTopCell?.(item)
          },
        })
      })
    }
  }

  @Builder
  leftBuilder(item: ESObject) {
    Image(item['imgUrl'] as Resource)
      .width(_imgWH).height(_imgWH)
      .borderRadius(5)
      .clip(true)
  }

  getTopData(): ESObject[] {
    return [
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.new_member_cell_629384750192')),
        'imgUrl': $rawfile('wechat/contacts/ic_new_friend.png'),
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.common_health_goals_cell_573829461847')),
        'imgUrl': $rawfile('images/picture/together_health.png'),
      },
      {
        'title': getContext(this).resourceManager.getStringSync($r('app.string.group_chat_cell_392847516293')),
        'imgUrl': $rawfile('wechat/contacts/ic_group_chat.png'),
      },
    ];
  }
}