import { APIs, HttpUtils, ResType } from 'JhCommon';
import { JhLoginTextInput, JhProgressHUD } from 'JhCommon';
import { JhColorUtils} from 'JhCommon';
import { JhButton } from 'JhCommon/src/main/ets/JhCommon/components/JhButton';
import { BaseNavigation, JhSetCell, KColors, JhAESPreferencesUtils, kUserDefault_UserInfo} from 'JhCommon'
import { UserModel } from '../../model/UserModel';
import { router } from '@kit.ArkUI';
import { UserCredentials, kUserDefault_UserCredentials } from '../../login/pages/CodeLoginPage'

//个人信息页面

const _cellH = 55.0;
const _rowSpace = 6.0;

interface ServerUserInfo {
  userID: string;
  userName: string;
  phone: string;
  pwd: string;
  token: string;
  avatarUrl: string;
  patContent?: string;
  healthCode?: string;
}

@Entry
@Preview
@Component
struct WxPersonInfoPage {
  @State name: string = 'jin'
  @State isEditing: boolean = false
  @State showDialog: boolean = false
  @State newName: string = ''
  @State paiYiPai: string = ''
  @State showPaiYiPaiDialog: boolean = false
  @State healthCode: string = ''
  @State showHealthCodeDialog: boolean = false

