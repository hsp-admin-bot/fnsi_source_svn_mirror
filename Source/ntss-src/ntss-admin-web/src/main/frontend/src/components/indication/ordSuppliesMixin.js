/**
 * add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 start
 * 予実リスト表示コンポーネント用のMixin
 */
import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  props: {
    values: {
      type: Array,
      required: true
    }
  },

  methods: {
    async ordMaterialSave(values) {
      // 登録や修正の値がない場合は、メソッドを実行しない
      if (!values) return;

      // 登録や修正データを設定する
      let conditions = {};
      // 処理タイプ
      conditions.species = values.species;
      // 処理タイプ(1:予定作成)
      if (values.species == 1) {
        // 治療方法セットコード
        conditions.treatment_set_cd = values.treatmentSetCd;
        // 施設コード
        conditions.facility_cd = values.facilityCd;
        // 患者ID
        conditions.pat_id = values.patId;
        // データ基準日(復数可能)
        conditions.supplies_base_date = values.treatDateList;
        // 指示・実績区分
        conditions.ind_rst_class = '1';
        // 確定フラグ
        conditions.is_confirm = '0';

      // 処理タイプ(2:予定コーピ)
      } else if (values.species == 2) {
        // データ元基準番号
        conditions.original_base_no = values.ord_no;
        // 施設コード
        conditions.facility_cd = values.facility_cd;
        // 患者ID
        conditions.pat_id = values.pat_id;
        // データ基準日
        conditions.base_date = values.dialysis_date_to;
        // 指示・実績区分
        conditions.ind_rst_class = '1';
        // 確定フラグ
        conditions.is_confirm = '0';

      // 処理タイプ(3:予定中止)
      } else if (values.species == 3) {
        // 削除されたOrdNo
        conditions.ord_no_list = values.ordNoList;
      }

      // 登録や修正修理を行う
      await ApiHelper.post("/mainData/ord_material_save", conditions);
    }
  }
}
/* add FNSI-No.396 使用物品の指示、レセ換算結果の保持に対応 李 end */
