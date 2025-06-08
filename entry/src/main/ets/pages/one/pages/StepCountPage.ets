import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';

///这是步数分析页面

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

class StoredHealthData {
  timestamp: string = '';
  type: string = '';
  value: string = '';
  unit: string = '';
  additionalInfo: HealthAdditionalInfo = new HealthAdditionalInfo();

  constructor() {}

  toString(): string {
    return `StoredHealthData{type: ${this.type}, value: ${this.value}, category: ${this.additionalInfo.category}}`;
  }
}

class HealthAdditionalInfo {
  category: string = '';
  dayOfWeek: string = '';
  goalValue: string = '';
  distance: string = '';

  constructor() {}
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

  private timeRanges: string[] = [];
  private preferencesHelper: preferences.Preferences | null = null;
  private weekDays: string[] = [];

  aboutToAppear(): void {
    this.selectedTimeRange = getContext(this).resourceManager.getStringSync($r('app.string.week_range_39284751'));
    this.distance = `0${getContext(this).resourceManager.getStringSync($r('app.string.km_unit_57382946'))}`;
    this.calories = `0${getContext(this).resourceManager.getStringSync($r('app.string.kcal_unit_39284751'))}`;

    this.timeRanges = [
      getContext(this).resourceManager.getStringSync($r('app.string.today_range_57382946')),
      getContext(this).resourceManager.getStringSync($r('app.string.week_range_39284751')),
      getContext(this).resourceManager.getStringSync($r('app.string.month_range_75839462')),
      getContext(this).resourceManager.getStringSync($r('app.string.year_range_18475936'))
    ];

    this.weekDays = [
      getContext(this).resourceManager.getStringSync($r('app.string.sunday_84739261')),
      getContext(this).resourceManager.getStringSync($r('app.string.monday_84739261')),
      getContext(this).resourceManager.getStringSync($r('app.string.tuesday_57382946')),
      getContext(this).resourceManager.getStringSync($r('app.string.wednesday_39284751')),
      getContext(this).resourceManager.getStringSync($r('app.string.thursday_75839462')),
      getContext(this).resourceManager.getStringSync($r('app.string.friday_18475936')),
      getContext(this).resourceManager.getStringSync($r('app.string.saturday_62938475'))
    ];

    this.initializeStepSystem();
  }

  private async initializeStepSystem(): Promise<void> {
    try {
      this.resetStepData();
      await this.initPreferences();
      await this.loadStepDataFromStorage();
      this.calculateWeeklyStats();
      this.isLoading = false;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      this.errorMessage = `${getContext(this).resourceManager.getStringSync($r('app.string.data_load_failed_prefix_75839462'))} ${errorMessage}`;
      this.isLoading = false;
      this.resetStepData();
    }
  }

  private resetStepData(): void {
    this.currentSteps = 0;
    this.dailyGoal = 0;
    this.weeklyAvg = 0;
    this.distance = `0${getContext(this).resourceManager.getStringSync($r('app.string.km_unit_57382946'))}`;
    this.calories = `0${getContext(this).resourceManager.getStringSync($r('app.string.kcal_unit_39284751'))}`;
    this.stepRecords = [];
    this.hasDataLoaded = false;
  }

  private async initPreferences(): Promise<void> {
    this.preferencesHelper = await preferences.getPreferences(getContext(), 'health_data');
  }

  private async loadStepDataFromStorage(): Promise<void> {
    if (!this.preferencesHelper) {
      return;
    }

    try {
      const storedData = await this.preferencesHelper.get('health_records', '[]') as string;

      if (storedData === '[]' || storedData.length === 0) {
        return;
      }

      const healthRecords: StoredHealthData[] = JSON.parse(storedData);

      const stepRecords = healthRecords.filter((record: StoredHealthData) =>
      record.type === 'steps' || record.type === 'distance' || record.type === 'calories'
      );

      if (stepRecords.length === 0) {
        return;
      }

      this.processStepRecords(stepRecords);
      this.hasDataLoaded = true;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
    }
  }

