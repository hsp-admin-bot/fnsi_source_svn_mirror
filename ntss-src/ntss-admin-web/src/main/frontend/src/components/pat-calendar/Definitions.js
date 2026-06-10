export const DISP_GROUP_MAP = {
  pat_info: "患者情報",
  physical_info: "身体情報",
  treat_plan: "治療予定",
  exam_result: "検査結果",
  exam_request: "検査予定 あり",
  rad_request: "一般撮影検査予定",
  pat_event: "患者イベント",
  prescription: "処方",
  bbs_info: "施設イベント"
};

class LayoutCategory {
  /**
   * @constructor
   * @param {String} title カテゴリ名
   * @param {String} key カテゴリキー
   */
  constructor(title, key) {
    this.title = title;
    this.key = key;
  }
}

/** レイアウトカテゴリ 感染症情報 */
export const LAYOUT_CATEGORY_INFECTINFO = new LayoutCategory(
  "感染症情報",
  "infect_info"
);
/** レイアウトカテゴリ インプラント情報 */
export const LAYOUT_CATEGORY_IMPLANTINFO = new LayoutCategory(
  "インプラント情報",
  "implant_info"
);
/** レイアウトカテゴリ 既往歴情報 */
export const LAYOUT_CATEGORY_MEDIHSTINFO = new LayoutCategory(
  "既往歴情報",
  "medical_hst_info"
);
/** レイアウトカテゴリ 入外・転入出情報 */
export const LAYOUT_CATEGORY_INOUTINFO = new LayoutCategory(
  "入外・転入出情報",
  "in_out_visit_history_info"
);
/** レイアウトカテゴリ 身体情報 */
export const LAYOUT_CATEGORY_PHYSICALINFO = new LayoutCategory(
  "身体情報",
  "physical_info"
);
/** レイアウトカテゴリ 治療情報 */
export const LAYOUT_CATEGORY_TREATINFO = new LayoutCategory(
  "治療情報",
  "treat_info"
);

/** レイアウトカテゴリ バイタルモニタグラフ */
export const LAYOUT_CATEGORY_VITALMONITORFLG_1 = new LayoutCategory(
  "バイタル·モニタグラフ① 入室～退室",
  "vital_monitor_flg_1"
);
export const LAYOUT_CATEGORY_VITALMONITORFLG_2 = new LayoutCategory(
  "バイタル·モニタグラフ② 入室～退室",
  "vital_monitor_flg_2"
);
export const LAYOUT_CATEGORY_VITALMONITORFLG_3 = new LayoutCategory(
  "バイタル·モニタグラフ③ 入室～退室",
  "vital_monitor_flg_3"
);
export const LAYOUT_CATEGORY_VITALMONITORFLG_4 = new LayoutCategory(
  "バイタル·モニタグラフ④ 入室～退室",
  "vital_monitor_flg_4"
);
/** レイアウトカテゴリ 患者イベント */
export const LAYOUT_CATEGORY_PATEVENT = new LayoutCategory(
  "患者イベント",
  "pat_event"
);
/** レイアウトカテゴリ 検査結果 */
export const LAYOUT_CATEGORY_EXAMRESULT = new LayoutCategory(
  "検査結果",
  "exam_result"
);
/** レイアウトカテゴリ 検査予定*/
export const LAYOUT_CATEGORY_EXAMREQUEST = new LayoutCategory(
  "検査予定",
  "exam_request"
);
/** レイアウトカテゴリ 一般撮影検査予定 */
export const LAYOUT_CATEGORY_RADREQUEST = new LayoutCategory(
  "一般撮影検査予定",
  "rad_request"
);
/** レイアウトカテゴリ 処方 */
export const LAYOUT_CATEGORY_PRESCRIPTION = new LayoutCategory(
  "処方",
  "prescription"
);
/** レイアウトカテゴリ 施設イベント */
export const LAYOUT_CATEGORY_BBSINFO = new LayoutCategory(
  "患者イベント",
  "bbs_info"
);


