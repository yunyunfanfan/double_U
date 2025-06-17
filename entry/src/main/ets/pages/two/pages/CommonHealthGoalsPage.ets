import { router } from '@kit.ArkUI'
import { BaseNavigation, JhProgressHUD } from 'JhCommon'

class HealthTargetModel {
  id: string
  title: string
  description: string
  startDate: string
  endDate: string
  progress: number
  participants: string[]
  category: string
  color: string
  isCompleted: boolean

  constructor(
    id: string,
    title: string,
    description: string,
    startDate: string,
    endDate: string,
    progress: number,
    participants: string[],
    category: string,
    color: string,
    isCompleted: boolean
  ) {
    this.id = id
    this.title = title
    this.description = description
    this.startDate = startDate
    this.endDate = endDate
    this.progress = progress
    this.participants = participants
    this.category = category
    this.color = color
    this.isCompleted = isCompleted
  }
}

@CustomDialog
struct AddTargetDialog {
  controller?: CustomDialogController
  @Link newTarget: HealthTargetModel
  onSaveCallback: () => void = () => {}
  onCancelCallback: () => void = () => {}

  @Builder
  inputField(label: string, value: string, onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 5 })

      TextInput({ text: value, placeholder: `请输入${label}` })
        .width('100%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(5)
        .padding(10)
        .onChange(onChange)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ bottom: 10 })
  }

  private getCategoryColor(category: string): string {
    switch(category) {
      case '运动': return '#4CAF50'
      case '步行': return '#2196F3'
      case '饮食': return '#FF9800'
      case '户外': return '#9C27B0'
      case '睡眠': return '#3F51B5'
      default: return '#CCCCCC'
    }
  }

  build() {
    Column() {
      Text("新建健康目标")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      this.inputField("目标标题", this.newTarget.title, (value: string) => {
        this.newTarget.title = value
      })

      this.inputField("目标描述", this.newTarget.description, (value: string) => {
        this.newTarget.description = value
      })

      this.inputField("开始日期", this.newTarget.startDate, (value: string) => {
        this.newTarget.startDate = value
      })

      this.inputField("结束日期", this.newTarget.endDate, (value: string) => {
        this.newTarget.endDate = value
      })

      this.inputField("参与人员（逗号分隔）", this.newTarget.participants.join(', '), (value: string) => {
        this.newTarget.participants = value.split(',').map(p => p.trim()).filter(p => p !== '')
      })

      this.inputField("健康类别（运动/步行/饮食/户外/睡眠）", this.newTarget.category, (value: string) => {
        this.newTarget.category = value
        this.newTarget.color = this.getCategoryColor(value)
      })

      Row() {
        Button("取消")
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .width(120)
          .height(40)
          .margin({ right: 20 })
          .onClick(() => {
            this.onCancelCallback()
            this.controller?.close()
          })

        Button("保存")
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .width(120)
          .height(40)
          .onClick(() => {
            this.onSaveCallback()
          })
      }
      .margin({ top: 20 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .width('90%')
  }
}

@Entry
@Component
export struct CommonHealthTargetsPage {
  @State activeTargets: HealthTargetModel[] = []
  @State completedTargets: HealthTargetModel[] = []
  @State selectedTab: number = 0
  @State newTarget: HealthTargetModel = new HealthTargetModel(
    '', '', '', this.getCurrentDate(), this.getCurrentDate(),
    0, [], '', '#CCCCCC', false
  )
  private tabs: string[] = ['进行中', '已完成']
  scroller: Scroller = new Scroller()

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddTargetDialog({
      newTarget: $newTarget,
      onSaveCallback: (): void => this.handleSaveTarget(),
      onCancelCallback: (): void => this.handleCancelTarget()
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  })

  aboutToAppear() {
    this.loadSampleData()
  }

  loadSampleData() {
    this.activeTargets = this.getActiveTargets()
    this.completedTargets = this.getCompletedTargets()
  }

  getActiveTargets(): HealthTargetModel[] {
    return [
      new HealthTargetModel(
        '1',
        '每周家庭运动计划',
        '每周累计运动时间达到300分钟，每位家庭成员至少贡献60分钟',
        '2024-05-01',
        '2024-05-31',
        65,
        ['爸爸', '妈妈', '爷爷', '奶奶', '我'],
        '运动',
        '#4CAF50',
        false
      ),
      new HealthTargetModel(
        '2',
        '家庭步数挑战',
        '本月家庭总步数达到50万步，每天记录并分享步数',
        '2024-05-01',
        '2024-05-31',
        42,
        ['爸爸', '妈妈', '我', '李逸飞', '卢景灏'],
        '步行',
        '#2196F3',
        false
      ),
      new HealthTargetModel(
        '3',
        '健康饮食月',
        '一个月内家庭成员每天至少摄入5种蔬果，减少高糖高脂食品',
        '2024-05-01',
        '2024-05-31',
        30,
        ['爸爸', '妈妈', '爷爷', '奶奶'],
        '饮食',
        '#FF9800',
        false
      )
    ]
  }

  getCompletedTargets(): HealthTargetModel[] {
    return [
      new HealthTargetModel(
        '4',
        '春季户外活动',
        '每周末组织一次家庭户外活动，如徒步、骑行或公园游玩',
        '2024-03-01',
        '2024-04-30',
        100,
        ['爸爸', '妈妈', '我'],
        '户外',
        '#9C27B0',
        true
      ),
      new HealthTargetModel(
        '5',
        '早睡早起挑战',
        '连续21天保持23:00前睡觉，7:00前起床的良好作息',
        '2024-04-01',
        '2024-04-21',
        100,
        ['我', '李逸飞', '卢景灏'],
        '睡眠',
        '#3F51B5',
        true
      )
    ]
  }

  handleSaveTarget() {
    if (!this.validateTarget()) return

    const newTarget = new HealthTargetModel(
      Date.now().toString(),
      this.newTarget.title,
      this.newTarget.description,
      this.newTarget.startDate,
      this.newTarget.endDate,
      0,
      this.newTarget.participants,
      this.newTarget.category,
      this.newTarget.color,
      false
    )

    this.activeTargets = [...this.activeTargets, newTarget]
    JhProgressHUD.showText('目标创建成功')
    this.resetNewTarget()
    this.dialogController.close()
  }

  validateTarget(): boolean {
    const validCategories = ['运动', '步行', '饮食', '户外', '睡眠']

    if (!this.newTarget.title.trim()) {
      JhProgressHUD.showText('请填写目标标题')
      return false
    }
    if (!this.newTarget.startDate || !this.newTarget.endDate) {
      JhProgressHUD.showText('请填写完整日期')
      return false
    }
    if (this.newTarget.participants.length === 0) {
      JhProgressHUD.showText('请至少添加一个参与者')
      return false
    }
    if (!validCategories.includes(this.newTarget.category)) {
      JhProgressHUD.showText('请输入有效的健康类别')
      return false
    }
    return true
  }

  getCurrentDate(): string {
    const now = new Date()
    return `${now.getFullYear()}-${(now.getMonth()+1).toString().padStart(2,'0')}-${now.getDate().toString().padStart(2,'0')}`
  }

  resetNewTarget() {
    this.newTarget = new HealthTargetModel(
      '', '', '', this.getCurrentDate(), this.getCurrentDate(),
      0, [], '', '#CCCCCC', false
    )
  }

  handleCancelTarget() {
    this.resetNewTarget()
    this.dialogController.close()
  }

  @Builder
  targetCard(item: HealthTargetModel) {
    Column() {
      Row() {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Text(item.category)
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(item.color)
          .padding(5)
          .borderRadius(5)
      }
      .justifyContent(FlexAlign.SpaceBetween)

      Text(item.description)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })

      Text(`${item.startDate} - ${item.endDate}`)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8 })

      Row() {
        Progress({ value: item.progress, total: 100, type: ProgressType.Linear })
          .width('70%')
          .height(6)
        Text(`${item.progress}%`)
          .fontColor(item.color)
          .margin({ left: 10 })
      }
      .margin({ top: 12 })

      Text('参与者：' + item.participants.join(', '))
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ top: 10, left: 15, right: 15 })
  }

  build() {
    Column() {
      BaseNavigation({ title: '健康目标管理', bgColor: Color.White })

      Column() {
        // 标签页切换
        Row() {
          ForEach(this.tabs, (tab: string, index: number) => {
            Text(tab)
              .fontSize(16)
              .fontColor(this.selectedTab === index ? '#4CAF50' : '#999999')
              .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .border({
                width: { bottom: this.selectedTab === index ? 2 : 0 },
                color: '#4CAF50'
              })
              .onClick(() => {
                this.selectedTab = index
              })
          })
        }
        .margin({ bottom: 15 })

        // 添加按钮
        Button('+ 创建新的健康目标')
          .width('90%')
          .height(45)
          .backgroundColor('#4CAF50')
          .borderRadius(22)
          .fontColor(Color.White)
          .margin(15)
          .onClick(() => this.dialogController.open())

        // 目标列表
        Scroll() {
          Column() {
            if (this.selectedTab === 0) {
              ForEach(this.activeTargets, (item: HealthTargetModel) => {
                this.targetCard(item)
              })
            } else {
              ForEach(this.completedTargets, (item: HealthTargetModel) => {
                this.targetCard(item)
              })
            }
          }
          .padding({ bottom: 30 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
