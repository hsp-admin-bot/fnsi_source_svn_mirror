import dayjs from "@/compat/date/dayjs";
import { dateFormat } from "@/functions/common/DateTimeUtils"

/**
 * 回診記録情報を表現するクラス.
 */
export class RstRoundInfo {
  constructor(
    round_type_cd = null,
    round_type_name = null,
    reg_date_time = null,
    ind_user_id = null,
    ind_user_last_name = '',
    ind_user_first_name = '',
    reg_user_id = null,
    reg_user_last_name = '',
    reg_user_first_name = '',
    content = null,
    is_ind_comment_post = null,
    ind_comment_no = null,
    posting_class = null,
    created_user_id = null,
    created_user_last_name = '',
    created_user_first_name = '',
    created_at = null,
    updated_user_id = null,
    updated_user_last_name = '',
    updated_user_first_name = '',
    updated_at = null
  ) {
    this.round_type_cd = round_type_cd; // 種別コード
    this.round_type_name = round_type_name; // 種別名
    this.reg_date_time = reg_date_time; // 起票日時（ISO8601）
    this.ind_user_id = ind_user_id; // 指示者ID
    this.ind_user_last_name = ind_user_last_name || ''; // 指示者名（姓）
    this.ind_user_first_name = ind_user_first_name || ''; // 指示者名（名）
    this.reg_user_id = reg_user_id; // 起票者ID
    this.reg_user_last_name = reg_user_last_name || ''; // 起票者名（姓）
    this.reg_user_first_name = reg_user_first_name || ''; // 起票者名（名）
    this.content = content; // 内容
    this.is_ind_comment_post = is_ind_comment_post; // 指示コメントに転記（'0': 転記しない, '1': 転記する）
    this.ind_comment_no = ind_comment_no; // 指示コメント番号
    this.posting_class = posting_class; // 転記区分（'0': 継続, '1': 当日のみ）
    this.created_user_id = created_user_id; // 登録者ID
    this.created_user_last_name = created_user_last_name || ''; // 登録者名（姓）
    this.created_user_first_name = created_user_first_name || ''; // 登録者名（名）
    this.created_at = created_at; // 登録日時（ISO8601）
    this.updated_user_id = updated_user_id; // 更新者ID
    this.updated_user_last_name = updated_user_last_name || ''; // 更新者名（姓）
    this.updated_user_first_name = updated_user_first_name || ''; // 更新者名（名）
    this.updated_at = updated_at; // 更新日時（ISO8601）
  }

  /**
   * モデルのコピーを返す
   */
  copy () {
    return new RstRoundInfo
    (
      this.round_type_cd,
      this.round_type_name,
      this.reg_date_time,
      this.ind_user_id,
      this.ind_user_last_name,
      this.ind_user_first_name,
      this.reg_user_id,
      this.reg_user_last_name,
      this.reg_user_first_name,
      this.content,
      this.is_ind_comment_post,
      this.ind_comment_no,
      this.posting_class,
      this.created_user_id,
      this.created_user_last_name,
      this.created_user_first_name,
      this.created_at,
      this.updated_user_id,
      this.updated_user_last_name,
      this.updated_user_first_name,
      this.updated_at
    );
  }

  /**
   * 指示者の氏名を返す.
   */
  get indUserFullName() {
    return `${this.ind_user_last_name} ${this.ind_user_first_name}`;
  }

  /**
   * 起票者の氏名を返す.
   */
  get regUserFullName() {
    return `${this.reg_user_last_name} ${this.reg_user_first_name}`;
  }

