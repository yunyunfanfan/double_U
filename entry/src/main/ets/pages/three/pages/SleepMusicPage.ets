import { BaseNavigation } from 'JhCommon';
import { promptAction, router } from '@kit.ArkUI';
import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 定义媒体错误接口
interface MediaError {
  code: number;
  message: string;
}

// 定义添加音乐对话框
@CustomDialog
struct AddMusicDialog {
  controller: CustomDialogController;
  addMusicToList!: (newMusic: MusicItem) => void;

  @State title: string = '';
  @State desc: string = '';
  @State category: string = '自定义';
  @State duration: string = '00:00';

  build(): void {
    Column() {
      Text('添加新音乐')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 });

      TextInput({ placeholder: '歌曲标题' })
        .onChange((value: string) => { this.title = value; })
        .margin({ bottom: 10 })
        .width('90%');

      TextInput({ placeholder: '歌曲描述' })
        .onChange((value: string) => { this.desc = value; })
        .margin({ bottom: 10 })
        .width('90%');

      TextInput({ placeholder: '分类 (例如: 轻音乐)' })
        .onChange((value: string) => { this.category = value; })
        .margin({ bottom: 10 })
        .width('90%');

      Button('选择音频文件 (待实现)')
        .onClick(() => {
          console.info("文件选择器待实现");
        })
        .margin({ bottom: 20 })
        .width('90%');

