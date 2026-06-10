/**
 * マージ対象項目定義.
 */
export const MERGE_ITEM_TYPES = {
  //add FNSI修正486改修 房 start
  TREATMENT: {
    name: "治療方法",
    properties: ["rst_treatment_cd", "rst_treatment_name"]
  },
  //add FNSI修正486改修 房 end
  KUR: {
    name: "クール",
    properties: ["rst_kur_cd", "rst_kur_name"]
  },
  BED: {
    name: "ベッド",
    properties: ["rst_bed_cd", "rst_bed_name"]
  },
  COND_SEND_DATE: {
    name: "条件送信日時",
    properties: ["rst_cond_send_date"]
  },
  ACCEPT_DATE: {
    name: "受付日時",
    properties: ["rst_accept_date"]
  },
  START_DATE: {
    name: "治療開始日時",
    properties: ["rst_start_date"]
  },
  END_DATE: {
    name: "治療終了日時",
    properties: ["rst_end_date"]
  },
  RETURN_HOME_DATE: {
    name: "帰宅日時",
    properties: ["rst_return_home_date"]
  },
  IN_OUT_CLASS: {
    name: "入外区分",
    properties: ["rst_in_out_class"]
  },
  DIALYSIS_CNT: {
    name: "透析回数",
    properties: ["rst_dialysis_cnt"]
  },
  PURIFICATION_CNT: {
    name: "特殊浄化回数",
    properties: ["rst_purification_cnt"]
  },
  WARD: {
    name: "病棟",
    properties: ["rst_ward_cd", "rst_ward_name"]
  },
  COURSE: {
    name: "診療科",
    properties: ["rst_course_cd", "rst_course_name"]
  },
  PUNCTURE_USER_NAME_1: {
    name: "穿刺者名1",
    base_property: "rst_puncture_user_info",
    properties: ["user_id_1", "user_last_name_1", "user_first_name_1", "date_1"]
  },
  PUNCTURE_USER_NAME_2: {
    name: "穿刺者名2",
    base_property: "rst_puncture_user_info",
    properties: ["user_id_2", "user_last_name_2", "user_first_name_2", "date_2"]
  },
  PUNCTURE_DATE: {
    name: "穿刺日時",
    base_property: "rst_puncture_user_info",
    properties: ["date"]
  },
  RETURN_USER_NAME_1: {
    name: "返血者名1",
    base_property: "rst_return_user_info",
    properties: ["user_id_1", "user_last_name_1", "user_first_name_1", "date_1"]
  },
  RETURN_USER_NAME_2: {
    name: "返血者名2",
    base_property: "rst_return_user_info",
    properties: ["user_id_2", "user_last_name_2", "user_first_name_2", "date_2"]
  },
  RETURN_DATE: {
    name: "返血日時",
    base_property: "rst_return_user_info",
    properties: ["date"]
  },
  RETURN_CHARGE_NAME_1: {
    name: "担当者名1",
    base_property: "rst_charge_user_info",
    properties: ["user_id_1", "user_last_name_1", "user_first_name_1", "date_1"]
  },
  RETURN_CHARGE_NAME_2: {
    name: "担当者名2",
    base_property: "rst_charge_user_info",
    properties: ["user_id_2", "user_last_name_2", "user_first_name_2", "date_2"]
  },
  BLOOD_CIRCULATE_TOTAL: {
    name: "血液循環積算値",
    properties: null
  },
  KT_V: {
    name: "Kt/V",
    properties: ["rst_kt_v"]
  },
  SET_DATE: {
    name: "透析記録確認日時",
    properties: ["rec_set_date"]
  },
  SEND_CTL_NO: {
    name: "送信管理番号",
    properties: ["send_ctl_no"]
  },
  BLOOD_PURIFIER_NAME: {
    name: "血液浄化装置名称",
    properties: ["blood_purifier_name"]
  },
  PULL_LEAVE_AMOUNT: {
    name: "プログラム補液引き残し量",
    properties: ["pull_leave_amount"]
  },
  COND_INFO: {
    group: true,
    name: "治療条件情報",
    properties: ["rst_cond_info"]
  },
  //add FNSI修正486改修 房 start
  COND_INFO_DETAIL: {
    subdetail: true,
    name: "治療条件情報明細",
    properties: null
  },
  //add FNSI修正486改修 房 end
  MEDI_INFO: {
    group: true,
    name: "投与薬剤情報",
    properties: null
  },
  MEDI_INFO_DETAIL: {
    detail: true,
    name: "投与薬剤情報明細",
    properties: null
  },
  EQUIP_INFO: {
    group: true,
    name: "医療材料情報",
    properties: null
  },
  EQUIP_INFO_DETAIL: {
    detail: true,
    name: "医療材料情報明細",
    properties: null
  },
  IND_COMMENT_INFO: {
    group: true,
    name: "指示コメント情報",
    properties: null
  },
  //add FNSI修正486改修 房 start
  IND_COMMENT_INFO_DETAIL: {
    detail: true,
    name: "指示コメント情報明細",
    properties: null
  },
  //add FNSI修正486改修 房 end
  TARE_INFO:{
    group: true,
    name: "風袋補正情報",
    properties: null
  },
  TARE_INFO_BEFORE_1: {
    name: "風袋補正1(透析前)",
    base_property: "rst_tare_info.before",
    properties: ["name_1", "weight_1"]
  },
  TARE_INFO_BEFORE_2: {
    name: "風袋補正2(透析前)",
    base_property: "rst_tare_info.before",
    properties: ["name_2", "weight_2"]
  },
  TARE_INFO_BEFORE_3: {
    name: "風袋補正3(透析前)",
    base_property: "rst_tare_info.before",
    properties: ["name_3", "weight_3"]
  },
  TARE_INFO_BEFORE_4: {
    name: "風袋補正4(透析前)",
    base_property: "rst_tare_info.before",
    properties: ["name_4", "weight_4"]
  },
  TARE_INFO_BEFORE_5: {
    name: "風袋補正5(透析前)",
    base_property: "rst_tare_info.before",
    properties: ["name_5", "weight_5"]
  },
  TARE_INFO_BEFORE_WHEEL_CHAIR: {
    name: "車いす(透析前)",
    base_property: "rst_tare_info.before",
    properties: ["wheel_chair_cd", "wheel_chair_name", "wheel_chair_weight"]
  },
  TARE_INFO_AFTER_1: {
    name: "風袋補正1(透析後)",
    base_property: "rst_tare_info.after",
    properties: ["name_1", "weight_1"]
  },
  TARE_INFO_AFTER_2: {
    name: "風袋補正2(透析後)",
    base_property: "rst_tare_info.after",
    properties: ["name_2", "weight_2"]
  },
  TARE_INFO_AFTER_3: {
    name: "風袋補正3(透析後)",
    base_property: "rst_tare_info.after",
    properties: ["name_3", "weight_3"]
  },
  TARE_INFO_AFTER_4: {
    name: "風袋補正4(透析後)",
    base_property: "rst_tare_info.after",
    properties: ["name_4", "weight_4"]
  },
  TARE_INFO_AFTER_5: {
    name: "風袋補正5(透析後)",
    base_property: "rst_tare_info.after",
    properties: ["name_5", "weight_5"]
  },
  TARE_INFO_AFTER_WHEEL_CHAIR: {
    name: "車いす(透析後)",
    base_property: "rst_tare_info.after",
    properties: ["wheel_chair_cd", "wheel_chair_name", "wheel_chair_weight"]
  },
  OFF_WATER_INFO: {
    group: true,
    name: "除水補正情報",
    properties: null
  },
  OFF_WATER_INFO_1: {
    name: "除水補正1",
    base_property: "rst_off_water_info",
    properties: ["name_1", "weight_1"]
  },
  OFF_WATER_INFO_2: {
    name: "除水補正2",
    base_property: "rst_off_water_info",
    properties: ["name_2", "weight_2"]
  },
  OFF_WATER_INFO_3: {
    name: "除水補正3",
    base_property: "rst_off_water_info",
    properties: ["name_3", "weight_3"]
  },
  OFF_WATER_INFO_4: {
    name: "除水補正4",
    base_property: "rst_off_water_info",
    properties: ["name_4", "weight_4"]
  },
  OFF_WATER_INFO_5: {
    name: "除水補正5",
    base_property: "rst_off_water_info",
    properties: ["name_5", "weight_5"]
  },
  WEIGHT_INFO: {
    group: true,
    name: "体重情報",
    properties: null
  },
  //add FNSI修正486改修 房 start
  WEIGHT_INFO_DETAIL_1: {
    detail: true,
    name: "体重情報明細",
    properties: null
  },
  WEIGHT_INFO_CTR_DETAIL: {
    subdetail: true,
    name: "CTR",
    base_property: "rst_weight_info",
    properties: ["ctr", "ctr_measure_date", "ctr_weight"]
  },
  WEIGHT_INFO_DETAIL_2: {
    detail: true,
    name: "体重情報明細1",
    properties: null
  },
  WEIGHT_INFO_RECRCL_DETAIL: {
    subdetail: true,
    name: "再循環率",
    /*#10344 再循環率単一レコードをマージ --start */
    // base_property: "rst_weight_info",
    // properties: ["recrcl_rt"]
    base_property: null,
    properties: null
    /*#10344 再循環率単一レコードをマージ --end */
  },
  WEIGHT_INFO_DETAIL_3: {
    detail: true,
    name: "体重情報明細2",
    properties: null
  },
  //add FNSI修正486改修 房 end
  VITAL_INFO: {
    group: true,
    name: "バイタル情報",
    properties: null
  },
  MONITOR_INFO: {
    group: true,
    name: "モニタ情報",
    properties: null
  },
  //add FNSI修正486改修 房 start
  COMPLAINT_INFO: {
    group: true,
    name: "愁訴処置",
    properties: null
  },
  ROUNDS_INFO: {
    group: true,
    name: "回診記録情報",
    properties: ["rst_rounds_info"]
  },
  CHECK_LIST_INFO: {
    group: true,
    name: "チェックリスト",
    properties: ["rst_check_list"]
  },
  DEVICE_SET_RECORD: {
    group: true,
    name: "装置記録",
    properties: null
  },
  DEVICE_SET_INFO: {
    group: true,
    name: "装置設定情報",
    properties: ["rst_device_set_info"]
  },
  WEIGHT_SCALE_NO: {
    name: "体重測定記録番号",
    properties: ["weight_scale_no"]
  },
  //add FNSI修正486改修 房 end
};
//add FNSI修正486改修 房 start
export const CONDITION_ITEM_NAMES = [
  "治療時間",
  "VA",
  "目標体重",
  "除水量制限",
  "ダイアライザ",
  "吸着カラム",
  "1次膜",
  "2次膜",
  "穿刺針(A針)",
  "穿刺針(V針)",
  "穿刺針(SN)",
  "シングルニードル使用",
  "血液回路",
  "血流量",
  "透析液",
  "透析液流量",
  "透析液量",
  "透析液温度",
  "補液",
  "補液量",
  "補液選択",
  "補液使用数",
  "補液温度",
  "補液速度",
  "抗凝固剤",
  "抗凝固剤ワンショット量",
  "抗凝固剤持続速度",
  "抗凝固剤持続総量",
  "IP使用選択",
  "IPスタート",
  "IPワンショット量",
  "IP速度",
  "IP速度最大値",
  "IPワンショットスタート",
  "IP電源自動切り",
  "IP電源自動切り時間",
  "IP電源OKモニタ切り",
  "IP電源OKモニタ切り時間",
  // "DW"
];
export const CONDITION_ITEM_UNIT = {
  4:"L",
  3:"kg",
  14:"mL/min",
  16:"mL/min",
  18:"℃",
  20:"L",
  23:"℃",
  24:"L/h",
  32:"mL/h",
  33:"mL/h",
  31:"mL",
  39:"kg"
}
//add FNSI修正486改修 房 end

