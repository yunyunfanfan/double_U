import { router } from '@kit.ArkUI'
import { BaseNavigation, JhTextList, ItemType, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

interface SecurityItem {
  icon: string
  title: Resource
  content: Resource
}

@Entry
@Preview
@Component
export struct DataSecurityPage {
  build() {
    Column() {
      BaseNavigation({ title: $r('app.string.data_security_title'), bgColor: Color.Transparent })

      Scroll() {
        Column({ space: 20 }) {
          this.BuildSecurityStatus()
          this.BuildEncryptionSection()
          this.BuildSecurityKnowledge()
        }
        .padding(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  private BuildNavigationBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text($r('app.string.data_security_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Button('返回')
        .margin({ left: 15 })
        .onClick(() => router.back())
        .position({ x: 0, y: 0 })
    }
    .width('100%')
    .height(50)
    .backgroundColor('#ff93d4cb')
  }

  @Builder
  private BuildSecurityStatus() {
    Column({ space: 10 }) {
      Text($r('app.string.security_status'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Row() {
        Progress({ value: 95, total: 100 })
          .width('70%')
          .color('#2ecc71')

        Text($r('app.string.enterprise_protection'))
          .fontColor('#27ae60')
          .margin({ left: 15 })
      }
      .padding(10)
      .backgroundColor('#f8f9fa')
      .borderRadius(8)
    }
  }

  @Builder
  private BuildEncryptionSection() {
    Column({ space: 10 }) {
      Text($r('app.string.encryption_measures'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2c3e50')

      Column() {
        this.BuildSecurityItem('🔐', $r('app.string.transmission_encryption'), $r('app.string.transmission_detail'), '#e8f6f3')
        this.BuildSecurityItem('🛡️', $r('app.string.storage_encryption'), $r('app.string.storage_detail'), '#f9f2e9')
        this.BuildSecurityItem('📁', $r('app.string.data_isolation'), $r('app.string.isolation_detail'), '#ebf5fb')
      }
    }
  }

  @Builder
  private BuildSecurityItem(icon: string, title: Resource, content: Resource, bgColor: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(24)
          .margin({ right: 10 })
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .margin({ bottom: 5 })

      Text(content)
        .fontSize(14)
        .fontColor('#666')
    }
    .padding(10)
    .backgroundColor(bgColor)
    .borderRadius(8)
    .width('100%')
    .margin({ bottom: 8 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private BuildSecurityKnowledge() {
    Column({ space: 15 }) {
      Text($r('app.string.security_guide'))
        .fontSize(20)
        .fontColor('#2c3e50')
        .fontWeight(FontWeight.Bold)

      this.BuildKnowledgeCard(
        $r('app.string.account_security'),
        [
          $r('app.string.enable_2fa'),
          $r('app.string.password_update'),
          $r('app.string.phone_verification'),
          $r('app.string.disable_simple_password')
        ],
        '#e8f6f3'
      )

      this.BuildKnowledgeCard(
        $r('app.string.data_sharing'),
        [
          $r('app.string.family_permissions'),
          $r('app.string.temporary_access'),
          $r('app.string.data_desensitization'),
          $r('app.string.access_audit')
        ],
        '#f9f2e9'
      )

      this.BuildKnowledgeCard(
        $r('app.string.risk_handling'),
        [
          $r('app.string.remote_wipe'),
          $r('app.string.login_alert'),
          $r('app.string.data_retention'),
          $r('app.string.security_report')
        ],
        '#ebf5fb'
      )
    }
    .padding(15)
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .shadow({ radius: 6, color: '#20000000' })
  }

  @Builder
  private BuildKnowledgeCard(
    title: Resource,
    tips: Resource[],
    color: string
  ) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(18)
        .fontColor('#2980b9')
        .margin({ bottom: 5 })

      Column() {
        ForEach(tips, (tip: Resource, index: number) => {
          Text(tip)
            .fontSize(16)
            .padding(8)
            .width('100%')
            .backgroundColor(color)
            .borderRadius(6)
            .margin({ bottom: 5 })
        })
      }
    }
    .width('100%')
    .padding(10)
  }
}