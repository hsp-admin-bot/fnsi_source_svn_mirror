import { dateFormat } from "@/functions/common/DateTimeUtils";
/**
 * 体重画面の体重を表現するクラス
 */

export class Weight {
  constructor(
    lastWeight = null,
    rstDw = null,
    targetWeight = null,
    rstWeightInfo = null,
    modalBefore = null,
    modalAfter = null
  ) {
    this.lastWeight = lastWeight;
    this.rstDw = rstDw;
    this.targetWeight = targetWeight;
    this.modalBefore = modalBefore;
    this.modalAfter = modalAfter;

    if (rstWeightInfo === null) {
      this.weightBefore = null;
      this.weightBeforeDate = null;
      this.ctr = null;
      this.ctrWeight = null;
      this.ctrMeasureDate = null;
      this.waterRemovalTarget = null;
      this.waterRemovalRst = null;
      this.addWaterTotal = null;
      this.weightAfter = null;
      this.weightAfterDate = null;
      this.weightDecreased = null;
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
      this.ihdfPll = null;
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
    } else {
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
      //liyanze-z #9695 add start
      // this.weightBefore = rstWeightInfo.weight_before? parseFloat(rstWeightInfo.weight_before) : null;
      this.weightBefore = parseNumber(rstWeightInfo.weight_before);
      //liyanze-z #9695 add end
      this.weightBeforeDate = rstWeightInfo.weight_before_date;
      this.ctr = rstWeightInfo.ctr? parseFloat(rstWeightInfo.ctr) : null;
      this.ctrWeight = rstWeightInfo.ctr_weight? parseFloat(rstWeightInfo.ctr_weight) : null;
      this.ctrMeasureDate = rstWeightInfo.ctr_measure_date;
      this.waterRemovalTarget = rstWeightInfo.water_removal_target? parseFloat(rstWeightInfo.water_removal_target) : null;
      this.waterRemovalRst = rstWeightInfo.water_removal_rst? parseFloat(rstWeightInfo.water_removal_rst) : null;
      this.addWaterTotal = rstWeightInfo.add_water_total? parseFloat(rstWeightInfo.add_water_total) : null;
      //liyanze-z #9695 add start
      // this.weightAfter = rstWeightInfo.weight_after? parseFloat(rstWeightInfo.weight_after) : null;
      this.weightAfter = parseNumber(rstWeightInfo.weight_after);
      //liyanze-z #9695 add end
      this.weightAfterDate = rstWeightInfo.weight_after_date;
      this.weightDecreased = rstWeightInfo.weight_decreased? parseFloat(rstWeightInfo.weight_decreased) : null;
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
      this.ihdfPll = rstWeightInfo.ihdf_pll? parseFloat(rstWeightInfo.ihdf_pll) : null;
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    }
  }

  /**
   * モデルの値をJSONで返す.
   */
  toJson() {
    return {
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
      weight_before: this.weightBefore? parseFloat(this.weightBefore) : null,
      weight_before_date: this.weightBeforeDate
        ? dateFormat.utc2Jst(this.weightBeforeDate)
        : null,
      weight_measure_before: this.modalBefore.weightResult? parseFloat(this.modalBefore.weightResult) : null,
      ctr: this.ctr? parseFloat(this.ctr) : null,
      ctr_weight: this.ctrWeight? parseFloat(this.ctrWeight) : null,
      ctr_measure_date: this.ctrMeasureDate
        ? dateFormat.utc2Jst(this.ctrMeasureDate)
        : null,
      water_removal_target: this.waterRemovalTarget? parseFloat(this.waterRemovalTarget) : null,
      water_removal_rst: this.waterRemovalRst? parseFloat(this.waterRemovalRst) : null,
      add_water_total: this.addWaterTotal? parseFloat(this.addWaterTotal) : null,
      weight_after: this.weightAfter? parseFloat(this.weightAfter) : null,
      weight_after_date: this.weightAfterDate
        ? dateFormat.utc2Jst(this.weightAfterDate)
        : null,
      weight_measure_after: this.modalAfter.weightResult? parseFloat(this.modalAfter.weightResult) : null,
      weight_decreased: this.weightDecreased? parseFloat(this.weightDecreased) : null,
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
      ihdf_pll: this.ihdfPll? parseFloat(this.ihdfPll) : null
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    };
  }
}
//liyanze-z #9695 add start
function parseNumber(val) {
  return val === null || val === undefined || val === ""
    ? null
    : Number(val);
}
//liyanze-z #9695 add end
