/**
 * 投与薬剤情報（rst_medi_info）の集合を表現するクラス
 */
export class MediInfoList {
  constructor(list = []) {
    this.list = list;
    // 通常薬剤マスタ
    this.latestMedicineList = [];
    // 調整薬剤マスタ
    this.latestMedicineMixList = [];
    // 薬剤分類マスタ
    this.latestMedicineClassList = [];
    // 利用者マスタ
    this.latestPersonalUserList = [];
    // 手技選択コンボボックスデータ
    this.procedureComboList = [];
    // 投与タイミングコンボボックスデータ
    this.medicateTimingComboList = [];
    // 利用者情報
    this.stateUserAccountInfo = null;
  }

  /**
   * 投与薬剤全件を返します.
   */
  value() {
    return this.list;
  }

  /**
   * 投与薬剤を追加します.
   * @param {*} mediInfo 投与薬剤(1件)
   */
  add(mediInfo) {
    this.list.push(mediInfo);
    return this;
  }

  /**
   * 複数の投与薬剤を追加します。
   * @param {*} mediInfoArr 投与薬剤の配列
   */
  addAll(mediInfoArr) {
    this.list = this.list.concat(mediInfoArr);
    return this;
  }

  /**
   * 指定したインデックスの投与薬剤を返します.
   * @param {*} index 配列のインデックス
   */
  get(index) {
    return this.list[index];
  }

  /**
   * 指定したインデックスの投与薬剤を、新しい投与薬剤に置き換えます
   * @param {*} index 配列のインデックス
   * @param {*} mediInfo 投与薬剤
   */
  update(index, mediInfo) {
    this.list[index] = mediInfo;
  }

  /**
   * 指定したインデックスの投与薬剤を、削除します
   * @param {*} index  配列のインデックス
   * @returns mediInfo 投与薬剤
   */
  removeAt(index) {
    this.list.splice(index, 1);
    return this;
  }

  /**
   * 全ての要素を削除します
   */
  deleteAll() {
    this.list = [];
  }

  /**
   * リストの長さを返します
   */
  size() {
    return this.list.length;
  }

  /**
   * 投与薬剤情報の文字列表現を返します.
   */
  toString() {
    const listAsStr = this.list.map(mediInfo => mediInfo.toString());
    return `[${listAsStr.toString()}]`;
  }

  /**
   * 編集された薬剤情報があるかを返します.
   */
  hasEditedMediInfo() {
    return this.list.some(e => e.is_edited);
  }
  /**
   * 削除にチェックがついた薬剤情報があるかを返します.
   */
  beDeleted() {
    return this.list.some(e => e.be_deleted);
  }

