import _ from "underscore";
import moment from "moment";
import { formatDatetime } from "@/functions/common/CommonFunctions.js";

/**
 * 透析条件項目番号
 */
export const DIAL_COND_ID = {
  // 治療時間
  DIALYSIS_TIME: "1",
  // VA
  VA: "2",
  // 目標体重
  WEIGHT: "3",
  // 除水量制限
  OFFWATER: "4",
  // ダイアライザ
  DIALYEZER: "5",
  // 吸着カラム
  ADSORPTIONCOLUMN: "6",
  // 1次膜
  FILM1: "7",
  // 2次膜
  FILM2: "8",
  // 穿刺針(A針)
  NEEDLE_A: "9",
  // 穿刺針(V針)
  NEEDLE_V: "10",
  // 穿刺針(SN)
  NEEDLE_SN: "11",
  // シングルニードル使用
  SINGLENEEDLE: "12",
  // 血液回路
  BLOODCIRCUIT: "13",
  // 血流量
  BLOODFLOW: "14",
  // 透析液
  DIALYSISFLUID: "15",
  // 透析液流量
  DIALYSISFLUID_FLOW: "16",
  // 透析液使用数
  DIALYSISFLUID_AMOUNT: "17",
  // 透析液温度
  DIALYSISFLUID_TEMPERATURE: "18",
  // 補液
  REPLENISHER: "19",
  // 補液量
  REPLENISHER_AMOUNT: "20",
  // 補液選択
  REPLENISHER_SELECT: "21",
  // 補液使用数
  REPLENISHER_NUM: "22",
  // 補液温度
  REPLENISHER_TEMPERATURE: "23",
  // 補液速度
  REPLENISHER_SPEED: "24",
  // 抗凝固剤
  ANTICOAGULANT: "25",
  // 抗凝固剤ワンショット量
  ANTICOAGULANT_ONESHOT: "26",
  // 抗凝固剤持続速度
  ANTICOAGULANT_SPEED: "27",
  // 抗凝固剤持総総量
  ANTICOAGULANT_AMOUNT: "28",
  // IP使用選択
  IP_USE: "29",
  // IPスタート
  IP_START: "30",
  // IPワンショット量
  IP_ONESHOT: "31",
  // IP速度
  IP_SPEED: "32",
  // IP速度最大値
  IP_SPEED_MAX: "33",
  // IPワンショットスタート
  AUTOONESHOT: "34",
  // IP電源自動切り
  IP_AUTOOFF: "35",
  // IP電源自動切り時間
  IP_AUTOOFF_TIME: "36",
  // IP電源OKモニタ切り
  IP_MONITOROFF: "37",
  // IP電源OKモニタ切り時間
  IP_MONITOROFF_TIME: "38",
  // 治療方法マスタ 再依赖 DWを追加する 孔 start
  // DW
  DW: "39"
  // 治療方法マスタ 再依赖 DWを追加する 孔 end
};

/**
 * 透析条件選択形式
 */
export const DIAL_COND_TYPE = {
  // リスト選択
  LIST_SELECT: 1,
  // 値範囲
  RANGE_VALUE: 2,
  // ラジオボタン
  RADIO: 3,
  // 時間
  TIME: 4
};

class DiaysisConditionItem {
  constructor(id, name, selectorType) {
    this.id = id;
    this.name = name;
    this.selectorType = selectorType;
  }
}

/**
 * 透析条件項目
 */
export const DIAL_COND_ITEMS = [
  new DiaysisConditionItem(
    DIAL_COND_ID.DIALYSIS_TIME,
    "透析時間",
    DIAL_COND_TYPE.TIME
  ),
  new DiaysisConditionItem(DIAL_COND_ID.VA, "VA", DIAL_COND_TYPE.LIST_SELECT),
  // add FutreNetWeb+SI課題管理No5148対応 趙 start
  new DiaysisConditionItem(
    DIAL_COND_ID.DW,
    "DW",
    DIAL_COND_TYPE.RANGE_VALUE
  ) ,
  // add FutreNetWeb+SI課題管理No5148対応 趙 end
  new DiaysisConditionItem(
    DIAL_COND_ID.WEIGHT,
    "目標体重",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.OFFWATER,
    "除水量制限",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.DIALYEZER,
    "ダイアライザ",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.ADSORPTIONCOLUMN,
    "吸着カラム",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.FILM1,
    "1次膜",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.FILM2,
    "2次膜",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.NEEDLE_A,
    "穿刺針(A針)",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.NEEDLE_V,
    "穿刺針(V針)",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.NEEDLE_SN,
    "穿刺針(SN)",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.SINGLENEEDLE,
    "シングルニードル使用",
    DIAL_COND_TYPE.RADIO
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.BLOODCIRCUIT,
    "血液回路",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.BLOODFLOW,
    "血流量",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.DIALYSISFLUID,
    "透析液",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.DIALYSISFLUID_FLOW,
    "透析液流量",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.DIALYSISFLUID_AMOUNT,
    "透析液使用数",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.DIALYSISFLUID_TEMPERATURE,
    "透析液温度",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.REPLENISHER,
    "補液",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.REPLENISHER_AMOUNT,
    "補液量",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.REPLENISHER_SELECT,
    "補液選択",
    DIAL_COND_TYPE.RADIO
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.REPLENISHER_NUM,
    "補液使用数",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.REPLENISHER_TEMPERATURE,
    "補液温度",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.REPLENISHER_SPEED,
    "補液速度",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.ANTICOAGULANT,
    "抗凝固剤",
    DIAL_COND_TYPE.LIST_SELECT
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.ANTICOAGULANT_ONESHOT,
    "抗凝固剤ワンショット量",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.ANTICOAGULANT_SPEED,
    "抗凝固剤持続速度",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.ANTICOAGULANT_AMOUNT,
    "抗凝固剤持続総量",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_USE,
    "IP使用選択",
    DIAL_COND_TYPE.RADIO
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_START,
    "IPスタート",
    DIAL_COND_TYPE.RADIO
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_SPEED,
    "IP速度",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_SPEED_MAX,
    "IP速度最大値",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.AUTOONESHOT,
    "IPワンショットスタート",
    DIAL_COND_TYPE.RADIO
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_ONESHOT,
    "IPワンショット量",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_AUTOOFF,
    "IP電源自動切り",
    DIAL_COND_TYPE.RADIO
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_AUTOOFF_TIME,
    "IP電源自動切り時間",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_MONITOROFF,
    "IP電源OKモニタ切り",
    DIAL_COND_TYPE.RADIO
  ),
  new DiaysisConditionItem(
    DIAL_COND_ID.IP_MONITOROFF_TIME,
    "IP電源OKモニタ切り時間",
    DIAL_COND_TYPE.RANGE_VALUE
  ),
];

/**
 * 透析条件値範囲選択の比較方式
 */
export const COMPARISON_TYPE = {
  EQUALITY: '1',
  INEQUALITY: '2'
};

/**
 * 透析条件値範囲選択の不等号記号
 */
export const INEQUALITY_SIGN = {
  LESS: 1,
  LESS_OR_EQUAL: 2
};

class RadioDefinition {
  constructor(value, label) {
    this.value = value;
    this.label = label;
  }
}

