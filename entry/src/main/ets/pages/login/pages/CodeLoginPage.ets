///  description:  验证码注册页面

import { router } from '@kit.ArkUI'
import { APIs, HttpUtils, ResType } from 'JhCommon';
import { BaseNavigation, JhLoginTextInput, JhProgressHUD, JhButton, JhCountDownBtn } from 'JhCommon';
import { JhAESPreferencesUtils, kUserDefault_UserInfo } from 'JhCommon';
import { userApiService, RegisterResponse } from '../../../services/api_network/UserApiService';

export const kUserDefault_UserCredentials: string = 'kUserDefault_UserCredentials';

export interface UserCredentials {
  phone: string;
  userName: string;
  password: string;
  registerTime: string;
}

interface UserData {
  userId: string;
  userName: string;
  phone: string;
}

@Entry
@Preview
@Component
struct CodeLoginPage {
  @State @Watch('onChange') phone: string = ''
  @State @Watch('onChange') code: string = ''
  @State @Watch('onChange') userName: string = ''
  @State @Watch('onChange') password: string = ''
  @State disabled: boolean = true
  @State getCodeText: string = ''
  @State resendText: string = ''
  @State registerBtnText: string = ''

  aboutToAppear(): void {
    this.getCodeText = getContext(this).resourceManager.getStringSync($r('app.string.get_code_text'))
    this.resendText = getContext(this).resourceManager.getStringSync($r('app.string.resend_code_text'))
    this.registerBtnText = getContext(this).resourceManager.getStringSync($r('app.string.register_and_login_btn'))
  }

  onChange(): void {
    const isClick: boolean = this.phone.length >= 11 &&
      this.code.length >= 4 &&
      this.userName.length >= 2 &&
      this.password.length >= 6
    this.disabled = !isClick
  }

  build() {
    Column() {
      BaseNavigation({ title: '', bgColor: Color.Transparent })
      Scroll() {
        Column() {
          this.body()
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin(15)
      }
    }
  }

  @Builder
  body() {
    Text($r('app.string.code_register_title')).fontSize(26).fontWeight(FontWeight.Bold)
    Blank().height(80)
    JhLoginTextInput({
      text: this.phone,
      placeholder: $r('app.string.input_phone_placeholder'),
      maxLength: 11,
      inputType: InputType.Number,
      inputCallBack: (value: Object): void => {
        this.phone = value as string
      },
    })
    Blank().height(8)
    JhLoginTextInput({
      text: this.code,
      placeholder: $r('app.string.input_code_placeholder'),
      maxLength: 6,
      inputType: InputType.Number,
      rightWidget: (): void => {
        this.rightBuilder()
      },
      inputCallBack: (value: Object): void => {
        this.code = value as string
      },
    })
    Blank().height(8)
    JhLoginTextInput({
      text: this.userName,
      placeholder: $r('app.string.input_username_placeholder'),
      inputType: InputType.Normal,
      inputCallBack: (value: Object): void => {
        this.userName = value as string
      },
    })
    Blank().height(8)
    JhLoginTextInput({
      text: this.password,
      placeholder: $r('app.string.input_password_placeholder'),
      inputType: InputType.Password,
      inputCallBack: (value: Object): void => {
        this.password = value as string
      },
    })
    JhButton({
      text: this.registerBtnText,
      disabled: this.disabled,
      onPressed: async (): Promise<void> => await this.clickRegister()
    })
      .margin({ top: 50, bottom: 30 })
  }

  @Builder
  rightBuilder() {
    JhCountDownBtn({
      getCodeText: this.getCodeText,
      resendAfterText: this.resendText,
      showBorder: true,
      getVCode: (): Promise<boolean> => {
        return this.verifyPhoneAndSendCode()
      }
    })
  }

  async verifyPhoneAndSendCode(): Promise<boolean> {
    if (this.phone.length !== 11) {
      JhProgressHUD.showError(getContext(this).resourceManager.getStringSync($r('app.string.phone_error_msg')))
      return false
    }

    return new Promise<boolean>((resolve: (value: boolean) => void) => {
      setTimeout((): void => {
        JhProgressHUD.showSuccess(getContext(this).resourceManager.getStringSync($r('app.string.code_sent_msg')))
        resolve(true)
      }, 1000)
    })
  }

  async clickRegister(): Promise<void> {
    if (await this.verifyCode()) {
      await this.saveUserCredentials()
    } else {
      JhProgressHUD.showError(getContext(this).resourceManager.getStringSync($r('app.string.code_error_msg')))
    }
  }

  async verifyCode(): Promise<boolean> {
    return true
  }

  async saveUserCredentials(): Promise<void> {
    try {
      const registerResult: RegisterResponse = await userApiService.register(
        this.phone,
        this.userName,
        this.password
      )

      if (registerResult.success) {
        const userCredentials: UserCredentials = {
          phone: this.phone,
          userName: this.userName,
          password: this.password,
          registerTime: new Date().toISOString()
        }

        await JhAESPreferencesUtils.saveModel(kUserDefault_UserCredentials, userCredentials)

        const userData: UserData = {
          userId: registerResult.user_id?.toString() || Date.now().toString(),
          userName: registerResult.username || this.userName,
          phone: registerResult.phone || this.phone
        }

        await JhAESPreferencesUtils.saveModel(kUserDefault_UserInfo, userData)

        JhProgressHUD.showSuccess(getContext(this).resourceManager.getStringSync($r('app.string.register_success_msg')))

        setTimeout((): void => {
          router.clear()
          router.replaceUrl({
            url: 'pages/Index',
            params: {
              userData: userData,
              loginTime: new Date().toISOString(),
              isNewUser: true,
              loginSource: getContext(this).resourceManager.getStringSync($r('app.string.login_source_code_register'))
            }
          })
        }, 1500)
      } else {
        JhProgressHUD.showError(registerResult.message)
      }
    } catch (error) {
      JhProgressHUD.showError(getContext(this).resourceManager.getStringSync($r('app.string.register_failed_msg')))
    }
  }
}