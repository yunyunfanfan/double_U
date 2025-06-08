
///睡眠改善页面

import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';

interface ImproveItem {
  title: string;
  desc: string;
  image: string;
  category: string;
  favorite: boolean;
}

interface CategoryOption {
  value: string;
}

@Entry
@Component
export struct SleepImprovePage {
  @State improveList: ImproveItem[] = [];
  @State newTitle: string = '';
  @State newDesc: string = '';
  @State newImage: string = '';
  @State newCategory: string = '';
  @State editingIndex: number = -1;
  @State categoryOptions: CategoryOption[] = [];

  aboutToAppear() {
    this.initData();
  }

  initData() {
    this.newCategory = getContext(this).resourceManager.getStringSync($r('app.string.category_schedule'));

    this.categoryOptions = [
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_schedule')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_relaxation')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_environment')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_diet')) },
      { value: getContext(this).resourceManager.getStringSync($r('app.string.category_exercise')) }
    ];

    this.improveList = [
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.regular_schedule_sleep')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.regular_schedule_desc')),
        image: 'images/schedule.png',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_schedule')),
        favorite: false
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.bedtime_relaxation')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.bedtime_relaxation_desc')),
        image: 'images/relax.png',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_relaxation')),
        favorite: false
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.reduce_electronics')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.reduce_electronics_desc')),
        image: 'images/no_phone.png',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_environment')),
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
        Text($r('app.string.sleep_improvement'))
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
          ForEach(this.improveList, (item: ImproveItem, index: number) => {
            ListItem() {
              Row() {
                Image($rawfile(item.image))
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
                  .onClick(() => { this.deleteImprove(index); })
                  .width(32)
                  .height(32)
                  .backgroundColor('#FFE5E5')
                  .margin({ bottom: 8 })
                  Button({ type: ButtonType.Circle }) {
                    Image($r('app.media.ic_back'))
                      .width(18)
                      .height(18)
                  }
                  .onClick(() => { this.editImprove(index); })
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
        getContext(this).resourceManager.getStringSync($r('app.string.edit_sleep_suggestion')) :
        getContext(this).resourceManager.getStringSync($r('app.string.add_sleep_suggestion')))
          .fontSize(16)
          .margin({ bottom: 8 })
        TextInput({
          placeholder: getContext(this).resourceManager.getStringSync($r('app.string.suggestion_title_placeholder')),
          text: this.newTitle
        })
          .onChange((value: string) => { this.newTitle = value; })
          .margin({ bottom: 8 })
        TextInput({
          placeholder: getContext(this).resourceManager.getStringSync($r('app.string.suggestion_desc_placeholder')),
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
        getContext(this).resourceManager.getStringSync($r('app.string.add_suggestion')))
          .onClick(() => { this.saveImprove(); })
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

  deleteImprove(index: number) {
    this.improveList.splice(index, 1);
    if (this.editingIndex === index) {
      this.editingIndex = -1;
      this.newTitle = '';
      this.newDesc = '';
      this.newImage = '';
      this.newCategory = getContext(this).resourceManager.getStringSync($r('app.string.category_schedule'));
    }
  }

  editImprove(index: number) {
    this.editingIndex = index;
    this.newTitle = this.improveList[index].title;
    this.newDesc = this.improveList[index].desc;
    this.newImage = this.improveList[index].image;
    this.newCategory = this.improveList[index].category;
  }

  saveImprove() {
    if (!this.newTitle || !this.newDesc) return;
    if (this.editingIndex >= 0) {
      this.improveList[this.editingIndex].title = this.newTitle;
      this.improveList[this.editingIndex].desc = this.newDesc;
      this.improveList[this.editingIndex].image = this.newImage || 'images/sleep_default.png';
      this.improveList[this.editingIndex].category = this.newCategory;
      this.editingIndex = -1;
    } else {
      this.improveList.push({
        title: this.newTitle,
        desc: this.newDesc,
        image: this.newImage || 'images/sleep_default.png',
        category: this.newCategory,
        favorite: false
      });
    }
    this.newTitle = '';
    this.newDesc = '';
    this.newImage = '';
    this.newCategory = getContext(this).resourceManager.getStringSync($r('app.string.category_schedule'));
  }
}