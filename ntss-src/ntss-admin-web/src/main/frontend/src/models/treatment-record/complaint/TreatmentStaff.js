import { CODES } from "@/constants/TreatmentRecord";
import { dateFormat } from "@/functions/common/DateTimeUtils";

/**
 * 愁訴処置者を表現するクラス.
 */
export class TreatmentStaff {
  /**
   * 愁訴処置者情報
   *
   * @param {*} rstTreatStaffInfo
   */
  constructor(rstTreatStaffInfo = null) {
    //
    if (!rstTreatStaffInfo) {
      // 管理番号
      this.ctlNo = 0;
      // 行番号
      this.rowNo = 0;
      // 入力区分
      this.inputClass = CODES.COMP_TREAT_INPUT_CLASS.CLIENT.cd;
      // 発生日時
      this.occurDate = null;
      // 処置者コード
      this.cd = null;
      // 処置者名
      this.name = null;
      // 連携オーダ番号
      this.copOrderNo = null;
      // 編集可否フラグ
      this.isEditable = CODES.IS_EDITABLE.POSSIBLE;
      return;
    }

    // 管理番号
    this.ctlNo = rstTreatStaffInfo.ctl_no;
    // 行番号
    this.rowNo = rstTreatStaffInfo.row_no;
    // 入力区分
    this.inputClass = rstTreatStaffInfo.input_class;
    // 発生日時
    this.occurDate = rstTreatStaffInfo.occur_date;
    // 処置者コード
    this.cd = rstTreatStaffInfo.treat_staff_cd;
    // 処置者名
    this.name = rstTreatStaffInfo.treat_staff_name;
    // 連携オーダ番号
    this.copOrderNo = rstTreatStaffInfo.cop_order_no;
    // 編集可否フラグ
    this.isEditable = rstTreatStaffInfo.is_editable;
    // 削除フラグ
    this.isDel = false;

    this.index = rstTreatStaffInfo.index;
  }

  /**
   * 処置者名を返す.
   */
  get treatStaffName() {
    return this.name ? this.name : null;
  }

  /**
   * 処置者コードを返す.
   */
  get treatStaffCd() {
    return this.cd ? this.cd : null;
  }

  // PUTリクエスト用の文字列を返す(愁訴処置者).
  treatStaffToString() {
    if (!this.cd) {
      return null;
    }
    return JSON.stringify({
      ctl_no: this.ctlNo,
      row_no: this.rowNo,
      index: this.index,
      input_class: this.inputClass,
      occur_date: dateFormat.utc2Jst(this.occurDate),
      treat_staff_cd: this.cd,
      treat_staff_name: this.name ? this.name : null,
      cop_order_no: this.copOrderNo,
      is_editable: this.isEditable,
      is_del: this.isDel,
    });
  }

  // ファクトリメソッド
  static of(treatStaffInfo) {
    const getOrElse = (obj, prop, defaultValue) => {
      if (!obj) {
        return defaultValue;
      }
      return obj.hasOwnProperty(prop) ? obj[prop] : defaultValue;
    };

    return new TreatmentStaff({
      ctl_no: getOrElse(treatStaffInfo, "ctlNo", 0),
      row_no: getOrElse(treatStaffInfo, "rowNo", 0),
      index: getOrElse(treatStaffInfo, "index", 0),
      input_class: getOrElse(
        treatStaffInfo,
        "inputClass",
        CODES.COMP_TREAT_INPUT_CLASS.CLIENT.cd
      ),
      occur_date: treatStaffInfo.occurDate,
      treat_staff_cd: treatStaffInfo.treatStaffCd,
      treat_staff_name: treatStaffInfo.treatStaffName,
      cop_order_no: getOrElse(treatStaffInfo, "copOrderNo", null),
      is_editable: getOrElse(
        treatStaffInfo,
        "isEditable",
        CODES.IS_EDITABLE.POSSIBLE.cd
      ),
      is_del: getOrElse(treatStaffInfo, "isDel", false),
    });
  }
}
