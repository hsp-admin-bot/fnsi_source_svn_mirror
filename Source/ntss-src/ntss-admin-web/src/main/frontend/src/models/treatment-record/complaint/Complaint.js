import {
  dateFormat,
  SHORT_TIME_FORMAT
} from "@/functions/common/DateTimeUtils";

/**
 * 愁訴処置画面の愁訴処置を表現するクラス
 */
export class Complaint {
  constructor(
    rstComplaintInfo,
    isDialysis = false,
    forOxygen = false,
    isDummy = false
  ) {
    // 発生日時（時刻）
    this.occurDate = new Date(rstComplaintInfo.occur_date);

    const { checkFlag } = rstComplaintInfo;
    this.checkFlag = checkFlag == 1 || checkFlag === undefined ? 1 : 0;
    if (isDialysis) {
      this.checkFlag = 1;
    }

    // 愁訴（愁訴情報.愁訴コード/愁訴内容）
    this.complaint = {
      ctlNo: rstComplaintInfo.ctl_no, // 新規の場合は0
      inputClass: rstComplaintInfo.input_class, // 新規の場合は1
      rowNo: rstComplaintInfo.row_no, // 新規の場合は0
      occurDate: rstComplaintInfo.occur_date,
      cd: rstComplaintInfo.comp_cd,
      name: rstComplaintInfo.complaint ? rstComplaintInfo.complaint : null,
      isDel: rstComplaintInfo.isDel,
    };

    // 愁訴処置、愁訴処置者のリスト
    this.treatmentList = [];

    // 透析開始または透析終了かどうか
    this.isDialysis = isDialysis;

    // 酸素吸入開始・終了のインスタンスの場合にtrueに設定する
    this.forOxygen = forOxygen;

    // ダミー(表示する為のみ使用)
    this.isDummy = isDummy;

    // 削除フラグ
    this.isDel = rstComplaintInfo.is_del;
  }

  /**
   * フォーマットした発生時刻を取得する.
   */
  get occurTime() {
    return this.occurDate
      ? dateFormat.format(this.occurDate, SHORT_TIME_FORMAT)
      : "";
  }

  /**
   * 特殊レコードかどうか.
   * (透析開始/透析終了/酸素吸入開始/酸素吸入終了)
   */
  get isSpecial() {
    // mod FNSI-改修内容 酸素吸入修正 房 start
    return this.isDialysis || this.forOxygen;
    // return this.isDialysis || this.isOxygen || this.forOxygen;
    // mod FNSI-改修内容 酸素吸入修正 房 end
  }

  /**
   * 透析開始/透析終了のレコードか否か.
   * @returns {Boolean} 透析開始/透析終了のレコードの場合trueを返す.
   */
  get isDialysisRecord() {
    return this.isDialysis;
  }

  /**
   * 酸素吸入開始/酸素吸入終了レコードかどうか.
   */
  get isOxygen() {
    return this.treatmentList.some((e) => e.isOxygenStart || e.isOxygenEnd);
  }

  /**
   * ソート用関数.
   * @param {Complaint} obj 比較対象
   */
  compareTo(obj) {
    if (this.occurDate < obj.occurDate) return -1;
    if (this.occurDate > obj.occurDate) return 1;
    if (this.isSpecial < obj.isSpecial) return -1;
    if (this.isSpecial > obj.isSpecial) return 1;
    return 0;
  }

  // PUTリクエスト用の文字列を返す.
  toString() {
    return JSON.stringify({
      //add 治療記録改修7 房 start 2020/08/13
      checkFlag: this.checkFlag,
      //add 治療記録改修7 房 end 2020/08/13
      ctl_no: this.complaint.ctlNo,
      input_class: this.complaint.inputClass,
      row_no: this.complaint.rowNo,
      occur_date: dateFormat.utc2Jst(this.complaint.occurDate),
      comp_cd: this.complaint.cd,
      complaint: this.complaint.name || null,
      is_del: this.complaint.isDel || false,
    });
  }

  // ファクトリメソッド
  static of(args, forOxygen = false, isDummy = false) {
    const getOrElse = (obj, prop, defaultValue) => {
      return Object.prototype.hasOwnProperty.call(obj, prop) ? obj[prop] : defaultValue;
    };

    return new Complaint(
      {
        ctl_no: getOrElse(args, "ctlNo", 0),
        input_class: getOrElse(args, "inputClass", 1),
        row_no: getOrElse(args, "rowNo", 0),
        occur_date: args.occurDate,
        comp_cd: args.compCd,
        complaint: args.complaint || null,
        is_del: getOrElse(args, "isDel", false),
      },
      false,
      forOxygen,
      isDummy
    );
  }
}
