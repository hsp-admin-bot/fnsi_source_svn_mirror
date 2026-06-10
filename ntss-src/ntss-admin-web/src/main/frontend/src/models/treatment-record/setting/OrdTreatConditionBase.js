import moment from "moment";
import { TREAT_CLASS } from "@/constants/TreatClass";
import { ORD_TREAT_CONDITION } from "@/constants/OrdTreatCondition";

/**
 * 治療記録（装置設定）のモデルの基底クラス
 * 各モデルはこのクラスを継承する。
 *
 * あわせて、JSON定義から値を取得する便利メソッドも実装している。
 */
export class OrdTreatConditionBase {
  constructor(receiveDate, treatClass) {
    this.receiveDate = receiveDate;
    this.treatClass = treatClass;
  }

  /**
   * @returns {string} 条件取得日時（ISO8601形式）の"MM/DD HH:mm"形式
   */
  getFormattedReceiveDate() {
    const receiveDateMoment = moment(this.receiveDate);
    return receiveDateMoment.format("MM/DD HH:mm");
  }

  /**
   * @returns {string} 区分の日本語表現
   */
  getTreatClassName() {
    if (this.treatClass === null) return "";

    return TREAT_CLASS[this.treatClass] !== undefined
      ? TREAT_CLASS[this.treatClass]
      : this.treatClass.toString()
      ;
  }

  /**
   * カテゴリーと値から、「変換ルール（conversionプロパティ）」で変換した値を取得する
   * @param {string} category
   * @param {number} value
   * @returns {string|number} 変換ルール（conversionプロパティ）」で変換した値
   */
  getAfterConversionValue(category, value) {
    if (value === undefined || value === null) return "";
    if (!ORD_TREAT_CONDITION.hasOwnProperty(category)) return "";

    const conversion = ORD_TREAT_CONDITION[category].conversion;
    //mod FNSI修正内容 不明追加 房 start
    return conversion[value] !== undefined
      ? conversion[value]
      : "不明"
      ;
    //mod FNSI修正内容 不明追加 房 end
  }

  /**
   * カテゴリーの単位を取得する
   * @param {string} category カテゴリー
   * @returns {string} 単位
   */
  getUnit(category) {
    return ORD_TREAT_CONDITION[category] !== undefined
      ? ORD_TREAT_CONDITION[category].unit
      : ""
      ;
  }

  /**
   * 指定された値がnullかundefinedの場合にtrueを返す
   * @param {*} value
   */
  isNullOrUndefined(value) {
    return value === null || value === undefined;
  }
}
