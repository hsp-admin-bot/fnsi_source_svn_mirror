/**
 * マスタ編集（愁訴処置マスタ）向けモデルクラス
 */
export class MstCompTreatment {
  constructor(mstCompTreatment = null, index = null, code = null) {
    // 処置コード
    this.code = mstCompTreatment ? mstCompTreatment.comp_treatment_cd : code ? code : null;
    // 処置内容
    this.treatment = mstCompTreatment ? mstCompTreatment.treatment : null;
    // 処置区分（デフォルトは処置）
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //this.treatClass = mstCompTreatment ? mstCompTreatment.treat_class : "2";
    this.treatClass = mstCompTreatment ? mstCompTreatment.treat_class : 2;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    // 処置薬剤
    this.treatMedicine = {
      code: mstCompTreatment ? mstCompTreatment.treat_medicine_cd : null,
      name: "",
      unit: "",
      decPoint: null
    };
    // 数量
    // add 9973 -4 by kangjie 20231026 start
    // this.amount = mstCompTreatment ? mstCompTreatment.amount : null;
    this.amount = mstCompTreatment ? mstCompTreatment.amount == null ? '' :mstCompTreatment.amount +'' : null;
    // add 9973 -4 by kangjie 20231026 end
    // 手技
    this.procedure = {
      code: mstCompTreatment ? mstCompTreatment.procedure_cd : null,
      name: ""
    };
    // 服用
    this.takeMedicine = {
      code: mstCompTreatment ? mstCompTreatment.take_medicine_cd : null,
      name: ""
    };
    // 表示フラグ("0":非表示,"1":表示)
    this.isDisp = mstCompTreatment ? mstCompTreatment.is_disp : "1";
    // 登録日時
    this.reg_date = mstCompTreatment ? mstCompTreatment.reg_date : null;
    // 更新日時
    this.up_date = mstCompTreatment ? mstCompTreatment.up_date : null;

    // 第1ソートキー
    this.sortRankFirst = index !== null ? index + 1 : 0;
    // 第2ソートキー
    this.sortRankSecond = 0;

    // 更新前データ退避
    this.initData = mstCompTreatment;
    this.initSortRankFirst = index !== null ? index + 1 : 0;

    // 利用開始日A
    this.inHospAStartdate = mstCompTreatment ? mstCompTreatment.in_hosp_astartdate : null;
    // 利用開始日B
    this.inHospBStartdate = mstCompTreatment ? mstCompTreatment.in_hosp_bstartdate : null;
    //連携コードA-1,2,3,4
    this.inHospitalCdA1 = mstCompTreatment ? mstCompTreatment.in_hospital_cd_a1 : null;
    this.inHospitalCdA2 = mstCompTreatment ? mstCompTreatment.in_hospital_cd_a2 : null;
    this.inHospitalCdA3 = mstCompTreatment ? mstCompTreatment.in_hospital_cd_a3 : null;
    this.inHospitalCdA4 = mstCompTreatment ? mstCompTreatment.in_hospital_cd_a4 : null;
    //連携コードB-1,2,3,4
    this.inHospitalCdB1 = mstCompTreatment ? mstCompTreatment.in_hospital_cd_b1 : null;
    this.inHospitalCdB2 = mstCompTreatment ? mstCompTreatment.in_hospital_cd_b2 : null;
    this.inHospitalCdB3 = mstCompTreatment ? mstCompTreatment.in_hospital_cd_b3 : null;
    this.inHospitalCdB4 = mstCompTreatment ? mstCompTreatment.in_hospital_cd_b4 : null;
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
   * 処置クラスが調整薬剤かどうか.
   */
  get isPreparationMedicine() {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //return this.treatClass === "0";
    return this.treatClass == 0;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  }

  /**
   * 処置クラスが薬剤かどうか.
   */
  get isMedicine() {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //return this.treatClass === "1";
    return this.treatClass == 1;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  }

  /**
   * 処置クラスが処置かどうか.
   */
  get isTreatment() {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //return this.treatClass === "2";
    return this.treatClass == 2;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  }

  /**
   * 処置マスタエンティティの形式で返す.
   */
  get entity() {
    const isUpdate = this.initData === null ? null :
      (this.treatment !== this.initData.treatment ||
        this.treatClass !== this.initData.treat_class ||
        this.treatMedicine.code !== this.initData.treat_medicine_cd ||
        (this.amount ? Number(this.amount).toFixed(2) : null) !== (this.initData.amount ? Number(this.initData.amount).toFixed(2) : null) ||
        this.procedure.code !== this.initData.procedure_cd ||
        this.takeMedicine.code !== this.initData.take_medicine_cd ||
        this.isDisp !== this.initData.is_disp ? null : this.up_date);
    return {
      comp_treatment_cd: this.code < 0 ? null : this.code,
      facility_cd: this.initData ? this.initData.facility_cd : null,
      treatment: this.treatment,
      treat_class: this.treatClass,
      treat_medicine_cd: this.treatMedicine.code,
      amount: this.amount,
      procedure_cd: this.procedure.code,
      take_medicine_cd: this.takeMedicine.code,
      is_disp: this.isDisp,
      is_del: '0',
      reg_date: this.reg_date,
      up_date: this.initData === null ? null : this.initData.up_date,
      is_update: isUpdate === null,
      in_hosp_astartdate: this.inHospAStartdate,
      in_hosp_bstartdate: this.inHospBStartdate,
      in_hospital_cd_a1: this.inHospitalCdA1,
      in_hospital_cd_a2: this.inHospitalCdA2,
      in_hospital_cd_a3: this.inHospitalCdA3,
      in_hospital_cd_a4: this.inHospitalCdA4,
      in_hospital_cd_b1: this.inHospitalCdB1,
      in_hospital_cd_b2: this.inHospitalCdB2,
      in_hospital_cd_b3: this.inHospitalCdB3,
      in_hospital_cd_b4: this.inHospitalCdB4
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
    return this.treatment || this.treatMedicine.code ? true : false;
  }

  /**
   * 今回編集したかどうか.
   */
  isEditedAtThisTime() {
    return !this.up_date && this.isEdited();
  }

  /**
   * ソートまたは表示フラグを変更したかどうか.
   */
  isSortedOrChangeDisp() {
    return this.sortRankSecond !== 0 || this.initData.is_disp != this.isDisp;
  }

  /**
   * 処置薬剤の参照先マスタが削除されているかどうか.
   */
  isTreatMedicineDeleted() {
    return this.treatMedicine.code && !this.treatMedicine.name;
  }

  /**
   * 手技の参照先マスタが削除されているかどうか.
   */
  isProcedureDeleted() {
    return this.procedure.code && !this.procedure.name;
  }
}
