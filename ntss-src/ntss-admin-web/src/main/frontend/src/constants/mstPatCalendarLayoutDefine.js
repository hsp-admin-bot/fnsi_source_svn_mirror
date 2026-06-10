/**
 * 患者カレンダーレイアウトマスタの項目定義
 * @summary
 *  category: 大項目
 *  subCategory: 中項目
 *  item: 小項目
 */
export const mstPatCalendarLayoutDefine = [
  {
    categoryNo: 1,
    categoryName: "患者情報",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "患者情報",
        dispGroup: "pat_info",
        subCategoryItem: [
          { itemNo: 1, itemName: "感染症", dataKey: "infect_info" },
          { itemNo: 2, itemName: "インプラント", dataKey: "implant_info" },
          { itemNo: 3, itemName: "既往歴", dataKey: "medical_hst_info" },
          { itemNo: 4, itemName: "入外・転入出", dataKey: "in_out_visit_history_info" }
        ]
      },
      {
        subCategoryNo: 2,
        subCategoryName: "身体情報",
        dispGroup: "physical_info",
        dataKey: "physical_info",
        subCategoryItem: [
          { itemNo: 1, itemName: "身長", itemKey: "height" },
          { itemNo: 2, itemName: "検査タイミング", itemKey: "order_class" },
          { itemNo: 3, itemName: "検査時体重", itemKey: "ctr_weight" },
          { itemNo: 4, itemName: "心横径", itemKey: "breast_dia" },
          { itemNo: 5, itemName: "胸郭横径", itemKey: "chest_dia" },
          { itemNo: 6, itemName: "CTR", itemKey: "ctr" },
          { itemNo: 7, itemName: "DW", itemKey: "dw" },
          { itemNo: 8, itemName: "目標体重変更有無", itemKey: "target_weight" },
          { itemNo: 9, itemName: "前体重許容上限", itemKey: "pre_scale_upper" },
          { itemNo: 10, itemName: "前体重許容下限", itemKey: "pre_scale_lower" }
        ]
      }
    ]
  },
  {
    categoryNo: 2,
    categoryName: "治療情報",
    dispGroup: "treat_plan",
    dataKey: "treat_info",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "治療予定",
        subCategoryItem: [
          { itemNo: 100, itemName: "治療方法", itemKey: "treatmentName" },
          { itemNo: 101, itemName: "クール", itemKey: "kurName" },
          { itemNo: 102, itemName: "治療開始時刻", itemKey: "startDate" },
          { itemNo: 103, itemName: "治療終了時刻", itemKey: "rstEndDate", rstCd: 1 },
          { itemNo: 104, itemName: "ベッド", itemKey: "bedName" },
          { itemNo: 1, itemName: "治療時間", },
          { itemNo: 2, itemName: "VA" },
          { itemNo: -1, itemName: "DW" },
          { itemNo: 3, itemName: "目標体重" },
          { itemNo: 4, itemName: "除水量制限" },
          { itemNo: 5, itemName: "ダイアライザ" },
          { itemNo: 6, itemName: "吸着カラム" },
          { itemNo: 7, itemName: "1次膜" },
          { itemNo: 8, itemName: "2次膜" },
          { itemNo: 105, itemName: "穿刺針" },
          { itemNo: 12, itemName: "シングルニードル使用" },
          { itemNo: 13, itemName: "血液回路" },
          { itemNo: 14, itemName: "血流量" },
          { itemNo: 15, itemName: "透析液" },
          { itemNo: 16, itemName: "透析液流量" },
          { itemNo: 17, itemName: "透析液使用数" },
          { itemNo: 18, itemName: "透析液温度" },
          { itemNo: 19, itemName: "補液" },
          { itemNo: 20, itemName: "補液量" },
          { itemNo: 21, itemName: "補液選択" },
          { itemNo: 22, itemName: "補液使用数" },
          { itemNo: 23, itemName: "補液温度" },
          { itemNo: 24, itemName: "補液速度" },
          { itemNo: 25, itemName: "抗凝固剤" },
          { itemNo: 26, itemName: "抗凝固剤ワンショット量" },
          { itemNo: 27, itemName: "抗凝固剤持続速度" },
          { itemNo: 28, itemName: "抗凝固剤持続総量" },
          { itemNo: 106, itemName: "抗凝固剤総量" },          
          { itemNo: 29, itemName: "IP使用選択" },
          { itemNo: 30, itemName: "IPスタート" },
          { itemNo: 32, itemName: "IP速度" },
          { itemNo: 33, itemName: "IP速度最大値" },
          { itemNo: 34, itemName: "IPワンショットスタート" },
          { itemNo: 31, itemName: "IPワンショット量" },
          { itemNo: 35, itemName: "IP電源自動切り" },
          { itemNo: 36, itemName: "IP電源自動切り時間" },
          { itemNo: 37, itemName: "IP電源OKモニタ切り" },
          { itemNo: 38, itemName: "IP電源OKモニタ切り時間" }
        ]
      },
      {
        subCategoryNo: 2,
        subCategoryName: "投与薬剤",
        subCategoryItem: []
      },
      {
        subCategoryNo: 3,
        subCategoryName: "医療材料",
        subCategoryItem: []
      },
      {
        subCategoryNo: 4,
        subCategoryName: "指示コメント",
        subCategoryItem: []
      },
      {
        subCategoryNo: 5,
        subCategoryName: "実績情報",
        rstCd: 100,
        subCategoryItem: [
          { itemNo: 1, itemName: "入外区分", itemKey: "rstInOutClass", rstCd: 2 },
          { itemNo: 2, itemName: "透析回数", itemKey: "rstDialysisCnt", rstCd: 3 },
          { itemNo: 3, itemName: "治療時間(実績)", itemKey: "rstDialysisTime", rstCd: 4 },
          { itemNo: 4, itemName: "病棟", itemKey: "rstWardName", rstCd: 5 },
          { itemNo: 5, itemName: "診療科", itemKey: "rstCourseName", rstCd: 6 },
          { itemNo: 6, itemName: "穿刺者1", itemKey: "rstPunctureUserInfo:1", rstCd: 7 },
          { itemNo: 7, itemName: "穿刺者2", itemKey: "rstPunctureUserInfo:2", rstCd: 8 },
          { itemNo: 8, itemName: "返血者1", itemKey: "rstReturnUserInfo:1", rstCd: 9 },
          { itemNo: 9, itemName: "返血者2", itemKey: "rstReturnUserInfo:2", rstCd: 10 },
          { itemNo: 10, itemName: "担当者1", itemKey: "rstChargeUserInfo:1", rstCd: 11 },
          { itemNo: 11, itemName: "担当者2", itemKey: "rstChargeUserInfo:2", rstCd: 12 },
          { itemNo: 12, itemName: "前体重", itemKey: "rstWeightInfo:weight_before", rstCd: 13 },
          { itemNo: 13, itemName: "後体重", itemKey: "rstWeightInfo:weight_after", rstCd: 14 },
          { itemNo: 14, itemName: "CTR", itemKey: "rstWeightInfo:ctr", rstCd: 15 },
          { itemNo: 15, itemName: "CTR測定日", itemKey: "rstWeightInfo:ctr_measure_date", rstCd: 16 },
          { itemNo: 16, itemName: "目標除水量", itemKey: "rstWeightInfo:water_removal_target", rstCd: 17 },
          { itemNo: 17, itemName: "実績除水量", itemKey: "rstWeightInfo:water_removal_rst", rstCd: 18 },
          { itemNo: 18, itemName: "実績補液量", itemKey: "rstWeightInfo:add_water_total", rstCd: 19 },
          { itemNo: 19, itemName: "I-HDF引き残し", itemKey: "rstWeightInfo:ihdf_pll", rstCd: 20 },
          { itemNo: 20, itemName: "Kt/V測定値", itemKey: "rstWeightInfo:kt_v_measure", rstCd: 21 },
          { itemNo: 21, itemName: "URR", itemKey: "rstWeightInfo:urr", rstCd: 22 },
          { itemNo: 22, itemName: "再循環率", itemKey: "rstWeightInfo:recrcl_rt:rate", rstCd: 23 },
          { itemNo: 23, itemName: "再循環率測定時血流量", itemKey: "rstWeightInfo:recrcl_rt:bld_vl", rstCd: 24 },
          { itemNo: 24, itemName: "再循環率測定日時", itemKey: "rstWeightInfo:recrcl_rt:datetime", rstCd: 25 },
          { itemNo: 25, itemName: "静的静脈圧", itemKey: "rstWeightInfo:sttc_vns_prssr", rstCd: 26 },
          { itemNo: 26, itemName: "IAP Ratio", itemKey: "rstWeightInfo:iap_rt", rstCd: 27 },
          { itemNo: 27, itemName: "透析前血圧", itemKey: "preBp", rstCd: 28 },
          { itemNo: 28, itemName: "透析後血圧", itemKey: "postBp", rstCd: 29 },
          { itemNo: 29, itemName: "体温", itemKey: "temperature", rstCd: 30 }
        ]
      },  
      {
        subCategoryNo: 11,
        subCategoryName: "バイタル・モニタグラフ①-1　入室～退室",
        dataKey: "vital_monitor_flg_1",
        subCategoryItem: []
      },
      {
        subCategoryNo: 12,
        subCategoryName: "バイタル・モニタグラフ①-2　入室～退室",
        dataKey: "vital_monitor_flg_1",
        subCategoryItem: []
      },
      {
        subCategoryNo: 13,
        subCategoryName: "バイタル・モニタグラフ①-3　入室～退室",
        dataKey: "vital_monitor_flg_1",
        subCategoryItem: []
      },
      {
        subCategoryNo: 21,
        subCategoryName: "バイタル・モニタグラフ②-1　入室～退室",
        dataKey: "vital_monitor_flg_2",
        subCategoryItem: []
      },
      {
        subCategoryNo: 22,
        subCategoryName: "バイタル・モニタグラフ②-2　入室～退室",
        dataKey: "vital_monitor_flg_2",
        subCategoryItem: []
      },
      {
        subCategoryNo: 23,
        subCategoryName: "バイタル・モニタグラフ②-3　入室～退室",
        dataKey: "vital_monitor_flg_2",
        subCategoryItem: []
      },
      {
        subCategoryNo: 31,
        subCategoryName: "バイタル・モニタグラフ③-1　入室～退室",
        dataKey: "vital_monitor_flg_3",
        subCategoryItem: []
      },
      {
        subCategoryNo: 32,
        subCategoryName: "バイタル・モニタグラフ③-2　入室～退室",
        dataKey: "vital_monitor_flg_3",
        subCategoryItem: []
      },
      {
        subCategoryNo: 33,
        subCategoryName: "バイタル・モニタグラフ③-3　入室～退室",
        dataKey: "vital_monitor_flg_3",
        subCategoryItem: []
      },
      {
        subCategoryNo: 41,
        subCategoryName: "バイタル・モニタグラフ④-1　入室～退室",
        dataKey: "vital_monitor_flg_4",
        subCategoryItem: []
      },
      {
        subCategoryNo: 42,
        subCategoryName: "バイタル・モニタグラフ④-2　入室～退室",
        dataKey: "vital_monitor_flg_4",
        subCategoryItem: []
      },
      {
        subCategoryNo: 43,
        subCategoryName: "バイタル・モニタグラフ④-3　入室～退室",
        dataKey: "vital_monitor_flg_4",
        subCategoryItem: []
      },
    ]
  },
  {
    categoryNo: 3,
    categoryName: "検査",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "検査結果",
        dataKey: "exam_result",
        dispGroup: "exam_result",
        subCategoryItem: []
      },
      {
        subCategoryNo: 2,
        subCategoryName: "検査予定",
        dataKey: "exam_request",
        dispGroup: "exam_request",
        subCategoryItem: [
          { itemNo: 1, itemName: "検査セット名" }
        ]
      }
    ]
  },
  {
    categoryNo: 4,
    categoryName: "一般撮影検査",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "一般撮影検査予定",
        dataKey: "rad_request",
        dispGroup: "rad_request",
        subCategoryItem: []
      }
    ]
  },
  {
    categoryNo: 5,
    categoryName: "患者イベント",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "患者イベント",
        dataKey: "pat_event",
        dispGroup: "pat_event",
        subCategoryItem: []
      },
    ]
  },
  {
    categoryNo: 6,
    categoryName: "処方",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "処方",
        dataKey: "prescription",
        dispGroup: "prescription",
        subCategoryItem: []
      },
    ]
  },
  {
    categoryNo: 7,
    categoryName: "施設イベント",
    categoryItem: [
      {
        subCategoryNo: 1,
        subCategoryName: "施設イベント",
        dataKey: "bbs_info",
        dispGroup: "bbs_info",
        subCategoryItem: []
      },
    ]
  }
];