class LayoutItem {
  /**
   * @constructor
   * @param {String} title 項目名
   * @param {String} key 項目キー
   */
  constructor(title, key) {
    this.title = title;
    this.key = key;
  }
}


/** レイアウト項目 身体情報-身長 */
export const LAYOUT_ITEM_PHYSICALINFO_HEIGHT = new LayoutItem(
  "身長", 
  "height");
/** レイアウト項目 身体情報-検査タイミング */
export const LAYOUT_ITEM_PHYSICALINFO_ORDERCLASS = new LayoutItem(
  "検査タイミング",
  "order_class"
);
/** レイアウト項目 身体情報-検査時体重 */
export const LAYOUT_ITEM_PHYSICALINFO_EXAMWEIGHT = new LayoutItem(
  "検査時体重",
  "ctr_weight"
);
/** レイアウト項目 身体情報-心横径 */
export const LAYOUT_ITEM_PHYSICALINFO_BREASTDIAMETER = new LayoutItem(
  "心横径",
  "breast_dia"
);
/** レイアウト項目 身体情報-胸郭横径 */
export const LAYOUT_ITEM_PHYSICALINFO_CHESTDIAMETER = new LayoutItem(
  "胸郭横径",
  "chest_dia"
);
/** レイアウト項目 身体情報-CTR */
export const LAYOUT_ITEM_PHYSICALINFO_CTR = new LayoutItem(
  "CTR", 
  "ctr"
);
/** レイアウト項目 身体情報-DW */
export const LAYOUT_ITEM_PHYSICALINFO_DW = new LayoutItem(
  "DW", 
  "dw"
);
/** レイアウト項目 身体情報-目標体重変更有無 */
export const LAYOUT_ITEM_PHYSICALINFO_TARGETWEIGHT = new LayoutItem(
  "目標体重",
  "target_weight"
);
/** レイアウト項目 身体情報-前体重許容上限 */
export const LAYOUT_ITEM_PHYSICALINFO_WEIGHTUPPER = new LayoutItem(
  "前体重許容上限",
  "pre_scale_upper"
);
/** レイアウト項目 身体情報-前体重許容下限 */
export const LAYOUT_ITEM_PHYSICALINFO_WEIGHTLOWER = new LayoutItem(
  "前体重許容下限",
  "pre_scale_lower"
);


export const LAYOUT_ITEM_INFO_TREATMENT = new LayoutItem(
  "治療方法",
  "treatmentName"
);
/** レイアウト項目 治療情報-クール */
export const LAYOUT_ITEM_INFO_KUR = new LayoutItem(
  "クール", 
  "kurName"
);
/** レイアウト項目 治療情報-ベッド */
export const LAYOUT_ITEM_INFO_BED = new LayoutItem(
  "ベッド", 
  "bedName"
);

/** レイアウト項目 治療情報-治療開始時刻 */
export const LAYOUT_ITEM_INFO_STARTTIME = new LayoutItem(
  "治療開始時刻",
  "startDate"
);

/** レイアウト項目 治療情報(指示)-治療開始時刻 */
export const LAYOUT_ITEM_INDINFO_STARTTIME = new LayoutItem(
  "開始時刻",
  "indTreatStartTime"
);