  private processStepRecords(storedRecords: StoredHealthData[]): void {
    const currentDate = new Date();
    const currentWeekDay = currentDate.getDay();
    const todayWeekName = this.weekDays[currentWeekDay];

    const weeklyStepData = new Map<string, number>();
    const weeklyDistanceData = new Map<string, number>();
    const weeklyCaloriesData = new Map<string, number>();
    let currentGoal = 0;

    storedRecords.forEach((record: StoredHealthData) => {
      const dayOfWeek = record.additionalInfo?.dayOfWeek || '';
      const category = record.additionalInfo?.category || '';

      if (record.type === 'steps') {
        const value = parseInt(record.value) || 0;

        const isTodaySteps = this.isTodayStepsCategory(category);
        const weekDayFromCategory = this.extractWeekDayFromCategory(category);

        if (isTodaySteps && dayOfWeek === todayWeekName) {
          this.currentSteps = value;
          weeklyStepData.set(todayWeekName, value);
        } else if (isTodaySteps && !dayOfWeek) {
          this.currentSteps = value;
          weeklyStepData.set(todayWeekName, value);
        } else if (weekDayFromCategory) {
          weeklyStepData.set(weekDayFromCategory, value);

          if (weekDayFromCategory === todayWeekName) {
            this.currentSteps = value;
          }
        } else if (dayOfWeek) {
          weeklyStepData.set(dayOfWeek, value);

          if (dayOfWeek === todayWeekName) {
            this.currentSteps = value;
          }
        }

        if (record.additionalInfo?.goalValue) {
          const goalValue = parseInt(record.additionalInfo.goalValue) || 0;
          if (goalValue > currentGoal) {
            currentGoal = goalValue;
          }
        }
      } else if (record.type === 'distance') {
        const value = parseFloat(record.value) || 0;
        if (dayOfWeek) {
          weeklyDistanceData.set(dayOfWeek, value);

          if (dayOfWeek === todayWeekName) {
            this.distance = `${value}${getContext(this).resourceManager.getStringSync($r('app.string.km_unit_57382946'))}`;
          }
        }
      } else if (record.type === 'calories') {
        const value = parseInt(record.value) || 0;
        if (dayOfWeek) {
          weeklyCaloriesData.set(dayOfWeek, value);

          if (dayOfWeek === todayWeekName) {
            this.calories = `${value}${getContext(this).resourceManager.getStringSync($r('app.string.kcal_unit_39284751'))}`;
          }
        }
      }
    });

    this.dailyGoal = currentGoal;
    this.generateWeeklyDisplayData(weeklyStepData, weeklyDistanceData, currentWeekDay);
  }

  private isTodayStepsCategory(category: string): boolean {
    const todayCategories = ['当日步数', '今日步数', '每日步数', '步数'];
    return todayCategories.includes(category);
  }

  private extractWeekDayFromCategory(category: string): string {
    const weekDayMap = new Map<string, string>([
      ['周一步数', getContext(this).resourceManager.getStringSync($r('app.string.monday_84739261'))],
      ['周二步数', getContext(this).resourceManager.getStringSync($r('app.string.tuesday_57382946'))],
      ['周三步数', getContext(this).resourceManager.getStringSync($r('app.string.wednesday_39284751'))],
      ['周四步数', getContext(this).resourceManager.getStringSync($r('app.string.thursday_75839462'))],
      ['周五步数', getContext(this).resourceManager.getStringSync($r('app.string.friday_18475936'))],
      ['周六步数', getContext(this).resourceManager.getStringSync($r('app.string.saturday_62938475'))],
      ['周日步数', getContext(this).resourceManager.getStringSync($r('app.string.sunday_84739261'))],
      ['上周六步数', getContext(this).resourceManager.getStringSync($r('app.string.saturday_62938475'))],
      ['上周日步数', getContext(this).resourceManager.getStringSync($r('app.string.sunday_84739261'))]
    ]);

    return weekDayMap.get(category) || '';
  }

