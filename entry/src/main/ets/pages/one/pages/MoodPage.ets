import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

//情绪状态页面

class MoodRecord {
  time: string;
  mood: string;
  description: string;
  color: string;

  constructor(time: string, mood: string, description: string, color: string) {
    this.time = time;
    this.mood = mood;
    this.description = description;
    this.color = color;
  }
}

// 定义情绪统计数据的类
class MoodStatItem {
  mood: string;
  percentage: number;

  constructor(mood: string, percentage: number) {
    this.mood = mood;
    this.percentage = percentage;
  }
}

// 定义情绪选项的接口
interface MoodOption {
  mood: string;
  emoji: string;
  color: string;
  description: string;
}

// 定义保存的情绪记录数据接口
interface SavedMoodRecord {
  time: string;
  mood: string;
  description: string;
  color: string;
}

@Entry
@Component
export struct MoodPage {
  @State currentMood: string = '';
  @State moodColor: string = '#4285F4';
  @State moodDescription: string = '';
  @State moodRecords: MoodRecord[] = [];
  @State moodStats: MoodStatItem[] = [];
  @State selectedTimeRange: string = '';

  // 新增状态变量
  @State showMoodSelector: boolean = false;
  @State selectedNewMood: string = '';
  @State newMoodDescription: string = '';

  // 数据存储相关
  private dataPreferences: preferences.Preferences | null = null;
  private readonly PREFERENCES_NAME = 'mood_data';
  private readonly KEY_CURRENT_MOOD = 'current_mood';
  private readonly KEY_MOOD_COLOR = 'mood_color';
  private readonly KEY_MOOD_DESCRIPTION = 'mood_description';
  private readonly KEY_MOOD_RECORDS = 'mood_records';

  private getTimeRanges(): string[] {
    return [
      getContext(this).resourceManager.getStringSync($r('app.string.today_timerange_84751639')),
      getContext(this).resourceManager.getStringSync($r('app.string.this_week_timerange_57382946')),
      getContext(this).resourceManager.getStringSync($r('app.string.this_month_timerange_39284751')),
      getContext(this).resourceManager.getStringSync($r('app.string.whole_year_timerange_75839462'))
    ];
  }

