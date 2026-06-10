export class Minutes {
  constructor(minutesString) {
    this.minutesString = minutesString;
  }

  // 分をHH:mmにして返す
  getHHmm() {
    if (!this.minutesString) return '';

    const m = new Number(this.minutesString).valueOf();
    const hours = '0' + Math.floor(m / 60);
    const minutes = '0' + m % 60;
    return `${hours.slice(-2)}:${minutes.slice(-2)}`;
  }
}