/**
 * 実績マージ画面のマージ対象項目情報を表現するクラス.
 */
export class ResultMergeItem {
  //add FNSI修正486改修 房 start
  constructor(type, value = null, key = null,
              // #10344 condNo doesn't exist means not available in mst
              available = false,
              details = [], selectNum = 1, rowNum = 1, cd) {
    //add FNSI修正486改修 房 end
    // 選択フラグ
    this._selected = false;

    // 項目説明
    this.type = type;

    // #10196 fixed:empty content shouldn't show as a 'null' String.
    // マージ項目の値
    if (!value || value === 'null') value = "";
    this.value = value;

    // マージ項目の比較用キー
    this.key = key;

    // 明細項目
    this.details = details;
    this.details.forEach(e => (e.parent = this));
    this._propagation = true;
    //add FNSI修正486改修 房 start
    this.be_selected = false;
    this.selectNum = selectNum;
    this.rowNum = rowNum;
    this.cd = cd;
    //add FNSI修正486改修 房 end

    // #10344 condNo doesn't exist means not available in mst
    this.available = available;
  }

  /**
   * 項目説明.
   */
  get description() {
    //add FNSI修正486改修 房 start
    return this.type.displayname != undefined ? this.type.displayname : this.type.detail ? this.value : this.type.name;
    //add FNSI修正486改修 房 end
  }

  /**
   * 項目がグループor明細かどうか.
   */
  get isGroupOrDetail() {
    return this.type.group || this.type.detail;
  }

  /**
   * 選択フラグGetter.
   */
  get selected() {
    return this._selected;
  }

  /**
   * 選択フラグSetter.
   */
  set selected(newVal) {
    this._selected = newVal;
    if (this._propagation) {
      this.details.forEach(e => {
        e.setSelectedNoPropagation(newVal);
      });
      if (this.parent) {
        this.parent.setSelectedNoPropagation(false);
      }
    }
  }

  /**
   * 選択フラグを変更する(伝播禁止).
   * @param {*} newVal 選択状態
   */
  setSelectedNoPropagation(newVal) {
    this._propagation = false;
    this.selected = newVal;
    this._propagation = true;
  }
}