      Row({ space: 10 }) {
        Button('取消')
          .onClick(() => {
            this.controller.close();
          })
          .layoutWeight(1)
          .backgroundColor('#E0E0E0')
          .fontColor(Color.Black);

        Button('添加')
          .onClick(() => {
            if (this.title.trim() && this.desc.trim()) {
              const newMusic: MusicItem = {
                title: this.title.trim(),
                desc: this.desc.trim(),
                cover: 'images/default_cover.png',
                path: 'entry/src/main/resources/rawfile/audio/' + this.title.trim().replace(/\s+/g, '_') + '.mp3',
                favorite: false,
                duration: this.duration,
                category: this.category.trim() || '自定义'
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
  @State musicList: MusicItem[] = [
    {
      title: '自然雨声',
      desc: '舒缓的雨声，帮助放松心情',
      cover: 'images/rain.png.jpg',
      path: 'entry/src/main/resources/rawfile/audio/rain.mp3',
      favorite: false,
      duration: '30:00',
      category: '自然音效'
    },
    {
      title: '白噪音',
      desc: '稳定的白噪音，掩盖环境杂音',
      cover: 'images/white_noise.png.jpg',
      path: 'entry/src/main/resources/rawfile/audio/white_noise.m4a',
      favorite: false,
      duration: '45:00',
      category: '白噪音'
    },
    {
      title: '轻音乐',
      desc: '柔和的轻音乐，促进睡眠',
      cover: 'images/light_music.png.jpg',
      path: 'entry/src/main/resources/rawfile/audio/light_music.mp3',
      favorite: false,
      duration: '60:00',
      category: '轻音乐'
    },
    {
      title: '冥想引导',
      desc: '放松身心的冥想引导音频',
      cover: 'images/meditation.png.jpg',
      path: 'entry/src/main/resources/rawfile/audio/meditation.wav',
      favorite: false,
      duration: '20:00',
      category: '冥想音乐'
    },
    {
      title: '睡前故事',
      desc: '温柔的助眠故事，伴你入眠',
      cover: 'images/story.png.jpg',
      path: 'entry/src/main/resources/rawfile/audio/story.mp3',
      favorite: false,
      duration: '15:00',
      category: '助眠故事'
    },
    {
      title: '森林鸟鸣',
      desc: '清晨的森林，悦耳的鸟叫声伴您入眠',
      cover: 'images/forest.jpg',
      path: 'entry/src/main/resources/rawfile/audio/forest.mp3',
      favorite: false,
      duration: '25:00',
      category: '自然音效'
    },
    {
      title: '海浪声声',
      desc: '轻柔的海浪拍打沙滩，放松身心',
      cover: 'images/waves.jpg',
      path: 'entry/src/main/resources/rawfile/audio/waves.wav',
      favorite: false,
      duration: '35:00',
      category: '自然音效'
    }
  ];
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
  @State isSliderEnabled: boolean = false;
  private avPlayer: media.AVPlayer | null = null;
  private progressTimer: number | null = null;
  private isSeek: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  // private avPlayer: media.AVPlayer | null = null; // 播放器实例

  // 根据官方文档实现状态回调
  private setAVPlayerCallback(avPlayer: media.AVPlayer) {
    // 状态变化回调
    avPlayer.on('stateChange', (state: string, reason: media.StateChangeReason) => {
      console.info(`State changed to: ${state}, reason: ${reason}`);

      switch (state) {
        case 'initialized':
          console.info('AVPlayer initialized');
          avPlayer.prepare();
          break;

        case 'prepared':
          console.info('AVPlayer prepared');
          // 获取音频时长（毫秒转换为秒）
          this.currentDurationInSeconds = Math.floor(avPlayer.duration / 1000);
          avPlayer.play();
          break;

        case 'playing':
          console.info('AVPlayer playing');
          this.isPlaying = true;
          // 启动进度更新定时器
          this.startProgressTimer();
          break;

        case 'paused':
          console.info('AVPlayer paused');
          this.isPlaying = false;
          this.stopProgressTimer();
          break;

        case 'completed':
          console.info('AVPlayer completed');
          this.isPlaying = false;
          this.progress = 0;
          this.stopProgressTimer();
          // 根据播放模式决定下一步操作
          if (this.playMode === 'repeat') {
            this.seekTo(0);
            avPlayer.play();
          } else {
            this.nextMusic();
          }
          break;

        case 'stopped':
          console.info('AVPlayer stopped');
          this.isPlaying = false;
          this.progress = 0;
          this.stopProgressTimer();
          break;

        case 'released':
          console.info('AVPlayer released');
          this.avPlayer = null;
          break;

        case 'error':
          console.error('AVPlayer error state');
          this.handlePlayerError();
          break;
      }
    });

    // 错误回调
    avPlayer.on('error', (err: BusinessError) => {
      console.error(`Player error: ${err.code}, ${err.message}`);
      this.handlePlayerError();
    });

    // 播放进度更新回调
    avPlayer.on('timeUpdate', (time: number) => {
      if (!this.isSeek) {
        this.progress = time / 1000; // 毫秒转秒
      }
    });

    // 跳转完成回调
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      console.info(`Seek completed to: ${seekDoneTime}ms`);
      this.isSeek = false;
      this.progress = seekDoneTime / 1000;
    });

    // 倍速设置完成回调
    avPlayer.on('speedDone', (speed: number) => {
      console.info(`Speed set to: ${speed}`);
    });

    // 音量设置完成回调
    avPlayer.on('volumeChange', (volume: number) => {
      console.info(`Volume set to: ${volume}`);
    });
  }

  // 启动进度定时器
  private startProgressTimer() {
    if (this.progressTimer) {
      clearInterval(this.progressTimer);
    }
    this.progressTimer = setInterval(() => {
      if (this.avPlayer && this.isPlaying) {
        // 使用timeUpdate事件更新进度，此处作为后备
        this.progress = this.avPlayer.currentTime / 1000;
      }
    }, 1000);
  }

  // 停止进度定时器
  private stopProgressTimer() {
    if (this.progressTimer) {
      clearInterval(this.progressTimer);
      this.progressTimer = null;
    }
  }

  // 处理播放器错误
  private handlePlayerError() {
    this.isPlaying = false;
    this.progress = 0;
    this.stopProgressTimer();

    if (this.avPlayer) {
      this.avPlayer.release();
      this.avPlayer = null;
    }
  }

  async aboutToAppear() {
    // // 不需要提前创建播放器
    // // 初始化播放器
    // this.avPlayer = await media.createAVPlayer();
    // media.createAVPlayer().then((video: media.AVPlayer) => {
    //   if (video != null) {
    //     this.avPlayer = video;
    //     console.info('createAVPlayer success');
    //     hilog.info(0x000, 'info111', 'chushisuccess'+JSON.stringify(video))
    //
    //     // setTimeout(() => {
    //     //   this.playAudio()
    //     // }, 1000)
    //   } else {
    //     console.error('createAVPlayer fail');
    //     hilog.info(0x000, 'info111', 'chushifail'+JSON.stringify(video))
    //   }
    // }).catch((error: BusinessError) => {
    //   hilog.info(0x000, 'info111', 'chushihuashibai'+JSON.stringify(error.message))
    //   console.error(`AVPlayer catchCallback, error message:${error.message}`);
    // });
  }

  async  createAVPlayerFn(cb: () => void) {
    media.createAVPlayer().then((video: media.AVPlayer) => {
      if (video != null) {
        this.avPlayer = video;
        console.info('createAVPlayer success');
        hilog.info(0x000, 'info111', 'chushisuccess'+JSON.stringify(video))

        setTimeout(() => {
          // this.playAudio()
          cb && cb()
        }, 200)
      } else {
        console.error('createAVPlayer fail');
        hilog.info(0x000, 'info111', 'chushifail'+JSON.stringify(video))
      }
    }).catch((error: BusinessError) => {
      hilog.info(0x000, 'info111', 'chushihuashibai'+JSON.stringify(error.message))
      console.error(`AVPlayer catchCallback, error message:${error.message}`);
    });
  }

  // 播放网络音频
  async playAudio() {
    // $rawfile('audio/white_noise.m4a')
    if (!this.avPlayer) return;

    try {
      let context = getContext(this) as common.UIAbilityContext
      let fileDescriptor = await context.resourceManager.getRawFd('white_noise.m4a')
      // this.avPlayer?.setSource($rawfile('audio/waves.wav'));    // 设置音频链接
      this.avPlayer.fdSrc = fileDescriptor
      await this.avPlayer.prepare();    // 准备播放
      await this.avPlayer.play();       // 开始播放
      this.isPlaying = true;
      // hilog.info(0x000, 'info', '播放'+ url)
    } catch (error) {
      console.error('播放失败:', error);
      hilog.info(0x000, 'musicplay', '播放失败'+ JSON.stringify(error))
    }
  }

  aboutToDisappear() {
    this.releasePlayer();
  }

  // 释放播放器资源
  private releasePlayer() {
    if (this.avPlayer) {
      if (this.isPlaying) {
        this.avPlayer.stop();
      }
      this.avPlayer.release();
      this.avPlayer = null;
    }
    this.stopProgressTimer();
    this.isPlaying = false;
    this.progress = 0;
  }

  // 播放/暂停控制
  async handlePlayPause() {
    if (!this.avPlayer) {
      if (this.musicList.length > 0) {
        await this.playMusic(this.currentIndex >= 0 ? this.currentIndex : 0);
      }
      return;
    }

    try {
      if (this.isPlaying) {
        await this.avPlayer.pause();
      } else {
        await this.avPlayer.play();
      }
    } catch (err) {
      console.error(`Play/pause failed: ${JSON.stringify(err)}`);
    }
  }

  // 跳转到指定位置
  private async seekTo(position: number) {
    if (!this.avPlayer || position < 0) return;

    try {
      this.isSeek = true;
      await this.avPlayer.seek(position * 1000); // 秒转毫秒
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Seek failed: ${err.code}, ${err.message}`);
      this.isSeek = false;
    }
  }

  // 下一首
  private async nextMusic() {
    let nextIndex = this.currentIndex + 1;
    if (nextIndex >= this.musicList.length) {
      nextIndex = 0;
    }
    await this.playMusic(nextIndex);
  }

  // 上一首
  private async previousMusic() {
    let prevIndex = this.currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = this.musicList.length - 1;
    }
    await this.playMusic(prevIndex);
  }

  // 设置音量
  private async setVolume(value: number) {
    this.volume = value;
    if (this.avPlayer) {
      try {
        await this.avPlayer.setVolume(value / 100);
      } catch (error) {
        const err = error as BusinessError;
        console.error(`Set volume failed: ${err.code}, ${err.message}`);
      }
    }
  }

  // 播放指定音乐
  private async playMusic(index: number) {
    hilog.info(0x000, 'musicplay', 'playMusic')
    if (index < 0 || index >= this.musicList.length) return;

    // // 释放当前播放器
    this.releasePlayer();

    this.createAVPlayerFn(async() => {
      // $rawfile('audio/white_noise.m4a')
      if (!this.avPlayer) return;

      const track = this.musicList[index];
      this.currentIndex = index;

      // 获取资源文件描述符
      const fileName = track.path.substring(track.path.lastIndexOf('/') + 1);
      hilog.info(0x000, 'musicplay', 'fileName'+fileName)

      try {
        let context = getContext(this) as common.UIAbilityContext
        let fileDescriptor = await context.resourceManager.getRawFd(fileName)
        // this.avPlayer?.setSource($rawfile('audio/waves.wav'));    // 设置音频链接
        this.avPlayer.fdSrc = fileDescriptor

        this.setAVPlayerCallback(this.avPlayer);
        // // 重置进度
        // this.progress = 0;
        // this.isSliderEnabled = true;
        //
        // // 获取音频时长（毫秒转换为秒）
        // this.currentDurationInSeconds = Math.floor(this.avPlayer.duration / 1000);

        await this.avPlayer.prepare();    // 准备播放
        await this.avPlayer.play();       // 开始播放
        this.isPlaying = true;
        // hilog.info(0x000, 'info', '播放'+ url)
      } catch (error) {
        console.error('播放失败:', error);
        hilog.info(0x000, 'musicplay', '播放失败'+ JSON.stringify(error))
        // promptAction.showToast({
        //   message: '播放失败'
        // })
      }
    })



    return;


    hilog.info(0x000, 'musicplay', 'playMusic')
    if (index < 0 || index >= this.musicList.length) return;

    // this.playAudio()
    //
    // return;
    // // 释放当前播放器
    // this.releasePlayer();


    try {
      // // 创建新播放器
      // this.avPlayer = await media.createAVPlayer();
      // this.setAVPlayerCallback(this.avPlayer);
      hilog.info(0x000, 'musicplay', 'this.avPlayer'+JSON.stringify(this.avPlayer))
      const track = this.musicList[index];
      this.currentIndex = index;

      // 获取资源文件描述符
      const fileName = track.path.substring(track.path.lastIndexOf('/') + 1);
      hilog.info(0x000, 'musicplay', 'fileName'+fileName)

      let context = getContext(this) as common.UIAbilityContext
      let fileDescriptor = await context.resourceManager.getRawFd('white_noise.m4a')
      // this.avPlayer?.setSource($rawfile('audio/waves.wav'));    // 设置音频链接
      if(this.avPlayer) {
        // this.avPlayer.fdSrc = fileDescriptor
        // await this.avPlayer.prepare();    // 准备播放
        // await this.avPlayer.play();       // 开始播放
      }



      // const context = getContext(this) as common.UIAbilityContext;
      // const fileDescriptor = await context.resourceManager.getRawFd(fileName);
      //
      // // 设置播放源 (使用官方推荐的fdSrc)
      // // const avFileDescriptor: media.AVFileDescriptor = {
      // //   fd: fileDescriptor.fd,
      // //   // offset: fileDescriptor.offset,
      // //   // length: fileDescriptor.length
      // // };
      // // let context = getContext(this) as common.UIAbilityContext
      // // let fileDescriptor = await context.resourceManager.getRawFd('white_noise.m4a')
      //
      // this.avPlayer.fdSrc = fileDescriptor;
      //
      // // // 设置播放参数
      // // this.avPlayer.loop = this.playMode === 'repeat';
      // // this.avPlayer.setVolume(this.volume / 100);
      // // this.avPlayer.setSpeed(this.playbackRate);
      //
      // // // 重置进度
      // // this.progress = 0;
      // // this.isSliderEnabled = true;
      //
      // await this.avPlayer.prepare();    // 准备播放
      // await this.avPlayer.play();       // 开始播放

    } catch (error) {
      // 5400102 错误 message is Operate Not Permit: operation not be permitted
      // 是因为media.createAVPlayer执行了多次，可以先释放
      const err = error as BusinessError;
      hilog.info(0x000, 'musicplay', 'err'+`Play music failed: ${err.code}, ${err.message}`)
      console.error(`Play music failed: ${err.code}, ${err.message}`);
      this.handlePlayerError();
    }


  }

  build(): void {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r('app.media.ic_back'))
            .width(20)
            .height(20)
        }
        .onClick(() => {
          try {
            if (this.avPlayer) {
              this.avPlayer.stop();
              this.avPlayer.release();
              this.avPlayer = null;
            }
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
        Text('助眠音乐')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
          .margin({ top: 20, bottom: 20 })
        Blank().layoutWeight(1)
        Button({ type: ButtonType.Circle, stateEffect: true }) {
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
                        .fontSize(item.title === '自然雨声' ? 16 : 18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.currentIndex === index ? '#007DFF' : '#222222')
                        .flexShrink(1)
                        .layoutWeight(1)
                      Text(item.duration)
                        .fontSize(14)
                        .fontColor('#999999')
                        .margin({ left: 8 })
                      Button({ type: ButtonType.Circle, stateEffect: true }) {
                        Image(this.currentIndex === index && this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
                          .width(24).height(24)
                      }
                      .onClick(() => {
                        if (this.currentIndex === index) {
                          this.handlePlayPause();
                        } else {
                          this.playMusic(index);
                        }
                      })
                      .width(40).height(40)
                      .backgroundColor('#E5F0FF')
                      .margin({ left: 8 })
                      Button({ type: ButtonType.Circle, stateEffect: true }) {
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

                // 关键修复：确保控制面板在选中时显示
                if (this.currentIndex === index) {
                  Column() {
                    Row() {
                      Text(this.formatTime(this.progress))
                        .fontSize(12)
                        .fontColor(Color.Gray)
                        .margin({ right: 8 })
                      Slider({
                        value: this.progress,
                        min: 0,
                        max: this.currentDurationInSeconds > 0 ? this.currentDurationInSeconds : 100,
                        step: 1
                      })
                        .enabled(this.isSliderEnabled)
                        .onChange((value: number) => { this.seekTo(value); })
                        .layoutWeight(1)
                        .trackColor(Color.Gray)
                        .selectedColor('#007DFF')
                        .blockColor('#007DFF')
                      Text(this.formatTime(this.currentDurationInSeconds))
                        .fontSize(12)
                        .fontColor(Color.Gray)
                        .margin({ left: 8 })
                    }
                    .width('100%')
                    .padding({ left: 15, right: 15 })
                    .margin({ top: 15, bottom: 10 })
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Button({ type: ButtonType.Normal }) {
                        Image($r('app.media.ic_prev_track'))
                          .width(24).height(24)
                          .fillColor('#007DFF')
                      }
                      .onClick(() => this.previousMusic())
                      .backgroundColor(Color.Transparent)
                      .width(48).height(48)
                      .borderRadius(24)
                      .clip(true)

                      Blank().layoutWeight(0.3)

                      Button({ type: ButtonType.Circle }) {
                        Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
                          .width(36).height(36)
                          .fillColor(Color.White)
                      }
                      .onClick(() => this.handlePlayPause())
                      .width(64).height(64)
                      .backgroundColor('#007DFF')
                      .shadow({ radius: 3, color: '#A0A0A0', offsetY: 1 })

                      Blank().layoutWeight(0.3)

                      Button({ type: ButtonType.Normal }) {
                        Image($r('app.media.ic_next_track'))
                          .width(24).height(24)
                          .fillColor('#007DFF')
                      }
                      .onClick(() => this.nextMusic())
                      .backgroundColor(Color.Transparent)
                      .width(48).height(48)
                      .borderRadius(24)
                      .clip(true)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Center)
                    .alignItems(VerticalAlign.Center)
                    .margin({ top: 10, bottom: 10 })

                    Row() {
                      Button({ type: ButtonType.Normal }) {
                        Image(this.getPlayModeIcon())
                          .width(22).height(22)
                          .fillColor(Color.Gray)
                      }
                      .onClick(() => this.switchPlayMode())
                      .backgroundColor(Color.Transparent)
                      .width(44).height(44)
                      .borderRadius(22)
                      .clip(true)

                      Button({ type: ButtonType.Normal }) {
                        Text(`${this.playbackRate.toFixed(1)}x`)
                          .fontSize(14)
                          .fontColor(Color.Gray)
                      }
                      .onClick(() => this.switchPlaybackRate())
                      .backgroundColor(Color.Transparent)
                      .height(44)
                      .borderRadius(22)
                      .clip(true)
                      .padding({ left: 10, right: 10 })
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceAround)
                    .alignItems(VerticalAlign.Center)
                    .margin({ bottom: 10 })
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8, left: 12, right: 12 })
                  .backgroundColor('#E8F0FE')
                  .borderRadius(8)
                  .margin({ top: 8 })
                }
              }
              .backgroundColor(this.currentIndex === index ? '#F0F8FF' : Color.White)
              .borderRadius(14)
              .margin({ bottom: 12 })
              .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
            }
            // 添加点击事件支持点击整行切换播放
            .onClick(() => {
              if (this.currentIndex === index) {
                this.handlePlayPause();
              } else {
                this.playMusic(index);
              }
            })
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

  async deleteMusic(index: number) {
    if (this.currentIndex === index) {
      this.releasePlayer();
    }

    this.musicList.splice(index, 1);

    if (this.currentIndex === index) {
      this.currentIndex = -1;
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

    if (this.avPlayer) {
      this.avPlayer.loop = this.playMode === 'repeat';
    }
  }

  switchPlaybackRate() {
    if (this.playbackRate === 1.0) this.playbackRate = 1.5;
    else if (this.playbackRate === 1.5) this.playbackRate = 2.0;
    else this.playbackRate = 1.0;

    if (this.avPlayer) {
      this.avPlayer.setSpeed(this.playbackRate);
    }
  }

  getPlayModeIcon(): Resource {
    return PlayModeIconMap[this.playMode as PlayMode] || $r('app.media.ic_mode_order');
  }

  getPlayPauseIcon(): Resource {
    return this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play');
  }

  addMusicDialogController: CustomDialogController = new CustomDialogController({
    builder: AddMusicDialog({ addMusicToList: (newMusic: MusicItem): void => this.addNewMusicItem(newMusic) }),
    autoCancel: true
  });
}