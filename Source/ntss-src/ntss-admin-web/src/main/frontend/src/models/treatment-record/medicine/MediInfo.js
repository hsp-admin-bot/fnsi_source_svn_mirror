import {
  SHORT_TIME_FORMAT,
  DATE_FORMAT,
  dateFormat,
  parseDate
} from "@/functions/common/DateTimeUtils.js";
import dayjs from "@/compat/date/dayjs";

/**
 * 投与薬剤情報（rst_medi_info）の1件分の投与薬剤を表現するクラス
 */
export class MediInfo {
  constructor(
    be_deleted,
    is_edited,
    //add 治療記録バッグ修正 改修2 start
    is_new,
    //add 治療記録バッグ修正 改修2 end
    no = 0,
    class_cd,
    class_name,
    class_type,
    // medicine_type = "1",
    medicine_type = 1,
    cd,
    name,
    short_name,
    unit,
    amount = null,
    init_date,
    date_interval,
    timing_cd = null,
    timing_name = null,
    procedure_cd,
    procedure_name,
    comment = null,
    ind_user_id,
    ind_user_last_name,
    ind_user_first_name,
    upd_user_id,
    upd_user_last_name,
    upd_user_first_name,
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //input_class = "1",
    input_class = 1,
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    is_editable = "1",
    cop_order_no = null,
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //effect_flg = "0",
    effect_flg = 0,
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    effect_status = "",
    effect_date,
    effect_user_id = null,
    effect_user_last_name = null,
    effect_user_first_name = null
  ) {
    this.be_deleted = be_deleted; // 削除対象かどうか（true: 削除対象である）
    this.is_edited = is_edited; // 編集されたかどうか（true: 編集された）
    //mod 治療記録バッグ修正 改修2 start
    this.is_new = is_new ? is_new : false;
    //mod 治療記録バッグ修正 改修2 end
    this.no = no; // 識別番号
    this.class_cd = class_cd; // 薬剤分類コード
    this.class_name = class_name; // 薬剤分類名
    this.class_type = class_type; // 分類区分
    this.medicine_type = medicine_type; // 薬剤区分
    this.cd = cd; // 薬剤(調整薬剤)コード
    this.name = name; // 薬剤名
    this.short_name = short_name; // 省略薬剤名
    this.unit = unit; // 単位
    this.amount = !isNaN(parseFloat(amount)) ? parseFloat(amount) :null; // 数量
    this.init_date = init_date; // 初回投与日 ※ISO8601形式
    this.date_interval = date_interval; // 投与間隔
    this.timing_cd = timing_cd; // 投与タイミングコード
    this.timing_name = timing_name; // 投与タイミング名
    this.procedure_cd = procedure_cd; // 手技コード
    this.procedure_name = procedure_name; // 手技名
    this.comment = comment; // コメント
    this.ind_user_id = ind_user_id; // 指示者コード(利用者マスタ.利用者ID)
    this.ind_user_last_name = ind_user_last_name; // 指示者名_姓(利用者マスタ.利用者名_姓)
    this.ind_user_first_name = ind_user_first_name; // 指示者名_名(利用者マスタ.利用者名_名)
    this.upd_user_id = upd_user_id; // 更新者コード(利用者マスタ.利用者ID)
    this.upd_user_last_name = upd_user_last_name; // 更新者名_姓(利用者マスタ.利用者名_姓)
    this.upd_user_first_name = upd_user_first_name; // 更新者名_名(利用者マスタ.利用者名_名)
    this.input_class = input_class; // 登録区分
    this.is_editable = is_editable; // 編集可否フラグ
    this.cop_order_no = cop_order_no; // 連携オーダ番号
    this.effect_flg = effect_flg; // 投与実施フラグ ※0：未実施、1：実施済み
    this.effect_status = effect_status; // 実施状況（DBには登録されない）
    this.effect_date = effect_date; // 投与実施日時 ※ISO8601形式：【TDC修正】
    this.effect_time = effect_flg == 1 && effect_date
      ? dateFormat.format(new Date(effect_date), SHORT_TIME_FORMAT)
      : null; // 実施時間（DBには登録されない）
    this.effect_user_id = effect_user_id; // 投与実施者コード
    this.effect_user_last_name = effect_user_last_name; // 投与実施者名_姓
    this.effect_user_first_name = effect_user_first_name; // 投与実施者名_名
  }

  /**
   * 実施状況を返す。
   */
  getEffectStatus() {
    return (this.effect_flg == 0) ? "未" : "済";
  }

  /**
   * 実施者のフルネームを返す
   */
  getEffectUserFullName() {
    return `${this.effect_user_last_name != null ? this.effect_user_last_name : ""} ${this.effect_user_first_name != null ? this.effect_user_first_name : ""}`;
  }

  /**
   * 更新者を設定する
   * @param {*} stateUserAccountInfo サインインしてるユーザ情報
   */
  setUpdUser(stateUserAccountInfo) {
    this.is_edited = true;

    this.upd_user_id = stateUserAccountInfo.userId;
    this.upd_user_last_name = stateUserAccountInfo.userLastName;
    this.upd_user_first_name = stateUserAccountInfo.userFirstName;
  }

  /**
   * 実施者を設定する
   * @param {*} userInfo 実施者として選択されたユーザ情報
   */
  setEffectUser(userInfo) {
    this.effect_user_id = userInfo === undefined ? null : userInfo.id;
    this.effect_user_last_name =
      userInfo === undefined ? null : userInfo.lastName;
    this.effect_user_first_name =
      userInfo === undefined ? null : userInfo.firstName;
  }

