
///服药提醒页面

import router from '@ohos.router';
import dataPreferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

interface ReminderItem {
  id: string;
  name: string;
  dose: string;
  time: string;
  repeatType: string;
  priority: string;
  sound: string;
  taken: boolean;
}

interface SelectOption {
  value: string;
}

@Entry
@Component
struct MedicineReminder {
  @State medicineName: string = '';
  @State dosage: string = '';
  @State hour: string = '00';
  @State minute: string = '00';
  @State reminders: Array<ReminderItem> = [];
  @State repeatType: string = '';
  @State priority: string = '';
  @State stock: string = '';
  @State selectedSound: string = '';
  @State repeatOptions: SelectOption[] = [];
  @State priorityOptions: SelectOption[] = [];
  @State soundOptions: SelectOption[] = [];
  private preferences: dataPreferences.Preferences | null = null;
  private readonly STORE_NAME = 'MedicineReminder';
  private readonly REMINDERS_KEY = 'reminders';

  aboutToAppear() {
    this.initOptions();
    this.loadReminders();
    this.startReminderCheck();
  }

  initOptions() {
    this.repeatType = getContext(this).resourceManager.getStringSync($r('app.string.repeat_daily'));
    this.priority = getContext(this).resourceManager.getStringSync($r('app.string.priority_medium'));
    this.selectedSound = getContext(this).resourceManager.getStringSync($r('app.string.sound_default'));

    this.repeatOptions = [
      { value: getContext(this).resourceManager.getStringSync($r('app.string.repeat_daily')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.repeat_weekday')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.repeat_weekend')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.repeat_custom')) }
    ];

    this.priorityOptions = [
      { value: getContext(this).resourceManager.getStringSync($r('app.string.priority_high')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.priority_medium')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.priority_low')) }
    ];

    this.soundOptions = [
      { value: getContext(this).resourceManager.getStringSync($r('app.string.sound_default')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.sound_1')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.sound_2')) }
    ];
  }

  async loadReminders() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.preferences = await dataPreferences.getPreferences(context, this.STORE_NAME);
      const remindersStr = await this.preferences?.get(this.REMINDERS_KEY, '[]') ?? '[]';
      this.reminders = JSON.parse(remindersStr as string);
    } catch (err) {
      console.error('Failed to load reminders:', err);
    }
  }

  async saveReminders() {
    try {
      await this.preferences?.put(this.REMINDERS_KEY, JSON.stringify(this.reminders));
      await this.preferences?.flush();
    } catch (err) {
      console.error('Failed to save reminders:', err);
    }
  }

  addReminder() {
    if (!this.medicineName || !this.dosage) {
      promptAction.showToast({
        message: getContext(this).resourceManager.getStringSync($r('app.string.medicine_name_hint_2'))
      });
      return;
    }

    const reminder: ReminderItem = {
      id: Date.now().toString(),
      name: this.medicineName,
      dose: this.dosage,
      time: `${this.hour}:${this.minute}`,
      repeatType: this.repeatType,
      priority: this.priority,
      sound: this.selectedSound,
      taken: false
    };

    this.reminders.push(reminder);
    this.saveReminders();

    this.medicineName = '';
    this.dosage = '';
    this.hour = '00';
    this.minute = '00';
    this.repeatType = getContext(this).resourceManager.getStringSync($r('app.string.repeat_daily'));
    this.priority = getContext(this).resourceManager.getStringSync($r('app.string.priority_medium'));
    this.selectedSound = getContext(this).resourceManager.getStringSync($r('app.string.sound_default'));
  }

  deleteReminder(index: number) {
    this.reminders.splice(index, 1);
    this.saveReminders();
  }

  markAsTaken(index: number) {
    this.reminders[index].taken = !this.reminders[index].taken;
    this.saveReminders();
  }

  startReminderCheck() {
    setInterval(() => {
      const now = new Date();
      const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

      this.reminders.forEach(reminder => {
        if (reminder.time === currentTime) {
          promptAction.showDialog({
            title: getContext(this).resourceManager.getStringSync($r('app.string.reminder_title')),
            message: `${getContext(this).resourceManager.getStringSync($r('app.string.reminder_message'))}
药物: ${reminder.name}
剂量: ${reminder.dose}`,
            buttons: [{
              text: getContext(this).resourceManager.getStringSync($r('app.string.confirm_ok')),
              color: '#4285F4'
            }]
          });
        }
      });
    }, 60000);
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_back'))
            .width(20)
            .height(20)
        }
        .onClick(() => {
          try {
            router.back();
          } catch (err) {
            router.pushUrl({ url: 'pages/three/pages/WxDiscoverPage' });
          }
        })
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .margin({ left: 10, top: 10, bottom: 20 })
        Blank().layoutWeight(1)
        Text($r('app.string.medicine_reminder'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .margin({ top: 20, bottom: 20 })
        Blank().layoutWeight(1)
        Blank().width(40).height(40).margin({ right: 10 })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F8F8F8')

      Scroll() {
        Column() {
          Column() {
            Text($r('app.string.add_new_reminder'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 20 })
              .fontColor('#333333')
            TextInput({
              placeholder: getContext(this).resourceManager.getStringSync($r('app.string.medicine_name_placeholder')),
              text: this.medicineName
            })
              .onChange((value: string) => { this.medicineName = value; })
              .margin({ bottom: 12 })
              .width('90%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
            TextInput({
              placeholder: getContext(this).resourceManager.getStringSync($r('app.string.dosage_placeholder')),
              text: this.dosage
            })
              .onChange((value: string) => { this.dosage = value; })
              .margin({ bottom: 12 })
              .width('90%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
            Row() {
              Select(this.repeatOptions)
                .selected(this.repeatOptions.findIndex((option: SelectOption) => option.value === this.repeatType))
                .value(this.repeatType)
                .onSelect((index: number, value: string) => { this.repeatType = value; })
                .width('45%')
                .height(44)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
              Select(this.priorityOptions)
                .selected(this.priorityOptions.findIndex((option: SelectOption) => option.value === this.priority))
                .value(this.priority)
                .onSelect((index: number, value: string) => { this.priority = value; })
                .width('45%')
                .height(44)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
            }
            .width('90%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 12 })
            Row() {
              Select(this.soundOptions)
                .selected(this.soundOptions.findIndex((option: SelectOption) => option.value === this.selectedSound))
                .value(this.selectedSound)
                .onSelect((index: number, value: string) => { this.selectedSound = value; })
                .width('45%')
                .height(44)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
              Row() {
                Select([
                  { value: '00' }, { value: '01' }, { value: '02' }, { value: '03' },
                  { value: '04' }, { value: '05' }, { value: '06' }, { value: '07' },
                  { value: '08' }, { value: '09' }, { value: '10' }, { value: '11' },
                  { value: '12' }, { value: '13' }, { value: '14' }, { value: '15' },
                  { value: '16' }, { value: '17' }, { value: '18' }, { value: '19' },
                  { value: '20' }, { value: '21' }, { value: '22' }, { value: '23' }
                ])
                  .selected(['00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23'].indexOf(this.hour))
                  .value(this.hour)
                  .onSelect((index: number, value: string) => { this.hour = value; })
                  .width(60)
                  .height(44)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                Text(':')
                  .margin({ left: 5, right: 5 })
                  .fontColor('#333333')
                Select([
                  { value: '00' }, { value: '05' }, { value: '10' }, { value: '15' },
                  { value: '20' }, { value: '25' }, { value: '30' }, { value: '35' },
                  { value: '40' }, { value: '45' }, { value: '50' }, { value: '55' }
                ])
                  .selected(['00','05','10','15','20','25','30','35','40','45','50','55'].indexOf(this.minute))
                  .value(this.minute)
                  .onSelect((index: number, value: string) => { this.minute = value; })
                  .width(60)
                  .height(44)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
              }
              .width('45%')
            }
            .width('90%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
            Button($r('app.string.add_reminder_btn'))
              .onClick(() => this.addReminder())
              .width('90%')
              .height(44)
              .margin({ bottom: 20 })
              .backgroundColor('#4285F4')
              .fontColor(Color.White)
              .borderRadius(22)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(16)
          .margin({ top: 16, left: 16, right: 16 })
          .shadow({ radius: 8, color: '#1A000000', offsetY: 4 })

          Column() {
            Text($r('app.string.reminder_list'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 20 })
              .fontColor('#333333')
            List() {
              ForEach(this.reminders, (item: ReminderItem, index: number) => {
                ListItem() {
                  Row() {
                    Row() {
                      Circle()
                        .width(14)
                        .height(14)
                        .backgroundColor(item.priority === getContext(this).resourceManager.getStringSync($r('app.string.priority_high')) ? '#FF4B4B' :
                          (item.priority === getContext(this).resourceManager.getStringSync($r('app.string.priority_medium')) ? '#FFA500' : '#4CAF50'))
                        .margin({ right: 12 })
                      Column() {
                        Text(item.name)
                          .fontSize(20)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#222222')
                        Text(`${getContext(this).resourceManager.getStringSync($r('app.string.dosage_label'))}: ${item.dose}`)
                          .fontSize(13)
                          .margin({ top: 6 })
                          .fontColor('#888888')
                        Row() {
                          Text(`${getContext(this).resourceManager.getStringSync($r('app.string.time_label'))}: ${item.time}`)
                            .fontSize(13)
                            .fontColor('#888888')
                          Text(`(${item.repeatType})`)
                            .fontSize(13)
                            .fontColor('#888888')
                            .margin({ left: 8 })
                        }
                        .margin({ top: 4 })
                      }
                    }
                    .alignItems(VerticalAlign.Center)
                    .layoutWeight(1)
                    Column() {
                      Button({ type: ButtonType.Circle }) {
                        Image($r('app.media.ic_delete'))
                          .width(20)
                          .height(20)
                      }
                      .onClick(() => this.deleteReminder(index))
                      .width(40)
                      .height(40)
                      .backgroundColor('#FFE5E5')
                      .margin({ bottom: 8 })
                      Button({ type: ButtonType.Circle }) {
                        Image($r('app.media.ic_reminder'))
                          .width(20)
                          .height(20)
                      }
                      .onClick(() => this.markAsTaken(index))
                      .width(40)
                      .height(40)
                      .backgroundColor(item.taken ? '#E5FFE5' : '#F5F5F5')
                    }
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(Color.White)
                  .borderRadius(12)
                  .margin({ bottom: 12 })
                  .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
                }
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}