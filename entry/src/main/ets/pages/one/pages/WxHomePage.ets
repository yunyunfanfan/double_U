import { promptAction, router } from '@kit.ArkUI'
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxHomeModel } from '../models/WxHomeModel'
import { WxHomeCell } from '../widgets/WxHomeCell'
import { userApiService, HealthDataSummary } from '../../../services/api_network/UserApiService'

interface PopMenuItem {
  text: string;
  icon: Resource;
}

interface HealthPageParams {
  user_id?: number;
}

interface UserInfo {
  userId: string;
  userName: string;
  phone: string;
  loginTime: string;
}

interface RouterParams {
  user_id?: number;
}

@Entry
@Preview
@Component
export struct WxHomePage {
  @State dataArr: WxHomeModel[] = []
  @State healthDataSummary: HealthDataSummary = new HealthDataSummary('加载中...', '加载中...', '加载中...', '加载中...', '加载中...', '加载中...')
  @State isRefreshing: boolean = false
  @State currentViewUserId: number = 0 // 当前查看的用户ID
  @State isViewingOtherUser: boolean = false // 是否查看其他用户
  @State currentUserName: string = '' // 当前查看用户的姓名
  scroller: ListScroller = new ListScroller()
  private healthDataService = userApiService

  aboutToAppear() {
    console.log('[WxHomePage] 页面即将显示，设置用户ID');
    this.setCurrentUserFromParams();
    this.loadHealthData()
  }

