import { BaseNavigation, JhProgressHUD, KColors } from 'JhCommon'
import { router } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'

interface HealthInfoItem {
  labelResource: Resource
  valueResource: Resource
}

interface MedicalRecord {
  id: string
  date: string
  hospital: string
  department: string
  doctor: string
  diagnosis: string
  treatment: string
}

@CustomDialog
struct AddRecordDialog {
  controller?: CustomDialogController
  @Link newRecord: MedicalRecord
  onSaveCallback: () => void = () => {}
  onCancelCallback: () => void = () => {}

  aboutToAppear(): void {
    hilog.info(0x0000, 'AddRecordDialog', '对话框初始化完成')
  }

  @Builder
  inputField(labelResource: Resource, value: string, onChange: (value: string) => void) {
    Column() {
      Text(labelResource)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 5 })

      TextInput({ text: value })
        .width('100%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(5)
        .padding(10)
        .onChange((value: string) => {
          onChange(value)
        })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ bottom: 10 })
  }

  build() {
    Column() {
      Text($r('app.string.add_medical_record'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      this.inputField($r('app.string.visit_date'), this.newRecord.date, (value: string) => {
        this.newRecord.date = value
      })
      this.inputField($r('app.string.hospital_name'), this.newRecord.hospital, (value: string) => {
        this.newRecord.hospital = value
      })
      this.inputField($r('app.string.department'), this.newRecord.department, (value: string) => {
        this.newRecord.department = value
      })
      this.inputField($r('app.string.doctor_name'), this.newRecord.doctor, (value: string) => {
        this.newRecord.doctor = value
      })
      this.inputField($r('app.string.diagnosis'), this.newRecord.diagnosis, (value: string) => {
        this.newRecord.diagnosis = value
      })
      this.inputField($r('app.string.treatment'), this.newRecord.treatment, (value: string) => {
        this.newRecord.treatment = value
      })

      Row() {
        Button($r('app.string.cancel'))
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .width(120)
          .height(40)
          .margin({ right: 20 })
          .onClick(() => {
            this.onCancelCallback()
            this.controller?.close()
          })

        Button($r('app.string.save'))
          .backgroundColor('#1698CE')
          .fontColor(Color.White)
          .width(120)
          .height(40)
          .onClick(() => {
            this.onSaveCallback()
          })
      }
      .margin({ top: 30 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .width('90%')
  }
}

@Entry
@Component
export struct HealthRecordsPage {
  @State currentTab: number = 0
  @State medicalRecordList: MedicalRecord[] = []
  @State selectedCategoryIndex: number = 0

  @State newRecord: MedicalRecord = {
    id: '',
    date: this.getCurrentDate(),
    hospital: '',
    department: '',
    doctor: '',
    diagnosis: '',
    treatment: ''
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddRecordDialog({
      newRecord: $newRecord,
      onSaveCallback: () => this.handleSaveRecord(),
      onCancelCallback: () => this.handleCancelAddRecord()
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  })

  aboutToAppear(): void {
    hilog.info(0x0000, 'HealthRecordsPage', '页面初始化开始')
    this.loadSampleRecords()
    hilog.info(0x0000, 'HealthRecordsPage', '页面初始化完成')
  }

  loadSampleRecords(): void {
    if (this.medicalRecordList.length === 0) {
      this.medicalRecordList = []
      hilog.info(0x0000, 'HealthRecordsPage', '示例记录初始化完成')
    }
  }

  getCurrentDate(): string {
    return new Date().toISOString().split('T')[0]
  }

  generateId(): string {
    return Date.now().toString()
  }

  handleSaveRecord(): void {
    hilog.info(0x0000, 'HealthRecordsPage', '开始保存记录')
    if (!this.newRecord.hospital || !this.newRecord.department) {
      JhProgressHUD.showText('请填写医院名称和科室')
      return
    }

    this.medicalRecordList.push({
      id: this.generateId(),
      date: this.newRecord.date,
      hospital: this.newRecord.hospital,
      department: this.newRecord.department,
      doctor: this.newRecord.doctor,
      diagnosis: this.newRecord.diagnosis,
      treatment: this.newRecord.treatment
    })

    JhProgressHUD.showText('记录添加成功')
    this.resetNewRecord()
    this.dialogController.close()
    hilog.info(0x0000, 'HealthRecordsPage', '记录保存成功')
  }

  handleCancelAddRecord(): void {
    this.resetNewRecord()
    hilog.info(0x0000, 'HealthRecordsPage', '取消添加记录')
  }

  resetNewRecord(): void {
    this.newRecord = {
      id: '',
      date: this.getCurrentDate(),
      hospital: '',
      department: '',
      doctor: '',
      diagnosis: '',
      treatment: ''
    }
  }

  build() {
    Column() {
      BaseNavigation({
        title: $r('app.string.health_records_title'),
        bgColor: Color.White,
      })

      Scroll() {
        Row() {
          Button($r('app.string.basic_health'))
            .onClick(() => {
              this.selectedCategoryIndex = 0
              this.currentTab = 0
              hilog.info(0x0000, 'HealthRecordsPage', '切换到基础健康')
            })
            .height(36)
            .constraintSize({ minWidth: 80, maxWidth: 120 })
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.selectedCategoryIndex === 0 ? '#4285F4' : '#F5F5F5')
            .fontColor(this.selectedCategoryIndex === 0 ? Color.White : '#222222')
            .fontWeight(this.selectedCategoryIndex === 0 ? FontWeight.Bold : FontWeight.Normal)
            .fontSize(14)
            .borderRadius(18)
            .margin({ right: 8 })

          Button($r('app.string.medical_records'))
            .onClick(() => {
              this.selectedCategoryIndex = 1
              this.currentTab = 1
              hilog.info(0x0000, 'HealthRecordsPage', '切换到就诊记录')
            })
            .height(36)
            .constraintSize({ minWidth: 80, maxWidth: 140 })
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.selectedCategoryIndex === 1 ? '#4285F4' : '#F5F5F5')
            .fontColor(this.selectedCategoryIndex === 1 ? Color.White : '#222222')
            .fontWeight(this.selectedCategoryIndex === 1 ? FontWeight.Bold : FontWeight.Normal)
            .fontSize(14)
            .borderRadius(18)
            .margin({ right: 8 })

          Button($r('app.string.health_data'))
            .onClick(() => {
              this.selectedCategoryIndex = 2
              this.currentTab = 2
              hilog.info(0x0000, 'HealthRecordsPage', '切换到健康数据')
            })
            .height(36)
            .constraintSize({ minWidth: 80, maxWidth: 120 })
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.selectedCategoryIndex === 2 ? '#4285F4' : '#F5F5F5')
            .fontColor(this.selectedCategoryIndex === 2 ? Color.White : '#222222')
            .fontWeight(this.selectedCategoryIndex === 2 ? FontWeight.Bold : FontWeight.Normal)
            .fontSize(14)
            .borderRadius(18)
        }
        .padding({ bottom: 10 })
        // .constraintSize({ minWidth: 120, maxWidth: '95%' })
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .scrollable(ScrollDirection.Horizontal)
      .width('100%')
      .backgroundColor(Color.White)

      if (this.currentTab === 0) {
        this.basicHealthInfo()
      } else if (this.currentTab === 1) {
        this.medicalRecordsTab()
      } else if (this.currentTab === 2) {
        this.healthData()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(KColors.wxBgColor)
  }

  @Builder
  basicHealthInfo() {
    Scroll() {
      Column() {
        this.infoCard($r('app.string.personal_info'), [
          { labelResource: $r('app.string.name_name'), valueResource: $r('app.string.patient_name') } as HealthInfoItem,
          { labelResource: $r('app.string.gender'), valueResource: $r('app.string.male') } as HealthInfoItem,
          { labelResource: $r('app.string.age'), valueResource: $r('app.string.age_value') } as HealthInfoItem,
          { labelResource: $r('app.string.height'), valueResource: $r('app.string.height_value') } as HealthInfoItem,
          { labelResource: $r('app.string.weight'), valueResource: $r('app.string.weight_value') } as HealthInfoItem
        ])

        this.infoCard($r('app.string.emergency_contact'), [
          { labelResource: $r('app.string.contact_person'), valueResource: $r('app.string.contact_name') } as HealthInfoItem,
          { labelResource: $r('app.string.relationship'), valueResource: $r('app.string.family') } as HealthInfoItem,
          { labelResource: $r('app.string.contact_phone'), valueResource: $r('app.string.contact_number') } as HealthInfoItem
        ])

        this.infoCard($r('app.string.allergy_history'), [
          { labelResource: $r('app.string.drug_allergy'), valueResource: $r('app.string.none') } as HealthInfoItem,
          { labelResource: $r('app.string.food_allergy'), valueResource: $r('app.string.none') } as HealthInfoItem
        ])
      }
      .width('100%')
      .padding({ top: 8, bottom: 20 })
    }
    .width('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  medicalRecordsTab() {
    Scroll() {
      Column() {
        if (this.medicalRecordList.length === 0) {
          Text($r('app.string.no_medical_records'))
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 30 })

          Button($r('app.string.add_medical_record'))
            .width(200)
            .height(40)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#1698CE')
            .borderRadius(20)
            .margin({ top: 20 })
            .onClick(() => {
              this.dialogController.open()
              hilog.info(0x0000, 'HealthRecordsPage', '打开添加记录对话框')
            })
        } else {
          Row() {
            Text($r('app.string.my_medical_records'))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .padding({ left: 15 })

            Blank()

            Button($r('app.string.add_record'))
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor('#1698CE')
              .borderRadius(15)
              .height(30)
              .margin({ right: 15 })
              .onClick(() => {
                this.dialogController.open()
                hilog.info(0x0000, 'HealthRecordsPage', '打开添加记录对话框')
              })
          }
          .width('100%')
          .padding({ top: 15, bottom: 10 })

          ForEach(this.medicalRecordList, (record: MedicalRecord) => {
            this.medicalRecordCard(record)
          })
        }
      }
      .width('100%')
      .padding({ top: 8, bottom: 20 })
    }
    .backgroundColor('#F5F5F5')
  }

  @Builder
  medicalRecordCard(record: MedicalRecord) {
    Column() {
      Row() {
        Text(record.date)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)

        Blank()

        Text(record.hospital)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 15 })

      Divider()
        .width('94%')
        .height(1)
        .margin({ top: 10, bottom: 10 })
        .backgroundColor('#EEEEEE')

      Row() {
        Column() {
          Text($r('app.string.visiting_department'))
            .fontSize(14)
            .fontColor('#999999')
          Text(record.department)
            .fontSize(15)
            .fontColor('#333333')
            .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text($r('app.string.attending_doctor'))
            .fontSize(14)
            .fontColor('#999999')
          Text(record.doctor)
            .fontSize(15)
            .fontColor('#333333')
            .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 15, right: 15 })

      Row() {
        Column() {
          Text($r('app.string.diagnosis'))
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 10 })
          Text(record.diagnosis)
            .fontSize(15)
            .fontColor('#333333')
            .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .width('100%')
      .padding({ left: 15, right: 15 })

      Row() {
        Column() {
          Text($r('app.string.treatment'))
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 10 })
          Text(record.treatment)
            .fontSize(15)
            .fontColor('#333333')
            .margin({ top: 5, bottom: 15 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .width('100%')
      .padding({ left: 15, right: 15 })
    }
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ left: 15, right: 15, top: 10 })
  }

  @Builder
  healthData() {
    Scroll() {
      Column() {
        this.dataCard($r('app.string.recent_blood_pressure'), $r('app.string.blood_pressure_value'), $r('app.string.normal'), true)
        this.dataCard($r('app.string.recent_blood_sugar'), $r('app.string.blood_sugar_value'), $r('app.string.normal'), true)
        this.dataCard($r('app.string.recent_heart_rate'), $r('app.string.heart_rate_value'), $r('app.string.normal'), true)
        this.dataCard($r('app.string.bmi_index'), $r('app.string.bmi_value'), $r('app.string.normal'), true)

        Button($r('app.string.view_more_health_data'))
          .constraintSize({ minWidth: 120, maxWidth: '80%' })
          .height(40)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#1698CE')
          .borderRadius(20)
          .margin({ top: 30, bottom: 50 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/four/pages/health/MoreHealthDataPage' })
            hilog.info(0x0000, 'HealthRecordsPage', '跳转到更多健康数据页面')
          })
      }
      .width('100%')
      .padding({ top: 8, bottom: 20 })
    }
    .backgroundColor('#F5F5F5')
  }

  @Builder
  infoCard(titleResource: Resource, items: HealthInfoItem[]) {
    Column() {
      Row() {
        Divider()
          .vertical(true)
          .height(16)
          .width(3)
          .backgroundColor('#1698CE')
          .margin({ right: 5 })
        Text(titleResource)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({ left: 15, top: 15, bottom: 10 })
      .alignItems(VerticalAlign.Center)

      ForEach(items, (item: HealthInfoItem) => {
        Row() {
          Text(item.labelResource)
            .fontSize(15)
            .fontColor('#666666')
            .width('30%')
          Text(item.valueResource)
            .fontSize(15)
            .fontColor('#333333')
        }
        .width('100%')
        .padding({ left: 15, right: 15, top: 10, bottom: 10 })
        .justifyContent(FlexAlign.SpaceBetween)
      })
    }
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ left: 15, right: 15, top: 10 })
  }

  @Builder
  dataCard(titleResource: Resource, value: Resource, statusResource: Resource, isNormal: boolean) {
    Row() {
      Column() {
        Text(titleResource)
          .fontSize(16)
          .fontColor('#666666')
        Text(value)
          .fontSize(20)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)

      Text(statusResource)
        .fontSize(14)
        .fontColor(isNormal ? '#1698CE' : '#FF6B6B')
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .borderRadius(15)
        .backgroundColor(isNormal ? '#E6F7FF' : '#FFEDED')
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 15, bottom: 15 })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ left: 15, right: 15, top: 10 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}