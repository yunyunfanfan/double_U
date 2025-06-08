import router from '@ohos.router';

//看起来想要做会员权益页面

interface BenefitCategory {
  title: Resource
  benefits: Resource[]
}

@Entry
@Component
struct MembershipPage {
  private benefitCategories: BenefitCategory[] = [
    {
      title: $r('app.string.course_learning'),
      benefits: [
        $r('app.string.free_courses'),
        $r('app.string.course_updates'),
        $r('app.string.progress_save')
      ]
    },
    {
      title: $r('app.string.expert_consultation'),
      benefits: [
        $r('app.string.weekly_consultation'),
        $r('app.string.detailed_answers'),
        $r('app.string.reply_guarantee')
      ]
    },
    {
      title: $r('app.string.learning_materials'),
      benefits: [
        $r('app.string.hd_video_download'),
        $r('app.string.exclusive_guide'),
        $r('app.string.exercises_answers'),
        $r('app.string.material_updates')
      ]
    },
    {
      title: $r('app.string.community_interaction'),
      benefits: [
        $r('app.string.topic_discussion'),
        $r('app.string.share_experience'),
        $r('app.string.exclusive_badge'),
        $r('app.string.offline_priority')
      ]
    },
    {
      title: $r('app.string.exclusive_service'),
      benefits: [
        $r('app.string.personalized_plan'),
        $r('app.string.progress_tracking'),
        $r('app.string.exclusive_report'),
        $r('app.string.one_on_one_tutoring')
      ]
    },
    {
      title: $r('app.string.certification_service'),
      benefits: [
        $r('app.string.completion_certificate'),
        $r('app.string.skill_certification'),
        $r('app.string.certificate_storage'),
        $r('app.string.job_recommendation')
      ]
    }
  ]

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($rawfile("images/memberRights.png"))
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .opacity(0.8)

        Column() {
          Text($r('app.string.membership_benefits_title'))
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 90, left: 20 })
        }
      }
      .width('100%')
      .height(180)

      Column() {
        Text($r('app.string.membership_privileges_services'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 25, left: 20, bottom: 15 })
          .width('100%')
          .textAlign(TextAlign.Start)

        Text($r('app.string.membership_intro'))
          .fontSize(16)
          .fontColor('#666666')
          .margin({ left: 20, right: 20, bottom: 15 })

        Column() {
          ForEach(this.benefitCategories, (category: BenefitCategory, index: number) => {
            this.BuildBenefitCategory(category)
          })
        }
        .width('90%')
        .padding(15)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .shadow({ radius: 3, color: '#EEEEEE' })
      }
      .width('100%')
      .padding({ left: '5%', right: '5%', top: 10, bottom: 20 })

      Button($r('app.string.activate_membership'))
        .width('90%')
        .height(50)
        .backgroundColor('#1E90FF')
        .fontColor('#FFFFFF')
        .fontSize(18)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/PaymentPage'
          });
        })
        .margin({ top: 20, bottom: 30 })

      Text($r('app.string.copyright_text'))
        .fontSize(12)
        .fontColor('#999999')
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  private BuildBenefitCategory(category: BenefitCategory) {
    Column() {
      Text(category.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 10, bottom: 5 })

      ForEach(category.benefits, (benefit: Resource, index: number) => {
        Text(benefit)
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 3 })
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 10 })
  }
}