/** レイアウト項目 治療情報(実績)-治療開始日時 */
export const LAYOUT_ITEM_RSTINFO_STARTDATE = new LayoutItem(
  "治療開始日時",
  "rstStartDate"
);
/** レイアウト項目 治療情報(実績)-治療終了日時 */
export const LAYOUT_ITEM_RSTINFO_ENDDATE = new LayoutItem(
  "治療終了日時",
  "rstEndDate"
);
/** レイアウト項目 治療情報(実績)-入外区分 */
export const LAYOUT_ITEM_RSTINFO_INOUTCLASS = new LayoutItem(
  "入外区分",
  "rstInOutClass"
);
/** レイアウト項目 治療情報(実績)-透析回数 */
export const LAYOUT_ITEM_RSTINFO_DIALYSISCNT = new LayoutItem(
  "透析回数",
  "rstDialysisCnt"
);
/** レイアウト項目 治療情報(実績)-治療時間(実績) */
export const LAYOUT_ITEM_RSTINFO_DIALYSISTIME = new LayoutItem(
  "治療時間", 
  "rstDialysisTime"
);
/** レイアウト項目 治療情報(実績)-病棟 */
export const LAYOUT_ITEM_RSTINFO_WARD = new LayoutItem(
  "病棟", 
  "rstWardName"
);
/** レイアウト項目 治療情報(実績)-診療科 */
export const LAYOUT_ITEM_RSTINFO_COURSE = new LayoutItem(
  "診療科",
  "rstCourseName"
);
/** レイアウト項目 治療情報(実績)-穿刺者1 */
export const LAYOUT_ITEM_RSTINFO_PUNCTUREUSER1 = new LayoutItem(
  "穿刺者1",
  "rstPunctureUserInfo:1"
);
/** レイアウト項目 治療情報(実績)-穿刺者2 */
export const LAYOUT_ITEM_RSTINFO_PUNCTUREUSER2 = new LayoutItem(
  "穿刺者2",
  "rstPunctureUserInfo:2"
);
/** レイアウト項目 治療情報(実績)-返血者1 */
export const LAYOUT_ITEM_RSTINFO_RETURNUSER1 = new LayoutItem(
  "返血者1",
  "rstReturnUserInfo:1"
);
/** レイアウト項目 治療情報(実績)-返血者2 */
export const LAYOUT_ITEM_RSTINFO_RETURNUSER2 = new LayoutItem(
  "返血者2",
  "rstReturnUserInfo:2"
);
/** レイアウト項目 治療情報(実績)-担当者1 */
export const LAYOUT_ITEM_RSTINFO_CHARGEUSER1 = new LayoutItem(
  "担当者1",
  "rstChargeUserInfo:1"
);
/** レイアウト項目 治療情報(実績)-担当者2 */
export const LAYOUT_ITEM_RSTINFO_CHARGEUSER2 = new LayoutItem(
  "担当者2",
  "rstChargeUserInfo:2"
);
/** レイアウト項目 治療情報(実績)-前体重 */
export const LAYOUT_ITEM_RSTINFO_WEIGHTBEFORE = new LayoutItem(
  "前体重",
  "rstWeightInfo:weight_before"
);
/** レイアウト項目 治療情報(実績)-後体重 */
export const LAYOUT_ITEM_RSTINFO_WEIGHTAFTER = new LayoutItem(
  "後体重",
  "rstWeightInfo:weight_after"
);
/** レイアウト項目 治療情報(実績)-CTR */
export const LAYOUT_ITEM_RSTINFO_CTR = new LayoutItem(
  "CTR",
  "rstWeightInfo:ctr"
);
/** レイアウト項目 治療情報(実績)-CTR測定日 */
export const LAYOUT_ITEM_RSTINFO_CTRMEASUREDATE = new LayoutItem(
  "CTR測定日",
  "rstWeightInfo:ctr_measure_date"
);
/** レイアウト項目 治療情報(実績)-目標除水量 */
export const LAYOUT_ITEM_RSTINFO_WATERREMOVALTARGET = new LayoutItem(
  "目標除水量",
  "rstWeightInfo:water_removal_target"
);
/** レイアウト項目 治療情報(実績)-実績除水量 */
export const LAYOUT_ITEM_RSTINFO_WATERREMOVALRST = new LayoutItem(
  "実績除水量",
  "rstWeightInfo:water_removal_rst"
);
/** レイアウト項目 治療情報(実績)-実績補液量 */
export const LAYOUT_ITEM_RSTINFO_ADDWATERTOTAL = new LayoutItem(
  "実績補液量",
  "rstWeightInfo:add_water_total"
);
/** レイアウト項目 治療情報(実績)-I-HDF引き残し */
export const LAYOUT_ITEM_RSTINFO_IHDFPLL = new LayoutItem(
  "I-HDF引き残し",
  "rstWeightInfo:ihdf_pll"
);
/** レイアウト項目 治療情報(実績)-Kt/V測定値 */
export const LAYOUT_ITEM_RSTINFO_KTVMEASURE = new LayoutItem(
  "Kt/V測定値",
  "rstWeightInfo:kt_v_measure"
);
/** レイアウト項目 治療情報(実績)-URR */
export const LAYOUT_ITEM_RSTINFO_URR = new LayoutItem(
  "URR",
  "rstWeightInfo:urr"
);
/** レイアウト項目 治療情報(実績)-再循環率 */
export const LAYOUT_ITEM_RSTINFO_RECRCLRT_RATE = new LayoutItem(
  "再循環率",
  "rstWeightInfo:recrcl_rt:rate"
);
/** レイアウト項目 治療情報(実績)-再循環率測定時血流量 */
export const LAYOUT_ITEM_RSTINFO_RECRCLRT_BLDVL = new LayoutItem(
  "再循環率測定時血流量",
  "rstWeightInfo:recrcl_rt:bld_vl"
);
/** レイアウト項目 治療情報(実績)-再循環率測定日時 */
export const LAYOUT_ITEM_RSTINFO_RECRCLRT_DATETIME = new LayoutItem(
  "再循環率測定日時",
  "rstWeightInfo:recrcl_rt:datetime"
);
/** レイアウト項目 治療情報(実績)-静的静脈圧 */
export const LAYOUT_ITEM_RSTINFO_STTCVNSPRSSR = new LayoutItem(
  "静的静脈圧",
  "rstWeightInfo:sttc_vns_prssr"
);
/** レイアウト項目 治療情報(実績)-IAP Ratio */
export const LAYOUT_ITEM_RSTINFO_IAPRT = new LayoutItem(
  "IAP Ratio",
  "rstWeightInfo:iap_rt"
);

