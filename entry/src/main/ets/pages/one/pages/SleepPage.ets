import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { userApiService, HealthDataResponse, HealthDataRequest } from '../../../services/api_network/UserApiService';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';

///这是睡眠分析页面

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

class SleepPhaseData {
  type: string = '';
  duration: number = 0;

  constructor(type: string, duration: number) {
    this.type = type;
    this.duration = duration;
  }
}

class SleepRecord {
  date: string = '';
  duration: string = '';
  quality: string = '';
  score: number = 0;

  constructor(date: string, duration: string, quality: string, score: number) {
    this.date = date;
    this.duration = duration;
    this.quality = quality;
    this.score = score;
  }

  toString(): string {
    return `SleepRecord{date: ${this.date}, duration: ${this.duration}, score: ${this.score}}`;
  }
}

@Entry
@Component
export struct SleepPage {
  @State sleepScore: number = 0;
  @State totalSleepTime: string = '0小时0分钟';
  @State bedTime: string = '00:00';
  @State wakeTime: string = '00:00';
  @State sleepPhases: SleepPhaseData[] = [];
  @State sleepRecords: SleepRecord[] = [];
  @State selectedTimeRange: string = '';
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State userId: number = 0;

  private timeRanges: string[] = [];
  private weekDays: string[] = [];

  aboutToAppear(): void {
    console.info('=== 睡眠分析页面初始化开始 ===');
    this.selectedTimeRange = '本周';
    this.timeRanges = ['今天', '本周', '本月', '今年'];
    this.weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    console.info('=== 初始化设置完成，开始加载数据 ===');
    this.initializeSleepSystem();
  }

  private async initializeSleepSystem(): Promise<void> {
    try {
      console.info('=== 开始初始化睡眠系统 ===');
      this.resetSleepData();
      await this.getUserId();
      await this.loadSleepDataFromDatabase();
      this.isLoading = false;
      console.info('=== 睡眠系统初始化完成 ===');
    } catch (error) {
      let errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error(`=== 初始化异常: ${errorMessage} ===`);
      this.errorMessage = `数据加载失败: ${errorMessage}`;
      this.isLoading = false;
      this.resetSleepData();
    }
  }

  private resetSleepData(): void {
    console.info('=== 重置睡眠数据 ===');
    this.sleepScore = 0;
    this.totalSleepTime = '0小时0分钟';
    this.bedTime = '00:00';
    this.wakeTime = '00:00';
    this.sleepPhases = [];
    this.sleepRecords = [];
  }

  private async getUserId(): Promise<void> {
    try {
      console.info('=== 开始获取用户ID ===');
      let userInfo: UserInfo = await JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as UserInfo;
      if (userInfo && userInfo.userId) {
        this.userId = parseInt(userInfo.userId);
        console.info(`=== 获取到用户ID: ${this.userId} ===`);
      } else {
        console.warn('=== 未找到用户信息，使用默认ID ===');
        this.userId = 1;
      }
    } catch (error) {
      console.error(`=== 获取用户ID异常: ${error} ===`);
      this.userId = 1;
    }
  }

  private async loadSleepDataFromDatabase(): Promise<void> {
    if (this.userId === 0) {
      console.error('=== 用户ID为0，跳过数据加载 ===');
      return;
    }

    try {
      console.info(`=== 开始加载睡眠数据，用户ID: ${this.userId} ===`);
      let sleepResponse: HealthDataResponse = await userApiService.getHealthData(this.userId, 7);
      console.info(`=== 睡眠数据响应: ${JSON.stringify(sleepResponse)} ===`);

      if (sleepResponse.success && sleepResponse.data && sleepResponse.data.length > 0) {
        let todayData: HealthDataRequest = sleepResponse.data[0];
        console.info(`=== 今日数据: ${JSON.stringify(todayData)} ===`);

        this.sleepScore = todayData.sleep_score || 0;
        this.totalSleepTime = this.formatDuration(todayData.sleep_duration || 0);
        this.bedTime = todayData.sleep_start_time || '00:00';
        this.wakeTime = todayData.sleep_end_time || '00:00';

        this.sleepPhases = [
          new SleepPhaseData('深睡眠', todayData.deep_sleep_duration || 0),
          new SleepPhaseData('浅睡眠', todayData.light_sleep_duration || 0),
          new SleepPhaseData('快速眼动', todayData.rem_sleep_duration || 0),
          new SleepPhaseData('清醒', todayData.awake_duration || 0)
        ];

        console.info(`=== 今日睡眠分数: ${this.sleepScore}, 时长: ${this.totalSleepTime} ===`);
      } else {
        console.warn('=== 今日睡眠数据为空 ===');
      }

      if (sleepResponse.success && sleepResponse.data) {
        this.generateWeeklySleepRecords(sleepResponse.data);
      } else {
        console.warn('=== 周睡眠数据为空或失败 ===');
      }
    } catch (error) {
      let errorMessage = error instanceof Error ? error.message : '网络请求失败';
      console.error(`=== 数据加载异常: ${errorMessage} ===`);
      throw new Error(errorMessage);
    }
  }

