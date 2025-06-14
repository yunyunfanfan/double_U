import { router } from '@kit.ArkUI'
import { pinyin } from 'pinyin-pro';
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxContactsModel } from '../models/WxContactsModel'
import { WxContactsCell } from '../widgets/WxContactsCell'
import { userApiService, FriendsListResponse, FriendItem } from '../../../services/api_network/UserApiService'
import { UserApiService } from '../../../services/api_network/UserApiService'

///第二页主页

interface UserData {
  userId: string;
  userName: string;
  phone: string;
  loginTime: string;
}

interface ContactData {
  id: number;
  name: string;
  phone: string;
  avatarUrl: string;
  color: string;
  img: string;
  namePinyin: string;
  tagIndex: string;
}

interface TopCellItem {
  title: string;
  imgUrl: Resource;
}

interface GroupItem {
  groupName: string;
  data: ContactData[];
}

@Entry
@Preview
@Component
export struct WxContactsPage {
  @State dataArr: GroupItem[] = []
  @State tagIndexList: string[] = []
  @State isLoading: boolean = true
  @State isRefreshing: boolean = false // 添加下拉刷新状态
  @State currentUserId: number = 0
  scroller: ListScroller = new ListScroller()
  searchController: SearchController = new SearchController()
  @State selectedIndex: number = 0
  @State isShowTagPopup: boolean = false
  @State contactsCount: string = ''

  aboutToAppear() {
    console.info('[家庭成员页面] 页面初始化');
    this.loadCurrentUser();
    this.loadFriendsData();
  }