  /**
   * インデックスで指定した薬剤情報について、薬剤と薬剤分類を最新に更新
   * @param {*} index this.listのインデックス
   */
  refreshMedicineAndClass(index) {
    // 薬剤情報を取得
    const mediInfo = this.list[index];
    // 通常薬剤か調整薬剤を判断
    // 判断は薬剤コードに[$]が含まれているか否か
    //let medicineType = "1";
    let medicineType = 1;
    let medicineCd;
    // 数値ではない場合、調整薬剤
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    //if (isNaN(mediInfo.cd)) {
    if (mediInfo.type == 2) {
      //medicineType = mediInfo.cd.indexOf('$') == -1 ? "1" : "2";
      //medicineType = mediInfo.cd.indexOf('$') == -1 ? 1 : 2;
      medicineType = mediInfo.type
      //medicineCd = Number(mediInfo.cd.split("$")[0]);
      medicineCd = Number(mediInfo.cd);
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    } else {
      medicineCd = mediInfo.cd;
    }
    // 薬剤マスタ
    let latestMedicine;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //if (medicineType === "1") {
    if (medicineType == 1) {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      latestMedicine = this.latestMedicineList.find(
        m => m.medicineCd == medicineCd// mod #9973 ind_cond value Number→文字列  shiyw
      );
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //} else if (medicineType === "2") {
    } else if (medicineType == 2) {
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      latestMedicine = this.latestMedicineMixList.find(
        m => m.medicineMixCd == medicineCd// mod #9973 ind_cond value Number→文字列  shiyw
      );
    }
    // 最新の薬剤に紐づく最新の薬剤の薬剤分類を取得
    let latestMedicineClass = undefined;

    // cd, name, short_name, unitを最新に更新

    mediInfo.cd =
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //latestMedicine === undefined ? null : medicineType === "1" ? latestMedicine.medicineCd : latestMedicine.medicineMixCd;
    latestMedicine === undefined ? null : medicineType == 1 ? latestMedicine.medicineCd : latestMedicine.medicineMixCd;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    // 薬剤名を設定
    mediInfo.name =
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //latestMedicine === undefined ? null : medicineType === "1" ? latestMedicine.medicineName : latestMedicine.medicineMixName;
      latestMedicine === undefined ? null : medicineType == 1 ? latestMedicine.medicineName : latestMedicine.medicineMixName;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    // 薬剤略称名を設定
    mediInfo.short_name =
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //latestMedicine === undefined ? null : medicineType === "1" ? latestMedicine.medicineShortName : latestMedicine.medicineMixShortName;
      latestMedicine === undefined ? null : medicineType == 1 ? latestMedicine.medicineShortName : latestMedicine.medicineMixShortName;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    // 単位を設定
    mediInfo.unit = latestMedicine === undefined ? null : latestMedicine.unit;
    // #9848+9849 薬剤変更時,薬剤マスタ依存＋薬剤マスタで未指定の場合変更しない linjunfeng start
    if (latestMedicine.procedureCd) {
      mediInfo.procedure_cd = latestMedicine.procedureCd;
      this.refreshProcedure(index);
    }
    if (latestMedicine.medicateTimingCd) {
      mediInfo.timing_cd = latestMedicine.medicateTimingCd;
      this.refreshMedicateTiming(index);
    }
    // #9848+9849 薬剤変更時,薬剤マスタ依存＋薬剤マスタで未指定の場合変更しない linjunfeng end

    if (latestMedicine) {
      latestMedicineClass = this.latestMedicineClassList.find(
        c => c.classCd === latestMedicine.classCd && c.isDisp === "1"
      );
    }
    mediInfo.medicine_type = medicineType;

    // 薬剤小数点桁数を設定
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //mediInfo.decPoint = latestMedicine === undefined ? null : medicineType === "1" ? latestMedicine.unitDecimalPoint : latestMedicine.unitDecimalPoint;
    mediInfo.decPoint = latestMedicine === undefined ? null : medicineType == 1 ? latestMedicine.unitDecimalPoint : latestMedicine.unitDecimalPoint;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

    // class_cdとclass_nameとclass_typeを最新に更新

    // latestMedicineClass === undefinedの場合はlatestMedicine.classCdを設定する
    // latestMedicine === undefinedの場合はnullを設定する
    if (latestMedicineClass === undefined) {
      mediInfo.class_cd =
        latestMedicine === undefined ? null : latestMedicine.classCd;
    } else {
      mediInfo.class_cd = latestMedicineClass.classCd;
    }
    mediInfo.class_name =
      latestMedicineClass === undefined ? null : latestMedicineClass.className;
    mediInfo.class_type =
      latestMedicineClass === undefined ? null : latestMedicineClass.classType;
  }

  /**
   * 最新の手技マスタ情報から情報を更新する
   * @param {*} index this.listのインデックス
   */
  refreshProcedure(index) {
    // 薬剤情報を取得
    const mediInfo = this.list[index];
    const procedureCd = mediInfo.procedure_cd;
    const procedure = this.procedureComboList.find(p => p.cd === procedureCd);
    mediInfo.procedure_name = procedure === undefined ? null : procedure.text;

    //mediInfo.medicine_type = 1;
  }

