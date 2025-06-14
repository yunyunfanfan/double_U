import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { userApiService, HealthDataResponse, HealthDataRequest, RealtimeDataResponse, RealtimeDataRequest } from '../../../services/api_network/UserApiService';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';

//情绪状态页面

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

interface RouterParams {
  user_id?: number;
}

class MoodRecord {
  time: string;
  mood: string;
  description: string;
  color: string;

  constructor(time: string, mood: string, description: string, color: string) {
    this.time = time;
    this.mood = mood;
    this.description = description;
    this.color = color;
  }

  toString(): string {
    return `MoodRecord{time: ${this.time}, mood: ${this.mood}}`;
  }
}

@Entry
@Component
export struct MoodPage {
  @State currentMood: string = '';
  @State moodColor: string = '#4285F4';
  @State moodDescription: string = '';
  @State moodRecords: MoodRecord[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State userId: number = 0;
  @State isViewingOtherUser: boolean = false; // 是否查看其他用户

  private weekDays: string[] = [];

  aboutToAppear(): void {
    console.info('=== 情绪分析页面初始化开始 ===');
    this.currentMood = '无数据';
    this.moodColor = '#4285F4';
    this.moodDescription = '请尝试录入数据';
    this.weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    console.info('=== 初始化设置完成，开始加载数据 ===');
    this.initializeMoodSystem();
  }

  private async initializeMoodSystem(): Promise<void> {
    try {
      console.info('=== 开始初始化情绪系统 ===');
      this.resetMoodData();
      await this.getUserId();
      await this.loadMoodDataFromDatabase();
      await this.loadMoodRecordsFromDatabase();
      this.isLoading = false;
      console.info('=== 情绪系统初始化完成 ===');
    } catch (error) {
      console.error(`=== 初始化异常: ${error} ===`);
      this.errorMessage = `数据加载失败: ${error}`;
      this.isLoading = false;
      this.resetMoodData();
    }
  }

  private resetMoodData(): void {
    console.info('=== 重置情绪数据 ===');
    this.currentMood = '无数据';
    this.moodColor = '#4285F4';
    this.moodDescription = '请尝试录入数据';
    this.moodRecords = [];
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

  private async loadMoodDataFromDatabase(): Promise<void> {
    if (this.userId === 0) {
      console.error('=== 用户ID为0，跳过数据加载 ===');
      return;
    }

    try {
      console.info(`=== 开始加载情绪数据，用户ID: ${this.userId} ===`);
      let moodResponse: HealthDataResponse = await userApiService.getHealthData(this.userId, 7, true);
      console.info(`=== 情绪数据响应: ${JSON.stringify(moodResponse)} ===`);

      if (moodResponse.success && moodResponse.data && moodResponse.data.length > 0) {
        let todayData: HealthDataRequest = moodResponse.data[0];
        console.info(`=== 今日数据: ${JSON.stringify(todayData)} ===`);

        let moodValue: number = todayData.current_mood || -1;
        this.currentMood = this.getMoodFromValue(moodValue);
        this.moodColor = this.getMoodColor(this.currentMood);
        this.moodDescription = this.getMoodDescription(this.currentMood);

        console.info(`=== 今日情绪: ${this.currentMood}, 数值: ${moodValue} ===`);
      } else {
        console.warn('=== 今日情绪数据为空 ===');
      }
    } catch (error) {
      console.error(`=== 数据加载异常: ${error} ===`);
      throw new Error(`网络请求失败: ${error}`);
    }
  }

  private async loadMoodRecordsFromDatabase(): Promise<void> {
    try {
      console.info(`=== 开始加载情绪记录，用户ID: ${this.userId} ===`);
      let realtimeResponse: RealtimeDataResponse = await userApiService.getRealtimeData(this.userId, 'mood', 7);
      console.info(`=== 实时情绪数据响应: ${JSON.stringify(realtimeResponse)} ===`);

      if (realtimeResponse.success && realtimeResponse.data) {
        let records: MoodRecord[] = [];

        for (let i: number = 0; i < realtimeResponse.data.length; i++) {
          let item: RealtimeDataRequest = realtimeResponse.data[i];
          let moodValue: number = item.value || 5;
          let mood: string = this.getMoodFromValue(moodValue);
          let color: string = this.getMoodColor(mood);
          let description: string = this.getMoodDescription(mood);
          let time: string = item.time_stamp || '';

          let record: MoodRecord = new MoodRecord(time, mood, description, color);
          records.push(record);
        }

        this.moodRecords = records;
        console.info(`=== 情绪记录加载完成，总计${records.length}条 ===`);
      }
    } catch (error) {
      console.error(`=== 加载情绪记录异常: ${error} ===`);
    }
  }

  private getMoodFromValue(value: number): string {
    if (value >= 8) return '开心';
    if (value >= 6) return '满足';
    if (value >= 4) return '平静';
    if (value >= 2) return '疲惫';
    if (value >= 0) return '焦虑';
    return '无数据';
  }

  private getMoodDescription(mood: string): string {
    if (mood === '开心') return '心情愉悦，充满活力';
    if (mood === '满足') return '内心满足，状态良好';
    if (mood === '平静') return '保持内心平静';
    if (mood === '疲惫') return '感到有些疲惫';
    if (mood === '焦虑') return '情绪较为紧张';
    if (mood === '无数据') return '等待录入数据'
    return '心情一般';
  }

  private refreshMoodData(): void {
    console.info('=== 用户触发数据刷新 ===');
    this.isLoading = true;
    this.errorMessage = '';
    this.initializeMoodSystem();
  }

  private getMoodColor(mood: string): string {
    if (mood === '开心' || mood === '满足') return '#34A853';
    if (mood === '平静') return '#4285F4';
    if (mood === '疲惫') return '#FBBC05';
    if (mood === '焦虑') return '#EA4335';
    return '#4285F4';
  }

  private getMoodEmoji(mood: string): string {
    if (mood === '开心') return '😊';
    if (mood === '满足') return '😌';
    if (mood === '平静') return '😌';
    if (mood === '疲惫') return '😴';
    if (mood === '焦虑') return '😰';
    if (mood=== '无数据') return '😕';
    return '😐';
  }

  build() {
    Column() {
      // 顶部导航栏
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

        Text('情绪状态')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.Black)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('🔄').fontSize(18)
        }
        .onClick(() => {
          this.refreshMoodData();
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ right: 10 })
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#4285F4')
          Text('正在加载情绪数据...')
            .fontSize(18).fontColor('#333333')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        Column({ space: 20 }) {
          Text('😔').fontSize(64)
          Text('加载失败')
            .fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button('重新加载')
            .onClick(() => this.refreshMoodData())
            .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        Scroll() {
          Column({ space: 20 }) {
            // 当前情绪概览卡片
            Column() {
              Text(`今日情绪状态 (${this.weekDays[new Date().getDay()]})`)
                .fontSize(18).fontWeight(FontWeight.Medium).margin({ bottom: 20 }).fontColor('#333333')

              Column() {
                Text(this.getMoodEmoji(this.currentMood))
                  .fontSize(64).margin({ bottom: 15 })

                Text(this.currentMood)
                  .fontSize(32).fontWeight(FontWeight.Bold).fontColor(this.moodColor).margin({ bottom: 10 })

                Text(this.moodDescription)
                  .fontSize(16).fontColor('#666666').textAlign(TextAlign.Center).maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%').alignItems(HorizontalAlign.Center)
            }
            .width('90%').padding(30).backgroundColor('#FFFFFF').borderRadius(20)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 4 })

            // 情绪记录卡片
            Column() {
              Text('情绪记录')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              if (this.moodRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('😐').fontSize(48)
                  Text('暂无情绪数据')
                    .fontSize(18).fontColor('#666666')
                  Button('刷新数据')
                    .onClick(() => this.refreshMoodData())
                    .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(20).height(40)
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                Column({ space: 12 }) {
                  ForEach(this.moodRecords, (record: MoodRecord, index: number) => {
                    Row() {
                      Row() {
                        Text(this.getMoodEmoji(record.mood))
                          .fontSize(20)
                      }
                      .width(44).height(44).borderRadius(22)
                      .backgroundColor(record.color + '20')
                      .justifyContent(FlexAlign.Center).margin({ right: 16 })

                      Column() {
                        Row() {
                          Text(record.mood)
                            .fontSize(16).fontWeight(FontWeight.Medium).fontColor(record.color)
                          Blank()
                          Text(record.time)
                            .fontSize(12).fontColor('#999999')
                        }
                        .width('100%')

                        Text(record.description)
                          .fontSize(14).fontColor('#666666').margin({ top: 4 })
                          .textAlign(TextAlign.Start).width('100%').maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
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

            // 情绪健康建议
            Column() {
              Row() {
                Text('情绪健康建议')
                  .fontSize(18).fontWeight(FontWeight.Medium).fontColor('#333333')
                Blank()
                Text('💡').fontSize(20)
              }
              .width('100%').margin({ bottom: 15 })

              Column({ space: 12 }) {
                this.buildMoodAdviceItem('定期冥想有助于放松心情', '🧘‍♂️')
                this.buildMoodAdviceItem('适量运动能够改善情绪', '🏃‍♂️')
                this.buildMoodAdviceItem('充足睡眠对情绪稳定很重要', '😴')
                this.buildMoodAdviceItem('与朋友交流分享心情', '👥')
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
  buildMoodAdviceItem(advice: string, icon: string) {
    Row() {
      Text(icon).fontSize(20).margin({ right: 12 })
      Text(advice)
        .fontSize(14).fontColor('#333333').textAlign(TextAlign.Start)
        .layoutWeight(1).maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%').padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .backgroundColor('#F8F9FA').borderRadius(8).alignItems(VerticalAlign.Top)
  }
}