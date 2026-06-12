/**
 * 予実リストのオーダー情報を表現するクラス
 */

export class InspectionResult {
  constructor(
    count,
    pattern,
    treatDate,
    type
  ) {
    this.count = count;
    this.pattern = pattern;
    this.treatDate = treatDate;
    this.type = type;
    this.pattern = 1;
  }
}
