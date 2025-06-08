
///助眠音乐页面

import { BaseNavigation } from 'JhCommon';
import { router } from '@kit.ArkUI';
import media from '@ohos.multimedia.media';

@CustomDialog
struct AddMusicDialog {
  controller: CustomDialogController;
  addMusicToList!: (newMusic: MusicItem) => void;

  @State title: string = '';
  @State desc: string = '';
  @State category: string = '';
  @State duration: string = '00:00';

  build(): void {
    Column() {
      Text(getContext(this).resourceManager.getStringSync($r('app.string.add_new_music')))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 });

      TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.song_title_placeholder')) })
        .onChange((value: string) => { this.title = value; })
        .margin({ bottom: 10 })
        .width('90%');

      TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.song_desc_placeholder')) })
        .onChange((value: string) => { this.desc = value; })
        .margin({ bottom: 10 })
        .width('90%');

      TextInput({ placeholder: getContext(this).resourceManager.getStringSync($r('app.string.category_placeholder')) })
        .onChange((value: string) => { this.category = value; })
        .margin({ bottom: 10 })
        .width('90%');

      Button(getContext(this).resourceManager.getStringSync($r('app.string.select_audio_file')))
        .onClick(() => {
          console.info("文件选择器待实现");
        })
        .margin({ bottom: 20 })
        .width('90%');

      Row({ space: 10 }) {
        Button(getContext(this).resourceManager.getStringSync($r('app.string.cancel')))
          .onClick(() => {
            this.controller.close();
          })
          .layoutWeight(1)
          .backgroundColor('#E0E0E0')
          .fontColor(Color.Black);

        Button(getContext(this).resourceManager.getStringSync($r('app.string.add')))
          .onClick(() => {
            if (this.title.trim() && this.desc.trim()) {
              const newMusic: MusicItem = {
                title: this.title.trim(),
                desc: this.desc.trim(),
                cover: 'images/default_cover.png',
                path: '',
                favorite: false,
                duration: '00:00',
                category: this.category.trim() || getContext(this).resourceManager.getStringSync($r('app.string.category_custom'))
              };
              this.addMusicToList(newMusic);
              this.controller.close();
            } else {
              console.error('请填写所有必填项');
            }
          })
          .layoutWeight(1)
          .backgroundColor('#4285F4')
          .fontColor(Color.White);
      }
      .width('90%')
      .margin({ bottom: 0 });
    }
    .padding(20)
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(15)
    .shadow({ radius: 10, color: '#80000000' });
  }
}

interface MusicItem {
  title: string;
  desc: string;
  cover: string;
  path: string;
  favorite: boolean;
  duration: string;
  category: string;
}

enum PlayMode {
  Order = 'order',
  Repeat = 'repeat',
  Shuffle = 'shuffle'
}

const PlayModeIconMap: Record<PlayMode, Resource> = {
  [PlayMode.Order]: $r('app.media.ic_mode_order'),
  [PlayMode.Repeat]: $r('app.media.ic_mode_repeat'),
  [PlayMode.Shuffle]: $r('app.media.ic_mode_shuffle')
};

@Entry
@Component
export struct SleepMusicPage {
  @State musicList: MusicItem[] = [];
  @State currentIndex: number = -1;
  @State isPlaying: boolean = false;
  @State progress: number = 0;
  @State currentDurationInSeconds: number = 0;
  @State volume: number = 80;
  @State isLoop: boolean = false;
  @State isShuffle: boolean = false;
  @State showTimer: boolean = false;
  @State sleepTimer: number = 0;
  @State playMode: string = 'order';
  @State playbackRate: number = 1.0;
  private audioPlayer: object | null = null;
  private progressTimer: number | null = null;

  aboutToAppear() {
    this.initMusicList();
  }

