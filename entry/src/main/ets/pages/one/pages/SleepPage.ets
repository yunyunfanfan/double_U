import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
//睡眠
class SleepPhase {
  type: string;
  duration: string;
  startTime: string;
  endTime: string;
  color: string;

  constructor(type: string, duration: string, startTime: string, endTime: string, color: string) {
    this.type = type;
    this.duration = duration;
    this.startTime = startTime;
    this.endTime = endTime;
    this.color = color;
  }
}

class SleepRecord {
  date: string;
  duration: string;
  quality: string;
  score: number;

  constructor(date: string, duration: string, quality: string, score: number) {
    this.date = date;
    this.duration = duration;
    this.quality = quality;
    this.score = score;
  }
}

@Entry
@Component
export struct SleepPage {
  @State totalSleepTime: string = '';
  @State sleepScore: number = 85;
  @State bedTime: string = '23:30';
  @State wakeTime: string = '07:00';
  @State sleepPhases: SleepPhase[] = [];
  @State sleepRecords: SleepRecord[] = [];
  @State selectedTimeRange: string = '';
  private timeRanges: string[] = [];

  aboutToAppear() {
    this.totalSleepTime = getContext(this).resourceManager.getStringSync($r('app.string.duration_7h30m_75839462'));
    this.selectedTimeRange = getContext(this).resourceManager.getStringSync($r('app.string.week_range_39284751'));

    this.timeRanges = [
      getContext(this).resourceManager.getStringSync($r('app.string.today_range_57382946')),
      getContext(this).resourceManager.getStringSync($r('app.string.week_range_39284751')),
      getContext(this).resourceManager.getStringSync($r('app.string.month_range_75839462')),
      getContext(this).resourceManager.getStringSync($r('app.string.year_range_18475936'))
    ];

    this.sleepPhases = [
      new SleepPhase(
        getContext(this).resourceManager.getStringSync($r('app.string.deep_sleep_84739261')),
        getContext(this).resourceManager.getStringSync($r('app.string.phase_duration_1h45m_18475936')),
        '00:15', '02:00', '#4285F4'
      ),
      new SleepPhase(
        getContext(this).resourceManager.getStringSync($r('app.string.light_sleep_57382946')),
        getContext(this).resourceManager.getStringSync($r('app.string.phase_duration_3h15m_62938475')),
        '23:30', '00:15', '#34A853'
      ),
      new SleepPhase(
        getContext(this).resourceManager.getStringSync($r('app.string.rem_sleep_39284751')),
        getContext(this).resourceManager.getStringSync($r('app.string.phase_duration_1h30m_84739261')),
        '04:30', '06:00', '#FBBC05'
      ),
      new SleepPhase(
        getContext(this).resourceManager.getStringSync($r('app.string.awake_state_75839462')),
        getContext(this).resourceManager.getStringSync($r('app.string.phase_duration_1h_57382946')),
        '02:00', '03:00', '#EA4335'
      )
    ];

    this.sleepRecords = [
      new SleepRecord(
        getContext(this).resourceManager.getStringSync($r('app.string.monday_62938475')),
        getContext(this).resourceManager.getStringSync($r('app.string.duration_7h30m_75839462')),
        getContext(this).resourceManager.getStringSync($r('app.string.quality_good_57382946')), 85
      ),
      new SleepRecord(
        getContext(this).resourceManager.getStringSync($r('app.string.tuesday_84739261')),
        getContext(this).resourceManager.getStringSync($r('app.string.duration_6h45m_18475936')),
        getContext(this).resourceManager.getStringSync($r('app.string.quality_fair_39284751')), 70
      ),
      new SleepRecord(
        getContext(this).resourceManager.getStringSync($r('app.string.wednesday_57382946')),
        getContext(this).resourceManager.getStringSync($r('app.string.duration_8h15m_62938475')),
        getContext(this).resourceManager.getStringSync($r('app.string.quality_excellent_84739261')), 92
      ),
      new SleepRecord(
        getContext(this).resourceManager.getStringSync($r('app.string.thursday_39284751')),
        getContext(this).resourceManager.getStringSync($r('app.string.duration_7h_84739261')),
        getContext(this).resourceManager.getStringSync($r('app.string.quality_good_57382946')), 80
      ),
      new SleepRecord(
        getContext(this).resourceManager.getStringSync($r('app.string.friday_75839462')),
        getContext(this).resourceManager.getStringSync($r('app.string.duration_6h30m_57382946')),
        getContext(this).resourceManager.getStringSync($r('app.string.quality_fair_39284751')), 65
      ),
      new SleepRecord(
        getContext(this).resourceManager.getStringSync($r('app.string.saturday_18475936')),
        getContext(this).resourceManager.getStringSync($r('app.string.duration_9h_39284751')),
        getContext(this).resourceManager.getStringSync($r('app.string.quality_excellent_84739261')), 95
      ),
      new SleepRecord(
        getContext(this).resourceManager.getStringSync($r('app.string.sunday_62938475')),
        getContext(this).resourceManager.getStringSync($r('app.string.duration_8h30m_75839462')),
        getContext(this).resourceManager.getStringSync($r('app.string.quality_excellent_84739261')), 90
      )
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
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .margin({ left: 10 })

        Text(getContext(this).resourceManager.getStringSync($r('app.string.sleep_title_84729361')))
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
          // 睡眠概览卡片
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.today_sleep_overview_57284916')))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 20 })
              .fontColor('#333333')

            // 睡眠评分圆环
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

              // 评分圆环
              Progress({
                value: this.sleepScore,
                total: 100,
                type: ProgressType.Ring
              })
                .width(160)
                .height(160)
                .color(this.sleepScore >= 80 ? '#34A853' : this.sleepScore >= 60 ? '#FBBC05' : '#EA4335')
                .style({ strokeWidth: 12 })

              // 中心内容
              Column() {
                Text(this.sleepScore.toString())
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.sleepScore >= 80 ? '#34A853' : this.sleepScore >= 60 ? '#FBBC05' : '#EA4335')

                Text(getContext(this).resourceManager.getStringSync($r('app.string.score_unit_39475829')))
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ top: 4 })