/** レイアウト項目 治療情報(実績)-透析前血圧 */
export const LAYOUT_ITEM_RSTINFO_PREBP = new LayoutItem(
  "前血圧",
  "preBp"
);
/** レイアウト項目 治療情報(実績)-透析後血圧 */
export const LAYOUT_ITEM_RSTINFO_POSTBP = new LayoutItem(
  "後血圧",
  "postBp"
);
/** レイアウト項目 治療情報(実績)-体温 */
export const LAYOUT_ITEM_RSTINFO_TEMPERATURE = new LayoutItem(
  "体温",
  "temperature"
);

/** レイアウト項目 治療条件(指示・実績)-治療時間 */
export const LAYOUT_ITEM_TREATCONDINFO_1 = new LayoutItem("治療時間", "1");
/** レイアウト項目 治療条件(指示・実績)-VA */
export const LAYOUT_ITEM_TREATCONDINFO_2 = new LayoutItem("VA", "2");
/** レイアウト項目 治療情報-DW */
export const LAYOUT_ITEM_TREATCONDINFO_DW = new LayoutItem("DW", "-1");
/** レイアウト項目 治療条件(指示・実績)-目標体重 */
export const LAYOUT_ITEM_TREATCONDINFO_3 = new LayoutItem("目標体重", "3");
/** レイアウト項目 治療条件(指示・実績)-除水量制限 */
export const LAYOUT_ITEM_TREATCONDINFO_4 = new LayoutItem("除水量制限", "4");
/** レイアウト項目 治療条件(指示・実績)-ダイアライザ */
export const LAYOUT_ITEM_TREATCONDINFO_5 = new LayoutItem("ダイアライザ", "5");
/** レイアウト項目 治療条件(指示・実績)-吸着カラム */
export const LAYOUT_ITEM_TREATCONDINFO_6 = new LayoutItem("吸着カラム", "6");
/** レイアウト項目 治療条件(指示・実績)-1次膜 */
export const LAYOUT_ITEM_TREATCONDINFO_7 = new LayoutItem("1次膜", "7");
/** レイアウト項目 治療条件(指示・実績)-2次膜 */
export const LAYOUT_ITEM_TREATCONDINFO_8 = new LayoutItem("2次膜", "8");
/** レイアウト項目 治療条件(指示・実績)-穿刺針 */
export const LAYOUT_ITEM_TREATCONDINFO_105 = new LayoutItem("穿刺針", "105");
/** レイアウト項目 治療条件(指示・実績)-穿刺針(A針) */
export const LAYOUT_ITEM_TREATCONDINFO_9 = new LayoutItem("A針", "9");
/** レイアウト項目 治療条件(指示・実績)-穿刺針(V針) */
export const LAYOUT_ITEM_TREATCONDINFO_10 = new LayoutItem("V針", "10");
/** レイアウト項目 治療条件(指示・実績)-穿刺針(SN) */
export const LAYOUT_ITEM_TREATCONDINFO_11 = new LayoutItem("SN", "11");
/** レイアウト項目 治療条件(指示・実績)-シングルニードル使用 */
export const LAYOUT_ITEM_TREATCONDINFO_12 = new LayoutItem("SN", "12");
/** レイアウト項目 治療条件(指示・実績)-血液回路 */
export const LAYOUT_ITEM_TREATCONDINFO_13 = new LayoutItem("血液回路", "13");
/** レイアウト項目 治療条件(指示・実績)-血流量 */
export const LAYOUT_ITEM_TREATCONDINFO_14 = new LayoutItem("血流量", "14");
/** レイアウト項目 治療条件(指示・実績)-透析液 */
export const LAYOUT_ITEM_TREATCONDINFO_15 = new LayoutItem("透析液", "15");
/** レイアウト項目 治療条件(指示・実績)-透析液流量 */
export const LAYOUT_ITEM_TREATCONDINFO_16 = new LayoutItem("透析液流量", "16");
/** レイアウト項目 治療条件(指示・実績)-透析液使用数 */
export const LAYOUT_ITEM_TREATCONDINFO_17 = new LayoutItem("透析液使用数", "17");
/** レイアウト項目 治療条件(指示・実績)-透析液温度 */
export const LAYOUT_ITEM_TREATCONDINFO_18 = new LayoutItem("透析液温度", "18");
/** レイアウト項目 治療条件(指示・実績)-補液 */
export const LAYOUT_ITEM_TREATCONDINFO_19 = new LayoutItem("補液", "19");
/** レイアウト項目 治療条件(指示・実績)-補液量 */
export const LAYOUT_ITEM_TREATCONDINFO_20 = new LayoutItem("補液量", "20");
/** レイアウト項目 治療条件(指示・実績)-補液選択 */
export const LAYOUT_ITEM_TREATCONDINFO_21 = new LayoutItem("補液選択", "21");
/** レイアウト項目 治療条件(指示・実績)-補液使用数 */
export const LAYOUT_ITEM_TREATCONDINFO_22 = new LayoutItem("補液使用数", "22");
/** レイアウト項目 治療条件(指示・実績)-補液温度 */
export const LAYOUT_ITEM_TREATCONDINFO_23 = new LayoutItem("補液温度", "23");
/** レイアウト項目 治療条件(指示・実績)-補液速度 */
export const LAYOUT_ITEM_TREATCONDINFO_24 = new LayoutItem("補液速度", "24");
/** レイアウト項目 治療条件(指示・実績)-抗凝固剤 */
export const LAYOUT_ITEM_TREATCONDINFO_25 = new LayoutItem("抗凝固剤", "25");
/** レイアウト項目 治療条件(指示・実績)-抗凝固剤ワンショット量 */
export const LAYOUT_ITEM_TREATCONDINFO_26 = new LayoutItem("ﾜﾝｼｮｯﾄ量", "26");
/** レイアウト項目 治療条件(指示・実績)-抗凝固剤持続速度 */
export const LAYOUT_ITEM_TREATCONDINFO_27 = new LayoutItem("持続速度", "27");
/** レイアウト項目 治療条件(指示・実績)-抗凝固剤持続総量 */
export const LAYOUT_ITEM_TREATCONDINFO_28 = new LayoutItem("持続総量", "28");
/** レイアウト項目 治療条件(指示・実績)-抗凝固剤総量 */
export const LAYOUT_ITEM_TREATCONDINFO_106 = new LayoutItem("総量", "106");
/** レイアウト項目 治療条件(指示・実績)-IP使用選択 */
export const LAYOUT_ITEM_TREATCONDINFO_29 = new LayoutItem("IP", "29");
/** レイアウト項目 治療条件(指示・実績)-IPスタート */
export const LAYOUT_ITEM_TREATCONDINFO_30 = new LayoutItem("IPスタート", "30");
/** レイアウト項目 治療条件(指示・実績)-IPワンショット量 */
export const LAYOUT_ITEM_TREATCONDINFO_31 = new LayoutItem("IPﾜﾝｼｮｯﾄ量", "31");
/** レイアウト項目 治療条件(指示・実績)-IP速度 */
export const LAYOUT_ITEM_TREATCONDINFO_32 = new LayoutItem("IP速度", "32");
/** レイアウト項目 治療条件(指示・実績)-IP速度最大値 */
export const LAYOUT_ITEM_TREATCONDINFO_33 = new LayoutItem("IP速度最大", "33");
/** レイアウト項目 治療条件(指示・実績)-IPワンショットスタート */
export const LAYOUT_ITEM_TREATCONDINFO_34 = new LayoutItem("IPﾜﾝｼｮｯﾄ", "34");
/** レイアウト項目 治療条件(指示・実績)-IP電源自動切り */
export const LAYOUT_ITEM_TREATCONDINFO_35 = new LayoutItem("IP電源自動切り", "35");
/** レイアウト項目 治療条件(指示・実績)-IP電源自動切り時間 */
export const LAYOUT_ITEM_TREATCONDINFO_36 = new LayoutItem("IP電源自動切り時間", "36");
/** レイアウト項目 治療条件(指示・実績)-IP電源OKモニタ切り */
export const LAYOUT_ITEM_TREATCONDINFO_37 = new LayoutItem("IP電源OKモニタ切り", "37");
/** レイアウト項目 治療条件(指示・実績)-IP電源OKモニタ切り時間 */
export const LAYOUT_ITEM_TREATCONDINFO_38 = new LayoutItem("IP電源OKモニタ切り時間", "38");


