import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { userApiService, HealthDataResponse, HealthDataRequest } from '../../../services/api_network/UserApiService';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';

///这是步数分析页面

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

interface RouterParams {
  user_id?: number;
}

class WeeklyStepData {
  date: string = '';
  steps: number = 0;
  distance: number = 0;
}

class StepRecord {
  time: string = '';
  value: number = 0;
  distance: string = '';
  dayOfWeek: string = '';
  timestamp: string = '';

  constructor(time: string, value: number, distance: string, dayOfWeek?: string, timestamp?: string) {
    this.time = time;
    this.value = value;
    this.distance = distance;
    this.dayOfWeek = dayOfWeek || '';
    this.timestamp = timestamp || '';
  }

  toString(): string {
    return `StepRecord{time: ${this.time}, value: ${this.value}步, distance: ${this.distance}}`;
  }
}

@Entry
@Component
export struct StepCountPage {
  @State currentSteps: number = 0;
  @State dailyGoal: number = 0;
  @State weeklyAvg: number = 0;
  @State distance: string = '';
  @State calories: string = '';
  @State stepRecords: StepRecord[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State hasDataLoaded: boolean = false;
  @State userId: number = 0;
  @State isViewingOtherUser: boolean = false; // 添加到组件状态变量中


  private weekDays: string[] = [];

  aboutToAppear(): void {
    console.info('=== 步数分析页面初始化开始 ===');
    this.distance = '0公里';
    this.calories = '0千卡';

    this.weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    console.info('=== 初始化设置完成，开始加载数据 ===');
    this.initializeStepSystem();
  }

  private async initializeStepSystem(): Promise<void> {
    try {
      console.info('=== 开始初始化步数系统 ===');
      this.resetStepData();
      await this.getUserId();
      await this.loadHealthDataFromDatabase();
      this.isLoading = false;
      console.info('=== 步数系统初始化完成 ===');
    } catch (error) {
      let errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error(`=== 初始化异常: ${errorMessage} ===`);
      this.errorMessage = `数据加载失败: ${errorMessage}`;
      this.isLoading = false;
      this.resetStepData();
    }
  }

  private resetStepData(): void {
    console.info('=== 重置步数数据 ===');
    this.currentSteps = 0;
    this.dailyGoal = 0;
    this.weeklyAvg = 0;
    this.distance = '0公里';
    this.calories = '0千卡';
    this.stepRecords = [];
    this.hasDataLoaded = false;
  }


  private async getUserId(): Promise<void> {
    try {
      console.info('=== 开始获取用户ID ===');

      // 先检查路由参数是否有传入user_id
      const params = router.getParams() as RouterParams;
      if (params && params.user_id) {
        console.info(`=== 从路由参数获取用户ID: ${params.user_id} ===`);
        this.userId = params.user_id;
        this.isViewingOtherUser = true;
        return;
      }

      // 如果没有路由参数，则从AppStorage获取当前登录用户
      const userInfoStr = AppStorage.get<string>('userInfo');
      const userInfo: UserInfo = userInfoStr ? JSON.parse(userInfoStr) as UserInfo : {};

      if (userInfo && userInfo.userId) {
        this.userId = parseInt(userInfo.userId);
        this.isViewingOtherUser = false;
        console.info(`=== 从存储获取当前用户ID: ${this.userId} ===`);
      } else {
        console.warn('=== 未找到用户信息，使用默认ID ===');
        this.userId = 1;
        this.isViewingOtherUser = false;
      }
    } catch (error) {
      console.error(`=== 获取用户ID异常: ${error} ===`);
      this.userId = 1;
      this.isViewingOtherUser = false;
    }
  }

  private async loadHealthDataFromDatabase(): Promise<void> {
    if (this.userId === 0) {
      console.error('=== 用户ID为0，跳过数据加载 ===');
      return;
    }

    try {
      console.info(`=== 开始加载健康数据，用户ID: ${this.userId} ===`);
      // 获取7天历史数据用于周步数记录
      let healthResponse: HealthDataResponse = await userApiService.getHealthData(this.userId, 7, false);
      console.info(`=== 健康数据响应: ${JSON.stringify(healthResponse)} ===`);

      if (healthResponse.success && healthResponse.data && healthResponse.data.length > 0) {
        // 过滤今日数据用于当前步数显示
        const todayDate = new Date();
        const today: string = `${todayDate.getFullYear()}-${String(todayDate.getMonth() + 1).padStart(2, '0')}-${String(todayDate.getDate()).padStart(2, '0')}`;
        const todayData: HealthDataRequest | undefined = healthResponse.data.find((item: HealthDataRequest) => {
          const itemDate: string = (item.record_date || '').replace(/'/g, '');
          return itemDate === today;
        });

        if (todayData) {
          console.info(`=== 找到今日数据: ${JSON.stringify(todayData)} ===`);
          this.currentSteps = todayData.steps || 0;
          this.dailyGoal = todayData.steps_goal || 0;
          this.distance = `${todayData.distance || 0}公里`;
          this.calories = `${todayData.active_calories || 0}千卡`;
          console.info(`=== 今日步数: ${this.currentSteps}, 目标: ${this.dailyGoal} ===`);
        } else {
          console.warn('=== 今日步数数据为空，使用默认值 ===');
          this.currentSteps = 0;
          this.dailyGoal = 0;
          this.distance = '0公里';
          this.calories = '0千卡';
        }

        // 生成周步数记录（使用所有7天数据）
        console.info(`=== 开始处理周数据，数据长度: ${healthResponse.data.length} ===`);
        let weeklyStepData: WeeklyStepData[] = [];

        for (let i = 0; i < healthResponse.data.length; i++) {
          let item = healthResponse.data[i];
          let stepData = new WeeklyStepData();
          let rawDate = item.record_date || '';
          if (rawDate.startsWith("'") && rawDate.endsWith("'")) {
            stepData.date = rawDate.slice(1, -1);
          } else {
            stepData.date = rawDate;
          }
          console.info(`=== 日期处理: ${rawDate} -> ${stepData.date} ===`);
          stepData.steps = item.steps || 0;
          stepData.distance = item.distance || 0;
          weeklyStepData.push(stepData);

          console.info(`=== 处理数据[${i}]: 日期=${stepData.date}, 步数=${stepData.steps} ===`);
        }

        console.info(`=== 周数据处理完成，总计${weeklyStepData.length}条 ===`);
        this.generateWeeklyDisplayDataFromDatabase(weeklyStepData);
      } else {
        console.warn('=== 步数数据为空 ===');
      }

      this.hasDataLoaded = true;
    } catch (error) {
      let errorMessage = error instanceof Error ? error.message : '网络请求失败';
      console.error(`=== 数据加载异常: ${errorMessage} ===`);
      throw new Error(errorMessage);
    }
  }

  private generateWeeklyDisplayDataFromDatabase(weeklyData: WeeklyStepData[]): void {
    console.info(`=== 开始生成周显示数据，输入数据: ${weeklyData.length}条 ===`);

    let displayRecords: StepRecord[] = [];
    let today = new Date();
    let todayString = today.toISOString().split('T')[0];
    let totalSteps = 0;
    let validDays = 0;

    console.info(`=== 今天日期: ${todayString} ===`);
    console.info(`=== 可用数据列表: ===`);
    weeklyData.forEach((data: WeeklyStepData, index: number) => {
      console.info(`=== 数据[${index}]: ${data.date} -> ${data.steps}步 ===`);
    });

    for (let i = 1; i <= 6; i++) {
      let targetDate = new Date();
      targetDate.setDate(today.getDate() - i);
      let targetDateString = targetDate.toISOString().split('T')[0];
      let dayName = this.weekDays[targetDate.getDay()];

      console.info(`=== 查找第${i}天数据，目标日期: ${targetDateString} (${dayName}) ===`);

      let stepData = weeklyData.find((data: WeeklyStepData) => {
        let match = data.date === targetDateString;
        console.info(`=== 比较: ${data.date} === ${targetDateString} -> ${match} ===`);
        return match;
      });

      let steps = stepData ? stepData.steps : 0;
      let distance = stepData ? `${stepData.distance}公里` : '0公里';
      console.info(`=== ${targetDateString}(${dayName}): 找到=${stepData ? '是' : '否'}, 步数=${steps} ===`);
      let stepRecord = new StepRecord(dayName, steps, distance, dayName);
      displayRecords.push(stepRecord);

      if (steps > 0) {
        totalSteps += steps;
        validDays++;
      }
    }

    // 不需要reverse，保持原来的顺序就是周六到周一
    this.stepRecords = displayRecords;

    console.info(`=== 最终记录数量: ${this.stepRecords.length} ===`);
    this.stepRecords.forEach((record: StepRecord, index: number) => {
      console.info(`=== 最终记录[${index}]: ${record.toString()} ===`);
    });

    this.weeklyAvg = validDays > 0 ? Math.round(totalSteps / validDays) : 0;
    console.info(`=== 周平均步数: ${this.weeklyAvg} (总步数: ${totalSteps}, 有效天数: ${validDays}) ===`);

    let nonZeroSteps = this.stepRecords.filter((record: StepRecord) => record.value > 0);
    if (nonZeroSteps.length > 0) {
      let sum = nonZeroSteps.reduce((total: number, record: StepRecord) => total + record.value, 0);
      this.weeklyAvg = Math.round(sum / nonZeroSteps.length);
      console.info(`=== 重新计算周平均: ${this.weeklyAvg} ===`);
    } else {
      this.weeklyAvg = 0;
      console.warn('=== 无有效步数数据，周平均为0 ===');
    }
  }

  private refreshStepData(): void {
    console.info('=== 用户触发数据刷新 ===');
    this.isLoading = true;
    this.errorMessage = '';
    this.initializeStepSystem();
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back')).width(20).height(20)
        }
        .onClick(() => {
          try {
            // 如果是查看其他用户，返回时需要传递user_id参数给主页
            if (this.isViewingOtherUser) {
              router.back({
                url: 'pages/one/pages/WxHomePage',
                params: { user_id: this.userId }
              });
            } else {
              router.back();
            }
          } catch (err) {
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ left: 10 })

        Text('步数分析')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.Black)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('🔄').fontSize(18)
        }
        .onClick(() => {
          this.refreshStepData();
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ right: 10 })
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#4285F4')
          Text('正在加载步数数据...')
            .fontSize(18).fontColor('#333333')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        Column({ space: 20 }) {
          Text('👟').fontSize(64)
          Text('加载失败')
            .fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button('重新加载')
            .onClick(() => this.refreshStepData())
            .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        Scroll() {
          Column({ space: 20 }) {
            Column() {
              Text(`今日步数 (${this.weekDays[new Date().getDay()]})`)
                .fontSize(18).fontWeight(FontWeight.Medium).margin({ bottom: 20 }).fontColor('#333333')

              Stack() {
                Progress({ value: 100, total: 100, type: ProgressType.Ring })
                  .width(160).height(160).color('#F0F0F0').style({ strokeWidth: 12 })

                Progress({
                  value: this.dailyGoal > 0 ? this.currentSteps : 0,
                  total: this.dailyGoal > 0 ? this.dailyGoal : 1,
                  type: ProgressType.Ring
                })
                  .width(160).height(160).color('#4285F4').style({ strokeWidth: 12 })

                Column() {
                  Text(this.currentSteps.toString()).fontSize(36).fontWeight(FontWeight.Bold).fontColor('#4285F4')
                  Text('步')
                    .fontSize(16).fontColor('#666666').margin({ top: 4 })
                  Text(`${this.dailyGoal > 0 ? Math.round((this.currentSteps / this.dailyGoal) * 100) : 0}%`)
                    .fontSize(14).fontColor('#999999').margin({ top: 8 })
                }
              }
              .margin({ bottom: 30 })

              Row({ space: 20 }) {
                this.buildStatCard('目标', `${this.dailyGoal} 步`, '#4285F4', '🎯')
                this.buildStatCard('距离', this.distance, '#34A853', '📍')
                this.buildStatCard('热量', this.calories, '#EA4335', '🔥')
              }
              .width('100%').justifyContent(FlexAlign.SpaceAround)
            }
            .width('90%').padding(30).backgroundColor('#FFFFFF').borderRadius(20)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 4 })

            Column() {
              Text('步数记录')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              if (this.stepRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('👟').fontSize(48)
                  Text('暂无步数数据')
                    .fontSize(18).fontColor('#666666')
                  Button('刷新数据')
                    .onClick(() => this.refreshStepData())
                    .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(20).height(40)
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                Column({ space: 8 }) {
                  ForEach(this.stepRecords, (record: StepRecord, index: number) => {
                    Row() {
                      Text(record.time).fontSize(16).fontColor('#333333').width('30%')
                      Text(`${record.value} 步`).fontSize(16).fontColor('#4285F4')
                        .fontWeight(FontWeight.Medium).width('40%').textAlign(TextAlign.Center)
                      Text(record.distance).fontSize(16).fontColor('#666666').width('30%').textAlign(TextAlign.End)
                    }
                    .width('100%').padding({ top: 12, bottom: 12, left: 16, right: 16 })
                    .backgroundColor(index % 2 === 0 ? '#F8F9FA' : '#FFFFFF').borderRadius(8)
                  })
                }
              }
            }
            .width('90%').backgroundColor('#FFFFFF').borderRadius(15).padding(20)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.06)', offsetX: 0, offsetY: 3 })
          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor('#F8F9FA')
  }

  @Builder
  buildStatCard(label: string, value: string, color: string, icon: string) {
    Column() {
      Text(icon).fontSize(20).margin({ bottom: 6 })
      Text(label).fontSize(12).fontColor('#999999').margin({ bottom: 4 })
      Text(value).fontSize(14).fontWeight(FontWeight.Bold).fontColor(color).textAlign(TextAlign.Center)
    }
    .width(80).height(80).padding(8).backgroundColor('#F8F9FA').borderRadius(12)
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .border({ width: 1, color: color })
  }
}