                Text(this.getScoreLevel(this.sleepScore))
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 8 })
              }
            }
            .margin({ bottom: 30 })

            // 睡眠统计信息卡片
            Row({ space: 20 }) {
              this.buildSleepStatCard(
                getContext(this).resourceManager.getStringSync($r('app.string.duration_label_75163948')),
                this.totalSleepTime, '#34A853', '🛌'
              )
              this.buildSleepStatCard(
                getContext(this).resourceManager.getStringSync($r('app.string.bedtime_label_18394756')),
                this.bedTime, '#4285F4', '🌙'
              )
              this.buildSleepStatCard(
                getContext(this).resourceManager.getStringSync($r('app.string.waketime_label_62847593')),
                this.wakeTime, '#FBBC05', '☀️'
              )
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

          // 时间范围选择器
          Row() {
            ForEach(this.timeRanges, (range: string) => {
              Text(range)
                .fontSize(14)
                .fontColor(this.selectedTimeRange === range ? '#34A853' : '#666666')
                .fontWeight(this.selectedTimeRange === range ? FontWeight.Bold : FontWeight.Normal)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .backgroundColor(this.selectedTimeRange === range ? '#E6F4EA' : '#F5F5F5')
                .borderRadius(20)
                .border({
                  width: this.selectedTimeRange === range ? 2 : 1,
                  color: this.selectedTimeRange === range ? '#34A853' : '#E0E0E0',
                  style: BorderStyle.Solid
                })
                .onClick(() => {
                  this.selectedTimeRange = range;
                })
            })
          }
          .width('90%')
          .justifyContent(FlexAlign.SpaceAround)

          // 睡眠阶段卡片
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.sleep_phases_title_62938475')))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ bottom: 15 })

            Column({ space: 12 }) {
              ForEach(this.sleepPhases, (phase: SleepPhase, index: number) => {
                Row() {
                  Row() {
                    Circle({ width: 12, height: 12 })
                      .fill(phase.color)
                      .margin({ right: 8 })

                    Text(phase.type)
                      .fontSize(15)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('30%')
                  .alignItems(VerticalAlign.Center)

                  Text(phase.duration)
                    .fontSize(14)
                    .fontColor('#666666')
                    .width('35%')
                    .textAlign(TextAlign.Center)

                  Text(`${phase.startTime} - ${phase.endTime}`)
                    .fontSize(13)
                    .fontColor('#999999')
                    .width('35%')
                    .textAlign(TextAlign.End)
                }
                .width('100%')
                .height(50)
                .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                .backgroundColor(index % 2 === 0 ? '#F8F9FA' : '#FFFFFF')
                .borderRadius(8)
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

          // 睡眠历史记录
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.sleep_records_title_18475936')))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ bottom: 15 })

            Column({ space: 12 }) {
              ForEach(this.sleepRecords, (record: SleepRecord, index: number) => {
                Row() {
                  Text(record.date)
                    .fontSize(15)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)
                    .width('18%')

                  Text(record.duration)
                    .fontSize(14)
                    .fontColor('#34A853')
                    .fontWeight(FontWeight.Medium)
                    .width('32%')
                    .textAlign(TextAlign.Center)

                  Text(record.quality)
                    .fontSize(14)
                    .fontColor(record.score >= 80 ? '#34A853' : record.score >= 60 ? '#FBBC05' : '#EA4335')
                    .fontWeight(FontWeight.Medium)
                    .width('25%')
                    .textAlign(TextAlign.Center)

                  Text(`${record.score}${getContext(this).resourceManager.getStringSync($r('app.string.score_unit_39475829'))}`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .width('25%')
                    .textAlign(TextAlign.End)
                }
                .width('100%')
                .height(50)
                .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                .backgroundColor(index % 2 === 0 ? '#F8F9FA' : '#FFFFFF')
                .borderRadius(8)
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

          // 睡眠建议
          Column() {
            Row() {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.sleep_tips_title_18475936')))
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Blank()

              Text('💤')
                .fontSize(20)
            }
            .width('100%')
            .margin({ bottom: 15 })

            Column({ space: 12 }) {
              this.buildSleepAdviceItem(
                getContext(this).resourceManager.getStringSync($r('app.string.tip_regular_schedule_62938475')), '⏰'
              )
              this.buildSleepAdviceItem(
                getContext(this).resourceManager.getStringSync($r('app.string.tip_avoid_screens_84739261')), '📱'
              )
              this.buildSleepAdviceItem(
                getContext(this).resourceManager.getStringSync($r('app.string.tip_sleep_environment_57382946')), '🌙'
              )
              this.buildSleepAdviceItem(
                getContext(this).resourceManager.getStringSync($r('app.string.tip_avoid_caffeine_39284751')), '☕'
              )
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
  buildSleepStatCard(label: string, value: string, color: string, icon: string) {
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
  buildSleepAdviceItem(advice: string, icon: string) {
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

  getScoreLevel(score: number): string {
    if (score >= 90) return getContext(this).resourceManager.getStringSync($r('app.string.quality_excellent_84739261'))
    if (score >= 80) return getContext(this).resourceManager.getStringSync($r('app.string.quality_good_57382946'))
    if (score >= 60) return getContext(this).resourceManager.getStringSync($r('app.string.quality_fair_39284751'))
    return getContext(this).resourceManager.getStringSync($r('app.string.quality_poor_75839462'))
  }
}