/**
 * 透析条件選択形式がラジオボタンの項目の定義
 */
export const DIAL_COND_RADIO_DEFINITION = {
  [DIAL_COND_ID.IP_USE]: {
    1: new RadioDefinition(1, "使用する"),
    2: new RadioDefinition(0, "使用しない")
  },
  [DIAL_COND_ID.REPLENISHER_SELECT]: {
    1: new RadioDefinition(1, "前補液"),
    2: new RadioDefinition(0, "後補液")
  },

  [DIAL_COND_ID.SINGLENEEDLE]: {
    1: new RadioDefinition(1, "有り"),
    2: new RadioDefinition(0, "無し")
  },

  [DIAL_COND_ID.IP_START]: {
    1: new RadioDefinition(1, "自動"),
    2: new RadioDefinition(0, "手動")
  },

  [DIAL_COND_ID.AUTOONESHOT]: {
    1: new RadioDefinition(1, "自動"),
    2: new RadioDefinition(0, "手動")
  },

  [DIAL_COND_ID.IP_AUTOOFF]: {
    1: new RadioDefinition(1, "入"),
    2: new RadioDefinition(0, "切")
  },

  [DIAL_COND_ID.IP_MONITOROFF]: {
    1: new RadioDefinition(1, "入"),
    2: new RadioDefinition(0, "切")
  }
};

/**
 * 透析条件薬剤分類区分(mst_medicine_class.class_type)
 */
export const MEDICINE_TYPE = {
  // 抗凝固剤
  ANTICOAGULANT: 1,
  // 透析液
  DIALYSISFLUID: 2,
  // 補液
  REPLENISHER: 3
};

/**
 * 透析条件医材分類区分(mst_equipment_class.class_type)
 */
export const EQUIPMENT_TYPE = {
  // 血流回路
  BLOODCIRCUIT: 1,
  // 穿刺針(SN以外)
  NEEDLE_NOT_SN: 2,
  // 穿刺針(SN)
  NEEDLE_SN: 3,
  // 吸着カラム
  ADSORPTIONCOLUMN: 4,
  // 吸着器
  ADSORBER: 5,
  // 分離器
  SEPARATOR: 6
};

class DiaysisCondition {
  constructor(conditionId, selectorType) {
    this.conditionId = conditionId;
    this.selectorType = selectorType;
  }
}

export class DiaysisConditionListSelect extends DiaysisCondition {
  constructor(conditionId, selectorType, selectedItemList = []) {
    super(conditionId, selectorType);
    this.selectedItemList = selectedItemList;
  }
}

export class DiaysisConditionRangeValue extends DiaysisCondition {
  constructor(
    conditionId,
    selectorType,
    value1String = "",
    value2String = "",
    comparisonType = COMPARISON_TYPE.INEQUALITY,
    inequalitySign1 = INEQUALITY_SIGN.LESS_OR_EQUAL,
    inequalitySign2 = INEQUALITY_SIGN.LESS_OR_EQUAL
  ) {
    super(conditionId, selectorType);
    this.value1String = value1String;
    this.value2String = value2String;
    this.comparisonType = comparisonType;
    this.inequalitySign1 = inequalitySign1;
    this.inequalitySign2 = inequalitySign2;
  }

  get value1Num() {
    if (this.value1String === "") {
      return null;
    }
    const num = +this.value1String;
    return Number.isNaN(num) ? null : num;
  }

  get value2Num() {
    if (this.value2String === "") {
      return null;
    }
    const num = +this.value2String;
    return Number.isNaN(num) ? null : num;
  }
}

export class DiaysisConditionRadio extends DiaysisCondition {
  constructor(conditionId, selectorType, value = null) {
    super(conditionId, selectorType);
    this.value = value;
  }
}

export class DiaysisConditionTime extends DiaysisCondition {
  constructor(conditionId, selectorType, lowerTime = "", upperTime = "") {
    super(conditionId, selectorType);
    this.lowerTime = lowerTime;
    this.upperTime = upperTime;
  }
  get lowerMinutes() {
    if (this.lowerTime === "") {
      return null;
    }
    const [hours, minutes] = this.lowerTime.split(":").map(Number);
    return hours * 60 + minutes;
  }

  get upperMinutes() {
    if (this.upperTime === "") {
      return null;
    }
    const [hours, minutes] = this.upperTime.split(":").map(Number);
    return hours * 60 + minutes;
  }
}

