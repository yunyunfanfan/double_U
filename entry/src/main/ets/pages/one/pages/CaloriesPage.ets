import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';

//活动热量

class CalorieRecord {
  time: string;
  value: number;
  activity: string;

  constructor(time: string, value: number, activity: string) {
    this.time = time;
    this.value = value;
    this.activity = activity;
  }
}

@Entry
@Component
export struct CaloriesPage {
  @State totalCalories: number = 2345;
  @State caloriesGoal: number = 3000;
  @State activeCalories: number = 1245;
  @State restingCalories: number = 1100;
  @State calorieRecords: CalorieRecord[] = [];
  @State selectedTimeRange: string = '';

  private getTimeRanges(): string[] {
    return [
      getContext(this).resourceManager.getStringSync($r('app.string.today_timerange_84739261')),
      getContext(this).resourceManager.getStringSync($r('app.string.this_week_timerange_57382946')),
      getContext(this).resourceManager.getStringSync($r('app.string.this_month_timerange_39284751')),
      getContext(this).resourceManager.getStringSync($r('app.string.this_year_timerange_75839462'))
    ];
  }

  aboutToAppear(): void {
    this.selectedTimeRange = getContext(this).resourceManager.getStringSync($r('app.string.today_timerange_84739261'));
    this.calorieRecords = [
      new CalorieRecord('08:00 - 10:00', 320, getContext(this).resourceManager.getStringSync($r('app.string.running_activity_84739261'))),
      new CalorieRecord('11:30 - 12:30', 180, getContext(this).resourceManager.getStringSync($r('app.string.walking_activity_57382946'))),
      new CalorieRecord('14:00 - 15:00', 250, getContext(this).resourceManager.getStringSync($r('app.string.cycling_activity_39284751'))),
      new CalorieRecord('16:30 - 17:30', 210, getContext(this).resourceManager.getStringSync($r('app.string.fitness_activity_75839462'))),
      new CalorieRecord('19:00 - 20:00', 285, getContext(this).resourceManager.getStringSync($r('app.string.swimming_activity_18475936')))
    ];
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back'))
            .width(20)
            .height(20)
        }
        .onClick(() => {
          try {
            router.back();
          } catch (err) {
            console.error('Failed to go back:', err);
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .margin({ left: 10 })

        Text(getContext(this).resourceManager.getStringSync($r('app.string.active_calories_title_84739261')))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 右侧占位元素，保持布局平衡
        Row()
          .width(40)
          .height(40)
          .margin({ right: 10 })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 可滚动的内容区域
      Scroll() {
        Column({ space: 20 }) {
          // 热量概览卡片
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.today_calories_text_57382946')))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 20 })
              .fontColor('#333333')

            // 热量进度圆环
            Stack() {
              // 背景圆环
              Progress({
                value: 100,
                total: 100,
                type: ProgressType.Ring
              })
                .width(160)
                .height(160)
                .color('#F0F0F0')
                .style({ strokeWidth: 12 })

              // 热量进度圆环
              Progress({
                value: this.totalCalories,
                total: this.caloriesGoal,
                type: ProgressType.Ring
              })
                .width(160)
                .height(160)
                .color('#FBBC05')
                .style({ strokeWidth: 12 })

              // 中心内容
              Column() {
                Text(this.totalCalories.toString())
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FBBC05')

                Text(getContext(this).resourceManager.getStringSync($r('app.string.kcal_unit_text_39284751')))
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ top: 4 })

                Text(`${Math.round((this.totalCalories / this.caloriesGoal) * 100)}%`)
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 8 })
              }
            }
            .margin({ bottom: 30 })

            // 热量统计信息卡片
            Row({ space: 20 }) {
              this.buildCalorieStatCard(getContext(this).resourceManager.getStringSync($r('app.string.goal_label_text_75839462')), `${this.caloriesGoal} ${getContext(this).resourceManager.getStringSync($r('app.string.kcal_unit_text_39284751'))}`, '#FBBC05', '🎯')
              this.buildCalorieStatCard(getContext(this).resourceManager.getStringSync($r('app.string.active_consumption_label_18475936')), `${this.activeCalories} ${getContext(this).resourceManager.getStringSync($r('app.string.kcal_unit_text_39284751'))}`, '#EA4335', '🔥')
              this.buildCalorieStatCard(getContext(this).resourceManager.getStringSync($r('app.string.basal_metabolism_label_62938475')), `${this.restingCalories} ${getContext(this).resourceManager.getStringSync($r('app.string.kcal_unit_text_39284751'))}`, '#34A853', '💪')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
          }
          .width('90%')
          .padding(30)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .shadow({
            radius: 12,
            color: 'rgba(0,0,0,0.08)',
            offsetX: 0,
            offsetY: 4
          })

          // 热量消耗明细
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.calorie_details_title_18475936')))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ bottom: 15 })

            Column({ space: 12 }) {
              ForEach(this.calorieRecords, (record: CalorieRecord, index: number) => {
                Row() {
                  // 活动图标
                  Row() {
                    Text(this.getActivityIcon(record.activity))
                      .fontSize(20)
                  }
                  .width(44)
                  .height(44)
                  .borderRadius(22)
                  .backgroundColor('#FEF7E0')
                  .justifyContent(FlexAlign.Center)
                  .margin({ right: 16 })

                  Column() {
                    Text(record.activity)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .textAlign(TextAlign.Start)
                      .width('100%')

                    Text(record.time)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 })
                      .textAlign(TextAlign.Start)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Text(`${record.value} ${getContext(this).resourceManager.getStringSync($r('app.string.kcal_unit_text_39284751'))}`)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FBBC05')
                }
                .width('100%')
                .height(60)
                .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                .backgroundColor(index % 2 === 0 ? '#F8F9FA' : '#FFFFFF')
                .borderRadius(12)
                .alignItems(VerticalAlign.Center)
              })
            }
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(15)
          .padding(20)
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.06)',
            offsetX: 0,
            offsetY: 3
          })

          // 热量建议
          Column() {
            Row() {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.calorie_health_tips_title_62938475')))
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Blank()

              Text('💡')
                .fontSize(20)
            }
            .width('100%')
            .margin({ bottom: 15 })

            Column({ space: 12 }) {
              this.buildCalorieAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.calorie_balance_tip_62938475')), '⚖️')
              this.buildCalorieAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.daily_activity_tip_84739261')), '🚶‍♂️')
              this.buildCalorieAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.hiit_training_tip_57382946')), '🏃‍♂️')
              this.buildCalorieAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.muscle_metabolism_tip_39284751')), '💪')
            }
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(15)
          .padding(20)
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.06)',
            offsetX: 0,
            offsetY: 3
          })
        }
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildCalorieStatCard(label: string, value: string, color: string, icon: string) {
    Column() {
      Text(icon)
        .fontSize(18)
        .margin({ bottom: 4 })

      Text(label)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ bottom: 6 })

      Text(value)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(16)
    }
    .width(90)
    .height(90)
    .padding(6)
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .border({
      width: 1,
      color: color,
      style: BorderStyle.Solid
    })
  }

  @Builder
  buildCalorieAdviceItem(advice: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 12 })

      Text(advice)
        .fontSize(14)
        .fontColor('#333333')
        .textAlign(TextAlign.Start)
        .layoutWeight(1)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .alignItems(VerticalAlign.Top)
  }

  getActivityIcon(activity: string): string {
    const runningText: string = getContext(this).resourceManager.getStringSync($r('app.string.running_activity_84739261'));
    const walkingText: string = getContext(this).resourceManager.getStringSync($r('app.string.walking_activity_57382946'));
    const cyclingText: string = getContext(this).resourceManager.getStringSync($r('app.string.cycling_activity_39284751'));
    const fitnessText: string = getContext(this).resourceManager.getStringSync($r('app.string.fitness_activity_75839462'));
    const swimmingText: string = getContext(this).resourceManager.getStringSync($r('app.string.swimming_activity_18475936'));

    if (activity === runningText) return '🏃‍♂️';
    if (activity === walkingText) return '🚶‍♂️';
    if (activity === cyclingText) return '🚴‍♂️';
    if (activity === fitnessText) return '💪';
    if (activity === swimmingText) return '🏊‍♂️';
    return '🔥';
  }
} 