  private generateWeeklySleepRecords(sleepData: HealthDataRequest[]): void {
    console.info(`=== 开始生成周睡眠记录，输入数据: ${sleepData.length}条 ===`);

    let records: SleepRecord[] = [];
    let today = new Date();

    for (let i = 1; i <= 6; i++) {
      let targetDate = new Date();
      targetDate.setDate(today.getDate() - i);
      let targetDateString = targetDate.toISOString().split('T')[0];
      let dayName = this.weekDays[targetDate.getDay()];

      let sleepItem = sleepData.find((item: HealthDataRequest) => {
        let itemDate = (item.record_date || '').replace(/'/g, '');
        return itemDate === targetDateString;
      });

      let score = sleepItem ? sleepItem.sleep_score || 0 : 0;
      let duration = sleepItem ? this.formatDuration(sleepItem.sleep_duration || 0) : '0小时0分钟';
      let quality = this.getScoreLevel(score);

      let record = new SleepRecord(dayName, duration, quality, score);
      records.push(record);

      console.info(`=== ${targetDateString}(${dayName}): 分数=${score}, 时长=${duration} ===`);
    }

    this.sleepRecords = records;
    console.info(`=== 睡眠记录生成完成，总计${records.length}条 ===`);
  }

  private formatDuration(minutes: number): string {
    let hours = Math.floor(minutes / 60);
    let mins = minutes % 60;
    return `${hours}小时${mins}分钟`;
  }

  private getScoreLevel(score: number): string {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 60) return '一般';
    if (score == 0) return '--'
    return '较差';
  }

  private refreshSleepData(): void {
    console.info('=== 用户触发数据刷新 ===');
    this.isLoading = true;
    this.errorMessage = '';
    this.initializeSleepSystem();
  }

  build() {
    Column() {
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

        Text('睡眠分析')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.Black)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('🔄').fontSize(18)
        }
        .onClick(() => {
          this.refreshSleepData();
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ right: 10 })
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#4285F4')
          Text('正在加载睡眠数据...')
            .fontSize(18).fontColor('#333333')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        Column({ space: 20 }) {
          Text('😴').fontSize(64)
          Text('加载失败')
            .fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button('重新加载')
            .onClick(() => this.refreshSleepData())
            .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        Scroll() {
          Column({ space: 20 }) {
            Column() {
              Text(`今日睡眠概况 (${this.weekDays[new Date().getDay()]})`)
                .fontSize(18).fontWeight(FontWeight.Medium).margin({ bottom: 20 }).fontColor('#333333')

              Stack() {
                Progress({ value: 100, total: 100, type: ProgressType.Ring })
                  .width(160).height(160).color('#F0F0F0').style({ strokeWidth: 12 })

                Progress({
                  value: this.sleepScore,
                  total: 100,
                  type: ProgressType.Ring
                })
                  .width(160).height(160)
                  .color(this.sleepScore >= 80 ? '#34A853' : this.sleepScore >= 60 ? '#FBBC05' : '#EA4335')
                  .style({ strokeWidth: 12 })

                Column() {
                  Text(this.sleepScore.toString())
                    .fontSize(36).fontWeight(FontWeight.Bold)
                    .fontColor(this.sleepScore >= 80 ? '#34A853' : this.sleepScore >= 60 ? '#FBBC05' : '#EA4335')
                  Text('分')
                    .fontSize(16).fontColor('#666666').margin({ top: 4 })
                  Text(this.getScoreLevel(this.sleepScore))
                    .fontSize(14).fontColor('#999999').margin({ top: 8 })
                }
              }
              .margin({ bottom: 30 })

              Row({ space: 20 }) {
                this.buildSleepStatCard('时长', this.totalSleepTime, '#34A853', '🛌')
                this.buildSleepStatCard('入睡', this.bedTime, '#4285F4', '🌙')
                this.buildSleepStatCard('醒来', this.wakeTime, '#FBBC05', '☀️')
              }
              .width('100%').justifyContent(FlexAlign.SpaceAround)
            }
            .width('90%').padding(30).backgroundColor('#FFFFFF').borderRadius(20)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 4 })

            Column() {
              Text('睡眠阶段分析')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              Column({ space: 12 }) {
                ForEach(this.sleepPhases, (phase: SleepPhaseData, index: number) => {
                  Row() {
                    Text(phase.type)
                      .fontSize(15).fontColor('#333333').fontWeight(FontWeight.Medium)
                      .width('30%')
                    Text(this.formatDuration(phase.duration))
                      .fontSize(14).fontColor('#666666')
                      .width('70%').textAlign(TextAlign.End)
                  }
                  .width('100%').padding({ top: 12, bottom: 12, left: 16, right: 16 })
                  .backgroundColor(index % 2 === 0 ? '#F8F9FA' : '#FFFFFF').borderRadius(8)
                })
              }
            }
            .width('90%').backgroundColor('#FFFFFF').borderRadius(15).padding(20)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.06)', offsetX: 0, offsetY: 3 })

            Column() {
              Text('睡眠记录')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              if (this.sleepRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('😴').fontSize(48)
                  Text('暂无睡眠数据')
                    .fontSize(18).fontColor('#666666')
                  Button('刷新数据')
                    .onClick(() => this.refreshSleepData())
                    .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(20).height(40)
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                Column({ space: 8 }) {
                  ForEach(this.sleepRecords, (record: SleepRecord, index: number) => {
                    Row() {
                      Text(record.date).fontSize(16).fontColor('#333333').width('20%')
                      Text(record.duration).fontSize(16).fontColor('#34A853')
                        .fontWeight(FontWeight.Medium).width('40%').textAlign(TextAlign.Center)
                      Text(record.quality).fontSize(16)
                        .fontColor(
                          record.score === 0 ? '#808080' :
                            record.score >= 80 ? '#34A853' :
                              record.score >= 60 ? '#FBBC05' :
                                '#EA4335'
                        )
                        .width('20%').textAlign(TextAlign.Center)
                      Text(`${record.score}分`).fontSize(16).fontColor('#666666')
                        .width('20%').textAlign(TextAlign.End)
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
  buildSleepStatCard(label: string, value: string, color: string, icon: string) {
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