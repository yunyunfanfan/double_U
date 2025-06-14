import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { WxNewFriendModel } from '../models/WxNewFriendModel'
import { WxNewFriendCell } from '../widgets/WxNewFriendCell'
import { router } from '@kit.ArkUI'
import { userApiService, AllUsersResponse, UserWithFriendStatus, RegisterResponse } from '../../../services/api_network/UserApiService'
import { UserApiService } from '../../../services/api_network/UserApiService'

///雷达加好友页面

interface UserInfoFromStorage {
  userId: string;
  userName: string;
  phone: string;
  loginTime: string;
}

@Entry
@Preview
@Component
struct WxRadarAddMemberPage {
  @State dataArr: WxNewFriendModel[] = []
  @State isScanning: boolean = false
  @State scanAngle: number = 0
  @State scanOpacity: number = 0.3
  @State waveScale: number = 1.0
  @State waveOpacity: number = 0.8
  @State currentUserId: number = 1
  @State nearbyUsers: UserWithFriendStatus[] = []
  private scanTimer: number = -1
  private waveTimer: number = -1

  aboutToAppear() {
    console.info('[雷达加好友页面] 页面初始化开始');
    this.loadCurrentUser();
    this.loadNearbyUsers();
  }

  aboutToDisappear() {
    this.stopAllTimers()
  }

