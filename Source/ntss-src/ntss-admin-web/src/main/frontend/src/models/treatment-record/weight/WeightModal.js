/**
 * 体重画面の透析[前|後]体重入力を表現するクラス
 */
import { TitleAndNumber } from "@/models/common/TitleAndNumber";
import { MasterAndNumber } from "@/models/common/MasterAndNumber";
import {
  truncateDecimal,
  plusDecimal,
  divideDecimal
} from "@/functions/treatment-record/NumberFunctions.js";

export class WeightModal {
  constructor(
    weightBefore = null,
    weightAfter = null,
    weightResult = null,
    targetWeight = null,
    targetOffWater = null,
    offWaterLimit = null,
    rstTareInfo = null,
    rstOffWaterInfo = null
  ) {
    this.weightBefore = weightBefore;
    this.weightAfter = weightAfter;
    this.weightResult = weightResult;
    this.targetWeight = targetWeight;
    this.targetOffWater = targetOffWater;
    this.offWaterLimit = offWaterLimit;

    if (rstTareInfo === null) {
      this.tareInfos = [];
      this.wheelChair = new MasterAndNumber();
    } else {
      this.tareInfos = [
        new TitleAndNumber(rstTareInfo.name_1, rstTareInfo.weight_1),
        new TitleAndNumber(rstTareInfo.name_2, rstTareInfo.weight_2),
        new TitleAndNumber(rstTareInfo.name_3, rstTareInfo.weight_3),
        new TitleAndNumber(rstTareInfo.name_4, rstTareInfo.weight_4),
        new TitleAndNumber(rstTareInfo.name_5, rstTareInfo.weight_5)
      ];

      this.wheelChair = new MasterAndNumber(
        rstTareInfo.wheel_chair_cd,
        rstTareInfo.wheel_chair_name,
        rstTareInfo.wheel_chair_weight
      );
    }

    if (rstOffWaterInfo === null) {
      this.offWaterInfos = [];
    } else {
      this.offWaterInfos = [
        new TitleAndNumber(rstOffWaterInfo.name_1, rstOffWaterInfo.weight_1),
        new TitleAndNumber(rstOffWaterInfo.name_2, rstOffWaterInfo.weight_2),
        new TitleAndNumber(rstOffWaterInfo.name_3, rstOffWaterInfo.weight_3),
        new TitleAndNumber(rstOffWaterInfo.name_4, rstOffWaterInfo.weight_4),
        new TitleAndNumber(rstOffWaterInfo.name_5, rstOffWaterInfo.weight_5)
      ];
    }

    // 風袋の合計を計算.
    this.calcTareSum();
    // 除水の合計を計算.
    this.calcOffWaterSum();
  }

  /**
   * 透析前・後体重を計算する.
   * @param {Boolean} isAfter trueの場合、透析後体重を計算する
   */
  calcWeight(isAfter) {
    const weightResultKg = this.weightResult;
    if (weightResultKg) {
      // 風袋合計の単位は"g"なので、"kg"へ変換
      const tareSum = this.tareSum ? divideDecimal(this.tareSum, 1000) : 0;
      const wheelChairWeight = this.wheelChair.value ? divideDecimal(this.wheelChair.value, 1000) : 0;
      // 小数点第3位以下は切り捨て.
      const value = truncateDecimal(plusDecimal(weightResultKg, -(tareSum + wheelChairWeight)), 2);
      if (!isAfter) {
        this.weightBefore = value;
      } else {
        this.weightAfter = value;
      }
    }
  }

  /**
   * 目標/実績除水量計算.
   * @param {Boolean} isAfter trueの場合、実績除水量を計算する
   */
  calcOffWater(isAfter) {
    const subtracted = !isAfter ? this.targetWeight : this.weightAfter;
    if (!this.weightBefore || !subtracted) {
      // 透析前体重 もしくは 透析後体重/目標体重が空やnullの場合、計算しない
      return;
    }
    // 除水補正合計の単位は"g"なので、"kg"へ変換
    const offWaterSum = this.offWaterSum
      ? divideDecimal(this.offWaterSum, 1000)
      : 0;
    const result = truncateDecimal(
      plusDecimal(this.weightBefore, -subtracted, offWaterSum),
      2
    );
    // 計算結果 > 除水量制限の場合は除水量制限、それ以外は計算結果を設定する
    this.targetOffWater =
      this.offWaterLimit < result ? this.offWaterLimit : result;
  }

  /**
   * 風袋合計.
   */
  calcTareSum() {
    this.tareSum = this.calcSum(this.tareInfos);
  }

  /**
   * 除水補正量合計.
   */
  calcOffWaterSum() {
    this.offWaterSum = this.calcSum(this.offWaterInfos);
  }

  /**
   * 合計する.
   */
  calcSum(values) {
    if (values.every(e => e.value == null)) {
      // 値が一つも入力されていない場合、合計値をクリア
      return null;
    }
    return plusDecimal(...values.map(e => (e.value ? e.value : 0)));
  }

  /**
   * クローンする.
   */
  clone() {
    const copied = new WeightModal();
    Object.assign(copied, this);
    copied.tareInfos = this.tareInfos.map(t => t.clone());
    copied.wheelChair = this.wheelChair.clone();
    copied.offWaterInfos = this.offWaterInfos.map(o => o.clone());
    return copied;
  }

  /**
   * 除水補正情報を反映する.
   */
  applyOffWaterInfos(value) {
    Object.assign(this.offWaterInfos, value);
    this.calcOffWaterSum();
  }

  /**
   * 風袋情報を反映する.
   */
  applyTareInfos(value) {
    Object.assign(this.tareInfos, value);
    this.calcTareSum();
  }

  /**
   * モデルの値をJSONで返す(風袋).
   */
  toJsonTareInfo() {
    const result = {};

    this.tareInfos.forEach((tareInfo, index) => {
      result[`name_${index + 1}`] = tareInfo.title;
      result[`weight_${index + 1}`] = tareInfo.value;
    });
    result.wheel_chair_cd = this.wheelChair.cd;
    result.wheel_chair_name = this.wheelChair.name;
    result.wheel_chair_weight = this.wheelChair.value;

    return result;
  }

  /**
   * モデルの値をJSONで返す(除水補正).
   */
  toJsonOffWaterInfo() {
    const result = {};

    this.offWaterInfos.forEach((offWaterInfo, index) => {
      result[`name_${index + 1}`] = offWaterInfo.title;
      result[`weight_${index + 1}`] = offWaterInfo.value;
    });

    return result;
  }
}