export class SearchQuery {
  constructor(queryObj = null) {
    if (queryObj === null) {
      // クエリオブジェクトを新規作成
      this.radPattern_exam_pattern_start_date="";
      this.radPattern_exam_pattern_end_date="";
      this.exam_pattern_start_date="";
      this.exam_pattern_end_date="";
      this.insurance_check_date="";
      this.radPattern_exam_week=[];
      this.radPattern_exam_pattern=null;
      this.exam_pattern=null;
      this.reg_order_class="";
      this.exam_week = [];
      this.dialysis_underlying_disease_List=[];
      this.primary_disease_name=null;
      this.primary_disease_cd=null;
      this.hospPatId = "";
      this.patName = "";
      this.nameInitialList = [];
      this.patSex = [];
      this.ageLower = null;
      this.ageUpper = null;
      this.bloodTypeAboList = [];
      this.bloodTypeRhList = [];
      this.bloodTypeSerovarList = [];
      this.isBloodSugerExam = "";
      this.isImplant = "";
      this.inOutClassList = [];
      this.inOutStateList = [];
      this.dialHstLower = { year: "", month: "" };
      this.dialHstUpper = { year: "", month: "" };
      this.staffCdDoctor = null;
      this.staffNameDoctor = "";
      this.staffCdCharge = null;
      this.staffNameCharge = "";
      this.staffCdPucture = null;
      this.staffNamePuncture = "";
      this.tabooCd = null;
      this.tabooContent = "";
      this.allergyCd = null;
      this.allergyContent = "";
      /* add 患者情報追加 馬宇婷 start */
      this.mainCourseCd = null;
      this.courseName = "";
      this.dialysisCourseCd = null;
      this.dialCourseName = "";
      this.wardCd = null;
      this.dialysisCountLower = null;
      this.dialysisCountUpper = null;
      this.purificationCountLower = null;
      this.purificationCountUpper = null;
      this.wardName = "";
      /* add 患者情報追加 馬宇婷 end */
      //add no338 連絡先情報 start 張岩
      // 連絡先情報．姓
      this.lastName = "";
      // 連絡先情報．名
      this.firstName = "";
      // 連絡先情報．セイ
      this.lastNameKana = "";
      // 連絡先情報．メイ
      this.firstNameKana = "";
      // 連絡先情報．続柄コード
      this.relationCd = null;
      // 連絡先情報．続柄名
      this.relationName = "";
      // 業者連絡先情報.会社名
      this.companyName = "";
      // 業者連絡先情報.担当者姓
      this.workerLastName = "";
      // 業者連絡先情報.担当者名
      this.workerFirstName = "";
      //add no338 連絡先情報 end 張岩
      this.isInfect = "";
      this.isDiabetes = "";
      this.outComeList = [];
      this.diseaseCd = null;
      this.diseaseName = "";
      this.dialysisStartDate = "";
      this.dialysisEndDate = "";
      this.dialysisDateArgs = "";
      this.kurCdList = [];
      this.bedCdList = [];
      this.bedGroupCdList = [];
      // add FutreNetWeb+SI課題管理No4770対応 趙 start
      this.examSetCdList = [];
      // add FutreNetWeb+SI課題管理No4770対応 趙 end
      this.treatDayOfWeekList = [];
      this.treatmentCdList = [];
      this.dialyzerCdList = [];
      //add 患者透析困難情報を検索する 劉全航 start
      this.isDialDiff = "";
      //add 患者透析困難情報を検索する 劉全航 end
      //add 重症度検索機能追加 劉全航 start
      this.severityCd = null;
      this.severityName = null;
      //add 重症度検索機能追加 劉全航 end
      //add 搬送区分検索機能追加 劉全航 start
      this.transportCd = null;
      this.transportName = null;
      //add 搬送区分検索機能追加 劉全航 end
      //add 車いす利用検索機能追加 劉全航 start
      this.isWheelChair = "";
      //add 車いす利用検索機能追加 劉全航 end
      //add 患者イベントのカテゴ検索追加 劉全航 start
      this.categoryList = [];
      //add 患者イベントのカテゴ検索追加 劉全航 end
      //add 患者イベントの開始日検索追加 劉全航 start
      this.eventStartDate = "";
      //add 患者イベントの開始日検索追加 劉全航 end
      //add 患者イベントの終了日検索追加 劉全航 start
      this.eventEndDate = "";
      //add 患者イベントの終了日検索追加 劉全航 end
      //add NO338 加算情報検索 劉全航 start
      this.additionCd = null;
      this.additionName = null;
      this.additionSearchCondition = "true";
      //add NO338 加算情報検索 劉全航 end
      //add no338 一般撮影検査予定項目追加 時刻 劉全航 start
      this.patRadPatternRegRadDate = "";
      this.conditionIsEmpty = true;
      //add no338 一般撮影検査予定項目追加 時刻 劉全航 end
      // 指示コメント条件
      // ※要素1は検索区分(2: 部分一致、3: 前方一致)、残りは検索文字列
      // ※検索区分はストアドプロシージャ(json_array_contains_value)の定義に依る
      this.indCommentList = ["3", "", "", ""];
      this.dialysisConditionList = {
        1: null,
        2: null,
        3: null,
        4: null,
        5: null
      };
      this.selectingDialCondId = {
        1: null,
        2: null,
        3: null,
        4: null,
        5: null
      };
      this.medicationList = {
        1: [],
        2: [],
        3: [],
        4: [],
        5: []
      };
      this.medicationSelectorClass = {
        1: null,
        2: null,
        3: null,
        4: null,
        5: null
      };
      this.equipmentList = {
        1: [],
        2: [],
        3: [],
        4: [],
        5: []
      };
      this.equipmentSelectorClass = {
        1: null,
        2: null,
        3: null,
        4: null,
        5: null
      };
      this.patGroups = [];
      this.patGroupsMethod = "1";
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      this.simpleSearchTreatDate = "";
      this.simpleSearchRstDialysisState = [];
      this.simpleSearchTreatDayOfWeekList = [];
      this.simpleSearchKurCdList = [];
      this.simpleSearchBedGroupCd = null;
      this.simpleSearchPatGroupSearch = null;
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    } else {
      // プレーンオブジェクトからクエリオブジェクトを作成
      // mod FNSI- 吉 start
      // this.radPattern_exam_pattern_start_date=queryObj.this.radPattern_exam_pattern_start_date;
      // this.radPattern_exam_pattern_end_date=queryObj.this.radPattern_exam_pattern_end_date;
      this.radPattern_exam_pattern_start_date=queryObj.radPattern_exam_pattern_start_date;
      this.radPattern_exam_pattern_end_date=queryObj.radPattern_exam_pattern_end_date;
      // mod FNSI-  吉 end
      this.exam_pattern_start_date=queryObj.exam_pattern_start_date;
      this.exam_pattern_end_date=queryObj.exam_pattern_end_date;
      this.insurance_check_date=queryObj.insurance_check_date;
      this.radPattern_exam_week=queryObj.radPattern_exam_week;
      this.radPattern_exam_pattern=queryObj.radPattern_exam_pattern;
      this.exam_pattern = queryObj.exam_pattern;
      this.reg_order_class = queryObj.reg_order_class;
      this.exam_week =queryObj.exam_week;
      this.dialysis_underlying_disease_List = queryObj.dialysis_underlying_disease_List
      this.primary_disease_name=queryObj.primary_disease_name;
      this.primary_disease_cd=queryObj.primary_disease_cd;
      this.hospPatId = queryObj.hospPatId;
      this.patName = queryObj.patName;
      this.nameInitialList = queryObj.nameInitialList;
      this.patSex = queryObj.patSex;
      this.ageLower = queryObj.ageLower;
      this.ageUpper = queryObj.ageUpper;
      this.bloodTypeAboList = queryObj.bloodTypeAboList;
      this.bloodTypeRhList = queryObj.bloodTypeRhList;
      this.bloodTypeSerovarList = queryObj.bloodTypeSerovarList;
      this.isBloodSugerExam = queryObj.isBloodSugerExam;
      this.isImplant = queryObj.isImplant;
      this.inOutClassList = queryObj.inOutClassList;
      this.inOutStateList = queryObj.inOutStateList;
      this.dialHstLower = queryObj.dialHstLower;
      this.dialHstUpper = queryObj.dialHstUpper;
      this.staffCdDoctor = queryObj.staffCdDoctor;
      this.staffNameDoctor = queryObj.staffNameDoctor;
      this.staffCdCharge = queryObj.staffCdCharge;
      this.staffNameCharge = queryObj.staffNameCharge;
      this.staffCdPucture = queryObj.staffCdPucture;
      this.staffNamePuncture = queryObj.staffNamePuncture;
      this.tabooCd = queryObj.tabooCd;
      this.tabooContent = queryObj.tabooContent;
      this.allergyCd = queryObj.allergyCd;
      this.allergyContent = queryObj.allergyContent;
      /* add 患者情報追加 馬宇婷 start */
      this.mainCourseCd = queryObj.mainCourseCd;
      this.courseName = queryObj.courseName;
      this.dialysisCourseCd = queryObj.dialysisCourseCd;
      this.dialCourseName = queryObj.dialCourseName;
      this.wardCd = queryObj.wardCd;
      this.wardName = queryObj.wardName;
      this.dialysisCountLower = queryObj.dialysisCountLower;
      this.dialysisCountUpper = queryObj.dialysisCountUpper;
      this.purificationCountLower = queryObj.purificationCountLower;
      this.purificationCountUpper = queryObj.purificationCountUpper;
      /* add 患者情報追加 馬宇婷 end */
      //add no338 連絡先情報 start 張岩
      // 連絡先情報．姓
      this.lastName = queryObj.lastName;
      // 連絡先情報．名
      this.firstName = queryObj.firstName;
      // 連絡先情報．セイ
      this.lastNameKana = queryObj.lastNameKana;
      // 連絡先情報．メイ
      this.firstNameKana = queryObj.firstNameKana;
      // 連絡先情報．続柄コード
      this.relationCd = queryObj.relationCd;
      // 連絡先情報．続柄名
      this.relationName = queryObj.relationName;
      // 業者連絡先情報.会社名
      this.companyName = queryObj.companyName;
      // 業者連絡先情報.担当者姓
      this.workerLastName = queryObj.workerLastName;
      // 業者連絡先情報.担当者名
      this.workerFirstName= queryObj.workerFirstName;
      //add no338 連絡先情報 end 張岩
      this.isInfect = queryObj.isInfect;
      this.isDiabetes = queryObj.isDiabetes;
      this.outComeList = queryObj.outComeList;
      this.diseaseCd = queryObj.diseaseCd;
      this.diseaseName = queryObj.diseaseName;
      this.dialysisDateArgs = queryObj.dialysisDateArgs;
      this.dialysisStartDate = this.dialysisDate(
        queryObj.dialysisStartDate,
        queryObj.dialysisEndDate
      ).start;
      this.dialysisEndDate = this.dialysisDate(
        queryObj.dialysisStartDate,
        queryObj.dialysisEndDate
      ).end;
      this.kurCdList = queryObj.kurCdList;
      this.bedCdList = queryObj.bedCdList;
      this.bedGroupCdList = queryObj.bedGroupCdList;
      // add FutreNetWeb+SI課題管理No4770対応 趙 start
      this.examSetCdList = queryObj.examSetCdList;
      // add FutreNetWeb+SI課題管理No4770対応 趙 end
      this.treatDayOfWeekList = queryObj.treatDayOfWeekList;
      this.indCommentList = queryObj.indCommentList;
      this.dialysisConditionList = queryObj.dialysisConditionList;
      this.treatmentCdList = queryObj.treatmentCdList;
      this.dialyzerCdList = queryObj.dialyzerCdList;
      //add 患者透析困難情報を検索する 劉全航 start
      this.isDialDiff = queryObj.isDialDiff;
      //add 患者透析困難情報を検索する 劉全航 end
      //add 重症度検索追加 劉全航 start
      this.severityCd = queryObj.severityCd;
      this.severityName = queryObj.severityName;
      //add 重症度検索追加 劉全航 end
      //add 搬送区分検索追加 劉全航 start
      this.transportCd = queryObj.transportCd;
      this.transportName = queryObj.transportName;
      //add 搬送区分検索追加 劉全航 end
      //add 車いす利用検索追加 劉全航 start
      this.isWheelChair = queryObj.isWheelChair;
      //add 車いす利用検索追加 劉全航 end
      //add 患者イベントのカテゴ検索追加 劉全航 start
      this.categoryList = queryObj.categoryList;
      //add 患者イベントのカテゴ検索追加 劉全航 end
      //add 患者イベントの開始日検索追加 劉全航 start
      this.eventStartDate = queryObj.eventStartDate;
      //add 患者イベントの開始日検索追加 劉全航 end
      //add 患者イベントの終了日検索追加 劉全航 start
      this.eventEndDate = queryObj.eventEndDate;
      //add 患者イベントの終了日検索追加 劉全航 end
      //add NO338 加算情報検索 劉全航 start
      this.additionCd = queryObj.additionCd;
      this.additionName = queryObj.additionName;
      this.additionSearchCondition = queryObj.additionSearchCondition;
      //add NO338 加算情報検索 劉全航 end
      //add no338 一般撮影検査予定項目追加 時刻 劉全航 start
      this.patRadPatternRegRadDate = queryObj.patRadPatternRegRadDate;
      //add no338 一般撮影検査予定項目追加 時刻 劉全航 end

      for (let i = 1; i <= 5; i++) {
        const cond = this.dialysisConditionList[i];
        if (cond === null) {
          // 透析条件未指定
          continue;
        }

        // 指定されている場合は選択形式に応じたクラスでインスタンス化
        let tmpCondObj = null;
        if (cond.selectorType === DIAL_COND_TYPE.LIST_SELECT) {
          tmpCondObj = new DiaysisConditionListSelect(
            cond.conditionId,
            cond.selectorType,
            cond.selectedItemList
          );
        } else if (cond.selectorType === DIAL_COND_TYPE.RANGE_VALUE) {
          tmpCondObj = new DiaysisConditionRangeValue(
            cond.conditionId,
            cond.selectorType,
            cond.value1String,
            cond.value2String,
            cond.comparisonType,
            cond.inequalitySign1,
            cond.inequalitySign2
          );
        } else if (cond.selectorType === DIAL_COND_TYPE.RADIO) {
          tmpCondObj = new DiaysisConditionRadio(
            cond.conditionId,
            cond.selectorType,
            +cond.value
          );
        } else if (cond.selectorType === DIAL_COND_TYPE.TIME) {
          tmpCondObj = new DiaysisConditionTime(
            cond.conditionId,
            cond.selectorType,
            cond.lowerTime,
            cond.upperTime
          );
        }
        this.dialysisConditionList[i] = tmpCondObj;
      }

      this.selectingDialCondId = queryObj.selectingDialCondId;
      this.medicationList = queryObj.medicationList;
      this.medicationSelectorClass = queryObj.medicationSelectorClass;
      this.equipmentList = queryObj.equipmentList;
      this.equipmentSelectorClass = queryObj.equipmentSelectorClass;
      this.patGroups = queryObj.patGroups;
      this.patGroupsMethod = queryObj.patGroupsMethod;
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      this.simpleSearchTreatDate = queryObj.simpleSearchTreatDate;
      this.simpleSearchRstDialysisState = queryObj.simpleSearchRstDialysisState;
      this.simpleSearchTreatDayOfWeekList = queryObj.simpleSearchTreatDayOfWeekList;
      this.simpleSearchKurCdList = queryObj.simpleSearchKurCdList;
      this.simpleSearchBedGroupCd = queryObj.simpleSearchBedGroupCd;
      this.simpleSearchPatGroupSearch = queryObj.simpleSearchPatGroupSearch;
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    }
  }