export const VITAL_MONITOR_KEYS = [
  LAYOUT_CATEGORY_VITALMONITORFLG_1.key,
  LAYOUT_CATEGORY_VITALMONITORFLG_2.key,
  LAYOUT_CATEGORY_VITALMONITORFLG_3.key,
  LAYOUT_CATEGORY_VITALMONITORFLG_4.key
];

/**
 * @classdesc 疑似マスタクラス
 */
class PseudoMst {
  /**
   * @constructor
   * @param {String} code コード
   * @param {String} name 名称
   */
  constructor(code, name) {
    this.code = code;
    this.name = name;
  }
}

/** 疑似マスタ：転入出区分 */
export const PSEUDO_MST_MOVEINOUT = [
  new PseudoMst("1", "導入"),
  new PseudoMst("2", "転入"),
  new PseudoMst("3", "転出"),
  new PseudoMst("4", "入院"),
  new PseudoMst("5", "退院"),
  new PseudoMst("6", "外来"),
  new PseudoMst("7", "離脱"),
  new PseudoMst("8", "移植"),
  new PseudoMst("9", "一時転出"),
  new PseudoMst("10", "通院拒否・不明"),
  new PseudoMst("11", "死亡"),
];

/** 疑似マスタ：転帰 */
export const PSEUDO_MST_OUTCOME = [
  new PseudoMst("1", "治療中"),
  new PseudoMst("2", "診断のみ"),
  new PseudoMst("3", "治癒"),
  new PseudoMst("4", "軽快"),
  new PseudoMst("5", "寛解"),
  new PseudoMst("6", "不変"),
  new PseudoMst("7", "増悪"),
  new PseudoMst("8", "中止"),
  new PseudoMst("9", "転医"),
  new PseudoMst("10", "死亡")
];

