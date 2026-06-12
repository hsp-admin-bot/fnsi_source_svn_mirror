import { DATE_CHOICES } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import { convertToHalfWidth } from "@/functions/common/CommonFunctions";
import {
  PAT_PERSONAL_MAIN_COL_PAT_SEX_M,
  PAT_PERSONAL_MAIN_COL_PAT_SEX_W
} from "@/constants/PatInfo";

export const makeDefaultCondition = (forSetting) => {
  const selectDateValue = forSetting
    ? (value) => value
    : (value) => calcTargetDate(value);
  return {
    viewDayType: 1,
    examDateSt: selectDateValue(DATE_CHOICES.BEFORE_THREE_MONTH.value),
    examDateEd: selectDateValue(DATE_CHOICES.TODAY.value),
    examSetCd: -1,
    viewPatId: true,
    viewExamDate: true,
    outRange: false,
    normalRange: true,
    unitDisplay: false,
    examGraphCd: -1,
  };
};

export const findExamSet = (examSetCd, examSetList) => {
  if (examSetCd === -1 || !examSetList) return null;
  return examSetList.find((item) => item.examSetCd === examSetCd);
};

/**
 * 正常範囲のkey取得
 */
export const getNormalValueKeys = (normalValueClass, patSex, defaultSex) => {
  // 正常値区分「0:共通」
  if (normalValueClass == "0") {
    return {
      normalValueUpper: "normalValueUpper",
      normalValueLower: "normalValueLower"
    };
  }
  // 正常値区分「1:男女」 患者性別が女性
  if (patSex == PAT_PERSONAL_MAIN_COL_PAT_SEX_W) {
    return {
      normalValueUpper: "normalValueUpperW",
      normalValueLower: "normalValueLowerW"
    };
  }
  // 正常値区分「1:男女」 患者性別が男性
  if (patSex == PAT_PERSONAL_MAIN_COL_PAT_SEX_M) {
    return {
      normalValueUpper: "normalValueUpperM",
      normalValueLower: "normalValueLowerM"
    };
  }

  // 正常値区分「1:男女」 患者性別が不明
  // ** 施設設定マスタNo.19「性別不明患者の正常範囲参照設定」**
  if (defaultSex == 1) {
    // 男性数値使用
    return {
      normalValueUpper: "normalValueUpperM",
      normalValueLower: "normalValueLowerM"
    };
  } else if (defaultSex == 2) {
    // 女性数値使用
    return {
      normalValueUpper: "normalValueUpperW",
      normalValueLower: "normalValueLowerW"
    };
  }

  // 該当なし
  return { normalValueUpper: null, normalValueLower: null };
};

/**
 * 検査結果セルの数値が正常範囲内かを判定
 *  - 上限・下限の設定あり、且つ、数値で範囲外の場合は文字色を変更する
 *  - 結果セルの数値は正常範囲を超える場合は赤文字、下回る場合は青文字表示
 *  - 形式「文字」の項目でも数値変換可能であれば文字色変更に対応
 *  - 数値変換範囲：全角数字も変換対象とする。文字列を少しでも含む場合は対象外
 */
export const getResultValueClass = (resultValue, lower, upper) => {
  const converted = convertToHalfWidth(resultValue);
  if (Number.isNaN(Number(converted))) return "";

  if (upper !== null && Number(converted) > upper) return "H";
  if (lower !== null && Number(converted) < lower) return "L";
  return "";
};