import router from '@ohos.router';
import dataPreferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { notificationManager } from '@kit.NotificationKit';
import NotificationManager from '@ohos.notificationManager';
import Base from '@ohos.base';
import { hilog } from '@kit.PerformanceAnalysisKit';



let requestEnableNotificationCallback = (err: Base.BusinessError): void => {
  if (err) {
    console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
  } else {
    console.info("requestEnableNotification success");
  }
};



function getRecentDays(): string[] {
  const oneDay = 24 * 60 * 60 * 1000;
  const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']; // 中文星期数组
  const resultArray: string[] = [];

  for (let i = 0; i <= 6; i++) {
    const currentDate = new Date(Date.now() + i * oneDay);
    const year = currentDate.getFullYear();
    const month = String(currentDate.getMonth() + 1).padStart(2, "0");
    const day = String(currentDate.getDate()).padStart(2, "0");
    const weekDay = weekDays[currentDate.getDay()]; // 获取星期索引(0-6)
    const formattedDate:string = `${year}年${month}月${day}日 ${weekDay}`; // 添加星期显示
    resultArray.push(formattedDate);
  }
  return resultArray;
}

interface Yaowu {
  name: string;
  jiliang: string;
  time: string;
  remark: string;
}


@CustomDialog
@Component
struct  addDialog {

  text: string = ''
  controller?: CustomDialogController
  clickChild: (str: string, str2: string,str3: string,str4: string,) => void = () => {}
  // dbManager: relationalStore.RdbStore | null
  @State username: string = ''
  @State password: string = ''
  @State selectedTime: Date = new Date('2022-07-22T08:00:00');
  // @State img: string = ''
  @State name: string = ''
  @State jiliang: string = ''
  // @State username: string = ''
  @State remark: string = ''

  aboutToAppear(): void {
    // 申请通知权限
    NotificationManager.requestEnableNotification(requestEnableNotificationCallback);
  }
  build() {
    Column() {
      Row() {
        Button('取消')
          .onClick(() => {
            this.controller?.close()
          })
        Button('确定').onClick(() => {
          let temp: Date = this.selectedTime
          this.clickChild(this.name, this.jiliang, `${String(temp.getHours()).padStart(2, "0")}:${String(temp.getMinutes()).padStart(2, "0")}`, this.remark)
          this.controller?.close()
        })
      }
      .width('100%')
      .margin({bottom: '20lpx'})
      .justifyContent(FlexAlign.SpaceBetween)

      // 名称 剂量（粒片ml） 时间（时分）  备注 是否服用 服用时间
      Row() {
        Text('药物名称').fontSize('28lpx').margin({ right: '2lpx' }).width('24%')
        TextInput( {
          placeholder: '请输入药物名称'
        })
          .width('70%')
          .onChange(async(val: string) => {
            this.name = val
          })
          .margin({bottom: '20lpx'})
      }
      .padding('20lpx')
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      .margin({bottom: '20lpx'})


      Row() {
        Text('药物剂量').fontSize('28lpx').margin({ right: '2lpx' }).width('24%')
        TextInput({
          placeholder: '请输入药物剂量(如1片/2粒/5毫升)'
        }).width('70%')
          .onChange(async (val: string) => {
            this.jiliang = val
          })
          .margin({ bottom: '20lpx' })
      }
      .padding('20lpx')
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      .margin({bottom: '20lpx'})


      Row() {
        Text('预约时间').fontSize('28lpx').margin({right: '2lpx'}).width('24%')
        Column() {
          Row() {
            TimePicker({
              selected: this.selectedTime
            }).width('70%')
              .disappearTextStyle({ color: '#004aaf', font: { size: 24, weight: FontWeight.Lighter } })
              .textStyle({ color: Color.Black, font: { size: 26, weight: FontWeight.Normal } })
              .selectedTextStyle({ color: Color.Blue, font: { size: 30, weight: FontWeight.Bolder } })
              .onChange((value: TimePickerResult) => {
                if (value.hour >= 0) {
                  this.selectedTime.setHours(value.hour, value.minute);
                  console.info('select current date is: ' + JSON.stringify(value));
                }
              })
          }
          .width('100%')
        }
      }
      .padding('20lpx')
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      .margin({bottom: '20lpx'})


      Row() {
        Text('备注').fontSize('28lpx').margin({ right: '2lpx' }).width('24%')
        TextInput( {
          placeholder: '请输入备注'
        }).width('70%')
          .onChange(async(val: string) => {
            this.remark = val
          })
          .margin({bottom: '20lpx'})
      }
      .padding('20lpx')
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      .margin({bottom: '20lpx'})


    }
    .padding('30lpx')
  }
}

