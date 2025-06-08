import { router } from '@kit.ArkUI';
import { BaseNavigation, JhProgressHUD } from 'JhCommon';

///共同健康目标页面

class HealthTargetModel {
  id: string;
  title: string;
  description: string;
  startDate: string;
  endDate: string;
  progress: number;
  participants: string[];
  category: string;
  color: string;
  isCompleted: boolean;

  constructor(
    id: string,
    title: string,
    description: string,
    startDate: string,
    endDate: string,
    progress: number,
    participants: string[],
    category: string,
    color: string,
    isCompleted: boolean
  ) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.startDate = startDate;
    this.endDate = endDate;
    this.progress = progress;
    this.participants = participants;
    this.category = category;
    this.color = color;
    this.isCompleted = isCompleted;
  }
}

@CustomDialog
struct AddTargetDialog {
  controller?: CustomDialogController;
  @Link newTarget: HealthTargetModel;
  onSaveCallback: () => void = () => {};
  onCancelCallback: () => void = () => {};

  @Builder
  inputField(label: string, value: string, onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 5 });

      TextInput({ text: value, placeholder: getContext(this).resourceManager.getStringSync($r('app.string.please_input_prefix_847392615738294847392615738294')) + label })
        .width('100%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(5)
        .padding(10)
        .onChange(onChange);
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ bottom: 10 });
  }

  private getCategoryColor(category: string): string {
    const exerciseText: string = getContext(this).resourceManager.getStringSync($r('app.string.exercise_category_573829461847392573829461847392573'))
    const walkingText: string = getContext(this).resourceManager.getStringSync($r('app.string.walking_category_392847516293847392847516293847392'))
    const dietText: string = getContext(this).resourceManager.getStringSync($r('app.string.diet_category_758394627184759758394627184759758'))
    const outdoorText: string = getContext(this).resourceManager.getStringSync($r('app.string.outdoor_category_184759362847392184759362847392184'))
    const sleepText: string = getContext(this).resourceManager.getStringSync($r('app.string.sleep_category_629384751952847629384751952847629'))

    switch(category) {
      case exerciseText: return '#4CAF50';
      case walkingText: return '#2196F3';
      case dietText: return '#FF9800';
      case outdoorText: return '#9C27B0';
      case sleepText: return '#3F51B5';
      default: return '#CCCCCC';
    }
  }

  build() {
    Column() {
      Text(getContext(this).resourceManager.getStringSync($r('app.string.new_health_target_dialog_title_758394627184759362758394627')))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 });

      this.inputField(getContext(this).resourceManager.getStringSync($r('app.string.target_title_label_184759362847392184759362847')), this.newTarget.title, (value: string) => {
        this.newTarget.title = value;
      });

      this.inputField(getContext(this).resourceManager.getStringSync($r('app.string.target_description_label_629384751952847629384751952')), this.newTarget.description, (value: string) => {
        this.newTarget.description = value;
      });

      this.inputField(getContext(this).resourceManager.getStringSync($r('app.string.start_date_label_847392615738294847392615738')), this.newTarget.startDate, (value: string) => {
        this.newTarget.startDate = value;
      });

      this.inputField(getContext(this).resourceManager.getStringSync($r('app.string.end_date_label_573829461847392573829461847392')), this.newTarget.endDate, (value: string) => {
        this.newTarget.endDate = value;
      });

      this.inputField(getContext(this).resourceManager.getStringSync($r('app.string.participants_label_392847516293847392847516293847')), this.newTarget.participants.join(', '), (value: string) => {
        this.newTarget.participants = value.split(',').map(p => p.trim()).filter(p => p !== '');
      });

      this.inputField(getContext(this).resourceManager.getStringSync($r('app.string.health_category_label_758394627184759758394627184759')), this.newTarget.category, (value: string) => {
        this.newTarget.category = value;
        this.newTarget.color = this.getCategoryColor(value);
      });

      Row() {
        Button(getContext(this).resourceManager.getStringSync($r('app.string.cancel_btn_184759362847392184759362847392')))
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .width(120)
          .height(40)
          .margin({ right: 20 })
          .onClick(() => {
            this.onCancelCallback();
            this.controller?.close();
          });

        Button(getContext(this).resourceManager.getStringSync($r('app.string.save_btn_629384751952847629384751952847')))
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .width(120)
          .height(40)
          .onClick(() => {
            this.onSaveCallback();
          });
      }
      .margin({ top: 20 });
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .width('90%');
  }
}

