/**
 * 医療材料情報（rst_equip_info）の1件分の医療材料を表現するクラス
 */
/* modify by chamaojia 2024-01-31 [10196] 指示者、更新者削除 --start */
export class Equipment {
  constructor(
    be_deleted = false,
    is_edited = false,
    class_cd,
    class_name,
    class_type,
    cd,
    name,
    short_name,
    // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
    // needle_type = 0,
    // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
    amount = null,
    unit,
    // ind_user_id,
    // ind_user_last_name,
    // ind_user_first_name,
    // upd_user_id,
    // upd_user_last_name,
    // upd_user_first_name,
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //input_class = "1",
    input_class = 1,
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    is_editable = "1",
    cop_order_no = null,
    equip_type = null,
    //add FNSI-改修内容 新規ボタン追加 房 start
    isNew,
    //add FNSI-改修内容 新規ボタン追加 房 end
  ) {
    this.be_deleted = be_deleted; // 削除対象かどうか（true: 削除対象である）
    this.is_edited = is_edited; // 編集されたかどうか（true: 編集された）
    this.class_cd = class_cd; //医療材料分類コード
    this.class_name = class_name; //医療材料分類名
    this.class_type = class_type; //分類区分
    this.cd = cd; //医療材料コード
    this.name = name; //医療材料名
    this.short_name = short_name; //省略医療材料名
    // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
    // this.needle_type = needle_type; //穿刺針区分
    // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
    this.amount = amount; //数量
    this.unit = unit; //単位
    // this.ind_user_id = ind_user_id; //指示者コード(利用者マスタ.利用者ID)
    // this.ind_user_last_name = ind_user_last_name; //指示者名_姓(利用者マスタ.利用者名_姓)
    // this.ind_user_first_name = ind_user_first_name; //指示者名_名(利用者マスタ.利用者名_名)
    // this.upd_user_id = upd_user_id; //更新者コード(利用者マスタ.利用者ID)
    // this.upd_user_last_name = upd_user_last_name; //更新者名_姓(利用者マスタ.利用者名_姓)
    // this.upd_user_first_name = upd_user_first_name; //更新者名_名(利用者マスタ.利用者名_名)
    this.input_class = input_class; //登録区分
    this.is_editable = is_editable; //編集可否フラグ
    this.cop_order_no = cop_order_no; //連携オーダ番号
    this.equip_type = equip_type; //医療材料区分
    //add FNSI-改修内容 新規ボタン追加 房 start
    this.isNew = isNew;
    //add FNSI-改修内容 新規ボタン追加 房 end
  }

  /**
   * ord_main.rst_equip_infoに設定される文字列表現を返す。
   */
  /* eslint-disable*/
  toString() {
    const ignoreFields = [
      'be_deleted',
      'is_edited',
      'isNew'
    ];
    return JSON.stringify(this, (key, value) => {
      if (ignoreFields.includes(key)) {
        return undefined;
      }
      return value === undefined ? null : value;
    });
  }

  /**
   * 更新者を設定する
   * @param {*} stateUserAccountInfo サインインしてるユーザ情報
   */
  setUpdUser(stateUserAccountInfo) {
    this.is_edited = true;

    // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
    // this.upd_user_id = stateUserAccountInfo.userId;
    // this.upd_user_last_name = stateUserAccountInfo.userLastName;
    // this.upd_user_first_name = stateUserAccountInfo.userFirstName;
    // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
  }

  /**
   * 医療材料名が入力済みかを返す
   */
  hasName() {
    return !!this.name;
  }

  /**
   * 数量が入力済みかを返す
   */
  hasAmount() {
    return !!this.amount;
  }

  /**
   * 医療材料情報に何も入力されていないかどうかを返す
   */
  isEmpty() {
    return !(
      this.hasName() ||
      this.hasAmount()
    );
  }

  static of(obj = {}) {
    // return new Equipment(
    //   false,
    //   false,
    //   obj.class_cd,
    //   obj.class_name,
    //   obj.class_type,
    //   obj.cd,
    //   obj.name,
    //   obj.short_name,
    //   // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
    //   // obj.needle_type,
    //   // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
    //   obj.amount,
    //   obj.unit,
    //   // obj.ind_user_id,
    //   // obj.ind_user_last_name,
    //   // obj.ind_user_first_name,
    //   // obj.upd_user_id,
    //   // obj.upd_user_last_name,
    //   // obj.upd_user_first_name,
    //   obj.input_class,
    //   obj.is_editable,
    //   obj.cop_order_no,
    //   obj.equip_type,
    //   //add FNSI-改修内容 新規ボタン追加 房 start
    //   obj.isNew != undefined ? obj.isNew : false,
    //   //add FNSI-改修内容 新規ボタン追加 房 end
    // );

    const ins = new Equipment(
      false,
      false,
      obj.class_cd,
      obj.class_name,
      obj.class_type,
      obj.cd,
      obj.name,
      obj.short_name,
      // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
      // obj.needle_type,
      // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
      obj.amount,
      obj.unit,
      // obj.ind_user_id,
      // obj.ind_user_last_name,
      // obj.ind_user_first_name,
      // obj.upd_user_id,
      // obj.upd_user_last_name,
      // obj.upd_user_first_name,
      obj.input_class,
      obj.is_editable,
      obj.cop_order_no,
      obj.equip_type,
      //add FNSI-改修内容 新規ボタン追加 房 start
      obj.isNew != undefined ? obj.isNew : false,
      //add FNSI-改修内容 新規ボタン追加 房 end
    );
    //#11397 add no start
    if (obj.no !== undefined) {
      ins.no = obj.no;
    }
    //#11397 add no start
    return ins;
  }
}
/* modify by chamaojia 2024-01-31 [10196] 指示者、更新者削除 --end */
