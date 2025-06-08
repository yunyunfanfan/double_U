import { BaseNavigation, KColors } from 'JhCommon'
import { hilog } from '@kit.PerformanceAnalysisKit'

interface HealthMetricItem {
  id: string
  labelResource: Resource
  value: string
  unitResource?: Resource
  trend?: 'up' | 'down' | 'stable'
  statusResource?: Resource
  lastUpdatedResource?: Resource
}

@Entry
@Component
export struct MoreHealthDataPage {
  @State vitalSigns: HealthMetricItem[] = [
    {
      id: 'vs1',
      labelResource: $r('app.string.resting_heart_rate'),
      value: '68',
      unitResource: $r('app.string.unit_bpm'),
      trend: 'stable',
      statusResource: $r('app.string.status_good'),
      lastUpdatedResource: $r('app.string.time_today_morning')
    } as HealthMetricItem,
    {
      id: 'vs2',
      labelResource: $r('app.string.average_heart_rate'),
      value: '75',
      unitResource: $r('app.string.unit_bpm'),
      trend: 'stable',
      statusResource: $r('app.string.status_normal'),
      lastUpdatedResource: $r('app.string.time_last_24h')
    } as HealthMetricItem,
    {
      id: 'vs3',
      labelResource: $r('app.string.blood_pressure'),
      value: '118/75',
      unitResource: $r('app.string.unit_mmhg'),
      trend: 'stable',
      statusResource: $r('app.string.status_ideal'),
      lastUpdatedResource: $r('app.string.time_yesterday_afternoon')
    } as HealthMetricItem,
    {
      id: 'vs4',
      labelResource: $r('app.string.blood_oxygen'),
      value: '98',
      unitResource: $r('app.string.unit_percent'),
      trend: 'stable',
      statusResource: $r('app.string.status_normal'),
      lastUpdatedResource: $r('app.string.time_today_9am')
    } as HealthMetricItem,
    {
      id: 'vs5',
      labelResource: $r('app.string.body_temperature'),
      value: '36.7',
      unitResource: $r('app.string.unit_celsius'),
      trend: 'stable',
      statusResource: $r('app.string.status_normal'),
      lastUpdatedResource: $r('app.string.time_today_7am')
    } as HealthMetricItem
  ]

  @State bodyMetrics: HealthMetricItem[] = [
    {
      id: 'bm1',
      labelResource: $r('app.string.weight'),
      value: '70.2',
      unitResource: $r('app.string.unit_kg'),
      trend: 'down',
      statusResource: $r('app.string.status_standard'),
      lastUpdatedResource: $r('app.string.time_today_730am')
    } as HealthMetricItem,
    {
      id: 'bm2',
      labelResource: $r('app.string.bmi'),
      value: '22.8',
      trend: 'stable',
      statusResource: $r('app.string.status_normal'),
      lastUpdatedResource: $r('app.string.time_today_730am')
    } as HealthMetricItem,
    {
      id: 'bm3',
      labelResource: $r('app.string.body_fat_rate'),
      value: '18.5',
      unitResource: $r('app.string.unit_percent'),
      trend: 'stable',
      statusResource: $r('app.string.status_healthy'),
      lastUpdatedResource: $r('app.string.time_3_days_ago')
    } as HealthMetricItem,
    {
      id: 'bm4',
      labelResource: $r('app.string.skeletal_muscle_mass'),
      value: '35.1',
      unitResource: $r('app.string.unit_kg'),
      trend: 'up',
      statusResource: $r('app.string.status_good'),
      lastUpdatedResource: $r('app.string.time_3_days_ago')
    } as HealthMetricItem
  ]

