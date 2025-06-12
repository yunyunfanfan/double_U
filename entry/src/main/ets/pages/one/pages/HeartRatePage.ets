import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { userApiService, HealthDataResponse, HealthDataRequest, RealtimeDataResponse, RealtimeDataRequest } from '../../../services/api_network/UserApiService';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';

///这是心率页面

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

// 心率记录数据结构
class HeartRateRecord {
  time: string = '';
  value: number = 0;
  status: string = '';
  dayOfWeek: string = '';

  constructor(time: string, value: number, status: string, dayOfWeek: string) {
    console.info(`[心率记录构造] 创建心率记录: ${time}, ${value}bpm, ${status}, ${dayOfWeek}`);
    this.time = time;
    this.value = value;
    this.status = status;
    this.dayOfWeek = dayOfWeek;
  }

  toString(): string {
    return `HeartRateRecord{time: ${this.time}, value: ${this.value}bpm, status: ${this.status}}`;
  }
}

@Entry
@Component
export struct HeartRatePage {
  @State currentHeartRate: number = 0;
  @State restingHeartRate: number = 0;
  @State minHeartRate: number = 0;
  @State maxHeartRate: number = 0;
  @State avgHeartRate: number = 0;
  @State heartRateRecords: HeartRateRecord[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State userId: number = 0;

  private weekDays: string[] = [];

  aboutToAppear(): void {
    console.info('[心率页面] ================ 心率监测系统初始化开始 ================');
    console.info('[心率页面] 当前用户: gadz2021, 系统时间: 2025-06-08 13:21:16 UTC');
    this.weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    console.info('[心率页面] 开始初始化心率监测系统');
    this.initializeHeartRateSystem();
  }

  private async initializeHeartRateSystem(): Promise<void> {
    try {
      console.info('[系统初始化] ======== 心率监测系统初始化开始 ========');
      console.info('[系统初始化] 当前用户: gadz2021, 时间: 2025-06-08 13:21:16 UTC');
      this.resetHeartRateData();
      await this.getUserId();
      await this.loadHeartRateDataFromDatabase();
      await this.loadHeartRateRecordsFromDatabase();
      this.isLoading = false;
      console.info('[系统初始化] ======== 心率监测系统初始化成功 ========');
    } catch (error) {
      console.error(`[系统初始化] 心率系统初始化失败: ${error}`);
      this.errorMessage = `心率数据加载失败: ${error}`;
      this.isLoading = false;
      this.resetHeartRateData();
    }
  }

  private resetHeartRateData(): void {
    console.info('[数据重置] ======== 重置心率数据为初始状态 ========');
    this.currentHeartRate = 0;
    this.restingHeartRate = 0;
    this.minHeartRate = 0;
    this.maxHeartRate = 0;
    this.avgHeartRate = 0;
    this.heartRateRecords = [];
    console.info('[数据重置] 心率数据重置完成，所有值已设为0');
  }

  private async getUserId(): Promise<void> {
    try {
      console.info('[用户ID] === 开始获取用户ID ===');
      const userInfoStr = AppStorage.get<string>('userInfo');
      const userInfo: UserInfo = userInfoStr ? JSON.parse(userInfoStr) as UserInfo : {};      if (userInfo && userInfo.userId) {
        this.userId = parseInt(userInfo.userId);
        console.info(`[用户ID] === 获取到用户ID: ${this.userId} ===`);
      } else {
        console.warn('[用户ID] === 未找到用户信息，使用默认ID ===');
        this.userId = 1;
      }
    } catch (error) {
      console.error(`[用户ID] === 获取用户ID异常: ${error} ===`);
      this.userId = 1;
    }
  }

  private async loadHeartRateDataFromDatabase(): Promise<void> {
    if (this.userId === 0) {
      console.error('[心率数据] === 用户ID为0，跳过数据加载 ===');
      return;
    }

    try {
      console.info(`[心率数据] === 开始加载心率数据，用户ID: ${this.userId} ===`);
      let heartRateResponse: HealthDataResponse = await userApiService.getHealthData(this.userId, 1, true);
      console.info(`[心率数据] === 心率数据响应: ${JSON.stringify(heartRateResponse)} ===`);

      if (heartRateResponse.success && heartRateResponse.data && heartRateResponse.data.length > 0) {
        let todayData: HealthDataRequest = heartRateResponse.data[0];
        console.info(`[心率数据] === 今日数据: ${JSON.stringify(todayData)} ===`);

        this.currentHeartRate = todayData.current_heart_rate || 0;
        this.restingHeartRate = todayData.resting_heart_rate || 0;
        this.minHeartRate = todayData.min_heart_rate || 0;
        this.avgHeartRate = todayData.avg_heart_rate || 0;
        this.maxHeartRate = todayData.max_heart_rate || 0;

        console.info(`[心率数据] === 心率统计: 当前=${this.currentHeartRate}bpm, 静息=${this.restingHeartRate}bpm, 最低=${this.minHeartRate}bpm, 平均=${this.avgHeartRate}bpm, 最高=${this.maxHeartRate}bpm ===`);
      } else {
        console.warn('[心率数据] === 今日心率数据为空 ===');
      }
    } catch (error) {
      console.error(`[心率数据] === 数据加载异常: ${error} ===`);
      throw new Error(`网络请求失败: ${error}`);
    }
  }

  private async loadHeartRateRecordsFromDatabase(): Promise<void> {
    try {
      console.info(`[心率记录] === 开始加载心率记录，用户ID: ${this.userId} ===`);
      let realtimeResponse: RealtimeDataResponse = await userApiService.getRealtimeData(this.userId, 'heart_rate', 7);
      console.info(`[心率记录] === 实时心率数据响应: ${JSON.stringify(realtimeResponse)} ===`);

      if (realtimeResponse.success && realtimeResponse.data) {
        let records: HeartRateRecord[] = [];

        for (let i: number = 0; i < realtimeResponse.data.length; i++) {
          let item: RealtimeDataRequest = realtimeResponse.data[i];
          let heartRateValue: number = item.value || 0;
          let status: string = this.getHeartRateStatus(heartRateValue);
          let time: string = item.time_stamp || '';
          let dayOfWeek: string = this.extractDayOfWeek(time);

          let record: HeartRateRecord = new HeartRateRecord(time, heartRateValue, status, dayOfWeek);
          records.push(record);
        }

        this.heartRateRecords = records;
        console.info(`[心率记录] === 心率记录加载完成，总计${records.length}条 ===`);
      }
    } catch (error) {
      console.error(`[心率记录] === 加载心率记录异常: ${error} ===`);
    }
  }

  private getHeartRateStatus(value: number): string {
    console.info(`[心率状态] 判断心率状态: ${value}bpm`);
    if (value < 60) return '偏低';
    if (value <= 100) return '正常';
    if (value <= 120) return '略高';
    return '偏高';
  }

  private extractDayOfWeek(timestamp: string): string {
    if (!timestamp) {
      return this.weekDays[new Date().getDay()];
    }
    let date: Date = new Date(timestamp);
    if (!isNaN(date.getTime())) {
      return this.weekDays[date.getDay()];
    }
    return this.weekDays[new Date().getDay()];
  }

  private getStatusColor(value: number): string {
    if (value < 60) return '#FBBC05';
    if (value <= 100) return '#34A853';
    if (value <= 120) return '#FF9800';
    return '#EA4335';
  }

  private getStatusBackgroundColor(value: number): string {
    if (value < 60) return 'rgba(251, 188, 5, 0.1)';
    if (value <= 100) return 'rgba(52, 168, 83, 0.1)';
    if (value <= 120) return 'rgba(255, 152, 0, 0.1)';
    return 'rgba(234, 67, 53, 0.1)';
  }

  private refreshHeartRateData(): void {
    console.info('[数据刷新] === 开始刷新心率数据 ===');
    this.isLoading = true;
    this.errorMessage = '';
    this.initializeHeartRateSystem();
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back')).width(20).height(20)
        }
        .onClick(() => {
          console.info('[用户操作] 用户点击返回按钮, 当前用户: gadz2021');
          try {
            router.back();
          } catch (err) {
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ left: 10 })

        Text('心率监测')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.Black)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('🔄').fontSize(18)
        }
        .onClick(() => {
          console.info('[用户操作] 用户点击刷新心率数据按钮');
          this.refreshHeartRateData();
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ right: 10 })
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#EA4335')
          Text('正在加载心率数据...')
            .fontSize(18).fontColor('#333333')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        Column({ space: 20 }) {
          Text('💔').fontSize(64)
          Text('加载失败')
            .fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button('重新加载')
            .onClick(() => this.refreshHeartRateData())
            .backgroundColor('#EA4335').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        Scroll() {
          Column({ space: 20 }) {
            // 当前心率卡片
            Column() {
              Text(`当前心率 (${this.weekDays[new Date().getDay()]})`)
                .fontSize(18).fontWeight(FontWeight.Medium).margin({ bottom: 20 })

              Row() {
                Text('❤️').fontSize(32)
                Text(this.currentHeartRate.toString())
                  .fontSize(48).fontWeight(FontWeight.Bold).fontColor('#EA4335')
                Text(' bpm').fontSize(20).fontColor('#666666').margin({ bottom: 8 })
              }
              .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Bottom)

              Text(this.getHeartRateStatus(this.currentHeartRate))
                .fontSize(16).fontColor(this.getStatusColor(this.currentHeartRate))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.getStatusBackgroundColor(this.currentHeartRate)).borderRadius(12)

              Text('正常范围：60-100 bpm')
                .fontSize(14).fontColor('#666666').margin({ top: 5 })

              Text(`静息心率：${this.restingHeartRate} bpm`)
                .fontSize(14).fontColor('#666666').margin({ top: 5 })
            }
            .width('90%').padding(30).backgroundColor('#FFFFFF').borderRadius(20)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 4 })

            // 统计数据
            Row() {
              this.statCard('最低', `${this.minHeartRate} bpm`, '#4285F4')
              this.statCard('平均', `${this.avgHeartRate} bpm`, '#34A853')
              this.statCard('最高', `${this.maxHeartRate} bpm`, '#EA4335')
            }
            .width('90%').justifyContent(FlexAlign.SpaceBetween)

            // 心率记录列表
            Column() {
              Text('心率记录')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              if (this.heartRateRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('💔').fontSize(48)
                  Text('暂无心率数据')
                    .fontSize(18).fontColor('#666666')
                  Button('刷新数据')
                    .onClick(() => this.refreshHeartRateData())
                    .backgroundColor('#EA4335').fontColor(Color.White).borderRadius(20).height(40)
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                Column({ space: 12 }) {
                  ForEach(this.heartRateRecords, (record: HeartRateRecord, index: number) => {
                    Row() {
                      Row() {
                        Text('❤️').fontSize(20)
                      }
                      .width(44).height(44).borderRadius(22)
                      .backgroundColor(this.getStatusBackgroundColor(record.value))
                      .justifyContent(FlexAlign.Center).margin({ right: 16 })

                      Column() {
                        Row() {
                          Text(`${record.value} bpm`)
                            .fontSize(16).fontWeight(FontWeight.Medium)
                            .fontColor(this.getStatusColor(record.value))
                          Blank()
                          Text(record.time)
                            .fontSize(12).fontColor('#999999')
                        }
                        .width('100%')

                        Text(record.status)
                          .fontSize(14).fontColor('#666666').margin({ top: 4 })
                          .textAlign(TextAlign.Start).width('100%')
                      }
                      .layoutWeight(1).alignItems(HorizontalAlign.Start)
                    }
                    .width('100%').height(60).padding({ top: 8, bottom: 8, left: 12, right: 12 })
                    .backgroundColor(index % 2 === 0 ? '#F8F9FA' : '#FFFFFF').borderRadius(12)
                    .alignItems(VerticalAlign.Center)
                  })
                }
              }
            }
            .width('90%').backgroundColor('#FFFFFF').borderRadius(15).padding(20)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.06)', offsetX: 0, offsetY: 3 })

            // 健康建议
            Column() {
              Text('心率健康建议')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              Column({ space: 12 }) {
                this.buildAdviceItem('正常心率范围60-100 bpm', '📊')
                this.buildAdviceItem('适量运动有助心率健康', '🏃‍♂️')
                this.buildAdviceItem('避免过量咖啡因摄入', '☕')
                this.buildAdviceItem('异常时及时咨询医生', '👨‍⚕️')
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
  statCard(title: string, value: string, color: string) {
    Column() {
      Text(title).fontSize(14).fontColor('#666666')
      Text(value).fontSize(18).fontWeight(FontWeight.Bold).fontColor(color)
    }
    .width('30%').padding(15).backgroundColor('#FFFFFF').borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetY: 3 })
  }

  @Builder
  buildAdviceItem(advice: string, icon: string) {
    Row() {
      Text(icon).fontSize(20).margin({ right: 12 })
      Text(advice)
        .fontSize(14).fontColor('#333333').textAlign(TextAlign.Start)
        .layoutWeight(1).maxLines(3)
    }
    .width('100%').padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .backgroundColor('#F8F9FA').borderRadius(8).alignItems(VerticalAlign.Top)
  }
}