  createCondition(facilityCdList) {
    let pat_personal_main = null;
    // 患者詳細検索ページデバッグ 劉全航 start
    if (
      this.hospPatId !== "" ||
      this.patName !== "" ||
      !_.isEmpty(this.nameInitialList) ||
      !_.isEmpty(this.patSex) ||
      this.ageLower !== null ||
      this.ageUpper !== null ||
      !_.isEmpty(this.bloodTypeAboList) ||
      !_.isEmpty(this.bloodTypeRhList) ||
      !_.isEmpty(this.bloodTypeSerovarList) ||
      !_.isEmpty(this.inOutClassList) ||
      //add no338 連絡先情報 start 張岩
      // 連絡先情報．姓
      this.lastName !== "" ||
      // 連絡先情報．名
      this.firstName !== "" ||
      // 連絡先情報．セイ
      this.lastNameKana !== "" ||
      // 連絡先情報．メイ
      this.firstNameKana !== "" ||
      // 連絡先情報．続柄コード
      this.relationCd !== null ||
      // 連絡先情報．続柄名
      this.relationName !== "" ||
      // 業者連絡先情報.会社名
      this.companyName !== "" ||
      // 業者連絡先情報.担当者姓
      this.workerLastName !== "" ||
      // 業者連絡先情報.担当者名
      this.workerFirstName !== "" ||
      //add no338 連絡先情報 end 張岩
      //add 患者透析困難情報を検索する 劉全航 start
      this.isDialDiff !== "" ||
      //add 患者透析困難情報を検索する 劉全航 end
      //add 重症度検索機能追加 劉全航 start
      this.severityCd !== null ||
      this.severityName !== null ||
      //add 重症度検索機能追加 劉全航 end
      //add 搬送区分検索機能追加 劉全航 start
      this.transportCd !== null ||
      //add 搬送区分検索機能追加 劉全航 end
      this.transportName !== null
      // 患者詳細検索ページデバッグ 劉全航 end
    ) {
      let [ageLowerTmp, ageUpperTmp] = [this.ageLower, this.ageUpper];
      if (
        ageLowerTmp !== null &&
        ageUpperTmp !== null &&
        ageLowerTmp > ageUpperTmp
      ) {
        // 年齢上下限逆転
        [ageLowerTmp, ageUpperTmp] = [ageUpperTmp, ageLowerTmp];
      }

      let bloodTypeSerovarListCustom = [];
      const bloodTypeSerovarTypeAAndBRange = [0, 1, 2, 3, 4, 5, 6, 7, 8];
      // 血液型(ABO)を指定する、血液型(亜型)を指定する場合
      if (
        !_.isEmpty(this.bloodTypeAboList) &&
        !_.isEmpty(this.bloodTypeSerovarList)
      ) {
        this.bloodTypeAboList.forEach((bloodTypeAbo) => {
          this.bloodTypeSerovarList.forEach((bloodTypeSerovar) => {
            const bloodTypeSerovarUnit = bloodTypeSerovar % 10;
            //mod 患者詳細検索no2障害  吉 start
            // switch(Number(bloodTypeAbo)) {
            switch (Number(bloodTypeAbo)) {
              //mod 患者詳細検索no2障害  吉 end
              case 0: // 不明の場合
              case 1: // A型の場合
              case 2: // B型の場合
                if (!bloodTypeSerovarListCustom.includes(bloodTypeSerovar)) {
                  bloodTypeSerovarListCustom.push(bloodTypeSerovar);
                }
                break;
              case 3: // O型の場合
                //mod 患者詳細検索no2障害  吉 start
                // switch(bloodTypeSerovar) {
                switch (Number(bloodTypeSerovar)) {
                  //mod 患者詳細検索no2障害  吉 end
                  case 16:
                    bloodTypeSerovarListCustom.push(35);
                    break;
                  case 26:
                    bloodTypeSerovarListCustom.push(36);
                    break;
                  default:
                    if (
                      !bloodTypeSerovarListCustom.includes(bloodTypeSerovar)
                    ) {
                      bloodTypeSerovarListCustom.push(bloodTypeSerovar);
                    }
                    break;
                }
                break;
              case 4: // AB型の場合
                //mod 患者詳細検索no2障害  吉 start
                // switch(bloodTypeSerovar) {
                switch (Number(bloodTypeSerovar)) {
                  //mod 患者詳細検索no2障害  吉 end
                  case 0:
                    bloodTypeSerovarTypeAAndBRange.forEach((item) => {
                      if (item === 0) {
                        bloodTypeSerovarListCustom.push(400);
                      } else {
                        const valueABloodType =
                          400 + bloodTypeSerovarUnit * 10 + item;
                        const valueBBloodType =
                          400 + item * 10 + bloodTypeSerovarUnit;
                        bloodTypeSerovarListCustom.push(valueABloodType);
                        bloodTypeSerovarListCustom.push(valueBBloodType);
                      }
                    });
                    break;
                  case 11:
                  case 12:
                  case 13:
                  case 14:
                  case 15:
                  case 16:
                  case 17:
                  case 18:
                    bloodTypeSerovarTypeAAndBRange.forEach((item) => {
                      const value = 400 + bloodTypeSerovarUnit * 10 + item;
                      if (!bloodTypeSerovarListCustom.includes(value)) {
                        bloodTypeSerovarListCustom.push(value);
                      }
                    });
                    break;
                  case 21:
                  case 22:
                  case 23:
                  case 24:
                  case 25:
                  case 26:
                  case 27:
                  case 28:
                    bloodTypeSerovarTypeAAndBRange.forEach((item) => {
                      const value = 400 + item * 10 + bloodTypeSerovarUnit;
                      if (!bloodTypeSerovarListCustom.includes(value)) {
                        bloodTypeSerovarListCustom.push(value);
                      }
                    });
                    break;
                }
                break;
            }
          });
        });
      }
      // 血液型(ABO)を指定する、血液型(亜型)を指定しない場合
      else if (
        _.isEmpty(this.bloodTypeAboList) &&
        !_.isEmpty(this.bloodTypeSerovarList)
      ) {
        this.bloodTypeSerovarList.forEach((bloodTypeSerovar) => {
          bloodTypeSerovarListCustom.push(bloodTypeSerovar);
          const bloodTypeSerovarUnit = bloodTypeSerovar % 10;
          //mod 患者詳細検索no2障害  吉 start
          // switch (bloodTypeSerovar) {
          switch (Number(bloodTypeSerovar)) {
            //mod 患者詳細検索no2障害  吉 end
            case 0:
              bloodTypeSerovarTypeAAndBRange.forEach((item) => {
                if (item === 0) {
                  bloodTypeSerovarListCustom.push(400);
                } else {
                  const valueABloodType =
                    400 + bloodTypeSerovarUnit * 10 + item;
                  const valueBBloodType =
                    400 + item * 10 + bloodTypeSerovarUnit;
                  bloodTypeSerovarListCustom.push(valueABloodType);
                  bloodTypeSerovarListCustom.push(valueBBloodType);
                }
              });
              break;
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
            case 17:
            case 18:
              bloodTypeSerovarTypeAAndBRange.forEach((item) => {
                const value = 400 + bloodTypeSerovarUnit * 10 + item;
                if (!bloodTypeSerovarListCustom.includes(value)) {
                  bloodTypeSerovarListCustom.push(value);
                }
              });
              break;
            case 16:
              bloodTypeSerovarTypeAAndBRange.forEach((item) => {
                const value = 400 + bloodTypeSerovarUnit * 10 + item;
                if (!bloodTypeSerovarListCustom.includes(value)) {
                  bloodTypeSerovarListCustom.push(value);
                }
              });
              bloodTypeSerovarListCustom.push(35);
              break;
            case 21:
            case 22:
            case 23:
            case 24:
            case 25:
            case 27:
            case 28:
              bloodTypeSerovarTypeAAndBRange.forEach((item) => {
                const value = 400 + item * 10 + bloodTypeSerovarUnit;
                if (!bloodTypeSerovarListCustom.includes(value)) {
                  bloodTypeSerovarListCustom.push(value);
                }
              });
              break;
            case 26:
              bloodTypeSerovarTypeAAndBRange.forEach((item) => {
                const value = 400 + item * 10 + bloodTypeSerovarUnit;
                if (!bloodTypeSerovarListCustom.includes(value)) {
                  bloodTypeSerovarListCustom.push(value);
                }
              });
              bloodTypeSerovarListCustom.push(36);
              break;
          }
        });
      }
      pat_personal_main = {
        hospPatId: this.hospPatId,
        patName: this.patName,
        nameInitialList: this.nameInitialList,
        patSex: this.patSex,
        ageLower: ageLowerTmp,
        ageUpper: ageUpperTmp,
        bloodTypeAboList: this.bloodTypeAboList,
        bloodTypeRhList: this.bloodTypeRhList,
        bloodTypeSerovarList: bloodTypeSerovarListCustom,
        inOutClassList: this.inOutClassList,
        //add no338 連絡先情報 start 張岩
        // 連絡先情報．姓
        lastName: this.lastName,
        // 連絡先情報．名
        firstName: this.firstName,
        // 連絡先情報．セイ
        lastNameKana: this.lastNameKana,
        // 連絡先情報．メイ
        firstNameKana: this.firstNameKana,
        // 連絡先情報．続柄コード
        relationCd: this.relationCd,
        // 連絡先情報．続柄名
        relationName: this.relationName,
        // 業者連絡先情報.会社名
        companyName: this.companyName,
        // 業者連絡先情報.担当者姓
        workerLastName: this.workerLastName,
        // 業者連絡先情報.担当者名
        workerFirstName: this.workerFirstName,
        //add no338 連絡先情報 end 張岩
        //add 患者透析困難情報を検索する 劉全航 start
        isDialDiff: this.isDialDiff,
        //add 患者透析困難情報を検索する 劉全航 end
        //add 重症度検索機能追加 劉全航 start
        severityCd: this.severityCd,
        severityName: this.severityName,
        //add 重症度検索機能追加 劉全航 end
        //add 搬送区分検索機能追加 劉全航 start
        transportCd: this.transportCd,
        transportName: this.transportName
        //add 搬送区分検索機能追加 劉全航 end
      };
    } else {
      pat_personal_main = {
        conditionIsEmpty: true,
      };
    }

    let pat_main = null;
    if (
      // 患者詳細検索ページデバッグ 劉全航 start
      this.isBloodSugerExam !== "" ||
      this.isInfect !== "" ||
      this.isImplant !== "" ||
      this.isDiabetes !== "" ||
      this.staffCdDoctor !== null ||
      this.staffCdCharge !== null ||
      this.staffCdPucture !== null ||
      this.tabooCd !== null ||
      this.tabooContent !== "" ||
      this.allergyCd !== null ||
      this.allergyContent !== "" ||
      /* add 患者情報追加 馬宇婷 start */
      this.mainCourseCd !== null ||
      !_.isEmpty(this.courseName) ||
      this.dialysisCourseCd !== null ||
      !_.isEmpty(this.dialCourseName) ||
      this.wardCd !== null ||
      !_.isEmpty(this.wardName) ||
      this.dialysisCountLower !== null ||
      this.dialysisCountUpper !== null ||
      this.purificationCountLower !== null ||
      this.purificationCountUpper !== null ||
      /* add 患者情報追加 馬宇婷 end */
      this.dialHstLower.year !== "" ||
      this.dialHstLower.month !== "" ||
      this.dialHstUpper.year !== "" ||
      this.dialHstUpper.month !== "" ||
      !_.isEmpty(this.inOutStateList) ||
      //add 車いす利用検索機能追加 劉全航 start
      this.isWheelChair !== "" ||
      //add 車いす利用検索機能追加 劉全航 end
      //add NO338 加算情報検索 劉全航 start
      this.additionCd !== null ||
      this.additionName !== null
      //add NO338 加算情報検索 劉全航 end
      // 患者詳細検索ページデバッグ 劉全航 end
    ) {
      /* 透析歴が上下限逆転してないか調べる */
      let [dialHstLowerTmp, dialHstUpperTmp] = [
        this.dialHstLower,
        this.dialHstUpper,
      ];
      // 年月をYYMMに
      const lower = `${this.dialHstLower.year.padStart(
        2,
        "0"
      )}${this.dialHstLower.month.padStart(2, "0")}`;
      const upper = `${this.dialHstUpper.year.padStart(
        2,
        "0"
      )}${this.dialHstUpper.month.padStart(2, "0")}`;

      if (
        lower > upper &&
        (this.dialHstUpper.year != "" || this.dialHstUpper.month != "")
      ) {
        // 逆転しているなら入れ替える
        [dialHstLowerTmp, dialHstUpperTmp] = [dialHstUpperTmp, dialHstLowerTmp];
      }

      /*
        診療情報に「透析歴」は存在しないため透析導入日に変換する
        例: 検索実行日が「2019/09/24」、指定透析歴が「0年1ヶ月」～「1年2ヶ月」の場合、
        透析歴「0年1ヶ月」の導入日範囲が「2019/07/25～2019/08/24」、「1年2ヶ月」の導入日範囲が「2018/06/25～2018/07/24」となるので、
        検索対象導入日は「2018/06/25～2019/08/24」となる
       */
      // 透析歴(下限) ⇒ 透析導入日(上限)
      let dialysisStartDateUpper = "";
      if (dialHstLowerTmp.year || dialHstLowerTmp.month) {
        const duration = moment.duration({
          years: dialHstLowerTmp.year,
          months: dialHstLowerTmp.month,
        });
        dialysisStartDateUpper = moment().subtract(duration).format("YYYYMMDD");
      }
      // 透析歴(上限) ⇒ 透析導入日(下限)
      let dialysisStartDateLower = "";
      if (dialHstUpperTmp.year || dialHstUpperTmp.month) {
        const duration = moment.duration({
          years: dialHstUpperTmp.year,
          months: Number(dialHstUpperTmp.month) + 1,
        });
        dialysisStartDateLower = moment()
          .subtract(duration)
          .add(1, "days")
          .format("YYYYMMDD");
      }

      if (dialysisStartDateLower != "" && dialysisStartDateUpper != "") {
        if (dialysisStartDateLower > dialysisStartDateUpper) {
          let temp = dialysisStartDateLower;
          dialysisStartDateLower = dialysisStartDateUpper;
          dialysisStartDateUpper = temp;
        }
      }

      if (dialysisStartDateLower != "" && dialysisStartDateUpper != "") {
        if (dialysisStartDateLower > dialysisStartDateUpper) {
          let temp = dialysisStartDateLower;
          dialysisStartDateLower = dialysisStartDateUpper;
          dialysisStartDateUpper = temp;
        }
      }

      pat_main = {
        isBloodSugerExam: this.isBloodSugerExam,
        isInfect: this.isInfect,
        isImplant: this.isImplant,
        isDiabetes: this.isDiabetes,
        staffCdDoctor: this.staffCdDoctor,
        staffCdCharge: this.staffCdCharge,
        staffCdPucture: this.staffCdPucture,
        tabooCd: this.tabooCd,
        tabooContent: this.tabooContent,
        allergyCd: this.allergyCd,
        allergyContent: this.allergyContent,
        /* add 患者情報追加 馬宇婷 start */
        mainCourseCd: this.mainCourseCd,
        courseName: this.courseName,
        dialysisCourseCd: this.dialysisCourseCd,
        dialCourseName: this.dialCourseName,
        wardCd: this.wardCd,
        wardName: this.wardName,
        dialysisCountLower: this.dialysisCountLower,
        dialysisCountUpper: this.dialysisCountUpper,
        purificationCountLower: this.purificationCountLower,
        purificationCountUpper: this.purificationCountUpper,
        /* add 患者情報追加 馬宇婷 end */
        dialysisStartDateLower,
        dialysisStartDateUpper,
        inOutStateList: this.inOutStateList,
        //add 車いす利用検索機能追加 劉全航 start
        isWheelChair: this.isWheelChair,
        //add 車いす利用検索機能追加 劉全航 end
        //add NO338 加算情報検索 劉全航 start
        additionCd: this.additionCd,
        additionName: this.additionName,
        additionSearchCondition:
          this.additionCd === null ? null : this.additionSearchCondition,
        //add NO338 加算情報検索 劉全航 end
        conditionIsEmpty: false,
      };
    } else {
      pat_main = {
        conditionIsEmpty: true,
      };
    }

    let pat_rad_pattern = null;
    if (
      !_.isEmpty(this.radPattern_exam_week)||
      this.radPattern_exam_pattern !== null||
      this.radPattern_exam_pattern_start_date!== ""||
      this.radPattern_exam_pattern_end_date!== "" ||
      //add no338 一般撮影検査予定項目追加 時刻 劉全航 start
      this.patRadPatternRegRadDate !== ""
      //add no338 一般撮影検査予定項目追加 時刻 劉全航 end
    ){
      pat_rad_pattern={
        radPattern_exam_week:this.radPattern_exam_week,
        radPattern_exam_pattern:this.radPattern_exam_pattern,
        radPattern_exam_pattern_start_date :this.radPattern_exam_pattern_start_date,
        radPattern_exam_pattern_end_date:this.radPattern_exam_pattern_end_date,
        //add no338 一般撮影検査予定項目追加 時刻 劉全航 start
        patRadPatternRegRadDate: this.patRadPatternRegRadDate,
        conditionIsEmpty: false
        //add no338 一般撮影検査予定項目追加 時刻 劉全航 end
      }
    }else{
      pat_rad_pattern={
        conditionIsEmpty: true
      }
    }


    let  pat_insurance = null;
    if (
      this.insurance_check_date!=""
    ){
      pat_insurance = {
        insurance_check_date : this.insurance_check_date,
      }
    }



    let pat_exam_pattern = null;
    if (
      !_.isEmpty(this.exam_week)||
      this.exam_pattern !== null||
      this.reg_order_class !== ""||
      this.exam_pattern_start_date!= ""||
      this.exam_pattern_end_date != ""
      // add FutreNetWeb+SI課題管理No4770対応 趙 start
      || !_.isEmpty(this.examSetCdList)
      // add FutreNetWeb+SI課題管理No4770対応 趙 end
    ){
      pat_exam_pattern = {
        exam_week : this.exam_week,
        exam_pattern : this.exam_pattern,
        reg_order_class : this.reg_order_class,
        exam_pattern_start_date:this.exam_pattern_start_date,
        exam_pattern_end_date:this.exam_pattern_end_date,
        // add FutreNetWeb+SI課題管理No4770対応 趙 start
        exam_set_cd:this.examSetCdList
        // add FutreNetWeb+SI課題管理No4770対応 趙 end
      }
    }



    let pat_unique = null;
    if (
      !_.isEmpty(this.outComeList) ||
      !_.isEmpty(this.dialysis_underlying_disease_List)||
      this.diseaseCd !== null ||
      this.primary_disease_cd!=null
    ) {
      pat_unique = {
        dialysis_underlying_disease_List:this.dialysis_underlying_disease_List,
        primary_disease_cd:this.primary_disease_cd,
        outComeList: this.outComeList,
        diseaseCd: this.diseaseCd
      };
    }

    let ord_schedule = null;
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    if (
      !_.isEmpty(this.kurCdList) ||
      !_.isEmpty(this.bedGroupCdList) ||
      !_.isEmpty(this.treatDayOfWeekList) ||
      !_.isEmpty(this.simpleSearchTreatDayOfWeekList) ||
      !_.isEmpty(this.simpleSearchKurCdList) ||
      this.simpleSearchBedGroupCd
    ) {
      ord_schedule = {
        kurCdList: this.kurCdList,
        bedGroupCdList: this.bedGroupCdList,
        treatDayOfWeekList: this.treatDayOfWeekList,
        simpleSearchTreatDayOfWeekList: this.simpleSearchTreatDayOfWeekList,
        simpleSearchKurCdList: this.simpleSearchKurCdList,
        simpleSearchBedGroupCd: this.simpleSearchBedGroupCd,
      };
    }
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

    let ord_main = null;
    const {

      selectionList: dialysisConditionSelectionList,
      rangeValues: dialysisConditionRangeValueList,
      radioValues: dialysisConditionRadioValueList,
      timeValues: dialysisConditionTimeValueList
    } = this.dialysisConditions();
    const medicationList = this.medicationConditions();
    const equipmentList = this.equipmentConditions();
    const indCommentList = this.indComments();
    const treatmentCdList = this.treatmentCdList;
    const dialyzerCdList = this.dialyzerCdList;
    const dialysisDateArgs = this.dialysisDateArgs;
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    if (
      this.dialysisDateArgs ||
      !_.isEmpty(dialysisConditionSelectionList) ||
      !_.isEmpty(dialysisConditionRangeValueList) ||
      !_.isEmpty(dialysisConditionRadioValueList) ||
      !_.isEmpty(dialysisConditionTimeValueList) ||
      !_.isEmpty(medicationList) ||
      !_.isEmpty(equipmentList) ||
      !_.isEmpty(treatmentCdList) ||
      !_.isEmpty(dialyzerCdList) ||
      indCommentList.length > 1 ||
      !_.isEmpty(this.simpleSearchRstDialysisState) ||
      !_.isEmpty(this.simpleSearchTreatDate)
    ) {
      ord_main = {
        dialysisConditionSelectionList,
        dialysisConditionRangeValueList,
        dialysisConditionRadioValueList,
        dialysisConditionTimeValueList,
        treatmentCdList,
        dialyzerCdList,
        medicationList,
        equipmentList,
        indCommentList,
        dialysisDateArgs,
        dialysisStartDate: this.dialysisDate(this.dialysisStartDate, this.dialysisEndDate).start,
        dialysisEndDate: this.dialysisDate(this.dialysisStartDate, this.dialysisEndDate).end,
        simpleSearchRstDialysisState: this.simpleSearchRstDialysisState,
        simpleSearchTreatDate: this.simpleSearchTreatDate,
      };
    }
    // mod 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

    let patGroupSearch = null;
    if (this.patGroups.length > 0) {
      patGroupSearch = {
        patGroupCd: this.patGroups,
        searchType: +this.patGroupsMethod
      };
    }
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    let simpleSearchPatGroupSearch = this.simpleSearchPatGroupSearch;
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

    //add 患者イベントで検索 劉全航 start
    let patEvent = null;
    if(
      this.categoryList.length>0 ||
      this.eventStartDate !== "" ||
      this.eventEndDate !== ""
    ) {
      patEvent = {
        categoryCdList: this.categoryList,
        eventStartDate: this.eventStartDate !== "" ? moment(this.eventStartDate).format("YYYYMMDD") : "",
        eventEndDate: this.eventEndDate !== "" ? moment(this.eventEndDate).format("YYYYMMDD") : ""
      }
    }
    //add 患者イベントで検索 劉全航 end

    return {
      pat_personal_main,
      pat_main,
      pat_unique,
      pat_exam_pattern,
      pat_rad_pattern,
      ord_schedule,
      ord_main,
      pat_insurance,
      facilityCdList,
      patGroupSearch,
      //add 患者イベント検索 劉全航 start
      patEvent,
      //add 患者イベント検索 劉全航 end
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      simpleSearchPatGroupSearch,
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    };
  }

