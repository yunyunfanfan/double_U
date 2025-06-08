
///第二页主页

import { router } from '@kit.ArkUI'
import { pinyin } from 'pinyin-pro';
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxContactsModel } from '../models/WxContactsModel'
import { WxContactsCell } from '../widgets/WxContactsCell'
import data from '../../../pages/res/wx_contacts.json'

interface GroupItem {
  groupName: string;
  data: ESObject[];
}

@Entry
@Preview
@Component
export struct WxContactsPage {
  @State dataArr: GroupItem[] = []
  // @State tagIndexList: string[] = ['🔍', '★', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
  //   'H', 'I', 'J', 'K', 'L', 'M', 'N',
  //   'O', 'P', 'Q', 'R', 'S', 'T', 'U',
  //   'V', 'W', 'X', 'Y', 'Z', '#']
  @State tagIndexList: string[] = []
  // scroller: Scroller = new Scroller()
  scroller: ListScroller = new ListScroller()
  searchController: SearchController = new SearchController()
  @State selectedIndex: number = 0
  @State isShowTagPopup: boolean = false
  @State contactsCount: string = ''

  aboutToAppear() {
    this.dataArr = this.loadData()
    // console.error('data', JSON.stringify(this.dataArr))

    const tempList: string[] = [];
    for (const item of this.dataArr) {
      tempList.push(item.groupName)
    }
    this.tagIndexList = tempList;
  }

  build() {
    Column() {
      BaseNavigation({
        //isGradient: true,
        //这渐变也不好看啊
        title: getContext(this).resourceManager.getStringSync($r('app.string.family_members_title_847592836')),
        leftItem: {},
        bgColor: Color.Transparent,
        rightImgPath: $rawfile("images/第二页加号.png"),
        rightItemCallBack: () => {
          this.searchController.stopEditing()
          router.pushUrl({ url: 'pages/two/pages/WxAddFriendPage' })
        },
      })
      this.body()
    }
  }

  @Builder
  body() {
    Stack({ alignContent: Alignment.End }) {
      List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
        ForEach(this.dataArr, (groupItem: GroupItem, index: number) => {
          ListItemGroup({ header: this.itemHeader(groupItem.groupName) }) {
            ForEach(groupItem.data, (cellItem: ESObject, index2: number) => {
              ListItem() {
                WxContactsCell({
                  index: index,
                  model: cellItem as WxContactsModel,
                  searchController: this.searchController,
                  onClickCell: (model: WxContactsModel) => {
                    this.searchController.stopEditing()
                    router.pushUrl({ url: 'pages/two/pages/WxUserInfoPage', params: { data: cellItem } })
                  },
                  onClickTopCell: (model: ESObject) => {
                    this.searchController.stopEditing()
                    this.clickCell(model['title'] as string)
                  },
                })
              }
              // .swipeAction({
              //   end: {
              //     builder: () => {
              //       if (index != 0) {
              //         this.itemSwipeEnd()
              //       }
              //     },
              //     actionAreaDistance: 0, // 设置组件长距离滑动删除距离阈值。 默认56
              //     onAction: () => {
              //       animateTo({ duration: 1000 }, () => {
              //       })
              //     },
              //   }
              // })
            }, (item: ESObject) => JSON.stringify(item))
          }
          // 每行之间的分界线
          .divider({
            strokeWidth: 0.6,
            startMargin: 65,
            endMargin: 0,
            color: KColors.kFormLineColor,
          })
        })
        ListItem() {
          this.footer()
        }
      }
      .height('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: true
      })
      .backgroundColor(Color.White)
      .sticky(StickyStyle.Header | StickyStyle.Footer)
      .scrollBar(BarState.Off)
      .onScrollIndex((firstIndex: number, lastIndex: number) => {
        // console.log('firstIndex', JSON.stringify(firstIndex))
        this.selectedIndex = firstIndex
      })

