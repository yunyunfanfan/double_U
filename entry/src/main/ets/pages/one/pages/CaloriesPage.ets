import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { userApiService, HealthDataResponse, HealthDataRequest } from '../../../services/api_network/UserApiService';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';

//活动热量

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

class CalorieRecord {
  time: string;
  value: number;
  dayOfWeek: string;

  constructor(time: string, value: number, dayOfWeek: string) {
    this.time = time;
    this.value = value;
    this.dayOfWeek = dayOfWeek;
  }
}

@Entry
@Component
export struct CaloriesPage {
  @State totalCalories: number = 0;
  @State caloriesGoal: number = 0;
  @State activeCalories: number = 0;
  @State restingCalories: number = 0;
  @State calorieRecords: CalorieRecord[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State userId: number = 0;

  private weekDays: string[] = [];

  aboutToAppear(): void {
    console.info('=== 热量分析页面初始化开始 ===');
    this.weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    console.info('=== 初始化设置完成，开始加载数据 ===');
    this.initializeCalorieSystem();
  }

  private async initializeCalorieSystem(): Promise<void> {
    try {
      console.info('=== 开始初始化热量系统 ===');
      this.resetCalorieData();
      await this.getUserId();
      await this.loadCalorieDataFromDatabase();
      this.isLoading = false;
      console.info('=== 热量系统初始化完成 ===');
    } catch (error) {
      console.error(`=== 初始化异常: ${error} ===`);
      this.errorMessage = `数据加载失败: ${error}`;
      this.isLoading = false;
      this.resetCalorieData();
    }
  }

  private resetCalorieData(): void {
    console.info('=== 重置热量数据 ===');
    this.totalCalories = 0;
    this.caloriesGoal = 0;
    this.activeCalories = 0;
    this.restingCalories = 0;
    this.calorieRecords = [];
  }

  private async getUserId(): Promise<void> {
    try {
      console.info('=== 开始获取用户ID ===');
      const userInfoStr = AppStorage.get<string>('userInfo');
      const userInfo: UserInfo = userInfoStr ? JSON.parse(userInfoStr) as UserInfo : {};      if (userInfo && userInfo.userId) {
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

  private async loadCalorieDataFromDatabase(): Promise<void> {
    if (this.userId === 0) {
      console.error('=== 用户ID为0，跳过数据加载 ===');
      return;
    }

    try {
      console.info(`=== 开始加载热量数据，用户ID: ${this.userId} ===`);
      // 获取7天历史数据用于周热量记录
      let calorieResponse: HealthDataResponse = await userApiService.getHealthData(this.userId, 7, false);
      console.info(`=== 热量数据响应: ${JSON.stringify(calorieResponse)} ===`);

      if (calorieResponse.success && calorieResponse.data && calorieResponse.data.length > 0) {
        // 过滤今日数据用于当前热量显示
        const today: string = new Date().toISOString().split('T')[0];
        const todayData: HealthDataRequest | undefined = calorieResponse.data.find((item: HealthDataRequest) => {
          const itemDate: string = (item.record_date || '').replace(/'/g, '');
          return itemDate === today;
        });

        if (todayData) {
          console.info(`=== 找到今日数据: ${JSON.stringify(todayData)} ===`);
          this.activeCalories = todayData.active_calories || 0;
          this.caloriesGoal = todayData.calories_goal || 2000;
          this.restingCalories = todayData.basic_metabolism_calories || 0;
          this.totalCalories = this.activeCalories + this.restingCalories;
          console.info(`=== 今日热量: 活动=${this.activeCalories}, 基础=${this.restingCalories}, 总计=${this.totalCalories} ===`);
        } else {
          console.warn('=== 今日热量数据为空，使用默认值 ===');
          this.activeCalories = 0;
          this.caloriesGoal = 0;
          this.restingCalories = 0;
          this.totalCalories = 0;
        }

        // 生成周热量记录（使用所有7天数据）
        this.generateWeeklyCalorieRecords(calorieResponse.data);
      } else {
        console.warn('=== 热量数据为空 ===');
      }
    } catch (error) {
      console.error(`=== 数据加载异常: ${error} ===`);
      throw new Error(`网络请求失败: ${error}`);
    }
  }

  private generateWeeklyCalorieRecords(calorieData: HealthDataRequest[]): void {
    console.info(`=== 开始生成周热量记录，输入数据: ${calorieData.length}条 ===`);

    let records: CalorieRecord[] = [];
    let today: Date = new Date();

    for (let i: number = 1; i <= 6; i++) {
      let targetDate: Date = new Date();
      targetDate.setDate(today.getDate() - i);
      let targetDateString: string = targetDate.toISOString().split('T')[0];
      let dayName: string = this.weekDays[targetDate.getDay()];

      let calorieItem: HealthDataRequest | undefined = calorieData.find((item: HealthDataRequest) => {
        let itemDate: string = (item.record_date || '').replace(/'/g, '');
        return itemDate === targetDateString;
      });

      let calories: number = calorieItem ? (calorieItem.active_calories || 0) : 0;
      let record: CalorieRecord = new CalorieRecord(dayName, calories, dayName);
      records.push(record);

      console.info(`=== ${targetDateString}(${dayName}): 热量=${calories} ===`);
    }

    this.calorieRecords = records;
    console.info(`=== 热量记录生成完成，总计${records.length}条 ===`);
  }

  private refreshCalorieData(): void {
    console.info('=== 用户触发数据刷新 ===');
    this.isLoading = true;
    this.errorMessage = '';
    this.initializeCalorieSystem();
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
            router.back();
          } catch (err) {
            console.error('Failed to go back:', err);
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ left: 10 })

        Text('活动热量')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.Black)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          Text('🔄').fontSize(18)
        }
        .onClick(() => {
          this.refreshCalorieData();
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ right: 10 })
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#FBBC05')
          Text('正在加载热量数据...')
            .fontSize(18).fontColor('#333333')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        Column({ space: 20 }) {
          Text('🔥').fontSize(64)
          Text('加载失败')
            .fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button('重新加载')
            .onClick(() => this.refreshCalorieData())
            .backgroundColor('#FBBC05').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        Scroll() {
          Column({ space: 20 }) {
            // 热量概览卡片
            Column() {
              Text(`今日热量消耗 (${this.weekDays[new Date().getDay()]})`)
                .fontSize(18).fontWeight(FontWeight.Medium).margin({ bottom: 20 }).fontColor('#333333')

              // 热量进度圆环
              Stack() {
                Progress({
                  value: 100,
                  total: 100,
                  type: ProgressType.Ring
                })
                  .width(160).height(160).color('#F0F0F0').style({ strokeWidth: 12 })

                Progress({
                  value: this.caloriesGoal > 0 ? this.totalCalories : 0,
                  total: this.caloriesGoal > 0 ? this.caloriesGoal : 1,
                  type: ProgressType.Ring
                })
                  .width(160).height(160).color('#FBBC05').style({ strokeWidth: 12 })

                Column() {
                  Text(this.totalCalories.toString())
                    .fontSize(36).fontWeight(FontWeight.Bold).fontColor('#FBBC05')
                  Text('千卡')
                    .fontSize(16).fontColor('#666666').margin({ top: 4 })
                  Text(`${this.caloriesGoal > 0 ? Math.round((this.totalCalories / this.caloriesGoal) * 100) : 0}%`)
                    .fontSize(14).fontColor('#999999').margin({ top: 8 })
                }
              }
              .margin({ bottom: 30 })

              // 热量统计信息卡片
              Row({ space: 20 }) {
                this.buildCalorieStatCard('目标', `${this.caloriesGoal} 千卡`, '#FBBC05', '🎯')
                this.buildCalorieStatCard('活动消耗', `${this.activeCalories} 千卡`, '#EA4335', '🔥')
                this.buildCalorieStatCard('基础代谢', `${this.restingCalories} 千卡`, '#34A853', '💪')
              }
              .width('100%').justifyContent(FlexAlign.SpaceAround)
            }
            .width('90%').padding(30).backgroundColor('#FFFFFF').borderRadius(20)
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetX: 0, offsetY: 4 })

            // 每日热量记录
            Column() {
              Text('每日热量记录')
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              if (this.calorieRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('🔥').fontSize(48)
                  Text('暂无热量数据')
                    .fontSize(18).fontColor('#666666')
                  Button('刷新数据')
                    .onClick(() => this.refreshCalorieData())
                    .backgroundColor('#FBBC05').fontColor(Color.White).borderRadius(20).height(40)
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                Column({ space: 8 }) {
                  ForEach(this.calorieRecords, (record: CalorieRecord, index: number) => {
                    Row() {
                      Text(record.time).fontSize(16).fontColor('#333333').width('30%')
                      Text(`${record.value} 千卡`).fontSize(16).fontColor('#FBBC05')
                        .fontWeight(FontWeight.Medium).width('70%').textAlign(TextAlign.End)
                    }
                    .width('100%').padding({ top: 12, bottom: 12, left: 16, right: 16 })
                    .backgroundColor(index % 2 === 0 ? '#F8F9FA' : '#FFFFFF').borderRadius(8)
                  })
                }
              }
            }
            .width('90%').backgroundColor('#FFFFFF').borderRadius(15).padding(20)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.06)', offsetX: 0, offsetY: 3 })

            // 热量建议
            Column() {
              Row() {
                Text('热量健康建议')
                  .fontSize(18).fontWeight(FontWeight.Medium).fontColor('#333333')
                Blank()
                Text('💡').fontSize(20)
              }
              .width('100%').margin({ bottom: 15 })

              Column({ space: 12 }) {
                this.buildCalorieAdviceItem('保持热量摄入与消耗平衡', '⚖️')
                this.buildCalorieAdviceItem('增加日常活动量', '🚶‍♂️')
                this.buildCalorieAdviceItem('进行高强度间歇训练', '🏃‍♂️')
                this.buildCalorieAdviceItem('增强肌肉提升基础代谢', '💪')
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
  buildCalorieStatCard(label: string, value: string, color: string, icon: string) {
    Column() {
      Text(icon).fontSize(18).margin({ bottom: 4 })
      Text(label).fontSize(12).fontColor('#999999').margin({ bottom: 6 })
      Text(value).fontSize(12).fontWeight(FontWeight.Bold).fontColor(color)
        .textAlign(TextAlign.Center).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(16)
    }
    .width(90).height(90).padding(6).backgroundColor('#F8F9FA').borderRadius(12)
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .border({ width: 1, color: color, style: BorderStyle.Solid })
  }

  @Builder
  buildCalorieAdviceItem(advice: string, icon: string) {
    Row() {
      Text(icon).fontSize(20).margin({ right: 12 })
      Text(advice).fontSize(14).fontColor('#333333').textAlign(TextAlign.Start)
        .layoutWeight(1).maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%').padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .backgroundColor('#F8F9FA').borderRadius(8).alignItems(VerticalAlign.Top)
  }
}