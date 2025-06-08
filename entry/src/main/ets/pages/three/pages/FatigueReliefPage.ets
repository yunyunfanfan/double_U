import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';

///疲劳缓解页面

interface ReliefItem {
  title: string;
  desc: string;
  cover: string;
  category: string;
  favorite: boolean;
}

interface CategoryOption {
  value: string;
}

@Entry
@Component
export struct FatigueReliefPage {
  @State reliefList: ReliefItem[] = [];
  @State newTitle: string = '';
  @State newDesc: string = '';
  @State newCover: string = '';
  @State newCategory: string = '';
  @State editingIndex: number = -1;
  @State categoryOptions: CategoryOption[] = [];

  aboutToAppear() {
    this.initData();
  }

  initData() {
    this.newCategory = getContext(this).resourceManager.getStringSync($r('app.string.category_whole_body'));

    this.categoryOptions = [
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_whole_body')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_eye')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_neck')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_hand')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_leg')) }
    ];

    this.reliefList = [
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.eye_exercise')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.eye_exercise_desc')),
        cover: 'images/eye_exercise.png',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_eye')),
        favorite: false
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.neck_stretch')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.neck_stretch_desc')),
        cover: 'images/neck_stretch.png',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_neck')),
        favorite: false
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.deep_breathing')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.deep_breathing_desc')),
        cover: 'images/breath.png',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_whole_body')),
        favorite: false
      }
    ];
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
        .margin({ left: 10 })
        Blank().layoutWeight(1)
        Text($r('app.string.fatigue_relief'))
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
          ForEach(this.reliefList, (item: ReliefItem, index: number) => {
            ListItem() {
              Row() {
                Image($rawfile(item.cover))
                  .width(60)
                  .height(60)
                  .borderRadius(8)
                  .margin({ right: 10 })
                Column() {
                  Row() {
                    Text(item.title)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#222222')
                    Text(` [${item.category}]`)
                      .fontSize(13)
                      .fontColor('#888888')
                      .margin({ left: 6 })
                  }
                  Text(item.desc)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ top: 5 })
                }
                .layoutWeight(1)
                Column() {
                  Button({ type: ButtonType.Circle }) {
                    Image($r('app.media.ic_delete'))
                      .width(18)
                      .height(18)
                  }
                  .onClick(() => { this.deleteRelief(index); })
                  .width(32)
                  .height(32)
                  .backgroundColor('#FFE5E5')
                  .margin({ bottom: 8 })
                  Button({ type: ButtonType.Circle }) {
                    Image($r('app.media.ic_back'))
                      .width(18)
                      .height(18)
                  }
                  .onClick(() => { this.editRelief(index); })
                  .width(32)
                  .height(32)
                  .backgroundColor('#E5F0FF')
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(14)
              .margin({ bottom: 12 })
              .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
            }
          })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F0F0F0')

      Column() {
        Text(this.editingIndex >= 0 ?
        getContext(this).resourceManager.getStringSync($r('app.string.edit_relief_method')) :
        getContext(this).resourceManager.getStringSync($r('app.string.add_relief_method')))
          .fontSize(16)
          .margin({ bottom: 8 })
        TextInput({
          placeholder: getContext(this).resourceManager.getStringSync($r('app.string.method_title_placeholder')),
          text: this.newTitle
        })
          .onChange((value: string) => { this.newTitle = value; })
          .margin({ bottom: 8 })
        TextInput({
          placeholder: getContext(this).resourceManager.getStringSync($r('app.string.method_desc_placeholder')),
          text: this.newDesc
        })
          .onChange((value: string) => { this.newDesc = value; })
          .margin({ bottom: 8 })
        Row() {
          Select(this.categoryOptions)
            .selected(this.categoryOptions.findIndex((option: CategoryOption) => option.value === this.newCategory))
            .value(this.newCategory)
            .onSelect((index: number, value: string) => { this.newCategory = value; })
            .width(120)
            .height(36)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
        }
        .margin({ bottom: 8 })
        Button(this.editingIndex >= 0 ?
        getContext(this).resourceManager.getStringSync($r('app.string.save_changes')) :
        getContext(this).resourceManager.getStringSync($r('app.string.add_relief_method_btn')))
          .onClick(() => { this.saveRelief(); })
          .width('100%')
          .height(44)
          .backgroundColor('#4285F4')
          .fontColor(Color.White)
          .borderRadius(22)
          .margin({ top: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#f0f0f0')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }

  deleteRelief(index: number) {
    this.reliefList.splice(index, 1);
    if (this.editingIndex === index) {
      this.editingIndex = -1;
      this.newTitle = '';
      this.newDesc = '';
      this.newCover = '';
      this.newCategory = getContext(this).resourceManager.getStringSync($r('app.string.category_whole_body'));
    }
  }

  editRelief(index: number) {
    this.editingIndex = index;
    this.newTitle = this.reliefList[index].title;
    this.newDesc = this.reliefList[index].desc;
    this.newCover = this.reliefList[index].cover;
    this.newCategory = this.reliefList[index].category;
  }

  saveRelief() {
    if (!this.newTitle || !this.newDesc) return;
    if (this.editingIndex >= 0) {
      this.reliefList[this.editingIndex].title = this.newTitle;
      this.reliefList[this.editingIndex].desc = this.newDesc;
      this.reliefList[this.editingIndex].cover = this.newCover || 'images/relief_default.png';
      this.reliefList[this.editingIndex].category = this.newCategory;
      this.editingIndex = -1;
    } else {
      this.reliefList.push({
        title: this.newTitle,
        desc: this.newDesc,
        cover: this.newCover || 'images/relief_default.png',
        category: this.newCategory,
        favorite: false
      });
    }
    this.newTitle = '';
    this.newDesc = '';
    this.newCover = '';
    this.newCategory = getContext(this).resourceManager.getStringSync($r('app.string.category_whole_body'));
  }
}