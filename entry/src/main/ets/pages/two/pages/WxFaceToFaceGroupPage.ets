import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { router } from '@kit.ArkUI'

///面对面建群

@Entry
@Preview
@Component
struct WxFaceToFaceGroupPage {
  @State groupNumber: string = ''
  @State isCreating: boolean = false
  @State isJoining: boolean = false
  @State showKeyboard: boolean = false
  @State groupNumberArr: string[] = ['', '', '', '']
  @State currentIndex: number = 0
  @State showCopyTip: boolean = false

  getKeys(): string[][] {
    const clearText: string = getContext(this).resourceManager.getStringSync($r('app.string.clear_key_text_573829461847392'))
    const deleteText: string = getContext(this).resourceManager.getStringSync($r('app.string.delete_key_text_392847516293847'))
    return [
      ['1','2','3'],
      ['4','5','6'],
      ['7','8','9'],
      [clearText,'0',deleteText]
    ]
  }

  build() {
    Column() {
      BaseNavigation({
        title: getContext(this).resourceManager.getStringSync($r('app.string.face_to_face_group_title_847392651847392')),
        bgColor: Color.Transparent
      })
      Column() {
        // 输入提示
        Text(getContext(this).resourceManager.getStringSync($r('app.string.input_four_digits_hint_629384751639284')))
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 40, bottom: 20 })
          .width('100%')
          .textAlign(TextAlign.Center)

        // 输入框
        Row() {
          ForEach([0,1,2,3], (i: number) => {
            Column() {
              Text(this.groupNumberArr[i] || '')
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#222')
                .width(48)
                .height(56)
                .border({ width: 2, color: this.currentIndex === i ? '#07C160' : '#E5E5E5' })
                .backgroundColor('#FFF')
                .textAlign(TextAlign.Center)
                .margin({ left: i === 0 ? 0 : 12 })
            }
          })
        }
        .margin({ bottom: 32 })

        // 数字键盘
        Column() {
          ForEach([0,1,2], (rowIdx: number) => {
            Row() {
              ForEach(this.getKeys()[rowIdx], (key: string, colIdx: number) => {
                Button(key)
                  .width(72)
                  .height(56)
                  .fontSize(22)
                  .backgroundColor('#FFF')
                  .fontColor('#222')
                  .borderRadius(8)
                  .margin({ left: colIdx === 0 ? 0 : 16, top: rowIdx === 0 ? 0 : 16 })
                  .onClick(() => this.handleKeyPress(key))
              })
            }
          })
          // 最后一行特殊布局
          Row() {
            Blank().width(72)
            Button('0')
              .width(72)
              .height(56)
              .fontSize(22)
              .backgroundColor('#FFF')
              .fontColor('#222')
              .borderRadius(8)
              .onClick(() => this.handleKeyPress('0'))
              .margin({ left: 16, right: 16 })
            Button('⌫')
              .width(72)
              .height(56)
              .fontSize(22)
              .backgroundColor('#FFF')
              .fontColor('#222')
              .borderRadius(8)
              .onClick(() => this.handleKeyPress(getContext(this).resourceManager.getStringSync($r('app.string.delete_key_text_392847516293847'))))
          }
          .margin({ top: 16 })
        }

        // 复制群号按钮
        if (this.groupNumberArr.every(num => num !== '')) {
          Button(getContext(this).resourceManager.getStringSync($r('app.string.copy_group_number_btn_758394627184759')))
            .width('80%')
            .height(44)
            .backgroundColor('#07C160')
            .fontColor(Color.White)
            .fontSize(16)
            .borderRadius(4)
            .margin({ top: 32 })
            .onClick(() => {
              // 复制群号
              const groupNumber: string = this.groupNumberArr.join('')
              // TODO: 实现复制功能
              this.showCopyTip = true
              setTimeout(() => {
                this.showCopyTip = false
              }, 2000)
            })
        }

        // 复制成功提示
        if (this.showCopyTip) {
          Text(getContext(this).resourceManager.getStringSync($r('app.string.group_number_copied_tip_184759362847392')))
            .fontSize(14)
            .fontColor('#07C160')
            .margin({ top: 8 })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ top: 60 })
      .alignItems(HorizontalAlign.Center)
    }
    .backgroundColor('#F7F7F7')
  }

  handleKeyPress(key: string) {
    const deleteText: string = getContext(this).resourceManager.getStringSync($r('app.string.delete_key_text_392847516293847'))
    const clearText: string = getContext(this).resourceManager.getStringSync($r('app.string.clear_key_text_573829461847392'))
    if (key === deleteText) {
      for (let i = 3; i >= 0; i--) {
        if (this.groupNumberArr[i] !== '') {
          this.groupNumberArr[i] = ''
          this.currentIndex = i
          break
        }
      }
    } else if (key === clearText) {
      this.groupNumberArr = ['', '', '', '']
      this.currentIndex = 0
    } else if (/^\d$/.test(key)) {
      for (let i = 0; i < 4; i++) {
        if (this.groupNumberArr[i] === '') {
          this.groupNumberArr[i] = key
          this.currentIndex = i < 3 ? i + 1 : 3
          break
        }
      }
    }
  }

  @Builder
  showGroupNumber() {
    Column() {
      Text(getContext(this).resourceManager.getStringSync($r('app.string.group_number_label_629384751952847')))
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 40, bottom: 10 })

      Text(this.groupNumber)
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 40 })

      Text(getContext(this).resourceManager.getStringSync($r('app.string.tell_group_number_hint_847392615738294')))
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 40 })

      Button(getContext(this).resourceManager.getStringSync($r('app.string.copy_group_number_btn_758394627184759')))
        .width('80%')
        .height(44)
        .backgroundColor('#07C160')
        .fontColor(Color.White)
        .fontSize(16)
        .borderRadius(4)
        .onClick(() => {
          // TODO: 实现复制功能
          JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.group_number_copied_toast_573829461847392')))
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  createGroup() {
    Column() {
      Text(getContext(this).resourceManager.getStringSync($r('app.string.input_four_digits_text_392847516293847')))
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 40, bottom: 20 })

      TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.group_number_placeholder_758394627184759')) })
        .width('80%')
        .height(44)
        .backgroundColor(Color.White)
        .borderRadius(4)
        .margin({ bottom: 40 })
        .onChange((value: string) => {
          this.groupNumber = value
        })
        .onFocus(() => {
          this.showKeyboard = true
        })
        .onBlur(() => {
          this.showKeyboard = false
        })

      Button(getContext(this).resourceManager.getStringSync($r('app.string.create_group_chat_btn_184759362847392')))
        .width('80%')
        .height(44)
        .backgroundColor('#07C160')
        .fontColor(Color.White)
        .fontSize(16)
        .borderRadius(4)
        .onClick(() => {
          if (this.groupNumber.length !== 4) {
            JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.input_four_digits_text_392847516293847')))
            return
          }
          this.isCreating = true
        })

      Text(getContext(this).resourceManager.getStringSync($r('app.string.or_text_separator_629384751952847')))
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 20, bottom: 20 })

      Button(getContext(this).resourceManager.getStringSync($r('app.string.join_group_chat_btn_847392615738294')))
        .width('80%')
        .height(44)
        .backgroundColor(Color.Transparent)
        .fontColor('#07C160')
        .fontSize(16)
        .border({ width: 1, color: '#07C160' })
        .borderRadius(4)
        .onClick(() => {
          this.isJoining = true
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  joinGroup() {
    Column() {
      Text(getContext(this).resourceManager.getStringSync($r('app.string.input_four_digits_text_392847516293847')))
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 40, bottom: 20 })

      TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.group_number_placeholder_758394627184759')) })
        .width('80%')
        .height(44)
        .backgroundColor(Color.White)
        .borderRadius(4)
        .margin({ bottom: 40 })
        .onChange((value: string) => {
          this.groupNumber = value
        })
        .onFocus(() => {
          this.showKeyboard = true
        })
        .onBlur(() => {
          this.showKeyboard = false
        })

      Button(getContext(this).resourceManager.getStringSync($r('app.string.join_group_chat_btn_847392615738294')))
        .width('80%')
        .height(44)
        .backgroundColor('#07C160')
        .fontColor(Color.White)
        .fontSize(16)
        .borderRadius(4)
        .onClick(() => {
          if (this.groupNumber.length !== 4) {
            JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.input_four_digits_text_392847516293847')))
            return
          }
          // TODO: 实现加入群聊功能
          JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.joining_group_chat_toast_573829461847392')))
        })

      Text(getContext(this).resourceManager.getStringSync($r('app.string.or_text_separator_629384751952847')))
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 20, bottom: 20 })

      Button(getContext(this).resourceManager.getStringSync($r('app.string.create_group_chat_btn_184759362847392')))
        .width('80%')
        .height(44)
        .backgroundColor(Color.Transparent)
        .fontColor('#07C160')
        .fontSize(16)
        .border({ width: 1, color: '#07C160' })
        .borderRadius(4)
        .onClick(() => {
          this.isJoining = false
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}