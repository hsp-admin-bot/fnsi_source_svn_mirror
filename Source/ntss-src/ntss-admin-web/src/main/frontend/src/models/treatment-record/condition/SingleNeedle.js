/**
 * 治療条件画面のシングルニードルを表現するクラス
 */
import { CODES } from "@/constants/TreatmentRecord";
import {
  numberToString,
  stringToNumber
} from "@/models/treatment-record/Helper";

export class SingleNeedle {
  constructor(rstCondInfo = null) {
    if (rstCondInfo === null) {
      rstCondInfo = {};
    }

    // シングルニードル使用(12)
    const single = rstCondInfo[CODES.TREATMENT_CONDITION_ITEM.SINGLE_NEEDLE.cd]
     ? rstCondInfo[CODES.TREATMENT_CONDITION_ITEM.SINGLE_NEEDLE.cd]
     : this.createEmpty();

    this.singleNeedle = numberToString(single.value);
  }

  /**
   * シングルニードルにSingleNeedleモデルを反映.
   * @param {*} updateObject 更新用オブジェクト
   */
  reflect(updateObject) {
    if (!updateObject.rst_cond_info) {
      updateObject.rst_cond_info = {};
    }
    if (updateObject.rst_cond_info[CODES.TREATMENT_CONDITION_ITEM.SINGLE_NEEDLE.cd]) {
      updateObject.rst_cond_info[CODES.TREATMENT_CONDITION_ITEM.SINGLE_NEEDLE.cd] = this.createEmpty();
    }
    /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --start */
    updateObject.rst_cond_info[
      CODES.TREATMENT_CONDITION_ITEM.SINGLE_NEEDLE.cd
    ].value = this.singleNeedle;
    /* modify by chamaojia 2024-01-31 [10196] "Value" assignment string --end */
  }

  /**
   * 空の要素を作成
   */
  createEmpty() {
    return {
      unit: null,
      value: null,
      input_class: CODES.CONDITION_INPUT_CLASS.CLIENT.cd,
      is_editable: CODES.IS_EDITABLE.POSSIBLE.cd,
      cop_order_no: null,
      value_name_1: null,
      /* del by chamaojia 2024-01-30 [10196] Delete unnecessary attributes  --start */
      // value_name_2: null,
      // value_name_3: null,
      // value_name_4: null,
      // value_name_5: null,
      // value_name_6: null,
      // value_name_7: null,
      // value_name_8: null,
      // value_name_9: null,
      // value_name_10: null,
      // medicine_type: null,
      // ind_user_id: null,
      // ind_user_last_name: null,
      // ind_user_first_name: null,
      // upd_user_id: null,
      // upd_user_last_name: null,
      // upd_user_first_name: null
      /* del by chamaojia 2024-01-30 [10196] Delete unnecessary attributes  --end */
    };
  }
}
