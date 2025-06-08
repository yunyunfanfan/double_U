import { router } from '@kit.ArkUI'
import { JhTextList, ItemType, JhSetCell, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

interface LocalItemType {
  label: Resource | string
}

@Entry
@Preview
@Component
export struct SetPage {
  private _rowSpace: number = 24
  private _cellH: number = 72
  private _paddingValue: number = 24

  private localDataArr: LocalItemType[] = [
    { label: $r('app.string.no_update_log') },
  ]

  @State dataArr: ItemType[] = []

  aboutToAppear(): void {
    console.info('🚀 SetPage - 页面即将出现，开始初始化数据')
    this.initializeData()
  }

  private initializeData(): void {
    console.info('📊 SetPage - 开始转换Resource到string')
    try {
      const context = getContext(this)
      this.dataArr = this.localDataArr.map((item: LocalItemType, index: number) => {
        const labelStr = context.resourceManager.getStringSync((item.label as Resource).id)
        console.info(`✅ SetPage - 第${index}项转换成功: ${labelStr}`)
        return { label: labelStr } as ItemType
      })
      console.info('🎉 SetPage - 所有数据转换完成')
    } catch (error) {
      console.error('❌ SetPage - 数据转换失败', error)
      this.dataArr = [{ label: '无更新日志' }] as ItemType[]
    }
  }

  build() {
    Scroll() {
      Column() {
        JhTextList({
          title: '',
          dataArr: this.dataArr,  // ✅ 正确的ItemType[]类型
          callBack: (index: number, text: string) => {
            console.info('🔍 SetPage - 用户点击列表项', `索引: ${index}, 文本: ${text}`)
            const cleanText = text.replace(/[^\u4e00-\u9fa5]/g, '')
            console.info('🧹 SetPage - 清理后的文本', `原文: ${text}, 清理后: ${cleanText}`)
            this.handleCellClick(cleanText)
          }
        })
          .margin({ bottom: this._rowSpace, top: 8 })
      }
      .padding({
        top: 4,
        bottom: 14,
        left: this._paddingValue,
        right: this._paddingValue
      })
      .width('100%')
    }
    .backgroundColor(0xF5F6FA)
  }

  private handleCellClick(text: string): void {
    console.info('🎯 SetPage - 处理单元格点击', `文本内容: ${text}`)
    switch (text) {
      default:
        console.info('⚠️ SetPage - 未处理的点击项', `文本: ${text}`)
        break
    }
  }
}