  private generateWeeklyDisplayData(stepData: Map<string, number>, distanceData: Map<string, number>, currentWeekDay: number): void {
    const displayRecords: StepRecord[] = [];
    let totalSteps = 0;
    let validDays = 0;

    for (let i = 0; i < 7; i++) {
      const dayIndex = (currentWeekDay + 6 - i) % 7;
      const dayName = this.weekDays[dayIndex];
      const steps = stepData.get(dayName) || 0;
      const distance = distanceData.get(dayName) || 0;

      const isToday = dayIndex === currentWeekDay;
      const todaySuffix = getContext(this).resourceManager.getStringSync($r('app.string.today_suffix_57382946'));
      const displayName = isToday ? `${dayName}(${todaySuffix})` : dayName;
      const kmUnit = getContext(this).resourceManager.getStringSync($r('app.string.km_unit_57382946'));

      const stepRecord = new StepRecord(
        displayName,
        steps,
        distance > 0 ? `${distance}${kmUnit}` : `0${kmUnit}`,
        dayName
      );

      displayRecords.unshift(stepRecord);

      if (steps > 0) {
        totalSteps += steps;
        validDays++;
      }
    }

    this.stepRecords = displayRecords;
    this.weeklyAvg = validDays > 0 ? Math.round(totalSteps / validDays) : 0;
  }

  private calculateWeeklyStats(): void {
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

        Text(getContext(this).resourceManager.getStringSync($r('app.string.step_analysis_title_84729361')))
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
          Text(getContext(this).resourceManager.getStringSync($r('app.string.loading_steps_data_39284751')))
            .fontSize(18).fontColor('#333333')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else if (this.errorMessage) {
        Column({ space: 20 }) {
          Text('👟').fontSize(64)
          Text(getContext(this).resourceManager.getStringSync($r('app.string.load_failed_title_75839462')))
            .fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button(getContext(this).resourceManager.getStringSync($r('app.string.reload_button_18475936')))
            .onClick(() => this.refreshStepData())
            .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(12).height(44).width(140)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        Scroll() {
          Column({ space: 20 }) {
            // 今日步数显示
            Column() {
              Text(`${getContext(this).resourceManager.getStringSync($r('app.string.today_steps_label_57284916'))} (${this.weekDays[new Date().getDay()]})`)
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
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.steps_unit_39475829')))
                    .fontSize(16).fontColor('#666666').margin({ top: 4 })
                  Text(`${this.dailyGoal > 0 ? Math.round((this.currentSteps / this.dailyGoal) * 100) : 0}%`)
                    .fontSize(14).fontColor('#999999').margin({ top: 8 })
                }
              }
              .margin({ bottom: 30 })

              Row({ space: 20 }) {
                this.buildStatCard(
                  getContext(this).resourceManager.getStringSync($r('app.string.goal_label_75163948')),
                  `${this.dailyGoal} ${getContext(this).resourceManager.getStringSync($r('app.string.steps_unit_39475829'))}`,
                  '#4285F4', '🎯'
                )
                this.buildStatCard(
                  getContext(this).resourceManager.getStringSync($r('app.string.distance_label_18394756')),
                  this.distance, '#34A853', '📍'
                )
                this.buildStatCard(
                  getContext(this).resourceManager.getStringSync($r('app.string.calories_label_62847593')),
                  this.calories, '#EA4335', '🔥'
                )
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
              Text(getContext(this).resourceManager.getStringSync($r('app.string.step_records_title_62938475')))
                .fontSize(18).fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start).width('100%').margin({ bottom: 15 })

              if (this.stepRecords.length === 0) {
                Column({ space: 16 }) {
                  Text('👟').fontSize(48)
                  Text(getContext(this).resourceManager.getStringSync($r('app.string.no_step_data_62938475')))
                    .fontSize(18).fontColor('#666666')
                  Button(getContext(this).resourceManager.getStringSync($r('app.string.refresh_data_button_84739261')))
                    .onClick(() => this.refreshStepData())
                    .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(20).height(40)
                }
                .width('100%').height(200).justifyContent(FlexAlign.Center)
              } else {
                Column({ space: 8 }) {
                  ForEach(this.stepRecords, (record: StepRecord, index: number) => {
                    Row() {
                      Text(record.time).fontSize(16).fontColor('#333333').width('30%')
                      Text(`${record.value} ${getContext(this).resourceManager.getStringSync($r('app.string.steps_unit_39475829'))}`).fontSize(16).fontColor('#4285F4')
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