  private loadCurrentUser(): void {
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        const userInfo: UserData = JSON.parse(userInfoStr) as UserData;
        this.currentUserId = parseInt(userInfo.userId);
        console.info(`[家庭成员页面] 当前用户ID: ${this.currentUserId}`);
      }
    } catch (error) {
      console.error(`[家庭成员页面] 获取用户信息失败:`, error);
    }
  }

  private async loadFriendsData(): Promise<void> {
    if (this.currentUserId === 0) {
      console.error('[家庭成员页面] 用户ID为0，使用默认数据');
      this.dataArr = this.loadData([]);
      this.isLoading = false;
      this.updateTagIndexList();
      return;
    }

    try {
      console.info('[家庭成员页面] 开始加载好友数据');
      const response: FriendsListResponse = await userApiService.getFriendsList(this.currentUserId);

      if (response.success && response.friends) {
        console.info(`[家庭成员页面] 好友数据加载成功，共${response.friends.length}个好友`);
        const contactsData: ContactData[] = this.processDataForDisplay(response.friends);
        this.dataArr = this.loadData(contactsData);
      } else {
        console.error('[家庭成员页面] 好友数据加载失败:', response.message);
        this.dataArr = this.loadData([]);
      }
    } catch (error) {
      console.error('[家庭成员页面] 加载好友数据异常:', error);
      this.dataArr = this.loadData([]);
    } finally {
      this.isLoading = false;
      this.updateTagIndexList();
    }
  }

  // 下拉刷新处理函数
  async onRefresh() {
    console.info('[家庭成员页面] 用户触发下拉刷新');
    this.isRefreshing = true;

    try {
      this.loadCurrentUser();
      await this.loadFriendsData();
      console.info('[家庭成员页面] 下拉刷新完成');
    } catch (error) {
      console.error('[家庭成员页面] 下拉刷新失败:', error);
      JhProgressHUD.showToast('刷新失败，请重试');
    } finally {
      this.isRefreshing = false;
    }
  }

  // 获取用户头像源
  private getUserAvatarSource(avatarUrl: string): string {
    console.info(`[家庭成员页面] 原始头像URL: "${avatarUrl}"`);
    if (avatarUrl && avatarUrl.trim() !== '') {
      const processedUrl = UserApiService.getUserDisplayAvatar(avatarUrl);
      console.info(`[家庭成员页面] 处理后的头像URL: "${processedUrl}"`);
      return processedUrl;
    }
    const defaultUrl = UserApiService.getDefaultAvatarUrl();
    console.info(`[家庭成员页面] 使用默认头像URL: "${defaultUrl}"`);
    return defaultUrl;
  }

  private processDataForDisplay(friends: FriendItem[]): ContactData[] {
    const contactsData: ContactData[] = [];

    for (const friend of friends) {
      const processedAvatarUrl = this.getUserAvatarSource(friend.avatar_url || '');
      const contactData: ContactData = {
        id: friend.id,
        name: friend.username,
        phone: friend.phone,
        avatarUrl: friend.avatar_url || '',
        color: '#f2e979',
        img: processedAvatarUrl,
        namePinyin: '',
        tagIndex: ''
      };
      contactsData.push(contactData);
    }

    return contactsData;
  }

  private updateTagIndexList(): void {
    const tempList: string[] = [];
    for (const item of this.dataArr) {
      tempList.push(item.groupName);
    }
    this.tagIndexList = tempList;
  }

  build() {
    Column() {
      BaseNavigation({
        title: '家庭成员',
        leftItem: {},
        bgColor: Color.Transparent,
        rightImgPath: $rawfile("images/第二页加号.png"),
        rightItemCallBack: () => {
          this.searchController.stopEditing()
          router.pushUrl({ url: 'pages/two/pages/WxAddFriendPage' })
        },
      })

      if (this.isLoading) {
        this.loadingView()
      } else {
        this.body()
      }
    }
  }

  @Builder
  loadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#07C160')
      Text('加载好友列表...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  body() {
    Stack({ alignContent: Alignment.End }) {
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ space: 0, initialIndex: 0, scroller: this.scroller }) {
          ForEach(this.dataArr, (groupItem: GroupItem, index: number) => {
            ListItemGroup({ header: this.itemHeader(groupItem.groupName) }) {
              ForEach(groupItem.data, (cellItem: ContactData, index2: number) => {
                ListItem() {
                  WxContactsCell({
                    index: groupItem.groupName === "🔍" ? 0 : 1,
                    model: cellItem as WxContactsModel,
                    searchController: this.searchController,
                    onClickCell: (model: WxContactsModel) => {
                      this.searchController.stopEditing()
                      router.pushUrl({ url: 'pages/two/pages/WxUserInfoPage', params: { data: cellItem } })
                    },
                    onClickTopCell: (model: TopCellItem) => {
                      this.searchController.stopEditing()
                      console.info(`[家庭成员页面] 点击头部项目: ${model.title}`)
                      this.clickCell(model.title)
                    },
                  })
                }
              }, (item: ContactData) => `${item.id}_${item.name}`)
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
          this.selectedIndex = firstIndex
        })
      }
      .onRefreshing(() => {
        this.onRefresh()
      })

      AlphabetIndexer({ arrayValue: this.tagIndexList, selected: 0 })
        .color(Color.Black)
        .selectedColor(Color.White)
        .popupColor(Color.White)
        .selectedBackgroundColor(KColors.kThemeColor)
        .popupBackground('#C9C9C9')
        .usingPopup(this.isShowTagPopup)
        .selectedFont({ size: 16, weight: FontWeight.Bolder })
        .popupFont({ size: 30, weight: FontWeight.Bolder })
        .font({ size: 14 })
        .itemSize(22)
        .alignStyle(IndexerAlign.END)
        .popupPosition({ x: 60, y: 48 })
        .itemBorderRadius(11)
        .popupBackgroundBlurStyle(BlurStyle.NONE)
        .selected(this.selectedIndex)
        .onSelect((index: number) => {
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
        Text(text)
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
      Text('备注')
        .fontSize(14)
        .fontColor(Color.White)
    }
    .width('25%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#74736D')
    .onClick(() => {
      JhProgressHUD.showToast('备注功能')
      this.scroller.closeAllSwipeActions()
    })
  }

  @Builder
  footer() {
    Row() {
      Text(`${this.getActualMemberCount()}个家庭成员`)
        .fontSize(16)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(KColors.wxBgColor)
  }

  private getActualMemberCount(): number {
    let count = 0;
    for (const group of this.dataArr) {
      if (group.groupName !== '🔍') {
        count += group.data.length;
      }
    }
    return count;
  }

  clickCell(text: string) {
    console.info(`[家庭成员页面] 执行点击操作: ${text}`)
    if (text == '新的成员') {
      router.pushUrl({ url: 'pages/two/pages/WxAddFriendPage' })
    }
    if (text == '共同健康目标') {
      router.pushUrl({ url: 'pages/two/pages/CommonHealthGoalsPage' })
    }
  }

  loadData(contactsData: ContactData[]): GroupItem[] {
    // 处理数据
    const tempList: ContactData[] = [];
    for (let i = 0; i < contactsData.length; i++) {
      const item: ContactData = contactsData[i];
      const pinyinStr: string = pinyin(item.name, { toneType: 'none' });
      const tag: string = pinyinStr.substring(0, 1).toUpperCase();
      item.namePinyin = pinyinStr;

      if (new RegExp('[A-Z]').test(tag)) {
        item.tagIndex = tag;
      } else {
        item.tagIndex = '#';
      }
      tempList.push(item);
    }

    // 根据A-Z排序
    tempList.sort((a: ContactData, b: ContactData) => {
      if (a.tagIndex === b.tagIndex) {
        return a.name.localeCompare(b.name);
      }
      if (a.tagIndex === "#") {
        return 1;
      }
      if (b.tagIndex === "#") {
        return -1;
      }
      return a.tagIndex.localeCompare(b.tagIndex);
    });

    // 添加 header
    const headerItem: ContactData = {
      id: -1,
      name: "header",
      phone: "",
      avatarUrl: "",
      color: "",
      img: "",
      namePinyin: "",
      tagIndex: "🔍"
    };
    tempList.unshift(headerItem);

    // 改成分组数据
    const newArr: GroupItem[] = this.groupListByKey(tempList, 'tagIndex');
    return newArr;
  }

  private groupListByKey(array: ContactData[], key: string): GroupItem[] {
    const result: GroupItem[] = [];
    const groupMap: Map<string, ContactData[]> = new Map();

    // 遍历数组，将每个元素按照key分组
    array.forEach((item: ContactData) => {
      const groupValue: string = item.tagIndex;
      if (!groupMap.has(groupValue)) {
        groupMap.set(groupValue, []);
      }
      const group = groupMap.get(groupValue);
      if (group) {
        group.push(item);
      }
    });

    groupMap.forEach((value, key) => {
      const groupItem: GroupItem = { groupName: key, data: value };
      result.push(groupItem);
    });
    return result;
  }
}