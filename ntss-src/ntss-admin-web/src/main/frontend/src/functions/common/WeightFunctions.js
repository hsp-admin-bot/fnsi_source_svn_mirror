import BigNumber from "bignumber.js";
import {
  dialysisState,
  weightScaleClass,
  weightScaleState,
  weightScaleMode
} from "@/constants/weightDefine";

/**
 * @description 主に風袋で使用、グラムをキログラム化し、小数点3位を切り捨て
 * @param {Number} gramValue グラム重量
 * @returns {Boolean}
 */
export const tareG2Kg = gramValue => {
  const totalWeight = new BigNumber(
    Math.floor(new BigNumber(gramValue).div(10).toNumber())
  )
    .div(100)
    .toNumber();
  return totalWeight;
};

/**
 * @description 主に除水補正で使用、グラムをキログラム化し、小数点3位を切り上げ
 * @param {Number} gramValue グラム重量
 * @returns {Boolean}
 */
export const offWaterG2Kg = gramValue => {
  const totalWeight = new BigNumber(
    Math.ceil(new BigNumber(gramValue).div(10).toNumber())
  )
    .div(100)
    .toNumber();
  return totalWeight;
};

/**
 * @description 治療状況コードから治療状況名称を取得
 * @param {Number} state 治療状況コード
 * @returns {String} 治療状況名称
 */
export const dialysisStateMsg = state => {
  switch (state) {
    case dialysisState.beforeSendCondition:
      return "前体重未測定";
    case dialysisState.afterSendCondition:
      return "前体重測定済";
    case dialysisState.checkedSendCondition:
      return "患者確認済み";
    case dialysisState.dialysis:
      return "治療中";
    case dialysisState.afterDialysis:
      return "治療終了";
    case dialysisState.afterWeight:
      return "後体重測定済";
    case dialysisState.afterPastRecord:
      return "後体重確認済み(過去実績)";
    default:
      return "";
  }
};

/**
 * 治療状況から前後体重測定モードを区別する
 * @param {Number} num 治療状況
 */
export const weightScaleClassByDialysisState = num => {
  if (num == null || num < 0) {
    // 治療状況情報なしの場合は重量測定モード
    return weightScaleClass.scale;
  } else if (num <= Number(dialysisState.checkedSendCondition)) {
    // 条件送信前または条件送信済みの場合は前体重モード
    // 条件送信確認済みの場合もいちおう前体重モード
    return weightScaleClass.before;
  } else if (
    num > Number(dialysisState.checkedSendCondition) &&
    num < Number(dialysisState.afterDialysis)
  ) {
    // 治療中の場合は治療中モード
    return weightScaleClass.dialysis;
  } else if (
    num == Number(dialysisState.afterDialysis) ||
    num == Number(dialysisState.afterWeight)
  ) {
    // 後体重モード
    return weightScaleClass.after;
  } else if (
    num == Number(dialysisState.afterPastRecord)
  ) {
    // 後体重確認済み
    return weightScaleClass.pastDialysis;
  }
  // それ以外の場合は重量測定モード
  return weightScaleClass.scale;
};

/**
 * @description 測定区分コードから測定区分名称を取得
 * @param {Number} value 測定区分コード
 * @returns {String} 治測定区分名称
 */
export const weightScaleClassMsg = value => {
  switch (value) {
    case weightScaleClass.before:
      return "前体重";
    case weightScaleClass.after:
      return "後体重";
    case weightScaleClass.scale:
      return "重量測定";
    case weightScaleClass.dialysis:
      return "治療中";
    case weightScaleClass.noSchedule:
      return "スケジュールなし";
    case weightScaleClass.pastDialysis:
      return "治療済";
    default:
      return "";
  }
};

/**
 * @description 測定モードから測定モード名称を取得
 * @param {Number} value 測定モードコード
 * @returns {String} 測定モード名称
 */
export const weightScaleModeMsg = value => {
  switch (value) {
    case weightScaleMode.weight:
      return "体重";
    case weightScaleMode.weightAndChair:
      return "体重車いす";
    case weightScaleMode.wheelChair:
      return "車いす";
    default:
      return "";
  }
};

/**
 * @description 測定記録状況コードから測定記録状況名称を取得
 * @param {Number} value 測定記録状況コード
 * @returns {String} 測定記録状況名称
 */
export const weightScaleStateMsg = value => {
  switch (value) {
    case weightScaleState.measured:
      return "測定済み";
    case weightScaleState.order:
      return "条件送信指示中";
    case weightScaleState.wait:
      return "待機";
    case weightScaleState.sendSuccess:
      return "条件送信成功";
    case weightScaleState.sendFailure:
      return "条件送信失敗";
    default:
      return "";
  }
};