@Entry
@Component
struct MedicineReminder {
  @State medicineName: string = '';
  @State dosage: string = '';
  @State hour: string = '00';
  @State minute: string = '00';
  @State reminders: Array<ReminderItem> = [];
  @State repeatType: string = '每天';
  @State priority: string = '中优先级';
  @State stock: string = '';
  @State selectedSound: string = '默认铃声';
  private preferences: dataPreferences.Preferences | null = null;
  private readonly STORE_NAME = 'MedicineReminder';
  private readonly REMINDERS_KEY = 'reminders';
  @State dateTime: string = ''
  @State list: Yaowu[] = [

  ]
  @State showList: Yaowu[] = [
  ]
  @State searchIpt: string = ''
  @State count: number = 1

  aboutToAppear() {
    this.dateTime = getRecentDays()[0]
    // 初始化数据
    // this.showList = [...this.list]
    this.loadReminders();
    // this.startReminderCheck();
  }

  async loadReminders() {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.preferences = await dataPreferences.getPreferences(context, this.STORE_NAME);
      const remindersStr = await this.preferences?.get(this.REMINDERS_KEY, '[]') ?? '[]';
      let firstList:Yaowu[] = [{
        name: '阿司匹林肠溶片',
        jiliang: '剂量:100mgx1片',
        time: '09:30',
        remark: '每日一次'
      }]
      let list = JSON.parse(remindersStr as string) as Yaowu[]
      if(Array.isArray(list) && list.length) {
        this.list = list
        this.showList = list
      } else {
        this.list = firstList
        this.showList = firstList
      }

    } catch (err) {
      console.error('Failed to load reminders:', err);
    }
  }

  async saveReminders() {
    try {
      await this.preferences?.put(this.REMINDERS_KEY, JSON.stringify(this.list));
      await this.preferences?.flush();
    } catch (err) {
      console.error('Failed to save reminders:', err);
    }
  }

  addReminder() {
    if (!this.medicineName || !this.dosage) {
      promptAction.showToast({ message: $r('app.string.medicine_name_hint') });
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

    // 重置输入
    this.medicineName = '';
    this.dosage = '';
    this.hour = '00';
    this.minute = '00';
    this.repeatType = '每天';
    this.priority = '中优先级';
    this.selectedSound = '默认铃声';
  }

  deleteReminder(index: number) {
    this.reminders.splice(index, 1);
    this.saveReminders();
  }

  startReminderCheck() {
    setInterval(() => {
      const now = new Date();
      const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

      this.reminders.forEach(reminder => {
        if (reminder.time === currentTime) {
          promptAction.showDialog({
            title: $r('app.string.reminder_title'),
            message: `${$r('app.string.reminder_message')}
药物: ${reminder.name}
剂量: ${reminder.dose}`,
            buttons: [{ text: $r('app.string.confirm'), color: $r('app.color.primary_color') }]
          });
        }
      });
    }, 60000);
  }

  dialog: CustomDialogController = new CustomDialogController({
    builder: addDialog({
      clickChild: (name: string, jiliang: string, time: string, remark: string) => {
        //
        if(!name) {
          promptAction.showToast({message: '名称不能为空'})
          return;
        }
        if(!jiliang) {
          promptAction.showToast({message: '剂量不能为空'})
          return;
        }
        if(!time) {
          promptAction.showToast({message: '时间不能为空'})
          return;
        }
        if(!remark) {
          promptAction.showToast({message: '备注不能为空'})
          return;
        }
        //
        let item: Yaowu = {
          name,
          jiliang,
          time,
          remark,
        }
        this.list = [...this.list, item ]
        this.showList = [...this.showList, item ]
        this.saveReminders()
        //
        // this.list2 = [item, ...this.list2]
        // promptAction.showToast({message: this.list2.length+'添加成功数据'+JSON.stringify(item)})
        this.dialog.close()
        this.count++
        let notificationRequest: NotificationManager.NotificationRequest = {
          id: this.count,
          content: {
            notificationContentType: NotificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
            normal: {
              title: "该吃药了",
              text: item.name,
              additionalText: "1片"
            }
          }
        }

        NotificationManager.publish(notificationRequest, (err) => {
          if (err) {
            // 1600004	Notification is not enabled.
            hilog.info(0x000, 'notification111', JSON.stringify(err))
            console.error(`[ANS] failed to publish, error[${err}]`);
            return;
          }
          hilog.info(0x000, 'notification111', '成功')
          console.info(`[ANS] publish success`);
        });

      },
    }),
    alignment: DialogAlignment.Center,
    width: '90%',
    height: '80%',
    maskColor: 'rgba(0,0,0,0.7)'
  })

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r('app.media.ic_back'))
            .width(20)
            .height(20)
        }
        .onClick(() => {
          try {
            router.back();
          } catch (err) {
            console.error('Failed to go back:', err);
            router.pushUrl({ url: 'pages/three/pages/WxDiscoverPage' });
          }
        })
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .margin({ left: 10, top: 10, bottom: 20 })
        Blank().layoutWeight(1)
        Text('服药提醒')
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

      // 服药计划卡片
      Column() {
        Row() {
          Text('今日服药提醒').fontSize('38lpx').fontColor(Color.White).margin({right: '5lpx'})
          Text(`${this.list.length}个提醒`).padding('5lpx').backgroundColor('#fff').borderRadius('20lpx').fontSize('28lpx').fontColor('#4086F6')
          Blank()
          Text(this.dateTime).fontSize('28lpx').fontColor(Color.White)
        }
        .width('100%')
        .padding('20lpx')
        .justifyContent(FlexAlign.Center)
        Row() {
          Row() {
            Image($r('app.media.reminder_yaowutitle')).width('70lpx').height('70lpx')
          }.width('100lpx').height('100lpx').borderRadius('50%').backgroundColor('#fff')
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
          .margin({right: '20lpx'})
          Column() {
            Text(this.list[0] && this.list[0].name).fontColor(Color.White).fontSize('38lpx').margin({bottom: '20lpx'})
            Text(this.list[0] && this.list[0].jiliang).fontColor('#eee').fontSize('32lpx')
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)
          Text(this.list[0] && this.list[0].time).fontWeight(FontWeight.Bold).fontColor(Color.White).fontSize('38lpx')
        }.width('100%')
        .padding('20lpx')
        .backgroundColor('rgba(255,255,255,0.02)')
      }.shadow({
        radius: 8,
        color: 'rgba(0,0,0,0.05)',
        offsetX: 0,
        offsetY: 3,
      })
      .margin({bottom: '10lpx'})
      .backgroundColor('#4086F6')

      // 搜索栏目
      Row() {
        TextInput({placeholder: "搜索药品名称"}).width('40%').onChange((str: string) => {
          this.showList = this.list.filter(item => {
            return item.name.includes(str)
          })
        })
        Blank()
        Row() {
          Image($r('app.media.reminder_flag')).width('30lpx').height('30lpx').margin({right: '20lpx'})
          Text('全部提醒').fontSize('32lpx')
        }
        .padding('10lpx')
        .backgroundColor('#fff')
        .borderRadius('20lpx')
        .border({width: '1lpx', color: '#4086F6'})
        .margin({right: '10lpx'})
        .onClick(() => {
          let requestEnableNotificationCallback = (err: Base.BusinessError): void => {
            if (err) {
              console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
            } else {
              console.info("requestEnableNotification success");
            }
          };
          // 申请通知权限
          this.count++
          let str2: string[] = []
          this.list.forEach((item) => {
            str2.push(item.name)
          })
          NotificationManager.requestEnableNotification(requestEnableNotificationCallback);
          let notificationRequest: NotificationManager.NotificationRequest = {
            id: this.count,
            content: {
              notificationContentType: NotificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
              normal: {
                title: "该吃药了",
                text: str2.join('，'),
                additionalText: "1片"
              }
            }
          }
          NotificationManager.publish(notificationRequest, (err) => {
            if (err) {
              // 1600004	Notification is not enabled.
              hilog.info(0x000, 'notification111', JSON.stringify(err))
              console.error(`[ANS] failed to publish, error[${err}]`);
              return;
            }
            hilog.info(0x000, 'notification111', '成功')
            console.info(`[ANS] publish success`);
          });
        })
        Row() {
          Image($r('app.media.reminder_add')).width('30lpx').height('30lpx').margin({right: '10lpx'})
          Text('添加提醒').fontColor(Color.White).fontSize('32lpx')
        }.backgroundColor('#4086F6').padding('10lpx')
        .borderRadius('20lpx')
        .onClick(async () => {
          this.dialog.open()
          let requestEnableNotificationCallback = (err: Base.BusinessError): void => {
            if (err) {
              console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
            } else {
              console.info("requestEnableNotification success");
            }
          };
          // 申请通知权限
          NotificationManager.requestEnableNotification(requestEnableNotificationCallback);


        })
      }
      .width('100%')
      .padding('20lpx')
      .backgroundColor('#fff')
      .borderRadius('10lpx')
      .justifyContent(FlexAlign.Center)
      .shadow({
        radius: 8,
        color: 'rgba(0,0,0,0.05)',
        offsetX: 0,
        offsetY: 3,
      })
      .margin({bottom: '10lpx'})

      // 主要内容区域
      Scroll() {
        Column() {
          ForEach(this.showList, (item: Yaowu) => {
            Column() {
              Row() {
                Image($r('app.media.reminder_yaowumingcheng')).width('40lpx').height('40lpx').margin({right: '20lpx'})
                Text(item.name).fontWeight(FontWeight.Bold).fontSize('38lpx')
                Blank()
                Text(item.time).backgroundColor('rgba(108, 92, 231, 0.08)').padding('20lpx').borderRadius('20lpx')
              }
              .width('100%')
              .padding('20lpx')
              .justifyContent(FlexAlign.Center)
              Row() {
                Image($r('app.media.reminder_jiliang2')).width('40lpx').height('40lpx').margin({right: '20lpx'})
                Text(item.jiliang).fontColor(Color.Black).fontSize('32lpx')
              }
              .width('100%')
              .padding('20lpx')
              Row() {
                Image($r('app.media.reminder_jiliang2')).width('40lpx').height('40lpx').margin({right: '20lpx'}).visibility(Visibility.Hidden)
                Text(item.remark).fontColor(Color.Black).fontSize('32lpx')
              }
              .width('100%')
              .padding('20lpx')

              Row() {
                Row() {
                  Image($r('app.media.reminder_dagou')).width('30lpx').height('30lpx').margin({right: '20lpx'})
                  Text('标记已服用').fontColor(Color.White).fontSize('32lpx')
                }
                .width('200lpx')
                .height('40lpx')
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)
                .borderRadius('20lpx')
              }
              .position({bottom: '30lpx', right: '30lpx'})
            }
            .backgroundColor('#fff')
            .borderRadius('10lpx')
            .border({color: '#4086F6', width: {left: '6lpx'}})
            .shadow({
              radius: 8,
              color: 'rgba(0,0,0,0.05)',
              offsetX: 0,
              offsetY: 3,
            })
            .margin({bottom: '20lpx'})
          })
        }.padding('20lpx')
      }.layoutWeight(1)
      .align(Alignment.Top)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }

  private getRepeatTypeText(type: string): string {
    switch (type) {
      case 'daily':
        return '每天';
      case 'weekday':
        return '工作日';
      case 'weekend':
        return '周末';
      case 'custom':
        return '自定义';
      default:
        return '每天';
    }
  }

  private markAsTaken(index: number) {
    this.reminders[index].taken = !this.reminders[index].taken;
    this.saveReminders();
  }
}

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