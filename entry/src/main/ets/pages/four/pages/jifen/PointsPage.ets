// pages/StepsInputPage.ets
import { userApiService } from '../../../../services/api_network/UserApiService';
import { router } from '@kit.ArkUI';
import { BaseNavigation, KColors } from 'JhCommon';

@Entry
@Component
struct StepsInputPage {
  private userId: number = 1;
  @State steps: string = '';
  @State message: string = '';
  @State isLoading: boolean = false;
  @State points: number = 0;

  private calculatePoints(steps: number): number {
    return Math.floor(steps / 500);
  }
  private currentUserId: number = 1;

  aboutToAppear(): void {
    this.loadCurrentUser();
  }

  private loadCurrentUser(): void {
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        interface UserInfoFromStorage {
          userId: string;
          userName: string;
          phone: string;
          loginTime: string;
        }
        const userInfo: UserInfoFromStorage = JSON.parse(userInfoStr) as UserInfoFromStorage;
        this.currentUserId = parseInt(userInfo.userId);
        console.info(`[AI健康录入] 当前用户ID: ${this.currentUserId}`);
      }
    } catch (error) {
      console.error(`[AI健康录入] 获取用户信息失败:`, error);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back')).width(20).height(20)
        }
        .onClick(() => {
          router.back();
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ left: 10 })

        Text('积分录入')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          .layoutWeight(1).textAlign(TextAlign.Center)

        // 占位符保持对称
        Row().width(40).height(40).margin({ right: 10 })
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFF').shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

      Scroll() {
        Column({ space: 20 }) {
          // 步数预览卡片
          Column({ space: 10 }) {
            Text('今日步数')
              .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text(this.steps || '0')
              .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#4CAF50')
          }
          .width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(12)
          .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

          // 积分预览卡片
          Column({ space: 10 }) {
            Text('预计获得积分')
              .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
            Text(`${this.points}`)
              .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#FF9800')
            Text('每500步 = 1积分')
              .fontSize(12).fontColor('#999999')
          }
          .width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(12)
          .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

          // 输入区域
          Column({ space: 15 }) {
            Text('请输入今日步数')
              .fontSize(16).fontColor('#333333').width('100%')

            TextInput({ placeholder: '例如: 8000' })
              .type(InputType.Number).width('100%').height(50)
              .borderRadius(10).backgroundColor('#F8F9FA')
              .border({ width: 1, color: '#E9ECEF' })
              .onChange((value: string) => {
                this.steps = value;
                const stepsNum = parseInt(value) || 0;
                this.points = this.calculatePoints(stepsNum);
              })

            Text('每500步可获得1积分')
              .fontSize(12).fontColor('#999999').width('100%')
          }
          .width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(15)
          .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

          // 保存按钮
          if (this.isLoading) {
            Column() {
              LoadingProgress().width(40).height(40).color('#4CAF50')
              Text('正在保存...').fontSize(14).fontColor('#4CAF50').margin({ top: 10 })
            }.height(80).justifyContent(FlexAlign.Center)
          } else {
            Button('保存积分', { type: ButtonType.Capsule })
              .width('90%').height(50).backgroundColor('#4CAF50').fontColor(Color.White)
              .onClick(() => { this.savePoints(); })
          }

          // 消息提示
          if (this.message) {
            Text(this.message)
              .fontSize(14).width('90%').textAlign(TextAlign.Center).padding(15)
              .backgroundColor(this.message.includes('成功') ? '#E8F5E8' : '#FFE8E8')
              .fontColor(this.message.includes('成功') ? '#4CAF50' : '#F44336')
              .borderRadius(8)
          }

          // 历史记录按钮
          Button('查看排行榜', { type: ButtonType.Normal })
            .width('90%').height(45).backgroundColor('#2196F3').fontColor(Color.White)
            .borderRadius(10).margin({ bottom: 20 })
            .onClick(() => { router.pushUrl({ url: 'pages/four/pages/jifen/PointsRankingPage' }); })
        }
        .padding({ top: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F8F9FA')
  }

  private async savePoints(): Promise<void> {
    if (!this.steps.trim()) {
      this.message = '请输入步数';
      return;
    }

    const stepsNum = parseInt(this.steps);
    if (isNaN(stepsNum)) {
      this.message = '请输入有效的数字';
      return;
    }

    if (stepsNum <= 0) {
      this.message = '步数必须大于0';
      return;
    }

    if (stepsNum > 100000) {
      this.message = '步数不能超过100,000';
      return;
    }

    this.isLoading = true;
    this.message = '';

    try {
      console.info(`=== 准备添加积分: 用户${this.currentUserId}, 积分${this.points} ===`);
      const result = await userApiService.addPoints(this.currentUserId, this.points, 'steps', `步数录入: ${stepsNum}步`);

      if (result.success) {
        this.message = `成功添加 ${this.points} 积分! (基于 ${stepsNum} 步)`;
        this.steps = '';
        this.points = 0;
        console.info(`=== 积分添加成功 ===`);
      } else {
        this.message = `保存失败: ${result.message || '服务器错误'}`;
        console.error(`=== 积分添加失败: ${result.message} ===`);
      }
    } catch (error) {
      this.message = '网络错误，请稍后重试';
      console.error('=== 添加积分异常:', error, ' ===');
    } finally {
      this.isLoading = false;
    }
  }
}