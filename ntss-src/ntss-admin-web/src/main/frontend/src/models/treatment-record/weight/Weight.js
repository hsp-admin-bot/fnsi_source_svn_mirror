import { dateFormat } from "@/functions/common/DateTimeUtils";
/**
 * 体重画面の体重を表現するクラス
 */

function parseNumber(val) {
  return val === null || val === undefined || val === "" ? null : Number(val);
}

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
      this.weightBefore = parseNumber(rstWeightInfo.weight_before);
      this.weightBeforeDate = rstWeightInfo.weight_before_date;
      this.ctr = parseNumber(rstWeightInfo.ctr);
      this.ctrWeight = parseNumber(rstWeightInfo.ctr_weight);
      this.ctrMeasureDate = rstWeightInfo.ctr_measure_date;
      this.waterRemovalTarget = parseNumber(rstWeightInfo.water_removal_target);
      this.waterRemovalRst = parseNumber(rstWeightInfo.water_removal_rst);
      this.addWaterTotal = parseNumber(rstWeightInfo.add_water_total);
      this.weightAfter = parseNumber(rstWeightInfo.weight_after);
      this.weightAfterDate = rstWeightInfo.weight_after_date;
      this.weightDecreased = parseNumber(rstWeightInfo.weight_decreased);
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
      this.ihdfPll = parseNumber(rstWeightInfo.ihdf_pll);
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
      weight_before: parseNumber(this.weightBefore),
      weight_before_date: this.weightBeforeDate
        ? dateFormat.utc2Jst(this.weightBeforeDate)
        : null,
      weight_measure_before: parseNumber(this.modalBefore.weightResult),
      ctr: parseNumber(this.ctr),
      ctr_weight: parseNumber(this.ctrWeight),
      ctr_measure_date: this.ctrMeasureDate
        ? dateFormat.utc2Jst(this.ctrMeasureDate)
        : null,
      water_removal_target: parseNumber(this.waterRemovalTarget),
      water_removal_rst: parseNumber(this.waterRemovalRst),
      add_water_total: parseNumber(this.addWaterTotal),
      weight_after: parseNumber(this.weightAfter),
      weight_after_date: this.weightAfterDate
        ? dateFormat.utc2Jst(this.weightAfterDate)
        : null,
      weight_measure_after: parseNumber(this.modalAfter.weightResult),
      weight_decreased: parseNumber(this.weightDecreased),
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
      ihdf_pll: parseNumber(this.ihdfPll)
      // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
      // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    };
  }
}
