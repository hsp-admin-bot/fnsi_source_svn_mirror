/* mstTreatmentStatusDispItemConstants.js */
// --------------------------------------

// mst_treatment_status_disp_item の item_cd 定数
// コメントに item_name を記載
export const TREATMENT_ITEM_CD = {
  HOSP_PAT_ID: 2,                    // 患者ID
  DW: 4,                             // DW
  PRE_WEIGHT_DW: 5,                  // 前体重 - DW
  TARGET_WEIGHT: 6,                  // 目標体重
  PRE_WEIGHT_TARGET_WEIGHT: 7,       // 前体重 - 目標体重
  TREATMENT_START: 8,                // 治療開始
  END_PREDICTION: 9,                 // 終了予測
  END_PREDICTION_POST_REMOVAL: 10,   // 終了予測(除水完了)
  END_PREDICTION_POST_DIALYSIS: 11,  // 終了予測(透析終了)
  TREATMENT_END: 12,                 // 治療終了
  TREATMENT_TIME: 13,                // 治療時間
  STATIC_VENOUS_PRESSURE: 14,        // 静的静脈圧
  DELAY_TIME: 15,                    // 遅れ時間
  PRE_WEIGHT: 16,                    // 前体重
  PRE_BP_MAX: 17,                    // 前血圧(最高)
  PRE_BP_MIN: 18,                    // 前血圧(最低)
  PRE_BP_AVG: 19,                    // 前血圧(平均)
  PRE_BP: 20,                        // 前血圧
  PRE_PULSE: 21,                     // 前脈拍
  CURRENT_BP: 22,                    // 現在血圧
  STAFF1: 23,                        // 担当者1
  STAFF2: 25,                        // 担当者2
  PUNCTURE_DATETIME: 27,             // 穿刺日時
  PUNCTURE_PERSON1: 28,              // 穿刺者1
  PUNCTURE_PERSON2: 30,              // 穿刺者2
  RETURN_BLOOD_DATETIME: 32,         // 返血日時
  RETURN_PERSON1: 33,                // 返血者1
  RETURN_PERSON2: 35,                // 返血者2
  POST_WEIGHT: 37,                   // 後体重
  PRE_POST_WEIGHT_DIFF: 38,          // 前体重-後体重
  EXPECTED_REMNANT: 39,              // 予想引き残し
  REMNANT: 40,                       // 引き残し
  POST_BP_MAX: 41,                   // 後血圧(最高)
  POST_BP_MIN: 42,                   // 後血圧(最低)
  POST_BP_AVG: 43,                   // 後血圧(平均)
  POST_BP: 44,                       // 後血圧
  POST_PULSE: 45,                    // 後脈拍
  UF_TARGET: 46,                     // 除水目標
  IAP_RATIO: 47,                     // IAP Ratio
  IHDF_REMNANT: 48,                  // IHDF引き残し量
  ACHIEVEMENT_RATE: 49,              // 達成率
  PATIENT_CONFIRM: 50,               // 患者確認
  PRE_WEIGHT_MEASURE_TIME: 51,       // 前体重測定時刻
  END_SCHEDULE: 52,                  // 終了予定
  LAST_POST_WEIGHT: 53,              // 前回後体重
  INCREASE_AMOUNT: 54,               // 増加量
  INCREASE_RATE: 55,                 // 増加率
  BLOOD_FLOW: 56,                    // 血流量
  IP_SPEED: 57,                      // IP速度
  PROGRESS_RATE: 58,                 // 進捗率
  TREATMENT_DATE: 60,                // 治療日
  COOL: 61,                          // クール
  ROUND_STATE: 62,                   // 回診状態
  ROUND_DATA: 63,                    // 回診データ
  DOSAGE_STATUS: 64,                 // 投与状況
  OBSERVATION_COUNT: 65,             // 観察記録件数
  LATEST_COMPLAINT: 66,              // 最新愁訴
  LATEST_PROCEDURE: 67,              // 最新処置
  CTR: 68,                           // CTR
  PRE_WEIGHT_BAG_TOTAL: 69,          // 前体重風袋合計
  POST_WEIGHT_BAG_TOTAL: 70,         // 後体重風袋合計
  UF_CORRECTION_TOTAL: 71,           // 除水補正合計
  RECIRCULATION_RATE: 72,            // 再循環率有効値
  VA: 73,                            // VA
  UF_LIMIT: 74,                      // 除水量制限
  DIALYZER: 75,                      // ダイアライザ
  ADSORPTION_COLUMN: 76,             // 吸着カラム
  PRIMARY_MEMBRANE: 77,              // 1次膜
  SECONDARY_MEMBRANE: 78,            // 2次膜
  NEEDLE_A: 79,                      // 穿刺針(A針)
  NEEDLE_V: 80,                      // 穿刺針(V針)
  NEEDLE_SN: 81,                     // 穿刺針(SN)
  SINGLE_NEEDLE_USE: 82,             // シングルニードル使用
  BLOOD_CIRCUIT: 83,                 // 血液回路
  BLOOD_FLOW_TREATMENT: 84,          // 血流量（治療条件）
  DIALYSATE: 85,                     // 透析液
  DIALYSATE_FLOW_TREATMENT: 86,      // 透析液流量(治療条件)
  DIALYSATE_USE_COUNT: 87,           // 透析液使用数
  DIALYSATE_TEMP_TREATMENT: 88,      // 透析液温度(治療条件)
  INFUSION: 89,                      // 補液
  INFUSION_VOLUME: 90,               // 補液量
  INFUSION_SELECTION: 91,            // 補液選択
  INFUSION_USE_COUNT: 92,            // 補液使用数
  INFUSION_TEMP_TREATMENT: 93,       // 補液温度(治療条件)
  INFUSION_SPEED_TREATMENT: 94,      // 補液速度(治療条件)
  ANTICOAGULANT: 95,                 // 抗凝固剤
  ANTICOAGULANT_ONE_SHOT: 96,        // 抗凝固剤ワンショット量
  ANTICOAGULANT_CONTINUOUS_SPEED: 97,// 抗凝固剤持続速度
  ANTICOAGULANT_CONTINUOUS_TOTAL: 98,// 抗凝固剤持続総量
  IP_USE_SELECTION: 99,              // IP使用選択
  IP_START: 100,                     // IPスタート
  IP_ONE_SHOT: 101,                  // IPワンショット量
  IP_SPEED_TREATMENT: 102,           // IP速度（治療条件）
  IP_SPEED_MAX: 103,                 // IP速度最大値
  AUTO_ONE_SHOT: 104,                // IPワンショットスタート
  IP_POWER_AUTO_OFF: 105,            // IP電源自動切り
  IP_POWER_AUTO_OFF_TIME: 106,       // IP電源自動切り時間
  IP_POWER_MONITOR_OK_OFF: 107,      // IP電源OKモニタ切り
  IP_POWER_MONITOR_OK_OFF_TIME: 108, // IP電源OKモニタ切り時間
  INSTRUCTION_CHANGE: 109,           // 指示変更
  MACHINE_SELF_MEASURE: 110,         // 装置自己診断
  ALARM_NOTICE: 111,                 // 警報・報知
  END_PREDICTION_POST_INFUSION: 112, // 終了予測(補液完了)
  REMAINING_TIME: 113                // 残り時間
};