      AlphabetIndexer({ arrayValue: this.tagIndexList, selected: 0 })
        .color(Color.Black)// 文字颜色
        .selectedColor(Color.White)// 选中项文字颜色
        .popupColor(Color.White)// 提示弹窗文字颜色
        .selectedBackgroundColor(KColors.kThemeColor)// 选中项背景颜色
        .popupBackground('#C9C9C9')// 提示弹窗背景色
        .usingPopup(this.isShowTagPopup)// 是否使用提示弹窗
        .selectedFont({ size: 16, weight: FontWeight.Bolder })// 选中项字体样式
        .popupFont({ size: 30, weight: FontWeight.Bolder })// 弹出框内容的字体样式
        .font({ size: 14 })// 字母索引条默认字体样式
        .itemSize(22)// 字母索引条字母区域大小
        .alignStyle(IndexerAlign.END)// 字母索引条弹框的对齐样式，支持弹窗显示在索引条右侧和左侧.默认值: IndexerAlign.END
        .popupPosition({ x: 60, y: 48 })
        .itemBorderRadius(11)//索引项背板圆角半径
        .popupBackgroundBlurStyle(BlurStyle.NONE)// 设置提示弹窗的背景模糊材质
        .selected(this.selectedIndex)
        .onSelect((index: number) => {
          // console.log('index', index)
          this.scroller.scrollToIndex(index)
          this.isShowTagPopup = true;
          setTimeout(() => {
            this.isShowTagPopup = false;
          }, 3000)
        })
        .onPopupSelect((index: number) => {
        })
    }
    .layoutWeight(1)
  }

  @Builder
  itemHeader(text: string) {
    if (text == '🔍') {
      Row()
    } else {
      Row() {
        Text(text == '★' ? getContext(this).resourceManager.getStringSync($r('app.string.special_care_members_629385741')) : text)
          .padding({ left: 15 })
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isFloat(text) ? KColors.wxPayColor : '#777777')
      }
      .width("100%")
      .height(30)
      .backgroundColor(KColors.wxBgColor)
    }
  }

  isFloat(text: string): boolean {
    return this.tagIndexList[this.selectedIndex] == text
  }

  @Builder
  itemSwipeEnd() {
    Row() {
      Text(getContext(this).resourceManager.getStringSync($r('app.string.remark_action_384759261')))
        .fontSize(14)
        .fontColor(Color.White)
    }
    .width('25%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#74736D')
    .onClick(() => {
      JhProgressHUD.showToast(getContext(this).resourceManager.getStringSync($r('app.string.remark_toast_927384615')))
      this.scroller.closeAllSwipeActions()
    })
  }

  @Builder
  footer() {
    Row() {
      Text(`${this.getData().length}${getContext(this).resourceManager.getStringSync($r('app.string.family_members_count_639481752'))}`)
        .fontSize(16)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(KColors.wxBgColor)
  }

  clickCell(text: string) {
    const newMemberText: string = getContext(this).resourceManager.getStringSync($r('app.string.new_member_758294637'))
    const groupChatText: string = getContext(this).resourceManager.getStringSync($r('app.string.group_chat_472961853'))
    const healthGoalsText: string = getContext(this).resourceManager.getStringSync($r('app.string.common_health_goals_851374269'))

    if (text == newMemberText) {
      router.pushUrl({ url: 'pages/two/pages/WxNewFriendPage' })
    }
    if (text == groupChatText) {
      router.pushUrl({ url: 'pages/two/pages/WxGroupChatPage' })
    }
    if (text == healthGoalsText) {
      router.pushUrl({ url: 'pages/two/pages/CommonHealthGoalsPage' })
    }
  }

  loadData(): GroupItem[] {
    // 原始数据
    const dataArr: ESObject[] = this.getData()

    // 处理数据
    const tempList: ESObject[] = [];
    for (let i = 0; i < dataArr.length; i++) {
      const item: ESObject = dataArr[i]
      const pinyinStr: string = pinyin(item.name as string, { toneType: 'none' })
      const tag: string = pinyinStr.substring(0, 1).toUpperCase();
      item.namePinyin = pinyinStr;
      if (item.isStar == true) {
        item.tagIndex = '★';
      } else if (new RegExp('[A-Z]').test(tag)) {
        item.tagIndex = tag;
      } else {
        item.tagIndex = '#';
      }
      tempList.push(item);
    }

    // 根据A-Z排序
    tempList.sort((a: ESObject, b: ESObject) => {
      if (a['tagIndex'] === b['tagIndex']) {
        return (a['name'] as string).localeCompare(b['name'] as string) as number
      }
      if (a['tagIndex'] === "#") {
        return 1
      }
      if (b['tagIndex'] === "#") {
        return -1
      }
      return (a['tagIndex'] as string).localeCompare(b['tagIndex'] as string) as number
    });

    // 把星标移到最前
    tempList.forEach((item: ESObject, index) => {
      if (item.isStar == true) {
        tempList.unshift(...tempList.splice(index, 1));
      }
    });

    // 添加 header
    tempList.unshift({
      name: "header",
      tagIndex: "🔍"
    });

    // 改成分组数据
    const newArr: GroupItem[] = groupListByKey(tempList, 'tagIndex');
    return newArr
  }

  getData(): ESObject[] {
    const dataArr: ESObject[] = data['data'] as ESObject[]
    return dataArr;
  }
}

// 数组按指定key分组
function groupListByKey<T>(array: T[], key: string): GroupItem[] {
  const result: GroupItem[] = [];
  const groupMap: Map<string, T[]> = new Map();

  // 遍历数组，将每个元素按照key分组
  array.forEach((item: ESObject) => {
    const groupValue: string = String(item[key]);
    if (!groupMap[groupValue]) {
      groupMap[groupValue] = [];
    }
    groupMap[groupValue].push(item);
  });

  Object.keys(groupMap).forEach((key) => {
    result.push({ groupName: key, data: groupMap[key] as ESObject[] });
  });
  return result;
}