  /**
   * @description 透析予定期間の検索条件
   */
  dialysisDate(start = '', end = '') {
    /* 1 :本日  2:昨日  3:明日 4:今週  5:先週
         6:来週  7:今月  8:先月  9:来月 */
    let nowDate = new Date();
    let time = nowDate.getTime();
    let week = nowDate.getDay();
    let Spacetime = "";
    switch (this.dialysisDateArgs) {
      case "today":
        start = end = moment(nowDate).format("YYYYMMDD");
        break;
      case "yesterday":
        Spacetime = moment(time - 24 * 60 * 60 * 1000);
        start = end = Spacetime.format("YYYYMMDD");
        break;
      case "tomorrow":
        Spacetime = moment(time + 24 * 60 * 60 * 1000);
        start = end = Spacetime.format("YYYYMMDD");
        break;
      case "thisWeek":
        Spacetime = moment(time - 24 * 60 * 60 * 1000 * (week - 1));
        start = Spacetime.format("YYYYMMDD");
        Spacetime = moment(time + 24 * 60 * 60 * 1000 * (7 - week));
        end = Spacetime.format("YYYYMMDD");
        break;
      case "lastWeek":
        Spacetime = moment(nowDate.getTime() - 24 * 60 * 60 * 1000 * week);
        end = Spacetime.format("YYYYMMDD");
        Spacetime = moment(nowDate.getTime() - 24 * 60 * 60 * 1000 * (week + 6));
        start = Spacetime.format("YYYYMMDD");
        break;
      case "nextWeek":
        Spacetime = moment(nowDate.getTime() + 24 * 60 * 60 * 1000 * (8 - week));
        start = Spacetime.format("YYYYMMDD");
        Spacetime = moment(nowDate.getTime() + 24 * 60 * 60 * 1000 * (14 - week));
        end = Spacetime.format("YYYYMMDD");
        break;
      case "thisMonth":
        start = moment(nowDate).startOf('month').format("YYYYMMDD");
        end = moment(nowDate).endOf('month').format("YYYYMMDD");
        break;
      case "lastMonth":
        start = moment(nowDate).subtract(1, 'months').startOf('month').format("YYYYMMDD");
        end = moment(nowDate).subtract(1, 'months').endOf('month').format("YYYYMMDD");
        break;
      case "nextMonth":
        start = moment(nowDate).add(1, 'months').startOf('month').format("YYYYMMDD");
        end = moment(nowDate).add(1, 'months').endOf('month').format("YYYYMMDD");
        break;
      default:
        start = formatDatetime(start, "YYYYMMDD");
        end = formatDatetime(end, "YYYYMMDD");
    }
    return { start, end };
  }