  /**
   * 投与実施フラグと 投与実施日時を設定する
   * @param {*} treatDate 治療日
   * @param {*} rstStartDate 実績：治療開始日時
   * @param {*} stateUserAccountInfo サインインしてるユーザ情報
   */
  setEffectDate(treatDate, stateUserAccountInfo, effectDate = null) {
    this.setUpdUser(stateUserAccountInfo);
    // 時刻が未入力の場合は投与実施フラグを未実施に変更
    if (!this.effect_time) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //this.effect_flg = "0";
      this.effect_flg = 0;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      this.effect_date = effectDate;
      return;
    }
    // 時刻が入力済みの場合は投与実施フラグを実施済みに変更
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //this.effect_flg = "1";
    this.effect_flg = 1;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    let calcDate;
    if (this.effect_date && !effectDate) {
      calcDate = this.effect_date;
    } else if (effectDate) {
      calcDate = new Date(
        Number(effectDate.substr(0, 4)),
        Number(effectDate.substr(4, 2) - 1),
        Number(effectDate.substr(6, 2)));
    } else {
      calcDate = new Date(
        Number(treatDate.substr(0, 4)),
        Number(treatDate.substr(4, 2) - 1),
        Number(treatDate.substr(6, 2)));
    }
    this.effect_date = dateFormat.utc2Jst(
      parseDate(
        dateFormat.format(new Date(calcDate), DATE_FORMAT),
        this.effect_time
      ).toISOString()
    );
  }

  //del 治療記録バッグ修正 改修2 start
  //setOnlyEffectDate(index = 0, effectDate = null, isCalendar = false) {
  //del 治療記録バッグ修正 改修2 end
  setOnlyEffectDate(effectDate = null, isCalendar = false) {
    let effectTime = dayjs().format('HH:mm');
    let calcDate;
    //del 治療記録バッグ修正 改修2 start
    // let isNew = false;
    //del 治療記録バッグ修正 改修2 end
    if (this.effect_time) {
      effectTime = this.effect_time;
    }
    if (this.effect_date) {
      effectDate = dayjs(this.effect_date).format('YYYYMMDD');
    }
    calcDate = new Date(
      Number(effectDate.substr(0, 4)),
      Number(effectDate.substr(4, 2) - 1),
      Number(effectDate.substr(6, 2)));
    this.effect_date = dateFormat.utc2Jst(
      parseDate(
        dateFormat.format(new Date(calcDate), DATE_FORMAT),
        effectTime
      ).toISOString()
    );
    //del 治療記録バッグ修正 改修2 start
    // if (index == 0) {
    //   isNew = true;
    // }
    //this.is_new = isNew;
    //del 治療記録バッグ修正 改修2 end
    if (isCalendar && this.effect_time) {
      this.is_edited = true;
    }
  }

  /**
   * 投与薬剤情報に何も入力されていないかどうかを返す
   */
  isEmpty() {
    return !(
      this.name ||
      this.effect_time ||
      this.amount ||
      this.procedure_name ||
      this.timing_name ||
      this.effect_user_id
    );
  }

  /**
   * 薬剤名が入力済みかを返す
   */
  hasName() {
    return !!this.name;
  }

  /**
   * 数量が入力済みかを返す
   */
  hasAmount() {
    // #9848+9849 投与薬剤登録検証追加 linjunfeng start
    // return !!this.amount || this.amount === 0;
    return !!this.amount && this.amount != 0;
    // #9848+9849 投与薬剤登録検証追加 linjunfeng end
  }

  /**
   * 手技が入力済みかを返す
   */
  hasProcedure() {
    return !!this.procedure_cd;
  }

  /**
   * 実施状況が入力されていて実施者が入力済みかを返す
   */
  hasEffectUser() {
    if (!this.effect_time) return true;
    return !!this.effect_user_id;
  }

  /**
   * ord_main.rst_medi_infoに設定される文字列表現を返す。
   */
  toString() {
    const ignoreFields = [
      'be_deleted',
      'is_edited',
      'effect_status',
      'effect_time'
    ];
    return JSON.stringify(this, (key, value) => {
      if (ignoreFields.includes(key)) {
        return undefined;
      }
      return value === undefined ? null : value;
    });
  }

  static of(obj = {}) {
    return new MediInfo(
      false,
      obj.is_edited,
      //add 治療記録バッグ修正 改修2 start
      obj.is_new,
      //add 治療記録バッグ修正 改修2 end
      obj.no,
      obj.class_cd,
      obj.class_name,
      obj.class_type,
      obj.medicine_type,
      obj.cd,
      obj.name,
      obj.short_name,
      obj.unit,
      obj.amount,
      obj.init_date,
      obj.date_interval,
      obj.timing_cd,
      obj.timing_name,
      obj.procedure_cd,
      obj.procedure_name,
      obj.comment,
      obj.ind_user_id,
      obj.ind_user_last_name,
      obj.ind_user_first_name,
      obj.upd_user_id,
      obj.upd_user_last_name,
      obj.upd_user_first_name,
      obj.input_class,
      obj.is_editable,
      obj.cop_order_no,
      obj.effect_flg,
      obj.effect_status,
      obj.effect_date,
      obj.effect_user_id,
      obj.effect_user_last_name,
      obj.effect_user_first_name
    );
  }
}
