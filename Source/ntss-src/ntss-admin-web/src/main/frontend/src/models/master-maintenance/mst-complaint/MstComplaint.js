/**
 * マスタ編集（愁訴処置マスタ）向けモデルクラス
 */
export class MstComplaint {
  constructor(mstComplaint = null, index = null, code = null) {
    // 愁訴コード
    this.code = mstComplaint ? mstComplaint.complaint_cd : code ? code : null;
    // 愁訴名
    this.name = mstComplaint ? mstComplaint.complaint_name : "";
    // 表示フラグ("0":非表示,"1":表示)
    this.isDisp = mstComplaint ? mstComplaint.is_disp : "1";
    // 登録日時
    this.reg_date = mstComplaint ? mstComplaint.reg_date : null;
    // 更新日時
    this.up_date = mstComplaint ? mstComplaint.up_date : null;
    // 第1ソートキー
    this.sortRankFirst = index !== null ? index + 1 : 0;
    // 第2ソートキー
    this.sortRankSecond = 0;

    // 更新前データ退避
    this.initData = mstComplaint;
    this.initSortRankFirst = index !== null ? index + 1 : 0;
    
    // 連携コード1,2
    this.inHospitalCd1 = mstComplaint ? mstComplaint.in_hospital_cd_1 : null;
    this.inHospitalCd2 = mstComplaint ? mstComplaint.in_hospital_cd_2 : null;
  }

  /**
   * 削除扱いかどうか.
   */
  get isDel() {
    return this.isDisp === "0";
  }

  /**
   * 削除名称を取得する.
   */
  get del() {
    return this.isDel ? "削除" : "";
  }

  /**
   * 愁訴マスタエンティティの形式で返す.
   */
  get entity() {
    const isUpdate = this.initData === null ? null :
      (this.name !== this.initData.complaint_name  ||
      this.isDisp !== this.initData.is_disp ? null : this.up_date);
    return {
      complaint_cd: this.code < 0 ? null : this.code,
      facility_cd: this.initData ? this.initData.facility_cd : null,
      complaint_name: this.name,
      is_disp: this.isDisp,
      is_del: '0',
      reg_date: this.reg_date,
      up_date: this.initData === null ? null : this.initData.up_date,
      is_update: isUpdate === null,
      in_hospital_cd_1: this.inHospitalCd1,
      in_hospital_cd_2: this.inHospitalCd2
    }
  }

  /**
   * 第2ソートキーを設定する.
   */
  setSortRankSecond() {
    this.sortRankSecond = Date.now();
  }

  /**
   * このオブジェクトを更新あり状態にする
   */
  updated() {
    this.up_date = null;
  }

  /**
   * 編集済みかどうか.
   */
  isEdited() {
    return this.name ? true : false;
  }

  /**
   * 今回編集したかどうか.
   */
  isEditedAtThisTime() {
    // console.log(!this.up_date && this.isEdited());
    
    return !this.up_date && this.isEdited();
  }

  /**
   * ソートまたは表示フラグを変更したかどうか.
   */
  isSortedOrChangeDisp() {
    return this.sortRankSecond !== 0 || this.initData.is_disp != this.isDisp;
  }
}
