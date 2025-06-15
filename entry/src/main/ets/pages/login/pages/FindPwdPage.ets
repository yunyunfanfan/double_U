///  description:  重置密码

import { router } from '@kit.ArkUI'
import { BaseNavigation, JhButton, JhLoginTextInput, JhProgressHUD } from 'JhCommon'
import { userApiService, ResetPasswordResponse } from '../../../services/api_network/UserApiService'

@Entry
@Preview
@Component
struct FindPwdPage {
  @State @Watch('onChange') name: string = ''
  @State @Watch('onChange') pwd: string = ''
  @State disabled: boolean = true
  @State titleText: string = ''
  @State usernameLabel: string = ''
  @State passwordLabel: string = ''
  @State usernamePlaceholder: string = ''
  @State passwordPlaceholder: string = ''
  @State resetButtonText: string = ''
  @State resettingText: string = ''

  aboutToAppear() {
    this.loadLanguageResources()
  }

  onPageShow(): void {
    console.info('[LoginPage] 页面显示，重新加载语言资源')
    this.loadLanguageResources()
  }

  private loadLanguageResources(): void {
    this.titleText = getContext(this).resourceManager.getStringSync($r('app.string.reset_password_title'))
    this.usernameLabel = getContext(this).resourceManager.getStringSync($r('app.string.username_label'))
    this.passwordLabel = getContext(this).resourceManager.getStringSync($r('app.string.password_label'))
    this.usernamePlaceholder = getContext(this).resourceManager.getStringSync($r('app.string.username_placeholder'))
    this.passwordPlaceholder = getContext(this).resourceManager.getStringSync($r('app.string.password_placeholder'))
    this.resetButtonText = getContext(this).resourceManager.getStringSync($r('app.string.reset_button_text'))
    this.resettingText = getContext(this).resourceManager.getStringSync($r('app.string.resetting_text'))
  }

  onChange(): void {
    const isClick: boolean = this.name.length >= 3 && this.pwd.length >= 6
    this.disabled = !isClick
  }

  build() {
    Column() {
      BaseNavigation({ title: this.titleText })
      Scroll() {
        Column() {
          this.body()
        }
        .margin(15)
      }
    }
  }

  @Builder
  body() {
    JhLoginTextInput({
      text: this.name,
      labelText: this.usernameLabel,
      placeholder: this.usernamePlaceholder,
      inputCallBack: (value: Object): void => {
        this.name = value as string
      },
    })
    Blank().height(8)
    JhLoginTextInput({
      text: this.pwd,
      labelText: this.passwordLabel,
      placeholder: this.passwordPlaceholder,
      isPwd: true,
      inputCallBack: (value: Object): void => {
        this.pwd = value as string
      },
    })
    JhButton({
      text: this.resetButtonText,
      disabled: this.disabled,
      onPressed: async (): Promise<void> => await this.clickBtn()
    })
      .margin({ top: 50, bottom: 30 })
  }

  async clickBtn(): Promise<void> {
    try {
      const resetResult: ResetPasswordResponse = await userApiService.resetPassword(
        this.name,
        this.pwd
      );

      if (resetResult.success) {
        JhProgressHUD.showSuccess($r('app.string.password_resets_success'));
        setTimeout((): void => {
          router.back();
        }, 1500);
      } else {
        JhProgressHUD.showError(resetResult.message);
      }
    } catch (error) {
      JhProgressHUD.showError($r('app.string.password_resets_failed'));
    }
  }
}