/**
 * 表示項目 RO
 * mst_treatment_status_layout.dro_view_items->'key_name'
 */
export const DISP_ITEM_DRO = {
  // 警報・報知
  ALARM_NOTICE: "R99"
};

/**
 * 表示項目 供給
 * mst_treatment_status_layout.dab_view_items->'key_name'
 */
export const DISP_ITEM_DAB = {
  // 警報・報知
  ALARM_NOTICE: "A99"
};

/**
 * 表示項目 溶解
 * mst_treatment_status_layout.dad_view_items->'key_name'
 */
export const DISP_ITEM_DAD = {
  // 警報・報知
  ALARM_NOTICE: "D99"
};

/**
 * 数値としてソートする項目
 */
export const ORDER_NUMBER_FIELDS = [
  TREATMENT_ITEM_CD.DW,
  TREATMENT_ITEM_CD.PRE_WEIGHT_DW,
  TREATMENT_ITEM_CD.TARGET_WEIGHT,
  TREATMENT_ITEM_CD.PRE_WEIGHT_TARGET_WEIGHT,
  TREATMENT_ITEM_CD.STATIC_VENOUS_PRESSURE,
  TREATMENT_ITEM_CD.PRE_WEIGHT,
  TREATMENT_ITEM_CD.PRE_BP_MAX,
  TREATMENT_ITEM_CD.PRE_BP_MIN,
  TREATMENT_ITEM_CD.PRE_BP_AVG,
  TREATMENT_ITEM_CD.PRE_PULSE,
  TREATMENT_ITEM_CD.POST_WEIGHT,
  TREATMENT_ITEM_CD.PRE_POST_WEIGHT_DIFF,
  TREATMENT_ITEM_CD.EXPECTED_REMNANT,
  TREATMENT_ITEM_CD.REMNANT,
  TREATMENT_ITEM_CD.POST_BP_MAX,
  TREATMENT_ITEM_CD.POST_BP_MIN,
  TREATMENT_ITEM_CD.POST_BP_AVG,
  TREATMENT_ITEM_CD.POST_PULSE,
  TREATMENT_ITEM_CD.UF_TARGET,
  TREATMENT_ITEM_CD.IAP_RATIO,
  TREATMENT_ITEM_CD.IHDF_REMNANT,
  TREATMENT_ITEM_CD.ACHIEVEMENT_RATE,
  TREATMENT_ITEM_CD.LAST_POST_WEIGHT,
  TREATMENT_ITEM_CD.INCREASE_AMOUNT,
  TREATMENT_ITEM_CD.INCREASE_RATE,
  TREATMENT_ITEM_CD.BLOOD_FLOW,
  TREATMENT_ITEM_CD.IP_SPEED,
  TREATMENT_ITEM_CD.PROGRESS_RATE,
  TREATMENT_ITEM_CD.OBSERVATION_COUNT,
  TREATMENT_ITEM_CD.CTR,
  TREATMENT_ITEM_CD.PRE_WEIGHT_BAG_TOTAL,
  TREATMENT_ITEM_CD.POST_WEIGHT_BAG_TOTAL,
  TREATMENT_ITEM_CD.UF_CORRECTION_TOTAL,
  TREATMENT_ITEM_CD.RECIRCULATION_RATE,
  TREATMENT_ITEM_CD.UF_LIMIT,
  TREATMENT_ITEM_CD.BLOOD_FLOW_TREATMENT,
  TREATMENT_ITEM_CD.DIALYSATE_FLOW_TREATMENT,
  TREATMENT_ITEM_CD.DIALYSATE_USE_COUNT,
  TREATMENT_ITEM_CD.DIALYSATE_TEMP_TREATMENT,
  TREATMENT_ITEM_CD.INFUSION_VOLUME,
  TREATMENT_ITEM_CD.INFUSION_USE_COUNT,
  TREATMENT_ITEM_CD.INFUSION_TEMP_TREATMENT,
  TREATMENT_ITEM_CD.INFUSION_SPEED_TREATMENT,
  TREATMENT_ITEM_CD.ANTICOAGULANT_ONE_SHOT,
  TREATMENT_ITEM_CD.ANTICOAGULANT_CONTINUOUS_SPEED,
  TREATMENT_ITEM_CD.ANTICOAGULANT_CONTINUOUS_TOTAL,
  TREATMENT_ITEM_CD.IP_ONE_SHOT,
  TREATMENT_ITEM_CD.IP_SPEED_TREATMENT,
  TREATMENT_ITEM_CD.IP_SPEED_MAX,
  TREATMENT_ITEM_CD.IP_POWER_AUTO_OFF_TIME,
  TREATMENT_ITEM_CD.IP_POWER_MONITOR_OK_OFF_TIME
];