  // 可选择的情绪列表
  private getMoodOptions(): MoodOption[] {
    return [
      { mood: getContext(this).resourceManager.getStringSync($r('app.string.mood_happy_18475936')), emoji: '😊', color: '#34A853', description: getContext(this).resourceManager.getStringSync($r('app.string.mood_happy_desc_62938475')) },
      { mood: getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_62938475')), emoji: '😌', color: '#4285F4', description: getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_desc_84739261')) },
      { mood: getContext(this).resourceManager.getStringSync($r('app.string.mood_satisfied_84739261')), emoji: '😌', color: '#34A853', description: getContext(this).resourceManager.getStringSync($r('app.string.mood_satisfied_desc_57382946')) },
      { mood: getContext(this).resourceManager.getStringSync($r('app.string.mood_tired_57382946')), emoji: '😴', color: '#FBBC05', description: getContext(this).resourceManager.getStringSync($r('app.string.mood_tired_desc_39284751')) },
      { mood: getContext(this).resourceManager.getStringSync($r('app.string.mood_anxious_39284751')), emoji: '😰', color: '#EA4335', description: getContext(this).resourceManager.getStringSync($r('app.string.mood_anxious_desc_75839462')) },
      { mood: getContext(this).resourceManager.getStringSync($r('app.string.mood_excited_75839462')), emoji: '🤩', color: '#FF6B35', description: getContext(this).resourceManager.getStringSync($r('app.string.mood_excited_desc_18475936')) },
      { mood: getContext(this).resourceManager.getStringSync($r('app.string.mood_depressed_18475936')), emoji: '😔', color: '#9E9E9E', description: getContext(this).resourceManager.getStringSync($r('app.string.mood_depressed_desc_62938475')) }
    ];
  }

  // 组件初始化时加载数据
  aboutToAppear() {
    this.selectedTimeRange = getContext(this).resourceManager.getStringSync($r('app.string.this_week_timerange_57382946'));
    this.currentMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_62938475'));
    this.moodDescription = getContext(this).resourceManager.getStringSync($r('app.string.default_mood_description_84739261'));
    this.moodStats = [
      new MoodStatItem(getContext(this).resourceManager.getStringSync($r('app.string.mood_happy_18475936')), 35),
      new MoodStatItem(getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_62938475')), 25),
      new MoodStatItem(getContext(this).resourceManager.getStringSync($r('app.string.mood_satisfied_84739261')), 15),
      new MoodStatItem(getContext(this).resourceManager.getStringSync($r('app.string.mood_tired_57382946')), 15),
      new MoodStatItem(getContext(this).resourceManager.getStringSync($r('app.string.mood_anxious_39284751')), 10)
    ];
    this.initPreferences();
  }

  // 初始化首选项存储
  async initPreferences() {
    try {
      this.dataPreferences = await preferences.getPreferences(getContext(this), this.PREFERENCES_NAME);
      await this.loadMoodData();
    } catch (err) {
      this.setDefaultMoodData();
    }
  }

  // 加载保存的情绪数据
  async loadMoodData() {
    if (!this.dataPreferences) return;

    try {
      // 加载当前情绪状态
      const savedCurrentMood = await this.dataPreferences.get(this.KEY_CURRENT_MOOD, getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_62938475')));
      const savedMoodColor = await this.dataPreferences.get(this.KEY_MOOD_COLOR, '#4285F4');
      const savedMoodDescription = await this.dataPreferences.get(this.KEY_MOOD_DESCRIPTION, getContext(this).resourceManager.getStringSync($r('app.string.default_mood_description_84739261')));

      this.currentMood = savedCurrentMood as string;
      this.moodColor = savedMoodColor as string;
      this.moodDescription = savedMoodDescription as string;

      // 加载情绪记录
      const savedRecordsJson = await this.dataPreferences.get(this.KEY_MOOD_RECORDS, '[]');
      const savedRecordsData: SavedMoodRecord[] = JSON.parse(savedRecordsJson as string);

      if (Array.isArray(savedRecordsData) && savedRecordsData.length > 0) {
        this.moodRecords = savedRecordsData.map((record: SavedMoodRecord) =>
        new MoodRecord(record.time, record.mood, record.description, record.color)
        );
        // 更新统计数据
        this.updateMoodStats();
      } else {
        // 如果没有保存的记录，使用默认数据
        this.setDefaultMoodData();
      }
    } catch (err) {
      this.setDefaultMoodData();
    }
  }

  // 设置默认情绪数据
  setDefaultMoodData() {
    const todayPrefix = getContext(this).resourceManager.getStringSync($r('app.string.today_time_prefix_62938475'));
    const yesterdayPrefix = getContext(this).resourceManager.getStringSync($r('app.string.yesterday_time_prefix_84739261'));
    const daysBefore2Prefix = getContext(this).resourceManager.getStringSync($r('app.string.days_ago_time_prefix_57382946'));
    const daysBefore3Prefix = getContext(this).resourceManager.getStringSync($r('app.string.days_ago_3_time_prefix_39284751'));

    this.moodRecords = [
      new MoodRecord(`${todayPrefix} 12:30`, getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_62938475')),  getContext(this).resourceManager.getStringSync($r('app.string.lunch_relaxed_desc_84729163')), '#4285F4'),
      new MoodRecord(`${todayPrefix} 08:00`, getContext(this).resourceManager.getStringSync($r('app.string.mood_happy_18475936')), getContext(this).resourceManager.getStringSync($r('app.string.morning_energetic_desc_57294816')), '#34A853'),
      new MoodRecord(`${yesterdayPrefix} 19:00`, getContext(this).resourceManager.getStringSync($r('app.string.mood_tired_57382946')), getContext(this).resourceManager.getStringSync($r('app.string.work_tired_desc_39485729')), '#FBBC05'),
      new MoodRecord(`${yesterdayPrefix} 10:00`, getContext(this).resourceManager.getStringSync($r('app.string.mood_anxious_39284751')), getContext(this).resourceManager.getStringSync($r('app.string.work_pressure_desc_75193847')), '#EA4335'),
      new MoodRecord(`${daysBefore2Prefix} 14:00`, getContext(this).resourceManager.getStringSync($r('app.string.mood_happy_18475936')), getContext(this).resourceManager.getStringSync($r('app.string.task_completed_desc_18475936')), '#34A853'),
      new MoodRecord(`${daysBefore2Prefix} 08:30`, getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_62938475')), getContext(this).resourceManager.getStringSync($r('app.string.meditation_calm_desc_62938475')), '#4285F4'),
      new MoodRecord(`${daysBefore3Prefix} 20:00`, getContext(this).resourceManager.getStringSync($r('app.string.mood_satisfied_84739261')), getContext(this).resourceManager.getStringSync($r('app.string.dinner_friends_desc_84739261')), '#34A853')
    ];
    this.updateMoodStats();
  }

  // 保存情绪数据到存储
  async saveMoodData() {
    if (!this.dataPreferences) return;

    try {
      // 保存当前情绪状态
      await this.dataPreferences.put(this.KEY_CURRENT_MOOD, this.currentMood);
      await this.dataPreferences.put(this.KEY_MOOD_COLOR, this.moodColor);
      await this.dataPreferences.put(this.KEY_MOOD_DESCRIPTION, this.moodDescription);

      // 保存情绪记录
      const recordsData: SavedMoodRecord[] = this.moodRecords.map((record: MoodRecord): SavedMoodRecord => ({
        time: record.time,
        mood: record.mood,
        description: record.description,
        color: record.color
      }));
      await this.dataPreferences.put(this.KEY_MOOD_RECORDS, JSON.stringify(recordsData));

      // 刷新到磁盘
      await this.dataPreferences.flush();
    } catch (err) {
    }
  }

  build() {
    Column() {
      // 顶部导航栏
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
            router.pushUrl({ url: 'pages/one/OnePage' });
          }
        })
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .margin({ left: 10 })

        Text(getContext(this).resourceManager.getStringSync($r('app.string.mood_status_title_84729638')))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 右侧占位元素，保持布局平衡
        Row()
          .width(40)
          .height(40)
          .margin({ right: 10 })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 可滚动的内容区域
      Scroll() {
        Column({ space: 20 }) {
          // 当前情绪概览卡片
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.current_mood_label_57284916')))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 20 })
              .fontColor('#333333')

            // 情绪显示区域
            Column() {
              Text(this.currentMood)
                .fontSize(48)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.moodColor)
                .margin({ bottom: 10 })

              Text(this.moodDescription)
                .fontSize(16)
                .fontColor('#666666')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 30 })
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Button(getContext(this).resourceManager.getStringSync($r('app.string.record_new_mood_button_39475829')))
                .fontSize(16)
                .fontColor(Color.White)
                .backgroundColor(this.moodColor)
                .borderRadius(25)
                .height(50)
                .width(150)
                .onClick(() => {
                  this.showMoodSelector = true;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
          .width('90%')
          .padding(30)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .shadow({
            radius: 12,
            color: 'rgba(0,0,0,0.08)',
            offsetX: 0,
            offsetY: 4
          })

          // 时间范围选择器
          Row() {
            ForEach(this.getTimeRanges(), (range: string) => {
              Text(range)
                .fontSize(14)
                .fontColor(this.selectedTimeRange === range ? '#4285F4' : '#666666')
                .fontWeight(this.selectedTimeRange === range ? FontWeight.Bold : FontWeight.Normal)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .backgroundColor(this.selectedTimeRange === range ? '#E8F0FE' : '#F5F5F5')
                .borderRadius(20)
                .border({
                  width: this.selectedTimeRange === range ? 2 : 1,
                  color: this.selectedTimeRange === range ? '#4285F4' : '#E0E0E0',
                  style: BorderStyle.Solid
                })
                .onClick(() => {
                  this.selectedTimeRange = range;
                })
            })
          }
          .width('90%')
          .justifyContent(FlexAlign.SpaceAround)

          // 情绪分布卡片
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.mood_distribution_title_75163948')))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ bottom: 15 })

            Row() {
              ForEach(this.moodStats, (item: MoodStatItem) => {
                Column() {
                  // 情绪图标
                  Row() {
                    Text(this.getMoodEmoji(item.mood))
                      .fontSize(24)
                  }
                  .width(44)
                  .height(44)
                  .borderRadius(22)
                  .backgroundColor(this.getMoodColor(item.mood) + '20')
                  .justifyContent(FlexAlign.Center)
                  .margin({ bottom: 8 })

                  Text(item.mood)
                    .fontSize(14)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 4 })

                  Text(`${item.percentage}%`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getMoodColor(item.mood))
                }
                .width('20%')
                .alignItems(HorizontalAlign.Center)
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(15)
          .padding(20)
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.06)',
            offsetX: 0,
            offsetY: 3
          })

          // 情绪记录卡片
          Column() {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.mood_records_title_18394756')))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ bottom: 15 })

            Column({ space: 12 }) {
              ForEach(this.moodRecords, (record: MoodRecord, index: number) => {
                Row() {
                  // 情绪图标
                  Row() {
                    Text(this.getMoodEmoji(record.mood))
                      .fontSize(20)
                  }
                  .width(44)
                  .height(44)
                  .borderRadius(22)
                  .backgroundColor(record.color + '20')
                  .justifyContent(FlexAlign.Center)
                  .margin({ right: 16 })

                  Column() {
                    Row() {
                      Text(record.mood)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(record.color)

                      Blank()

                      Text(record.time)
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                    .width('100%')

                    Text(record.description)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 })
                      .textAlign(TextAlign.Start)
                      .width('100%')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .height(60)
                .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                .backgroundColor(index % 2 === 0 ? '#F8F9FA' : '#FFFFFF')
                .borderRadius(12)
                .alignItems(VerticalAlign.Center)
              })
            }
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(15)
          .padding(20)
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.06)',
            offsetX: 0,
            offsetY: 3
          })

          // 情绪健康建议
          Column() {
            Row() {
              Text(getContext(this).resourceManager.getStringSync($r('app.string.mood_health_tips_title_62847593')))
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Blank()

              Text('💡')
                .fontSize(20)
            }
            .width('100%')
            .margin({ bottom: 15 })

            Column({ space: 12 }) {
              this.buildMoodAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.meditation_advice_57382946')), '🧘‍♂️')
              this.buildMoodAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.exercise_advice_39284751')), '🏃‍♂️')
              this.buildMoodAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.sleep_advice_75839462')), '😴')
              this.buildMoodAdviceItem(getContext(this).resourceManager.getStringSync($r('app.string.social_advice_18475936')), '👥')
            }
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(15)
          .padding(20)
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.06)',
            offsetX: 0,
            offsetY: 3
          })
        }
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 情绪选择弹窗
      if (this.showMoodSelector) {
        this.buildMoodSelectorDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildMoodSelectorDialog() {
    Column() {
      Column({ space: 20 }) {
        Text(getContext(this).resourceManager.getStringSync($r('app.string.record_new_mood_dialog_title_18475936')))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(getContext(this).resourceManager.getStringSync($r('app.string.select_current_mood_desc_62938475')))
          .fontSize(14)
          .fontColor('#666666')

        // 情绪选择网格
        Grid() {
          ForEach(this.getMoodOptions(), (option: MoodOption) => {
            GridItem() {
              Column() {
                Row() {
                  Text(option.emoji)
                    .fontSize(32)
                }
                .width(60)
                .height(60)
                .borderRadius(30)
                .backgroundColor(this.selectedNewMood === option.mood ? option.color + '30' : '#F5F5F5')
                .justifyContent(FlexAlign.Center)
                .margin({ bottom: 8 })
                .border({
                  width: this.selectedNewMood === option.mood ? 2 : 1,
                  color: this.selectedNewMood === option.mood ? option.color : '#E0E0E0',
                  style: BorderStyle.Solid
                })

                Text(option.mood)
                  .fontSize(14)
                  .fontColor(this.selectedNewMood === option.mood ? option.color : '#333333')
                  .fontWeight(this.selectedNewMood === option.mood ? FontWeight.Bold : FontWeight.Normal)
              }
              .onClick(() => {
                this.selectedNewMood = option.mood;
                this.newMoodDescription = option.description;
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(16)
        .columnsGap(16)
        .width('100%')
        .height(200)

        // 描述输入框
        if (this.selectedNewMood) {
          Column({ space: 10 }) {
            Text(getContext(this).resourceManager.getStringSync($r('app.string.add_description_optional_84739261')))
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')
              .textAlign(TextAlign.Start)

            TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.describe_feeling_placeholder_57382946')), text: this.newMoodDescription })
              .fontSize(14)
              .height(80)
              .borderRadius(8)
              .backgroundColor('#F8F9FA')
              .onChange((value: string) => {
                this.newMoodDescription = value;
              })
          }
          .width('100%')
        }

        // 按钮组
        Row({ space: 15 }) {
          Button(getContext(this).resourceManager.getStringSync($r('app.string.cancel_button_39284751')))
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(25)
            .height(45)
            .width(100)
            .onClick(() => {
              this.showMoodSelector = false;
              this.selectedNewMood = '';
              this.newMoodDescription = '';
            })

          Button(getContext(this).resourceManager.getStringSync($r('app.string.confirm_record_button_75839462')))
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.selectedNewMood ? this.getMoodColor(this.selectedNewMood) : '#CCCCCC')
            .borderRadius(25)
            .height(45)
            .width(120)
            .enabled(!!this.selectedNewMood)
            .onClick(() => {
              this.recordNewMood();
            })
        }
      }
      .padding(30)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .width('85%')
      .shadow({
        radius: 20,
        color: 'rgba(0,0,0,0.3)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildMoodAdviceItem(advice: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 12 })

      Text(advice)
        .fontSize(14)
        .fontColor('#333333')
        .textAlign(TextAlign.Start)
        .layoutWeight(1)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .alignItems(VerticalAlign.Top)
  }

  // 记录新情绪的方法
  async recordNewMood() {
    if (!this.selectedNewMood) return;

    // 获取当前时间
    const now = new Date();
    const todayPrefix = getContext(this).resourceManager.getStringSync($r('app.string.today_time_prefix_62938475'));
    const timeString = `${todayPrefix} ${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

    // 创建新的情绪记录
    const newRecord = new MoodRecord(
      timeString,
      this.selectedNewMood,
      this.newMoodDescription || this.getMoodDefaultDescription(this.selectedNewMood),
      this.getMoodColor(this.selectedNewMood)
    );

    // 添加到记录列表的开头
    this.moodRecords.unshift(newRecord);

    // 更新当前情绪状态
    this.currentMood = this.selectedNewMood;
    this.moodColor = this.getMoodColor(this.selectedNewMood);
    this.moodDescription = this.newMoodDescription || this.getMoodDefaultDescription(this.selectedNewMood);

    // 更新统计数据
    this.updateMoodStats();

    // 保存数据到存储
    await this.saveMoodData();

    // 关闭弹窗并重置状态
    this.showMoodSelector = false;
    this.selectedNewMood = '';
    this.newMoodDescription = '';
  }

  // 更新情绪统计数据
  updateMoodStats() {
    const moodCounts: Record<string, number> = {};
    const totalRecords = this.moodRecords.length;

    // 统计各种情绪的数量
    this.moodRecords.forEach(record => {
      moodCounts[record.mood] = (moodCounts[record.mood] || 0) + 1;
    });

    // 更新统计数据
    this.moodStats = Object.entries(moodCounts)
      .map((entry: [string, number]) => new MoodStatItem(entry[0], Math.round((entry[1] / totalRecords) * 100)))
      .sort((a, b) => b.percentage - a.percentage)
      .slice(0, 5); // 只显示前5种情绪
  }

  // 获取情绪默认描述
  getMoodDefaultDescription(mood: string): string {
    const option = this.getMoodOptions().find(opt => opt.mood === mood);
    return option ? option.description : getContext(this).resourceManager.getStringSync($r('app.string.default_record_desc_18475936'));
  }

  getMoodColor(mood: string): string {
    const happyMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_happy_18475936'));
    const satisfiedMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_satisfied_84739261'));
    const calmMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_62938475'));
    const tiredMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_tired_57382946'));
    const anxiousMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_anxious_39284751'));
    const excitedMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_excited_75839462'));
    const depressedMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_depressed_18475936'));

    if (mood === happyMood || mood === satisfiedMood) return '#34A853';
    if (mood === calmMood) return '#4285F4';
    if (mood === tiredMood) return '#FBBC05';
    if (mood === anxiousMood) return '#EA4335';
    if (mood === excitedMood) return '#FF6B35';
    if (mood === depressedMood) return '#9E9E9E';
    return '#4285F4';
  }

  getMoodEmoji(mood: string): string {
    const happyMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_happy_18475936'));
    const calmMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_calm_62938475'));
    const satisfiedMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_satisfied_84739261'));
    const tiredMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_tired_57382946'));
    const anxiousMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_anxious_39284751'));
    const excitedMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_excited_75839462'));
    const depressedMood = getContext(this).resourceManager.getStringSync($r('app.string.mood_depressed_18475936'));

    if (mood === happyMood) return '😊';
    if (mood === calmMood) return '😌';
    if (mood === satisfiedMood) return '😌';
    if (mood === tiredMood) return '😴';
    if (mood === anxiousMood) return '😰';
    if (mood === excitedMood) return '🤩';
    if (mood === depressedMood) return '😔';
    return '😐';
  }
}