@Entry
@Component
export struct CommonHealthTargetsPage {
  @State activeTargets: HealthTargetModel[] = [];
  @State completedTargets: HealthTargetModel[] = [];
  @State selectedTab: number = 0; // 0:进行中, 1:已完成
  @State newTarget: HealthTargetModel = new HealthTargetModel(
    '', '', '', this.getCurrentDate(), this.getCurrentDate(),
    0, [], '', '#CCCCCC', false
  );
  scroller: Scroller = new Scroller();

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddTargetDialog({
      newTarget: $newTarget,
      onSaveCallback: (): void => this.handleSaveTarget(),
      onCancelCallback: (): void => this.handleCancelTarget()
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    this.loadSampleData();
  }

  getTabs(): string[] {
    const inProgressText: string = getContext(this).resourceManager.getStringSync($r('app.string.in_progress_tab_629384751639284751639284751'))
    const completedText: string = getContext(this).resourceManager.getStringSync($r('app.string.completed_tab_573829461847392573829461847'))
    return [inProgressText, completedText];
  }

  loadSampleData() {
    this.activeTargets = this.getActiveTargets();
    this.completedTargets = this.getCompletedTargets();
  }

  getActiveTargets(): HealthTargetModel[] {
    const weeklyExerciseTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.weekly_family_exercise_plan_847392615738294847392615738294847'))
    const weeklyExerciseDesc: string = getContext(this).resourceManager.getStringSync($r('app.string.weekly_exercise_description_573829461847392573829461847392573829'))
    const stepChallengeTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.family_step_challenge_392847516293847392847516293847392847'))
    const stepChallengeDesc: string = getContext(this).resourceManager.getStringSync($r('app.string.family_step_description_758394627184759758394627184759758394'))
    const healthyDietTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.healthy_diet_month_184759362847392184759362847392184759'))
    const healthyDietDesc: string = getContext(this).resourceManager.getStringSync($r('app.string.healthy_diet_description_629384751952847629384751952847629384'))
    const dadText: string = getContext(this).resourceManager.getStringSync($r('app.string.dad_participant_184759362847392184759362847392184759362'))
    const momText: string = getContext(this).resourceManager.getStringSync($r('app.string.mom_participant_629384751952847629384751952847629384751'))
    const grandpaText: string = getContext(this).resourceManager.getStringSync($r('app.string.grandpa_participant_847392615738294847392615738294847392615'))
    const grandmaText: string = getContext(this).resourceManager.getStringSync($r('app.string.grandma_participant_573829461847392573829461847392573829461847'))
    const meText: string = getContext(this).resourceManager.getStringSync($r('app.string.me_participant_392847516293847392847516293847392847516'))
    const liYifeiText: string = getContext(this).resourceManager.getStringSync($r('app.string.li_yifei_participant_758394627184759758394627184759758394627'))
    const luJinghaoText: string = getContext(this).resourceManager.getStringSync($r('app.string.lu_jinghao_participant_184759362847392184759362847392184759362847'))
    const exerciseText: string = getContext(this).resourceManager.getStringSync($r('app.string.exercise_category_573829461847392573829461847392573'))
    const walkingText: string = getContext(this).resourceManager.getStringSync($r('app.string.walking_category_392847516293847392847516293847392'))
    const dietText: string = getContext(this).resourceManager.getStringSync($r('app.string.diet_category_758394627184759758394627184759758'))

    return [
      new HealthTargetModel(
        '1',
        weeklyExerciseTitle,
        weeklyExerciseDesc,
        '2024-05-01',
        '2024-05-31',
        65,
        [dadText, momText, grandpaText, grandmaText, meText],
        exerciseText,
        '#4CAF50',
        false
      ),
      new HealthTargetModel(
        '2',
        stepChallengeTitle,
        stepChallengeDesc,
        '2024-05-01',
        '2024-05-31',
        42,
        [dadText, momText, meText, liYifeiText, luJinghaoText],
        walkingText,
        '#2196F3',
        false
      ),
      new HealthTargetModel(
        '3',
        healthyDietTitle,
        healthyDietDesc,
        '2024-05-01',
        '2024-05-31',
        30,
        [dadText, momText, grandpaText, grandmaText],
        dietText,
        '#FF9800',
        false
      )
    ];
  }

  getCompletedTargets(): HealthTargetModel[] {
    const springOutdoorTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.spring_outdoor_activity_847392615738294847392615738294847392'))
    const springOutdoorDesc: string = getContext(this).resourceManager.getStringSync($r('app.string.spring_outdoor_description_573829461847392573829461847392573829461'))
    const earlySleepTitle: string = getContext(this).resourceManager.getStringSync($r('app.string.early_sleep_challenge_392847516293847392847516293847392847392'))
    const earlySleepDesc: string = getContext(this).resourceManager.getStringSync($r('app.string.early_sleep_description_758394627184759758394627184759758394627'))
    const dadText: string = getContext(this).resourceManager.getStringSync($r('app.string.dad_participant_184759362847392184759362847392184759362'))
    const momText: string = getContext(this).resourceManager.getStringSync($r('app.string.mom_participant_629384751952847629384751952847629384751'))
    const meText: string = getContext(this).resourceManager.getStringSync($r('app.string.me_participant_392847516293847392847516293847392847516'))
    const liYifeiText: string = getContext(this).resourceManager.getStringSync($r('app.string.li_yifei_participant_758394627184759758394627184759758394627'))
    const luJinghaoText: string = getContext(this).resourceManager.getStringSync($r('app.string.lu_jinghao_participant_184759362847392184759362847392184759362847'))
    const outdoorText: string = getContext(this).resourceManager.getStringSync($r('app.string.outdoor_category_184759362847392184759362847392184'))
    const sleepText: string = getContext(this).resourceManager.getStringSync($r('app.string.sleep_category_629384751952847629384751952847629'))

    return [
      new HealthTargetModel(
        '4',
        springOutdoorTitle,
        springOutdoorDesc,
        '2024-03-01',
        '2024-04-30',
        100,
        [dadText, momText, meText],
        outdoorText,
        '#9C27B0',
        true
      ),
      new HealthTargetModel(
        '5',
        earlySleepTitle,
        earlySleepDesc,
        '2024-04-01',
        '2024-04-21',
        100,
        [meText, liYifeiText, luJinghaoText],
        sleepText,
        '#3F51B5',
        true
      )
    ];
  }

  handleSaveTarget() {
    if (!this.validateTarget()) return;

    const newTarget = new HealthTargetModel(
      Date.now().toString(),
      this.newTarget.title,
      this.newTarget.description,
      this.newTarget.startDate,
      this.newTarget.endDate,
      0,
      this.newTarget.participants,
      this.newTarget.category,
      this.newTarget.color,
      false
    );

    this.activeTargets = [...this.activeTargets, newTarget];
    JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.target_created_success_847392615738294847392615738294847392615738294')));
    this.resetNewTarget();
    this.dialogController.close();
  }

  validateTarget(): boolean {
    const exerciseText: string = getContext(this).resourceManager.getStringSync($r('app.string.exercise_category_573829461847392573829461847392573'))
    const walkingText: string = getContext(this).resourceManager.getStringSync($r('app.string.walking_category_392847516293847392847516293847392'))
    const dietText: string = getContext(this).resourceManager.getStringSync($r('app.string.diet_category_758394627184759758394627184759758'))
    const outdoorText: string = getContext(this).resourceManager.getStringSync($r('app.string.outdoor_category_184759362847392184759362847392184'))
    const sleepText: string = getContext(this).resourceManager.getStringSync($r('app.string.sleep_category_629384751952847629384751952847629'))
    const validCategories = [exerciseText, walkingText, dietText, outdoorText, sleepText];

    if (!this.newTarget.title.trim()) {
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.please_fill_title_573829461847392573829461847392573829461847392573')));
      return false;
    }
    if (!this.newTarget.startDate || !this.newTarget.endDate) {
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.please_fill_dates_392847516293847392847516293847392847516293847392')));
      return false;
    }
    if (this.newTarget.participants.length === 0) {
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.please_add_participant_758394627184759758394627184759758394627184759758')));
      return false;
    }
    if (!validCategories.includes(this.newTarget.category)) {
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.please_enter_valid_category_184759362847392184759362847392184759362847392184')));
      return false;
    }
    return true;
  }

  getCurrentDate(): string {
    const now = new Date();
    return `${now.getFullYear()}-${(now.getMonth()+1).toString().padStart(2,'0')}-${now.getDate().toString().padStart(2,'0')}`;
  }

  resetNewTarget() {
    this.newTarget = new HealthTargetModel(
      '', '', '', this.getCurrentDate(), this.getCurrentDate(),
      0, [], '', '#CCCCCC', false
    );
  }

  handleCancelTarget() {
    this.resetNewTarget();
    this.dialogController.close();
  }

  deleteTarget(id: string, isCompleted: boolean) {
    if (isCompleted) {
      this.completedTargets = this.completedTargets.filter(item => item.id !== id);
    } else {
      this.activeTargets = this.activeTargets.filter(item => item.id !== id);
    }
    JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.target_deleted_629384751952847629384751952847629384751952847629384751')));
  }

  toggleTargetStatus(id: string) {
    const activeIndex = this.activeTargets.findIndex(item => item.id === id);
    if (activeIndex !== -1) {
      const targetItem = this.activeTargets[activeIndex];
      this.activeTargets = this.activeTargets.filter((_, index) => index !== activeIndex);
      targetItem.isCompleted = true;
      this.completedTargets = [...this.completedTargets, targetItem];
      JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.target_completed_847392615738294847392615738294847392615738294847392615')));
    } else {
      const completedIndex = this.completedTargets.findIndex(item => item.id === id);
      if (completedIndex !== -1) {
        const targetItem = this.completedTargets[completedIndex];
        this.completedTargets = this.completedTargets.filter((_, index) => index !== completedIndex);
        targetItem.isCompleted = false;
        this.activeTargets = [...this.activeTargets, targetItem];
        JhProgressHUD.showText(getContext(this).resourceManager.getStringSync($r('app.string.target_reactivated_573829461847392573829461847392573829461847392573829461')));
      }
    }
  }

  @Builder
  targetCard(item: HealthTargetModel) {
    Column() {
      Row() {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1);

        Text(item.category)
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(item.color)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(10);
      }
      .margin({ bottom: 8 });

      Text(item.description)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 10 })
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