/**
 * カテゴリの定数クラス
 */
export const CATEGORY_NO = {
  // 患者情報
  PAT_CONTENT : 1,
  // 治療情報
  TREATMENT_CONTENT : 2,
  // 検査
  EXAM_CONTENT : 3,
  // 一般撮影検査
  RAD_CONTENT : 4,
  // 患者イベント
  PAT_EVENT_CONTENT : 5,
  // 処方
  PRESCRIPTION_CONTENT : 6,
  // 施設イベント
  BBS_CONTENT : 7
};

/**
 * サブカテゴリの定数クラス
 */
export const SUB_CATEGORY_NO = {
  // 患者情報-患者情報
  PAT_INFO : 1,
  // 治療情報-治療予定
  TREAT_PLAN : 1,
  // 治療情報-投与薬剤
  MEDI_INFO : 2,
  // 治療情報-医療材料
  EQUIP_INFO : 3,
  // 治療情報-指示コメント
  IND_COMMENT : 4,
  // バイタル・モニタグラフ①-1入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_1_1 : 11,
  // バイタル・モニタグラフ①-2入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_1_2 : 12,
  // バイタル・モニタグラフ①-3入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_1_3 : 13,
  // バイタル・モニタグラフ②-1入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_2_1 : 21,
  // バイタル・モニタグラフ②-2入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_2_2 : 22,
  // バイタル・モニタグラフ②-3入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_2_3 : 23,
  // バイタル・モニタグラフ③-1入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_3_1 : 31,
  // バイタル・モニタグラフ③-2入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_3_2 : 32,
  // バイタル・モニタグラフ③-3入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_3_3 : 33,
  // バイタル・モニタグラフ④-1入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_4_1 : 41,
  // バイタル・モニタグラフ④-2入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_4_2 : 42,
  // バイタル・モニタグラフ④-3入室～退室
  VITAL_MONITOR_GRAPH_IN_OUT_4_3 : 43,
};