  @State sleepData: HealthMetricItem[] = [
    {
      id: 'sd1',
      labelResource: $r('app.string.total_sleep_duration'),
      value: '7',
      unitResource: $r('app.string.unit_hours_minutes'),
      statusResource: $r('app.string.status_sufficient'),
      lastUpdatedResource: $r('app.string.time_last_night')
    } as HealthMetricItem,
    {
      id: 'sd2',
      labelResource: $r('app.string.deep_sleep_duration'),
      value: '1',
      unitResource: $r('app.string.unit_hours_minutes'),
      statusResource: $r('app.string.status_good'),
      lastUpdatedResource: $r('app.string.time_last_night')
    } as HealthMetricItem,
    {
      id: 'sd3',
      labelResource: $r('app.string.light_sleep_duration'),
      value: '5',
      unitResource: $r('app.string.unit_hours_minutes'),
      statusResource: $r('app.string.status_normal'),
      lastUpdatedResource: $r('app.string.time_last_night')
    } as HealthMetricItem,
    {
      id: 'sd4',
      labelResource: $r('app.string.rem_sleep'),
      value: '1',
      unitResource: $r('app.string.unit_hours_minutes'),
      statusResource: $r('app.string.status_normal'),
      lastUpdatedResource: $r('app.string.time_last_night')
    } as HealthMetricItem,
    {
      id: 'sd5',
      labelResource: $r('app.string.bedtime'),
      value: '23:15',
      statusResource: $r('app.string.status_regular'),
      lastUpdatedResource: $r('app.string.time_last_night')
    } as HealthMetricItem,
    {
      id: 'sd6',
      labelResource: $r('app.string.wake_time'),
      value: '07:05',
      statusResource: $r('app.string.status_regular'),
      lastUpdatedResource: $r('app.string.time_this_morning')
    } as HealthMetricItem
  ]

  aboutToAppear(): void {
    hilog.info(0x0000, 'MoreHealthDataPage', '更多健康数据页面初始化开始')
    hilog.info(0x0000, 'MoreHealthDataPage', `生命体征数据项数量: ${this.vitalSigns.length}`)
    hilog.info(0x0000, 'MoreHealthDataPage', `身体指标数据项数量: ${this.bodyMetrics.length}`)
    hilog.info(0x0000, 'MoreHealthDataPage', `睡眠数据项数量: ${this.sleepData.length}`)
    hilog.info(0x0000, 'MoreHealthDataPage', '页面初始化完成')
  }

  build() {
    Column() {
      BaseNavigation({
        title: $r('app.string.more_health_data_title'),
        bgColor: Color.White
      })

      Scroll() {
        Column() {
          this.healthSection($r('app.string.vital_signs'), this.vitalSigns)
          this.healthSection($r('app.string.body_metrics'), this.bodyMetrics)
          this.healthSection($r('app.string.sleep_analysis'), this.sleepData)
        }
        .width('100%')
        .padding({ top: 10, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(KColors.wxBgColor)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  healthSection(titleResource: Resource, items: HealthMetricItem[]) {
    Column() {
      Row() {
        Divider()
          .vertical(true)
          .height(16)
          .width(3)
          .backgroundColor('#1698CE')
          .margin({ right: 8 })
        Text(titleResource)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ left: 15, top: 20, bottom: 10 })
      .alignItems(VerticalAlign.Center)

      ForEach(items, (item: HealthMetricItem) => {
        this.metricCard(item)
      }, (item: HealthMetricItem) => item.id)
    }
    .width('100%')
  }

  @Builder
  metricCard(item: HealthMetricItem) {
    Column() {
      Row() {
        Text(item.labelResource)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Blank()
        if (item.lastUpdatedResource) {
          Text(item.lastUpdatedResource)
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .padding({ bottom: 8 })

      Row() {
        Text(item.value)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1698CE')
        if (item.unitResource) {
          Text(item.unitResource)
            .fontSize(14)
            .fontColor('#1698CE')
            .margin({ left: 4, top: 8 })
        }
        Blank()
        if (item.statusResource) {
          Text(item.statusResource)
            .fontSize(14)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .fontColor('#1698CE')
            .backgroundColor('#E6F7FF')
            .borderRadius(8)
        }
      }
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ left: 15, right: 15, top: 5, bottom: 5 })
    .width('calc(100% - 30vp)')
    .onClick(() => {
      hilog.info(0x0000, 'MoreHealthDataPage', `点击健康指标卡片: ${item.id}`)
    })
  }
}