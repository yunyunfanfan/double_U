import { router } from '@kit.ArkUI';
import { BaseNavigation } from 'JhCommon';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 健康积分中的我的勋章页面

interface BadgeData {
  id: number;
  image: Resource;
  nameKey: string;
  descKey: string;
  obtainedDate: string;
  conditionKey: string;
}

@Entry
@Component
struct BadgesPage {
  @State selectedBadge: BadgeData | null = null;
  @State showDetail: boolean = false;

  private badges: BadgeData[] = [
    {
      id: 1,
      image: $r('app.media.badge1'),
      nameKey: 'badge_annual_star',
      descKey: 'badge_annual_desc',
      obtainedDate: '2025.05.29',
      conditionKey: 'badge_annual_condition'
    },
    {
      id: 2,
      image: $r('app.media.badge2'),
      nameKey: 'badge_light_chaser',
      descKey: 'badge_light_desc',
      obtainedDate: '2025.05.20',
      conditionKey: 'badge_light_condition'
    },
    {
      id: 3,
      image: $r('app.media.badge3'),
      nameKey: 'badge_friend_max',
      descKey: 'badge_friend_desc',
      obtainedDate: '2025.3.26',
      conditionKey: 'badge_friend_condition'
    },
    {
      id: 4,
      image: $r('app.media.badge5'),
      nameKey: 'badge_monthly_champion',
      descKey: 'badge_monthly_desc',
      obtainedDate: '2025.3.01',
      conditionKey: 'badge_monthly_condition'
    },
    {
      id: 5,
      image: $r('app.media.VIP'),
      nameKey: 'badge_vip',
      descKey: 'badge_vip_desc',
      obtainedDate: '2025.04.12',
      conditionKey: 'badge_vip_condition'
    },
    {
      id: 6,
      image: $r('app.media.varolant'),
      nameKey: 'badge_valorant',
      descKey: 'badge_valorant_desc',
      obtainedDate: '2024.12.01',
      conditionKey: 'badge_valorant_condition'
    }
  ];

  aboutToAppear(): void {
    hilog.info(0x0000, 'BadgesPage', '勋章页面初始化开始');
    hilog.info(0x0000, 'BadgesPage', `勋章总数: ${this.badges.length}`);
  }

  build() {
    Stack() {
      Column() {
        // 1. 顶部导航栏（最小高度）
        BaseNavigation({
          title: $r('app.string.badge_title'),
          bgColor: Color.Transparent
        })
          .height(40)
          .margin({ bottom: 20 });

        // 2. 勋章数量与勋章网格合并区域
        Column() {
          // 勋章数量显示
          Row() {
            Text($r('app.string.badge_count'))
              .fontSize(23)
              .fontColor('#666666')
              .margin({ bottom: 20, right: 4 });

            Text(this.badges.length.toString())
              .fontSize(24)
              .fontColor('#000000')
              .fontWeight(FontWeight.Bold)
              .margin({bottom: 20});
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 10 })

          // 3. 勋章网格（直接贴着上方文字）
          Grid() {
            ForEach(this.badges, (badge: BadgeData) => {
              GridItem() {
                Column() {
                  Image(badge.image)
                    .width(90)
                    .height(90)
                    .objectFit(ImageFit.Contain)
                    .onClick(() => {
                      hilog.info(0x0000, 'BadgesPage', `点击勋章: ID=${badge.id}, nameKey=${badge.nameKey}`);
                      this.selectedBadge = badge;
                      this.showDetail = true;
                    });

                  Text($r(`app.string.${badge.nameKey}`))
                    .fontSize(16)
                    .fontColor('#333333')
                    .margin({ top: 4 });

                  Text($r(`app.string.${badge.descKey}`))
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 2 });
                }
                .width('100%')
                .height(150)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .padding(8)
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .width('100%')
          .padding({ left: 16, right: 16 })
          .margin({ top: -4 }) // 关键：负margin上移网格
        }
        .width('100%')
        .margin({ top: -2 }) // 二次上移确保完全贴合
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 将勋章详情弹窗部分也包裹在Stack中
      if (this.showDetail && this.selectedBadge) {
        Column() {
          // 半透明遮罩
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.5)
            .onClick(() => {
              hilog.info(0x0000, 'BadgesPage', '点击遮罩关闭弹窗');
              this.showDetail = false;
            });

          // 弹窗内容
          Column() {
            Image(this.selectedBadge.image)
              .width(120)
              .height(120)
              .objectFit(ImageFit.Contain)
              .margin({ top: 20, bottom: 12 });

            Text($r(`app.string.${this.selectedBadge.nameKey}`))
              .fontSize(20)
              .fontColor('#000000')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 6 });

            Row() {
              Text(this.selectedBadge.obtainedDate)
                .fontSize(14)
                .fontColor('#999999');

              Text($r('app.string.obtained_on'))
                .fontSize(14)
                .fontColor('#999999');
            }
            .margin({ bottom: 12 });

            Text($r(`app.string.${this.selectedBadge.conditionKey}`))
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 20 });

            Button($r('app.string.share_badge'), { type: ButtonType.Normal })
              .width('80%')
              .height(36)
              .fontSize(16)
              .backgroundColor('#07C160')
              .fontColor(Color.White)
              .margin({ bottom: 20 })
              .onClick(() => {
                hilog.info(0x0000, 'BadgesPage', `分享勋章: ${this.selectedBadge?.nameKey}`);
                // 分享逻辑
              });
          }
          .width('80%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .position({ x: '10%', y: '20%' })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
  }
}