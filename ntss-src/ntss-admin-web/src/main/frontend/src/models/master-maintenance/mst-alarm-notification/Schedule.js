import dayjs from "@/compat/date/dayjs";

export default class Schedule {
  constructor(
    isNotice = "1",
    startTime = null,
    endTime = null,
    isNextDay = "0"
  ) {
    this.isNoticeBool = this.isStr2Boolean(isNotice);
    this.isNotice = isNotice;
    this._startTime = startTime;
    this._endTime = endTime;
    this.isNextDayBool = this.isStr2Boolean(isNextDay);
    this.isNextDay = isNextDay;
  }

  hasStartTimeAndEndTime() {
    return (
      (this._startTime === null && this._endTime === null) ||
      (this._startTime !== null && this._endTime !== null)
    );
  }

  isStartTimeSameOrBeforeThanEndTime() {
    // 「翌」にチェックがついている時は、必ず開始時間 < 終了時間である
    if (this.isNextDayBool) {
      return true;
    }

    // momentにnullを渡すとNaNになって正確に比較できない。入力としては正しい。
    if (this._startTime === null && this._endTime === null) {
      return true;
    }

    const startTime = dayjs(this._startTime, "HH:mm");
    const endTime = dayjs(this._endTime, "HH:mm");
    return startTime.isSameOrBefore(endTime);
  }

  set startTime(newVal) {
    this._startTime = newVal === "" ? null : newVal;
  }

  set endTime(newVal) {
    this._endTime = newVal === "" ? null : newVal;
  }

  get startTime() {
    return this._startTime;
  }

  get endTime() {
    return this._endTime;
  }

  getIsNoticeAsBoolean() {
    return this.isStr2Boolean(this.isNotice);
  }

  getIsNoticeBoolAsString() {
    return this.isBool2Str(this.isNoticeBool);
  }

  getIsNextDayAsBoolean() {
    return this.isStr2Boolean(this.isNextDay);
  }

  getIsNextDayBoolAsString() {
    return this.isBool2Str(this.isNextDayBool);
  }

  isStr2Boolean(str) {
    return str === "1";
  }

  isBool2Str(bool) {
    return bool ? "1" : "0";
  }
}
