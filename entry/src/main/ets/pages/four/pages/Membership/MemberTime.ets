//想做会员时间页面

@Entry
@Component
struct MemberDurationDisplay {
  @State remainingDays: number = 45
  @State isHovered: boolean = false

  getDurationText(): string {
    if (this.remainingDays <= 0) return '会员已过期';
    if (this.remainingDays === 1) return '剩余1天';

    const weeks = Math.floor(this.remainingDays / 7);
    const days = this.remainingDays % 7;

    if (weeks >= 1 && days > 0) {
      return `剩余${weeks}周${days}天`;
    } else if (weeks >= 1) {
      return `剩余${weeks}周`;
    } else {
      return `剩余${days}天`;
    }
  }

  getTextColor(): ResourceStr {
    if (this.remainingDays <= 0) return '#F53F3F';
    if (this.remainingDays <= 7) return '#FF7D00';
    return this.isHovered ? '#007DFF' : '#181818';
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.member_duration_title'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width(150)
          .margin({ left: 15 })

        Text(this.getDurationText())
          .fontSize(14)
          .fontColor(this.getTextColor())
          .fontWeight(this.isHovered ? FontWeight.Medium : FontWeight.Normal)
          .margin({ left: 10 })
          .padding(8)
          .backgroundColor(this.isHovered ? '#F0F8FF' : '#FFFFFF')
          .borderRadius(6)
          .onHover((isHover: boolean) => {
            this.isHovered = isHover;
          })
      }
      .height(50)
      .width('100%')
      .margin({ top: 15 })
    }
    .width('100%')
  }
}