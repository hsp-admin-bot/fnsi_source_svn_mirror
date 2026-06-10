/**
 * 医療材料情報（rst_equip_info）の集合を表現するクラス
 */
export class EquipmentList {
  constructor(list = []) {
    this.list = list;
    this.latestEquipmentList = [];
    this.latestEquipmentClassList = [];
    this.latestDialyzerList = [];
  }

  /**
   * 医療材料全件を返します.
   */
  value() {
    return this.list;
  }

  /**
   * 医療材料を追加します.
   * @param {*} equipment 医療材料(1件)
   */
  add(equipment) {
    this.list.push(equipment);
  }

  /**
   * 複数の医療材料を追加します。
   * @param {*} equipmentArr 医療材料の配列
   */
  addAll(equipmentArr) {
    this.list = this.list.concat(equipmentArr);
    return this;
  }

  /**
   * 指定したインデックスの医療材料を返します.
   * @param {*} index 配列のインデックス
   */
  get(index) {
    return this.list[index];
  }

  /**
   * 指定したインデックスの医療材料を、新しい医療材料に置き換えます
   * @param {*} index 配列のインデックス
   * @param {*} equipment 医療材料
   */
  update(index, equipment) {
    this.list[index] = equipment;
  }

  /**
   * インデックスで指定した医療材料情報について、医療材料と医療材料分類を最新の状態に更新する.
   * @param {*} index this.listのインデックス
   */
  refreshEquipmentAndClass(index) {
    // 医療材料情報を取得
    const equip = this.list[index];
    // mod #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
     // cd、equip_typeにて最新の医療材料を取得
    //  let latestEquipmentList = equip.equip_type === 1 ? this.latestDialyzerList : this.latestEquipmentList;
    //  let latestEquipment = latestEquipmentList.find(
    //    e => e.equipmentCd === equip.cd
    //  );
    //  // 最新のマスタから、医療材料名、省略医療材料名、単位を取得する
    //  equip.name = latestEquipment === undefined ? null : latestEquipment.equipmentName;
    //  if (equip.equip_type === 1) {
    //    equip.short_name =  latestEquipment === undefined ? null : latestEquipment.equipmentName;
    //  } else {
    //    equip.short_name = latestEquipment === undefined ? null : latestEquipment.equipmentShortName;
    //  }
    //  equip.unit = latestEquipment === undefined ? null : latestEquipment.unit;
    //  // 最新の医療材料に紐づく最新の医療材料の医療材料分類を取得
    //  let latestEquipmentClass = undefined;
    //  if (latestEquipment) {
    //    latestEquipmentClass = this.latestEquipmentClassList.find(
    //      c => c.classCd === latestEquipment.classCd && c.isDisp === "1"
    //    );
    //  }
    //  // class_cdとclass_nameとclass_typeを最新に更新
    //  // ダイアライザの場合はlatestEquipment.classCd(null)を設定する
    //  // latestEquipment === undefinedの場合はnullを設定する
    //  if (latestEquipmentClass === undefined) {
    //    equip.class_cd =
    //      latestEquipment === undefined ? null : latestEquipment.classCd;
    //  } else {
    //    equip.class_cd = latestEquipmentClass.classCd;
    //  }
    //  equip.class_name =
    //    latestEquipmentClass === undefined
    //      ? null
    //      : latestEquipmentClass.className;
    //  equip.class_type =
    //    latestEquipmentClass === undefined
    //      ? null
    //      : latestEquipmentClass.classType;

    if (equip.equip_type === 1) {
      const latestEquipment = this.latestDialyzerList.find(e => e.dialyzerCd == equip.cd?.replace("dialyzer", "") || "") || {};
      
      equip.name = latestEquipment?.modelNumber || null;
      equip.short_name = latestEquipment?.modelNumber || null;
      equip.unit = "本";
      equip.class_cd = null;
      equip.class_name = null;
      equip.class_type = null;
    } else {
      const latestEquipment = this.latestEquipmentList.find(e => e.equipmentCd === equip.cd) || {};
      
      equip.name = latestEquipment?.equipmentName || null;
      equip.short_name = latestEquipment?.equipmentShortName || null;
      equip.unit = latestEquipment?.unit || null;
    
      const latestEquipmentClass = this.latestEquipmentClassList.find(
        c => c.classCd === latestEquipment?.classCd && c.isDisp === "1"
      ) || {};
    
      equip.class_cd = latestEquipmentClass?.classCd || latestEquipment?.classCd || null;
      equip.class_name = latestEquipmentClass?.className || null;
      equip.class_type = latestEquipmentClass?.classType ?? null;
    }
    // mod #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
  }

  /**
   * 編集された医療材料情報があるかどうかを返します.
   */
  hasEditedEquipment() {
    return this.list.some(e => e.is_edited);
  }

  /**
   * 削除にチェックがついた医療材料情報があるかどうかを返します.
   */
  beDeleted() {
    return this.list.some(e => e.be_deleted);
  }

  /**
   * 指定したインデックスの医療材料情報を、削除します
   * @param {*} index  配列のインデックス
   * @returns mediInfo 医療材料情報
   */
  removeAt(index) {
    this.list.splice(index, 1);
    return this;
  }

  /**
   * リストの中身を全て削除します.
   */
  deleteAll() {
    this.list = [];
  }

  /**
   * 医療材料名が入力済みかどうかを返す
   * @param {*} equipmentArr validate対象データ
   */
  hasEquipmentName(equipmentArr) {
    return equipmentArr.every(e => e.hasName());
  }

  /**
   * 数量が入力済みかどうかを返す
   * @param {*} equipmentArr validate対象データ
   */
  hasAmount(equipmentArr) {
    return equipmentArr.every(e => e.hasAmount());
  }

  /**
   * 必要項目が入力済みかどうかをチェックする
   */
  validate() {
    const targetEquipmentList = this.getUpdateEquipmentList().value();

    return {
      name: this.hasEquipmentName(targetEquipmentList),
      amount: this.hasAmount(targetEquipmentList)
    };
  }

  /**
   * 更新対象の医療材料情報を取得する
   */
  getUpdateEquipmentList() {
    const targetEquipment = this.list.slice();

    // 先頭行が未入力の場合は対象から除外
    if (targetEquipment[0].isEmpty()) {
      targetEquipment.shift();
    }

    return new EquipmentList(targetEquipment);
  }

  /**
   * 医療材料情報の文字列表現を返します.
   */
  toString() {
    const listAsStr = this.list.map(equipment => equipment.toString());
    return `[${listAsStr.toString()}]`;
  }
}