/**
 * スタッフ名をシステム共通ソートする項目
 */
export const ORDER_NAME_FIELDS = [
  TREATMENT_ITEM_CD.STAFF1,
  TREATMENT_ITEM_CD.STAFF2,
  TREATMENT_ITEM_CD.PUNCTURE_PERSON1,
  TREATMENT_ITEM_CD.PUNCTURE_PERSON2,
  TREATMENT_ITEM_CD.RETURN_PERSON1,
  TREATMENT_ITEM_CD.RETURN_PERSON2
];

/**
 * 単位を除いた値を数値としてソートする項目
 */
export const ORDER_NUMBER_WITHOUT_UNIT_FIELDS = [
  TREATMENT_ITEM_CD.DIALYSATE_USE_COUNT,
  TREATMENT_ITEM_CD.INFUSION_USE_COUNT,
  TREATMENT_ITEM_CD.ANTICOAGULANT_ONE_SHOT,
  TREATMENT_ITEM_CD.ANTICOAGULANT_CONTINUOUS_SPEED,
  TREATMENT_ITEM_CD.ANTICOAGULANT_CONTINUOUS_TOTAL
];

/**
 * 最高血圧部分（例：110/ 66/ 80 (45) の場合は100でソート）でソートする項目
 */
export const ORDER_MAX_BP_FIELDS = [
  TREATMENT_ITEM_CD.PRE_BP,
  TREATMENT_ITEM_CD.CURRENT_BP,
  TREATMENT_ITEM_CD.POST_BP
];

/**
 * 時刻（hh:mm）としてソートする項目
 */
export const ORDER_TIME_FIELDS = [
  TREATMENT_ITEM_CD.TREATMENT_TIME,
  TREATMENT_ITEM_CD.DELAY_TIME,
  TREATMENT_ITEM_CD.REMAINING_TIME
];

/**
 * 昇順/降順を逆順でソートする項目
 */
export const ORDER_REVERSE_FIELDS = [
  TREATMENT_ITEM_CD.SINGLE_NEEDLE_USE,
  TREATMENT_ITEM_CD.IP_USE_SELECTION,
  TREATMENT_ITEM_CD.AUTO_ONE_SHOT,
  TREATMENT_ITEM_CD.IP_POWER_AUTO_OFF,
  TREATMENT_ITEM_CD.IP_POWER_MONITOR_OK_OFF
];

