import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { userApiService, HealthDataResponse, HealthDataRequest, RealtimeDataResponse, RealtimeDataRequest } from '../../../services/api_network/UserApiService';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';

//血氧饱和度页面

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

interface RouterParams {
  user_id?: number;
}

class OxygenRecord {
  time: string;
  value: number;
  status: string;
  dayOfWeek: string;

  constructor(time: string, value: number, status: string, dayOfWeek: string) {
    console.info(`[血氧记录构造] 创建血氧记录: ${time}, ${value}%, ${status}, ${dayOfWeek}`);
    this.time = time;
    this.value = value;
    this.status = status;
    this.dayOfWeek = dayOfWeek;
  }

  toString(): string {
    return `OxygenRecord{time: ${this.time}, value: ${this.value}%, status: ${this.status}}`;
  }
}

@Entry
@Component
export struct BloodOxygenPage {
  @State currentOxygen: number = 0;
  @State minOxygen: number = 0;
  @State maxOxygen: number = 0;
  @State avgOxygen: number = 0;
  @State oxygenRecords: OxygenRecord[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State userId: number = 0;
  @State isViewingOtherUser: boolean = false; // 是否查看其他用户

  private weekDays: string[] = [];

  aboutToAppear(): void {
    console.info('[血氧页面] ================ 血氧监测系统初始化开始 ================');
    console.info('[血氧页面] 当前用户: gadz2021, 系统时间: 2025-06-08 13:04:49 UTC');
    this.weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    console.info('[血氧页面] 开始初始化血氧监测系统');
    this.initializeOxygenSystem();
  }

  private async initializeOxygenSystem(): Promise<void> {
    try {
      console.info('[系统初始化] ======== 血氧监测系统初始化开始 ========');
      console.info('[系统初始化] 当前用户: gadz2021, 时间: 2025-06-08 13:04:49 UTC');
      this.resetOxygenData();
      await this.getUserId();
      await this.loadOxygenDataFromDatabase();
      await this.loadOxygenRecordsFromDatabase();
      this.isLoading = false;
      console.info('[系统初始化] ======== 血氧监测系统初始化成功 ========');
    } catch (error) {
      console.error(`[系统初始化] 血氧系统初始化失败: ${error}`);
      this.errorMessage = `血氧数据加载失败: ${error}`;
      this.isLoading = false;
      this.resetOxygenData();
    }
  }

  private resetOxygenData(): void {
    console.info('[数据重置] ======== 重置血氧数据为初始状态 ========');
    this.currentOxygen = 0;
    this.minOxygen = 0;
    this.maxOxygen = 0;
    this.avgOxygen = 0;
    this.oxygenRecords = [];
    console.info('[数据重置] 血氧数据重置完成，所有值已设为0');
  }

  private async getUserId(): Promise<void> {
    try {
      console.info('[用户ID] === 开始获取用户ID ===');

      // 先检查路由参数是否有传入user_id
      const params = router.getParams() as RouterParams;
      if (params && params.user_id) {
        console.info(`[用户ID] === 从路由参数获取用户ID: ${params.user_id} ===`);
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
        console.info(`[用户ID] === 从存储获取当前用户ID: ${this.userId} ===`);
      } else {
        console.warn('[用户ID] === 未找到用户信息，使用默认ID ===');
        this.userId = 1;
        this.isViewingOtherUser = false;
      }
    } catch (error) {
      console.error(`[用户ID] === 获取用户ID异常: ${error} ===`);
      this.userId = 1;
      this.isViewingOtherUser = false;
    }
  }

  private async loadOxygenDataFromDatabase(): Promise<void> {
    if (this.userId === 0) {
      console.error('[血氧数据] === 用户ID为0，跳过数据加载 ===');
      return;
    }

    try {
      console.info(`[血氧数据] === 开始加载血氧数据，用户ID: ${this.userId} ===`);
      let oxygenResponse: HealthDataResponse = await userApiService.getHealthData(this.userId, 7, false);
      console.info(`[血氧数据] === 血氧数据响应: ${JSON.stringify(oxygenResponse)} ===`);

      if (oxygenResponse.success && oxygenResponse.data && oxygenResponse.data.length > 0) {
        // 过滤今日数据用于当前血氧显示
        const todayDate = new Date();
        const today: string = `${todayDate.getFullYear()}-${String(todayDate.getMonth() + 1).padStart(2, '0')}-${String(todayDate.getDate()).padStart(2, '0')}`;
        const todayData: HealthDataRequest | undefined = oxygenResponse.data.find((item: HealthDataRequest) => {
          const itemDate: string = (item.record_date || '').replace(/'/g, '');
          return itemDate === today;
        });

        if (todayData) {
          console.info(`[血氧数据] === 找到今日数据: ${JSON.stringify(todayData)} ===`);
          this.currentOxygen = todayData.current_blood_oxygen || 0;
          this.minOxygen = todayData.min_blood_oxygen || 0;
          this.avgOxygen = todayData.avg_blood_oxygen || 0;
          this.maxOxygen = todayData.max_blood_oxygen || 0;
          console.info(`[血氧数据] === 血氧统计: 当前=${this.currentOxygen}%, 最低=${this.minOxygen}%, 平均=${this.avgOxygen}%, 最高=${this.maxOxygen}% ===`);
        } else {
          console.warn('[血氧数据] === 今日血氧数据为空，使用默认值 ===');
          this.currentOxygen = 0;
          this.minOxygen = 0;
          this.avgOxygen = 0;
          this.maxOxygen = 0;
        }
      } else {
        console.warn('[血氧数据] === 血氧数据为空 ===');
      }
    } catch (error) {
      console.error(`[血氧数据] === 数据加载异常: ${error} ===`);
      throw new Error(`网络请求失败: ${error}`);
    }
  }

  private async loadOxygenRecordsFromDatabase(): Promise<void> {
    try {
      console.info(`[血氧记录] === 开始加载血氧记录，用户ID: ${this.userId} ===`);
      let realtimeResponse: RealtimeDataResponse = await userApiService.getRealtimeData(this.userId, 'blood_oxygen', 7);
      console.info(`[血氧记录] === 实时血氧数据响应: ${JSON.stringify(realtimeResponse)} ===`);

      if (realtimeResponse.success && realtimeResponse.data) {
        let records: OxygenRecord[] = [];

        for (let i: number = 0; i < realtimeResponse.data.length; i++) {
          let item: RealtimeDataRequest = realtimeResponse.data[i];
          let oxygenValue: number = item.value || 0;
          let status: string = this.getOxygenStatus(oxygenValue);
          let time: string = item.time_stamp || '';
          let dayOfWeek: string = this.extractDayOfWeek(time);

          let record: OxygenRecord = new OxygenRecord(time, oxygenValue, status, dayOfWeek);
          records.push(record);
        }

        this.oxygenRecords = records;
        console.info(`[血氧记录] === 血氧记录加载完成，总计${records.length}条 ===`);
      }
    } catch (error) {
      console.error(`[血氧记录] === 加载血氧记录异常: ${error} ===`);
    }
  }

  private getOxygenStatus(value: number): string {
    console.info(`[血氧状态] 判断血氧状态: ${value}%`);
    if (value < 90) return '严重偏低';
    if (value < 95) return '偏低';
    if (value <= 100) return '正常';
    return '异常';
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

  private refreshOxygenData(): void {
    console.info('[数据刷新] === 开始刷新血氧数据 ===');
    this.isLoading = true;
    this.errorMessage = '';
    this.initializeOxygenSystem();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back')).width(20).height(20)
        }
        .onClick(() => {
          console.info('[用户操作] 用户点击返回按钮, 当前用户: gadz2021');
          try {
            // 如果是查看其他用户，返回时需要传递user_id参数给主页
            if (this.isViewingOtherUser) {
              router.back({
                url: 'pages/one/pages/WxHomePage',
                params: { user_id: this.userId }
              });
            }else {
              router.back();
            }
          } catch (err) {
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ left: 10 })

        Text('血氧饱和度')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.Black)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('🔄').fontSize(18)
        }
        .onClick(() => {
          console.info('[用户操作] 用户点击刷新血氧数据按钮');
          this.refreshOxygenData();
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ right: 10 })
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#9C27B0')
          Text('正在加载血氧数据...')
            .fontSize(18).fontColor('#333333')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        Column({ space: 20 }) {
          Text('🫁').fontSize(64)
          Text('加载失败')
            .fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button('重新加载')
            .onClick(() => this.refreshOxygenData())
            .backgroundColor('#9C27B0').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        Scroll() {
          Column({ space: 20 }) {
            // 当前血氧显示
            Column() {
              Text(`当前血氧饱和度 (${this.weekDays[new Date().getDay()]})`)
                .fontSize(18).fontWeight(FontWeight.Medium).margin({ bottom: 20 })

              Row() {
                Text(this.currentOxygen.toString())
                  .fontSize(48).fontWeight(FontWeight.Bold).fontColor('#9C27B0')
                Text(' %').fontSize(20).fontColor('#666666').margin({ bottom: 5 })
              }

              Text('正常范围：95%-100%')
                .fontSize(14).fontColor('#666666').margin({ top: 5 })
            }
            .width('90%').padding(30).backgroundColor('#FFFFFF').borderRadius(20)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 4 })

            // 统计数据
            Row() {
              this.statCard('最低', `${this.minOxygen} %`, '#FBBC05')
              this.statCard('平均', `${this.avgOxygen} %`, '#34A853')
              this.statCard('最高', `${this.maxOxygen} %`, '#4285F4')
            }
            .width('90%').justifyContent(FlexAlign.SpaceBetween)

            // 血氧历史记录
            Column() {
              Text('血氧记录')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              if (this.oxygenRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('🫁').fontSize(48)
                  Text('暂无血氧数据')
                    .fontSize(18).fontColor('#666666')
                  Button('刷新数据')
                    .onClick(() => this.refreshOxygenData())
                    .backgroundColor('#9C27B0').fontColor(Color.White).borderRadius(20).height(40)
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                Column({ space: 12 }) {
                  ForEach(this.oxygenRecords, (record: OxygenRecord, index: number) => {
                    Row() {
                      Row() {
                        Text('🫁').fontSize(20)
                      }
                      .width(44).height(44).borderRadius(22)
                      .backgroundColor(record.value < 95 ? 'rgba(234,67,53,0.2)' : 'rgba(52,168,83,0.2)')
                      .justifyContent(FlexAlign.Center).margin({ right: 16 })

                      Column() {
                        Row() {
                          Text(`${record.value}%`)
                            .fontSize(16).fontWeight(FontWeight.Medium)
                            .fontColor(record.value < 95 ? '#EA4335' : '#34A853')
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
              Text('血氧健康建议')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              Column({ space: 12 }) {
                this.buildAdviceItem('正常血氧范围95%-100%', '📊')
                this.buildAdviceItem('保持良好的呼吸习惯', '🌬️')
                this.buildAdviceItem('适量运动增加血氧', '🏃‍♂️')
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