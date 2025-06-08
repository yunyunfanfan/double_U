import { router } from '@kit.ArkUI'
import { JhTextList, ItemType } from 'JhCommon'

//多语言界面

@Entry
@Preview
@Component
export struct LanguagePage {
  private _rowSpace: number = 24
  private _paddingValue: number = 24

  dataArr: ItemType[] = [
    { label: $r('app.string.chinese_current') },
    { label: $r('app.string.english') },
    { label: $r('app.string.japanese') },
    { label: $r('app.string.russian') },
  ]

  build() {
    Scroll() {
      Column() {
        JhTextList({
          title: $r('app.string.multilingual_settings'),
          dataArr: this.dataArr,
          callBack: (index: number, text: string) => {
            console.log('选择语言:', text)
          }
        })
      }
      .padding({
        top: 14,
        bottom: 14,
        left: this._paddingValue,
        right: this._paddingValue
      })
      .width('100%')
    }
    .backgroundColor(0xF5F6FA)
  }
}