  /**
   * @description 透析条件の検索条件
   */
  dialysisConditions() {
    const selectionList = [];
    const rangeValues = [];
    const radioValues = [];
    const timeValues = [];

    // 5つの透析条件から同じ選択形式の条件ごとに集める
    for (let i = 1; i <= 5; i++) {
      const cond = this.dialysisConditionList[i];
      if (cond instanceof DiaysisConditionListSelect) {
        // リスト選択形式には選択項目の名称が含まれているので除外する
        const cdList = cond.selectedItemList.map(item => item.cd);
        if (cdList.length > 0) {
          // リストが選択されていれば条件に追加
          selectionList.push({
            conditionId: cond.conditionId,
            cdList
          });
        }
      } else if (cond instanceof DiaysisConditionRangeValue) {
        // 範囲値形式
        const rangeValueCond = {
          conditionId: cond.conditionId,
          value1: null,
          value2: null,
          comparisonType: cond.comparisonType,
          inequalitySign1: cond.inequalitySign1,
          inequalitySign2: cond.inequalitySign2
        };
        if (
          cond.comparisonType == COMPARISON_TYPE.EQUALITY &&
          cond.value1String !== ""
        ) {
          // 値一致指定で値1が空でなければ条件に追加
          rangeValueCond.value1 = cond.value1Num;
          rangeValues.push(rangeValueCond);
        } else if (
          cond.comparisonType == COMPARISON_TYPE.INEQUALITY &&
          (cond.value1String !== "" || cond.value2String !== "")
        ) {
          // 値範囲指定で値1または値2が空でなければ条件に追加
          rangeValueCond.value1 = cond.value1Num;
          rangeValueCond.value2 = cond.value2Num;
          rangeValues.push(rangeValueCond);
        }
      } else if (cond instanceof DiaysisConditionRadio) {
        // ラジオボタン形式
        if (cond.value !== null) {
          cond.value = +cond.value;
          // 選択されていれば条件に追加
          radioValues.push(cond);
        }
      } else if (cond instanceof DiaysisConditionTime) {
        // 時間形式
        if (cond.lowerTime !== "" || cond.upperTime !== "") {
          // 開始時間または終了時間が空でなければ条件に追加
          let [lowerMinutesTmp, upperMinutesTmp] = [
            cond.lowerMinutes,
            cond.upperMinutes
          ];
          if (
            cond.lowerTime !== "" &&
            cond.upperTime !== "" &&
            lowerMinutesTmp > upperMinutesTmp
          ) {
            // 時間上下限逆転
            [lowerMinutesTmp, upperMinutesTmp] = [
              upperMinutesTmp,
              lowerMinutesTmp
            ];
          }
          timeValues.push({
            conditionId: cond.conditionId,
            lowerMinutes: lowerMinutesTmp,
            upperMinutes: upperMinutesTmp
          });
        }
      }
    }
    return { selectionList, rangeValues, radioValues, timeValues };
  }

  /**
   * @description 投薬指示の検索条件
   */
  medicationConditions() {
    const medications = [];
    for (let i = 1; i <= 5; i++) {
      // マスタコードと名称のオブジェクトを持っているのでコードだけにする
      const cdList = this.medicationList[i].map(item => item.cd);
      if (cdList.length > 0) {
        medications.push(cdList);
      }
    }
    return medications;
  }

  /**
   * @description 医材指示の検索条件
   */
  equipmentConditions() {
    const equipments = [];
    for (let i = 1; i <= 5; i++) {
      // マスタコードと名称のオブジェクトを持っているのでコードだけにする
      const cdList = this.equipmentList[i].map(item => item.cd);
      if (cdList.length > 0) {
        equipments.push(cdList);
      }
    }
    return equipments;
  }

  /**
   * @description 空欄以外の指示コメント
   */
  indComments() {
    return this.indCommentList.filter(comment => comment !== "");
  }
}
