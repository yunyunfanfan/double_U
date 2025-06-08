import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { userApiService, HealthDataResponse } from '../../../services/api_network/UserApiService';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';

///这是步数分析页面

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

class WeeklyStepData {
  date: string = '';
  steps: number = 0;
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
  @State selectedTimeRange: string = '';
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State hasDataLoaded: boolean = false;
  @State userId: number = 0;

  private timeRanges: string[] = [];
  private weekDays: string[] = [];

  aboutToAppear(): void {
    this.selectedTimeRange = '本周';
    this.distance = '0公里';
    this.calories = '0千卡';

    this.timeRanges = ['今天', '本周', '本月', '今年'];
    this.weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    this.initializeStepSystem();
  }

  private async initializeStepSystem(): Promise<void> {
    try {
      this.resetStepData();
      await this.getUserId();
      await this.loadHealthDataFromDatabase();
      this.isLoading = false;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      this.errorMessage = `数据加载失败: ${errorMessage}`;
      this.isLoading = false;
      this.resetStepData();
    }
  }

  private resetStepData(): void {
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
      const userInfo: UserInfo = await JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as UserInfo;
      if (userInfo && userInfo.userId) {
        this.userId = parseInt(userInfo.userId);
      }
    } catch (error) {
      this.userId = 1;
    }
  }

  private async loadHealthDataFromDatabase(): Promise<void> {
    if (this.userId === 0) {
      return;
    }

    try {
      const healthResponse: HealthDataResponse = await userApiService.getHealthData(this.userId, 7);
      const weeklyResponse: HealthDataResponse = await userApiService.getWeeklySteps(this.userId);

      if (healthResponse.success && healthResponse.data && healthResponse.data.length > 0) {
        const todayData = healthResponse.data[0];
        this.currentSteps = todayData.steps || 0;
        this.dailyGoal = todayData.steps_goal || 10000;
        this.distance = `${todayData.distance || 0}公里`;
        this.calories = `${todayData.active_calories || 0}千卡`;
      }

      if (weeklyResponse.success && weeklyResponse.data) {
        const weeklyStepData: WeeklyStepData[] = [];
        for (let i = 0; i < weeklyResponse.data.length; i++) {
          const item = weeklyResponse.data[i];
          const stepData = new WeeklyStepData();
          stepData.date = item.record_date || '';
          stepData.steps = item.steps || 0;
          weeklyStepData.push(stepData);
        }
        this.generateWeeklyDisplayDataFromDatabase(weeklyStepData);
      }

      this.hasDataLoaded = true;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '网络请求失败';
      throw new Error(errorMessage);
    }
  }

  private generateWeeklyDisplayDataFromDatabase(weeklyData: WeeklyStepData[]): void {
    const displayRecords: StepRecord[] = [];
    const currentDate = new Date();
    const currentWeekDay = currentDate.getDay();

    let totalSteps = 0;
    let validDays = 0;

    for (let i = 0; i < 7; i++) {
      const dayIndex = (currentWeekDay + 6 - i) % 7;
      const dayName = this.weekDays[dayIndex];

      const stepData = weeklyData.find((data: WeeklyStepData) => {
        const dataDate = new Date(data.date);
        return dataDate.getDay() === dayIndex;
      });

      const steps = stepData ? stepData.steps : 0;
      const isToday = dayIndex === currentWeekDay;
      const displayName = isToday ? `${dayName}(今天)` : dayName;

      const stepRecord = new StepRecord(
        displayName,
        steps,
        `${(steps * 0.0008).toFixed(1)}公里`,
        dayName
      );

      displayRecords.unshift(stepRecord);
    }

    this.stepRecords = displayRecords;

    const nonZeroSteps = this.stepRecords.filter((record: StepRecord) => record.value > 0);
    if (nonZeroSteps.length > 0) {
      const sum = nonZeroSteps.reduce((total: number, record: StepRecord) => total + record.value, 0);
      this.weeklyAvg = Math.round(sum / nonZeroSteps.length);
    } else {
      this.weeklyAvg = 0;
    }
  }

  private refreshStepData(): void {
    this.isLoading = true;
    this.errorMessage = '';
    this.initializeStepSystem();
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back')).width(20).height(20)
        }
        .onClick(() => {
          try {
            router.back();
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
            // 今日步数显示
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

            // 时间范围
            Row() {
              ForEach(this.timeRanges, (range: string) => {
                Text(range)
                  .fontSize(14)
                  .fontColor(this.selectedTimeRange === range ? '#4285F4' : '#666666')
                  .fontWeight(this.selectedTimeRange === range ? FontWeight.Bold : FontWeight.Normal)
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor(this.selectedTimeRange === range ? '#E8F0FE' : '#F5F5F5')
                  .borderRadius(20)
                  .border({
                    width: this.selectedTimeRange === range ? 2 : 1,
                    color: this.selectedTimeRange === range ? '#4285F4' : '#E0E0E0'
                  })
                  .onClick(() => {
                    this.selectedTimeRange = range;
                  })
              })
            }
            .width('90%').justifyContent(FlexAlign.SpaceAround)

            // 步数记录
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