  build() {
    Column() {
      BaseNavigation({ title: $r('app.string.wxPersonInfo'), bgColor: Color.Transparent })
      this.body()
      if (this.showDialog) {
        this.editDialog()
      }
      if (this.showPaiYiPaiDialog) {
        this.editPaiYiPaiDialog()
      }
      if (this.showHealthCodeDialog) {
        this.editHealthCodeDialog()
      }
    }
    .backgroundColor(KColors.wxBgColor)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  @Builder
  editDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .onClick(() => {
          this.showDialog = false
          this.newName = this.name
        })

      Column() {
        Column() {
          Text($r('app.string.edit_name_title'))
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 20 })

          TextInput({ placeholder: $r('app.string.edit_name_placeholder'), text: this.newName })
            .width('90%')
            .height(45)
            .padding(10)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .margin({ bottom: 25 })
            .fontColor('#333333')
            .onChange((value: string) => {
              this.newName = value
            })

          Row() {
            Button($r('app.string.cancel'))
              .width('45%')
              .height(42)
              .backgroundColor('#EEEEEE')
              .fontColor('#666666')
              .fontSize(16)
              .borderRadius(21)
              .onClick(() => {
                this.showDialog = false
                this.newName = this.name
              })

            Button($r('app.string.confirm'))
              .width('45%')
              .height(42)
              .backgroundColor('#1698CE')
              .fontColor(Color.White)
              .fontSize(16)
              .borderRadius(21)
              .onClick(() => {
                if (this.newName.trim() !== '') {
                  this.name = this.newName

                  let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as ServerUserInfo;
                  if (!userInfo) {
                    userInfo = {
                      userID: Date.now().toString(),
                      userName: this.name,
                      phone: "",
                      pwd: "",
                      token: "",
                      avatarUrl: ""
                    } as ServerUserInfo;
                  } else {
                    userInfo.userName = this.name;
                  }

                  JhAESPreferencesUtils.saveModel(kUserDefault_UserInfo, userInfo);
                }
                let userCredentials = JhAESPreferencesUtils.getModel(kUserDefault_UserCredentials) as UserCredentials;
                if (userCredentials) {
                  userCredentials.userName = this.name;
                  JhAESPreferencesUtils.saveModel(kUserDefault_UserCredentials, userCredentials);
                }

                this.showDialog = false
                router.clear()
                setTimeout(() => {
                  router.replaceUrl({
                    url: 'pages/Index',
                    params: {
                      tabIndex: 3,
                      refresh: true,
                      timestamp: Date.now()
                    }
                  });
                }, 200);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 15 })
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 2, offsetY: 4 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  editPaiYiPaiDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .onClick(() => {
          this.showPaiYiPaiDialog = false
        })

      Column() {
        Column() {
          Text($r('app.string.edit_paiyipai_title'))
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 20 })

          TextInput({ placeholder: $r('app.string.edit_paiyipai_placeholder'), text: this.paiYiPai })
            .width('90%')
            .height(45)
            .padding(10)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .margin({ bottom: 25 })
            .fontColor('#333333')
            .onChange((value: string) => {
              this.paiYiPai = value
            })

          Row() {
            Button($r('app.string.cancel'))
              .width('45%')
              .height(42)
              .backgroundColor('#EEEEEE')
              .fontColor('#666666')
              .fontSize(16)
              .borderRadius(21)
              .onClick(() => {
                this.showPaiYiPaiDialog = false
              })

            Button($r('app.string.confirm'))
              .width('45%')
              .height(42)
              .backgroundColor('#1698CE')
              .fontColor(Color.White)
              .fontSize(16)
              .borderRadius(21)
              .onClick(() => {
                if (this.paiYiPai.trim() !== '') {
                  let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as ServerUserInfo;
                  if (!userInfo) {
                    userInfo = {
                      userID: Date.now().toString(),
                      userName: this.name,
                      phone: "",
                      pwd: "",
                      token: "",
                      avatarUrl: ""
                    } as ServerUserInfo;
                  }
                  userInfo.patContent = this.paiYiPai;
                  JhAESPreferencesUtils.saveModel(kUserDefault_UserInfo, userInfo);
                }
                this.showPaiYiPaiDialog = false
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 15 })
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 2, offsetY: 4 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  editHealthCodeDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .onClick(() => {
          this.showHealthCodeDialog = false
        })

      Column() {
        Column() {
          Text($r('app.string.edit_healthcode_title'))
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 20 })

          TextInput({ placeholder: $r('app.string.edit_healthcode_placeholder'), text: this.healthCode })
            .width('90%')
            .height(45)
            .padding(10)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .margin({ bottom: 25 })
            .fontColor('#333333')
            .onChange((value: string) => {
              this.healthCode = value
            })

          Row() {
            Button($r('app.string.cancel'))
              .width('45%')
              .height(42)
              .backgroundColor('#EEEEEE')
              .fontColor('#666666')
              .fontSize(16)
              .borderRadius(21)
              .onClick(() => {
                this.showHealthCodeDialog = false
              })

            Button($r('app.string.confirm'))
              .width('45%')
              .height(42)
              .backgroundColor('#1698CE')
              .fontColor(Color.White)
              .fontSize(16)
              .borderRadius(21)
              .onClick(() => {
                if (this.healthCode.trim() !== '') {
                  let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as ServerUserInfo;
                  if (!userInfo) {
                    userInfo = {
                      userID: Date.now().toString(),
                      userName: this.name,
                      phone: "",
                      pwd: "",
                      token: "",
                      avatarUrl: "",
                      healthCode: this.healthCode
                    } as ServerUserInfo;
                  }
                  userInfo.healthCode = this.healthCode;
                  JhAESPreferencesUtils.saveModel(kUserDefault_UserInfo, userInfo);
                }
                this.showHealthCodeDialog = false
                router.clear()
                setTimeout(() => {
                  router.replaceUrl({
                    url: 'pages/Index',
                    params: {
                      tabIndex: 3,
                      refresh: true,
                      timestamp: Date.now()
                    }
                  });
                }, 200);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 15 })
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(15)
        .shadow({ radius: 20, color: '#40000000', offsetX: 2, offsetY: 4 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  body() {
    List() {
      ListItem() {
        Column() {
          JhSetCell({
            cellHeight: 75,
            title: $r('app.string.avatar'),
            rightWidget: () => {
              this.rightBuilder1()
            },
            clickCallBack: (): void => {
            },
          })
          JhSetCell({
            cellHeight: _cellH,
            title: $r('app.string.name'),
            text: this.name,
            clickCallBack: (): void => {
              this.newName = this.name
              this.showDialog = true
            }
          })
          JhSetCell({
            cellHeight: _cellH,
            title: $r('app.string.more'),
            hiddenLine: true
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            title: $r('app.string.my_address'),
            hiddenLine: true,
          })
          Blank().height(15)
        }
      }
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true
    })
  }

  @Builder
  rightBuilder1() {
    Image('https://gitee.com/zhaozehe/zako/raw/master/ic_535a5f26fa59f35f023467562ae1388e.png')
      .width(55)
      .height(55)
      .borderRadius(5)
      .alt($rawfile("wechat/mine/default_avatar.jpg"))
      .onError(() => {
      })
  }

  @Builder
  rightBuilder2() {
    Image($rawfile('wechat/mine/ic_setting_myQR.png'))
      .width(20)
      .height(20)
      .margin({ right: 15 })
  }

  aboutToAppear() {
    let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as ServerUserInfo;
    if (userInfo && userInfo.userName) {
      this.name = userInfo.userName;
      if (userInfo.patContent) {
        this.paiYiPai = userInfo.patContent;
      } else {
        this.paiYiPai = this.name;
      }
      if (userInfo.healthCode) {
        this.healthCode = userInfo.healthCode;
      }
    }
  }
}