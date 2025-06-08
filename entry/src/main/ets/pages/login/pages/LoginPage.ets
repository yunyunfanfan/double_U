///  LoginPage.ets
///  15117053374 空调安装师傅
///  Created by iotjin on 2024/08/15.
///  description:  登录页面

import { router } from '@kit.ArkUI';
import { userApiService, LoginResponse } from '../../../services/api_network/UserApiService';
import { JhLoginTextInput, JhProgressHUD } from 'JhCommon';
import { JhAESPreferencesUtils, JhColorUtils, kUserDefault_UserInfo } from 'JhCommon';
import { JhButton } from 'JhCommon/src/main/ets/JhCommon/components/JhButton';

interface UserInfo {
  userId?: string;
  userName?: string;
  phone?: string;
  loginTime?: string;
}

interface UserData {
  userId: string;
  userName: string;
  phone: string;
  loginTime: string;
}

@Preview
@Entry
@Component
export struct LoginPage {
  @State @Watch('onChange') name: string = ''
  @State @Watch('onChange') pwd: string = ''
  @State disabled: boolean = true
  @State registerText: string = ''
  @State usernamePlaceholder: string = ''
  @State passwordPlaceholder: string = ''
  @State loginButtonText: string = ''
  @State codeRegisterText: string = ''
  @State forgetPasswordText: string = ''
  @State loggingInText: string = ''
  @State loginSuccessText: string = ''
  @State loginErrorText: string = ''
  @State loginFailedText: string = ''

  aboutToAppear() {
    this.registerText = getContext(this).resourceManager.getStringSync($r('app.string.register_text'))
    this.usernamePlaceholder = getContext(this).resourceManager.getStringSync($r('app.string.username_placeholder'))
    this.passwordPlaceholder = getContext(this).resourceManager.getStringSync($r('app.string.password_placeholder'))
    this.loginButtonText = getContext(this).resourceManager.getStringSync($r('app.string.login_button_text'))
    this.codeRegisterText = getContext(this).resourceManager.getStringSync($r('app.string.code_register_text'))
    this.forgetPasswordText = getContext(this).resourceManager.getStringSync($r('app.string.forget_password_text'))
    this.loggingInText = getContext(this).resourceManager.getStringSync($r('app.string.logging_in_text'))
    this.loginSuccessText = getContext(this).resourceManager.getStringSync($r('app.string.login_success_text'))
    this.loginErrorText = getContext(this).resourceManager.getStringSync($r('app.string.login_error_text'))
    this.loginFailedText = getContext(this).resourceManager.getStringSync($r('app.string.login_failed_text'))
    this.获取上次登录用户名()
  }

  async 获取上次登录用户名(): Promise<void> {
    try {
      const userInfo: UserInfo = await JhAESPreferencesUtils.getModel(kUserDefault_UserInfo) as UserInfo
      if (userInfo && userInfo.userName) {
        this.name = userInfo.userName
      }
    } catch (异常) {
    }
  }

  onChange() {
    const isClick: boolean = this.name.length >= 2 && this.pwd.length >= 6
    this.disabled = !isClick
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text(this.registerText)
            .fontSize(18)
            .onClick(() => {
              this.点击按钮(this.registerText)
            })
        }
        .justifyContent(FlexAlign.End)
        .width('100%')

        Row() {
          Image($rawfile('images/picture/img.png'))
            .width(144)
            .height(144)
            .objectFit(ImageFit.Cover)
            .borderRadius(72)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width(180)
        .height(180)
        .margin({ top: 80, bottom: 30 })
        .backgroundColor('#F0F0F0')
        .borderRadius(90)
        JhLoginTextInput({
          text: this.name,
          placeholder: this.usernamePlaceholder,
          leftIcon: $rawfile("svg/ic_login_user.svg"),
          inputCallBack: (value: Object): void => {
            this.name = value as string
          },
        })
        Blank().height(8)
        JhLoginTextInput({
          text: this.pwd,
          placeholder: this.passwordPlaceholder,
          leftIcon: $rawfile("svg/ic_login_pwd.svg"),
          isPwd: true,
          inputCallBack: (value: Object): void => {
            this.pwd = value as string
          },
        })
        JhButton({
          text: this.loginButtonText,
          disabled: this.disabled,
          onPressed: async (): Promise<void> => {
            await this.点击登录()
          }
        })
          .margin({ top: 50, bottom: 30 })

        Row() {
          Text(this.codeRegisterText)
            .fontSize(18)
            .onClick(() => {
              this.点击按钮(this.codeRegisterText)
            })
          Text(this.forgetPasswordText)
            .fontSize(18)
            .onClick(() => {
              this.点击按钮(this.forgetPasswordText)
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .height('100%')
      .width('100%')
      .padding(15)
    }
  }

  async 点击登录(): Promise<void> {
    try {
      const loginResult: LoginResponse = await userApiService.login(this.name, this.pwd)

      if (loginResult.success) {
        const userData: UserData = {
          userId: loginResult.user_id?.toString() || Date.now().toString(),
          userName: loginResult.username || this.name,
          phone: loginResult.phone || '',
          loginTime: new Date().toISOString()
        }

        await JhAESPreferencesUtils.saveModel(kUserDefault_UserInfo, userData)
        JhProgressHUD.showSuccess(this.loginSuccessText)

        setTimeout((): void => {
          router.clear()
          router.replaceUrl({ url: 'pages/Index' })
        }, 1500)
      } else {
        JhProgressHUD.showError(loginResult.message)
      }
    } catch (异常) {
      JhProgressHUD.showError(this.loginFailedText)
    }
  }

  点击按钮(text: string): void {
    if (text == this.registerText || text == this.codeRegisterText) {
      router.pushUrl({ url: 'pages/login/pages/CodeLoginPage' })
    }
    if (text == this.forgetPasswordText) {
      router.pushUrl({ url: 'pages/login/pages/FindPwdPage' })
    }
  }
}