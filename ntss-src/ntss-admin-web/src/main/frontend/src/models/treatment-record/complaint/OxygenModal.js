import { Master } from "@/models/common/master-selector-condition/Master";
import { DATE_FORMAT, SHORT_TIME_FORMAT, dateFormat, parseDate } from "@/functions/common/DateTimeUtils";

/**
 * 酸素吸入モーダル画面用のモデルクラス
 */
export class OxygenModal {
  constructor(treatment, isStart, defaultDate) {
    // 開始日時 ※日時は時分までしか画面から登録出来ないので時分までを保持
    this.startDate = treatment ? this.convertDateTime(treatment.occurDate) : null;
    
    // 速度
    this.oxygenSpeed = treatment ? treatment.oxygenSpeed : null;
    
    // 終了日時
    this.endDate = treatment ? this.convertDateTime(treatment.occurDate) : null;
    
    // 吸入量
    this.oxygenAmount = treatment ? treatment.oxygenAmount : null;
    
    // 処置者
    this.staff = treatment ? new Master(treatment.treatStaffCd, treatment.treatStaffName) : null;

    // 愁訴処置レコード
    this.treatment = treatment;
    
    // 開始ブロックかどうか
    this._isStart = isStart;
    
    // デフォルト日時
    this.defaultDate = defaultDate ? this.convertDateTime(defaultDate) : null;
    
    // 有効な日時かどうか
    this.isValid = true;
  }

  /**
   *  開始ブロックかどうかを設定.
   */
  set isStart(newVal) {
    this._isStart = newVal;
  }
  
  /**
   * 開始ブロックかどうかを取得.
   */
  get isStart() {
    return this._isStart || (this.treatment && this.treatment.isOxygenStart) || false;
  }
  
  /**
   * 編集可能かどうかの判定.
   */
  get isEditable() {
    return (this.treatment && this.treatment.isEditable === "1") || !this.treatment;
  }
  
  /**
   * 追加行かどうかの判定.
   */
  get isNew() {
    return this.treatment === null;
  }
  
  /** 
  * "YYYY-MM-DD HH:mm" 部分だけの Date オブジェクトを作成
  * @param {Date} dateTime
  * @return "YYYY-MM-DD HH:mm" 部分だけの Date オブジェクト
  */
  convertDateTime(dateTime) {
    const dateString = dateFormat.format(dateTime, DATE_FORMAT);
    const timeString = dateFormat.format(dateTime, SHORT_TIME_FORMAT);
    return parseDate(dateString, timeString);
  }
}