      Row() {
        Text(getContext(this).resourceManager.getStringSync($r('app.string.date_label_prefix_629384751952847629384751952847629384751952')))
          .fontSize(12)
          .fontColor('#999999');
        Text(`${item.startDate} - ${item.endDate}`)
          .fontSize(12)
          .fontColor('#999999');
      }
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 12 });

      // 进度条显示
      Column() {
        Progress({
          value: item.progress,
          total: 100,
          type: ProgressType.Linear
        })
          .width('100%')
          .height(8)
          .color(item.color);

        // 百分比数字显示
        Text(`${item.progress}%`)
          .fontColor(item.color)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 5 })
          .width('100%')
          .textAlign(TextAlign.Center);
      }
      .margin({ bottom: 12 });

      // 参与者显示
      Row() {
        Text(getContext(this).resourceManager.getStringSync($r('app.string.participants_label_prefix_847392615738294847392615738294847392615738')))
          .fontSize(14)
          .fontColor('#666666');
        Text(item.participants.join(', '))
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 5 });

      // 状态分隔线
      Divider()
        .color('#EEEEEE')
        .margin({ top: 10, bottom: 5 });

      // 操作按钮区域
      Row() {
        // 完成/重新激活按钮
        Button(item.isCompleted ? getContext(this).resourceManager.getStringSync($r('app.string.reactivate_btn_573829461847392573829461847392573829461847392')) : getContext(this).resourceManager.getStringSync($r('app.string.mark_complete_btn_392847516293847392847516293847392847516293')), { type: ButtonType.Capsule })
          .height(30)
          .fontSize(12)
          .backgroundColor(item.isCompleted ? '#E0F7FA' : '#E8F5E9')
          .fontColor(item.isCompleted ? '#0097A7' : '#388E3C')
          .onClick(() => this.toggleTargetStatus(item.id))
          .margin({ right: 10 });

        // 删除按钮
        Button(getContext(this).resourceManager.getStringSync($r('app.string.delete_btn_758394627184759758394627184759758394627184759')), { type: ButtonType.Capsule })
          .height(30)
          .fontSize(12)
          .backgroundColor('#FFEBEE')
          .fontColor('#D32F2F')
          .onClick(() => this.deleteTarget(item.id, item.isCompleted));
      }
      .justifyContent(FlexAlign.End)
      .margin({ top: 5 });
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 6, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .margin({ top: 10, left: 12, right: 12 });
  }

  @Builder
  emptyState() {
    Column() {
      Text('📋')
        .fontSize(48)
        .margin({ bottom: 20 });

      Text(getContext(this).resourceManager.getStringSync($r('app.string.no_health_targets_184759362847392184759362847392184759362847392')))
        .fontSize(16)
        .fontColor('#999999')
        .margin({ bottom: 5 });

      Text(getContext(this).resourceManager.getStringSync($r('app.string.create_first_target_hint_629384751952847629384751952847629384751952847')))
        .fontSize(14)
        .fontColor('#CCCCCC');
    }
    .height(300)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  build() {
    Column() {
      // 导航栏
      BaseNavigation({ title: getContext(this).resourceManager.getStringSync($r('app.string.health_targets_management_title_847392651847392651847926')), bgColor: Color.White });

      Column() {
        // 标签页切换 - 使用参考代码中的样式
        Row() {
          ForEach(this.getTabs(), (tab: string, index: number) => {
            Text(tab)
              .fontSize(16)
              .fontColor(this.selectedTab === index ? '#4CAF50' : '#999999')
              .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .border({
                width: { bottom: this.selectedTab === index ? 2 : 0 },
                color: '#4CAF50'
              })
              .onClick(() => {
                this.selectedTab = index;
              });
          });
        }
        .margin({ bottom: 15 });

        // 创建目标按钮
        Button(getContext(this).resourceManager.getStringSync($r('app.string.create_health_target_btn_392847516293847516293847516')), { type: ButtonType.Capsule })
          .height(45)
          .backgroundColor('#4CAF50')
          .fontColor(Color.White)
          .fontSize(16)
          .margin({ bottom: 15, top: 5, left: 16, right: 16 })
          .onClick(() => this.dialogController.open());

        // 目标列表
        // 目标列表
        // 目标列表
        Scroll() {
          Column() {
            if (this.selectedTab === 0) {
              // 进行中目标
              if (this.activeTargets.length === 0) {
                this.emptyState();
              } else {
                ForEach(this.activeTargets, (item: HealthTargetModel) => {
                  this.targetCard(item);
                });
              }
            } else {
              // 已完成目标
              if (this.completedTargets.length === 0) {
                this.emptyState();
              } else {
                ForEach(this.completedTargets, (item: HealthTargetModel) => {
                  this.targetCard(item);
                });
              }
            }
          }
          .padding({ bottom: 30 });
        }
        .layoutWeight(1);
      }
      .backgroundColor('#F5F5F5')
      .flexGrow(1);
    }
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}