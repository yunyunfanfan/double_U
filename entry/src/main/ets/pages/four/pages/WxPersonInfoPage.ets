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
import { userApiService, AvatarUploadResponse, UserProfileResponse } from '../../../services/api_network/UserApiService';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { UserApiService } from '../../../services/api_network/UserApiService';

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
    serverUrl: '',
    uploadStatus: 'none'
  }
  @State currentUserId: number = 1

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

      // 读取图片文件并转换为base64
      const file = fileIo.openSync(imagePath);
      const stat = fileIo.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);

      // 转换为base64
      const uint8Array = new Uint8Array(buffer);
      const base64Helper = new util.Base64Helper();
      const base64String = base64Helper.encodeToStringSync(uint8Array);
      const base64Data = `data:image/jpeg;base64,${base64String}`;

      // 调用API上传
      const uploadResult: AvatarUploadResponse = await userApiService.uploadAvatar(this.currentUserId, base64Data);

      if (uploadResult.success && uploadResult.avatar_url) {
        this.avatarInfo.serverUrl = uploadResult.avatar_url;
        this.avatarInfo.uploadStatus = 'success';

        // 更新本地存储的用户信息
        let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as ServerUserInfo;
        if (userInfo) {
          userInfo.avatarUrl = uploadResult.avatar_url;
          JhAESPreferencesUtils.saveModel(kUserDefault_UserInfo, userInfo);
        }

        console.info('[头像上传] 头像上传成功');
        JhProgressHUD.showToast('头像上传成功');
      } else {
        this.avatarInfo.uploadStatus = 'failed';
        console.error(`[头像上传] 上传失败: ${uploadResult.message}`);
        JhProgressHUD.showToast(uploadResult.message || '上传失败');
      }
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[头像上传] 上传失败: ${err.message}`);
      this.avatarInfo.uploadStatus = 'failed';
      JhProgressHUD.showToast('头像上传失败');
    }
  }

  // 从服务器加载用户资料
  private async loadUserProfile(): Promise<void> {
    try {
      console.info(`[用户资料] 开始加载用户${this.currentUserId}的资料`);

      const profileResult: UserProfileResponse = await userApiService.getUserProfile(this.currentUserId);

      if (profileResult.success && profileResult.data) {
        this.name = profileResult.data.username;
        if (profileResult.data.avatar_url) {
          this.avatarInfo.serverUrl = profileResult.data.avatar_url;
        }
        console.info(`[用户资料] 资料加载成功: ${this.name}`);
      } else {
        console.error(`[用户资料] 加载失败: ${profileResult.message}`);
      }
    } catch (error) {
      console.error(`[用户资料] 加载异常: ${error}`);
    }
  }

  // 获取显示的头像源
  private getAvatarSource(): string | Resource {
    if (this.avatarInfo.serverUrl) {
      return UserApiService.getAvatarUrl(this.avatarInfo.serverUrl);
    }
    return $rawfile("wechat/mine/default_avatar.jpg");
  }

  build() {
    Column() {
      BaseNavigation({ title: '个人信息', bgColor: Color.Transparent })
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
          Text('编辑名字')
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 20 })

          TextInput({ placeholder: '请输入新名字', text: this.newName })
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
            Button('取消')
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

            Button('确定')
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
          Text('编辑拍一拍')
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 20 })

          TextInput({ placeholder: '请输入拍一拍内容', text: this.paiYiPai })
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
            Button('取消')
              .width('45%')
              .height(42)
              .backgroundColor('#EEEEEE')
              .fontColor('#666666')
              .fontSize(16)
              .borderRadius(21)
              .onClick(() => {
                this.showPaiYiPaiDialog = false
              })

            Button('确定')
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
          Text('编辑健康码')
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20, bottom: 20 })

          TextInput({ placeholder: '请输入健康码', text: this.healthCode })
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
            Button('取消')
              .width('45%')
              .height(42)
              .backgroundColor('#EEEEEE')
              .fontColor('#666666')
              .fontSize(16)
              .borderRadius(21)
              .onClick(() => {
                this.showHealthCodeDialog = false
              })

            Button('确定')
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
            title: '头像',
            rightWidget: () => {
              this.rightBuilder1()
            },
            clickCallBack: (): void => {
              this.selectImageFromGallery()
            },
          })
          JhSetCell({
            cellHeight: _cellH,
            title: '名字',
            text: this.name,
            clickCallBack: (): void => {
              this.newName = this.name
              this.showDialog = true
            }
          })
          JhSetCell({
            cellHeight: _cellH,
            title: '更多',
            hiddenLine: true
          })
          Blank().height(_rowSpace)
          JhSetCell({
            cellHeight: _cellH,
            title: '我的地址',
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

    // 获取当前用户ID
    let userInfo = JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as ServerUserInfo;
    if (userInfo && userInfo.userID) {
      this.currentUserId = parseInt(userInfo.userID);
    }

    // 加载本地用户信息
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

    // 从服务器加载最新的用户资料
    this.loadUserProfile();

    console.info(`[个人信息页面] 用户信息加载完成: ${this.name}`)
  }
}