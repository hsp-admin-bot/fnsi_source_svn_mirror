/**
 * 予実リストのオーダー情報を表現するクラス
 */

export class InspectionScheduleResult {
  constructor(
    title,
    count,
    pattern,
    treatDate,
    type
  ) {
    this.title = title;
    this.count = count;
    this.pattern = pattern;
    this.treatDate = treatDate;
    this.type = type;
    this.pattern = 1;
  }
}
