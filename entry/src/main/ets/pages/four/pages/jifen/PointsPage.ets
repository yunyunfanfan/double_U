// pages/StepsInputPage.ets
import { stepsApiService } from '../../../../services/step_api/StepApiService';
import { router } from '@kit.ArkUI';
import { BaseNavigation, KColors } from 'JhCommon';

@Entry
@Component
struct StepsInputPage {
  private userId: number = 1; // 实际应用中应从登录状态获取
  @State steps: string = '';
  @State message: string = '';
  @State isLoading: boolean = false;
  @State points: number = 0; // 新增积分状态

  // 计算积分的方法
  private calculatePoints(steps: number): number {
    return Math.floor(steps / 500);
  }

  build() {
    Column({ space: 20 }) {
      // 返回按钮
      Row() {
        Button('返回')
          .width(80)
          .height(40)
          .backgroundColor('#f0f0f0')
          .fontColor('#333333')
          .onClick(() => {
            router.back(); // 返回上一页
          })

        Text('健康步数记录')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 40 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ top: 30, bottom: 20 })

      // 新增：积分显示区域
      Row() {
        Column() {
          Text('预计获得积分')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.points}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFA500') // 橙色
            .margin({ top: 5 })
        }
        .width('50%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('当前步数')
            .fontSize(16)
            .fontColor('#666666')
          Text(this.steps || '0')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3CB371') // 绿色
            .margin({ top: 5 })
        }
        .width('50%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 2, color: '#E0E0E0', offsetX: 0, offsetY: 2 })

      Text('请输入您今天的步数:')
        .fontSize(18)
        .width('90%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: '例如: 8000' })
        .type(InputType.Number)
        .width('90%')
        .height(60)
        .borderRadius(10)
        .backgroundColor('#f5f5f5')
        .onChange((value: string) => {
          this.steps = value;
          // 实时计算积分
          const stepsNum = parseInt(value) || 0;
          this.points = this.calculatePoints(stepsNum);
        })

      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 20 })
      } else {
        Button('保存步数', { type: ButtonType.Capsule })
          .width('90%')
          .height(50)
          .margin({ top: 20 })
          .backgroundColor('#007aff')
          .fontColor(Color.White)
          .onClick(() => {
            this.saveSteps();
          })
      }

      Text(this.message)
        .fontSize(16)
        .margin({ top: 20 })
        .width('90%')
        .textAlign(TextAlign.Center)
        .fontColor(this.message.includes('成功') ? '#34C759' : '#FF3B30')

      Button('查看历史记录', { type: ButtonType.Normal })
        .width('90%')
        .height(45)
        .margin({ top: 30 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/StepsHistoryPage' });
        })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#ffffff')
  }

  private async saveSteps(): Promise<void> {
    // 验证输入
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

    // 保存数据
    this.isLoading = true;
    this.message = '正在保存...';

    try {
      const result = await stepsApiService.saveSteps(this.userId, stepsNum);

      if (result.success) {
        this.message = `成功保存 ${stepsNum} 步! 获得 ${this.points} 积分`;
        this.steps = ''; // 清空输入框
        this.points = 0; // 重置积分
      } else {
        this.message = `保存失败: ${result.message || '服务器错误'}`;
      }
    } catch (error) {
      this.message = '网络错误，请稍后重试';
      console.error('保存步数错误:', error);
    } finally {
      this.isLoading = false;
    }
  }
}