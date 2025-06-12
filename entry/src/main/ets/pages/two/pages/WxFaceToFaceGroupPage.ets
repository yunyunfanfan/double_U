import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { router } from '@kit.ArkUI'
import { userApiService, RegisterResponse } from '../../../services/api_network/UserApiService'

interface UserData {
  userId: string;
  userName: string;
  phone: string;
  loginTime: string;
}

///面对面加成员

@Entry
@Preview
@Component
struct WxFaceToFaceGroupPage {
  @State groupNumberArr: string[] = ['', '', '', '']
  @State currentIndex: number = 0
  @State showCopyTip: boolean = false
  @State isLoading: boolean = false
  @State currentUserId: number = 0

  aboutToAppear(): void {
    console.info('[面对面加好友] 页面初始化');
    this.loadCurrentUser();
  }

  private loadCurrentUser(): void {
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        const userInfo: UserData = JSON.parse(userInfoStr) as UserData;
        this.currentUserId = parseInt(userInfo.userId);
        console.info(`[面对面加好友] 当前用户ID: ${this.currentUserId}`);
      }
    } catch (error) {
      console.error(`[面对面加好友] 获取用户信息失败:`, error);
    }
  }

  private async handleFaceToFaceAdd(): Promise<void> {
    const fourDigitCode: string = this.groupNumberArr.join('');

    if (fourDigitCode.length !== 4) {
      JhProgressHUD.showText('请输入4位数字');
      return;
    }

    if (this.currentUserId === 0) {
      JhProgressHUD.showText('请先登录');
      return;
    }

    this.isLoading = true;
    console.info(`[面对面加好友] 开始匹配，代码: ${fourDigitCode}`);

    try {
      const response: RegisterResponse = await userApiService.createFaceToFaceSession(
        this.currentUserId,
        fourDigitCode
      );

      if (response.success) {
        // 根据后端返回的message判断是否匹配成功
        const isMatched = response.message?.includes('添加家庭成员成功') ||
        response.message?.includes('匹配成功') ||
        response.message?.includes('成功');

        if (isMatched) {
          JhProgressHUD.showSuccess('匹配成功，已添加为家庭成员');
          setTimeout(() => {
            router.back();
          }, 1500);
        } else {
          JhProgressHUD.showText('等待其他人输入相同数字...');
          this.showCopyTip = true;
          setTimeout(() => {
            this.showCopyTip = false;
          }, 5000);
        }
      } else {
        JhProgressHUD.showError(response.message || '添加失败');
      }
    } catch (error) {
      console.error(`[面对面加好友] 添加异常:`, error);
      JhProgressHUD.showError('网络连接失败');
    } finally {
      this.isLoading = false;
    }
  }

  getKeys(): string[][] {
    return [
      ['1','2','3'],
      ['4','5','6'],
      ['7','8','9'],
      ['清空','0','删除']
    ]
  }

  build() {
    Column() {
      BaseNavigation({
        title: '面对面添加成员',
        bgColor: Color.Transparent
      })

      Column() {
        Text('输入4个数字, 添加身边的家庭成员')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 40, bottom: 20 })
          .width('100%')
          .textAlign(TextAlign.Center)

        Row() {
          ForEach([0,1,2,3], (i: number) => {
            Column() {
              Text(this.groupNumberArr[i] || '')
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222')
                .width(48)
                .height(56)
                .border({ width: 2, color: this.currentIndex === i ? '#07C160' : '#E5E5E5' })
                .backgroundColor('#FFF')
                .textAlign(TextAlign.Center)
                .margin({ left: i === 0 ? 0 : 12 })
            }
          })
        }
        .margin({ bottom: 32 })

        Column() {
          ForEach([0,1,2], (rowIdx: number) => {
            Row() {
              ForEach(this.getKeys()[rowIdx], (key: string, colIdx: number) => {
                Button(key)
                  .width(72)
                  .height(56)
                  .fontSize(22)
                  .backgroundColor('#FFF')
                  .fontColor('#222')
                  .borderRadius(8)
                  .margin({ left: colIdx === 0 ? 0 : 16, top: rowIdx === 0 ? 0 : 16 })
                  .onClick(() => this.handleKeyPress(key))
                  .enabled(!this.isLoading)
              })
            }
          })

          Row() {
            Blank().width(72)
            Button('0')
              .width(72)
              .height(56)
              .fontSize(22)
              .backgroundColor('#FFF')
              .fontColor('#222')
              .borderRadius(8)
              .onClick(() => this.handleKeyPress('0'))
              .margin({ left: 16, right: 16 })
              .enabled(!this.isLoading)
            Button('⌫')
              .width(72)
              .height(56)
              .fontSize(22)
              .backgroundColor('#FFF')
              .fontColor('#222')
              .borderRadius(8)
              .onClick(() => this.handleKeyPress('删除'))
              .enabled(!this.isLoading)
          }
          .margin({ top: 16 })
        }

        if (this.groupNumberArr.every(num => num !== '')) {
          if (this.isLoading) {
            Row() {
              LoadingProgress()
                .width(20)
                .height(20)
                .color('#07C160')
                .margin({ right: 8 })
              Text('匹配中...')
                .fontSize(16)
                .fontColor('#07C160')
            }
            .margin({ top: 32 })
          } else {
            Button('开始匹配')
              .width('80%')
              .height(44)
              .backgroundColor('#07C160')
              .fontColor(Color.White)
              .fontSize(16)
              .borderRadius(4)
              .margin({ top: 32 })
              .onClick(() => this.handleFaceToFaceAdd())
          }
        }

        if (this.showCopyTip) {
          Text('等待其他人输入相同的4位数字')
            .fontSize(14)
            .fontColor('#07C160')
            .margin({ top: 8 })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ top: 60 })
      .alignItems(HorizontalAlign.Center)
    }
    .backgroundColor('#F7F7F7')
  }

  handleKeyPress(key: string) {
    if (this.isLoading) return;

    if (key === '删除') {
      for (let i = 3; i >= 0; i--) {
        if (this.groupNumberArr[i] !== '') {
          this.groupNumberArr[i] = ''
          this.currentIndex = i
          break
        }
      }
    } else if (key === '清空') {
      this.groupNumberArr = ['', '', '', '']
      this.currentIndex = 0
    } else if (/^\d$/.test(key)) {
      for (let i = 0; i < 4; i++) {
        if (this.groupNumberArr[i] === '') {
          this.groupNumberArr[i] = key
          this.currentIndex = i < 3 ? i + 1 : 3
          break
        }
      }
    }
  }
}