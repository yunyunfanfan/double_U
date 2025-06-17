//设置中的"关于"页面
import { router } from '@kit.ArkUI'
import { BaseNavigation, JhTextList, ItemType, JhSetCell, JhProgressHUD, JhAESPreferencesUtils, kUserDefault_UserInfo, JhAlert } from 'JhCommon'

@Entry
@Preview
@Component
export struct PointsPage {
  aboutToAppear() {
    console.info('[关于页面] 页面初始化完成');
  }

  build() {
    Column() {
      BaseNavigation({ title: '关于应用', bgColor: Color.Transparent })

      Scroll() {
        Column({ space: 20 }) {
          Text('家庭健康管理系统')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a1a1a')
            .margin({ top: 20 })

          Text('运行环境与技术栈')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('90%')
            .textAlign(TextAlign.Start)

          Text('基于HarmonyOS NEXT开发，采用ArkTS语言构建，集成DeepSeek AI技术，提供智能化家庭健康管理解决方案。')
            .width('90%')

          this.buildSection('核心功能', '提供完整的家庭健康数据管理服务，包括健康数据录入、实时监控、家庭成员互联、健康趋势分析等核心功能，帮助家庭成员共同维护健康生活。')

          this.buildSection('AI智能助手', '集成DeepSeek技术的专属客服系统，支持流式输出和Markdown格式显示。特色猫娘助手提供有趣的交互体验，协助用户快速录入健康数据和解答使用问题。')

          this.buildSection('健康数据管理', '支持心率、血氧、步数、热量、睡眠、心情等多维度健康数据录入。自动识别时间戳，区分实时数据和日常数据。提供一周趋势分析和历史数据查询。')

          this.buildSection('家庭互联功能', '创新的家庭成员添加方式：雷达扫描、面对面四位数匹配、手机号搜索。支持查看家庭成员的所有健康数据，建立双向健康监督机制。')

          this.buildSection('激励机制', '健康积分系统鼓励用户坚持记录数据。全用户排行榜展示步数和积分排名，增强用户参与度和竞争意识，营造健康生活氛围。')

          this.buildSection('个性化体验', '支持头像上传、用户名修改、主题切换、多语言设置。提供服药提醒通知和助眠音乐播放功能，全方位关注用户健康需求。')

          this.buildSection('数据同步', '四个主页面均支持下拉刷新，实时同步最新数据。登录状态持久化保存，重启应用无需重复登录，提升用户使用体验。')

          Text('数据安全承诺：我们采用加密存储和传输技术保护您的健康隐私数据，支持账户删除和数据清理功能。您的健康数据完全由您自主控制。')
            .width('90%')
            .fontColor('#666')
            .margin({ top: 30, bottom: 50 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  private buildSection(title: string, content: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .width('90%')
        .textAlign(TextAlign.Start)
        .fontColor('#2c3e50')

      Text(content)
        .fontSize(16)
        .width('90%')
        .textAlign(TextAlign.Start)
        .fontColor('#666')
        .padding(10)
        .backgroundColor('#f8f9fa')
        .borderRadius(8)
    }
    .width('100%')
    .margin({ top: 10 })
  }
}