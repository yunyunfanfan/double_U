import { router } from '@kit.ArkUI'
import { JhTextList, ItemType } from 'JhCommon'

interface ExtendedItemType extends ItemType {
  pagePath?: string;
  textKey?: string;
  displayText?: Resource;
  text ?: Resource;
}

@Entry
@Preview
@Component
export struct PointsHomePage {
  private _rowSpace: number = 24
  private _paddingValue: number = 24
  @State private displayDataArr: ExtendedItemType[] = []

  private dataArr: ExtendedItemType[] = [
    {
      label: '',
      pagePath: 'pages/four/pages/jifen/PointsPage',
      textKey: 'my_points'
    },
    {
      label: '',
      pagePath: 'pages/four/pages/jifen/BadgesPage',
      textKey: 'my_badges'
    },
    {
      label: '',
      pagePath: 'pages/four/pages/jifen/AboutPage',
      textKey: 'about'
    },
    {
      label: '',
      pagePath: 'pages/four/pages/jifen/PointsExplainPage',
      textKey: 'points_explanation'
    }
  ]

  aboutToAppear(): void {
    this.initDisplayData()
  }

  private initDisplayData(): void {
    this.displayDataArr = this.dataArr.map((item: ExtendedItemType) => {
      let iconPrefix: string = ''
      let textResource: Resource = $r('app.string.about')

      if (item.textKey === 'my_points')
      {
        iconPrefix = ' 💰 '
        textResource = $r('app.string.my_points')
      }
      else if (item.textKey === 'my_badges')
      {
        iconPrefix = ' 🎖️ '
        textResource = $r('app.string.my_badges')
      }
      else if (item.textKey === 'about')
      {
        iconPrefix = ' ℹ️ '
        textResource = $r('app.string.about')
      }
      else if (item.textKey === 'points_explanation')
      {
        iconPrefix = ' 📘 '
        textResource = $r('app.string.points_explanation')
      }

      const newItem: ExtendedItemType = {
        label: iconPrefix,
        pagePath: item.pagePath,
        textKey: item.textKey,
        text: textResource,
        value: undefined
      }
      return newItem
    })
  }

  build() {
    Scroll() {
      Column() {
        JhTextList({
          title: $r('app.string.health_points'),
          dataArr: this.displayDataArr,
          callBack: (index: number, str: string) => {
            this.handleItemClick(index)
          }
        })
      }
      .padding({
        top: 0,
        bottom: 14,
        left: 13,
        right: 13
      })
      .width('100%')
    }
    .backgroundColor(0xF5F6FA)
  }

  private handleItemClick(index: number): void {
    if (index >= 0 && index < this.dataArr.length) {
      const item: ExtendedItemType = this.dataArr[index]
      if (item.pagePath) {
        router.pushUrl({ url: item.pagePath })
      }
    }
  }
}