/** 疑似マスタ 治療条件 使用する/しない */
// TODO: 1: 使用する/しないの値が以下のソース(他にもあるかも、、)ごとに異なるので必ず統一させること
// IndPlanCreate.vue, IndDetailInfo.vue, IndTreatCondXXX.vue
// TODO: 2: 見たところNumberかStringかすら曖昧な模様
export const PSEUDO_MST_INDCOND_USE = [
  new PseudoMst(0, "使用しない"),
  new PseudoMst(1, "使用する")
];

/** 疑似マスタ 治療条件 補液選択 */
// TODO: 上記TODO 1, 2と同様
export const PSEUDO_MST_INDCOND_REPLENISHERSELECT = [
  new PseudoMst(1, "前補液"),
  new PseudoMst(0, "後補液")
];

/** 疑似マスタ 治療条件 IPスタート、IPワンショットスタート */
// TODO: 上記TODO 2と同様
export const PSEUDO_MST_INDCOND_IPSTART = [
  new PseudoMst(0, "手動"),
  new PseudoMst(1, "自動")
];

/** 疑似マスタ 治療条件 IP電源 */
// TODO: 上記TODO 2と同様
export const PSEUDO_MST_INDCOND_IPPOWER = [
  new PseudoMst(0, "切"),
  new PseudoMst(1, "入")
];