  /**
   * 編集有無を比較する項目を返す.
   */
  getCompareProperties() {
    let copy = Object.assign({}, this);
    copy.ind_user_id = String(copy.ind_user_id);
    delete copy.round_type_name;
    delete copy.ind_user_first_name;
    delete copy.ind_user_last_name;
    delete copy.reg_user_first_name;
    delete copy.reg_user_last_name;
    delete copy.created_user_id;
    delete copy.created_user_last_name;
    delete copy.created_at;
    delete copy.updated_user_id;
    delete copy.updated_user_last_name;
    delete copy.updated_user_first_name;
    delete copy.updated_at;
    // add 6173 治療記録の加算情報および回診記録は、編集していなくても編集破棄のメッセージが表示される 関 start
    delete copy.create_user_last_name;
    delete copy.create_user_id;
    delete copy.create_user_first_name;
    // add 6173 治療記録の加算情報および回診記録は、編集していなくても編集破棄のメッセージが表示される 関  end

    return copy;
  }

  /**
   * ord_main.rst_round_infoに設定される文字列表現を返す.
   */
  toString() {
    return JSON.stringify(this);
  }

  /**
   * 記載日時が未来日かどうかを返す
   * @returns {boolean} true: 未来日である、false: 未来日でない
   */
  isRegDateTimeFuture() {
    return dayjs(this.reg_date_time).isAfter(new Date());
  }

  /**
   * 指示コメント番号が入力されているかどうかを返す
   * 「指示コメントに転記」がOFFの場合は必ずtrueを返す（チェックしない）
   * @returns {boolean} true: 入力されている、false: 入力されていない
   */
  hasIndCommentNo() {
    if(this.is_ind_comment_post === "0") return true;

    return !!this.ind_comment_no;
  }

  /**
   * 指示：指示コメントを保存対象かどうかを返す
   */
  shouldSaveIndComment() {

    // mod FNSI 1006 No.395 治療記録：回診記録 part start --孙灏 20201215
    return this.is_ind_comment_post === "1";
    // return this.is_ind_comment_post === "1" && this.posting_class === "0";
    // mod FNSI 1006 No.395 治療記録：回診記録 part end --孙灏 20201215
  }

  /**
   * 実績：指示コメントを保存対象かどうかを返す
   */
  shouldSaveRstIndComment() {
    return this.is_ind_comment_post === "1" && this.posting_class === "1";
  }

  /**
   * バリデーション結果を項目ごとに返す
   * @returns {*} value値がtrue: 不正な入力でない、value値がfalse: 不正な入力
   */
  validation() {
    return {
      reg_date_time: !!this.reg_date_time,
      reg_date_time_future: this.isRegDateTimeFuture(),
      ind_user: !!this.ind_user_id,
      content: !!this.content,
      ind_comment: this.hasIndCommentNo()
    };
  }

  /**
   * 作成者と更新者を設定する
   */
  setCreatedAndUpdatedAndIndUser(userId, userFirstName, userLastName) {
    const now = dateFormat.utc2Jst(new Date());

    if(!this.created_user_id) {
      this.created_user_id = userId;
      this.created_user_first_name = userFirstName;
      this.created_user_last_name = userLastName;
      this.created_at = now;
    }

    this.updated_user_id = userId;
    this.updated_user_first_name = userFirstName;
    this.updated_user_last_name = userLastName;
    this.updated_at = now;

    if(!this.ind_user_id) {
      this.ind_user_id = userId;
      this.ind_user_first_name = userFirstName;
      this.ind_user_last_name = userLastName;
    }

  }

  static of(obj = {}) {
    return new RstRoundInfo(
      obj.round_type_cd,
      obj.round_type_name,
      obj.reg_date_time,
      obj.ind_user_id,
      obj.ind_user_last_name,
      obj.ind_user_first_name,
      obj.reg_user_id,
      obj.reg_user_last_name,
      obj.reg_user_first_name,
      obj.content,
      obj.is_ind_comment_post,
      obj.ind_comment_no,
      obj.posting_class,
      obj.created_user_id,
      obj.created_user_last_name,
      obj.created_user_first_name,
      obj.created_at,
      obj.updated_user_id,
      obj.updated_user_last_name,
      obj.updated_user_first_name,
      obj.updated_at
    );
  }
}
