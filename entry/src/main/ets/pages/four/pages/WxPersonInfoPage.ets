import { APIs, HttpUtils, ResType } from 'JhCommon';
import { JhLoginTextInput, JhProgressHUD } from 'JhCommon';
import { JhColorUtils} from 'JhCommon';
import { JhButton } from 'JhCommon/src/main/ets/JhCommon/components/JhButton';
import { BaseNavigation, JhSetCell, KColors, JhAESPreferencesUtils, kUserDefault_UserInfo} from 'JhCommon'
import { UserModel } from '../../model/UserModel';
import { router } from '@kit.ArkUI';
import { UserCredentials, kUserDefault_UserCredentials } from '../../login/pages/CodeLoginPage'
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

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

interface AvatarInfo {
  localPath: string;
  serverUrl: string;
  uploadStatus: 'uploading' | 'success' | 'failed' | 'none';
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
  @State avatarInfo: AvatarInfo = {
    localPath: '',
    serverUrl: '',
    uploadStatus: 'none'
  }

  // 从相册选择图片
  private async selectImageFromGallery(): Promise<void> {
    try {
      console.info('[头像选择] 开始从相册选择图片');

      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoPicker = new picker.PhotoViewPicker();
      const selectResult: picker.PhotoSelectResult = await photoPicker.select(photoSelectOptions);

      if (selectResult && selectResult.photoUris && selectResult.photoUris.length > 0) {
        const selectedUri: string = selectResult.photoUris[0];
        console.info(`[头像选择] 选择的图片URI: ${selectedUri}`);

        this.avatarInfo.localPath = selectedUri;
        await this.uploadAvatarToServer(selectedUri);
      } else {
        console.warn('[头像选择] 未选择任何图片');
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[头像选择] 选择图片失败: ${err.message}`);
    }
  }

  // 上传头像到服务器
  private async uploadAvatarToServer(imagePath: string): Promise<void> {
    try {
      console.info('[头像上传] 开始上传头像到服务器');
      this.avatarInfo.uploadStatus = 'uploading';

      // TODO: 这里实现实际的上传逻辑
      // const uploadResult = await this.uploadImageToAPI(imagePath);

      // 模拟上传过程
      await new Promise<void>((resolve: (value: void) => void) => {
        setTimeout(() => {
          resolve();
        }, 2000);
      });

      // 模拟上传成功，保存到本地存储
      this.avatarInfo.serverUrl = imagePath; // 临时使用本地路径
      this.avatarInfo.uploadStatus = 'success';

      // 更新用户信息
      let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as ServerUserInfo;
      if (userInfo) {
        userInfo.avatarUrl = imagePath;
        JhAESPreferencesUtils.saveModel(kUserDefault_UserInfo, userInfo);
      }

      console.info('[头像上传] 头像上传成功');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[头像上传] 上传失败: ${err.message}`);
      this.avatarInfo.uploadStatus = 'failed';
    }
  }

  // 获取显示的头像源
  private getAvatarSource(): string | Resource {
    if (this.avatarInfo.localPath) {
      return this.avatarInfo.localPath;
    }
    if (this.avatarInfo.serverUrl) {
      return this.avatarInfo.serverUrl;
    }
    return $rawfile("wechat/mine/default_avatar.jpg");
  }

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
              this.selectImageFromGallery()
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
    Stack() {
      Image(this.getAvatarSource())
        .width(55)
        .height(55)
        .borderRadius(5)
        .objectFit(ImageFit.Cover)
        .onError(() => {
          console.error('[头像显示] 头像加载失败')
        })

      // 上传状态遮罩
      if (this.avatarInfo.uploadStatus === 'uploading') {
        Column() {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#FFFFFF')
        }
        .width(55)
        .height(55)
        .borderRadius(5)
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
      }
    }
  }

  @Builder
  rightBuilder2() {
    Image($rawfile('wechat/mine/ic_setting_myQR.png'))
      .width(20)
      .height(20)
      .margin({ right: 15 })
  }

  aboutToAppear() {
    console.info('[个人信息页面] 页面初始化开始')
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
      if (userInfo.avatarUrl) {
        this.avatarInfo.serverUrl = userInfo.avatarUrl;
      }
    }
    console.info(`[个人信息页面] 用户信息加载完成: ${this.name}`)
  }
}