  /**
   * 最新の時間帯マスタ情報から情報を更新する
   * @param {*} index this.listのインデックス
   */
  refreshMedicateTiming(index) {
    // 薬剤情報を取得
    const mediInfo = this.list[index];
    const timingCd = mediInfo.timing_cd;
    const timing = this.medicateTimingComboList.find(t => t.cd == timingCd); // mod #9973 value Number→文字列  shiyw
    mediInfo.timing_name = timing === undefined ? null : timing.text;

    //mediInfo.medicine_type = 1;
  }

  /**
   * 最新の利用者マスタ情報から情報を更新する
   * @param {*} index this.listのインデックス
   */
  refreshEffectUser(index) {
    // 薬剤情報を取得
    const mediInfo = this.list[index];
    const personalUser = this.latestPersonalUserList.find(
      user => user.userId === mediInfo.effect_user_id
    );
    mediInfo.setEffectUser({
      id: personalUser === undefined ? null : personalUser.userId,
      lastName: personalUser === undefined ? null : personalUser.userLastName,
      firstName: personalUser === undefined ? null : personalUser.userFirstName
    });
    //mediInfo.medicine_type = 1;
  }

  /**
   * 最新の各種マスタ情報からマスタ情報と薬剤情報を更新する
   * @param {*} index this.listのインデックス
   */
  refreshAllMasterAndMediInfo(index) {
    // 薬剤情報を取得
    const mediInfo = this.list[index];

    // 薬剤情報を更新
    this.refreshMedicineAndClass(index);

    // 手技を更新
    this.refreshProcedure(index);

    // 時間帯を更新
    this.refreshMedicateTiming(index);

    // 実施者を更新
    this.refreshEffectUser(index);

    // 更新者を設定
    mediInfo.setUpdUser(this.stateUserAccountInfo);
  }

  /**
   * 最新の各種マスタ情報から情報を更新する
   * @param {*} index this.listのインデックス
   */
  refreshAllMaster(index) {
    //薬剤情報を取得
    const mediInfo = this.list[index];

    // 手技を更新
    this.refreshProcedure(index);

    // 時間帯を更新
    this.refreshMedicateTiming(index);

    // 実施者を更新
    this.refreshEffectUser(index);

    // 更新者を設定
    mediInfo.setUpdUser(this.stateUserAccountInfo);
  }

  /**
   * 薬剤名が入力済みかを返す
   * @param {*} mediInfoArr validate対象データ
   */
  hasMedicineName(mediInfoArr) {
    return mediInfoArr.every(m => m.hasName());
  }

  /**
   * 数量が入力済みかを返す
   * @param {*} mediInfoArr validate対象データ
   */
  hasAmount(mediInfoArr) {
    return mediInfoArr.every(m => m.hasAmount());
  }

  /**
   * 手技が入力済みかを返す
   * @param {*} mediInfoArr validate対象データ
   */
  hasProcedure(mediInfoArr) {
    return mediInfoArr.every(m => m.hasProcedure());
  }

  /**
   * 実施者が入力済みかを返す
   * @param {*} mediInfoArr validate対象データ
   */
  hasEffectUser(mediInfoArr) {
    return mediInfoArr.every(m => m.hasEffectUser());
  }

  /**
   * 必要項目が入力済みかをチェックする
   */
  validate() {
    const targetMediInfo = this.getUpdateMediInfoList().value();

    return {
      name: this.hasMedicineName(targetMediInfo),
      amount: this.hasAmount(targetMediInfo),
      procedure: this.hasProcedure(targetMediInfo),
      effectUser: this.hasEffectUser(targetMediInfo)
    };
  }

  /**
   * 更新対象の薬剤情報を取得する
   */
  getUpdateMediInfoList() {
    const targetMediInfo = this.list.slice();

    // 先頭行が未入力の場合は対象から除外
    if (targetMediInfo.lenght > 0 && targetMediInfo[0].isEmpty()) {
      targetMediInfo.shift();
    }

    return new MediInfoList(targetMediInfo);
  }
}
