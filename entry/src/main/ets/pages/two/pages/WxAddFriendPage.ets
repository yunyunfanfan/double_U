///  WxAddFriendPage.ets
///  description:  添加朋友
// 我是傻逼
import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxAddFriendModel } from '../models/WxAddFriendModel'
import { WxAddFriendCell } from '../widgets/WxAddFriendCell'
import { router } from '@kit.ArkUI';

@Entry
@Preview
@Component
struct WxAddFriendPage {
  @State dataArr: WxAddFriendModel[] = []
  @State searchValue: string = ''

  aboutToAppear() {
    this.dataArr = this.getData()
  }

  build() {
    Column() {
      BaseNavigation({ title: '添加成员', bgColor: Color.Transparent })
      Scroll() {
        Column() {
          this.header()
          this.body()
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: true
      })
    }
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  body() {
    List() {
      ForEach(this.dataArr, (item: WxAddFriendModel, index: number) => {
        ListItem() {
          WxAddFriendCell({
            model: item,
            onClickCell: () => {
              this.clickCell(item)
            },
          })
        }
      })
    }
    .layoutWeight(1)
    .divider({
      strokeWidth: 0.5,
      startMargin: 0,
      endMargin: 0,
      color: KColors.kLineColor
    })
  }

  @Builder
  header() {
    Column() {
      Search({ value: this.searchValue, placeholder: '输入完整手机号查找成员' })
        .borderRadius(5)
        .margin(10)
        .backgroundColor(Color.White)
        .onSubmit((value: string) => {
          console.info('[添加朋友页面] 搜索提交:', value);
          if (value.trim() !== '') {
            this.navigateToSearch(value.trim());
          }
        })
        .onChange((value: string) => {
          this.searchValue = value;
        })
    }
  }

  private navigateToSearch(searchValue: string): void {
    console.info('[添加朋友页面] 导航到搜索页面:', searchValue);
    router.pushUrl({
      url: 'pages/two/pages/WxSearchUserPage',
      params: {
        searchValue: searchValue
      }
    });
  }

  clickCell(item: WxAddFriendModel) {
    switch (item.title) {
      case '雷达加成员':
        router.pushUrl({ url: 'pages/two/pages/WxRadarAddMemberPage' });
        break;
      case '面对面添加家庭成员':
        router.pushUrl({ url: 'pages/two/pages/WxFaceToFaceGroupPage' });
        break;
      case '健康客服':
        router.pushUrl({ url: 'pages/three/pages/CustomerServicePage' });
        break;
      case '扫一扫':
        router.pushUrl({ url: 'pages/two/pages/WxScanPage' });
        break;
      default:
        JhProgressHUD.showText(`点击了 ${item.title}`);
        break;
    }
  }

  getData(): WxAddFriendModel[] {
    const dataArr: WxAddFriendModel[] = [
      {
        'title': '雷达加成员',
        'subtitle': '添加身边的家庭成员',
        'img': 'wechat/contacts/add/add_friend_icon_reda_36x36_@3x.png',
      },
      {
        'title': '面对面添加家庭成员',
        'subtitle': '输入四位数字, 添加身边的家庭成员',
        'img': 'wechat/contacts/add/add_friend_icon_addgroup_36x36_@3x.png',
      },
      {
        'title': '健康客服',
        'subtitle': '获取健康咨询服务',
        'img': 'wechat/contacts/add/add_friend_icon_search_wework_40x40_@2x.png',
      },
    ];
    return dataArr;
  }
}