  private setCurrentUserFromParams(): void {
    try {
      // 先检查路由参数是否有传入user_id
      const params = router.getParams() as RouterParams;
      if (params && params.user_id) {
        console.log(`[WxHomePage] 从路由参数获取用户ID: ${params.user_id}`);
        this.currentViewUserId = params.user_id;
        this.isViewingOtherUser = true;
        this.healthDataService.setCurrentUserId(params.user_id);
        this.loadUserName(params.user_id);
        return;
      }

      // 如果没有路由参数，则从AppStorage获取当前登录用户
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        const userInfo: UserInfo = JSON.parse(userInfoStr) as UserInfo;
        const userId: number = parseInt(userInfo.userId);
        console.log(`[WxHomePage] 从存储获取当前用户ID: ${userId}`);
        this.currentViewUserId = userId;
        this.currentUserName = userInfo.userName;
        this.isViewingOtherUser = false;
        this.healthDataService.setCurrentUserId(userId);
      } else {
        console.error('[WxHomePage] 未找到用户信息，使用默认用户ID: 1');
        this.currentViewUserId = 1;
        this.currentUserName = '默认用户';
        this.isViewingOtherUser = false;
        this.healthDataService.setCurrentUserId(1);
      }
    } catch (error) {
      console.error('[WxHomePage] 解析用户信息失败:', error);
      this.currentViewUserId = 1;
      this.currentUserName = '默认用户';
      this.isViewingOtherUser = false;
      this.healthDataService.setCurrentUserId(1);
    }
  }

  private async loadUserName(userId: number): Promise<void> {
    try {
      console.log(`[WxHomePage] 开始获取用户名，用户ID: ${userId}`);
      const userName = await this.healthDataService.getUserName(userId);
      this.currentUserName = userName || '未知用户';
      console.log(`[WxHomePage] 获取用户名成功: ${this.currentUserName}`);
    } catch (error) {
      console.error('[WxHomePage] 获取用户名失败:', error);
      this.currentUserName = '未知用户';
    }
  }

  onPageShow() {
    // 检查是否需要显示他人数据
    const shouldShowOtherUser = AppStorage.get<boolean>('shouldShowOtherUser');
    const viewingUserId = AppStorage.get<number>('viewingUserId');

    if (shouldShowOtherUser && viewingUserId) {
      console.log(`[WxHomePage] 从返回状态获取用户ID: ${viewingUserId}`);
      this.currentViewUserId = viewingUserId;
      this.isViewingOtherUser = true;
      this.healthDataService.setCurrentUserId(viewingUserId);
      this.loadUserName(viewingUserId);
    } else {
      // 页面显示时重新设置用户ID并刷新数据
      this.setCurrentUserFromParams();
    }
    this.refreshHealthData()
  }

  async refreshHealthData() {
    try {
      console.log('[WxHomePage] 刷新健康数据...')
      this.healthDataSummary = await this.healthDataService.getLatestHealthData()
      this.dataArr = this.getData()
      console.log('[WxHomePage] 健康数据刷新完成:', JSON.stringify(this.healthDataSummary))
    } catch (error) {
      console.error('[WxHomePage] 刷新健康数据失败:', error)
    }
  }

  async loadHealthData() {
    try {
      console.log('[WxHomePage] 开始加载健康数据...');
      // 加载实时健康数据
      this.healthDataSummary = await this.healthDataService.getLatestHealthData()
      console.log('[WxHomePage] 健康数据加载完成:', JSON.stringify(this.healthDataSummary));
      // 生成页面数据，使用实时健康数据
      this.dataArr = this.getData()
      console.log('[WxHomePage] 页面数据生成完成，数据项数量:', this.dataArr.length);
    } catch (error) {
      console.error('[WxHomePage] 加载健康数据失败:', error)
      // 使用默认数据
      this.healthDataSummary = new HealthDataSummary('0步', '0bpm', '0%', '0分', '0Kcal', '一般')
      this.dataArr = this.getData()
      console.log('[WxHomePage] 使用默认健康数据');
    }
  }

  // 下拉刷新处理函数
  async onRefresh() {
    console.log('[WxHomePage] 用户触发下拉刷新');
    this.isRefreshing = true;

    try {
      // 重新从数据库加载健康数据
      await this.refreshHealthData();
      console.log('[WxHomePage] 下拉刷新完成');
    } catch (error) {
      console.error('[WxHomePage] 下拉刷新失败:', error);
      JhProgressHUD.showToast('刷新失败，请重试');
    } finally {
      this.isRefreshing = false;
    }
  }

  build() {
    Column() {
      if (this.isViewingOtherUser) {
        BaseNavigation({
          title: `${this.currentUserName}的健康情况`,
          bgColor: Color.Transparent,
        })
      }
      else
      {
        BaseNavigation({
          title: '健康助手',
          leftItem: {},
          bgColor: Color.Transparent,
          rightImgPath: $rawfile("images/第一页加号.png"),
          rightItemCallBack: () => {
            console.log('点击了右侧图标')
            this.onClickRightItem()
          },
        })
      }
      this.body()
    }
    //.backgroundColor(KColors.wxBgColor)
    //这个是主页标志性的蓝色
  }

  @Builder
  body() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List({ scroller: this.scroller }) {
        ForEach(this.dataArr, (item: WxHomeModel, index: number) => {
          ListItem() {
            WxHomeCell({
              model: item,
              onClickCell: () => {
                this.clickCell(item)
              },
            })
          }
          //禁用第一页的滑动效果
          // .swipeAction({
          //   end: {
          //     builder: () => {
          //       this.itemSwipeEnd(item.type)
          //     },
          //     actionAreaDistance: 0, // 设置组件长距离滑动删除距离阈值。 默认56
          //     onAction: () => {
          //       animateTo({ duration: 1000 }, () => {
          //       })
          //     },
          //   }
          // })
        })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: true
      })
      .divider({
        strokeWidth: 0.5,
        startMargin: 70,
        endMargin: 0,
        color: KColors.kLineColor
      })
    }
    .onRefreshing(() => {
      this.onRefresh()
    })
  }

  @Builder
  itemSwipeEnd(type: string) {
    if (type == '0') {
      Row()
    }
    if (type == '1') {
      Row() {
        Text('删除')
          .fontSize(14)
          .fontWeight(400)
          .fontColor(Color.White)
      }
      .width('25%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast('删除')
        this.scroller.closeAllSwipeActions()
      })
    }
    if (type == '2') {
      Row() {
        Row() {
          Text('标记未读')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#74736D')
        .onClick(() => {
          JhProgressHUD.showToast('标记未读')
          this.scroller.closeAllSwipeActions()
        })

        Row() {
          Text('删除')
            .fontSize(14)
            .fontWeight(400)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.Red)
        .onClick(() => {
          JhProgressHUD.showToast('删除')
          this.scroller.closeAllSwipeActions()
        })
      }
      .width('50%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast('删除')
        this.scroller.closeAllSwipeActions()
      })
    }
    if (type == '3') {
      Row() {
        Row() {
          Text('取消关注')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#74736D')
        .onClick(() => {
          JhProgressHUD.showToast('取消关注')
          this.scroller.closeAllSwipeActions()
        })

        Row() {
          Text('删除')
            .fontSize(14)
            .fontWeight(400)
            .fontColor(Color.White)
        }
        .width('50%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.Red)
        .onClick(() => {
          JhProgressHUD.showToast('删除')
          this.scroller.closeAllSwipeActions()
        })
      }
      .width('50%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Red)
      .onClick(() => {
        JhProgressHUD.showToast('删除')
        this.scroller.closeAllSwipeActions()
      })
    }
  }

  /* openCustomDialog API12+

    创建并弹出dialogContent对应的自定义弹窗，使用Promise异步回调。

    https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-arkui-uicontext-V5#opencustomdialog12
   */

  /* promptAction.openCustomDialog API11+

    打开自定义弹窗

   https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-promptaction-V5#promptactionopencustomdialog11
   */

  private customDialogId: number = 0

  onClickRightItem() {
    promptAction.openCustomDialog({
      builder: () => {
        this.customDialogComponent()
      },
      width: '160vp',
      height: this.getPopData().length * 50 + 6,
      offset: { dx: -10, dy: 56 },
      alignment: DialogAlignment.TopEnd,
      // backgroundColor: '#2D2D2D',
      backgroundColor: Color.Transparent,
      cornerRadius: 5,
    }).then((dialogId: number) => {
      this.customDialogId = dialogId
    })
  }

  @Builder
  //顶部菜单栏的箭头区域
  customDialogComponent() {
    Column() {
      Row() {
        Image($rawfile('images/popMenus/ic_menu_up_arrow.png')).height(6)
        Blank().width(10)
      }
      .width('100%')
      .backgroundColor("#CBCBCB")
      .justifyContent(FlexAlign.End)

      List() {
        ForEach(this.getPopData(), (item: PopMenuItem, index: number) => {
          ListItem() {
            Row() {
              Blank().width(15)
              Image(item.icon).width(28)
              //这个大小直接控制的菜单栏图标大小
              Blank().width(15)
              Text(item.text)
                .fontColor(Color.White)
                .fontSize(16)
            }
            .width('100%')
            .height(50)
            .alignItems(VerticalAlign.Center)
          }
          .onClick(() => {
            promptAction.closeCustomDialog(this.customDialogId)
            this.clickPopCell(item.text)
          })
        })
      }
      .scrollBar(BarState.Off)
      .enableScrollInteraction(false)
      .layoutWeight(1)
      .divider({
        strokeWidth: 1,
        startMargin: 50,
        endMargin: 0,
        color: '#E6E6E6',
      })
      .backgroundColor('#2D2D2D')
      .borderRadius(5)
    }
  }

  //控制跳转
  clickCell(item: WxHomeModel) {
    console.log('点击cell', JSON.stringify(item))
    let sportsRankingTitle: string = '运动排行榜'
    let healthMemoryTitle: string = '健康记忆'
    let heartRateTitle: string = '心率'
    let bloodOxygenTitle: string = '血氧'
    let stepAnalysisTitle: string = '步数分析'
    let sleepTitle: string = '睡眠'
    let caloriesTitle: string = '热量'
    let moodTitle: string = '心情'
    let deepseekTitle: string = 'DeepSeek助手'

    // 如果查看其他用户，需要传递user_id参数
    let routerParams: HealthPageParams = {};
    if (this.isViewingOtherUser) {
      routerParams.user_id = this.currentViewUserId;
    }

    if (item.title == sportsRankingTitle) {
      console.log('正在跳转到运动排行榜页面...')
      router.pushUrl({
        url: 'pages/one/pages/WxMotionTopPage',
        params: {
          fromHome: 'true'
        }
      })
    } else if (item.title == healthMemoryTitle) {
      router.pushUrl({ url: 'pages/one/pages/HealthMemoryPage', params: routerParams })
    } else if (item.title == heartRateTitle) {
      router.pushUrl({ url: 'pages/one/pages/HeartRatePage', params: routerParams })
    } else if (item.title == bloodOxygenTitle) {
      router.pushUrl({ url: 'pages/one/pages/BloodOxygenPage', params: routerParams })
    } else if (item.title == stepAnalysisTitle) {
      router.pushUrl({ url: 'pages/one/pages/StepCountPage', params: routerParams })
    } else if (item.title == sleepTitle) {
      router.pushUrl({ url: 'pages/one/pages/SleepPage', params: routerParams })
    } else if (item.title == caloriesTitle) {
      router.pushUrl({ url: 'pages/one/pages/CaloriesPage', params: routerParams })
    } else if (item.title == moodTitle) {
      router.pushUrl({ url: 'pages/one/pages/MoodPage', params: routerParams })
    } else if (item.title == deepseekTitle) {
      router.pushUrl({url: 'pages/one/pages/HealthDataEntryPage'})
    }
    else {
      router.pushUrl({ url: 'pages/demos/DemoListPage' })
    }
  }

  clickPopCell(text: string) {
    console.log('点击', JSON.stringify(text))
    let addMemberText: string = '添加朋友'
    let deepseekText: string = 'DeepSeek'
    let startGroupChatText: string = '健康圈'
    let openMembershipText: string = '开通会员'

    if (text == addMemberText) {
      router.pushUrl({ url: 'pages/two/pages/WxAddFriendPage' })
    }
    else if (text == deepseekText){
      router.pushUrl({ url: 'pages/new_deepseek/ChatPage' })
    }
    else if (text == startGroupChatText){
      router.pushUrl( {url: 'pages/three/pages/WxFriendsCirclePage'})
    }
    else if (text == openMembershipText){
      router.pushUrl({url : 'pages/four/pages/Membership/MemberShip' })
    }
  }

  // 这是控制文本
  getData(): WxHomeModel[] {
    let dataArr: WxHomeModel[] = [];

    // 如果查看其他用户，排除运动排行榜和DeepSeek助手
    if (!this.isViewingOtherUser) {
      dataArr.push({
        'title': '运动排行榜',
        'subtitle': '查看今日步数排行榜',
        'img': 'images/picture/bushu.png',
        'isNew': false,
        'type': '2',
      });
      dataArr.push({
        'title': 'DeepSeek助手',
        'subtitle': '智能健康咨询助手',
        'img': 'images/picture/ic_health_assistant.png',
        'isNew': true,
        'type': '2',
      });
    }

    // 通用的健康数据项
    dataArr.push(
      {
        'title': '健康记忆',
        'subtitle': '记录您的健康时光',
        'img': 'images/picture/jiyi.png',
        'isNew': false,
        'type': '3',
      },
      {
        'title': '心率',
        'subtitle': this.healthDataSummary.heartRate, // 使用实时数据
        'img': 'images/picture/touxiang_1.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': '血氧',
        'subtitle': this.healthDataSummary.bloodOxygen, // 使用实时数据
        'img': 'images/picture/xueyang.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': '步数分析',
        'subtitle': this.healthDataSummary.steps, // 使用实时数据
        'img': 'images/picture/bushu.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': '睡眠',
        'subtitle': this.healthDataSummary.sleep, // 使用实时数据
        'img': 'images/picture/sleep.png',
        'isNew': false,
        'type': '2',
      },
      {
        'title': '热量',
        'subtitle': this.healthDataSummary.calories, // 使用实时数据
        'img': 'images/picture/reliang.png',
        'isNew': false,
        'type': '1',
      },
      {
        'title': '心情',
        'subtitle': this.healthDataSummary.mood, // 使用实时数据
        'img': 'images/picture/xinqing.png',
        'isNew': false,
        'type': '1',
      }
    );

    return dataArr;
  }

  getPopData(): PopMenuItem[] {
    return [
      {
        'text': '健康圈',
        'icon': $rawfile('images/popMenus/ic_chat.png'),
      },
      {
        'text': '添加朋友',
        'icon': $rawfile('images/popMenus/ic_add.png'),
      },
      {
        'text': 'DeepSeek',
        'icon': $rawfile('images/popMenus/ic_scan.png'),
      },
      {
        'text': '开通会员',
        'icon': $rawfile('images/popMenus/ic_pay.png'),
      },
    ];
  }
}