/** 疑似マスタ 実績情報 入外区分 */
export const PSEUDO_MST_RSTINFO_INOUT = [
  new PseudoMst(0, "外来"),
  new PseudoMst(1, "入院"),
  new PseudoMst(2, "死亡")
];

/** 疑似マスタ 身体情報 検査タイミング */
export const PSEUDO_MST_ORDER_CLASS = [
  new PseudoMst(1, "透析前"),
  new PseudoMst(2, "透析後"),
  new PseudoMst(3, "その他")
];

/** 疑似マスタ：検査予定 検査区分 */
export const PSEUDO_MST_REG_ORDER_CLASS = [
  new PseudoMst("1", "(前)"),
  new PseudoMst("2", "(後)"),
  new PseudoMst("0", "(他)")
];

/** ルーティング用文字列-患者情報 */
export const ROUTERLINK_PATINFO = "pat-info";
/** ルーティング用文字列-患者経過総合ビューア */
export const ROUTERLINK_PATVIEWER = "pat-viewer";
//add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
/** ルーティング用文字列-検査結果 */
export const ROUTERLINK_EXAMRECORD_DETAIL = "exam-record-detail";
/** ルーティング用文字列-検査予定 */
export const ROUTERLINK_EXAMREQUESTRECORD_DETAIL = "exam-request-detail";
/** ルーティング用文字列-一般撮影検査予定 */
export const ROUTERLINK_RADEQUESTRECORD_DETAIL = "rad-request-detail";
/** ルーティング用文字列-処方 */
export const ROUTERLINK_PRESCRIPTIONRECORD_DETAIL = "pat-prescription";
/** ルーティング用文字列-患者イベント */
export const ROUTERLINK_PATEVENT = "pat-event";
//add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
/** ルーティング用文字列-治療記録 */
export const ROUTERLINK_TREATMENTRECORD = "treatment-record";
/** ルーティング用文字列-掲示板 */
export const ROUTERLINK_BBSINFO = "bbs-info";
/** ルーティング用文字列-施設カレンダー */
export const ROUTERLINK_FACILITY_CALENDAR = "facility-calendar";

