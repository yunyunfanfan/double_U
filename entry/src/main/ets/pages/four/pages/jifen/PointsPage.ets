import { router } from '@kit.ArkUI';
import { BaseNavigation, KColors } from 'JhCommon';


// 定义排行榜项的类型接口
interface RankItem {
  rank: number;
  userKey: string;
  steps: number;
  likes: number;
  iconColor: string;
}


@Entry
@Component
export struct PointsPage {
  // 使用明确的类型定义排行榜数据
  rankList: RankItem[] = [
    { rank: 1, userKey: 'user_li_yifei', steps: 285, likes: 27, iconColor: '#1E90FF' },
    { rank: 2, userKey: 'user_dad', steps: 163, likes: 23, iconColor: '#ff41e7e3' },
    { rank: 3, userKey: 'user_mom', steps: 102, likes: 31, iconColor: '#fffc7fbb' },
    { rank: 4, userKey: 'user_lu_jinghao', steps: 91, likes: 19, iconColor: '#ffe56b6b' },
    { rank: 5, userKey: 'user_me', steps: 83, likes: 15, iconColor: '#ff7ff37f' },
    { rank: 6, userKey: 'user_grandma', steps: 28, likes: 18, iconColor: '#fff3c568' }
  ];


  build() {
    Column() {
      // 顶部导航栏
      BaseNavigation({
        title: $r('app.string.my_points'),
        bgColor: Color.Transparent
      })

      // 排行榜区域
      Column() {
        // 排行榜标题区 - 使用正确的渐变背景
        Column() {
          // 使用文本图标替代图片
          Text('🏆')
            .fontSize(40)
            .margin({ top: 15 })
          Text($r('app.string.points_ranking'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 5, bottom: 10 })
        }
        .width('100%')
        // 正确使用背景色和渐变
        .backgroundColor('#3CB371')

        .padding({ top: 15, bottom: 15 })
        .borderRadius({ topLeft: 20, topRight: 20 })

        // 排行榜列表区
        Column() {
          // 排行榜头部
          Row() {
            Text($r('app.string.rank'))
              .fontSize(16)
              .fontColor('#666666')
              .width('15%')
              .textAlign(TextAlign.Start)
            Text($r('app.string.user'))
              .fontSize(16)
              .fontColor('#666666')
              .width('50%')
              .textAlign(TextAlign.Start)
            Text($r('app.string.likes'))
              .fontSize(16)
              .fontColor('#666666')
              .width('35%')
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 10 })
          .backgroundColor('#F8F8F8')

          // 排行榜具体数据展示
          ForEach(this.rankList, (item: RankItem) => {
            Row() {
              // 排名列
              Column() {
                Text(item.rank.toString())
                  .fontSize(item.rank <= 3 ? 20 : 18)
                  .fontWeight(item.rank <= 3 ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(item.rank === 1 ? '#FFD700' :
                    item.rank === 2 ? '#C0C0C0' :
                      item.rank === 3 ? '#CD7F32' : '#333333')
              }
              .width('15%')
              .justifyContent(FlexAlign.Start)

              // 用户信息列
              Row() {
                // 用户头像
                Text(item.userKey.charAt(5).toUpperCase())
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .width(36)
                  .height(36)
                  .backgroundColor(item.iconColor)
                  .margin({ right: 12 })
                  .borderRadius(18)
                  .fontColor('#FFFFFF')

                Column() {
                  // 用户名
                  Text($r(`app.string.${item.userKey}`))
                    // Text(this.getResourceString($r(`app.string.${item.userKey}`)))
                  // Text($r(`app.string.${item.userKey}`))
                    .fontSize(16)
                    .fontColor('#333333')
                    .width('100%')
                    .textAlign(TextAlign.Start)

                  // 步数
                  Text() {
                    Span(`${item.steps.toLocaleString()} `)
                    Span($r('app.string.points_unit'))
                  }
                    .fontSize(14)
                    .fontColor('#666666')
                    .width('100%')
                    .textAlign(TextAlign.Start)
                }
                .width('85%')
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Start)
              }
              .width('50%')
              .justifyContent(FlexAlign.Start)

              // 点赞列
              Row() {
                Column() {
                  Text(item.likes.toString())
                    .fontSize(16)
                    .fontColor(item.likes > 0 ? '#FF0000' : '#999999')
                    .width('100%')
                    .textAlign(TextAlign.End)
                  Text(item.likes > 0 ? '❤' : '♡')
                    .fontSize(18)
                    .fontColor(item.likes > 0 ? '#FF0000' : '#999999')
                    .width('100%')
                    .textAlign(TextAlign.End)
                }
                .width('100%')
              }
              .width('35%')
              .justifyContent(FlexAlign.End)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 15, bottom: 15 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 10 })
            .shadow({
              radius: 3,
              color: '#E0E0E0',
              offsetX: 0,
              offsetY: 2
            })
          })
        }
        .width('100%')
        .backgroundColor('#F5F5F5')
        .padding({ left: 15, right: 15, top: 15, bottom: 20 })
        .borderRadius({ bottomLeft: 20, bottomRight: 20 })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 15, right: 15, top: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
