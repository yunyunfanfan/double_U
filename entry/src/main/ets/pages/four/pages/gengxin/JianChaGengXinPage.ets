import { router } from '@kit.ArkUI'
import { JhTextList, ItemType, JhSetCell, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

interface LocalItemType {
  label: Resource | string
  key: string
}

@Entry
@Preview
@Component
export struct SetPage {
  private _rowSpace: number = 24
  private _cellH: number = 72
  private _paddingValue: number = 24

  private localDataArr: LocalItemType[] = [
    { label: $r('app.string.update_log'), key: 'update_log' },
    { label: $r('app.string.current_version_title'), key: 'current_version' },
  ]

  @State dataArr: ItemType[] = []
  @State titleText: string = ''

  aboutToAppear(): void {
    console.info('🚀 SetPage - 页面即将出现，开始初始化')
    this.initializeData()
  }

  private initializeData(): void {
    console.info('📊 SetPage - 开始初始化数据数组')
    try {
      const context = getContext(this)

      // 🌐 获取多语言标题
      this.titleText = context.resourceManager.getStringSync($r('app.string.check_update').id)
      console.info('🏷️ SetPage - 标题获取成功', `标题: ${this.titleText}`)

      // 🔄 处理数据数组
      this.dataArr = this.localDataArr.map((item: LocalItemType, index: number) => {
        const labelStr = context.resourceManager.getStringSync((item.label as Resource).id)
        console.info(`✅ SetPage - 数据项${index}转换成功`, `key: ${item.key}, label: ${labelStr}`)
        return { label: labelStr } as ItemType
      })
      console.info('🎉 SetPage - 数据初始化完成', `总数: ${this.dataArr.length}`)
    } catch (error) {
      console.error('❌ SetPage - 数据初始化失败', error)
      // 降级处理
      this.titleText = '检查更新'
      this.dataArr = [
        { label: '更新日志' },
        { label: '当前版本号' }
      ] as ItemType[]
    }
  }

  build() {
    Scroll() {
      Column() {
        JhTextList({
          title: this.titleText,  // ✅ 使用string类型变量
          dataArr: this.dataArr,
          callBack: (index: number, text: string) => {
            console.info('🔍 SetPage - 用户点击列表项', `索引: ${index}, 文本: ${text}`)
            const cleanText = text.replace(/[^\u4e00-\u9fa5]/g, '')
            console.info('🧹 SetPage - 文本清理完成', `清理后: ${cleanText}`)
            this.handleCellClick(cleanText, index)
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

  private handleCellClick(text: string, index: number): void {
    console.info('🎯 SetPage - 处理单元格点击', `文本: ${text}, 索引: ${index}`)

    const itemKey = this.localDataArr[index]?.key
    console.info('🔑 SetPage - 获取项目键值', `键值: ${itemKey}`)

    switch (itemKey) {
      case 'current_version':
        console.info('📱 SetPage - 显示版本信息')
        this.showVersionInfo()
        break
      case 'update_log':
        console.info('📝 SetPage - 跳转更新日志页面')
        this.navigateToUpdateLog()
        break
      default:
        console.error('⚠️ SetPage - 未知选项', `键值: ${itemKey}`)
    }
  }

  private showVersionInfo(): void {
    console.info('🏷️ SetPage - 准备显示版本信息弹窗')
    try {
      const context = getContext(this)
      const titleStr = context.resourceManager.getStringSync($r('app.string.current_version_title').id)
      const messageStr = context.resourceManager.getStringSync($r('app.string.version_message').id)

      JhAlert.showSystemAlert({
        title: titleStr,    // ✅ string类型
        message: messageStr // ✅ string类型
      })
      console.info('✅ SetPage - 版本信息弹窗显示成功')
    } catch (error) {
      console.error('❌ SetPage - 显示版本信息失败', error)
    }
  }

  private navigateToUpdateLog(): void {
    console.info('🔄 SetPage - 准备跳转更新日志页面')
    try {
      router.pushUrl({ url: 'pages/four/pages/gengxin/RiZhi' })
      console.info('✅ SetPage - 页面跳转请求发送成功')
    } catch (error) {
      console.error('❌ SetPage - 页面跳转失败', error)
    }
  }
}