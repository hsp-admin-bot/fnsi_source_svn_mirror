/**
 * 予実リストのオーダー情報を表現するクラス
 */

export class PatientEventResult {
  constructor(
    patEventCd,
    categoryName,
    eventEndDate,
    eventEndTime,
    eventStartDate,
    eventStartTime,
    subCategoryName
  ) {
    this.patEventCd = patEventCd;
    this.categoryName = categoryName;
    this.eventEndDate = eventEndDate;
    this.eventEndTime = eventEndTime;
    this.eventStartDate = eventStartDate;
    this.eventStartTime = eventStartTime;
    this.subCategoryName = subCategoryName;
    this.pattern = 1;
  }
}