  initMusicList() {
    this.musicList = [
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.natural_rain')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.natural_rain_desc')),
        cover: 'images/rain.png.jpg',
        path: '',
        favorite: false,
        duration: '30:00',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_nature'))
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.white_noise')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.white_noise_desc')),
        cover: 'images/white_noise.png.jpg',
        path: '',
        favorite: false,
        duration: '45:00',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_white_noise'))
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.light_music')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.light_music_desc')),
        cover: 'images/light_music.png.jpg',
        path: '',
        favorite: false,
        duration: '60:00',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_light_music'))
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.meditation_guide')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.meditation_guide_desc')),
        cover: 'images/meditation.png.jpg',
        path: '',
        favorite: false,
        duration: '20:00',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_meditation'))
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.bedtime_story')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.bedtime_story_desc')),
        cover: 'images/story.png.jpg',
        path: '',
        favorite: false,
        duration: '15:00',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_story'))
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.forest_birds')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.forest_birds_desc')),
        cover: 'images/forest.jpg',
        path: '',
        favorite: false,
        duration: '25:00',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_nature'))
      },
      {
        title: getContext(this).resourceManager.getStringSync($r('app.string.ocean_waves')),
        desc: getContext(this).resourceManager.getStringSync($r('app.string.ocean_waves_desc')),
        cover: 'images/waves.jpg',
        path: '',
        favorite: false,
        duration: '35:00',
        category: getContext(this).resourceManager.getStringSync($r('app.string.category_nature'))
      }
    ];
  }

  private handleAudioError(): void {
    console.error('Audio Error occurred on player (handled by dedicated method - 0 params).');
  }

  addMusicDialogController: CustomDialogController = new CustomDialogController({
    builder: AddMusicDialog({ addMusicToList: (newMusic: MusicItem): void => this.addNewMusicItem(newMusic) }),
    autoCancel: true
  });

  parseDurationToSeconds(durationStr: string): number {
    const parts = durationStr.split(':');
    if (parts.length === 2) {
      const minutes = parseInt(parts[0], 10);
      const seconds = parseInt(parts[1], 10);
      if (!isNaN(minutes) && !isNaN(seconds)) {
        return minutes * 60 + seconds;
      }
    }
    return 0;
  }

  build(): void {
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
        Text($r('app.string.sleep_music_title'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
          .margin({ top: 20, bottom: 20 })
        Blank().layoutWeight(1)
        Button({ type: ButtonType.Circle }) {
          Text('+')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4285F4')
        }
        .onClick(() => { this.uploadMusic(); })
        .width(40)
        .height(40)
        .backgroundColor('#E5F0FF')
        .margin({ right: 10 })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F8F8F8')

      Scroll() {
        Column() {
          ForEach(this.musicList, (item: MusicItem, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  Image($rawfile(item.cover))
                    .width(60)
                    .height(60)
                    .borderRadius(8)
                    .margin({ right: 10 })
                  Column() {
                    Row() {
                      Text(item.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.currentIndex === index ? '#4285F4' : '#222222')
                        .flexShrink(1)
                        .layoutWeight(1)
                      Text(item.duration)
                        .fontSize(14)
                        .fontColor('#999999')
                        .margin({ left: 8 })
                      Button({ type: ButtonType.Circle }) {
                        Image($r('app.media.ic_play')).width(24).height(24)
                      }
                      .onClick(() => { this.playMusic(index); })
                      .width(40).height(40)
                      .backgroundColor('#E5F0FF')
                      .margin({ left: 8 })
                      Button({ type: ButtonType.Circle }) {
                        Image($r('app.media.ic_delete'))
                          .width(18)
                          .height(18)
                      }
                      .onClick(() => { this.deleteMusic(index); })
                      .width(32)
                      .height(32)
                      .backgroundColor('#FFE5E5')
                      .margin({ left: 8 })
                    }
                    .width('100%')

                    Text(item.desc)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 5 })
                    Text(item.category)
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(12)

                if (this.currentIndex === index) {
                  Column() {
                    Row() {
                      Text(this.formatTime(this.progress))
                        .fontSize(13).fontColor('#666666')
                      Slider({
                        value: this.progress,
                        min: 0,
                        max: this.currentDurationInSeconds > 0 ? this.currentDurationInSeconds : 100,
                        step: 1
                      })
                        .onChange((value: number) => {
                          this.progress = value;
                          this.seekMusic(value);
                        })
                        .width('60%')
                        .margin({ left: 8, right: 8 })
                      Text(this.formatTime(this.currentDurationInSeconds))
                        .fontSize(13).fontColor('#666666')
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Center)
                    .margin({ top: 10 })

                    Row({ space: 24 }) {
                      Button({ type: ButtonType.Circle }) {
                        Image(this.getPlayModeIcon()).width(28).height(28)
                      }
                      .onClick(() => { this.switchPlayMode(); })
                      .width(44).height(44).backgroundColor('#F0F0F0')

                      Button({ type: ButtonType.Circle }) {
                        Image(this.getPlayPauseIcon()).width(36).height(36)
                      }
                      .onClick(() => { this.togglePlay(); })
                      .width(56).height(56).backgroundColor('#F0F0F0')

                      Button({ type: ButtonType.Circle }) {
                        Text(this.playbackRate.toFixed(1) + 'x')
                          .fontSize(18).fontColor('#4285F4')
                      }
                      .onClick(() => { this.switchPlaybackRate(); })
                      .width(44).height(44).backgroundColor('#F0F0F0')
                    }
                    .justifyContent(FlexAlign.Center)
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                  .backgroundColor(this.currentIndex === index ? '#E8F0FE' : Color.Transparent)
                  .borderRadius(8)
                  .margin({ top: 8 })
                }
              }
              .backgroundColor(this.currentIndex === index ? '#F0F8FF' : Color.White)
              .borderRadius(14)
              .margin({ bottom: 12 })
              .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
            }
          })
        }
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F0F0F0')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return mins.toString().padStart(2, '0') + ':' + secs.toString().padStart(2, '0');
  }

  playMusic(index: number) {
    if (this.currentIndex !== index) {
      this.currentIndex = index;
      this.progress = 0;
      this.currentDurationInSeconds = this.parseDurationToSeconds(this.musicList[index].duration);
    }
    if (!this.isPlaying || this.currentIndex !== index) {
      this.togglePlay();
    } else {
      this.togglePlay();
    }
    if (this.progressTimer) {
      clearInterval(this.progressTimer);
    }
    this.progressTimer = setInterval(() => {
      if (this.isPlaying && this.currentIndex !== -1) {
        if (this.progress < this.currentDurationInSeconds) {
          this.progress++;
        } else {
          clearInterval(this.progressTimer);
          this.progressTimer = null;
        }
      }
    }, 1000);
  }

  togglePlay() {
    this.isPlaying = !this.isPlaying;
    if (this.isPlaying) {
      if (this.currentIndex === -1 && this.musicList.length > 0) {
        this.currentIndex = 0;
        this.currentDurationInSeconds = this.parseDurationToSeconds(this.musicList[this.currentIndex].duration);
      }
      if(this.currentIndex !== -1) {
        console.log("Mock: Play " + this.musicList[this.currentIndex].title);
      }
      if (this.progressTimer) {
        clearInterval(this.progressTimer);
      }
      this.progressTimer = setInterval(() => {
        if (this.isPlaying && this.currentIndex !== -1) {
          if (this.progress < this.currentDurationInSeconds) {
            this.progress++;
          } else {
            clearInterval(this.progressTimer);
            this.progressTimer = null;
          }
        }
      }, 1000);
    } else {
      console.log("Mock: Pause");
      if (this.progressTimer) {
        clearInterval(this.progressTimer);
        this.progressTimer = null;
      }
    }
  }

  prevMusic() {
    if (this.musicList.length === 0) return;
    let prev = this.currentIndex - 1;
    if (prev < 0) prev = this.musicList.length - 1;
    this.playMusic(prev);
  }

  nextMusic() {
    if (this.musicList.length === 0) return;
    let next = (this.currentIndex + 1) % this.musicList.length;
    this.playMusic(next);
  }

  seekMusic(value: number) {
    this.progress = value;
    console.log('Mock: Seek to ' + value.toString() + 's');
  }

  deleteMusic(index: number) {
    this.musicList.splice(index, 1);
    if (this.currentIndex === index) {
      this.currentIndex = -1;
      this.isPlaying = false;
      this.progress = 0;
      if (this.progressTimer) {
        clearInterval(this.progressTimer);
        this.progressTimer = null;
      }
    } else if (this.currentIndex > index) {
      this.currentIndex--;
    }
  }

  uploadMusic() {
    this.addMusicDialogController.open();
  }

  addNewMusicItem(newMusic: MusicItem) {
    this.musicList.push(newMusic);
  }

  switchPlayMode() {
    if (this.playMode === 'order') this.playMode = 'repeat';
    else if (this.playMode === 'repeat') this.playMode = 'shuffle';
    else this.playMode = 'order';
  }

  switchPlaybackRate() {
    if (this.playbackRate === 1.0) this.playbackRate = 1.5;
    else if (this.playbackRate === 1.5) this.playbackRate = 2.0;
    else this.playbackRate = 1.0;
  }

  getPlayModeIcon(): Resource {
    return PlayModeIconMap[this.playMode as PlayMode] || $r('app.media.ic_mode_order');
  }

  getPlayPauseIcon(): Resource {
    return this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play');
  }
}