  // 加载当前用户信息
  private loadCurrentUser(): void {
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        const userInfo: UserInfoFromStorage = JSON.parse(userInfoStr) as UserInfoFromStorage;
        if (userInfo && userInfo.userId) {
          this.currentUserId = parseInt(userInfo.userId);
          console.info(`[雷达加好友页面] 当前用户ID: ${this.currentUserId}`);
        } else {
          console.warn('[雷达加好友页面] 未找到用户信息，使用默认ID');
          this.currentUserId = 1;
        }
      } else {
        console.warn('[雷达加好友页面] AppStorage中无用户信息，使用默认ID');
        this.currentUserId = 1;
      }
    } catch (error) {
      console.error(`[雷达加好友页面] 获取用户ID异常: ${error}`);
      this.currentUserId = 1;
    }
  }

  // 加载附近用户（实际是所有非好友用户）
  private async loadNearbyUsers(): Promise<void> {
    try {
      console.info('[雷达加好友页面] 开始加载附近用户');
      const response: AllUsersResponse = await userApiService.getAllUsers(this.currentUserId);

      if (response.success && response.users) {
        // 过滤出非好友用户
        this.nearbyUsers = response.users.filter((user: UserWithFriendStatus) => !user.is_friend);
        this.convertToWxNewFriendModels();
        console.info(`[雷达加好友页面] 加载附近用户成功，共${this.nearbyUsers.length}个用户`);
      } else {
        console.error(`[雷达加好友页面] 加载用户失败: ${response.message}`);
        this.dataArr = [];
      }
    } catch (error) {
      console.error(`[雷达加好友页面] 加载用户异常: ${error}`);
      this.dataArr = [];
    }
  }

  // 转换用户数据为页面数据模型
  private convertToWxNewFriendModels(): void {
    this.dataArr = this.nearbyUsers.map((user: UserWithFriendStatus) => {
      const maskedPhone = this.maskPhoneNumber(user.phone);
      const model: WxNewFriendModel = {
        title: user.username,
        subtitle: maskedPhone,
        img: this.getUserAvatarSource(user.avatar_url),
        isAdd: false,
        userId: user.id
      };
      return model;
    });
  }

  // 获取用户头像源
  private getUserAvatarSource(avatarUrl: string): string {
    console.info(`[雷达加好友页面] 原始头像URL: "${avatarUrl}"`);
    if (avatarUrl && avatarUrl.trim() !== '') {
      const processedUrl = UserApiService.getUserDisplayAvatar(avatarUrl);
      console.info(`[雷达加好友页面] 处理后的头像URL: "${processedUrl}"`);
      return processedUrl;
    }
    const defaultUrl = UserApiService.getDefaultAvatarUrl();
    console.info(`[雷达加好友页面] 使用默认头像URL: "${defaultUrl}"`);
    return defaultUrl;
  }

  // 手机号脱敏处理
  private maskPhoneNumber(phone: string): string {
    if (!phone || phone.length !== 11) {
      return '手机号未知';
    }
    return `${phone.substring(0, 3)}****${phone.substring(7)}`;
  }

  // 添加好友
  private async addFriend(userId: number, userName: string): Promise<void> {
    try {
      console.info(`[雷达加好友页面] 开始添加好友: ${userName}`);
      const response: RegisterResponse = await userApiService.addFamilyMember(this.currentUserId, userId, '朋友');

      if (response.success) {
        JhProgressHUD.showToast('添加好友成功');
        const targetUser = this.dataArr.find((item: WxNewFriendModel) => item.userId === userId);
        if (targetUser) {
          targetUser.isAdd = true;
        }
        console.info(`[雷达加好友页面] 添加好友成功: ${userName}`);
      } else {
        JhProgressHUD.showToast(response.message || '添加失败');
        console.error(`[雷达加好友页面] 添加好友失败: ${response.message}`);
      }
    } catch (error) {
      console.error(`[雷达加好友页面] 添加好友异常: ${error}`);
      JhProgressHUD.showToast('网络连接失败');
    }
  }

  stopAllTimers() {
    if (this.scanTimer !== -1) {
      clearInterval(this.scanTimer)
      this.scanTimer = -1
    }
    if (this.waveTimer !== -1) {
      clearInterval(this.waveTimer)
      this.waveTimer = -1
    }
  }

  build() {
    Column() {
      BaseNavigation({
        title: '雷达加成员',
        bgColor: Color.Transparent
      })
      this.content()
    }
    .backgroundColor('#F7F7F7')
  }

  @Builder
  content() {
    Column() {
      this.radarView()
      this.memberList()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  radarView() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 雷达背景
        Circle()
          .width(200)
          .height(200)
          .fill('#1A1A1A')

        // 扫描动画
        Circle()
          .width(200)
          .height(200)
          .fill('#07C160')
          .opacity(this.scanOpacity)
          .rotate({ angle: this.scanAngle })
          .clip(new Circle({ width: 200, height: 200 }))

        // 波纹动画
        ForEach([1, 2, 3], (index: number) => {
          Circle()
            .width(200)
            .height(200)
            .fill('#07C160')
            .opacity(this.waveOpacity / (index + 1))
            .scale({ x: this.waveScale + (index * 0.2), y: this.waveScale + (index * 0.2) })
        })

        // 中心点
        Circle()
          .width(20)
          .height(20)
          .fill('#07C160')
      }
      .width('100%')
      .height(250)
      .margin({ top: 20 })

      // 加载提示文字
      if (this.isScanning) {
        Text('正在搜索附近的人...')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 10 })
      }

      Button(this.isScanning ? '停止搜索' : '开始搜索')
        .width(180)
        .height(40)
        .backgroundColor('#07C160')
        .fontColor(Color.White)
        .fontSize(16)
        .borderRadius(4)
        .margin({ top: 10 })
        .onClick(() => {
          this.isScanning = !this.isScanning
          if (this.isScanning) {
            this.startScanning()
            this.loadNearbyUsers()
          } else {
            this.stopScanning()
          }
        })
    }
  }

  @Builder
  memberList() {
    List() {
      ForEach(this.dataArr, (item: WxNewFriendModel) => {
        ListItem() {
          WxNewFriendCell({
            model: item,
            onClickCell: () => {
              this.clickCell(item.title!)
            },
            onClickBtn: () => {
              if (item.userId) {
                this.addFriend(item.userId, item.title!);
              }
            },
          })
        }
      })
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
    .divider({
      strokeWidth: 0.5,
      startMargin: 0,
      endMargin: 0,
      color: '#1A1A1A'
    })
  }

  startScanning() {
    const direction: number = 1
    this.scanTimer = setInterval(() => {
      this.scanAngle = (this.scanAngle + 2) % 360
      this.scanOpacity += direction * 0.01
      if (this.scanOpacity >= 0.3) {
        // direction = -1
      } else if (this.scanOpacity <= 0.1) {
        // direction = 1
      }
    }, 16)

    this.waveTimer = setInterval(() => {
      this.waveScale += 0.02
      this.waveOpacity -= 0.01
      if (this.waveScale >= 1.5) {
        this.waveScale = 1.0
        this.waveOpacity = 0.8
      }
    }, 50)
  }

  stopScanning() {
    this.stopAllTimers()
    this.scanAngle = 0
    this.scanOpacity = 0.3
    this.waveScale = 1.0
    this.waveOpacity = 0.8
  }

  clickCell(text: string) {
    JhProgressHUD.showText(`点击了 ${text}`)
  }
}