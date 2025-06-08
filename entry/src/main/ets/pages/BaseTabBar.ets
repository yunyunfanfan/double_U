import { OnePage } from './one/OnePage';
import { TwoPage } from './two/TwoPage';
import { ThreePage } from './three/ThreePage';
import { FourPage } from './four/FourPage';

export interface TabType {
  text: string,
  imgPath: string,
  imgFormat: 'png' | 'svg',
  showBadge?: boolean,
}

@Preview
@Entry
@Component
export struct BaseTabBar {
  @Prop initialIndex: number = 0;
  @State currentIndex: number = 0;
  tabsController: TabsController = new TabsController();

  private tabList: TabType[] = [{
    imgPath: 'tab/nav_tab_1',
    text: this.getStringResource($r('app.string.tab_health')),
    imgFormat: 'svg'
  }, {
    text: this.getStringResource($r('app.string.tab_family')),
    imgPath: 'tab/nav_tab_2',
    imgFormat: 'svg'
  }, {
    text: this.getStringResource($r('app.string.tab_device')),
    imgPath: 'tab/nav_tab_3',
    showBadge: false,
    imgFormat: 'png'
  }, {
    text: this.getStringResource($r('app.string.tab_mine')),
    imgPath: 'tab/nav_tab_4',
    imgFormat: 'png'
  }];

  private getStringResource(resource: Resource): string {
    return getContext(this).resourceManager.getStringSync(resource);
  }

  aboutToAppear() {
    this.currentIndex = this.initialIndex;
  }

  aboutToRender() {
    setTimeout(() => {
      this.tabsController.changeIndex(this.currentIndex);
    }, 50);
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController,
        index: this.initialIndex
      }) {
        ForEach(this.tabList, (item: TabType, index: number) => {
          TabContent() {
            if (index == 0) {
              OnePage()
            } else if (index == 1) {
              TwoPage()
            } else if (index == 2) {
              ThreePage()
            } else {
              FourPage()
            }
          }
          .tabBar(this.TabBarBuilder(
            item.text,
            index,
            $rawfile(`${item.imgPath}.${item.imgFormat}`),
            $rawfile(`${item.imgPath}_on.${item.imgFormat}`),
            item.showBadge
          ))
        })
      }
      .scrollable(true)
      .animationDuration(1)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .backgroundColor("#eeeeee")
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBarBuilder(title: string, index: number, normalImg: Resource, selectedImg: Resource, showBadge?: boolean) {
    Column() {
      Badge({
        value: '',
        position: { x: 24 - 2.5, y: -2.5 },
        style: { badgeSize: showBadge && this.currentIndex != index ? 6 : 0, badgeColor: '#FA2A2D' }
      }) {
        Image(this.currentIndex == index ? selectedImg : normalImg)
          .width(24)
          .height(24)
      }

      Text(title)
        .fontSize(14)
        .margin({ top: 4 })
        .fontColor(this.currentIndex == index ? '#000000' : '#999999')
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height(50)
    .padding({ top: 6, bottom: 6 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .id(`tabBar${index}`)
  }
}