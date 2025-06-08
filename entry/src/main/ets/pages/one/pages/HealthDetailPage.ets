import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';

//这是啥页面

// 数据点类型
class DataPoint {
  time: string;
  value: string;
  
  constructor(time: string, value: string) {
    this.time = time;
    this.value = value;
  }
}

// 健康数据类型
export class HealthDetailData {
  title: string;
  currentValue: string;
  unit: string;
  description: string;
  normalRange: string;
  chartData: DataPoint[];
  tips: string[];
  color: string;
  
  constructor(title: string, currentValue: string, unit: string, description: string, 
              normalRange: string, chartData: DataPoint[], tips: string[], color: string) {
    this.title = title;
    this.currentValue = currentValue;
    this.unit = unit;
    this.description = description;
    this.normalRange = normalRange;
    this.chartData = chartData;
    this.tips = tips;
    this.color = color;
  }
}

@Entry
@Component
export struct HealthDetailPage {
  @State detailData: HealthDetailData = router.getParams() as HealthDetailData;
  @State selectedTimeRange: string = '今日';
  private timeRanges: string[] = ['今日', '本周', '本月', '全年'];

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
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
        
        Text(this.detailData.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .margin({ top: 20, bottom: 20 })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)

      // 当前数值展示
      Column() {
        Row() {
          Text(this.detailData.currentValue)
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.detailData.color)
          Text(this.detailData.unit)
            .fontSize(18)
            .fontColor('#666666')
            .margin({ left: 5, bottom: 8 })
            .alignSelf(ItemAlign.End)
        }
        .margin({ top: 20, bottom: 10 })
        
        Text(`正常范围: ${this.detailData.normalRange}`)
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 20 })
        
        Text(this.detailData.description)
          .fontSize(16)
          .fontColor('#333333')
          .margin({ bottom: 20 })
          .width('90%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#F5F5F5')
      .borderRadius(15)
      .margin({ top: 10, bottom: 20 })

      // 时间范围选择器
      Row() {
        ForEach(this.timeRanges, (range: string) => {
          Text(range)
            .fontSize(16)
            .fontColor(this.selectedTimeRange === range ? this.detailData.color : '#666666')
            .fontWeight(this.selectedTimeRange === range ? FontWeight.Bold : FontWeight.Normal)
            .padding(10)
            .backgroundColor(this.selectedTimeRange === range ? '#F0F0F0' : Color.Transparent)
            .borderRadius(20)
            .onClick(() => {
              this.selectedTimeRange = range;
            })
        })
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 20 })

      // 数据图表（模拟）
      Column() {
        Text('数据趋势')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 15 })
          .alignSelf(ItemAlign.Start)
        
        // 模拟图表
        Row() {
          ForEach(this.detailData.chartData, (item: DataPoint, index: number) => {
            Column() {
              Column() {
                // 模拟柱状图
              }
              .width(15)
              .height(100 * (parseInt(item.value) / 200))
              .backgroundColor(this.detailData.color)
              .borderRadius(8)
              
              Text(item.time)
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 5 })
            }
            .width('12%')
            .height(150)
            .justifyContent(FlexAlign.End)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .margin({ bottom: 20 })
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#F5F5F5')
      .borderRadius(15)
      .margin({ bottom: 20 })

      // 健康提示
      Column() {
        Text('健康提示')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 15 })
          .alignSelf(ItemAlign.Start)
        
        List() {
          ForEach(this.detailData.tips, (tip: string, index: number) => {
            ListItem() {
              Row() {
                Text(`${index + 1}.`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.detailData.color)
                  .width(25)
                
                Text(tip)
                  .fontSize(16)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 10 })
            }
          })
        }
        .width('100%')
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#F5F5F5')
      .borderRadius(15)
      .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .padding({ bottom: 20 })
  }
} 