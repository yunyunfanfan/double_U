import { router } from '@kit.ArkUI';
import { userApiService, PointsRankingResponse, PointsRankingItem } from '../../../../services/api_network/UserApiService';

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
}

class RankingDisplayItem {
  rank: number;
  userId: number;
  username: string;
  totalPoints: number;
  isCurrentUser: boolean;

  constructor(rank: number, userId: number, username: string, totalPoints: number, isCurrentUser: boolean) {
    this.rank = rank;
    this.userId = userId;
    this.username = username;
    this.totalPoints = totalPoints;
    this.isCurrentUser = isCurrentUser;
  }
}

@Entry
@Component
export struct PointsRankingPage {
  @State rankingList: RankingDisplayItem[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State currentUserId: number = 0;
  @State currentUserRank: number = 0;
  @State refreshing: boolean = false;

  aboutToAppear(): void {
    console.info('=== 积分排行榜页面初始化 ===');
    this.loadCurrentUser();
    this.loadRankingData();
  }

  private loadCurrentUser(): void {
    try {
      const userInfoStr = AppStorage.get<string>('userInfo');
      if (userInfoStr) {
        const userInfo: UserInfo = JSON.parse(userInfoStr) as UserInfo;
        this.currentUserId = parseInt(userInfo.userId || '0');
        console.info(`=== 当前用户ID: ${this.currentUserId} ===`);
      }
    } catch (error) {
      console.error(`=== 获取用户信息失败: ${error} ===`);
      this.currentUserId = 0;
    }
  }

  private async loadRankingData(): Promise<void> {
    try {
      console.info('=== 开始加载积分排行榜 ===');
      this.isLoading = true;
      this.errorMessage = '';

      const response: PointsRankingResponse = await userApiService.getPointsRanking(100);
      console.info(`=== 排行榜响应: ${JSON.stringify(response)} ===`);

      if (response.success && response.rankings) {
        const displayItems: RankingDisplayItem[] = response.rankings.map((item: PointsRankingItem) => {
          const isCurrentUser = item.user_id === this.currentUserId;
          if (isCurrentUser) {
            this.currentUserRank = item.rank;
          }
          return new RankingDisplayItem(
            item.rank,
            item.user_id,
            item.username,
            item.total_points,
            isCurrentUser
          );
        });

        this.rankingList = displayItems;
        console.info(`=== 排行榜加载完成，共${displayItems.length}条记录 ===`);
      } else {
        this.errorMessage = response.message || '获取排行榜失败';
        this.rankingList = [];
      }
    } catch (error) {
      console.error(`=== 加载排行榜异常: ${error} ===`);
      this.errorMessage = `加载失败: ${error}`;
      this.rankingList = [];
    } finally {
      this.isLoading = false;
      this.refreshing = false;
    }
  }

  private async refreshRanking(): Promise<void> {
    console.info('=== 用户触发排行榜刷新 ===');
    this.refreshing = true;
    await this.loadRankingData();
  }

  private getRankIcon(rank: number): string {
    if (rank === 1) return '🥇';
    if (rank === 2) return '🥈';
    if (rank === 3) return '🥉';
    return `${rank}`;
  }

  private getRankColor(rank: number): string {
    if (rank === 1) return '#FFD700';
    if (rank === 2) return '#C0C0C0';
    if (rank === 3) return '#CD7F32';
    return '#666666';
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
            console.error('=== 返回失败 ===', err);
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ left: 12 })

        Text('积分排行榜')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Button({ type: ButtonType.Circle }) {
          if (this.refreshing) {
            LoadingProgress().width(20).height(20).color('#4285F4')
          } else {
            Text('🔄').fontSize(18)
          }
        }
        .onClick(() => {
          if (!this.refreshing) {
            this.refreshRanking();
          }
        })
        .width(40).height(40).backgroundColor(Color.Transparent).margin({ right: 12 })
        .enabled(!this.refreshing)
      }
      .width('100%').height(60).justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFF').shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

      if (this.isLoading) {
        Column({ space: 20 }) {
          LoadingProgress().width(60).height(60).color('#4285F4')
          Text('正在加载排行榜...')
            .fontSize(16).fontColor('#666666')
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.errorMessage) {
        Column({ space: 20 }) {
          Text('😕').fontSize(64)
          Text('加载失败').fontSize(20).fontColor('#EA4335')
          Text(this.errorMessage).fontSize(14).fontColor('#666666').textAlign(TextAlign.Center)
          Button('重新加载')
            .onClick(() => this.refreshRanking())
            .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(12).height(44).width(120)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).padding(40)
      } else {
        Column() {
          // 当前用户排名卡片
          if (this.currentUserRank > 0) {
            Row() {
              Text('我的排名').fontSize(16).fontColor('#666666')
              Blank()
              Text(`第${this.currentUserRank}名`).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#4285F4')
            }
            .width('90%').padding(16).backgroundColor('#F0F8FF').borderRadius(12).margin({ top: 16, bottom: 8 })
          }

          // 排行榜列表
          if (this.rankingList.length === 0) {
            Column({ space: 16 }) {
              Text('📊').fontSize(48)
              Text('暂无排行榜数据').fontSize(16).fontColor('#666666')
              Button('刷新数据')
                .onClick(() => this.refreshRanking())
                .backgroundColor('#4285F4').fontColor(Color.White).borderRadius(20).height(40)
            }
            .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
          } else {
            Scroll() {
              Column({ space: 8 }) {
                ForEach(this.rankingList, (item: RankingDisplayItem, index: number) => {
                  Row() {
                    // 排名
                    Row() {
                      if (item.rank <= 3) {
                        Text(this.getRankIcon(item.rank))
                          .fontSize(24).textAlign(TextAlign.Center)
                      } else {
                        Text(`${item.rank}`)
                          .fontSize(16).fontWeight(FontWeight.Bold)
                          .fontColor(this.getRankColor(item.rank))
                      }
                    }
                    .width(50).height(40).justifyContent(FlexAlign.Center)

                    // 用户信息
                    Column() {
                      Text(item.username)
                        .fontSize(16).fontWeight(FontWeight.Medium)
                        .fontColor(item.isCurrentUser ? '#4285F4' : '#333333')
                        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(`用户ID: ${item.userId}`)
                        .fontSize(12).fontColor('#999999').margin({ top: 2 })
                    }
                    .layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 16 })

                    // 积分
                    Column() {
                      Text(`${item.totalPoints}`)
                        .fontSize(18).fontWeight(FontWeight.Bold)
                        .fontColor(item.isCurrentUser ? '#4285F4' : '#333333')
                      Text('积分')
                        .fontSize(12).fontColor('#666666')
                    }
                    .alignItems(HorizontalAlign.End)
                  }
                  .width('90%').height(60).padding({ left: 12, right: 12 })
                  .backgroundColor(item.isCurrentUser ? '#F0F8FF' : (index % 2 === 0 ? '#FAFAFA' : '#FFFFFF'))
                  .borderRadius(12).margin({ bottom: 4 })
                  .shadow({
                    radius: item.isCurrentUser ? 8 : 4,
                    color: item.isCurrentUser ? 'rgba(66, 133, 244, 0.2)' : 'rgba(0,0,0,0.05)',
                    offsetY: 2
                  })
                })
              }
              .padding({ top: 8, bottom: 20 })
            }
            .layoutWeight(1).scrollBar(BarState.Auto)
          }
        }
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%').height('100%').backgroundColor('#F8F9FA')
  }
}