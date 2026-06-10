import {ApiHelper} from "@/apis/AxiosHelper";
import {deepCopy, merge, convertToHalfWidth, getPrefix} from "@/functions/common/CommonFunctions";
import {mstPatViewerLayoutDefine, vitalMonitorGraphInoutDefine} from "@/constants/mstPatViewerLayoutDefine";
import {sendRequestGetMstSupportSettingData as getMstSupportSettingData} from "@/apis/mst-support-setting-maintenance";
import { dialyzer, dialyzerTabooAllergy, dialyzerTabooAllergyDeleted, equipment, equipmentAllergy, equipmentClass, equipmentTabooAllergy, medicateTiming, medicine, medicineAllergy, medicineClass, medicineIncludeDeleted, medicineMix, medicineMixAllergy, medicineMixIncludeDeleted, medicineMixTabooAllergy, medicineTabooAllergy, mstPatViewerLayout, procedure, treatment, treatmentDel, va } from "@/functions/mst/MstGetters";
import store from "@/stores";
import moment from "moment";
import BigNumber from "bignumber.js";
import {defaultMstDeviceInfo} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import {sendRequestFindPhysicalInfo} from "@/apis/pat-viewer";
import {sendRequestGetMstFacilityByCd} from "@/apis/facility";
import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
import {fitTermCheck} from "@/functions/common/DateTimeUtils";
import {sendRequestGetTreatmentRecordVitalMonitor} from "@/apis/treatment-record";
import {sendRequestGetOrdMainByOrdNo} from "@/apis/ord-main.js";
import {toFixed} from "@/functions/common/NumberFunctions.js";
import { CODES } from "@/constants/TreatmentRecord";
import { DEVICEMODE } from "@/constants/mstTreatmentDefine.js";
import {
  isValidNumber,
  getThreshold,
  getSeriesMarker
} from "@/functions/pat-viewer/PatViewerFunctions";

/**
 * 画面表示用 各表示項目のデータ構造の雛形
 * @param {number} itemNo 識別番号(例:治療条件の場合、治療条件項目番号として使用)
 * @param {string} itemName 項目名(一覧の項目列に表示する項目名)
 * @param {Array} data 日付列ごとに表示するデータ(※layoutDispData_dataを参照)
 */
const layoutDispData = {
  itemNo: null,
  itemName: null,
  data: []
};

/**
 * 画面表示用 各表示項目のデータ構造の雛形の'data'部分
 * @param {string} treatDate 治療日(YYYYMMDD形式)
 * @param {number} ordNo オーダ番号
 * @param {*} value1 表示データ(指示)
 * @param {*} value2 表示データ(実績)
 */
const layoutDispData_data = {
  treatDate: null,
  ordNo: null,
  value1: null,
  value2: null,
  isNotClickable: null,
  // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
  colorFlg: 0,
  deviceMode: -1,
  treatMethodCd: 0,
  // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
  // add FNSI-回診記録を追加 李 start
  isRstRoundsFlg: false,
  // add FNSI-回診記録を追加 李 end
  // 加算：1
  dataItem: null
};

/* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
const TABOO_CLASS_PREFIX = "【禁忌】";
const ALLERGY_CLASS_PREFIX = "【ｱﾚﾙｷﾞｰ】";
const TABOO_ALLERGY_CLASS_PREFIX = "【禁忌・ｱﾚﾙｷﾞｰ】";

function getTabooAllergyPrefix(isTaboo, isAllergy) {
  if (isTaboo && isAllergy) {
    return TABOO_ALLERGY_CLASS_PREFIX;
  } else if (isTaboo && !isAllergy) {
    return TABOO_CLASS_PREFIX;
  } else if (!isTaboo && isAllergy) {
    return ALLERGY_CLASS_PREFIX;
  }
}

function isTabooAllergy(name) {

  if (name.startsWith(TABOO_CLASS_PREFIX) 
    || name.startsWith(ALLERGY_CLASS_PREFIX) 
    || name.startsWith(TABOO_ALLERGY_CLASS_PREFIX)) {
    return true;
  }
  return false;
}
/* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */
// xrangeタイプデータの重複日付結合関数
const mergeXrangeData = (arr) => {
  let dates = [];
  arr.forEach(item => {
    let [start, end, count] = item;
    let currentDate = start;
    while (currentDate <= end) {
      dates.push({ date: currentDate, count: Number(count) });
      currentDate = moment(currentDate).add(1, "days").format("YYYYMMDD");
    }
  });

  dates.sort((a, b) => a.date - b.date);
  let mergedDates = [];
  dates.forEach(item => {
    let lastItem = mergedDates[mergedDates.length - 1];
    if (lastItem && lastItem.date === item.date) {
      lastItem.count += item.count;
    } else {
      mergedDates.push({ ...item });
    }
  });

  let result = [];
  mergedDates.forEach(item => {
    let lastItem = result[result.length - 1];
    if (lastItem && Number(lastItem.end) + 1 === Number(item.date) && lastItem.count === item.count) {
      lastItem.end = item.date;
    } else {
      result.push({ start: item.date, end: item.date, count: item.count });
    }
  });

  return result.map(item => [item.start, item.end, item.count.toString()]);
};

export default {
  namespaced: true,
  strict: true,

  state: {
    /**
     * 一覧ヘッダー表示日付リスト
     */
    dateList: [],
    dialysisStateArray: [],

    /**
     * 一覧に表示する項目リスト(患者経過総合ビューアレイアウトマスタ情報)
     */
    dispLayoutItemList: [],

    /**
     * DB取得データ(ord_main)を行単位に加工したデータ
     */
    treatmentData: [],
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    recentTreatmentDate: [],
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    treatmentDataTmp: [],
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
    //内部remine 5840  add ljx start
    treatmentDataOfPeriod: [],
    treatmentDataOfPeriodTmp: [],
    dateArray:[],
    //内部remine 5840  add ljx end
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    // weekChangeData: [],
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

    /**
     * DB取得データ(pat_exam_main)を行単位に加工したデータ
     */
    examMainData: [],

    // add FNSI-検体検査の表示の修正 楊 start
    /**
     * DB取得データ(pat_exam_main)
     */
    lastExamMainData: null,
    // add FNSI-検体検査の表示の修正 楊 end

    /**
     * DB取得データ(pat_rad_main)を行単位に加工したデータ
     */
    radMainData: [],

    // add FNSI-放射線検査の表示の修正 楊 start
    /**
     * DB取得データ(pat_rad_main)
     */
    lastRadDate: null,
    // add FNSI-放射線検査の表示の修正 楊 end

    // add FNSI-観察記録を追加 楊 start
    /**
     * DB取得データ(pat_event)
     */
    patEventDataList: [],
    // add FNSI-観察記録を追加 楊 end

    // add FNSI-紹介状を追加 楊 start
    /**
     * DB取得データ(pat_unique)
     */
    patUniqueDataList: [],
    // add FNSI-紹介状を追加 楊 end

    // add FNSI-患者イベント（仮）を追加 李 start
    /**
     * DB取得データ(pat_event)
     */
    patientDataList: [],
    // add FNSI-患者イベント（仮）を追加 李 end
    //7342 add 紹介状のイベント日付が登録日になる 張 start
    letterDataList:[],
    //7342 add 紹介状のイベント日付が登録日になる 張 start
    // add FNSI-処方を追加 姜 start
    /**
     * DB取得データ(pat_event)
     */
    patPrescriptionDataList: [],
    // add FNSI-処方を追加 姜 end

    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    dataListKeepTreatCond: {},
    dataListKeepMedicine: {},
    dataListKeepEquipment: {},
    dataListKeepIndComment: {},
    dataListKeepUFRProgram: {},
    dataListKeepNaProgram: {},
    dataListKeepDialysateProgram: {},
    dataListKeepBvUfc: {},
    dataListKeepDiaysisProgram: {},
    dataListKeepSchedule: {},
    dataListKeepTreatMethod: {},
    patIdKeep: "",
    patIdKeepChgFlg: false,
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

    /**
     * ベッドマスタデータ
     */
    mstBedData: [],
    //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
    /**
     * ベッドマスタデータ
     */
    mstAllBedData: [],
    //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
    /**
     * クールマスタデータ
     */
    mstKurData: [],

    /**
     * 治療方法マスタデータ
     */
    mstTreatmentData: [],

    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
    /**
     * 治療方法マスタデータは削除されました
     */
     mstTreatmentDataIsDel: [],
    //  mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

    /**
     * VAマスタデータ
     */
    mstVaData: [],

    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 start
    /**
     * VAマスタデータ(削除されたを含む)
     */
    mstVaDelData: [],
    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 end

    /**
     * ダイアライザマスタデータ
     */
    mstDialyzerData: [],

    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 start
    /**
     * ダイアライザマスタデータ(削除されたを含む)
     */
    mstDialyzerDelData: [],
    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 end

    /**
     * ダイアライザマスタデータ（禁忌アレルギー込み）
     */
    mstDialyzerTabooAllergyData: [],
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    mstDialyzerTabooAllergyDeletedData: [],
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 薬剤マスタデータ
     */
    mstMedicineData: [],
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    /**
     * 薬剤マスタデータ（削除された薬剤を含む）
     */
    mstMedicineIncludeDeletedData: [],
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 薬剤マスタデータ（禁忌アレルギー込み）
     */
    mstMedicineTabooAllergyData: [],

    // add FNSI-期限切れ削除済みと表示するの修正 李 start
    /**
     * 薬剤マスタデータ（削除された薬剤を含む）
     */
    mstMedicineAllergyData: [],
    // add FNSI-期限切れ削除済みと表示するの修正 李 end

    /**
     * 調製薬剤マスタデータ
     */
    mstMedicineMixData: [],

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    /**
     * 調製薬剤マスタデータ（削除された薬剤を含む）
     */
    mstMedicineMixIncludeDeletedData: [],
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 調製薬剤マスタデータ（禁忌アレルギー込み）
     */
    mstMedicineMixTabooAllergyData: [],

    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 starta
    /**
     * 調製薬剤マスタデータ（削除された薬剤を含む）
     */
    mstMedicineMixAllergyData: [],
    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

    /**
     * 薬剤分類マスタデータ
     */
    mstMedicineClassData: [],

    /**
     * 医療材料マスタデータ
     */
    mstEquipmentData: [],

    /**
     * 医療材料マスタデータ（禁忌アレルギー込み）
     */
    mstEquipmentTabooAllergyData: [],

    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
    /**
     * 医療材料マスタデータ（削除された薬剤を含む）
     */
    mstEquipmentAllergyData: [],
    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

    // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
    /**
     * 医療材料分類マスタデータ
     */
    mstEquipmentClassData: [],
    // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end

    /**
     * 手技マスタデータ
     */
    mstProcedureData: [],

    /**
     * 投与タイミングマスタデータ
     */
    mstMedicateTimingData: [],
    // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 start
    /**
     * 投薬支援マスタデータ
     */
    mstMedicineSupportData: [],
    /**
     * 選択中投薬支援マスタ
     */
    selectedMedicineSupport: null,
    // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 end
    //add FNSI内容修正 バグ284、286 姜 start
    /**
     * 予定リスト
     */
    ordNoMediList: [],
    //add FNSI内容修正 バグ284、286 姜 end
    /**
     * 一覧上の治療予定の有無
     */
    isTreatPlan: true,

    /**
     * 指示・実績表示切替
     * 「指示のみ表示」,「実績優先表示」,「実績指示併記表示」
     */
    selectIndRst: "2",

    /**
     * 一覧上の期間切替
     * "1": 3日分
     * "2": 7日分
     * "3": 14日分
     * "4": 12週分
     * "5": 6ヶ月分
     * "6": 1年分
     * "7": 3年分
     */
    selectedPeriod: "2",
    /**
     * 治療日(基準日)
     */
    treatDate: null,

    ordNoList: [],

    // 死亡フラグ
    is_die: false,
    // 死亡メッセージ表示フラグ
    isDieMessage: false,

    tickPositions: {},
    // 患者身体情報
    physicalInfo: [],

    // 選択中レイアウト
    selectedLayout: null,

    selectedCondition: null,

    // add 更新中の予定を表示する様にする。 李 start
    // データが一つしかない場合:セールのOrdNo
    // 複数のデータがある場合:すべてのOrdNo
    scrollBarPositioningOrdNo: [],
    // add 更新中の予定を表示する様にする。 李 end

    // add FNSI-横展開-日付検索条件 関 start
    condition: {
      logDateStart: "",
      logDateEnd: "",
      // 治療日
      treatmentStartDate: "",
      // 治療方法
      treatmentMethod: "",
      treatmentCourse: "",
      logTarget: "",
      // 作成／更新
      createdBy: null,
      updatedBy: null,
      createdUserId: "",
      updatedUserId: "",
      // フリーワード
      searchQuery: ""
    },
    // add FNSI-横展開-日付検索条件 関 end

    // add FNSI-予定内容遅延問題対応 李 start
    indPlanCreateDate: [],
    resMniMonitors: [],
    mntMachineStates: [],
    // add FNSI-予定内容遅延問題対応 李 end

    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    priorToChangeList: [],
    //内部remine 5840  add ljx start
    afterToChangeList: []
    //内部remine 5840  add ljx end
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    ,indEndDate: null
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
    ,tabooMedicine: false,
    tabooEquipment: false,
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
    //add 5619 装置と紐づいていないベッドも表示 張 start
    bedAndMachine:[],
    //add 5619 装置と紐づいていないベッドも表示 張 end
    treatDateList: [],
    /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
    patTabooAllergy: [],
    /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */
    allData:[],
  },

  getters: {
    /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
    getPatTabooAllergy : state => state.patTabooAllergy,
    /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */
    // add FNSI-横展開-日付検索条件 関 start
    // 抽出条件
    getCondition: state => state.condition,
    // add FNSI-横展開-日付検索条件 関 end
    /**
     * 一覧ヘッダー表示日付リストを取得
     */
    getDateList(state) {
      return state.dateList;
    },
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    getIndEndDate(state) {
      return state.indEndDate;
    },
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
    /**
     * 一覧に表示する項目リストを取得
     */
    getDispLayoutItemListData(state) {
      return state.dispLayoutItemList;
    },

    getDialysisStateArray(state) {
      return state.dialysisStateArray;
    },

    /**
     * DB取得データ(ord_main)を行単位に加工したデータを取得
     */
    getTreatmentData(state) {
      return state.treatmentData;
    },
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    getRecentTreatmentDate(state) {
      return state.recentTreatmentDate;
    },
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    //内部remine 5840  add ljx start
    getTreatmentDataOfPeriod(state) {
      return state.treatmentDataOfPeriod;
    },
    getTreatmentDataOfPeriodTmp(state) {
      return state.treatmentDataOfPeriodTmp;
    },
    //内部remine 5840  add ljx end

    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    /**
     * DB取得データ(ord_main)を行単位に加工したデータを取得
     */
    getTreatmentDataTmp(state) {
      return state.treatmentDataTmp;
    },
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    // getWeekChangeData(state) {
    //   return state.weekChangeData;
    // },
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

    /**
     * DB取得データ(pat_exam_main)を行単位に加工したデータを取得
     */
    getExamMainData(state) {
      return state.examMainData;
    },

    // add FNSI-検体検査の表示の修正 楊 start
    /**
     * DB取得データ(pat_exam_main)
     */
    getLastExamMainData(state) {
      return state.lastExamMainData;
    },
    // add FNSI-検体検査の表示の修正 楊 end

    /**
     * DB取得データ(pat_rad_main)を行単位に加工したデータを取得
     */
    getRadMainData(state) {
      return state.radMainData;
    },

    // add FNSI-放射線検査の表示の修正 楊 start
    /**
     * DB取得データ(lastRadDate)を取得
     */
    getLastRadDate(state) {
      return state.lastRadDate;
    },
    // add FNSI-放射線検査の表示の修正 楊 end

    // add FNSI-観察記録を追加 楊 start
    /**
     * DB取得データ(patEventDataList)を取得
     */
    getPatEventDataList(state) {
      return state.patEventDataList;
    },
    // add FNSI-観察記録を追加 楊 end

    // del FNSI-FutreNetWeb+SI課題管理No.5317 李 start
    // // add FNSI-紹介状を追加 楊 start
    // /**
    //  * DB取得データ(patUniqueDataList)を取得
    //  */
    // getPatUniqueDataList(state) {
    //   return state.patUniqueDataList;
    // },
    // // add FNSI-紹介状を追加 楊 end
    // del FNSI-FutreNetWeb+SI課題管理No.5317 李 end

    // add FNSI-患者イベント（仮）を追加 李 start
    /**
     * DB取得データ(patEventDataList)を取得
     */
    getPatientDataList(state) {
      return state.patientDataList;
    },
    // add FNSI-患者イベント（仮）を追加 李 end
    //7342 add 紹介状のイベント日付が登録日になる 張 start
    getLetterDataList(state){
      return state.letterDataList
    },
    //7342 add 紹介状のイベント日付が登録日になる 張 end
    // add FNSI-処方を追加 姜 start
    /**
     * DB取得データ(patEventDataList)を取得
     */
    getPrescriptionDataList(state) {
      return state.patPrescriptionDataList;
    },
    // add FNSI-処方を追加 姜 end
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    getDataListKeepTreatMethod(state) {
      return state.dataListKeepTreatMethod;
    },
    getDataListKeepSchedule(state) {
      return state.dataListKeepSchedule;
    },
    getPatIdKeep(state) {
      return state.patIdKeep;
    },
    getPatIdKeepChgFlg(state) {
      return state.patIdKeepChgFlg;
    },
    getDataListKeepTreatCond(state) {
      return state.dataListKeepTreatCond;
    },
    getDataListKeepMedicine(state) {
      return state.dataListKeepMedicine
    },
    getDataListKeepEquipment(state) {
      return state.dataListKeepEquipment;
    },
    getDataListKeepDialysateProgram(state) {
      return state.dataListKeepDialysateProgram;
    },
    getDataListKeepIndComment(state) {
      return state.dataListKeepIndComment;
    },
    getDataListKeepBvUfc(state) {
      return state.dataListKeepBvUfc;
    },
    getDataListKeepDiaysisProgram(state) {
      return state.dataListKeepDiaysisProgram;
    },
    getDataListKeepUFRProgram(state) {
      return state.dataListKeepUFRProgram;
    },
    getDataListKeepNaProgram(state) {
      return state.dataListKeepNaProgram;
    },
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

    /**
     * ベッドマスタデータを取得
     */
    getMstBedData(state) {
      let mstBedData = state.mstAllBedData.filter(el => {
        return el.isDisp === "1" && el.isDel === "0";
      });
      return mstBedData;
    },
    //add 5619 装置と紐づいていないベッドも表示 張 start
    /**
     * 指定施設にて装置が割りついているベッド+装置情報の一覧を取得する
     */
    getBedAndMachine(state) {
      return state.bedAndMachine;
    },
    //add 5619 装置と紐づいていないベッドも表示 張 end
    //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
    /**
     * ベッドマスタデータを取得
     */
    getMstAllBed(state) {
      return state.mstAllBedData;
    },
    //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
    /**
     * クールマスタデータを取得
     */
    getMstKurData(state) {
      return state.mstKurData;
    },

    /**
     * 治療方法マスタデータを取得
     */
    getMstTreatmentData(state) {
      return state.mstTreatmentData;
    },

    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
     /**
     * 治療方法マスタ削除データを取得
     */
      getMstTreatmentDataIsDel(state) {
        return state.mstTreatmentDataIsDel;
      },
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

    /**
     * VAマスタデータを取得
     */
    getMstVaData(state) {
      return state.mstVaData;
    },

    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 start
    /**
     * VAマスタデータを取得
     */
    getMstVaDelData(state) {
      return state.mstVaDelData;
    },
    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 end

    /**
     * ダイアライザマスタデータを取得
     */
    getMstDialyzerData(state) {
      return state.mstDialyzerData;
    },

    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 start
    /**
     * ダイアライザマスタデータを取得(削除されたを含む)
     */
    getMstDialyzerDelData(state) {
      return state.mstDialyzerDelData;
    },
    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 end

    /**
     * ダイアライザマスタデータを取得（禁忌アレルギー込み）
     */
    getMstDialyzerTabooAllergyData(state) {
      return state.mstDialyzerTabooAllergyData;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    getMstDialyzerTabooAllergyDeletedData(state) {
      return state.mstDialyzerTabooAllergyDeletedData;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 薬剤マスタデータを取得
     */
    getMstMedicineData(state) {
      return state.mstMedicineData;
    },

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    /**
     * 薬剤マスタデータを取得（削除された薬剤を含む）
     */
    getMstMedicineIncludeDeletedData(state) {
      return state.mstMedicineIncludeDeletedData;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 薬剤マスタデータを取得（禁忌アレルギー込み）
     */
    getMstMedicineTabooAllergyData(state) {
      return state.mstMedicineTabooAllergyData;
    },

    /**
     * 調製薬剤マスタデータを取得
     */
    getMstMedicineMixData(state) {
      return state.mstMedicineMixData;
    },

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    /**
     * 調製薬剤マスタデータを取得（削除された薬剤を含む）
     */
    getMstMedicineMixIncludeDeletedData(state) {
      return state.mstMedicineMixIncludeDeletedData;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 調製薬剤マスタデータを取得（禁忌アレルギー込み）
     */
    getMstMedicineMixTabooAllergyData(state) {
      return state.mstMedicineMixTabooAllergyData;
    },

    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 starta
    /**
     * 調製薬剤マスタデータ（削除された薬剤を含む）
     */
    getMstMedicineMixAllergyData(state) {
      return state.mstMedicineMixAllergyData;
    },
    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

    // add FNSI-期限切れ削除済みと表示するの修正 李 start
    /**
     * 薬剤マスタデータを取得（削除された薬剤を含む）
     */
    getMstMedicineAllergyData(state) {
      return state.mstMedicineAllergyData;
    },
    // add FNSI-期限切れ削除済みと表示するの修正 李 end

    /**
     * 薬剤分類マスタデータを取得
     */
    getMstMedicineClassData(state) {
      return state.mstMedicineClassData;
    },

    /**
     * 医療材料マスタデータを取得
     */
    getMstEquipmentData(state) {
      return state.mstEquipmentData;
    },

    /**
     * 医療材料マスタデータを取得（禁忌アレルギー込み）
     */
    getMstEquipmentTabooAllergyData(state) {
      return state.mstEquipmentTabooAllergyData;
    },

    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
    /**
     * 医療材料マスタデータ（削除された薬剤を含む）
     */
    getMstEquipmentAllergy(state) {
      return state.mstEquipmentAllergyData;
    },
    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

    // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
    /**
     * 医療材料分類マスタデータを取得
     */
    getMstEquipmentClassData(state) {
      return state.mstEquipmentClassData;
    },
    // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end

    /**
     * 手技マスタデータを取得
     */
    getMstProcedureData(state) {
      return state.mstProcedureData;
    },

    /**
     * 投与タイミングマスタデータを取得
     */
    getMstMedicateTimingData(state) {
      return state.mstMedicateTimingData;
    },

    // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 start
    /**
     * 投薬支援マスタデータを取得
     */
    getMstMedicineSupportData(state) {
      return state.mstMedicineSupportData;
    },

    /**
     * 選択中投薬支援マスタ
     */
    getSelectedMedicineSupport(state) {
      return state.selectedMedicineSupport;
    },
    // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 end

    /**
     * 一覧上の治療予定の有無
     */
    getIsTreatPlan(state) {
      let isPlan = false;
      if (0 !== state.treatmentData.length) {
        // 一覧上に治療予定が入ってればtrueを返す
        for (const date in state.treatmentData[0]) {
          if (null !== state.treatmentData[0][date]) {
            isPlan = true;
          }
        }
      }
      return isPlan;
    },

    /**
     * 指示・実績表示切替
     */
    getSelectIndRst(state) {
      return state.selectIndRst;
    },

    /**
     * 一覧上の期間切替
     */
    getSelectedPeriod(state) {
      return state.selectedPeriod;
    },
    /**
     * 治療日(基準日の取得)
     */
    getTreatBaseDate(state) {
      return state.treatDate;
    },

    getOrdNoList(state) {
      return state.ordNoList;
    },

    getIsDie(state) {
      return state.is_die;
    },
    getIsDieMessage(state) {
      return state.isDieMessage;
    },

    getTickPositions(state) {
      return state.tickPositions;
    },
    getPhysicalInfo: state => state.physicalInfo,

    getSelectedLayout(state) {
      return state.selectedLayout;
    },

    getSelectedCondition(state) {
      return state.selectedCondition;
    },

    // add 更新中の予定を表示する様にする。 李 start
    getScrollBarPositioningOrdNo(state) {
      return state.scrollBarPositioningOrdNo;
    },
    // add 更新中の予定を表示する様にする。 李 end
    //add FNSI内容修正 バグ284、286 姜 start
    getOrdNoMediList(state) {
      return state.ordNoMediList;
    },
    //add FNSI内容修正 バグ284、286 姜 end

    // add FNSI-予定内容遅延問題対応 李 start
    getIndPlanCreateDate(state) {
      return state.indPlanCreateDate;
    },
    getResMniMonitors(state) {
      return state.resMniMonitors;
    },
    getMntMachineStates(state) {
      return state.mntMachineStates;
    },
    // add FNSI-予定内容遅延問題対応 李 end

    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    getPriorToChangeList(state) {
      return state.priorToChangeList;
    },

    getAfterToChangeList(state) {
      return state.afterToChangeList;
    }
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
    ,getTabooMedicine(state) {
      return state.tabooMedicine;
    },
    getTabooEquipment(state) {
      return state.tabooEquipment;
    },
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 end
    // add 9200 kangjie 20230912 start
    getAddIndMediInfo(state) {
      return state.addIndMediInfo;
    },
    // add 9200 kangjie 20230912 end
    getAllData(state) {
      return state.allData;
    },

  },

  mutations: {
    setTreatDateList(state, response) {
      state.treatDateList = response;
    },
    // add 9200 by kangjie 20230912 start
    setAddIndMediInfo(state,response){
      state.addIndMediInfo = response;
    },
    // add 9200 by kangjie 20230912 end
    /**
     * 一覧ヘッダー表示日付リストを格納
     * @param {Array} dateList
     */
    setDateList(state, dateList) {
      state.dateList = dateList;
    },
    // add FNSI-横展開-日付検索条件 関 start
    // 抽出条件
    setCondition(state, condition) {
      state.condition = condition;
    },
    // add FNSI-横展開-日付検索条件 関 end
    /**
     * 一覧に表示する項目リストを格納
     * @param {Array} dispLayoutItemList
     */
    setDispLayoutItemList(state, dispLayoutItemList) {
      state.dispLayoutItemList = dispLayoutItemList;
    },

    setDialysisStateArray(state, dialysisStateArray) {
      state.dialysisStateArray = JSON.parse(JSON.stringify(dialysisStateArray));
    },
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    setIndEndDate(state, indEndDate) {
      state.indEndDate = indEndDate;
    },
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
    /**
     * DB取得データ(ord_main)を行単位に加工したデータを格納
     * @param {Array} treatmentData
     */
    setTreatmentData(state, treatmentData) {
      state.treatmentData = treatmentData;
    },
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    setRecentTreatmentDate(state, treatmentData) {
      state.recentTreatmentDate = treatmentData;
    },
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    //内部remine 5840  add ljx start
    setTreatmentDataOfPeriod(state, treatmentDataOfPeriod) {
      state.treatmentDataOfPeriod = treatmentDataOfPeriod;
    },
    setTreatmentDataOfPeriodTmp(state, treatmentDataOfPeriodTmp) {
      state.treatmentDataOfPeriodTmp = treatmentDataOfPeriodTmp;
    },
    //内部remine 5840  add ljx end

    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    /**
     * DB取得データ(ord_main)を行単位に加工したデータを格納
     * @param {Array} treatmentDataTmp
     */
    setTreatmentDataTmp(state, treatmentDataTmp) {
      state.treatmentDataTmp = treatmentDataTmp;
    },
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    // setWeekChangeData(state, weekChangeData) {
    //   state.weekChangeData = weekChangeData;
    // },
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end

    /**
     * DB取得データ(pat_exam_main)を行単位に加工したデータを格納
     * @param {Array} examMainData
     */
    setExamMainData(state, examMainData) {
      state.examMainData = examMainData;
    },

    // add FNSI-検体検査の表示の修正 楊 start
    /**
     * DB取得データ(pat_exam_main)
     * @param {Array} examMainData
     */
    setLastExamMainData(state, examMainData) {
      state.lastExamMainData = examMainData;
    },
    // add FNSI-検体検査の表示の修正 楊 end

    /**
     * DB取得データ(rad_exam_main)を行単位に加工したデータを格納
     * @param {Array} radMainData
     */
    setRadMainData(state, radMainData) {
      state.radMainData = radMainData;
    },

    // add FNSI-放射線検査の表示の修正 楊 start
    /**
     * DB取得データ(pat_rad_main)を行単位に加工したデータを格納
     * @param {Array} lastRadDate
     */
    setLastRadDate(state, lastRadDate) {
      state.lastRadDate= lastRadDate;
    },
    // add FNSI-放射線検査の表示の修正 楊 end

    // add FNSI-観察記録を追加 楊 start
    /**
     * DB取得データ(pat_event)を行単位に加工したデータを格納
     * @param {Array} patEventDataList
     */
    setPatEventDataList(state, patEventDataList) {
      state.patEventDataList = patEventDataList;
    },
    // add FNSI-観察記録を追加 楊 end

    // del FNSI-FutreNetWeb+SI課題管理No.5317 李 start
    // // add FNSI-紹介状を追加 楊 start
    // /**
    //  * DB取得データ(pat_unique)を行単位に加工したデータを格納
    //  * @param {Array} patUniqueDataList
    //  */
    // setPatUniqueDataList(state, patUniqueDataList) {
    //   state.patUniqueDataList = patUniqueDataList;
    // },
    // // add FNSI-紹介状を追加 楊 end
    // del FNSI-FutreNetWeb+SI課題管理No.5317 李 end

    // add FNSI-患者イベント（仮）を追加 李 start
    /**
     * DB取得データ(pat_event)を行単位に加工したデータを格納
     * @param {Array} patientDataList
     */
    setPatientDataList(state, patientDataList) {
      state.patientDataList = patientDataList;
    },
    // add FNSI-患者イベント（仮）を追加 李 end
    //7342 add 紹介状のイベント日付が登録日になる 張 start
    setLetterDataList(state,letterDataList){
      state.letterDataList=letterDataList;
    },
    //7342 add 紹介状のイベント日付が登録日になる 張 end
    // add FNSI-処方を追加 姜 start
    /**
     * DB取得データ(pat_event)を行単位に加工したデータを格納
     * @param {Array} patPrescriptionDataList
     */
    setPrescriptionDataList(state, patPrescriptionDataList) {
      state.patPrescriptionDataList = patPrescriptionDataList;
    },
    // add FNSI-処方を追加 姜 end
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    setDataListKeepTreatMethod(state, dataListKeepTreatMethod) {
      state.dataListKeepTreatMethod = dataListKeepTreatMethod;
    },
    setDataListKeepSchedule(state, dataListKeepSchedule) {
      state.dataListKeepSchedule = dataListKeepSchedule;
    },
    setPatIdKeepChgFlg(state, patIdKeepChgFlg) {
      state.patIdKeepChgFlg = patIdKeepChgFlg;
    },
    setPatIdKeep(state, patIdKeep) {
      state.patIdKeep = patIdKeep;
    },
    setDataListKeepTreatCond(state, dataListKeepTreatCond) {
      state.dataListKeepTreatCond = dataListKeepTreatCond;
    },
    setDataListKeepMedicine(state, dataListKeepMedicine) {
      state.dataListKeepMedicine = dataListKeepMedicine;
    },
    setDataListKeepEquipment(state, dataListKeepEquipment) {
      state.dataListKeepEquipment = dataListKeepEquipment;
    },
    setDataListKeepIndComment(state, dataListKeepIndComment) {
      state.dataListKeepIndComment = dataListKeepIndComment;
    },
    setDataListKeepUFRProgram(state, dataListKeepUFRProgram) {
      state.dataListKeepUFRProgram = dataListKeepUFRProgram;
    },
    setDataListKeepNaProgram(state, dataListKeepNaProgram) {
      state.dataListKeepNaProgram = dataListKeepNaProgram;
    },
    setDataListKeepDialysateProgram(state, dataListKeepDialysateProgram) {
      state.dataListKeepDialysateProgram = dataListKeepDialysateProgram;
    },
    setDataListKeepBvUfc(state, dataListKeepBvUfc) {
      state.dataListKeepBvUfc = dataListKeepBvUfc;
    },
    setDataListKeepDiaysisProgram(state, dataListKeepDiaysisProgram) {
      state.dataListKeepDiaysisProgram = dataListKeepDiaysisProgram;
    },
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

    /**
     * ベッドマスタデータを設定
     * @param {Array} mstBedData
     */
    setMstBedData(state, mstBedData) {
      state.mstBedData = mstBedData;
    },
    //add 5619 装置と紐づいていないベッドも表示 張 start
    /**
     * 指定施設にて装置が割りついているベッド+装置情報の一覧を取得する
     */
    setBedAndMachine(state ,bedAndMachine) {
      state.bedAndMachine = bedAndMachine;
    },
    //add 5619 装置と紐づいていないベッドも表示 張 end
    //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
    /**
     * ベッドマスタデータを設定
     * @param {Array} mstAllBedData
     */
    setMstAllBed(state, mstAllBedData) {
      state.mstAllBedData = mstAllBedData;
    },
    //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end

    /**
     * クールマスタデータを設定
     * @param {Array} mstKurData
     */
    setMstKurData(state, mstKurData) {
      state.mstKurData = mstKurData;
    },

    /**
     * 治療方法マスタデータを設定
     * @param {Array} mstTreatmentData
     */
    setMstTreatmentData(state, mstTreatmentData) {
      state.mstTreatmentData = mstTreatmentData;
    },

    /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
    addMstTreatmentData(state, mstTreatmentData) {
      const baseList = Array.isArray(state.mstTreatmentData) ? state.mstTreatmentData : [];
      const addList = Array.isArray(mstTreatmentData) ? mstTreatmentData : [];
      const keySet = new Set(baseList.map(item => item?.treatmentCd));
      const uniqueAddList = addList.filter(item => {
        const key = item?.treatmentCd;
        if (keySet.has(key)) {
          return false;
        }
        keySet.add(key);
        return true;
      });
      state.mstTreatmentData = [...baseList, ...uniqueAddList];
    },
    addMstProcedureData(state, mstProcedureData) {
      const baseList = Array.isArray(state.mstProcedureData) ? state.mstProcedureData : [];
      const addList = Array.isArray(mstProcedureData) ? mstProcedureData : [];
      const keySet = new Set(baseList.map(item => item?.procedureCd));
      const uniqueAddList = addList.filter(item => {
        const key = item?.procedureCd;
        if (keySet.has(key)) {
          return false;
        }
        keySet.add(key);
        return true;
      });
      state.mstProcedureData = [...baseList, ...uniqueAddList];
    },
    addMstMedicateTimingData(state, mstMedicateTimingData) {
      const baseList = Array.isArray(state.mstMedicateTimingData) ? state.mstMedicateTimingData : [];
      const addList = Array.isArray(mstMedicateTimingData) ? mstMedicateTimingData : [];
      const keySet = new Set(baseList.map(item => item?.medicateTimingCd));
      const uniqueAddList = addList.filter(item => {
        const key = item?.medicateTimingCd;
        if (keySet.has(key)) {
          return false;
        }
        keySet.add(key);
        return true;
      });
      state.mstMedicateTimingData = [...baseList, ...uniqueAddList];
    },
    addMstMedicineMixData(state, mstMedicineMixData) {
      const baseList = Array.isArray(state.mstMedicineMixData) ? state.mstMedicineMixData : [];
      const addList = Array.isArray(mstMedicineMixData) ? mstMedicineMixData : [];
      const keySet = new Set(baseList.map(item => item?.medicineMixCd));
      const uniqueAddList = addList.filter(item => {
        const key = item?.medicineMixCd;
        if (keySet.has(key)) {
          return false;
        }
        keySet.add(key);
        return true;
      });
      state.mstMedicineMixData = [...baseList, ...uniqueAddList];
    },
    /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
     /**
     * 治療方法マスタ削除データを設定
     * @param {Array} mstTreatmentData
     */
      setMstTreatmentDataIsDel(state, mstTreatmentDataIsDel) {
        state.mstTreatmentDataIsDel = mstTreatmentDataIsDel;
      },
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

    /**
     * VAマスタデータを設定
     * @param {Array} mstVaData
     */
    setMstVaData(state, mstVaData) {
      state.mstVaData = mstVaData;
    },

    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 start
    /**
     * VAマスタデータを設定(削除されたを含む)
     * @param {Array} mstVaDelData
     */
    setMstVaDelData(state, mstVaDelData) {
      state.mstVaDelData = mstVaDelData;
    },
    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 end

    /**
     * ダイアライザマスタデータを設定
     * @param {Array} mstDialyzerData
     */
    setMstDialyzerData(state, mstDialyzerData) {
      state.mstDialyzerData = mstDialyzerData;
    },

    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 start
    /**
     * ダイアライザマスタデータを設定(削除されたを含む)
     * @param {Array} mstDialyzerDelData
     */
    setMstDialyzerDelData(state, mstDialyzerDelData) {
      state.mstDialyzerDelData = mstDialyzerDelData;
    },
    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 end

    /**
     * ダイアライザマスタデータを設定（禁忌アレルギー込み）
     * @param {Array} mstDialyzerTabooAllergyData
     */
    setMstDialyzerTabooAllergyData(state, mstDialyzerTabooAllergyData) {
      state.mstDialyzerTabooAllergyData = mstDialyzerTabooAllergyData;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    setMstDialyzerTabooAllergyDeletedData(state, mstDialyzerTabooAllergyDeletedData) {
      state.mstDialyzerTabooAllergyDeletedData = mstDialyzerTabooAllergyDeletedData;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 薬剤マスタデータを設定
     * @param {Array} mstMedicineData
     */
    setMstMedicineData(state, mstMedicineData) {
      state.mstMedicineData = mstMedicineData;
    },

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    /**
     * 薬剤マスタデータを設定（削除された薬剤を含む）
     * @param {Array} mstMedicineIncludeDeletedData
     */
    setMstMedicineIncludeDeletedData(state, mstMedicineIncludeDeletedData) {
      state.mstMedicineIncludeDeletedData = mstMedicineIncludeDeletedData;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 薬剤マスタデータを設定（禁忌アレルギー込み）
     * @param {Array} mstMedicineTabooAllergyData
     */
    setMstMedicineTabooAllergyData(state, mstMedicineTabooAllergyData) {
      state.mstMedicineTabooAllergyData = mstMedicineTabooAllergyData;
    },

    // add FNSI-期限切れ削除済みと表示するの修正 李 start
    /**
     * 薬剤マスタデータを設定（削除された薬剤を含む）
     * @param {Array} mstMedicineAllergyData
     */
    setMstMedicineAllergy(state, mstMedicineAllergyData) {
      state.mstMedicineAllergyData = mstMedicineAllergyData;
    },
    // add FNSI-期限切れ削除済みと表示するの修正 李 end

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    /**
     * 調製薬剤マスタデータを設定（削除された薬剤を含む）
     * @param {Array} mstMedicineMixData
     */
    setMstMedicineMixIncludeDeletedData(state, mstMedicineMixIncludeDeletedData) {
      state.mstMedicineMixIncludeDeletedData = mstMedicineMixIncludeDeletedData;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 調製薬剤マスタデータを設定
     * @param {Array} mstMedicineMixData
     */
    setMstMedicineMixData(state, mstMedicineMixData) {
      state.mstMedicineMixData = mstMedicineMixData;
    },

    /**
     * 調製薬剤マスタデータを設定（禁忌アレルギー込み）
     * @param {Array} mstMedicineMixTabooAllergyData
     */
    setMstMedicineMixTabooAllergyData(state, mstMedicineMixTabooAllergyData) {
      state.mstMedicineMixTabooAllergyData = mstMedicineMixTabooAllergyData;
    },

    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 starta
    /**
     * 調製薬剤マスタデータ（削除された薬剤を含む）
     * @param {Array} mstMedicineMixAllergyData
     */
    setMstMedicineMixAllergyData(state, mstMedicineMixAllergyData) {
      state.mstMedicineMixAllergyData = mstMedicineMixAllergyData;
    },
    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

    /**
     * 薬剤分類マスタデータを設定
     * @param {Array} mstMedicineClassData
     */
    setMstMedicineClassData(state, mstMedicineClassData) {
      state.mstMedicineClassData = mstMedicineClassData;
    },

    /**
     * 医療材料マスタデータを設定
     * @param {Array} mstEquipmentData
     */
    setMstEquipmentData(state, mstEquipmentData) {
      state.mstEquipmentData = mstEquipmentData;
    },

    /**
     * 医療材料マスタデータを設定（禁忌アレルギー込み）
     * @param {Array} mstEquipmentTabooAllergyData
     */
    setMstEquipmentTabooAllergyData(state, mstEquipmentTabooAllergyData) {
      state.mstEquipmentTabooAllergyData = mstEquipmentTabooAllergyData;
    },

    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
    /**
     * 医療材料マスタデータ（削除された薬剤を含む）
     * @param {Array} mstEquipmentAllergyData
     */
    setMstEquipmentAllergy(state, mstEquipmentAllergyData) {
      state.mstEquipmentAllergyData = mstEquipmentAllergyData;
    },
    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

    // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
    /**
     * 医療材料分類マスタデータを設定
     * @param {Array} mstEquipmentClassData
     */
    setMstEquipmentClassData(state, mstEquipmentClassData) {
      state.mstEquipmentClassData = mstEquipmentClassData;
    },
    // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end

    /**
     * 手技マスタデータを設定
     * @param {Array} mstProcedureData
     */
    setMstProcedureData(state, mstProcedureData) {
      state.mstProcedureData = mstProcedureData;
    },

    /**
     * 投与タイミングマスタデータを設定
     * @param {Array} mstMedicateTimingData
     */
    setMstMedicateTimingData(state, mstMedicateTimingData) {
      state.mstMedicateTimingData = mstMedicateTimingData;
    },

    // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 start
    /**
     * 投薬支援マスタデータを設定
     * @param {Array} mstMedicineSupportData
     */
    setMstMedicineSupportData(state, mstMedicineSupportData) {
      state.mstMedicineSupportData = mstMedicineSupportData;
    },

    /**
     * 選択中投薬支援マスタを設定
     */
    setSelectedMedicineSupport(state, selectedMedicineSupport) {
      state.selectedMedicineSupport = selectedMedicineSupport;
    },
    // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 end

    /**
     * 指示・実績表示切替の設定
     */
    setShowIndRst(state, selectShowIndRst) {
      state.selectIndRst = selectShowIndRst;
    },

    /**
     * 一覧上の期間切替の設定
     */
    setSelectedPeriod(state, selectedPeriod) {
      state.selectedPeriod = selectedPeriod;
    },

    /**
     * 基準日を格納
     */
    commmitTreatDate(state, treatDate) {
      state.treatDate = treatDate;
    },

    setOrdNoList(state, ordNoList) {
      state.ordNoList = ordNoList;
    },

    setIsDie(state, isDie) {
      state.is_die = isDie;
    },
    setIsDieMessage(state, isDieMessage) {
      state.isDieMessage = isDieMessage;
    },

    setTickPositions(state, rec) {
      state.tickPositions = JSON.parse(JSON.stringify(rec));
    },

    setPhysicalInfo(state, physicalInfo) {
      state.physicalInfo = physicalInfo.sort(
        // 登録日が新しいもの順にソートする
        // @ts-ignore
        (a, b) => moment(b.exam_date) - moment(a.exam_date)
      );
    },

    setSelectedLayout(state, layout) {
      state.selectedLayout = layout;
    },

    setSelectedCondition(state, selectedCondition) {
      state.selectedCondition = selectedCondition;
    },

    // add 更新中の予定を表示する様にする。 李 start
    setScrollBarPositioningOrdNo(state, scrollBarPositioningOrdNo) {
      state.scrollBarPositioningOrdNo = scrollBarPositioningOrdNo;
    },
    // add 更新中の予定を表示する様にする。 李 end
    //add FNSI内容修正 バグ284、286 姜 start
    setOrdNoMediList(state, ordNoMediList) {
      state.ordNoMediList = ordNoMediList;
    },
    //add FNSI内容修正 バグ284、286 姜 end

    // add FNSI-予定内容遅延問題対応 李 start
    setIndPlanCreateDate(state, indPlanCreateDate) {
      state.indPlanCreateDate = indPlanCreateDate;
    },
    setResMniMonitors(state, resMniMonitors) {
      state.resMniMonitors = resMniMonitors;
    },
    setMntMachineStates(state, mntMachineStates) {
      state.mntMachineStates = mntMachineStates;
    },
    // add FNSI-予定内容遅延問題対応 李 end

    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    setPriorToChangeList(state, priorToChangeList) {
      state.priorToChangeList = priorToChangeList;
    },

    setAfterToChangeList(state, afterToChangeList) {
      state.afterToChangeList = afterToChangeList;
    }
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
    ,setTabooMedicine(state, tabooMedicine) {
      state.tabooMedicine = tabooMedicine;
    }
    ,setTabooEquipment(state, tabooEquipment) {
      state.tabooEquipment = tabooEquipment;
    },
//add FutreNetWeb+SI課題管理 no.6422 劉全航 end
    setAllData(state, dataList) {
      state.allData = dataList;
    },
    /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
    setPatTabooAllergy(state, patTabooAllergy) {
      state.patTabooAllergy = patTabooAllergy;
    },
    /* add by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */
  },

  actions: {
    /**
     * 一覧表示データの初期化
     */
    // add FNSI-横展開-日付検索条件 関 start
    setCondition({ commit }, condition) {
      // 抽出条件セット
      commit("setCondition", condition);
    },
    // add FNSI-横展開-日付検索条件 関 end
    clearTreatmentData({ commit }) {
      commit("setTreatmentData", []);
    },
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
    clearrecentTreatmentDate({ commit }) {
      commit("setRecentTreatmentDate", []);
    },
    // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    setIndEndDate({ commit }, indEndDate) {
      commit("setIndEndDate", indEndDate);
    },
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
    //add FutreNetWeb+SI課題管理 no.6422 劉全航 start
    setTabooMedicine({ commit }, tabooMedicine) {
      commit("setTabooMedicine", tabooMedicine);
    },
    setTabooEquipment({commit}, tabooEquipment) {
      commit("setTabooEquipment", tabooEquipment);
    },
//add FutreNetWeb+SI課題管理 no.6422 劉全航 end
    setDialysisStateArray({ commit }, dialysisStateArray) {
      // コミット
      commit("setDialysisStateArray", dialysisStateArray);
    },

    /**
     * 一覧ヘッダーに表示する日付リストの設定
     * @param {String} startDay 表示開始日
     * @param {String} endDay 表示終了日
     * @param {String} period 期間
     */
    async setDateList({ commit }, { startDay, endDay, period }) {
      // 日付(YYYYMMDD形式)をリストに追加
      const dayList = [];
      switch (period) {
        case "1":
        case "2":
        case "3":
          for (let i = 0; ; i++) {
            // // 1～足していく(最初は0)
            const addDay = moment(startDay)
              .add(i, "days")
              .format("YYYYMMDD");

            // リストに追加
            dayList.push(addDay);

            // 表示終了日と同じ日付になったら終了
            if (addDay === endDay) {
              break;
            }
          }
          break;
        case "4":
          for (let i = 0; i < 12; i++) {
            if (i === 0) {
              dayList.push(moment(startDay).format("YYYYMMDD"));
            } else {
              dayList.push(
                moment(startDay)
                  .add(i, "weeks")
                  .format("YYYYMMDD")
              );
            }
          }
          break;
        case "5":
          for (let i = 0; i < 6; i++) {
            if (i === 0) {
              dayList.push(moment(startDay).format("YYYYMMDD"));
            } else {
              dayList.push(
                moment(startDay)
                  .add(i, "months")
                  .format("YYYYMMDD")
              );
            }
          }
          break;
        case "6":
          for (let i = 0; i < 12; i++) {
            if (i === 0) {
              dayList.push(moment(startDay).format("YYYYMMDD"));
            } else {
              dayList.push(
                moment(startDay)
                  .add(i, "months")
                  .format("YYYYMMDD")
              );
            }
          }
          break;
        case "7":
          for (let i = 0; i < 3; i++) {
            if (i === 0) {
              dayList.push(moment(startDay).format("YYYYMMDD"));
            } else {
              dayList.push(
                moment(startDay)
                  .add(i, "year")
                  .format("YYYYMMDD")
              );
            }
          }
          break;
      }

      // コミット
      commit("setSelectedPeriod", period);
      commit("setDateList", dayList);
    },

    /**
     * 治療日のみ表示時 一覧ヘッダーに表示する日付リストの設定
     * @param {Array} dateList 表示する日付リスト
     */
    async setIsTreatmentOnlyDateList({ commit }, { dateList }) {
      // コミット
      commit("setDateList", dateList);
    },

    /**
     * 指定施設にて装置が割りついているベッド+装置情報の一覧を取得する
     */
    async getBedAndMachine({ commit }, { facilityCd }) {
      // API実行
      // TODO: MstGetter.jsでは未実装のため、一時的に下記で実施(形式が他と異なっているため)
      const response = await ApiHelper.get("/mstInfo/getByFacilityCd", {
        facility_cd: facilityCd
      }).catch(err => {
        throw err;
      });

      // コミット
      commit("setBedAndMachine", response.data);
    },
    //add 5619 装置と紐づいていないベッドも表示 張 end
    //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
    async getMstBedAll({ commit }, { facilityCd }) {
      // API実行
      // TODO: MstGetter.jsでは未実装のため、一時的に下記で実施(形式が他と異なっているため)
      const response = await ApiHelper.get("/mstInfo/selectAllByFacilityCd", {
        facility_cd: facilityCd
      }).catch(err => {
        throw err;
      });
      //mod FNSI-7238 劉全航 start
      response.data.sort((a, b) =>a.bedCd - b.bedCd);
      //mod FNSI-7238 劉全航 end
      // コミット
      commit("setMstAllBed", response.data);
    },
    //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end

    /**
     * クールマスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstKur({ commit }, { facilityCd }) {
      // // API実行
      // const response = await kur(facilityCd).catch(err => {
      //   throw err;
      // });
      // TODO: 上記で用意されている関数ではエラーとなるため、一時的に下記で実施
      const response = await ApiHelper.get("/mstInfo/mstKur", {
        facility_cd: facilityCd,
        is_del: "0"
      }).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstKurData", response.data);
    },

    /**
     * 治療方法マスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstTreatment({ commit }, { facilityCd }) {
      // API実行
      const response = await treatment(facilityCd).catch(err => {
        throw err;
      });

      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
      const treatmentDelData = await treatmentDel(facilityCd).catch(err => {
        throw err;
      });
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

      // コミット
      commit("setMstTreatmentData", response);
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
      commit("setMstTreatmentDataIsDel", treatmentDelData);
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
    },

    /**
     * VAマスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstVa({ commit }, { facilityCd }) {
      // API実行
      const response = await va(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstVaData", response);
    },

    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 start
    /**
     * VAマスタを取得(削除されたを含む)
     * @param {string} facilityCd 施設コード
     */
    async getMstDelVa({ commit }, { facilityCd }) {
      // API実行
      const requestParam = {
        facilityCd: facilityCd
      };

      const response = await ApiHelper.get("/mstInfo/mstVaDel", requestParam)
        .catch(err => {
          throw err;
        });

      // コミット
      commit("setMstVaDelData", response.data);
    },
    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 end

    /**
     * ダイアライザマスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstDialyzer({ commit }, { facilityCd }) {
      // API実行
      const response = await dialyzer(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstDialyzerData", response);
    },

    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 start
    /**
     * ダイアライザマスタを取得(削除されたを含む)
     * @param {string} facilityCd 施設コード
     */
    async getMstDialyzerDel({ commit }, { facilityCd }) {
      // API実行
      const requestParam = {
        facilityCd: facilityCd
      };

      const response = await ApiHelper.get("/mstInfo/mstDialyzerIncludeDeleted", requestParam)
        .catch(err => {
          throw err;
        });

      // コミット
      commit("setMstDialyzerDelData", response.data);
    },
    // add FNSI-FutreNetWeb+SI課題管理No.4869 李 end

    /**
     * ダイアライザマスタを取得（禁忌アレルギーマスタ参照）
     * @param {string} patId 患者ID
     */
    async getMstDialyzerTabooAllergy({ commit }, { patId }) {
      // API実行
      const response = await dialyzerTabooAllergy(patId).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstDialyzerTabooAllergyData", response);
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getMstDialyzerTabooAllergyDeleted({ commit }, { patId }) {
      // API実行
      const response = await dialyzerTabooAllergyDeleted(patId).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstDialyzerTabooAllergyDeletedData", response);
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 薬剤マスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstMedicine({ commit }, { facilityCd }) {
      // API実行
      const response = await medicine(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineData", response);
    },

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    /**
     * 薬剤マスタを取得(削除された薬剤を含む)
     * @param {string} facilityCd 施設コード
     */
    async getMstMedicineIncludeDeleted({ commit }, { facilityCd }) {
      // API実行
      const response = await medicineIncludeDeleted(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineIncludeDeletedData", response);
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 薬剤マスタを取得（禁忌アレルギーマスタ参照）
     * @param {string} patId 患者ID
     */
    async getMstMedicineTabooAllergy({ commit }, { patId }) {
      // API実行
      const response = await medicineTabooAllergy(patId).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineTabooAllergyData", response);
    },

    // add FNSI-期限切れ削除済みと表示するの修正 李 start
    /**
     * 薬剤マスタを取得(削除された薬剤を含む)
     * @param {string} patId 患者ID
     */
    async getMstMedicineAllergy({ commit }, { patId, is_Del_Flg }) {
      // API実行
      const response = await medicineAllergy(patId, is_Del_Flg).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineAllergy", response);
    },
    // add FNSI-期限切れ削除済みと表示するの修正 李 end

    /**
     * 調製薬剤マスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstMedicineMix({ commit }, { facilityCd }) {
      // API実行
      const response = await medicineMix(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineMixData", response);
    },

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    /**
     * 調製薬剤マスタを取得(削除された薬剤を含む)
     * @param {string} facilityCd 施設コード
     */
    async getMstMedicineMixIncludeDeleted({ commit }, { facilityCd }) {
      // API実行
      const response = await medicineMixIncludeDeleted(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineMixIncludeDeletedData", response);
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * 調製薬剤マスタを取得（禁忌アレルギーマスタ参照）
     * @param {string} patId 患者ID
     */
    async getMstMedicineMixTabooAllergy({ commit }, { patId }) {
      // API実行
      const response = await medicineMixTabooAllergy(patId).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineMixTabooAllergyData", response);
    },

    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 starta
    /**
     * 調製薬剤マスタデータ（削除された薬剤を含む）
     * @param {string} patId 患者ID
     */
    async getMstMedicineMixAllergyData({ commit }, { patId, isDelFlg }) {
      // API実行
      const response = await medicineMixAllergy(patId, isDelFlg).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineMixAllergyData", response);
    },
    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

    /**
     * 薬剤分類マスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstMedicineClass({ commit }, { facilityCd }) {
      // API実行
      const response = await medicineClass(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineClassData", response);
    },

    /**
     * 医療材料マスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstEquipment({ commit }, { facilityCd }) {
      // API実行
      const response = await equipment(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstEquipmentData", response);
    },

    /**
     * 医療材料マスタを取得（禁忌アレルギーマスタ参照）
     * @param {string} patId 患者ID
     */
    async getMstEquipmentTabooAllergy({ commit }, { patId }) {
      // API実行
      const response = await equipmentTabooAllergy(patId).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstEquipmentTabooAllergyData", response);
    },

    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
    /**
     * 医療材料マスタデータ（削除された薬剤を含む）
     * @param {string} patId 患者ID
     */
    async getMstEquipmentAllergy({ commit }, { patId, isDelFlg }) {
      // API実行
      const response = await equipmentAllergy(patId, isDelFlg).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstEquipmentAllergy", response);
    },
    // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

    // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
    /**
     * 医療材料分類マスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstEquipmentClass({ commit }, { facilityCd }) {
      // API実行
      const response = await equipmentClass(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstEquipmentClassData", response);
    },
    // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end

    /**
     * 手技マスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstProcedure({ commit }, { facilityCd }) {
      // API実行
      const response = await procedure(facilityCd).catch(err => {
        throw err;
      });
      // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
      const tableName = "mst_procedure";
      const mstselector = await ApiHelper.get(
        `/report_designer/master/${tableName}`
      ).catch(err => {
        throw err;
      });

      for (let i = 0; i < response.length; i++) {
        let index = mstselector.data.findIndex(el => el.code == response[i].procedureCd);
        response[i].index = index;
      }
      // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
      // コミット
      commit("setMstProcedureData", response);
    },

    /**
     * 投与タイミングマスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstMedicateTiming({ commit }, { facilityCd }) {
      // API実行
      const response = await medicateTiming(facilityCd).catch(err => {
        throw err;
      });
      // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
      const tableName = "mst_medicate_timing";
      const mstselector = await ApiHelper.get(
        `/report_designer/master/${tableName}`
      ).catch(err => {
        throw err;
      });

      for (let i = 0; i < response.length; i++) {
        let index = mstselector.data.findIndex(el => el.code == response[i].medicateTimingCd);
        response[i].index = index;
      }
      // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
      // コミット
      commit("setMstMedicateTimingData", response);
    },

    // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 start
    /**
     * 投薬支援マスタを取得
     * @param {string} facilityCd 施設コード
     */
    async getMstMedicineSupport({ commit }, { facilityCd }) {
      // API実行
      const response = await getMstSupportSettingData(facilityCd).catch(err => {
        throw err;
      });

      // コミット
      commit("setMstMedicineSupportData", response.data.filter(p => p.isDisp === "1" && p.isDel === "0"));
    },
    // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 end

    /**
     * 患者経過総合ビューアレイアウトマスタを取得し、表示用に加工
     * @param {string} facilityCd 施設コード
     */
    async getDispLayoutItemList({ commit }, { facilityCd }) {
      // API実行
      const response = await mstPatViewerLayout(facilityCd)
        .catch(err => {
          throw err;
        });
      // 取得失敗 or 0件の場合は空のリストをコミット
      if (!response || 0 === response.length) {
        commit("setDispLayoutItemList", []);
        return;
      }

      // 施設拡張設定を取得(ビューアレイアウトマスタ内非表示項目取得)
      const responseFacility = await sendRequestGetMstFacilityByCd(facilityCd)
        .catch(error => {
          throw error;
        });
      let advancedSettings = {};
      if (responseFacility?.data?.advancedSettings) {
        advancedSettings = JSON?.parse(
          responseFacility.data.advancedSettings
        );
      }

      let advancedAdditionInfo = false; // 施設設定 > 拡張機能 > 加算情報の有効状態
      let advancedDispcomponent = [];
      if (advancedSettings?.func_advcds) {
        const isDispBvUfc = advancedSettings.func_advcds.some(
          setting => setting.func_advcd === ADVANCED_SETTINGS.BV_UFC
        );
        if (!isDispBvUfc) {
          advancedDispcomponent.push("bv-ufc");
        }

        const isDAProgram = advancedSettings.func_advcds.some(
          setting =>
            setting.func_advcd === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
        );
        if (!isDAProgram) {
          advancedDispcomponent.push("diaysis-program");
        }

        const isDispAdditionInfo = advancedSettings.func_advcds.some(
          setting => setting.func_advcd === ADVANCED_SETTINGS.ADDITION_INFO
        );
        if (!isDispAdditionInfo) {
          advancedAdditionInfo = true;
        }
      }

      // add FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 start
      const vitalMonitorGraphInout = [];
      // add FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 end

      //  取得したレイアウトマスタのレコード数でループ
      response.forEach(eleMstLayout => {
        // TODO: カスタムコントロールを使用する場合はこの設定が必要
        // // 表示条件ポップオーバー用に値を設定
        // eleMstLayout.value = eleMstLayout.layoutCd;
        // eleMstLayout.displayValue = eleMstLayout.layoutName;

        // 表示項目がnullの場合この後の処理でエラーとなるので、空文字に置き換える
        if (eleMstLayout.dispItemInfo === null) {
          eleMstLayout.dispItemInfo = "[]";
        }

        eleMstLayout.dispItemInfo = JSON.parse(eleMstLayout.dispItemInfo);

        eleMstLayout.dispItemInfo.forEach(eleMstCategory => {
          // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 start
          if (eleMstCategory.categoryNo === 1028 && eleMstCategory.hasOwnProperty("medicineGroupCd") && eleMstCategory.medicineGroupCd) {
            commit("setSelectedMedicineSupport", eleMstCategory.medicineGroupCd);
            return;
          }
          // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 end

          // 患者経過総合ビューアレイアウトマスタ定義(Json)から対象カテゴリの定義を抽出
          const mstCategoryDefine = mstPatViewerLayoutDefine.find(
            eleCategoryDefine => {
              return eleMstCategory.categoryNo === eleCategoryDefine.categoryNo;
            }
          );

          // 定義ファイルをベースに抽出しているので存在しないことはあり得ないがチェックは行う
          if (!mstCategoryDefine) {
            return;
          }

          // カテゴリ名、対象コンポーネント名を追加設定
          eleMstCategory.categoryName = mstCategoryDefine.categoryName;
          eleMstCategory.component = mstCategoryDefine.component;

          // 条件付データセット
          eleMstCategory.categoryItem = eleMstCategory.categoryItem.filter(
            item => !advancedDispcomponent.includes(item.component));

          // 施設設定 > 拡張機能 > 加算情報の有効状態 に応じて判定
          if (advancedAdditionInfo && eleMstCategory.categoryNo === 1) {
            eleMstCategory.categoryItem = eleMstCategory.categoryItem.filter(item => item.subCategoryNo !== 74);
          }

          //  categoryItem(カテゴリに紐づくサブカテゴリ数)でループ
          eleMstCategory.categoryItem.forEach(eleMstSubCategory => {
            // 患者経過総合ビューアレイアウトマスタ定義(Json)から対象サブカテゴリの定義を抽出
            let mstSubCategoryDefine = mstCategoryDefine.categoryItem.find(
              eleSubCategoryDefine => {
                return (
                  eleMstSubCategory.subCategoryNo ===
                  eleSubCategoryDefine.subCategoryNo
                );
              }
            );

            // 定義ファイルをベースに抽出しているので存在しないことはあり得ないがチェックは行う
            // または定義ファイル上はいるが、画面表示が選択肢として不可状態の項目
            if (!mstSubCategoryDefine) {
              return;
            }

            //カテゴリNoが1(治療情報)、かつ、サブカテゴリNoが30(治療時間(実績))の場合、項目名称を治療時間に変更
            if(mstCategoryDefine.categoryNo === 1 && mstSubCategoryDefine.subCategoryNo === 30){
              mstSubCategoryDefine.subCategoryName = "治療時間";
              mstSubCategoryDefine.subCategoryItem[0].itemName = "治療時間";
            }

            // サブカテゴリ名、対象コンポーネント名を設定
            eleMstSubCategory.subCategoryName =
              mstSubCategoryDefine.subCategoryName;
            eleMstSubCategory.component = mstSubCategoryDefine.component;

            // add FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 start
            if (eleMstSubCategory.subClassify) {
              // レイアウト別情報
              const eleMstLayoutInout = vitalMonitorGraphInout.find(findItem => {
                return (eleMstLayout.layoutCd === findItem.layoutCd);
              });

              // 存在しない場合⇒追加
              if (!eleMstLayoutInout) {
                vitalMonitorGraphInout.push({
                  layoutCd: eleMstLayout.layoutCd,
                  vitalInout: deepCopy(vitalMonitorGraphInoutDefine)
                });
              }

              vitalMonitorGraphInout.forEach(mstInout => {
                // レイアウト別情報
                if (eleMstLayout.layoutCd === mstInout.layoutCd) {
                  mstInout.vitalInout.forEach(io => {
                    if (io.subClassify === eleMstSubCategory.subClassify) {
                      const existSub = io.categoryItem.find(findItem => {
                        return (eleMstSubCategory.subCategoryNo === findItem.subCategoryNo);
                      });

                      if (!existSub) {
                        io.categoryItem.push({
                          // add FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 start
                          component: eleMstSubCategory.component,
                          drugStatus: eleMstSubCategory.drugStatus,
                          graphMax: eleMstSubCategory.graphMax,
                          graphMin: eleMstSubCategory.graphMin,
                          treatmentStatus: eleMstSubCategory.treatmentStatus,
                          inspectionStatus: eleMstSubCategory.inspectionStatus,
                          // add FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 end
                          subCategoryItem: deepCopy(eleMstSubCategory.subCategoryItem),
                          subCategoryName: io.categoryName,
                          subCategoryNo: eleMstSubCategory.subCategoryNo,
                          subClassify: eleMstSubCategory.subClassify
                        });
                      }
                    }
                  });
                }
              });
              return;
            }
            // add FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 end

            //  subCategoryItem(サブカテゴリに紐づく項目数)でループ
            eleMstSubCategory.subCategoryItem.forEach(eleItem => {
              const mstItemDefine = mstSubCategoryDefine.subCategoryItem.find(
                eleItemDefine => {
                  // 患者経過総合ビューアレイアウトマスタ定義(Json)から対象項目の定義を抽出
                  return eleItem.itemNo === eleItemDefine.itemNo;
                }
              );

              // 定義ファイルをベースに抽出しているので存在しないことはあり得ないがチェックは行う
              if (!mstItemDefine) {
                return;
              }

              // 項目の定義情報をコピー(マージ)する
              merge(eleItem, mstItemDefine);
            });
          });
        });
      });

      // コミット
      // mod FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 start
      // commit("setDispLayoutItemList", response);

      const responseVital = [];
      response.forEach(eleMstLayout => {
        const dispItemInfo = [];
        eleMstLayout.dispItemInfo.forEach(eleMstCategory => {
          const categoryItem = [];
          eleMstCategory.categoryItem.forEach(eleMstSubCategory => {
            if (eleMstSubCategory.subClassify) {
              vitalMonitorGraphInout.forEach(mstInout => {
                if (eleMstLayout.layoutCd === mstInout.layoutCd) {
                  mstInout.vitalInout.forEach(io => {
                    if (io.categoryNo === eleMstSubCategory.subCategoryNo) {
                      categoryItem.push(io);
                    }
                  });
                }
              });
            } else {
              categoryItem.push(eleMstSubCategory);
            }
          });
          eleMstCategory.categoryItem = categoryItem;
          dispItemInfo.push(eleMstCategory);
        });
        eleMstLayout.dispItemInfo = dispItemInfo;
        responseVital.push(eleMstLayout);
      });
      commit("setDispLayoutItemList", responseVital);
      // mod FNSI-グラフ３軸表示対応「230」バイタル・モニタグラフ分（入室～退室） 周 end
    },

    // add 9200 by kangjie 20230912 start
    /**
     *9200
     * @param dispatch
     * @param commit
     * @param facilityCd 施設コード
     * @param patId 患者ID
     * @param baseDate 基準日の格納
     * @returns {Promise<void>}
     */
    /* upd by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --start */
    async getOrdMainOfIndMediInfo (
        { dispatch, commit },
        { facilityCd, patId, startTime, patShareMode }
    ){
      const sendData = {};
      sendData.facilityCd = facilityCd;
      sendData.patId = patId;
      sendData.startTime = startTime;
      sendData.patShareMode = patShareMode;
      const response = await ApiHelper.post("/mainData/sharingInfo/getOrdMainOfIndMediInfo",sendData).catch(err =>{
        throw err;
      });
      commit("setAddIndMediInfo",response.data);
    },
    /* upd by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --end */

    // add 9200 by kangjie 20230912 end
    /**
     * 治療情報(ord_main)の取得
     * @param {string} facilityCd 施設コード
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     * @param {string} endDay 抽出終了日(YYYYMMDD形式)
     * @param {string} weekPattern 取得曜日(※全曜日の場合、[{'text': '全','done': true,'value': 0}]) ※要検討
     */
    async getOrdMain(
      { dispatch, commit },
      { facilityCd, patId, startDay, endDay, weekPattern }
    ) {
      // APIの引数作成
      const sendData = {};
      // 施設コード
      sendData.facility_cd = facilityCd;
      // 患者ID
      sendData.pat_id = patId;
      // 抽出開始日
      sendData.ind_start_date = startDay;
      // 抽出終了日
      sendData.ind_end_date = endDay;
      // 曜日パターン
      sendData.week_pattern = weekPattern;


      let startDayTmp = moment(startDay).add(-7, "days").format("YYYYMMDD");
      let endDayTmp = moment(endDay).add(7, "days").format("YYYYMMDD");
      /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
      const patientShareMode = store.getters["account-edit/getPatientShareMode"];
      const patientShareFacilityCdMode = store.getters["account-edit/getPatientShareFacilityCdMode"];
      // 0: マージ  1: 自施設
      const patShareMode = patientShareMode == 0 && !patientShareFacilityCdMode ? 0 : 1;
      const sendDataTmp = {};
      // 施設コード
      sendDataTmp.facility_cd = facilityCd;
      // 患者ID
      sendDataTmp.pat_id = patId;
      // 曜日パターン
      sendDataTmp.week_pattern = weekPattern;
      // 抽出開始日
      sendDataTmp.ind_start_date = startDayTmp;
      // 抽出終了日
      sendDataTmp.ind_end_date = endDayTmp;
      sendDataTmp.patShareMode = patShareMode;
      const responseTmp = await ApiHelper.post(
        // "/mainData/sharingInfo/TreatDateList",
        "/mainData/sharingInfo/getOrdMainInfo",
        sendDataTmp
      ).catch(err => {
        throw err;
      });
      /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
      const responsData = responseTmp.data.filter(item => {
        return moment(item.treatDate).isBetween(startDay, endDay, null, '[]');
      });

      //#11397  start
      commit("setAllData", responsData);
      //#11397  end

      let resMniMonitors = [];
      if (responsData && responsData.length > 0) {
        let mntMachineStates = [];
        let ordNoList = [];
        let bodyDataList = [];
        /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
        let ordNoToShrList = [];
        let monitorsReqList = [];
        for (const ordInfo of responsData) {
          monitorsReqList.push({
              "facility_cd": ordInfo.facilityCd, "ord_no": ordInfo.ordNo
            });
          if (ordInfo.readOnly) {
            ordNoToShrList.push(ordInfo.ordNo);
          }
          ordNoList.push(ordInfo.ordNo);
          if(ordInfo.rstDialysisState == 3) { // add by shiyw  2024-01-01 #10236 不要なapi呼び出しを減らす：rstDialysisState=3の場合のみ、mnt _ machine _ state.monitor _ dataデータを取得する必要があります
            bodyDataList.push({
              "facility_cd": ordInfo.facilityCd, "pat_id": ordInfo.patId, "ord_no": ordInfo.ordNo
            });
          } // add by shiyw  2024-01-01 #10236 不要なapi呼び出しを減らす：rstDialysisState=3の場合のみ、mnt _ machine _ state.monitor _ dataデータを取得する必要があります
        }
        
        if (patShareMode == 0 && ordNoToShrList.length > 0) {
          const shrMstResponse = await ApiHelper.post("/mstInfo/getMstInfoByOrdNo", ordNoToShrList);
          commit("addMstTreatmentData", shrMstResponse.data["mstTreatment"]);
          commit("addMstProcedureData", shrMstResponse.data["mstProcedure"]);
          commit("addMstMedicateTimingData", shrMstResponse.data["mstMedicateTiming"]);
          commit("addMstMedicineMixData", shrMstResponse.data["mstMedicineMix"]);

          // 現在の患者に紐づく共有患者の禁忌情報を取得する
          const patTabooAllergyRes = await ApiHelper.get(`/patInfo/selectPatTabooAllergyByPatId/${facilityCd}/${patId}`);
          commit("setPatTabooAllergy", patTabooAllergyRes.data);
        }
        /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

        if(bodyDataList.length > 0) {
          const mntMachineStateTmp = await ApiHelper.post("/mainData/getMniMonitorByFacilityCdAndPatIdAndOrdNo", bodyDataList);
          let mntMachineStateData = mntMachineStateTmp.data;
          for (const ordInfo of responsData) {
            let mntMachineState = mntMachineStateData.filter(item => {
              return item.ordNo == ordInfo.ordNo;
            });
            mntMachineStates.push({
              ordNo: ordInfo.ordNo,
              mntMachineState: {data: mntMachineState}
            });
          }
        }
        /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start */
        // const  resMniMonitorTmp = await  ApiHelper.get(`/status_list/mni_monitors/${ordNoList}/${facilityCd}`);
        const resMniMonitorTmp = await ApiHelper.post("/status_list/mni_monitors", monitorsReqList);
        /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end */
        let resMniMonitorData = resMniMonitorTmp.data;
        for (const ordInfo of responsData) {
          let resMniMonitor = resMniMonitorData.filter(item => {
            // return item.ordNo == ordInfo.ordNo;
            return item.ord_no == ordInfo.ordNo;
          });
          resMniMonitors.push({
            ordNo: ordInfo.ordNo,
            resMniMonitor: {data: resMniMonitor}
          });
        }

        commit("setResMniMonitors", resMniMonitors);
        commit("setMntMachineStates", mntMachineStates);
      }

      // 患者身体情報も取得
      let physical = [];
      if (patId) {
        /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
        // physical = await sendRequestFindPhysicalInfo(patId).catch(err => {
        physical = await sendRequestFindPhysicalInfo(patId, patShareMode).catch(err => {
          throw err;
        });
        /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
      }

      // 表示用にデータを加工
      const convertRowResult = await dispatch("convertRowTreatData", {
        targetData: responsData,
        physical: physical.data
      });
      // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
      await dispatch("convertRowTreatDataTmp", {
        targetData: responseTmp.data,
        physical: physical.data
      });
      // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

      return {
        treatmentData: convertRowResult?.treatmentData,
        resMniMonitors: resMniMonitors,
      };
    },

    /**
     * 取得した治療情報を行単位に加工
     * @summary 1行目:各日付の1回目の治療予定、2行目:各日付の2回目の治療予定、…)
     * @param {*} context
     * @param {*} payload
     * @param {*} payload.targetData 治療指示・実績情報
     * @param {*} payload.physical 患者身体情報
     */
    async convertRowTreatData({ getters, commit }, payload) {
      // 加工データ格納用(リスト)
      const convertDataList = [];
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      const convertDataList2 = [];
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      // 加工データ格納用(行の雛形構造用)
      const layoutDataRow = {};
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      const layoutDataRow2 = {};
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      // DB取得データ(ord_main)をディープコピーして加工データに使用
      const baseData = deepCopy(payload.targetData);

      // 検索用日付リスト
      const searchDateList = deepCopy(getters.getDateList);
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      const searchDateList2 = deepCopy(getters.getDateList);
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      // 日付をキーとして設定(初期値としてnullと設定)
      searchDateList.forEach(element => {
        layoutDataRow[element] = null;
      });
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      searchDateList2.forEach(element => {
        layoutDataRow2[element] = null;
      });
      !!baseData && baseData.forEach(bData =>{
        if (!(bData.treatDate in layoutDataRow2)) {
          // 将日期添加到对象中
          layoutDataRow2[bData.treatDate] = null;
        }
        if (!searchDateList2.includes(bData.treatDate)) {
          // 将日期添加到数组中
          searchDateList2.push(bData.treatDate);
        }
      })
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 日付をキーとした空データ行を追加
      convertDataList.push(deepCopy(layoutDataRow));
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      convertDataList2.push(deepCopy(layoutDataRow2));
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end

      // 日付リスト分ループ
      // 対象日付の治療情報を抽出し、表示用リストに格納
      searchDateList.forEach(element => {
        // ord_mainデータの治療日と一覧ヘッダーの日付を比較し、一致するデータを抽出
        const filter = baseData.filter(item => {
          // 一致する治療日のデータを抽出
          // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#2。 周 start
          // if (item.treatDate === element) {
          if (item.treatDate === element && item.isDel !== "1") {
            // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#2。 周 end
            return true;
          } else {
            return false;
          }
        });

        for (let i = 0; i < filter.length; i++) {
          // リストに行が存在しない場合、行を追加
          if (!convertDataList[i]) {
            convertDataList.push(deepCopy(layoutDataRow));
          }
          // add FNSI-改修内容 論理削除したの治療情報を修正 楊 start
          if (filter[i].isDel !== "1") {
            // add FNSI-改修内容 論理削除したの治療情報を修正 楊 end
            // 対象行の対象キー(日付)に治療情報を格納
            convertDataList[i][element] = filter[i];
            // add FNSI-改修内容 論理削除したの治療情報を修正 楊 start
          }
          // add FNSI-改修内容 論理削除したの治療情報を修正 楊 end
        }
      });
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // 日付リスト分ループ
      // 対象日付の治療情報を抽出し、表示用リストに格納
      searchDateList2.forEach(element => {
        // ord_mainデータの治療日と一覧ヘッダーの日付を比較し、一致するデータを抽出
        const filter2 = baseData.filter(item => {
          // 一致する治療日のデータを抽出
          // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#2。 周 start
          // if (item.treatDate === element) {
          if (item.treatDate === element && item.isDel !== "1") {
            // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#2。 周 end
            return true;
          } else {
            return false;
          }
        });
        for (let i = 0; i < filter2.length; i++) {
          // リストに行が存在しない場合、行を追加
          if (!convertDataList2[i]) {
            convertDataList2.push(deepCopy(layoutDataRow2));
          }
          // add FNSI-改修内容 論理削除したの治療情報を修正 楊 start
          if (filter2[i].isDel !== "1") {
            // add FNSI-改修内容 論理削除したの治療情報を修正 楊 end
            // 対象行の対象キー(日付)に治療情報を格納
            convertDataList2[i][element] = filter2[i];
            // add FNSI-改修内容 論理削除したの治療情報を修正 楊 start
          }
          // add FNSI-改修内容 論理削除したの治療情報を修正 楊 end
        }
      });
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // コミット
      commit("setTreatmentData", convertDataList);
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      commit("setRecentTreatmentDate", convertDataList2);
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      commit("setPhysicalInfo", payload.physical);
      commit(
        "setOrdNoList",
        payload.targetData.map(({ ordNo, rstDialysisState }) => ({
          ordNo,
          rstDialysisState
        }))
      );

      return { treatmentData: convertDataList }

    },
    /**
     * 期間の治療情報(ord_main)の取得（曜日パタン変更用）
     * @param {string} facilityCd 施設コード
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     * @param {string} endDay 抽出終了日(YYYYMMDD形式)
     * @param {string} weekPattern 取得曜日(※全曜日の場合、[{'text': '全','done': true,'value': 0}]) ※要検討
     */
    async getOrdMainOfPeriod(
      { dispatch, commit },
      { facilityCd, patId, startDay, endDay, weekPattern }
    ) {

      this.dateArray = getDayArr(startDay,endDay);
      let startDayTmp = moment(startDay).format("YYYYMMDD");
      let endDayTmp = moment(endDay).format("YYYYMMDD");
      const sendDataTmp = {};
      // 施設コード
      sendDataTmp.facility_cd = facilityCd;
      // 患者ID
      sendDataTmp.pat_id = patId;
      // 曜日パターン
      sendDataTmp.week_pattern = weekPattern;
      // 抽出開始日
      sendDataTmp.ind_start_date = startDayTmp;
      // 抽出終了日
      sendDataTmp.ind_end_date = endDayTmp;
      const responseTmp = await ApiHelper.post(
        "/mainData/sharingInfo/TreatDateList",
        sendDataTmp
      ).catch(err => {
        throw err;
      });
      const responsData = responseTmp.data.filter(item => {
        return moment(item.treatDate).isBetween(startDay, endDay, null, '[]');
      });

      // 表示用にデータを加工
      await dispatch("convertRowTreatDataOfPeriod", {
        targetData: responsData
      });
    },

    /**
     * 取得した治療情報を行単位に加工（曜日パタン変更用）
     * @summary 1行目:各日付の1回目の治療予定、2行目:各日付の2回目の治療予定、…)
     * @param {*} context
     * @param {*} payload
     * @param {*} payload.targetData 治療指示・実績情報
     * @param {*} payload.physical 患者身体情報
     */
    async convertRowTreatDataOfPeriod({ getters, commit }, payload) {
      // 加工データ格納用(リスト)
      const convertDataList = [];
      // 加工データ格納用(行の雛形構造用)
      const layoutDataRow = {};
      // DB取得データ(ord_main)をディープコピーして加工データに使用
      const baseData = deepCopy(payload.targetData);
      // 検索用日付リスト
      const searchDateList = deepCopy(this.dateArray);
      // 日付をキーとして設定(初期値としてnullと設定)
      searchDateList.forEach(element => {
        layoutDataRow[element] = null;
      });
      // 日付をキーとした空データ行を追加
      convertDataList.push(deepCopy(layoutDataRow));
      // 日付リスト分ループ
      // 対象日付の治療情報を抽出し、表示用リストに格納
      searchDateList.forEach(element => {
        // ord_mainデータの治療日と一覧ヘッダーの日付を比較し、一致するデータを抽出
        const filter = baseData.filter(item => {
          // 一致する治療日のデータを抽出
          if (item.treatDate === element && item.isDel !== "1") {
            // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#2。 周 end
            return true;
          } else {
            return false;
          }
        });

        for (let i = 0; i < filter.length; i++) {
          // リストに行が存在しない場合、行を追加
          if (!convertDataList[i]) {
            convertDataList.push(deepCopy(layoutDataRow));
          }
          if (filter[i].isDel !== "1") {
            // 対象行の対象キー(日付)に治療情報を格納
            convertDataList[i][element] = filter[i];
          }
        }
      });
      // コミット
      commit("setTreatmentDataOfPeriod", convertDataList);
    },
    //内部remine 5840  add ljx end

    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    /**
     * 取得した治療情報を行単位に加工
     * @summary 1行目:各日付の1回目の治療予定、2行目:各日付の2回目の治療予定、…)
     * @param {*} context
     * @param {*} payload
     * @param {*} payload.targetData 治療指示・実績情報
     * @param {*} payload.physical 患者身体情報
     */
    async convertRowTreatDataTmp({ getters, commit }, payload) {
      // 加工データ格納用(リスト)
      const convertDataList = [];

      // 加工データ格納用(行の雛形構造用)
      const layoutDataRow = {};

      // DB取得データ(ord_main)をディープコピーして加工データに使用
      const baseData = deepCopy(payload.targetData);

      // 検索用日付リスト
      const searchDateListTmp = deepCopy(getters.getDateList);
      let searchDateList = [];
      for (let i = -7; i < 0; i++) {
        searchDateList.push(moment(searchDateListTmp[0]).add(i, "days").format("YYYYMMDD"));
      }
      searchDateListTmp.forEach(item => {
        searchDateList.push(item);
      });

      // mod FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
      // for (let i = 1; i < 8; i++) {
      //   searchDateList.push(moment(searchDateList[searchDateList.length - 1]).add(i, "days").format("YYYYMMDD"));
      // }
      for (let i = 1; i < 8; i++) {
        searchDateList.push(moment(searchDateList[searchDateList.length - 1]).add(1, "days").format("YYYYMMDD"));
      }
      // mod FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end

      // 日付をキーとして設定(初期値としてnullと設定)
      searchDateList.forEach(element => {
        layoutDataRow[element] = null;
      });
      // 日付をキーとした空データ行を追加
      convertDataList.push(deepCopy(layoutDataRow));

      // 日付リスト分ループ
      // 対象日付の治療情報を抽出し、表示用リストに格納
      searchDateList.forEach(element => {
        // ord_mainデータの治療日と一覧ヘッダーの日付を比較し、一致するデータを抽出
        const filter = baseData.filter(item => {
          // 一致する治療日のデータを抽出
          // if (item.treatDate === element) {
          if (item.treatDate === element && item.isDel !== "1") {
            return true;
          } else {
            return false;
          }
        });

        for (let i = 0; i < filter.length; i++) {
          // リストに行が存在しない場合、行を追加
          if (!convertDataList[i]) {
            convertDataList.push(deepCopy(layoutDataRow));
          }
          if (filter[i].isDel !== "1") {
            // 対象行の対象キー(日付)に治療情報を格納
            convertDataList[i][element] = filter[i];
          }
        }
      });
      // コミット
      commit("setTreatmentDataTmp", convertDataList);
    },
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

    /**
     * 患者検査結果(pat_exam_main)の取得
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     * @param {string} endDay 抽出終了日(YYYYMMDD形式)
     */
    async getPatExamMain({ dispatch }, { patId, startDay, endDay, patShareMode }) {
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
      const sendData = {};
      sendData.patShareMode = patShareMode;
      const response = await ApiHelper.post(
        // `/exam/TreatDateList/${patId}/${startDay}/${endDay}`
        `/exam/TreatDateList/${patId}/${startDay}/${endDay}`, sendData
      ).catch(err => {
        throw err;
      });
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

      // 表示用にデータを加工
      await dispatch("convertRowExamMainData", response.data);
    },

    /**
     * 取得した検査結果を行単位に加工
     * @summary 1行目:各日付の1回目の検査結果、2行目:各日付の2回目の検査結果、…)
     */
    async convertRowExamMainData({ getters, commit }, targetData) {
      // 加工データ格納用(リスト)
      const convertDataList = [];

      // 加工データ格納用(行の雛形構造用)
      const layoutDataRow = {};

      // DB取得データ(pat_exam_main)をディープコピーして加工データに使用
      const baseData = deepCopy(targetData);

      // 検索用日付リスト
      const searchDateList = deepCopy(getters.getDateList);

      // 日付をキーとして設定(初期値としてnullと設定)
      searchDateList.forEach(element => {
        layoutDataRow[element] = null;
      });
      // 日付をキーとした空データ行を追加
      convertDataList.push(deepCopy(layoutDataRow));

      // 日付リスト分ループ
      // 対象日付の検査結果を抽出し、表示用リストに格納
      searchDateList.forEach(element => {
        // pat_exam_mainデータの治療日と一覧ヘッダーの日付を比較し、一致するデータを抽出
        const filter = baseData.filter(item => {
          // 一致する治療日のデータを抽出
          //mod FNSI-7230 劉全航 start
          // const date = new Date(item.regExamDate);
          // const dateStr = moment(date, "YYYYMMDD").format("YYYYMMDD");
          const dateStr = moment(item.regExamDate).format("YYYYMMDD");
          //mod FNSI-7230 劉全航 end
          if (dateStr === element) {
            return true;
          } else {
            return false;
          }
        });

        for (let i = 0; i < filter.length; i++) {
          // リストに行が存在しない場合、行を追加
          if (!convertDataList[i]) {
            convertDataList.push(deepCopy(layoutDataRow));
          }
          // 対象行の対象キー(日付)に検査結果を格納
          convertDataList[i][element] = filter[i];
        }
      });

      // コミット
      commit("setExamMainData", convertDataList);
    },

    // add FNSI-検体検査の表示の修正 楊 start
    /**
     * 検査予定前回検査日の取得
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     */
    async getExamMainDataLastDate({ dispatch }, { patId, startDay, patShareMode}) {
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
      const sendData = {};
      sendData.patShareMode = patShareMode;
      const response = await ApiHelper.post(
        // `/exam/TreatDateList/${patId}/${startDay}`
        `/exam/TreatDateList/${patId}/${startDay}`, sendData
      ).catch(err => {
        throw err;
      });
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

      // 表示用にデータを加工
      await dispatch("convertLastExamMainData", response.data);
    },

    /**
     * 取得した前回検査日の加工
     * @summary 前回検査日
     */
    async convertLastExamMainData({ commit }, targetData) {

      // DB取得データ(pat_rad_main)をディープコピーして加工データに使用
      const baseData = deepCopy(targetData);
      // コミット
      commit("setLastExamMainData", baseData.regExamDate);
    },
    // add FNSI-検体検査の表示の修正 楊 end

    /**
     * 患者放射線検査結果(pat_rad_main)の取得
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     * @param {string} endDay 抽出終了日(YYYYMMDD形式)
     */
    async getPatRadMain({ dispatch }, { patId, startDay, endDay, patShareMode }) {
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
      const sendData = {};
      sendData.patShareMode = patShareMode;
      const response = await ApiHelper.post(
        // `/rad/TreatDateList/${patId}/${startDay}/${endDay}`
        `/rad/TreatDateList/${patId}/${startDay}/${endDay}`, sendData
      ).catch(err => {
        throw err;
      });
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

      // 表示用にデータを加工
      await dispatch("convertRowRadMainData", response.data);
    },

    /**
     * 取得した放射線検査結果を行単位に加工
     * @summary 1行目:各日付の1回目の放射線検査結果、2行目:各日付の2回目の放射線検査結果、…)
     */
    async convertRowRadMainData({ getters, commit }, targetData) {
      // 加工データ格納用(リスト)
      const convertDataList = [];

      // 加工データ格納用(行の雛形構造用)
      const layoutDataRow = {};

      // DB取得データ(pat_rad_main)をディープコピーして加工データに使用
      const baseData = deepCopy(targetData);

      // 検索用日付リスト
      const searchDateList = deepCopy(getters.getDateList);

      // 日付をキーとして設定(初期値としてnullと設定)
      searchDateList.forEach(element => {
        layoutDataRow[element] = null;
      });
      // 日付をキーとした空データ行を追加
      convertDataList.push(deepCopy(layoutDataRow));

      // 日付リスト分ループ
      // 対象日付の放射線検査結果を抽出し、表示用リストに格納
      searchDateList.forEach(element => {
        // pat_rad_mainデータの治療日と一覧ヘッダーの日付を比較し、一致するデータを抽出
        const filter = baseData.filter(item => {
          // 一致する治療日のデータを抽出
          //mod FNSI-7230 劉全航 start
          // const date = new Date(item.regRadDate);
          // const dateStr = moment(date, "YYYYMMDD").format("YYYYMMDD");
          const dateStr = moment(item.regRadDate).format("YYYYMMDD");
          //mod FNSI-7230 劉全航
          if (dateStr === element) {
            return true;
          } else {
            return false;
          }
        });

        for (let i = 0; i < filter.length; i++) {
          // リストに行が存在しない場合、行を追加
          if (!convertDataList[i]) {
            convertDataList.push(deepCopy(layoutDataRow));
          }
          // 対象行の対象キー(日付)に放射線検査結果を格納
          convertDataList[i][element] = filter[i];
        }
      });

      // コミット
      commit("setRadMainData", convertDataList);
    },

    // add FNSI-放射線検査の表示の修正 楊 start
    /**
     * 一般撮影検査前回検査日の取得
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     */
    async getPatRadMainLastDate({ dispatch }, { patId, startDay, patShareMode}) {
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
      const sendData = {};
      sendData.patShareMode = patShareMode;
      const response = await ApiHelper.post(
        // `/rad/TreatDateList/${patId}/${startDay}`
        `/rad/TreatDateList/${patId}/${startDay}`, sendData
      ).catch(err => {
        throw err;
      });
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */

      // 表示用にデータを加工
      await dispatch("convertLastRadDate", response.data);
    },

    /**
     * 取得した前回検査日の加工
     * @summary 前回検査日
     */
    async convertLastRadDate({ commit }, targetData) {

      // DB取得データ(pat_rad_main)をディープコピーして加工データに使用
      const baseData = deepCopy(targetData);
      // コミット
      commit("setLastRadDate", baseData.regRadDate);
    },
    // add FNSI-放射線検査の表示の修正 楊 end

    // add FNSI-観察記録を追加 楊 start
    /**
     * 観察記録データを表示用に加工
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     * @param {string} endDay 抽出終了日(YYYYMMDD形式)
     */
    async getPatEventData({ dispatch }, { patId, startDay, endDay }) {
      const response = await ApiHelper.post(
        `/pat_event/PatEventList/${patId}/${startDay}/${endDay}`
      ).catch(err => {
        throw err;
      });

      // 表示用にデータを加工
      await dispatch("convertPatEventData", response.data);
    },

    /**
     * 取得した観察記録を行単位に加工
     * @summary 観察記録データの設定
     */
    async convertPatEventData({ commit }, targetData) {

      // DB取得データ(pat_exam_main)をディープコピーして加工データに使用
      const baseData = deepCopy(targetData);

      // コミット
      commit("setPatEventDataList", baseData);
    },


    /**
     * 患者イベント（仮）データを表示用に加工
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     * @param {string} endDay 抽出終了日(YYYYMMDD形式)
     */
    async getPatientData({ dispatch }, { patId, startDay, endDay }) {
      const response = await ApiHelper.post(
        `/pat_event/PatientList/${patId}/${startDay}/${endDay}`
      ).catch(err => {
        throw err;
      });

      // 表示用にデータを加工
      await dispatch("patientData", response.data);
    },

    /**
     * 取得した患者イベント（仮）を行単位に加工
     * @summary 各日付の患者イベント（仮）データ
     */
    async patientData({ commit }, targetData) {

      // DB取得データ(pat_exam_main)をディープコピーして加工データに使用
      const baseData = deepCopy(targetData);

      // コミット
      commit("setPatientDataList", baseData);
    },
    // add FNSI-患者イベント（仮）を追加 李 end
    //7342 add 紹介状のイベント日付が登録日になる 張 start
    /**
     * 紹介状表示用に加工
     * @param {number} patId 患者ID
     * @param {string} startDay 抽出開始日(YYYYMMDD形式)
     * @param {string} endDay 抽出終了日(YYYYMMDD形式)
     */
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
    async getLetterData({ dispatch }, { patId, startDay, endDay, patShareMode }) {
      const response = await ApiHelper.post(
        // `/pat_event/selectByLetterDate/${patId}/${startDay}/${endDay}`
        `/pat_event/selectByLetterDate/${patId}/${startDay}/${endDay}/${patShareMode}`
      ).catch(err => {
        throw err;
      });

      // 表示用にデータを加工
      await dispatch("letterData", response.data);
    },
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
    async letterData({ commit }, targetData) {

      // DB取得データ(pat_exam_main)をディープコピーして加工データに使用
      const baseData = deepCopy(targetData);

      // コミット
      commit("setLetterDataList", baseData);
    },
    //7342 add 紹介状のイベント日付が登録日になる 張 end
    // add FNSI-処方を追加 姜 start
    /**
     * 処方データを表示用に加工
     * @param {number} patId 患者ID
     * @param {string} facilityCd 施設
     */
    //mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy start
    // async getPrescriptionData({ commit }, { patId,facilityCd}) {
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
    async getPrescriptionData({ commit }, { patId,facilityCd,startDay,endDay, patShareMode}) {
      const response = await ApiHelper.post(
        // `/pat-prescription/prescriptionDateList/${patId}/${facilityCd}`
        // `/pat-prescription/prescriptionDateList/${patId}/${facilityCd}/${startDay}/${endDay}`
        `/pat-prescription/prescriptionDateList/${patId}/${facilityCd}/${startDay}/${endDay}/${patShareMode}`
        //mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy end
      ).catch(err => {
        throw err;
      });

      // 表示用にデータを加工
      commit("setPrescriptionDataList", response.data);
      // await dispatch("convertPrescriptionData", response.data);
    },
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

    // /**
    //  * 取得した処方を加工
    //  * @summary 紹介状データの設定
    //  */
    // async convertPrescriptionData({ commit }, targetData) {
    //
    //   // DB取得データ(pat_exam_main)をディープコピーして加工データに使用
    //   const baseData = deepCopy(targetData);
    //
    //   // コミット
    //   commit("setPrescriptionDataList", baseData);
    // },
    // add FNSI-処方を追加 姜 end


    /**
     * 治療予定(治療状況)データを表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {Number} 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     */
    async convertTreatPlanData(
      { getters, dispatch },
      { listIndex, selectLayoutCd }
    ) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      const searchDateList = getters.getDateList;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      dispatch("getDispLayoutItemForSubCategory", {
        layoutCd: selectLayoutCd,
        categoryNo: 1, // 治療情報
        subCategoryNo: 1 // 治療予定
      }).then(searchDispLayoutItemList => {
        if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
          return [];
        }

        // 表示用データの作成
        searchDispLayoutItemList.forEach(eleDispItem => {
          // 対象番号の表示項目を抽出
          let findConvertData = convertData.find(item => {
            return eleDispItem.itemNo === item.itemNo;
          });

          // 対象番号が存在しない場合、雛形構造を追加
          if (!findConvertData) {
            const temp = deepCopy(layoutDispData);
            temp.itemNo = eleDispItem.itemNo;
            temp.itemName = eleDispItem.itemName;
            findConvertData = temp;
            convertData.push(findConvertData);
          }

          // 表示分日付(期間)ループ
          searchDateList.forEach(eleDate => {
            // 対象日付の抽出
            let findConvertDataForTreatDate = findConvertData.data.find(item => {
              return item.treatDate === eleDate;
            });
            // 対象日付のデータが存在しない場合、雛形構造を追加
            if (!findConvertDataForTreatDate) {
              const temp = deepCopy(layoutDispData_data);
              temp.treatDate = eleDate;
              findConvertDataForTreatDate = temp;
              findConvertData.data.push(findConvertDataForTreatDate);
            }

            // 対象日付に治療情報が存在するかを確認
            if (!copyTreatmentData[findConvertDataForTreatDate.treatDate]) {
              return; // forEachでのcontinueの代替
            }

            // オーダ番号を格納
            findConvertDataForTreatDate.ordNo =
              copyTreatmentData[findConvertDataForTreatDate.treatDate].ordNo;
            if (copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly) {
              findConvertDataForTreatDate.isNotClickable = true;
            }
            // 治療状況の値を画面表示用に変換し格納
            dispatch(
              "getDialysisStateMessage",
              copyTreatmentData[findConvertDataForTreatDate.treatDate]
                .rstDialysisState
            ).then(ele => {
              findConvertDataForTreatDate.value1 = ele.dispData;
            });
          });
        });
      });
      // mod FNSI-性能を最適化する 李 end

      return convertData;
    },

    /**
     * 治療条件データを表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     * @param {Boolean} isMakeStructionColorData 文字色変更用データ取得(既定値：false)
     */
    async convertTreatCondData(
      { getters, dispatch, commit },
      { listIndex, selectLayoutCd, isMakeStructionColorData = false }
    ) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      let searchDateList = [];
      // ord_main
      let copyTreatmentData = [];
      // 文字色変更用データ取得有の場合
      if (isMakeStructionColorData) {
        // 治療日一覧の取得
        const searchDateListTmp = getters.getDateList;
        // 左端画面表示治療日 - 7
        for (let i = -7; i < 0; i++) {
          searchDateList.push(moment(searchDateListTmp[0]).add(i, "days").format("YYYYMMDD"));
        }
        // 画面表示治療日
        searchDateListTmp.forEach(item => {
          searchDateList.push(item);
        });
        // 右端画面表示治療日 + 7
        for (let i = 1; i < 8; i++) {
          searchDateList.push(moment(searchDateList[searchDateList.length - 1]).add(1, "days").format("YYYYMMDD"));
        }
        // ord_mainの取得
        copyTreatmentData = getters.getTreatmentDataTmp[listIndex];
      } else {
        searchDateList = getters.getDateList;
        copyTreatmentData = getters.getTreatmentData[listIndex];
      }

      // 治療方法マスタの取得
      let response = getters.getMstTreatmentData;

      // ord_main = NULLの場合
      if (!copyTreatmentData) {
        return [];
      }

      // 検索用表示項目リスト(治療情報-治療条件)の取得
      const searchDispLayoutItemList = await dispatch(
        "getDispLayoutItemForSubCategory",
        {
          layoutCd: selectLayoutCd,
          categoryNo: 1, // 治療情報
          subCategoryNo: 4 // 治療条件
        }
      );
      if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
        return [];
      }

      // 表示分日付(期間)ループ
      searchDateList.forEach(eleDate => {
        const isCase15 = {
          indCondInfo: null,
          rstCondInfo: null
        };
        const isCase17 = {
          indCondInfo: false,
          rstCondInfo: false
        };
        const isCase19 = {
          indCondInfo: null,
          rstCondInfo: null
        };
        const isCase22 = {
          indCondInfo: false,
          rstCondInfo: false
        };
        const isCase25 = {
          indCondInfo: null,
          rstCondInfo: null
        };
        const isCase26 = {
          indCondInfo: null,
          rstCondInfo: null
        };
        const isCase27 = {
          indCondInfo: false,
          rstCondInfo: false
        };
        const isCase28 = {
          indCondInfo: false,
          rstCondInfo: false
        };

        // 表示用データの作成
        searchDispLayoutItemList.forEach(eleDispItem => {
          // 対象番号の表示項目を抽出
          let findConvertData = convertData.find(item => {
            return eleDispItem.itemNo === item.itemNo;
          });
          // 対象番号が存在しない場合、雛形構造を追加
          if (!findConvertData) {
            const temp = deepCopy(layoutDispData);
            temp.itemNo = eleDispItem.itemNo;
            temp.itemName = eleDispItem.itemName;
            findConvertData = temp;
            convertData.push(findConvertData);
          }

          // 対象日付の抽出
          let findConvertDataForTreatDate = findConvertData.data.find(item => {
            return item.treatDate === eleDate;
          });
          // 対象日付のデータが存在しない場合、雛形構造を追加
          if (!findConvertDataForTreatDate) {
            const temp = deepCopy(layoutDispData_data);
            temp.treatDate = eleDate;
            findConvertDataForTreatDate = temp;
            findConvertData.data.push(findConvertDataForTreatDate);
          }

          // 対象日付に治療情報が存在するかを確認
          if (!copyTreatmentData[findConvertDataForTreatDate.treatDate]) {
            return; // forEachでのcontinueの代替
          }
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
          const treatMethodCd = copyTreatmentData[findConvertDataForTreatDate.treatDate].indTreatmentCd;
          findConvertDataForTreatDate.treatMethodCd = treatMethodCd;
          const treatMethodInfo = response.find(i => {
            return i.treatmentCd === treatMethodCd;
          });
          if (treatMethodInfo !== undefined) {
            findConvertDataForTreatDate.deviceMode = treatMethodInfo.deviceMode;
          }
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

          // オーダ番号を格納
          findConvertDataForTreatDate.ordNo =
            copyTreatmentData[findConvertDataForTreatDate.treatDate].ordNo;

          // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
          // 治療方法コード取得
          const treatmentCd = copyTreatmentData[findConvertDataForTreatDate.treatDate].indTreatmentCd;
          // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end

          // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
          // 治療状況取得
          const rstDialysisState = copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState;
          findConvertDataForTreatDate.rstDialysisState = rstDialysisState;
          // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start

          // 対象番号を格納
          findConvertDataForTreatDate.itemNo = findConvertData.itemNo;

          findConvertDataForTreatDate.isNotClickable = copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly;
          // 指示・実績データを格納する
          for (let i = 1; i <= 2; i++) {
            const columnName = 1 === i ? "indCondInfo" : "rstCondInfo";

            // 対象治療条件項目が存在する場合、その値を格納
            // indCondInfoが文字列なのでobject型に変換
            const indCondInfo = JSON.parse(
              copyTreatmentData[findConvertDataForTreatDate.treatDate][
                columnName
                ]
            );

            if (!indCondInfo) {
              findConvertDataForTreatDate[`value${i}`] = "未登録";
              // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
              if (columnName === 'indCondInfo' && findConvertDataForTreatDate?.rstDialysisState > 0) {
                findConvertDataForTreatDate[`value${i}`] = null;
                findConvertDataForTreatDate.isDisabled1 = true;
              }
              // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
              continue;
            }

            if (findConvertData.itemNo === -1) {
              // 6885 治療日のみ表示で過去に遷移すると治療条件が表示しなくなる  zhao start
              let treatmentConditionSetting;
              let dwSetting;
              if (treatMethodInfo) {
                treatmentConditionSetting = JSON.parse(treatMethodInfo.treatmentConditionSetting);
                // mod 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 start
                // dwSetting = treatmentConditionSetting.find(item => {
                //   return item.category_no + "" === "2";
                // }).items[0].is_use;
                dwSetting = treatmentConditionSetting.find(item => {
                  return item.category_no === 2;
                }).items.find(item => item.ctl_no === '3').is_use;
                // mod 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 start
              } else {
                dwSetting = "0";
              }
              // add bug 6538 修正 chen start
              // let treatmentConditionSetting = JSON.parse(treatMethodInfo.treatmentConditionSetting);
              // let dwSetting = treatmentConditionSetting.find(item => {
              //   return item.category_no + "" === "2";
              // }).items[0].is_use;
              // add bug 6538 修正 chen end
              // 6885 治療日のみ表示で過去に遷移すると治療条件が表示しなくなる  zhao end
              // 治療条件内に表示するDW情報
              if (i === 1) {
                //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.42(外結)対応 韓 start
                // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
                //if (rstDialysisState === '0') {
                // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
                //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.42(外結)対応 韓 end
                // 指示
                let dw =
                  copyTreatmentData[findConvertDataForTreatDate.treatDate]
                    .indDw;
                /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --start */
                // findConvertDataForTreatDate.isNotClickable = false;
                findConvertDataForTreatDate.isNotClickable = copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly;
                /* upd by chamaojia 2026-03-14 [12462] 患者情報共有->患者経過総合ビューア --end */
                if (dw === null || dw === undefined) {
                  // indDwが取得できないならば身体情報から治療日最直近のDWを取得
                  const baseDate = findConvertDataForTreatDate.treatDate;
                  const tDate = moment(baseDate, "YYYYMMDD").add(1, "day");
                  for (const physicalInfo of getters.getPhysicalInfo) {
                    if (
                      physicalInfo &&
                      physicalInfo.exam_date &&
                      moment(physicalInfo.exam_date) < tDate
                    ) {
                      // 治療日より未来の登録日を除外する
                      if (
                        physicalInfo.dw !== undefined &&
                        physicalInfo.dw !== null
                      ) {
                        dw = physicalInfo.dw;
                        break;
                      }
                    }
                  }
                }
                if (dw === null || dw === undefined) {
                  findConvertDataForTreatDate[`value${i}`] = "未登録";
                } else {
                  // mod #IES_6501 dou start
                  // findConvertDataForTreatDate[`value${i}`] = `${dw.toFixed(2)} kg`;
                  findConvertDataForTreatDate[`value${i}`] = `${toFixed(dw, 2)} kg`;
                  // mod #IES_6501 dou end
                }
                //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.13(外結)対応 韓 start
                // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
                // } else {
                //   // 条件送信後(治療状況:0以外)の場合、DW(39)データを表示
                //   const treatCondItemData_dw_39 = indCondInfo[39];
                //   if (treatCondItemData_dw_39 && treatCondItemData_dw_39.value) {
                //     findConvertDataForTreatDate[`value${i}`] = `${treatCondItemData_dw_39.value.toFixed(2)} kg`;
                //   } else {
                //     findConvertDataForTreatDate[`value${i}`] = "未登録";
                //   }
                // }
                // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
                //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.13(外結)対応 韓 end
                // add bug 6538 修正 chen start
                // del 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
                // add 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 start
                if (dwSetting === "0") {
                  findConvertDataForTreatDate.isDisabled1 = true;
                  findConvertDataForTreatDate[`value${i}`] = "";
                }
                // add 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 end
                // del 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
                // add bug 6538 修正 chen end
                continue;
              } else {
                // 実績
                //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.42(外結)対応 韓 start
                // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
                //if (rstDialysisState === '0') {
                // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
                //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.42(外結)対応 韓 end
                const dw =
                  copyTreatmentData[findConvertDataForTreatDate.treatDate]
                    .rstDw;
                if (dw === null || dw === undefined) {
                  // mod 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 start
                  // findConvertDataForTreatDate[`value${i}`] = "未登録";
                  findConvertDataForTreatDate.isDisabled2 = dwSetting === '0' ? true : false;
                  findConvertDataForTreatDate[`value${i}`] = dwSetting === '0' ? "" : '未登録';
                  // mod 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 end
                } else {
                  // mod #IES_6501 dou start
                  // findConvertDataForTreatDate[`value${i}`] = `${dw.toFixed(2)} kg`;
                  findConvertDataForTreatDate[`value${i}`] = `${toFixed(dw, 2)} kg`;
                  // mod #IES_6501 dou end
                }
                //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.42(外結)対応 韓 start
                // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
                // } else {
                //   // 条件送信後(治療状況:0以外)の場合、DW(39)データを表示
                //   const treatCondItemData_dw_39 = indCondInfo[39];
                //   if (treatCondItemData_dw_39 && treatCondItemData_dw_39.value) {
                //     findConvertDataForTreatDate[`value${i}`] = `${treatCondItemData_dw_39.value.toFixed(2)} kg`;
                //   } else {
                //     findConvertDataForTreatDate[`value${i}`] = "未登録";
                //   }
                // }
                // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
                //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.42(外結)対応 韓 end
                // del 10443 身体情報・DW・目標体重バグ 関  start
                // add bug 6538 修正 chen start
                // if (dwSetting === "0") {
                //   // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
                //   // findConvertDataForTreatDate.isDisabled = true;
                //   // findConvertDataForTreatDate[`value${i}`] = "";
                //   findConvertDataForTreatDate.isDisabled1 = true;
                //   findConvertDataForTreatDate.isDisabled2 = true;
                //   findConvertDataForTreatDate[`value${1}`] = "";
                //   findConvertDataForTreatDate[`value${2}`] = "";
                //   // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
                // }
                // add bug 6538 修正 chen end
                // del 10443 身体情報・DW・目標体重バグ 関  end
                continue;
              }
            }

            const treatCondItemData = indCondInfo[findConvertData.itemNo];
            /* add by chamaojia 2023-10-30 [9973] 指示と実際のdisabledの区別 --start */
            if (!treatCondItemData) {
              // データと実際のデータを示すdisabledは区別される
              if (i === 1) {
                findConvertDataForTreatDate.isDisabled1 = true;
              } else {
                findConvertDataForTreatDate.isDisabled2 = true;
              }
            }
            /* add by chamaojia 2023-10-30 [9973] 指示と実際のdisabledの区別 --end */
            // 目標体重が「DWと同じ」
            if (
              findConvertData.itemNo === 3 &&
              treatCondItemData &&
              (treatCondItemData.value == '-1' ||  // mod #9973 value Number→文字列  shiyw
                treatCondItemData.value === null)
            ) {
              findConvertDataForTreatDate[`value${i}`] = "DWと同じ";
              continue;
            } else if (!treatCondItemData) {
              findConvertDataForTreatDate.isDisabled = true;
              continue;
            } else if (
              undefined === treatCondItemData.value ||
              null === treatCondItemData.value
            ) {
              findConvertDataForTreatDate[`value${i}`] = "未登録";
              continue;
            }

            let treatCondValue;
            let hour = "";
            let min = "";
            let temp1 = null;
            let selectedPatId = store.getters["pat-info/selectedPatId"];
            let indCondInfoFlag = !!JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo);
            let rstCondInfoFlag = !!JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo);
            switch (findConvertData.itemNo) {
              case 1:
                // 治療時間
                hour = String(Math.floor(treatCondItemData.value / 60));
                hour = hour.padStart(2, "0");
                min = String(treatCondItemData.value % 60);
                min = min.padStart(2, "0");
                findConvertDataForTreatDate[`value${i}`] = `${hour}:${min}`;
                break;

              case 2: // VA
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */  
                  // 指示：VA名
                  if(indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["2"]){
                    findConvertDataForTreatDate.indVAName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["2"].value_name_1;
                  }
                  // 実績：VA名
                  if(rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["2"]){
                    findConvertDataForTreatDate.rstVAName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["2"].value_name_1;
                  }
                }
                // VA
                if (copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly) {
                  /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                  // const param = {
                  //   vaCd : treatCondItemData.value
                  // }
                  // ApiHelper.get("/mstInfo/mstVa/getVaName", param).then((res) => {
                  //   if (i === 1) {
                  //     if (findConvertDataForTreatDate.rstDialysisState == "0") {
                  //       findConvertDataForTreatDate[`value${i}`] = response.name;
                  //     } else {
                  //       findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.indVAName;
                  //     }
                  //   } else {
                  //     findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstVAName;
                  //   }
                  //   findConvertDataForTreatDate[`value${i}`] = res.data;
                  // });

                  const vaName = i === 1 ? findConvertDataForTreatDate.indVAName : findConvertDataForTreatDate.rstVAName;
                  findConvertDataForTreatDate[`value${i}`] = vaName;
                  /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  
                } else {
                  dispatch("getMstRecordInState", {
                    mstClass: 4,
                    code: treatCondItemData.value,
                    notExistReturnValue: "削除済み"
                  }).then(response => {
                    // 治療条件の値を格納
                    // findConvertDataForTreatDate[`value${i}`] = response.name;
                    // findConvertDataForTreatDate.value1 = response.name;
                    if (i === 1) {
                      if (findConvertDataForTreatDate.rstDialysisState == "0") {
                        findConvertDataForTreatDate[`value${i}`] = response.name;
                      } else {
                        findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.indVAName;
                      }
                    }
                  });
                  // findConvertDataForTreatDate.value2=findConvertDataForTreatDate.rstVAName;
                  if (i === 2) {
                    findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstVAName;
                  }
                  // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 end
                }
                // }
                //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                break;

              case 3: // 目標体重
                // if(null==treatCondItemData.value.editValue&&null==treatCondItemData.value.initValue){
                //   findConvertDataForTreatDate[
                //     `value${i}`
                //   ] = "未登録"
                // }else{
                findConvertDataForTreatDate[
                  `value${i}`
                  // mod #IES_6501 dou start
                  // ] = `${treatCondItemData.value.toFixed(2)} kg`
                  // #10196 数値IFのスタイル全不正 linjunfeng start
                  // ] = `${toFixed(treatCondItemData.value, 2)} kg`
                  ] = `${Number(treatCondItemData.value).toFixed(2)} kg`
                  // #10196 数値IFのスタイル全不正 linjunfeng end
                // mod #IES_6501 dou end
                // }
                break;

				//add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
              case 4: // 4:除水量制限
                findConvertDataForTreatDate[
                  `value${i}`
                  // mod #IES_6501 dou start
                  // ] = `${treatCondItemData.value.toFixed(2)} L`;
                  ] = `${treatCondItemData.value} L`;
                // mod #IES_6501 dou end
                break;
				//add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
              case 5: // ダイアライザ
                // FNSI-修正 マスタ削除の対応 wangchen add start
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  // 指示：ダイアライザ名
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                  if(indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["5"]) {
                    findConvertDataForTreatDate.indDialyzerName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["5"].value_name_1;
                  }
                  // 実績：ダイアライザ名
                  if(rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["5"]) {
                    findConvertDataForTreatDate.rstDialyzerName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["5"].value_name_1;
                  }
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                }
                // FNSI-修正 マスタ削除の対応 wangchen add end
                if (copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly) {
                  /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                  // const param = {
                  //   dialyzerCd: treatCondItemData.value,
                  //   patId: selectedPatId
                  // }
                  // ApiHelper.get("/mstInfo/mstDialyzer/getDialyzerSharingInfo", param).then((res) => {
                  //   if (i === 1) {
                  //     if (findConvertDataForTreatDate.rstDialysisState == "0") {
                  //       findConvertDataForTreatDate[`value${i}`] = res.data.dialyzerName;
                  //     } else {
                  //       findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.indDialyzerName;
                  //     }
                  //   } else {
                  //     findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstDialyzerName;
                  //   }
                  //   findConvertDataForTreatDate[`isTabooAllergy${i}`] = res.data.isTabooAllergy;
                  //   // 使用期限の判定
                  //   findConvertDataForTreatDate.isExpired = !fitTermCheck(res.data.useStartDate, res.data.useEndDate, findConvertDataForTreatDate.treatDate);
                  // });

                  const dialyzerName = i === 1 ? findConvertDataForTreatDate.indDialyzerName : findConvertDataForTreatDate.rstDialyzerName;
                  if (i === 1 && findConvertDataForTreatDate.rstDialysisState == "0") {
                    // ダイアライザ
                    const tabooAllergyClassType = "4";
                    const tabooAllergyInfos = getters.getPatTabooAllergy.filter(item =>
                      item.patId == copyTreatmentData[findConvertDataForTreatDate.treatDate].patId &&
                      item.classType == tabooAllergyClassType &&
                      item.cd == treatCondItemData.value
                    );
                    if (tabooAllergyInfos && tabooAllergyInfos.length > 0) {
                      const tabooAllergyInfo = tabooAllergyInfos[0];
                      findConvertDataForTreatDate[`isTabooAllergy${i}`] = true;
                      findConvertDataForTreatDate[`value${i}`] = getTabooAllergyPrefix(tabooAllergyInfo.taboo, tabooAllergyInfo.allergy) + dialyzerName;
                    } else {
                      findConvertDataForTreatDate[`value${i}`] = dialyzerName;
                      findConvertDataForTreatDate[`isTabooAllergy${i}`] = false;
                    }
                  } else {
                    findConvertDataForTreatDate[`value${i}`] = dialyzerName;
                    findConvertDataForTreatDate[`isTabooAllergy${i}`] = isTabooAllergy(dialyzerName);
                  }
                  /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

                } else {
                  if (treatCondItemData.value_name_1) {
                    // ダイアライザ
                    dispatch("getMstRecordInState", {
                      mstClass: 13,
                      code: treatCondItemData.value,
                      notExistReturnValue: "削除済み",
                      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                      treatDate: findConvertDataForTreatDate.treatDate
                      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                    }).then(response => {
                      // 治療条件の値を格納
                      // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#3。 周 start
                      // findConvertDataForTreatDate[`value${i}`] = response.prefix + treatCondItemData.value_name_1;
                      // findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                      if (response.prefix) {
                        // findConvertDataForTreatDate[`value${i}`] = response.prefix + treatCondItemData.value_name_1;
                        if (i === 1) {
                          if (findConvertDataForTreatDate.rstDialysisState == "0") {
                            // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240321 ztc start
                            // findConvertDataForTreatDate[`value${i}`] = response.prefix + response.name;
                            findConvertDataForTreatDate[`value${i}`] = response.name.includes(response.prefix) ?
                            response.name : response.prefix + response.name;
                            // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240321 ztc end
                          } else {
                            findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.indDialyzerName.includes(response.prefix) ? findConvertDataForTreatDate.indDialyzerName : response.prefix + findConvertDataForTreatDate.indDialyzerName;
                          }
                        } else {
                          findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstDialyzerName.includes(response.prefix) ? findConvertDataForTreatDate.rstDialyzerName : response.prefix + findConvertDataForTreatDate.rstDialyzerName;
                        }
                        findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                      } else {
                        //mod FNSI-5678 劉全航 start
                        // findConvertDataForTreatDate[`value${i}`] = response.name;
                        //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
                        // findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                        // findConvertDataForTreatDate.value1 = response.name;
                        // findConvertDataForTreatDate.value2 = findConvertDataForTreatDate.rstDialyzerName;
                        // findConvertDataForTreatDate[`value${i}`] = i === 1 ? response.name : findConvertDataForTreatDate.rstDialyzerName;
                        if (i === 1) {
                          if (findConvertDataForTreatDate.rstDialysisState == "0") {
                            findConvertDataForTreatDate[`value${i}`] = response.name;
                          } else {
                            findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.indDialyzerName;
                          }
                        } else {
                          findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstDialyzerName;
                        }
                        //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                        //mod FNSI-5678 劉全航 end
                      }
                      // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#3。 周 end
                    });
                  } else {
                    // ダイアライザ
                    dispatch("getMstRecordInState", {
                      mstClass: 13,
                      code: treatCondItemData.value,
                      notExistReturnValue: "削除済み",
                      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                      treatDate: findConvertDataForTreatDate.treatDate
                      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                    }).then(response => {
                      // 治療条件の値を格納
                      //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
                      // findConvertDataForTreatDate[`value${i}`] = response.name;
                      // findConvertDataForTreatDate.value1 = response.name;
                      // findConvertDataForTreatDate.value2 = findConvertDataForTreatDate.rstDialyzerName;
                      // findConvertDataForTreatDate[`value${i}`] = i === 1 ? response.name : findConvertDataForTreatDate.rstDialyzerName;
                      if (i === 1) {
                        if (findConvertDataForTreatDate.rstDialysisState == "0") {
                          findConvertDataForTreatDate[`value${i}`] = response.name;
                        } else {
                          findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.indDialyzerName;
                        }
                      } else {
                        findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstDialyzerName;
                      }
                      //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                      findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                      // 使用期限の判定
                      findConvertDataForTreatDate.isExpired = !fitTermCheck(response.useStartDate, response.useEndDate, findConvertDataForTreatDate.treatDate);
                    });
                  }
                  // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 end
                }
                break;

              case 6: // 吸着カラム
                // FNSI-修正 マスタ削除の対応 wangchen add start
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  // 指示：医療材料名
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                  if(indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["6"]) {
                    findConvertDataForTreatDate.indEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["6"].value_name_1;
                  }
                  // 実績：医療材料名
                  if(rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["6"]) {
                    findConvertDataForTreatDate.rstEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["6"].value_name_1;
                  }
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                }
              //mod 8752 【IES起票】患者経過総合ビューア画面にて表示されない項目がある 張 start
              // break;
              // FNSI-修正 マスタ削除の対応 wangchen add end
              case 7: // 1次膜
                // FNSI-修正 マスタ削除の対応 wangchen add start
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                  // 指示：医療材料名
                  findConvertDataForTreatDate.indEquipmentName = indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["7"]?JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["7"].value_name_1:"";
                  // 実績：医療材料名
                  findConvertDataForTreatDate.rstEquipmentName = rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["7"]?JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["7"].value_name_1:"";
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                }
              // break;
              // FNSI-修正 マスタ削除の対応 wangchen add end
              case 8: // 2次膜
                // FNSI-修正 マスタ削除の対応 wangchen add start
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                  // 指示：医療材料名
                  findConvertDataForTreatDate.indEquipmentName = indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["8"]?JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["8"].value_name_1:"";
                  // 実績：医療材料名
                  findConvertDataForTreatDate.rstEquipmentName = rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["8"]?JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["8"].value_name_1:"";
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                }
              // break;
              // FNSI-修正 マスタ削除の対応 wangchen add end
              case 9:
                // FNSI-修正 マスタ削除の対応 wangchen add start
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                  // 指示：医療材料名
                  if(indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["9"]) {
                    findConvertDataForTreatDate.indEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["9"].value_name_1;
                  }
                  // 実績：医療材料名
                  if(rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["9"]) {
                    findConvertDataForTreatDate.rstEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["9"].value_name_1;
                  }
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                }
              // break;
              // FNSI-修正 マスタ削除の対応 wangchen add end
              case 10:
                // FNSI-修正 マスタ削除の対応 wangchen add start
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                  // 指示：医療材料名
                  if(indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["10"]) {
                    findConvertDataForTreatDate.indEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["10"].value_name_1;
                  }
                  // 実績：医療材料名
                  if(rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["10"]) {
                    findConvertDataForTreatDate.rstEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["10"].value_name_1;
                  }
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                }
              // break;
              // FNSI-修正 マスタ削除の対応 wangchen add end
              case 11:
                // FNSI-修正 マスタ削除の対応 wangchen add start
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                  // 指示：医療材料名
                  if(indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["11"]) {
                    findConvertDataForTreatDate.indEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["11"].value_name_1;
                  }
                  // 実績：医療材料名
                  if(rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["11"]) {
                    findConvertDataForTreatDate.rstEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["11"].value_name_1;
                  }
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                }
              // break;
              //mod 8752 【IES起票】患者経過総合ビューア画面にて表示されない項目がある 張 end
              // FNSI-修正 マスタ削除の対応 wangchen add end
              case 13:
                // FNSI-修正 マスタ削除の対応 wangchen add start
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // if(findConvertDataForTreatDate.rstDialysisState!="0"){
                if(findConvertDataForTreatDate.rstDialysisState!="0" || copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly){
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */  
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                  // 指示：医療材料名
                  if(indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["13"]) {
                    findConvertDataForTreatDate.indEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["13"].value_name_1;
                  }
                  // 実績：医療材料名
                  if(rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["13"]) {
                    findConvertDataForTreatDate.rstEquipmentName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["13"].value_name_1;
                  }
                  /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                }
                // FNSI-修正 マスタ削除の対応 wangchen add end
                if (copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly) {
                  /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                  // const param = {
                  //   equipmentCd: treatCondItemData.value,
                  //   patId: selectedPatId
                  // }
                  // ApiHelper.get("/mstInfo/mstEquipment/getEquipmentSharingInfo", param).then((res) => {
                  //   // findConvertDataForTreatDate[`value${i}`] = res.data.prefix + res.data.equipmentName;
                  //   if (i === 1) {
                  //     if (findConvertDataForTreatDate.rstDialysisState == "0") {
                  //       // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240321 ztc start
                  //       // findConvertDataForTreatDate[`value${i}`] = res.data.prefix + res.data.equipmentName;
                  //       findConvertDataForTreatDate[`value${i}`] = res.data.equipmentName.includes(response.data.prefix) ?
                  //       res.data.equipmentName : res.data.prefix + res.data.equipmentName;
                  //       // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240321 ztc end
                  //     } else {
                  //       findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.data.prefix) ? treatCondItemData.value_name_1 : response.data.prefix + treatCondItemData.value_name_1;
                  //     }
                  //   } else {
                  //     findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.data.prefix) ? treatCondItemData.value_name_1 : response.data.prefix + treatCondItemData.value_name_1;
                  //   }
                  //   findConvertDataForTreatDate[`isTabooAllergy${i}`] = res.data.isTabooAllergy;
                  //   // 使用期限の判定
                  //   findConvertDataForTreatDate.isExpired = !fitTermCheck(res.data.useStartDate, res.data.useEndDate, findConvertDataForTreatDate.treatDate);
                  // });

                  const ordMainInfo = copyTreatmentData[findConvertDataForTreatDate.treatDate];
                  const equipmentName = i === 1 ? JSON.parse(ordMainInfo.indCondInfo)[findConvertData.itemNo].value_name_1 
                                                : JSON.parse(ordMainInfo.rstCondInfo)[findConvertData.itemNo].value_name_1;
                  if (i === 1 && findConvertDataForTreatDate.rstDialysisState == "0") {
                    // ダイアライザ
                    const tabooAllergyClassType = "3";
                    const tabooAllergyInfos = getters.getPatTabooAllergy.filter(item =>
                      item.patId == copyTreatmentData[findConvertDataForTreatDate.treatDate].patId &&
                      item.classType == tabooAllergyClassType &&
                      item.cd == treatCondItemData.value
                    );
                    if (tabooAllergyInfos && tabooAllergyInfos.length > 0) {
                      const tabooAllergyInfo = tabooAllergyInfos[0];
                      findConvertDataForTreatDate[`isTabooAllergy${i}`] = true;
                      findConvertDataForTreatDate[`value${i}`] = getTabooAllergyPrefix(tabooAllergyInfo.taboo, tabooAllergyInfo.allergy) + equipmentName;
                    } else {
                      findConvertDataForTreatDate[`value${i}`] = equipmentName;
                      findConvertDataForTreatDate[`isTabooAllergy${i}`] = false;
                    }

                  } else {
                    findConvertDataForTreatDate[`value${i}`] = equipmentName;
                    findConvertDataForTreatDate[`isTabooAllergy${i}`] = isTabooAllergy(equipmentName);
                  }
                  /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                } else {
                  // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                  let classTypeObj = {
                    6: CODES.EQUIPMENT_CLASS.ADSORPTION_COLUMN.classType,
                    7: [CODES.EQUIPMENT_CLASS.ADSORBER.classType, CODES.EQUIPMENT_CLASS.SEPARATOR.classType],
                    8: [CODES.EQUIPMENT_CLASS.ADSORBER.classType, CODES.EQUIPMENT_CLASS.SEPARATOR.classType],
                    9: CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType,
                    10: CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType,
                    11: CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE_SN.classType,
                    13: CODES.EQUIPMENT_CLASS.BLOOD_CIRCUIT.classType,
                  }
                  // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                  if (treatCondItemData.value_name_1) {
                    // 6:吸着カラム、7:1次膜、8:2次膜、9:穿刺針(A針)、10:穿刺針(V針)、11:穿刺針(S針)、13:血液回路
                    dispatch("getMstRecordInState", {
                      mstClass: 12,
                      code: treatCondItemData.value,
                      notExistReturnValue: "削除済み"
                    }).then(response => {
                      // 治療条件の値を格納
                      // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#3。 周 start
                      // findConvertDataForTreatDate[`value${i}`] = response.prefix + treatCondItemData.value_name_1;
                      // findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                      if (response.prefix) {
                        //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
                        // findConvertDataForTreatDate[`value${i}`] = response.prefix + treatCondItemData.value_name_1;
                        // findConvertDataForTreatDate.value1 = response.prefix + treatCondItemData.value_name_1;
                        // findConvertDataForTreatDate.value2 = treatCondItemData.value_name_1;
                        // findConvertDataForTreatDate[`value${i}`] = i === 1 ? response.prefix + treatCondItemData.value_name_1 : treatCondItemData.value_name_1;
                        if (i === 1) {
                          if (findConvertDataForTreatDate.rstDialysisState == "0") {
                            // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240321 ztc start
                            // findConvertDataForTreatDate[`value${i}`] = response.prefix + response.name;
                            findConvertDataForTreatDate[`value${i}`] = response.name.includes(response.prefix) ?
                            response.name : response.prefix + response.name;
                            // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240321 ztc end
                          } else {
                            findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.prefix) ? treatCondItemData.value_name_1 : response.prefix + treatCondItemData.value_name_1;
                          }
                        } else {
                          findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.prefix) ? treatCondItemData.value_name_1 : response.prefix + treatCondItemData.value_name_1;
                        }
                        //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                        findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                      } else {
                        // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
                        // 治療条件項目の値で、医療材料マスタの医療材料コードを取得する。
                        //mod no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
                        // const equipmentData = getters.getMstEquipmentData.find(eqData => {
                        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                        // const equipmentData = getters.getMstEquipmentAllergy.find(eqData => {
                        //   //mod no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
                        //   return treatCondItemData.value == eqData.equipmentCd;
                        // })
                        // let classCd = null;
                        // if (equipmentData && equipmentData.classCd) classCd = equipmentData.classCd;
                        // // 分類が一致するかどうかを判断する
                        // const inconClassificationName = getInconClassificationName(
                        //   getters,
                        //   findConvertData.itemNo,
                        //   classCd,
                        //   findConvertDataForTreatDate.ordNo,
                        //   treatmentCd,
                        //   // add FNSI-FutreNetWeb+SI課題管理No.5323 李 start
                        //   response.name
                        //   // add FNSI-FutreNetWeb+SI課題管理No.5323 李 end
                        // );
                        // if (inconClassificationName) response.name = `【${inconClassificationName}】` + response.name;
                        // // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end
                        // //mod FNSI-5678 劉全航 start
                        // // findConvertDataForTreatDate[`value${i}`] = response.name;
                        // //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
                        // // findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                        // // findConvertDataForTreatDate.value1 = treatCondItemData.value_name_1;
                        // // findConvertDataForTreatDate.value2 = inconClassificationName==null?treatCondItemData.value_name_1:`【${inconClassificationName}】` +treatCondItemData.value_name_1;
                        // // findConvertDataForTreatDate[`value${i}`] = i === 1 ? treatCondItemData.value_name_1 : inconClassificationName == null ? treatCondItemData.value_name_1 : `【${inconClassificationName}】` + treatCondItemData.value_name_1;
                        // if (i === 1) {
                        //   if (findConvertDataForTreatDate.rstDialysisState == "0") {
                        //     findConvertDataForTreatDate[`value${i}`] = response.name;
                        //   } else {
                        //     findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                        //   }
                        // } else {
                        //   findConvertDataForTreatDate[`value${i}`] = inconClassificationName == null ? treatCondItemData.value_name_1 : `【${inconClassificationName}】` + treatCondItemData.value_name_1;
                        // }
                        findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                        //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                        //mod FNSI-5678 劉全航 end
                      }
                      // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#3。 周 end
                    });
                  } else {
                    // 6:吸着カラム、7:1次膜、8:2次膜、9:穿刺針(A針)、10:穿刺針(V針)、11:穿刺針(S針)、13:血液回路
                    dispatch("getMstRecordInState", {
                      mstClass: 12,
                      code: treatCondItemData.value,
                      notExistReturnValue: "削除済み",
                      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                      classType: classTypeObj[findConvertData.itemNo],
                      treatDate: findConvertDataForTreatDate.treatDate
                      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                    }).then(response => {
                      // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
                      // 治療条件項目の値で、医療材料マスタの医療材料コードを取得する。
                      //mod no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
                      // const equipmentData = getters.getMstEquipmentData.find(eqData => {
                      // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                      // const equipmentData = getters.getMstEquipmentAllergy.find(eqData => {
                      //   //mod no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
                      //   return treatCondItemData.value == eqData.equipmentCd;
                      // })
                      // let classCd = null;
                      // if (equipmentData && equipmentData.classCd) classCd = equipmentData.classCd;
                      // 分類が一致するかどうかを判断する
                      // const inconClassificationName = getInconClassificationName(
                      //   getters,
                      //   findConvertData.itemNo,
                      //   classCd,
                      //   findConvertDataForTreatDate.ordNo,
                      //   treatmentCd,
                      //   // add FNSI-FutreNetWeb+SI課題管理No.5323 李 start
                      //   response && response.name
                      //   // add FNSI-FutreNetWeb+SI課題管理No.5323 李 end
                      // );
                      // if (inconClassificationName) response.name = `【${inconClassificationName}】` + response.name;
                      // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                      // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end

                      // 治療条件の値を格納
                      //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
                      // findConvertDataForTreatDate[`value${i}`] = response.name;
                      // findConvertDataForTreatDate.value1 = response.name;
                      // findConvertDataForTreatDate.value2 = inconClassificationName==null?findConvertDataForTreatDate.rstEquipmentName:`【${inconClassificationName}】` +findConvertDataForTreatDate.rstEquipmentName;
                      // findConvertDataForTreatDate[`value${i}`] = i === 1 ? response.name : inconClassificationName == null ? findConvertDataForTreatDate.rstEquipmentName : `【${inconClassificationName}】` + findConvertDataForTreatDate.rstEquipmentName;
                      if (i === 1) {
                        if (findConvertDataForTreatDate.rstDialysisState == "0") {
                          findConvertDataForTreatDate[`value${i}`] = response.name;
                        } else {
                          findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                        }
                      } else {
                        findConvertDataForTreatDate[`value${i}`] = inconClassificationName == null ? treatCondItemData.value_name_1 : `【${inconClassificationName}】` + treatCondItemData.value_name_1;
                      }
                      //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                      findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                      // 使用期限の判定
                      findConvertDataForTreatDate.isExpired = !fitTermCheck(response.useStartDate, response.useEndDate, findConvertDataForTreatDate.treatDate);
                    });
                  }
                }
                break;

              case 12:
              case 29:
                // 12:シングルニードル使用、29:IP使用選択
                treatCondValue =
                  '0' == treatCondItemData.value ? "使用しない" : "使用する"; // mod #9973 value Number→文字列  shiyw
                if ('0' == treatCondItemData.value) { // mod #9973 value Number→文字列  shiyw
                  treatCondValue = "使用しない";
                } else if ('1' == treatCondItemData.value) { // mod #9973 value Number→文字列  shiyw
                  treatCondValue = "使用する";
                } else {
                  treatCondValue = "未登録";
                }
                // 治療条件の値を格納
                findConvertDataForTreatDate[`value${i}`] = treatCondValue;
                break;

              case 14:
              case 16:
                // 14:血流量、16:透析液流量
                findConvertDataForTreatDate[
                  `value${i}`
                  ] = `${treatCondItemData.value} mL/min`;
                break;

              case 15:
              case 19:
              case 25:
                //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
                if (findConvertData.itemNo == 15) {
                  isCase15[columnName] = treatCondItemData.value;
                }
                if (findConvertData.itemNo == 19) {
                  isCase19[columnName] = treatCondItemData.value;
                }
                if (findConvertData.itemNo == 25) {
                  isCase25[columnName] = treatCondItemData.value;
                }
                //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
                if (copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly) {
                  /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                  // if (treatCondItemData.medicine_type == 2) {
                  //   const param = {
                  //     medicineMixCd: treatCondItemData.value,
                  //     patId: selectedPatId
                  //   }
                  //   ApiHelper.get("/mstInfo/mstMedicineMix/getMedicineMixSharingInfo", param).then((res) => {
                  //     // findConvertDataForTreatDate[`value${i}`] = res.data.prefix + res.data.medicineMixName;
                  //     if (i === 1) {
                  //       if (findConvertDataForTreatDate.rstDialysisState == "0") {
                  //         // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240321 ztc start
                  //         // findConvertDataForTreatDate[`value${i}`] = res.data.prefix + res.data.medicineMixName;
                  //         findConvertDataForTreatDate[`value${i}`] = res.data.medicineMixName.includes(res.data.prefix) ?
                  //         res.data.medicineMixName : res.data.prefix + res.data.medicineMixName;
                  //         // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240321 ztc end
                  //       } else {
                  //         findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.data.prefix) ? treatCondItemData.value_name_1 : response.data.prefix + treatCondItemData.value_name_1;
                  //       }
                  //     } else {
                  //       findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.data.prefix) ? treatCondItemData.value_name_1 : response.data.prefix + treatCondItemData.value_name_1;
                  //     }
                  //     findConvertDataForTreatDate[`isTabooAllergy${i}`] = res.data.isTabooAllergy;
                  //     findConvertDataForTreatDate.isExpired = !fitTermCheck(res.data.useStartDate, res.data.useEndDate, findConvertDataForTreatDate.treatDate);
                  //   });
                  // } else {
                  //   const param = {
                  //     medicineCd: treatCondItemData.value,
                  //     patId: selectedPatId
                  //   }
                  //   ApiHelper.get("/mstInfo/mstMedicine/getMedicineSharingInfo", param).then((res) => {
                  //     // findConvertDataForTreatDate[`value${i}`] = res.data.prefix + res.data.medicineName;
                  //     if (i === 1) {
                  //       if (findConvertDataForTreatDate.rstDialysisState == "0") {
                  //         findConvertDataForTreatDate[`value${i}`] = res.data.prefix + res.data.medicineName;
                  //       } else {
                  //         findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.data.prefix) ? treatCondItemData.value_name_1 : response.data.prefix + treatCondItemData.value_name_1;
                  //       }
                  //     } else {
                  //       findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.data.prefix) ? treatCondItemData.value_name_1 : response.data.prefix + treatCondItemData.value_name_1;
                  //     }
                  //     findConvertDataForTreatDate[`isTabooAllergy${i}`] = res.data.isTabooAllergy;
                  //     findConvertDataForTreatDate.isExpired = !fitTermCheck(res.data.useStartDate, res.data.useEndDate, findConvertDataForTreatDate.treatDate);
                  //   });
                  // }
                
                  findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                  findConvertDataForTreatDate[`isTabooAllergy${i}`] = isTabooAllergy(treatCondItemData.value_name_1);

                  if (i === 1 && findConvertDataForTreatDate.rstDialysisState == "0") {
                    const patId = copyTreatmentData[findConvertDataForTreatDate.treatDate].patId;
                    if (treatCondItemData.medicine_type == 2) {   // 調製薬剤
                      const medicineMixData = getters.getMstMedicineMixData.find(item =>
                        item.medicineMixCd == treatCondItemData.value
                      );
                      if (medicineMixData) {
                        const mixInfo = JSON.parse(medicineMixData.mixInfo)
                        let taboo = false;
                        let allergy = false;
                        for (let medicineData of mixInfo) {
                          const tabooAllergyInfo = getters.getPatTabooAllergy.find(item =>
                            item.patId == patId &&
                            item.classType == "1" &&
                            item.cd == medicineData.cd
                          );

                          if (tabooAllergyInfo) {
                            if (tabooAllergyInfo.taboo) {
                              taboo = true;
                            }
                            if (tabooAllergyInfo.allergy) {
                              allergy = true;
                            }
                          }

                          if (taboo && allergy) break;
                        }

                        if (taboo || allergy) {
                          findConvertDataForTreatDate[`isTabooAllergy${i}`] = true;
                          findConvertDataForTreatDate[`value${i}`] = getTabooAllergyPrefix(taboo, allergy) + treatCondItemData.value_name_1;

                        }
                      }
                    } else {  // 薬剤
                      const tabooAllergyInfo = getters.getPatTabooAllergy.find(item =>
                        item.patId == patId &&
                        item.classType == "1" &&
                        item.cd == treatCondItemData.value
                      );
                      if (tabooAllergyInfo) {
                        findConvertDataForTreatDate[`isTabooAllergy${i}`] = true;
                        findConvertDataForTreatDate[`value${i}`] = getTabooAllergyPrefix(tabooAllergyInfo.taboo, tabooAllergyInfo.allergy) + treatCondItemData.value_name_1;
                      }
                    }
                  }
                  /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                } else {
                  // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                  const deviceModeOnline = [DEVICEMODE.OHDF, DEVICEMODE.OHF, DEVICEMODE.I_HDF];
                  const deviceModeOnlineClassType = [CODES.MEDICINE_CLASS.DIALYSATE.classType, CODES.MEDICINE_CLASS.REPLACEMENT.classType];
                  const dialysateClassType = deviceModeOnline.includes(findConvertDataForTreatDate.deviceMode) ? deviceModeOnlineClassType : CODES.MEDICINE_CLASS.DIALYSATE.classType;
                  const replacementClassType = deviceModeOnline.includes(findConvertDataForTreatDate.deviceMode) ? deviceModeOnlineClassType : CODES.MEDICINE_CLASS.REPLACEMENT.classType;
                  let classTypeObj = {
                    15: dialysateClassType,
                    19: replacementClassType,
                    25: CODES.MEDICINE_CLASS.ANTI_COAGULANT.classType,
                  }
                  // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                  if (treatCondItemData.value_name_1) {
                    // 15:透析液、19:補液、25:抗凝固剤
                    dispatch("getMstRecordInState", {
                      // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
                      mstClass: treatCondItemData.medicine_type == 2 ? 11 : 10,
                      code: treatCondItemData.value,
                      notExistReturnValue: "削除済み"
                    }).then(response => {
                      // 治療条件の値を格納
                      // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#3。 周 start
                      // findConvertDataForTreatDate[`value${i}`] = response.prefix + treatCondItemData.value_name_1;
                      // findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                      if (response) {
                        if (response.prefix) {
                          //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
                          // findConvertDataForTreatDate[`value${i}`] = response.prefix + treatCondItemData.value_name_1;
                          // findConvertDataForTreatDate.value1 = response.prefix + treatCondItemData.value_name_1;
                          // findConvertDataForTreatDate.value2 = treatCondItemData.value_name_1;
                          findConvertDataForTreatDate[`value${i}`] = i === 1 ? response.prefix + treatCondItemData.value_name_1 : treatCondItemData.value_name_1;
                          if (i === 1) {
                            if (findConvertDataForTreatDate.rstDialysisState == "0") {
                              /* modify by chamaojia 2024-02-28 [10196] "response.name" already contains "prefix" --start */
                              findConvertDataForTreatDate[`value${i}`] = response.name;
                              /* modify by chamaojia 2024-02-28 [10196] "response.name" already contains "prefix" --end */
                            } else {
                              findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.prefix) ? treatCondItemData.value_name_1 : response.prefix + treatCondItemData.value_name_1;
                            }
                          } else {
                            findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1.includes(response.prefix) ? treatCondItemData.value_name_1 : response.prefix + treatCondItemData.value_name_1;
                          }
                          //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                          findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                        } else {
                          // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 start
                          const medicineMix = getters.getMstMedicineMixAllergyData.find(medicine => {
                            return treatCondItemData.value == medicine.medicineMixCd;
                          })
                          const medicine = getters.getMstMedicineAllergyData.find(medicine => {
                            return treatCondItemData.value == medicine.medicineCd;
                          })
                          const medicineData = treatCondItemData.medicine_type == 2 ? medicineMix : medicine
                          // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 end
                          let classCd = null;
                          if (medicineData && medicineData.classCd) classCd = medicineData.classCd;
                          // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
                          const inconClassificationName = getInconClassificationName(
                            getters,
                            findConvertData.itemNo,
                            classCd,
                            findConvertDataForTreatDate.ordNo,
                            treatmentCd,
                            // add FNSI-FutreNetWeb+SI課題管理No.5323 李 start
                            response.name
                            // add FNSI-FutreNetWeb+SI課題管理No.5323 李 end
                          );
                          if (inconClassificationName) response.name = `【${inconClassificationName}】` + response.name;
                          // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end
                          //mod FNSI-5678 劉全航 start
                          // findConvertDataForTreatDate[`value${i}`] = response.name;
                          //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
                          // findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                          // findConvertDataForTreatDate.value1 = treatCondItemData.value_name_1;
                          // findConvertDataForTreatDate.value2 = treatCondItemData.value_name_1;
                          // findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                          if (i === 1) {
                            if (findConvertDataForTreatDate.rstDialysisState == "0") {
                              findConvertDataForTreatDate[`value${i}`] = response.name;
                            } else {
                              findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                            }
                          } else {
                            findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                          }
                          //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                          //mod FNSI-5678 劉全航 end
                        }
                        // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#3。 周 end
                        var numbers = "";
                        var decPoint = "";
                        switch (findConvertData.itemNo) {
                          // 小数点桁数のみは必ずマスタ参照のため実施
                          case 15:
                            // 透析液かつ透析液使用数
                            isCase15[columnName] = treatCondItemData.value;
                            if (isCase17[columnName]) {
                              const temp1 = convertData.find(eleData => {
                                return 17 === eleData.itemNo;
                              });
                              if (!temp1) {
                                return;
                              }
                              const temp2 = temp1.data.find(eleItem => {
                                return eleDate === eleItem.treatDate;
                              });
                              if (!temp2) {
                                return;
                              }
                              if (
                                undefined !== response.unitSecond && null !== response.unitSecond &&
                                "未登録" !== temp2[`value${i}`] && "削除済み" !== temp2[`value${i}`]
                              ) {
                                numbers = String(temp2[`value${i}`]).split('.');
                                decPoint = (numbers[1]) ? numbers[1].length : 0;
                                // mod FNSI-小数点の修正 楊 start
                                // if(decPoint > response.decPointSecond){
                                if (copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState !== "0") {
                                  // temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed();
                                  //mod 7793 使用数の小数点以下が表示されない 張 start
                                  // temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(decPoint);
                                  temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(response.decPointSecond);
                                  //mod 7793 使用数の小数点以下が表示されない 張 end
                                  // mod FNSI-小数点の修正 楊 end
                                  //temp2[`unit${i}`] = ` ${response.unitSecond}`;
                                } else {
                                  temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(response.decPointSecond);
                                  /* modify by chamaojia 2024-02-28 [10196] the deleted data needs to display units --start */
                                  temp2[`unit${i}`] = ` ${response.unitSecond}`;
                                  /* modify by chamaojia 2024-02-28 [10196] the deleted data needs to display units --end */
                                }
                              }
                            }
                            break;
                          case 19:
                            // 補液
                            isCase19[columnName] = treatCondItemData.value;
                            if (isCase22[columnName]) {
                              const temp1 = convertData.find(eleData => {
                                return 22 === eleData.itemNo;
                              });
                              if (!temp1) {
                                return;
                              }
                              const temp2 = temp1.data.find(eleItem => {
                                return eleDate === eleItem.treatDate;
                              });
                              if (!temp2) {
                                return;
                              }
                              if (
                                undefined !== response.unit && null !== response.unit &&
                                "未登録" !== temp2[`value${i}`] && "削除済み" !== temp2[`value${i}`]
                              ) {
                                numbers = String(temp2[`value${i}`]).split('.');
                                decPoint = (numbers[1]) ? numbers[1].length : 0;
                                // mod FNSI-小数点の修正 楊 start
                                // if(decPoint > response.decPointSecond){
                                if (copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState !== "0") {
                                  // temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed();
                                  //mod 7793 使用数の小数点以下が表示されない 張 start
                                  // temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(decPoint);
                                  temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(response.decPointSecond);
                                  //mod 7793 使用数の小数点以下が表示されない 張 end
                                  // mod FNSI-小数点の修正 楊 end
                                  //temp2[`unit${i}`] = ` ${response.unitSecond}`;
                                } else {
                                  temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(response.decPointSecond);
                                  //temp2[`unit${i}`] = ` ${response.unitSecond}`;
                                }
                              }
                            }
                            break;
                          case 25:
                            // 抗凝固剤
                            isCase25[columnName] = treatCondItemData.value;
                            for (let j = 0; j < 3; j++) {
                              temp1 = null;
                              if (isCase26[columnName] && 0 === j) {
                                // 抗凝固剤ワンショット量
                                temp1 = convertData.find(eleData => {
                                  return 26 === eleData.itemNo;
                                });
                              } else if (isCase27[columnName] && 1 === j) {
                                // 抗凝固剤持続速度
                                temp1 = convertData.find(eleData => {
                                  return 27 === eleData.itemNo;
                                });
                              } else if (isCase28[columnName] && 2 === j) {
                                // 抗凝固剤持続総
                                temp1 = convertData.find(eleData => {
                                  return 28 === eleData.itemNo;
                                });
                              }
                              if (!temp1) {
                                continue;
                              }
                              const temp2 = temp1.data.find(eleItem => {
                                return eleDate === eleItem.treatDate;
                              });
                              if (!temp2) {
                                continue;
                              }
                              if (
                                undefined !== response.unit &&
                                null !== response.unit &&
                                "未登録" !== temp2[`value${i}`] &&
                                "削除済み" !== temp2[`value${i}`]
                              ) {
                                temp2[`value${i}`] = (BigNumber(temp2[`value${i}`]).toFixed());
                              }
                            }
                            break;
                        }
                      }
                    });
                  } else {
                    // 15:透析液、19:補液、25:抗凝固剤
                    dispatch("getMstRecordInState", {
                      // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
                      mstClass: treatCondItemData.medicine_type == 2 ? 11 : 10,
                      code: treatCondItemData.value,
                      notExistReturnValue: "削除済み",
                      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                      classType: classTypeObj[findConvertData.itemNo],
                      treatDate: findConvertDataForTreatDate.treatDate
                      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                    }).then(response => {
                      if (response) {
                        //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
                        // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 start
                        // let medicineData = getters.getMstMedicineAllergyData.find(medicine => {
                        //   return treatCondItemData.value == medicine.medicineCd;
                        // })
                        // // add FNSI#6662-薬剤マスタに存在しない場合、調整薬剤マスタに検索することを追加。ljx start
                        // if(!medicineData){
                        //   medicineData = getters.getMstMedicineMixData.find(medicine => {
                        //     return treatCondItemData.value == medicine.medicineMixCd;
                        //   })
                        // }
                        // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                        // const medicineMix = getters.getMstMedicineMixAllergyData.find(medicine => {
                        //   return treatCondItemData.value == medicine.medicineMixCd;
                        // })
                        // const medicine = getters.getMstMedicineAllergyData.find(medicine => {
                        //   return treatCondItemData.value == medicine.medicineCd;
                        // })
                        // const medicineData = treatCondItemData.medicine_type == 2 ? medicineMix : medicine
                        // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 end
                        // add FNSI#6662-薬剤マスタに存在しない場合、調整薬剤マスタに検索することを追加。ljx end
                        // let classCd = null;
                        // if (medicineData && medicineData.classCd) classCd = medicineData.classCd;
                        //add no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
                        // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
                        // const inconClassificationName = getInconClassificationName(
                        //   getters,
                        //   findConvertData.itemNo,
                        //   //mod no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
                        //   // response.classCd
                        //   classCd,
                        //   //mod no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
                        //   findConvertDataForTreatDate.ordNo,
                        //   treatmentCd,
                        //   // add FNSI-FutreNetWeb+SI課題管理No.5323 李 start
                        //   response.name
                        //   // add FNSI-FutreNetWeb+SI課題管理No.5323 李 end
                        // );
                        // if (inconClassificationName) response.name = `【${inconClassificationName}】` + response.name;
                        // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                        // add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end

                        // 治療条件の値を格納
                        //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
                        // findConvertDataForTreatDate[`value${i}`] = response.name;
                        // findConvertDataForTreatDate.value1 = response.name;
                        // findConvertDataForTreatDate.value2 = inconClassificationName==null?treatCondItemData.value_name_1:`【${inconClassificationName}】` +treatCondItemData.value_name_1;
                        // findConvertDataForTreatDate[`value${i}`] = i === 1 ? response.name : inconClassificationName == null ? treatCondItemData.value_name_1 : `【${inconClassificationName}】` + treatCondItemData.value_name_1;
                        if (i === 1) {
                          if (findConvertDataForTreatDate.rstDialysisState == "0") {
                            findConvertDataForTreatDate[`value${i}`] = response.name;
                          } else {
                            findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                          }
                        } else {
                          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                          // findConvertDataForTreatDate[`value${i}`] = inconClassificationName == null ? treatCondItemData.value_name_1 : `【${inconClassificationName}】` + treatCondItemData.value_name_1;
                          findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value_name_1;
                          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                        }
                        //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
                        findConvertDataForTreatDate[`isTabooAllergy${i}`] = response.isTabooAllergy;
                        // 使用期限の判定
                        findConvertDataForTreatDate.isExpired = !fitTermCheck(response.useStartDate, response.useEndDate, findConvertDataForTreatDate.treatDate);
                        var numbers = ""
                        var decPoint = ""
                        switch (findConvertData.itemNo) {
                          case 15:
                            // FNSI-修正 マスタ削除の対応 wangchen add start
                            if (findConvertDataForTreatDate.rstDialysisState != "0") {
                              /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                              // 指示：薬剤名
                              if (indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["15"]) {
                                findConvertDataForTreatDate.indMedicineName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["15"].value_name_1;
                              }
                              // 実績：薬剤名
                              if (rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["15"]) {
                                findConvertDataForTreatDate.rstMedicineName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["15"].value_name_1;
                              }
                              /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                            }
                            // FNSI-修正 マスタ削除の対応 wangchen add end
                            // 透析液
                            isCase15[columnName] = treatCondItemData.value;
                            if (isCase17[columnName]) {
                              const temp1 = convertData.find(eleData => {
                                return 17 === eleData.itemNo;
                              });
                              if (!temp1) {
                                return;
                              }
                              const temp2 = temp1.data.find(eleItem => {
                                return eleDate === eleItem.treatDate;
                              });
                              if (!temp2) {
                                return;
                              }
                              if (
                                undefined !== response.unitSecond && null !== response.unitSecond &&
                                "未登録" !== temp2[`value${i}`] && "削除済み" !== temp2[`value${i}`]
                              ) {
                                numbers = String(temp2[`value${i}`]).split('.');
                                decPoint = (numbers[1]) ? numbers[1].length : 0;
                                // mod FNSI-小数点の修正 楊 start
                                // if (decPoint > response.decPointSecond) {
                                if (copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState !== "0") {
                                  // temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed();
                                  //mod 7793 使用数の小数点以下が表示されない 張 start
                                  // temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(decPoint);
                                  temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(response.decPointSecond);
                                  //mod 7793 使用数の小数点以下が表示されない 張 end
                                  // mod FNSI-小数点の修正 楊 end

                                  temp2[`unit${i}`] = ` ${response.unitSecond}`;
                                } else {
                                  temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(response.decPointSecond);
                                  temp2[`unit${i}`] = ` ${response.unitSecond}`;
                                }
                              }
                            }
                            break;

                          case 19:
                            // FNSI-修正 マスタ削除の対応 wangchen add start
                            if (findConvertDataForTreatDate.rstDialysisState != "0") {
                              /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                              // 指示：薬剤名
                              if (indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["19"]) {
                                findConvertDataForTreatDate.indMedicineName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["19"].value_name_1;
                              }
                              // 実績：薬剤名
                              if (rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["19"]) {
                                findConvertDataForTreatDate.rstMedicineName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["19"].value_name_1;
                              }
                              /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                            }
                            // FNSI-修正 マスタ削除の対応 wangchen add end
                            // 補液
                            isCase19[columnName] = treatCondItemData.value;
                            if (isCase22[columnName]) {
                              const temp1 = convertData.find(eleData => {
                                return 22 === eleData.itemNo;
                              });
                              if (!temp1) {
                                return;
                              }
                              const temp2 = temp1.data.find(eleItem => {
                                return eleDate === eleItem.treatDate;
                              });
                              if (!temp2) {
                                return;
                              }
                              /* modify by chamaojia 2024-02-28 [10196] Correction of judgment parameter errors --start */
                              if (
                                undefined !== response.unitSecond &&
                                null !== response.unitSecond &&
                                "未登録" !== temp2[`value${i}`] &&
                                "削除済み" !== temp2[`value${i}`]
                              ) {
                              /* modify by chamaojia 2024-02-28 [10196] Correction of judgment parameter errors --end */
                                numbers = String(temp2[`value${i}`]).split('.');
                                decPoint = (numbers[1]) ? numbers[1].length : 0;
                                // mod FNSI-小数点の修正 楊 start
                                // if (decPoint > response.decPointSecond) {
                                if (copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState !== "0") {
                                  // temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed();
                                  //mod 7793 使用数の小数点以下が表示されない 張 start
                                  // temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(decPoint);
                                  temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(response.decPointSecond);
                                  //mod 7793 使用数の小数点以下が表示されない 張 end
                                  // mod FNSI-小数点の修正 楊 end

                                  temp2[`unit${i}`] = ` ${response.unitSecond}`;
                                } else {
                                  temp2[`value${i}`] = BigNumber(temp2[`value${i}`]).toFixed(response.decPointSecond);
                                  temp2[`unit${i}`] = ` ${response.unitSecond}`;
                                }
                              }
                            }
                            break;

                          case 25:
                            // FNSI-修正 マスタ削除の対応 wangchen add start
                            if (findConvertDataForTreatDate.rstDialysisState != "0") {
                              /* upd EOL対応内部 #7021 by ztc 2023-07-12 --start */
                              // 指示：薬剤名
                              if (indCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["25"]) {
                                findConvertDataForTreatDate.indMedicineName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].indCondInfo)["25"].value_name_1;
                              }
                              // 実績：薬剤名
                              if (rstCondInfoFlag && JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["25"]) {
                                findConvertDataForTreatDate.rstMedicineName = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstCondInfo)["25"].value_name_1;
                              }
                              /* upd EOL対応内部 #7021 by ztc 2023-07-12 --end */
                            }
                            // FNSI-修正 マスタ削除の対応 wangchen add end
                            // 抗凝固剤
                            isCase25[columnName] = treatCondItemData.value;
                            for (let j = 0; j < 3; j++) {
                              temp1 = null;
                              if (isCase26[columnName] && 0 === j) {
                                // 抗凝固剤ワンショット量
                                temp1 = convertData.find(eleData => {
                                  return 26 === eleData.itemNo;
                                });
                              } else if (isCase27[columnName] && 1 === j) {
                                // 抗凝固剤持続速度
                                temp1 = convertData.find(eleData => {
                                  return 27 === eleData.itemNo;
                                });
                              } else if (isCase28[columnName] && 2 === j) {
                                // 抗凝固剤持続総
                                temp1 = convertData.find(eleData => {
                                  return 28 === eleData.itemNo;
                                });
                              }
                              if (!temp1) {
                                continue;
                              }
                              const temp2 = temp1.data.find(eleItem => {
                                return eleDate === eleItem.treatDate;
                              });
                              if (!temp2) {
                                continue;
                              }
                              if (
                                undefined !== response.unit &&
                                null !== response.unit &&
                                "未登録" !== temp2[`value${i}`] &&
                                "削除済み" !== temp2[`value${i}`]
                              ) {
                                temp2[`value${i}`] = (BigNumber(temp2[`value${i}`]).toFixed());
                                temp2[`unit${i}`] = 1 === j ? ` ${response.unit}/h` : ` ${response.unit}`;
                              }
                            }
                            break;
                        }
                      }
                    });
                  }
                }
                break;

              case 17:
                // 透析液使用数
                findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value;
                findConvertDataForTreatDate[`unit${i}`] = treatCondItemData.unit;
                //unitデータがあれば通知後データなのでマスタ参照してvalue値の小数点桁数を取得
                isCase17[columnName] = true;
                if (
                  undefined !== isCase15[columnName] &&
                  null !== isCase15[columnName]
                ) {
                  dispatch("getMstRecordInState", {
                    mstClass: 7,
                    code: isCase15[columnName],
                    notExistReturnValue: "削除済み"
                  }).then(response => {
                    // 透析液の薬剤の単位を付与
                    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
                    // if (undefined !== response.unitSecond && null !== response.unitSecond) {
                      var numbers = String(treatCondItemData.value).split('.');
                      var decPoint = (numbers[1]) ? numbers[1].length : 0;
                      // mod FNSI-小数点の修正 楊 start
                      // if(decPoint > response.decPointSecond){
                    if (copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState !== "0") {
                      // findConvertDataForTreatDate[`value${i}`] = BigNumber(findConvertDataForTreatDate[`value${i}`]).toFixed();
                      findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value;
                      // mod FNSI-小数点の修正 楊 end
                    } else {
                      if (decPoint > response.decPointSecond) {
                        let numTemp = BigNumber(treatCondItemData.value).toFixed();
                        let numSplit = numTemp.split('.');
                        let decTempPoint = (numSplit[1]) ? numSplit[1].length : 0;
                        if (decTempPoint > response.decPointSecond) {
                          findConvertDataForTreatDate[`value${i}`] = numTemp;
                        } else {
                          findConvertDataForTreatDate[`value${i}`] = BigNumber(treatCondItemData.value).toFixed(response.decPointSecond);
                        }
                      } else {
                        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                        // findConvertDataForTreatDate[`value${i}`] = BigNumber(treatCondItemData.value).toFixed(response.decPointSecond);
                        findConvertDataForTreatDate[`value${i}`] = response.decPoint ? BigNumber(treatCondItemData.value).toFixed(response.decPointSecond) : treatCondItemData.value;
                        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                      }
                    }
                      // データがセットされていない場合のみマスタ値セット
                      if(findConvertDataForTreatDate[`unit${i}`] == null){
                        findConvertDataForTreatDate[`unit${i}`] = ` ${response.unitSecond??""}`;
                      }
                    // }
                    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
                  });
                }
                break;

//add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
              case 18:
              case 23:
                // 18:透析液温度,23:補液温度
                findConvertDataForTreatDate[
                  `value${i}`
                  // mod #IES_6501 dou start
                  // ] = `${treatCondItemData.value.toFixed(1)} ℃`;
                  ] = `${treatCondItemData.value} ℃`;
                // mod #IES_6501 dou end
                break;
//add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
              case 20: // 20:補液量
                if(treatCondItemData.value == '-1'){ // mod #9973 value Number→文字列  shiyw
                  findConvertDataForTreatDate[`value${i}`] = "濾過率から算出";
                }else{
                  findConvertDataForTreatDate[
                    `value${i}`
                    // mod #IES_6501 dou start
                    // ] = `${treatCondItemData.value.toFixed(1)} L`;
                    ] = `${treatCondItemData.value} L`;
                  // mod #IES_6501 dou end
                }
                // mod #7194 2022/8/29 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 gaoey end
                break;

              case 21:
                // 補液選択
                if ('0' == treatCondItemData.value) { // mod #9973 value Number→文字列  shiyw
                  treatCondValue = "後補液";
                } else if ('1' == treatCondItemData.value) { // mod #9973 value Number→文字列  shiyw
                  treatCondValue = "前補液";
                } else {
                  treatCondValue = "未登録";
                }
                // 治療条件の値を格納
                findConvertDataForTreatDate[`value${i}`] = treatCondValue;
                break;

              case 22:
                // 補液使用数
                findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value;
                findConvertDataForTreatDate[`unit${i}`] = treatCondItemData.unit;

                //if(treatCondItemData.unit){
                //  findConvertDataForTreatDate[`value${i}`] +=
                //  ` ${treatCondItemData.unit}`;
                //}
                isCase22[columnName] = true;
                if (
                  undefined !== isCase19[columnName] &&
                  null !== isCase19[columnName]
                ) {
                  dispatch("getMstRecordInState", {
                    mstClass: 7,
                    code: isCase19[columnName],
                    notExistReturnValue: "削除済み"
                  }).then(response => {
                    // 透析液の薬剤の単位を付与
                    //del #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 20240513 zhaoqi start
                    // if (undefined !== response.unitSecond && null !== response.unitSecond) {
                    //del #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 20240513 zhaoqi end
                      //del #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 20240513 zhaoqi start
                      //   var numbers = String(findConvertDataForTreatDate[`value${i}`]).split('.');
                      //del #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 20240513 zhaoqi end
                      //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 20240513 zhaoqi start
                      var numbers = String(treatCondItemData.value).split('.');
                      //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 20240513 zhaoqi end
                      var decPoint = (numbers[1]) ? numbers[1].length : 0;
                      // mod FNSI-小数点の修正 楊 start
                      // if(decPoint > response.decPointSecond){
                      if(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState !== "0"){
                        //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
                        // findConvertDataForTreatDate[`value${i}`] = BigNumber(findConvertDataForTreatDate[`value${i}`]).toFixed();
                        findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value;
                        // mod FNSI-小数点の修正 楊 end
                        //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
                      }else{
                        //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
                        if (decPoint > response.decPointSecond) {
                          let numTemp = BigNumber(treatCondItemData.value).toFixed();
                          let numSplit = numTemp.split('.');
                          let decTempPoint = (numSplit[1]) ? numSplit[1].length : 0;
                          if (decTempPoint > response.decPointSecond) {
                            findConvertDataForTreatDate[`value${i}`] = numTemp;
                          } else {
                            findConvertDataForTreatDate[`value${i}`] = BigNumber(treatCondItemData.value).toFixed(response.decPointSecond);
                          }
                        } else {
                          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                          // findConvertDataForTreatDate[`value${i}`] = BigNumber(treatCondItemData.value).toFixed(response.decPointSecond);
                          findConvertDataForTreatDate[`value${i}`] = response.decPoint ? BigNumber(treatCondItemData.value).toFixed(response.decPointSecond) : treatCondItemData.value;
                          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                        }
                        //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
                          }
                      // データがセットされていない場合のみマスタ値セット
                      if(findConvertDataForTreatDate[`unit${i}`] == null){
                        findConvertDataForTreatDate[`unit${i}`] = ` ${response.unitSecond??""}`;
                      }
                    //del #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 20240513 zhaoqi start
                    // }
                    //del #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 20240513 zhaoqi end
                  });
                }
                break;
//add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
              case 24:
                // 補液速度
                //mod FNSI-7194 劉全航 start
                // findConvertDataForTreatDate[
                //   `value${i}`
                // ] = `${treatCondItemData.value.toFixed(2)} L/h`;
                if(treatCondItemData.value == '-1'){ // mod #9973 value Number→文字列  shiyw
                  findConvertDataForTreatDate[`value${i}`] = "濾過率から算出";
                }else{
                  findConvertDataForTreatDate[
                    `value${i}`
                    // mod #IES_6501 dou start
                    // ] = `${treatCondItemData.value.toFixed(2)} L/h`;
                    ] = `${treatCondItemData.value} L/h`;
                  // mod #IES_6501 dou end
                }
                //mod FNSI-7194 劉全航 end
                break;
//add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
              case 26:
              case 27:
              case 28:
                // 26:抗凝固剤ワンショット量、27:抗凝固剤持続速度、28:抗凝固剤持続総量
                findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value;
                findConvertDataForTreatDate[`unit${i}`] = treatCondItemData.unit;
                // del #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
                //add FNSI-5553 劉全航 start
                // if(findConvertData.itemNo === 27 && findConvertDataForTreatDate[`unit${i}`] == null){
                //   findConvertDataForTreatDate[`unit${i}`] = "/h";
                // }
                //add FNSI-5553 劉全航 end
                // del #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
                isCase26[columnName] =
                  26 === findConvertData.itemNo ? true : isCase26[columnName];
                isCase27[columnName] =
                  27 === findConvertData.itemNo ? true : isCase27[columnName];
                isCase28[columnName] =
                  28 === findConvertData.itemNo ? true : isCase28[columnName];
                if (
                  undefined !== isCase25[columnName] &&
                  null !== isCase25[columnName]
                ) {
                  dispatch("getMstRecordInState", {
                    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
                    mstClass: indCondInfo[25].medicine_type == 2?9:7,
                    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
                    code: isCase25[columnName],
                    notExistReturnValue: "削除済み"
                  }).then(response => {
                    // 透析液の薬剤の単位を付与
                    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 start
                    // if (undefined !== response.unit && null !== response.unit) {
                      var numbers = String(treatCondItemData.value).split('.');
                      var decPoint = (numbers[1]) ? numbers[1].length : 0;
                      // mod FNSI-小数点の修正 楊 start
                      // if(decPoint > response.decPointSecond){
                      if(copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState !== "0"){
                        // findConvertDataForTreatDate[`value${i}`] = BigNumber(findConvertDataForTreatDate[`value${i}`]).toFixed();
                        findConvertDataForTreatDate[`value${i}`] = treatCondItemData.value;
                        // mod FNSI-小数点の修正 楊 end
                      }else{
                        if (decPoint > response.decPoint) {
                          let numTemp = BigNumber(treatCondItemData.value).toFixed();
                          let numSplit = numTemp.split('.');
                          let decTempPoint = (numSplit[1]) ? numSplit[1].length : 0;
                          if (decTempPoint > response.decPoint) {
                            findConvertDataForTreatDate[`value${i}`] = numTemp;
                          } else {
                            findConvertDataForTreatDate[`value${i}`] = BigNumber(treatCondItemData.value).toFixed(response.decPoint);
                          }
                        } else {
                          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                          // findConvertDataForTreatDate[`value${i}`] = BigNumber(treatCondItemData.value).toFixed(response.decPoint);
                          findConvertDataForTreatDate[`value${i}`] =  response.decPoint ? BigNumber(treatCondItemData.value).toFixed(response.decPoint) : treatCondItemData.value;
                          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
                        }
                          }
                      // データがセットされていない場合のみマスタ値セット
                      if(findConvertDataForTreatDate[`unit${i}`] == null && response.unit !== null && response.unit !== undefined){
                        findConvertDataForTreatDate[`unit${i}`] = 27 === findConvertData.itemNo
                          ? ` ${response.unit}/h`
                          : ` ${response.unit}`;
                      }
                    // }
                    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240516 end
                  });
                }
                break;

              case 30:
              case 34:
                // 30:IPスタート、34:IPワンショットスタート
                if ('0' == treatCondItemData.value) { // mod #9973 value Number→文字列  shiyw
                  treatCondValue = "手動";
                } else if ('1' == treatCondItemData.value) { // mod #9973 value Number→文字列  shiyw
                  treatCondValue = "自動";
                } else {
                  treatCondValue = "未登録";
                }
                findConvertDataForTreatDate[`value${i}`] = treatCondValue;
                break;

              case 31:
                // IPワンショット量
                findConvertDataForTreatDate[
                  `value${i}`
                  //mod FNSI-5989 劉全航 start
                  // ] = `${treatCondItemData.value.toFixed(1)} mL`;
                  // mod #IES_6501 dou start
                  // ] = `${Number.parseFloat(treatCondItemData.value.toFixed(2)).toFixed(1)} mL`;
                    /* upd EOL対応内部 #7021 by ztc 2023-07-09 --start */
                  // ] = `${toFixed(Number.parseFloat(parseFloat(treatCondItemData.value).toFixed(2)), 1)} mL`;
                  ] = `${treatCondItemData.value} mL`;
                /* upd EOL対応内部 #7021 by ztc 2023-07-09 --end */
                // mod #IES_6501 dou end
                //mod FNSI-5989 劉全航 end
                break;

              case 32:
              case 33:
                // 32:IP速度、33:IP速度最大値
                findConvertDataForTreatDate[
                  `value${i}`
                  // mod #IES_6501 dou start
                  // ] = `${Number.parseFloat(treatCondItemData.value.toFixed(2)).toFixed(1)} mL/h`;
                    /* upd EOL対応内部 #7021 by ztc 2023-07-09 --start */
                  // ] = `${toFixed(Number.parseFloat(parseFloat(treatCondItemData.value).toFixed(2)),1)} mL/h`;
                  ] = `${treatCondItemData.value} mL/h`;
                /* upd EOL対応内部 #7021 by ztc 2023-07-09 --end */
                // mod #IES_6501 dou end
                break;

              case 35:
              case 37:
                // 35:IP電源自動切り、37:IP電源OKモニタ切り
                if ('1' == treatCondItemData.value) { // mod #9973 value Number→文字列  shiyw
                  treatCondValue = "入";
                } else if ('0' == treatCondItemData.value) { // mod #9973 value Number→文字列  shiyw
                  treatCondValue = "切";
                } else {
                  treatCondValue = "未登録";
                }
                // 治療条件の値を格納
                findConvertDataForTreatDate[`value${i}`] = treatCondValue;
                break;

              case 36:
              case 38:
                // 36:IP電源自動切り時間、38:IP電源OK自動切り時間
                findConvertDataForTreatDate[
                  `value${i}`
                  ] = `${treatCondItemData.value} 分`;
                break;

              default:
                // 治療条件の値を格納
                findConvertDataForTreatDate[`value${i}`] =
                  treatCondItemData.value;
                break;
            }
          }
        });
      });
      return convertData;
    },

    /**
     * 治療方法データを表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     * @param {Boolean} isMakeStructionColorData 文字色変更用データ取得(既定値：false)
     */
    async convertTreatMethodData(
      { getters, dispatch, commit },
      { listIndex, selectLayoutCd, isMakeStructionColorData = false }
    ) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      let searchDateList = [];
      // ord_main
      let copyTreatmentData = []
      // 文字色変更用データ取得有の場合
      if (isMakeStructionColorData) {
        // 治療日一覧の取得
        const searchDateListTmp = getters.getDateList;
        // 左端画面表示治療日 - 7
        for (let i = -7; i < 0; i++) {
          searchDateList.push(moment(searchDateListTmp[0]).add(i, "days").format("YYYYMMDD"));
        }
        // 画面表示治療日
        searchDateListTmp.forEach(item => {
          searchDateList.push(item);
        });
        // 右端画面表示治療日 + 7
        for (let i = 1; i < 8; i++) {
          searchDateList.push(moment(searchDateList[searchDateList.length - 1]).add(1, "days").format("YYYYMMDD"));
        }
        // ord_mainの取得
        copyTreatmentData = getters.getTreatmentDataTmp[listIndex];
      } else {
        searchDateList = getters.getDateList;
        copyTreatmentData = getters.getTreatmentData[listIndex];
      }

      // 治療方法マスタの取得
      let response = getters.getMstTreatmentData;

      // ord_main = NULLの場合
      if (!copyTreatmentData) {
        return [];
      }

      // 検索用表示項目リスト(治療情報-治療方法)の取得
      const searchDispLayoutItemList = await dispatch(
        "getDispLayoutItemForSubCategory",
        {
          layoutCd: selectLayoutCd,
          categoryNo: 1, // 治療情報
          subCategoryNo: 2 // 治療方法
        }
      );
      if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
        return [];
      }

      // 表示用データの作成
      searchDispLayoutItemList.forEach(eleDispItem => {
        // 対象番号の表示項目を抽出
        let findConvertData = convertData.find(item => {
          return eleDispItem.itemNo === item.itemNo;
        });

        // 対象番号が存在しない場合、雛形構造を追加
        if (!findConvertData) {
          const temp = deepCopy(layoutDispData);
          temp.itemNo = eleDispItem.itemNo;
          temp.itemName = eleDispItem.itemName;
          findConvertData = temp;
          convertData.push(findConvertData);
        }

        // 表示分日付(期間)ループ
        searchDateList.forEach(eleDate => {
          // 対象日付の抽出
          let findConvertDataForTreatDate = findConvertData.data.find(item => {
            return item.treatDate === eleDate;
          });
          // 対象日付のデータが存在しない場合、雛形構造を追加
          if (!findConvertDataForTreatDate) {
            const temp = deepCopy(layoutDispData_data);
            temp.treatDate = eleDate;
            findConvertDataForTreatDate = temp;
            findConvertData.data.push(findConvertDataForTreatDate);
          }

          // 対象日付に治療情報が存在するかを確認
          if (!copyTreatmentData[findConvertDataForTreatDate.treatDate]) {
            return; // forEachでのcontinueの代替
          }

          // オーダ番号を格納
          findConvertDataForTreatDate.ordNo =
            copyTreatmentData[findConvertDataForTreatDate.treatDate].ordNo;

          // add FNSI-マスタ削除表示の対応課題--治療方法 李 start
          // 治療状況
          findConvertDataForTreatDate.rstDialysisState = copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState;
          // 指示：治療方法名
          findConvertDataForTreatDate.indTreatmentName = copyTreatmentData[findConvertDataForTreatDate.treatDate].indTreatmentName;
          // 実績：治療方法名
          findConvertDataForTreatDate.rstTreatmentName = copyTreatmentData[findConvertDataForTreatDate.treatDate].rstTreatmentName;
          // add FNSI-マスタ削除表示の対応課題--治療方法 李 end
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const indCondInfo = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate]['indCondInfo']);
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          for (let i = 1; i <= 2; i++) {
            const columnName = 1 === i ? "indTreatmentCd" : "rstTreatmentCd";
            // 治療方法項目が存在する場合、その値を格納
            const treatMethodCd =
              copyTreatmentData[findConvertDataForTreatDate.treatDate][
                columnName
                ];
            if (undefined === treatMethodCd || null === treatMethodCd) {
              // 治療方法名を未登録として設定
              findConvertDataForTreatDate[`value${i}`] = "未登録";
              // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
              if (columnName === 'indTreatmentCd' && !indCondInfo && findConvertDataForTreatDate?.rstDialysisState > 0) {
                findConvertDataForTreatDate[`value${i}`] = null;
                findConvertDataForTreatDate.isDisabled1 = true;
              }
              // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
            } else {
              // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
              findConvertDataForTreatDate.treatMethodCd = treatMethodCd;
              const treatMethodInfo = response.find(i => {
                return i.treatmentCd === treatMethodCd;
              });
              if (treatMethodInfo !== undefined) {
                findConvertDataForTreatDate.deviceMode = treatMethodInfo.deviceMode;
              }
              // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
              // 治療方法名をマスタから取得(マスタに存在しない場合は"削除済み"とする)
              if (copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly) {
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                // const param = {
                //   treatmentCd: treatMethodCd
                // }
                // ApiHelper.get("/mstInfo/mstTreatment/getTreatmentName", param).then((res) => {
                //   findConvertDataForTreatDate[`value${i}`] = res.data;
                // });

                const treatmentName = 1 === i ? findConvertDataForTreatDate.indTreatmentName : findConvertDataForTreatDate.rstTreatmentName;
                findConvertDataForTreatDate[`value${i}`] = treatmentName;
                /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                findConvertDataForTreatDate.isNotClickable = true;
              } else {
                dispatch("getMstRecordInState", {
                  mstClass: 1,
                  code: treatMethodCd,
                  notExistReturnValue: "削除済み"
                }).then(response => {
                  //mod FNSI-5678 劉全航 start
                  // findConvertDataForTreatDate[`value${i}`] = response.name;
                  // findConvertDataForTreatDate.isNotClickable = false;
                  if(findConvertDataForTreatDate.rstTreatmentName){
                    // mod 9339
                    // findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstTreatmentName;
                    findConvertDataForTreatDate.value1 = findConvertDataForTreatDate.indTreatmentName;
                    findConvertDataForTreatDate.value2 = findConvertDataForTreatDate.rstTreatmentName;
                    // mod 9339
                    findConvertDataForTreatDate.isNotClickable = false;
                  }else{
                    findConvertDataForTreatDate[`value${i}`] = response.name;
                    findConvertDataForTreatDate.isNotClickable = false;
                  }
                  //mod FNSI-5678 劉全航 end
                });
              }
            }
          }
        });
      });

      return convertData;
    },

    /**
     * スケジュールデータを表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     * @param {Boolean} isMakeStructionColorData 文字色変更用データ取得(既定値：false)
     */
    async convertScheduleData(
      { getters, dispatch, commit },
      { listIndex, selectLayoutCd, isMakeStructionColorData = false }
    ) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      let searchDateList = [];
      // ord_main
      let copyTreatmentData = [];
      // 文字色変更用データ取得有の場合
      if (isMakeStructionColorData) {
        // 治療日一覧の取得
        const searchDateListTmp = getters.getDateList;
        // 左端画面表示治療日 - 7
        for (let i = -7; i < 0; i++) {
          searchDateList.push(moment(searchDateListTmp[0]).add(i, "days").format("YYYYMMDD"));
        }
        // 画面表示治療日
        searchDateListTmp.forEach(item => {
          searchDateList.push(item);
        });
        // 右端画面表示治療日 + 7
        for (let i = 1; i < 8; i++) {
          searchDateList.push(moment(searchDateList[searchDateList.length - 1]).add(1, "days").format("YYYYMMDD"));
        }
        // ord_mainの取得
        copyTreatmentData = getters.getTreatmentDataTmp[listIndex];
      } else {
        searchDateList = getters.getDateList;
        copyTreatmentData = getters.getTreatmentData[listIndex];
      }

      // 治療方法マスタの取得
      let response = getters.getMstTreatmentData;

      // ord_main = NULLの場合
      if (!copyTreatmentData) {
        return [];
      }

      // 検索用表示項目リスト(治療情報-スケジュール)の取得
      const searchDispLayoutItemList = await dispatch(
        "getDispLayoutItemForSubCategory",
        {
          layoutCd: selectLayoutCd,
          categoryNo: 1, // 治療情報
          subCategoryNo: 3 // スケジュール
        }
      );
      if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
        return [];
      }

      // 表示用データの作成
      searchDispLayoutItemList.forEach(eleDispItem => {
        // 対象番号の表示項目を抽出
        let findConvertData = convertData.find(item => {
          return eleDispItem.itemNo === item.itemNo;
        });

        // 対象番号が存在しない場合、雛形構造を追加
        if (!findConvertData) {
          const temp = deepCopy(layoutDispData);
          temp.itemNo = eleDispItem.itemNo;
          temp.itemName = eleDispItem.itemName;
          findConvertData = temp;
          convertData.push(findConvertData);
        }

        // 表示分日付(期間)ループ
        searchDateList.forEach(eleDate => {
          // 対象日付の抽出
          let findConvertDataForTreatDate = findConvertData.data.find(item => {
            return item.treatDate === eleDate;
          });
          // 対象日付のデータが存在しない場合、雛形構造を追加
          if (!findConvertDataForTreatDate) {
            const temp = deepCopy(layoutDispData_data);
            temp.treatDate = eleDate;
            findConvertDataForTreatDate = temp;
            findConvertData.data.push(findConvertDataForTreatDate);
          }

          // 対象日付に治療情報が存在するかを確認
          if (!copyTreatmentData[findConvertDataForTreatDate.treatDate]) {
            return; // forEachでのcontinueの代替
          }
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
          const treatMethodCd = copyTreatmentData[findConvertDataForTreatDate.treatDate].indTreatmentCd;
          findConvertDataForTreatDate.treatMethodCd = treatMethodCd;
          const treatMethodInfo = response.find(i => {
            return i.treatmentCd === treatMethodCd;
          });
          if (treatMethodInfo !== undefined) {
            findConvertDataForTreatDate.deviceMode = treatMethodInfo.deviceMode;
          }
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

          // オーダ番号を格納
          findConvertDataForTreatDate.ordNo = copyTreatmentData[findConvertDataForTreatDate.treatDate].ordNo;
          findConvertDataForTreatDate.isNotClickable = copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly;

          // FNSI-修正 マスタ削除の対応 wangchen add start
          // 治療状況
          findConvertDataForTreatDate.rstDialysisState = copyTreatmentData[findConvertDataForTreatDate.treatDate].rstDialysisState;
          if(findConvertDataForTreatDate.rstDialysisState!="0"){
            if(eleDispItem.itemName=="クール"){
              // 指示：クール名
              findConvertDataForTreatDate.indKurName = copyTreatmentData[findConvertDataForTreatDate.treatDate].indKurName;
              // 実績：クール名
              findConvertDataForTreatDate.rstKurName = copyTreatmentData[findConvertDataForTreatDate.treatDate].rstKurName;
            }else if(eleDispItem.itemName=="ベッド"){
              // 指示：ベッド名
              findConvertDataForTreatDate.indBedName = copyTreatmentData[findConvertDataForTreatDate.treatDate].indBedName;
              // 実績：ベッド名
              findConvertDataForTreatDate.rstBedName = copyTreatmentData[findConvertDataForTreatDate.treatDate].rstBedName;
            }
          }
          // FNSI-修正 マスタ削除の対応 wangchen add end

          // 対象スケジュールデータが存在する場合、その値を格納
          let code;
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const indCondInfo = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate]['indCondInfo']);
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          switch (findConvertData.itemNo) {
            case 1:
              for (let i = 1; i <= 2; i++) {
                const columnName = 1 === i ? "indKurCd" : "rstKurCd";
                // クール
                code =
                  copyTreatmentData[findConvertDataForTreatDate.treatDate][
                    columnName
                    ];
                // add FNSI-マスタ削除表示の対応課題--クール 鄧シン start
                findConvertDataForTreatDate[`kurCd${i}`] = code;
                // add FNSI-マスタ削除表示の対応課題--クール 鄧シン end
                if (undefined === code || null === code || 0 === code) {
                  findConvertDataForTreatDate[`value${i}`] = "未登録";
                  // add FNSI-マスタ削除表示の対応課題--クール 鄧シン end
                  // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
                  if (columnName === 'indKurCd' && !indCondInfo && findConvertDataForTreatDate?.rstDialysisState > 0) {
                    findConvertDataForTreatDate[`value${i}`] = null;
                    findConvertDataForTreatDate.isDisabled1 = true;
                  }
                  // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
                } else {
                  // クール名をマスタから取得(マスタに存在しない場合は"削除済み"とする)
                  if (copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly) {
                    /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                    // const param = {
                    //   kurCd: code
                    // }
                    // ApiHelper.get("/mstInfo/mstKur/getKurName", param).then((res) => {
                    //   findConvertDataForTreatDate[`value${i}`] = res.data;
                    // });

                    const kurName = 1 === i ? copyTreatmentData[findConvertDataForTreatDate.treatDate].indKurName 
                                            : copyTreatmentData[findConvertDataForTreatDate.treatDate].rstKurName;
                    findConvertDataForTreatDate[`value${i}`] = kurName;
                    /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                  } else {
                    dispatch("getMstRecordInState", {
                      mstClass: 2,
                      code,
                      notExistReturnValue: "削除済み"
                    }).then(response => {
                      // スケジュール(クール)の値を格納
                      // findConvertDataForTreatDate[`value${i}`] = response.name;
                      if (i === 1) {
                        if (findConvertDataForTreatDate.rstDialysisState == "0") {
                          findConvertDataForTreatDate[`value${i}`] = response.name;
                        } else {
                          findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.indKurName;
                        }
                      } else {
                        findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstKurName;
                      }
                    });
                  }
                }
              }
              break;

            case 2:
              for (let i = 1; i <= 2; i++) {
                const columnName =
                  1 === i ? "indTreatStartTime" : "rstStartDate";
                // 治療開始時刻
                code =
                  copyTreatmentData[findConvertDataForTreatDate.treatDate][
                    columnName
                    ];
                if (undefined === code || null === code || 0 === code) {
                  findConvertDataForTreatDate[`value${i}`] = "未登録";
                  // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
                  if (columnName === 'indTreatStartTime' && !indCondInfo && findConvertDataForTreatDate?.rstDialysisState > 0) {
                    findConvertDataForTreatDate[`value${i}`] = null;
                    findConvertDataForTreatDate.isDisabled1 = true;
                  }
                  // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
                } else {
                  // スケジュール(治療開始時刻)の値を格納
                  findConvertDataForTreatDate[`value${i}`] =
                    1 === i
                      ? moment(code, "HHmm").format("HH:mm")
                      : moment(code).format("HH:mm");
                }
              }
              break;

            case 3:
              // ベッド
              for (let i = 1; i <= 2; i++) {
                const columnName = 1 === i ? "indBedCd" : "rstBedCd";
                code =
                  copyTreatmentData[findConvertDataForTreatDate.treatDate][
                    columnName
                    ];
                if (undefined === code || null === code || 0 === code) {
                  findConvertDataForTreatDate[`value${i}`] = "未登録";
                  // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
                  if (columnName === 'indBedCd' && !indCondInfo && findConvertDataForTreatDate?.rstDialysisState > 0) {
                    findConvertDataForTreatDate[`value${i}`] = null;
                    findConvertDataForTreatDate.isDisabled1 = true;
                  }
                  // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
                } else {
                  // ベッド名をマスタから取得(マスタに存在しない場合は"削除済み"とする)
                  if (copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly) {
                    /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                    // const param = {
                    //   bedCd: code
                    // }
                    // ApiHelper.get("/mstInfo/mstBed/getBedName", param).then((res) => {
                    //   findConvertDataForTreatDate[`value${i}`] = res.data;
                    // });
                    const bedName = 1 === i ? copyTreatmentData[findConvertDataForTreatDate.treatDate].indBedName 
                                            : copyTreatmentData[findConvertDataForTreatDate.treatDate].rstBedName;
                    findConvertDataForTreatDate[`value${i}`] = bedName;
                    /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

                  } else {
                    dispatch("getMstRecordInState", {
                      mstClass: 3,
                      code,
                      notExistReturnValue: "【削除済み】"
                    }).then(response => {
                      // スケジュール(ベッド)の値を格納
                      //add FNSI-6777 ljx start
                      // 総合ビューアには、実績の場合、ベット名称がマスタではなく、ord_mainのrst_bed_nameより取得。
                      // if(i==2){//実績の場合
                      //   const rstBedNameView = copyTreatmentData[findConvertDataForTreatDate.treatDate]["rstBedName"]
                      //   findConvertDataForTreatDate[`value${i}`] = rstBedNameView;
                      // }else{
                      //   findConvertDataForTreatDate[`value${i}`] = response.name;
                      // }
                      // findConvertDataForTreatDate[`value${i}`] = response.name;
                      //add FNSI-6777 ljx end
                      if (i === 1) {
                        if (findConvertDataForTreatDate.rstDialysisState == "0") {
                          findConvertDataForTreatDate[`value${i}`] = response.name;
                        } else {
                          findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.indBedName;
                        }
                      } else {
                        findConvertDataForTreatDate[`value${i}`] = findConvertDataForTreatDate.rstBedName;
                      }
                    });
                  }
                }
              }
              break;

            default:
              return null;
          }
        });
      });

      return convertData;
    },

    /**
     * 投与薬剤データを表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     * @param {Boolean} isMakeStructionColorData 文字色変更用データ取得(既定値：false)
     */
    async convertMedicinetData(
      { getters, dispatch, commit, state },
      { listIndex, selectLayoutCd, isMakeStructionColorData = false }
    ) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      // const searchDateList = getters.getDateList;
      // ord_main
      let copyTreatmentData = [];
      // 文字色変更用データ取得有の場合
      if (isMakeStructionColorData) {
        copyTreatmentData = getters.getTreatmentDataTmp[listIndex];
      } else {
        copyTreatmentData = getters.getTreatmentData[listIndex];
      }

      // 治療方法マスタの取得
      let response = getters.getMstTreatmentData;

      // ord_main = NULLの場合
      if (!copyTreatmentData) {
        return [];
      }

      // 検索用表示項目リスト(治療情報-投与薬剤)の取得
      const searchDispLayoutItemList = await dispatch(
        "getDispLayoutItemForSubCategory",
        {
          layoutCd: selectLayoutCd,
          categoryNo: 1, // 治療情報
          subCategoryNo: 5 // 投与薬剤
        }
      );

      // 項目列に「投与薬剤分類名」か「投与薬剤名」かを表示する
      const isDisplayClassName =
        searchDispLayoutItemList[0].itemNo === 1 ? false : true;
      // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
      const tableName = "mst_medicine_class";
      const mstselector = await ApiHelper.get(
        `/report_designer/master/${tableName}`
      ).catch(err => {
        throw err;
      });
      // 表示用データの作成
      for (const treatData in copyTreatmentData) {
        const ordInfo = copyTreatmentData[treatData];

        // 治療情報が存在しないか存在する治療情報に医療材料データがない場合
        if (!ordInfo || (!ordInfo.indMediInfo && !ordInfo.rstMediInfo)) {
          continue;
        }

        const indMediInfo = JSON.parse(ordInfo.indMediInfo);
        const rstMediInfo = JSON.parse(ordInfo.rstMediInfo);
        // 指示の投与薬剤を識別番号で絞り込んで取得
        if (indMediInfo) {
          for (let i = 0; i < indMediInfo.length; i++) {
            const mediCurrent = indMediInfo[i];
            const mediFind = convertData.find(item => {
              // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 start
              // return item.itemNo === mediCurrent.no;
              return item.itemNo === mediCurrent.no && item.cd === mediCurrent.cd;
              // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 end
            });

            // 対象番号の表示項目が存在しない場合のみ作成して追加する
            if (!mediFind) {
              // mod #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
              // const mediMst = await dispatch("getMstRecordInState", {
              let mediMst = await dispatch("getMstRecordInState", {
                // mod #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
                // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
                mstClass: mediCurrent.medicine_type == 2 ? 11 : 10,
                code: mediCurrent.cd,
                notExistReturnValue: "削除済み",
                // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
                treatDate: treatData
                // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
              });
              const mediClassMst = await dispatch("getMstRecordInState", {
                mstClass: 8,
                code: mediMst.classCd,
                notExistReturnValue: "未分類"
              });
              // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
              let classCdIndex = mstselector.data.findIndex(el => el.code == mediMst.classCd);
              // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
              // 投与タイミングマストのデータ
              const timingMst = getters.getMstMedicateTimingData.find(mstData => {
                return mstData.medicateTimingCd === mediCurrent.timing_cd;
              });
              // 手技マストのデータ
              const procedureMst = getters.getMstProcedureData.find(mstData => {
                return mstData.procedureCd === mediCurrent.procedure_cd;
              });
              // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
              // 項目列に「投与薬剤分類名」を表示する場合、日付列に「投与薬剤名」を表示する
              
              /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
              if (ordInfo.readOnly) {
                mediCurrent.name = indMediInfo[i].name;
                mediCurrent.unit = indMediInfo[i].unit;
                mediCurrent.class_name = indMediInfo[i].class_name;
                mediCurrent.decPoint = indMediInfo[i].decPoint;
                mediCurrent.isTabooAllergy = isTabooAllergy(indMediInfo[i].name);
                if (ordInfo.rstDialysisState == "0") {
                  if (mediCurrent.medicine_type == 2) {   // 調製薬剤 
                    const medicineMixData = getters.getMstMedicineMixData.find(item =>
                          item.medicineMixCd == mediCurrent.cd
                    );
                    if (medicineMixData) {
                      const mixInfo = JSON.parse(medicineMixData.mixInfo)
                      let taboo = false;
                      let allergy = false;
                      for (let medicineData of mixInfo) {
                        const tabooAllergyInfo = getters.getPatTabooAllergy.find(item =>
                          item.patId == ordInfo.patId &&
                          item.classType == "1" &&
                          item.cd == medicineData.cd
                        );

                        if (tabooAllergyInfo) {
                          if (tabooAllergyInfo.taboo) {
                            taboo = true;
                          }
                          if (tabooAllergyInfo.allergy) {
                            allergy = true;
                          }
                        }

                        if (taboo && allergy) break;
                      }

                      if (taboo || allergy) {
                        mediCurrent.isTabooAllergy = true;
                        mediCurrent.name = getTabooAllergyPrefix(taboo, allergy) + indMediInfo[i].name
                      }
                    }
                  } else {  // 薬剤
                    const tabooAllergyInfo = getters.getPatTabooAllergy.find(item =>
                      item.patId == ordInfo.patId &&
                      item.classType == "1" &&
                      item.cd == mediCurrent.cd
                    );
                    if (tabooAllergyInfo) {
                      mediCurrent.isTabooAllergy = true;
                      mediCurrent.name = getTabooAllergyPrefix(tabooAllergyInfo.taboo, tabooAllergyInfo.allergy) + indMediInfo[i].name
                    }
                  }
                }
              } else {
                if (isDisplayClassName) {
                  if (ordInfo.rstDialysisState == "0") {
                    mediCurrent.name = mediMst.name;
                    mediCurrent.unit = mediMst.unit;
                    mediCurrent.class_name = mediClassMst.name;
                  }
                  mediCurrent.isTabooAllergy = false;
                  mediCurrent.decPoint = mediMst.decPoint;
                } else {
                  if (ordInfo.rstDialysisState == "0") {
                    mediCurrent.name = mediMst.name;
                    mediCurrent.unit = mediMst.unit;
                    mediCurrent.class_name = mediClassMst.name;
                  } else {
                    if (mediMst.prefix) {
                      mediCurrent.name = mediCurrent.name.includes(mediMst.prefix) ? mediCurrent.name : mediMst.prefix + mediCurrent.name;
                    }
                  }
                  mediCurrent.isTabooAllergy = mediMst.isTabooAllergy;
                  mediCurrent.decPoint = mediMst.decPoint;
                }
              }
              /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */

              convertData.push({
                data: [],
                // 列名称(分類表示有の場合、薬剤分類名称 / 分類表示無の場合、薬剤名称)
                itemName: isDisplayClassName ? mediCurrent.class_name || mediClassMst.name : mediCurrent.name,
                // FNSI-投与薬剤の補助画面を追加 周 add start
                // 薬剤名称
                /* upd by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --start */
                // medicineName: mediMst.name,
                medicineName: ordInfo.readOnly ? mediCurrent.name : mediMst.name,
                // 分類名称
                // className: mediClassMst.name,
                className: ordInfo.readOnly ? (mediCurrent.class_name ? mediCurrent.class_name : "未分類") : mediClassMst.name,
                /* upd by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --end */
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                //薬剤分類マスタ表示順
                classCdIndex:classCdIndex === -1 ? 999999 : classCdIndex,
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                // コメント
                comment: mediCurrent.comment,
                medicateTimingCd2: mediCurrent.timing_cd,
                procedureCd2: mediCurrent.procedure_cd,
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                medicateTimingCdIndex :timingMst === undefined || timingMst === null ? 999999 : timingMst.index,
                procedureCdIndex : procedureMst === undefined || procedureMst === null ? 999999 : procedureMst.index,
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                dateInterval2: mediCurrent.date_interval,
                // FNSI-投与薬剤の補助画面を追加 周 add end
                itemNo: mediCurrent.no,
                amount: mediCurrent.amount,
                decPoint: mediCurrent.decPoint,
                unit: mediCurrent.unit,
                cd: mediCurrent.cd,
                medicineType: mediCurrent.medicine_type,
                isTabooAllergy: mediCurrent.isTabooAllergy,
                // 使用期限の判定用に追加
                useStartDate: mediMst.useStartDate,
                useEndDate: mediMst.useEndDate,
                // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
                classCd: mediMst.classCd,
                index: mediMst.index,
                medicateTimingCd: mediMst.medicateTimingCd,
                procedureCd: mediMst.procedureCd,
                dateInterval: mediCurrent.date_interval,
                // add 8105 2023-04-11 GX連携で実装されていない機能 張 start
                isEditable: mediCurrent.is_editable,
                // add 8105 2023-04-11 GX連携で実装されていない機能 張 end
                // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
                // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
                isDelFlag: mediMst.isDelFlag,
                // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
                /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                readOnly: ordInfo.readOnly,
                facilityCd: ordInfo.facilityCd,
                patId: ordInfo.patId
                /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
              });
            }
          }
        }

        // 実績の投与薬剤を識別番号で絞り込んで取得
        if (rstMediInfo) {
          for (let i = 0; i < rstMediInfo.length; i++) {
            const mediCurrent = rstMediInfo[i];
            if (mediCurrent && mediCurrent.cd) {
              const mediFind = convertData.find(item => {
                // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 start
                // return item.itemNo === mediCurrent.no;
                return item.itemNo === mediCurrent.no && item.cd === mediCurrent.cd;
                // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 end
              });

              // 対象番号の表示項目が存在しない場合のみ作成して追加する
              if (!mediFind) {
                const mediMst = await dispatch("getMstRecordInState", {
                  // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
                  //mod FNSI-6866 劉全航 start
                  // mstClass: mediCurrent.medicine_type === "2" ? 11 : 10,
                  mstClass: mediCurrent.medicine_type == 2 ? 11 : 10,
                  //mod FNSI-6866 劉全航 end
                  code: mediCurrent.cd,
                  notExistReturnValue: "削除済み"
                });

                const mediClassMst = await dispatch("getMstRecordInState", {
                  mstClass: 8,
                  code: mediMst.classCd,
                  notExistReturnValue: "未分類"
                });
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                let classCdIndex = mstselector.data.findIndex(el => el.code == mediMst.classCd);
                // 投与タイミングマストのデータ
                const timingMst = getters.getMstMedicateTimingData.find(mstData => {
                  return mstData.medicateTimingCd === mediCurrent.timing_cd;
                });
                // 手技マストのデータ
                const procedureMst = getters.getMstProcedureData.find(mstData => {
                  return mstData.procedureCd === mediCurrent.procedure_cd;
                });
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                // 項目列に「投与薬剤分類名」を表示する場合、日付列に「投与薬剤名」を表示する
                if (isDisplayClassName) {
                  mediCurrent.isTabooAllergy = false;
                  mediCurrent.decPoint = mediMst.decPoint;
                } else {
                  if (mediMst.prefix) {
                    mediCurrent.name = mediCurrent.name.includes(mediMst.prefix) ? mediCurrent.name : mediMst.prefix + mediCurrent.name;
                  }
                  mediCurrent.isTabooAllergy = mediMst.isTabooAllergy;
                  mediCurrent.decPoint = mediMst.decPoint;
                }

                convertData.push({
                  data: [],
                  // 列名称(分類表示有の場合、薬剤分類名称 / 分類表示無の場合、薬剤名称)
                  itemName: isDisplayClassName ? mediCurrent.class_name || mediClassMst.name : mediCurrent.name,
                  // FNSI-投与薬剤の補助画面を追加 周 add start
                  // 薬剤名称
                  medicineName: mediCurrent.name,
                  // 分類名称
                  className: mediCurrent.class_name,
                  // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                  //薬剤分類マスタ表示順
                  classCdIndex:classCdIndex === -1 ? 999999 : classCdIndex,
                  // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                  // コメント
                  comment: mediCurrent.comment,
                  medicateTimingCd2: mediCurrent.timing_cd,
                  procedureCd2: mediCurrent.procedure_cd,
                  // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                  medicateTimingCdIndex :timingMst === undefined || timingMst === null ? 999999 : timingMst.index,
                  procedureCdIndex : procedureMst === undefined || procedureMst === null ? 999999 :  procedureMst.index,
                  // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                  dateInterval2: mediCurrent.date_interval,
                  // FNSI-投与薬剤の補助画面を追加 周 add end
                  itemNo: mediCurrent.no,
                  amount: mediCurrent.amount,
                  decPoint: mediCurrent.decPoint,
                  unit: mediCurrent.unit,
                  cd: mediCurrent.cd,
                  medicineType: mediCurrent.medicine_type,
                  isTabooAllergy: mediCurrent.isTabooAllergy,
                  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
                  classCd: mediMst.classCd,
                  index: mediMst.index,
                  medicateTimingCd: mediMst.medicateTimingCd,
                  procedureCd: mediMst.procedureCd,
                  dateInterval: mediCurrent.date_interval,
                  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
                  // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
                  isDelFlag: mediMst.isDelFlag,
                  // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
                  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
                  readOnly: ordInfo.readOnly,
                  facilityCd: ordInfo.facilityCd,
                  patId: ordInfo.patId
                  /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
                });
              }
            }
          }
        }
      }



      // add 9200 by kangjie 20230912 start
      const OrdMainInfoCaChe = state.addIndMediInfo;
      for (const data in OrdMainInfoCaChe) {

        const ordInfo = OrdMainInfoCaChe[data];
        /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
        // const indMediInfo = JSON.parse(ordInfo.indMediInfo);
        // const rstMediInfo = JSON.parse(ordInfo.rstMediInfo);
        const indMediInfo = (ordInfo && ordInfo.indMediInfo) ? JSON.parse(ordInfo.indMediInfo) : [];
        const rstMediInfo = (ordInfo && ordInfo.rstMediInfo) ? JSON.parse(ordInfo.rstMediInfo) : [];
        /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
        if (indMediInfo) {
          for (let i = 0; i < indMediInfo.length; i++) {
            const mediCurrent = indMediInfo[i];
            const mediFind = convertData.find(item => {
              // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 start
              // return item.itemNo === mediCurrent.no;
              return item.itemNo === mediCurrent.no && item.cd === mediCurrent.cd;
              // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 end
            });
            // 対象番号の表示項目が存在しない場合のみ作成して追加する
            if (!mediFind) {
              // mod #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
              // const mediMst = await dispatch("getMstRecordInState", {
              let mediMst = await dispatch("getMstRecordInState", {
                // mod #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
                // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
                mstClass: mediCurrent.medicine_type == 2 ? 11 : 10,
                code: mediCurrent.cd,
                notExistReturnValue: "削除済み"
              });
              const mediClassMst = await dispatch("getMstRecordInState", {
                mstClass: 8,
                code: mediMst.classCd,
                notExistReturnValue: "未分類"
              });
              // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
              let classCdIndex = mstselector.data.findIndex(el => el.code == mediMst.classCd);
              // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
              // 投与タイミングマストのデータ
              const timingMst = getters.getMstMedicateTimingData.find(mstData => {
                return mstData.medicateTimingCd === mediCurrent.timing_cd;
              });
              // 手技マストのデータ
              const procedureMst = getters.getMstProcedureData.find(mstData => {
                return mstData.procedureCd === mediCurrent.procedure_cd;
              });
              // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
              // 項目列に「投与薬剤分類名」を表示する場合、日付列に「投与薬剤名」を表示する
              /* upd by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --start */
              const selectedPatId = store.getters["pat-info/selectedPatId"];
              const readOnly = ordInfo.patId != selectedPatId;
              if (readOnly) {
                mediCurrent.name = indMediInfo[i].name;
                mediCurrent.unit = indMediInfo[i].unit;
                mediCurrent.class_name = indMediInfo[i].class_name;
                mediCurrent.decPoint = indMediInfo[i].decPoint;
              } else {
                if (isDisplayClassName) {
                  if (ordInfo.rstDialysisState == "0") {
                    mediCurrent.name = mediMst.name;
                    mediCurrent.unit = mediMst.unit;
                    mediCurrent.class_name = mediClassMst.name;
                  }
                  mediCurrent.isTabooAllergy = false;
                  mediCurrent.decPoint = mediMst.decPoint;
                } else {
                  if (ordInfo.rstDialysisState == "0") {
                    mediCurrent.name = mediMst.name;
                    mediCurrent.unit = mediMst.unit;
                    mediCurrent.class_name = mediClassMst.name;
                  } else {
                    if (mediMst.prefix) {
                      mediCurrent.name = mediCurrent.name.includes(mediMst.prefix) ? mediCurrent.name : mediMst.prefix + mediCurrent.name;
                    }
                  }
                  mediCurrent.isTabooAllergy = mediMst.isTabooAllergy;
                  mediCurrent.decPoint = mediMst.decPoint;
                }
              }
              /* upd by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --end */

              convertData.push({
                data: [],
                // 列名称(分類表示有の場合、薬剤分類名称 / 分類表示無の場合、薬剤名称)
                itemName: isDisplayClassName ? mediCurrent.class_name || mediClassMst.name : mediCurrent.name,
                // FNSI-投与薬剤の補助画面を追加 周 add start
                // 薬剤名称
                /* upd by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --start */
                // medicineName: mediMst.name,
                medicineName: readOnly ? mediCurrent.name : mediMst.name,
                // 分類名称
                // className: mediClassMst.name,
                className: readOnly ? (mediCurrent.class_name ? mediCurrent.class_name :"未分類") : mediClassMst.name,
                /* upd by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --end */
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                //薬剤分類マスタ表示順
                classCdIndex:classCdIndex === -1 ? 9999999 : classCdIndex + 9999999,
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                // コメント
                comment: mediCurrent.comment,
                medicateTimingCd2: mediCurrent.timing_cd,
                procedureCd2: mediCurrent.procedure_cd,
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                medicateTimingCdIndex :timingMst === undefined || timingMst === null ? 999999 : timingMst.index + 9999999,
                procedureCdIndex : procedureMst === undefined || procedureMst === null ? 999999 : procedureMst.index + 9999999,
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                dateInterval2: mediCurrent.date_interval,
                // FNSI-投与薬剤の補助画面を追加 周 add end
                itemNo: mediCurrent.no,
                amount: mediCurrent.amount,
                decPoint: mediCurrent.decPoint,
                unit: mediCurrent.unit,
                cd: mediCurrent.cd,
                medicineType: mediCurrent.medicine_type +9999999,
                isTabooAllergy: mediCurrent.isTabooAllergy,
                // 使用期限の判定用に追加
                useStartDate: mediMst.useStartDate,
                useEndDate: mediMst.useEndDate,
                // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
                classCd: mediMst.classCd,
                index: mediMst.index + 9999999,
                medicateTimingCd: mediMst.medicateTimingCd,
                procedureCd: mediMst.procedureCd,
                dateInterval: mediCurrent.date_interval + 9999999,
                // add 8105 2023-04-11 GX連携で実装されていない機能 張 start
                isEditable: mediCurrent.is_editable,
                // add 8105 2023-04-11 GX連携で実装されていない機能 張 end
                // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
                // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
                isDelFlag: mediMst.isDelFlag,
                // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
                /* add by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --start */
                readOnly: readOnly,
                facilityCd: ordInfo.facilityCd,
                patId: ordInfo.patId
                /* add by chamaojia 2026-03-17 [12462] 患者情報共有->患者経過総合ビューア --end */
              });
            }
          }
        }
        if (rstMediInfo) {
          for (let i = 0; i < rstMediInfo.length; i++) {
            const mediCurrent = rstMediInfo[i];
            if (mediCurrent && mediCurrent.cd) {
              const mediFind = convertData.find(item => {
                // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 start
                // return item.itemNo === mediCurrent.no;
                return item.itemNo === mediCurrent.no && item.cd === mediCurrent.cd;
                // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 end
              });

              // 対象番号の表示項目が存在しない場合のみ作成して追加する
              if (!mediFind) {
                const mediMst = await dispatch("getMstRecordInState", {
                  // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
                  //mod FNSI-6866 劉全航 start
                  // mstClass: mediCurrent.medicine_type === "2" ? 11 : 10,
                  mstClass: mediCurrent.medicine_type == 2 ? 11 : 10,
                  //mod FNSI-6866 劉全航 end
                  code: mediCurrent.cd,
                  notExistReturnValue: "削除済み"
                });

                const mediClassMst = await dispatch("getMstRecordInState", {
                  mstClass: 8,
                  code: mediMst.classCd,
                  notExistReturnValue: "未分類"
                });
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                let classCdIndex = mstselector.data.findIndex(el => el.code == mediMst.classCd);
                // 投与タイミングマストのデータ
                const timingMst = getters.getMstMedicateTimingData.find(mstData => {
                  return mstData.medicateTimingCd === mediCurrent.timing_cd;
                });
                // 手技マストのデータ
                const procedureMst = getters.getMstProcedureData.find(mstData => {
                  return mstData.procedureCd === mediCurrent.procedure_cd;
                });
                // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                // 項目列に「投与薬剤分類名」を表示する場合、日付列に「投与薬剤名」を表示する
                if (isDisplayClassName) {
                  mediCurrent.isTabooAllergy = false;
                  mediCurrent.decPoint = mediMst.decPoint;
                } else {
                  if (mediMst.prefix) {
                    mediCurrent.name = mediCurrent.name.includes(mediMst.prefix) ? mediCurrent.name : mediMst.prefix + mediCurrent.name;
                  }
                  mediCurrent.isTabooAllergy = mediMst.isTabooAllergy;
                  mediCurrent.decPoint = mediMst.decPoint;
                }

                convertData.push({
                  data: [],
                  // 列名称(分類表示有の場合、薬剤分類名称 / 分類表示無の場合、薬剤名称)
                  itemName: isDisplayClassName ? mediCurrent.class_name || mediClassMst.name : mediCurrent.name,
                  // FNSI-投与薬剤の補助画面を追加 周 add start
                  // 薬剤名称
                  medicineName: mediCurrent.name,
                  // 分類名称
                  className: mediCurrent.class_name,
                  // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                  //薬剤分類マスタ表示順
                  classCdIndex:classCdIndex === -1 ? 999999 : classCdIndex + 9999999,
                  // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                  // コメント
                  comment: mediCurrent.comment,
                  medicateTimingCd2: mediCurrent.timing_cd,
                  procedureCd2: mediCurrent.procedure_cd,
                  // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
                  medicateTimingCdIndex :timingMst === undefined || timingMst === null ? 999999 : timingMst.index + 9999999,
                  procedureCdIndex : procedureMst === undefined || procedureMst === null ? 999999 :  procedureMst.index + 9999999,
                  // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
                  dateInterval2: mediCurrent.date_interval,
                  // FNSI-投与薬剤の補助画面を追加 周 add end
                  itemNo: mediCurrent.no,
                  amount: mediCurrent.amount,
                  decPoint: mediCurrent.decPoint,
                  unit: mediCurrent.unit,
                  cd: mediCurrent.cd,
                  medicineType: mediCurrent.medicine_type + 9999999,
                  isTabooAllergy: mediCurrent.isTabooAllergy,
                  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
                  classCd: mediMst.classCd,
                  index: mediMst.index + 9999999,
                  medicateTimingCd: mediMst.medicateTimingCd,
                  procedureCd: mediMst.procedureCd,
                  dateInterval: mediCurrent.date_interval + 9999999,
                  // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
                  // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
                  isDelFlag: mediMst.isDelFlag,
                  // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
                  /* add by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --start */
                  readOnly: ordInfo.patId != selectedPatId ? true : false,
                  facilityCd: ordInfo.facilityCd,
                  patId: ordInfo.patId
                  /* add by chamaojia 2026-03-23 [12462] 患者情報共有->患者経過総合ビューア --end */
                });
              }
            }
          }
        }
      }
      // add 9200 by kangjie 20230912 end
      // 0件の場合は空行を挿入
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      // if (convertData.length === 0) {
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
        const tempMedi = {
          data: [],
          itemName: "投与薬剤",
          itemNo: -1,
          // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
          isAdd: true
          // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
        };

        for (const treatData in copyTreatmentData) {
          // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
          const ordInfo = copyTreatmentData[treatData];
          // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const indCondInfo = copyTreatmentData[treatData]?.indCondInfo;
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          tempMedi.data.push({
            // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
            // ordNo: null,
            ordNo:  ordInfo?.ordNo,
            // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
            treatDate: treatData,
            value1: null,
            // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            // isShowAddImg: ordInfo ? true : false,
            isShowAddImg: ordInfo && !ordInfo.readOnly ? true : false,
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
            // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isDisabled1: !indCondInfo && ordInfo ? !!ordInfo.ordNo : false,
            // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          });
        }

        convertData.push(tempMedi);
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      // }
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
      // 各治療日に投与薬剤の値を格納
      for (let i = 0; i < convertData.length; i++) {
        if (convertData[i].itemNo === -1) {
          continue;
        }

        // 対象日付の抽出
        for (const treatData in copyTreatmentData) {
          const ordInfo = copyTreatmentData[treatData];
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const indCondInfo = copyTreatmentData[treatData]?.indCondInfo;
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          const tempData = {
            ordNo: null,
            treatDate: treatData,
            value1: null,
            value2: null,
            // add FNSI-投与薬剤の詳細情報の修正 楊 start
            toolText1: null,
            toolText2: null,
            // add FNSI-投与薬剤の詳細情報の修正 楊 end
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isNotClickable: ordInfo ? ordInfo.readOnly : null,
            isDisabled1: !indCondInfo && ordInfo ? !!ordInfo.ordNo : false,
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          };
          const indInfo =
            ordInfo && ordInfo.indMediInfo && JSON.parse(ordInfo.indMediInfo);
          const rstInfo =
            ordInfo && ordInfo.rstMediInfo && JSON.parse(ordInfo.rstMediInfo);
          const ind =
            indInfo &&
            indInfo.find(item => {
              // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 start
              // return item.no === convertData[i].itemNo;
              return item.no === convertData[i].itemNo && item.cd === convertData[i].cd;
              // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 end
            });
          const rst =
            rstInfo &&
            rstInfo.find(item => {
              // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 start
              // return item.no === convertData[i].itemNo;
              return item.no === convertData[i].itemNo && item.cd === convertData[i].cd;
              // mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.44(外結)対応 韓 end
            });

          // 対象スケジュールデータが存在する場合
          tempData.ordNo = ordInfo && ordInfo.ordNo;
          let numbers = null;
          let decPoint = null;
          if (ind && ind.amount !== null) {
            //薬剤数量の小数点以下桁数対応
            numbers = String(ind.amount || 0).split('.');
            decPoint = (numbers[1]) ? numbers[1].length : 0;
            // mod FNSI-小数点の修正 楊 start
            // if(decPoint > (convertData[i].decPoint || 0)){
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240522 start
            if (ordInfo.rstDialysisState == "0") {
              if (decPoint > convertData[i].decPoint) {
                let numTemp = BigNumber(ind.amount).toFixed();
                let numSplit = numTemp.split('.');
                let decTempPoint = (numSplit[1]) ? numSplit[1].length : 0;

                if (decTempPoint > convertData[i].decPoint) {
                  ind.amount = numTemp;
                } else {
                  ind.amount = BigNumber(ind.amount).toFixed(convertData[i].decPoint);
                }
              } else {
                ind.amount = BigNumber(ind.amount).toFixed(convertData[i].decPoint);
              }
            }
            //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240522 end
          }

          if (rst && rst.amount !== null) {
            //薬剤数量の小数点以下桁数対応
            numbers = String(rst.amount || 0).split('.');
            decPoint = (numbers[1]) ? numbers[1].length : 0;
            // mod FNSI-小数点の修正 楊 start
            // if(decPoint > (convertData[i].decPoint || 0)){
            if(ordInfo.rstDialysisState !== "0"){
              // rst.amount= BigNumber(rst.amount).toFixed();
              rst.amount= BigNumber(rst.amount).toFixed(decPoint || 0);
              // mod FNSI-小数点の修正 楊 end
            }else{
              rst.amount = BigNumber(rst.amount).toFixed(convertData[i].decPoint || 0);
            }
          }


          tempData.value1 =
            (ind &&
              (convertData[i].unit
                ? `${ind.amount || "0"} ${convertData[i].unit}`
                : ind.amount || "0")) ||
            (ordInfo && null);
          tempData.value2 =
            (rst &&
              (convertData[i].unit
                ? `${rst.amount || "0"} ${convertData[i].unit}`
                : rst.amount || "0")) ||
            // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 start
            // (tempData.value1 && "未登録") ||
            (tempData.value1 && " ") ||
            // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 end
            (ordInfo && null);

          // 実績にデータがあり、指示にデータがない場合未登録と表示する
          tempData.value1 =
            // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 start
            // !tempData.value1 && tempData.value2 ? "未登録" : tempData.value1;
            !tempData.value1 && tempData.value2 ? " " : tempData.value1;
          // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 end
          // 項目列に「投与薬剤分類名」を表示する場合、日付列に「投与薬剤名」を表示する
          if (isDisplayClassName) {
            const mediMst = await dispatch("getMstRecordInState", {
              // 「"2": 調製薬剤」「11: 調製薬剤マスタ（禁忌アレルギー込み）」「10: 薬剤マスタ（禁忌アレルギー込み）」
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
              //mstClass: convertData[i].medicineType === "2" ? 11 : 10,
              mstClass: convertData[i].medicineType == 2 ? 11 : 10,
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              code: convertData[i].cd,
              notExistReturnValue: "削除済み",
              // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
              treatDate: treatData
              // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            });

            // mod FNSI-期限切れ削除済みと表示するの修正 李 start
            // if (tempData.value1 !== null) {
            if (ind && tempData.value1 !== null) {
              // mod FNSI-期限切れ削除済みと表示するの修正 李 end
              /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --start */
              // let indName = ordInfo.rstDialysisState == "0" && !ordInfo.readOnly ? mediMst.name : ind.name;
              let indName = ordInfo.rstDialysisState == "0" && !ordInfo.readOnly ? mediMst.name : convertData[i].medicineName;
              /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --end */
              // mod FNSI-期限切れ削除済みと表示するの修正 李 start
              // if (ind.name) indName = mediMst.prefix + indName;
              // tempData.value1 = `[${indName}] ${tempData.value1}`;
              if (ind.name && mediMst.prefix) indName = indName.includes(mediMst.prefix) ? indName : mediMst.prefix + indName;
              tempData.value1 = `${indName} ${tempData.value1}`;
              // mod FNSI-期限切れ削除済みと表示するの修正 李 end
              tempData.isTabooAllergy1 = mediMst.isTabooAllergy;
            }

            // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 start
            // if (tempData.value2 !== null && tempData.value2 !== "未登録") {
            if (tempData.value2 !== null && tempData.value2 !== " ") {
              // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 end
              let rstName = rst.name || mediMst.name;
              // mod FNSI-期限切れ削除済みと表示するの修正 李 start
              // if (rst.name) rstName = mediMst.prefix + rstName;
              //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 start
              // if (rst.name && mediMst.prefix) rstName = mediMst.prefix + rstName;
              // if (rst.name) rstName = rstName;
              //mod 8007 患者経過総合ビューアで薬剤が「削除済み」で表示される時がある 張 end
              // mod FNSI-期限切れ削除済みと表示するの修正 李 end
              tempData.value2 = `[${rstName}] ${tempData.value2}`;
              tempData.isTabooAllergy2 = mediMst.isTabooAllergy;
            }
          }

          // add FNSI-投与薬剤の詳細情報の修正 楊 start
          // (指示)ツールチップ
          if (ind) {
            if (ordInfo.rstDialysisState == "0") {
              const indProcedureMst = getters.getMstProcedureData.find(mstData => {
                return mstData.procedureCd === ind.procedure_cd;
              });
              const indTimingMst = getters.getMstMedicateTimingData.find(mstData => {
                return mstData.medicateTimingCd === ind.timing_cd;
              });
              tempData.toolText1 = (indProcedureMst ? " ".concat(indProcedureMst.pricedureName) : "")
                .concat(indTimingMst ? " ".concat(indTimingMst.medicateTimingName) : "")
                .concat(ind.comment ? " ".concat(ind.comment) : "");
            } else {
              tempData.toolText1 = (ind.procedure_name ? " ".concat(ind.procedure_name) : "")
                .concat(ind.timing_name ? " ".concat(ind.timing_name) : "")
                .concat(ind.comment ? " ".concat(ind.comment) : "");
            }
          }
          // (実績)ツールチップ
          if (rst) {
            tempData.toolText2 = (rst.procedure_name ? " ".concat(rst.procedure_name) : "")
              .concat(rst.timing_name ? " ".concat(rst.timing_name) : "")
              .concat(rst.comment ? " ".concat(rst.comment) : "");
          }
          // add FNSI-投与薬剤の詳細情報の修正 楊 end
          // 使用期限の判定
          tempData.isExpired = !fitTermCheck(convertData[i].useStartDate, convertData[i].useEndDate, treatData);
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
          if (copyTreatmentData[tempData.treatDate] !== null) {
            const treatMethodCd = copyTreatmentData[tempData.treatDate].indTreatmentCd;
            tempData.treatMethodCd = treatMethodCd;
            const treatMethodInfo = response.find(i => {
              return i.treatmentCd === treatMethodCd;
            });
            if (treatMethodInfo !== undefined) {
              tempData.deviceMode = treatMethodInfo.deviceMode;
            }
          }
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
          convertData[i].data.push(tempData);
        }
        // 不要な項目を削除
        delete convertData[i].useStartDate;
        delete convertData[i].useEndDate;
      }

      return convertData;
    },

    /**
     * 医療材料データを表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {Boolean} isMakeStructionColorData 文字色変更用データ取得(既定値：false)
     */
    async convertEquipmentData(
      { getters, dispatch, commit },
      { listIndex, isMakeStructionColorData = false }
    ) {
      // 加工した表示用データ格納用
      const convertData = [];

      // ord_main
      let copyTreatmentData = [];
      // 文字色変更用データ取得有の場合
      if (isMakeStructionColorData) {
        copyTreatmentData = getters.getTreatmentDataTmp[listIndex];
      } else {
        copyTreatmentData = getters.getTreatmentData[listIndex];
      }

      // 治療方法マスタの取得
      let response = getters.getMstTreatmentData;

      // ord_main = NULLの場合
      if (!copyTreatmentData) {
        return [];
      }

      // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
      const tableName = "mst_equipment_class";
      const mstselector = await ApiHelper.get(
        `/report_designer/master/${tableName}`
      ).catch(err => {
        throw err;
      });
      const mstselectorDialyzer = await ApiHelper.get(
        `/report_designer/master/mst_dialyzer`
      ).catch(err => {
        throw err;
      });
      // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
      // 表示用データの作成
      for (const treatData in copyTreatmentData) {
        const ordInfo = copyTreatmentData[treatData];

        // 治療情報が存在しないか存在する治療情報に医療材料データがない場合
        if (!ordInfo || (!ordInfo.indEquipInfo && !ordInfo.rstEquipInfo)) {
          continue;
        }

        const indEquipInfo = JSON.parse(ordInfo.indEquipInfo);
        const rstEquipInfo = JSON.parse(ordInfo.rstEquipInfo);

        // 指示の医療材料を識別番号で絞り込んで取得
        if (indEquipInfo) {
          for (let i = 0; i < indEquipInfo.length; i++) {
            const equipmentCurrent = indEquipInfo[i];

            const existEquipment = convertData.filter(item =>
              item.treatData === treatData &&
              item.division === 0 &&
              item.itemNo === equipmentCurrent.cd &&
              item.equipType === equipmentCurrent.equip_type
            );
            const equipMst = await dispatch("getMstRecordInState", {
              mstClass: equipmentCurrent.equip_type === 0 ? 12 : 13,
              code: equipmentCurrent.cd,
              notExistReturnValue: "削除済み",
              // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
              treatDate: treatData
              // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            });
            
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            if (ordInfo.readOnly) {
              // 医療材料  ダイアライザ
              if (ordInfo.rstDialysisState == "0") {
                const tabooAllergyClassType = equipmentCurrent.equip_type == 0 ? "3" : "4";
                const tabooAllergyInfos = getters.getPatTabooAllergy.filter(item =>
                  item.patId == ordInfo.patId &&
                  item.classType == tabooAllergyClassType &&
                  item.cd == equipmentCurrent.cd
                );
                if (tabooAllergyInfos && tabooAllergyInfos.length > 0) {
                  const tabooAllergyInfo = tabooAllergyInfos[0];
                  equipmentCurrent.isTabooAllergy = true;
                  equipmentCurrent.name = getTabooAllergyPrefix(tabooAllergyInfo.taboo, tabooAllergyInfo.allergy) + equipmentCurrent.name
                } else {
                  equipmentCurrent.isTabooAllergy = false;
                }
              } else {
                equipmentCurrent.isTabooAllergy = isTabooAllergy(equipmentCurrent.name);
              }
            } else {
              if (ordInfo.rstDialysisState == "0") {
                equipmentCurrent.name = equipMst?.name;
                equipmentCurrent.unit = equipMst?.unit;
              } else {
                if (equipMst?.prefix) {
                  equipmentCurrent.name = equipmentCurrent.name.includes(equipMst.prefix) ? equipmentCurrent.name : equipMst.prefix + equipmentCurrent.name;
                }
              }
            }
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
            let classCdIndex
            if(equipmentCurrent.equip_type === 0 ){
              classCdIndex = mstselector.data.findIndex(el => el.code == equipMst.classCd);
            } else {
              classCdIndex = Number("999999" + mstselectorDialyzer.data.findIndex(el => el.code == equipmentCurrent.cd));
            }
            // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
            convertData.push({
              data: [],
              itemName: equipmentCurrent.name,
              itemNo: equipmentCurrent.cd,
              // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#6。 周 start
              treatData: treatData,
              seq: existEquipment ? existEquipment.length : 0,
              // 0:指示
              division: 0,
              // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#6。 周 end
              amount: equipmentCurrent.amount,
              unit: equipmentCurrent.unit,
              equipType: equipmentCurrent.equip_type || 0,
              /* upd by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --start */
              // isTabooAllergy: equipMst.isTabooAllergy,
              isTabooAllergy: ordInfo.readOnly ? equipmentCurrent.isTabooAllergy : equipMst.isTabooAllergy,
              /* upd by chamaojia 2026-03-27 [12462] 患者情報共有->患者経過総合ビューア --end */
              // 使用期限の判定用に追加
              useStartDate: equipMst.useStartDate,
              useEndDate: equipMst.useEndDate,
              classCd: equipMst.classCd,
              index: equipMst.index,
              classCdIndex : classCdIndex === -1 ? 999999 : classCdIndex,
              isDelFlag: equipMst.isDelFlag,
              /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
              readOnly: ordInfo.readOnly
              /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            });
          }
        }

        // 実績の医療材料を識別番号で絞り込んで取得
        if (rstEquipInfo) {
          for (let i = 0; i < rstEquipInfo.length; i++) {
            const equipmentCurrent = rstEquipInfo[i];

            const existEquipment = convertData.filter(item =>
              item.treatData === treatData &&
              item.division === 1 &&
              item.itemNo === equipmentCurrent.cd &&
              item.equipType === equipmentCurrent.equip_type
            );
            const equipMst = await dispatch("getMstRecordInState", {
              // equipType => 0: 医療材料, 1: ダイアライザ
              mstClass: equipmentCurrent.equip_type === 1 ? 13 : 12,
              code: equipmentCurrent.cd,
              notExistReturnValue: "削除済み"
            });

            if (equipMst.prefix) {
              equipmentCurrent.name = equipmentCurrent.name.includes(equipMst.prefix) ? equipmentCurrent.name : equipMst.prefix + equipmentCurrent.name;
            }
            // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
            let classCdIndex
            if(equipmentCurrent.equip_type === 0 ){
              classCdIndex = mstselector.data.findIndex(el => el.code == equipMst.classCd);
            } else {
              classCdIndex = classCdIndex = Number("999999" + mstselectorDialyzer.data.findIndex(el => el.code == equipmentCurrent.cd));
            }
            // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
            convertData.push({
              data: [],
              itemName: equipmentCurrent.name,
              itemNo: equipmentCurrent.cd,
              // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#6。 周 start
              treatData: treatData,
              seq: existEquipment ? existEquipment.length : 0,
              // 1:実績
              division: 1,
              // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#6。 周 end
              amount: equipmentCurrent.amount,
              unit: equipmentCurrent.unit,
              equipType: equipmentCurrent.equip_type || 0,
              isTabooAllergy: equipMst.isTabooAllergy,
              // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
              classCd: equipMst.classCd,
              index: equipMst.index,
              // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
              // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 start
              classCdIndex : classCdIndex === -1 ? 999999 : classCdIndex,
              // add 7886 施設設定マスタ＞No.106, 107の表示・動作不備 end
              // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
              isDelFlag: equipMst.isDelFlag,
              // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
              /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
              readOnly: ordInfo.readOnly
              /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            });
            // del FNSI-障害票一覧_患者経過総合ビューア_初期表示#6。 周 start
            // }
            // del FNSI-障害票一覧_患者経過総合ビューア_初期表示#6。 周 end
          }
        }
      }

      // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#6。 周 start
      // convertData再作成
      const tempConvertData = [];
      convertData.forEach(function(item) {
        const tempExist = tempConvertData.filter(t =>
          t.itemNo === item.itemNo &&
          t.equipType === item.equipType
        );
        if (tempExist && tempExist.length === 0) {
          tempConvertData.push({
            data: [],
            itemName: item.itemName,
            itemNo: item.itemNo,
            seq: item.seq,
            amount: item.amount,
            unit: item.unit,
            equipType: item.equipType,
            isTabooAllergy: item.isTabooAllergy,
            classCd: item.classCd,
            index: item.index,
            classCdIndex : item.classCdIndex,
            isDelFlag: item.isDelFlag,
            useStartDate: item.useStartDate,
            useEndDate: item.useEndDate,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            readOnly: item.readOnly
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
          });
        }
      });
      convertData.length = 0;
      Array.prototype.push.apply(convertData, tempConvertData);
        const tempEquip = {
          data: [],
          itemName: "医療材料",
          itemNo: -1,
          isAdd: true
        };

        for (const treatData in copyTreatmentData) {
          const ordInfo = copyTreatmentData[treatData];
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const indCondInfo = copyTreatmentData[treatData]?.indCondInfo
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          tempEquip.data.push({
            ordNo:  ordInfo?.ordNo,
            treatDate: treatData,
            value1: null,
            value2: null,
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            // isShowAddImg: ordInfo ? true : false,
            isShowAddImg: ordInfo && !ordInfo.readOnly ? true : false,
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isNotClickable: !indCondInfo && ordInfo ? !!ordInfo.ordNo : false,
            isDisabled1: !indCondInfo && ordInfo ? !!ordInfo.ordNo : false,
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          });
        }

        convertData.push(tempEquip);

      // 治療日ごとに医療材料の値を格納
      for (let i = 0; i < convertData.length; i++) {
        if (convertData[i].itemNo === -1) {
          continue;
        }

        // 対象日付の抽出
        for (const treatData in copyTreatmentData) {
          const ordInfo = copyTreatmentData[treatData];
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const indCondInfo = copyTreatmentData[treatData]?.indCondInfo
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          const tempData = {
            ordNo: null,
            treatDate: treatData,
            value1: null,
            value2: null,
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isNotClickable: ordInfo ? ordInfo.readOnly : null,
            isDisabled1: !indCondInfo && ordInfo ? !!ordInfo.ordNo : false,
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          };
          const indInfo =
            ordInfo && ordInfo.indEquipInfo && JSON.parse(ordInfo.indEquipInfo);
          const rstInfo =
            ordInfo && ordInfo.rstEquipInfo && JSON.parse(ordInfo.rstEquipInfo);
          const ind =
            indInfo &&
            indInfo.filter(item =>
              item.cd === convertData[i].itemNo &&
              (item.equip_type || 0) === convertData[i].equipType
            )[convertData[i].seq];
          const rst =
            rstInfo &&
            rstInfo.filter(item =>
              item.cd === convertData[i].itemNo &&
              (item.equip_type || 0) === convertData[i].equipType
            )[convertData[i].seq];
          // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#6。 周 end

          // 対象スケジュールデータが存在する場合
          tempData.ordNo = ordInfo && ordInfo.ordNo;
          tempData.value1 =
            (ind &&
              (convertData[i].unit
                ? `${ind.amount || "0"} ${convertData[i].unit}`
                : ind.amount || "0")) ||
            (ordInfo && null);
          tempData.value2 =
            (rst &&
              (convertData[i].unit
                ? `${rst.amount || "0"} ${convertData[i].unit}`
                : rst.amount || "0")) ||
            // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 start
            // (tempData.value1 && "未登録") ||
            (tempData.value1 && " ") ||
            // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 end
            (ordInfo && null);

          // 実績にデータがあり、指示にデータがない場合未登録と表示する
          tempData.value1 =
            // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 start
            // !tempData.value1 && tempData.value2 ? "未登録" : tempData.value1;
            !tempData.value1 && tempData.value2 ? " " : tempData.value1;
          // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 end

          // 使用期限の判定
          tempData.isExpired = !fitTermCheck(convertData[i].useStartDate, convertData[i].useEndDate, treatData);
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
          if (copyTreatmentData[tempData.treatDate] !== null) {
            const treatMethodCd = copyTreatmentData[tempData.treatDate].indTreatmentCd;
            tempData.treatMethodCd = treatMethodCd;
            const treatMethodInfo = response.find(i => {
              return i.treatmentCd === treatMethodCd;
            });
            if (treatMethodInfo !== undefined) {
              tempData.deviceMode = treatMethodInfo.deviceMode;
            }
          }
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
          convertData[i].data.push(tempData);
        }
        // 不要な項目を削除
        delete convertData[i].useStartDate;
        delete convertData[i].useEndDate;
      }
      return convertData;
    },

    /**
     * 指示コメントデータを表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {Boolean} isMakeStructionColorData 文字色変更用データ取得(既定値：false)
     */
    async convertIndCommentData(
      { getters, commit },
      { listIndex, isMakeStructionColorData = false }
    ) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      let searchDateList = [];
      // ord_main
      let copyTreatmentData = [];
      // 文字色変更用データ取得有の場合
      if (isMakeStructionColorData) {
        // 治療日一覧の取得
        const searchDateListTmp = getters.getDateList;
        // 左端画面表示治療日 - 7
        for (let i = -7; i < 0; i++) {
          searchDateList.push(moment(searchDateListTmp[0]).add(i, "days").format("YYYYMMDD"));
        }
        // 画面表示治療日
        searchDateListTmp.forEach(item => {
          searchDateList.push(item);
        });
        // 右端画面表示治療日 + 7
        for (let i = 1; i < 8; i++) {
          searchDateList.push(moment(searchDateList[searchDateList.length - 1]).add(1, "days").format("YYYYMMDD"));
        }
        // ord_mainの取得
        copyTreatmentData = getters.getTreatmentDataTmp[listIndex];
      } else {
        searchDateList = getters.getDateList;
        copyTreatmentData = getters.getTreatmentData[listIndex]
      }

      // 治療方法マスタの取得
      let response = getters.getMstTreatmentData;

      // ord_main = NULLの場合
      if (!copyTreatmentData) {
        return [];
      }

      const searchDispLayoutItemList = [];
      // 指示コメント項目作成
      searchDateList.forEach(eleDate => {
        // もし対象曜日に治療情報がなければ、次のループ
        if (!copyTreatmentData[eleDate]) {
          return;
        }
        // 指示、実績の項目作成
        for (let i = 1; i <= 2; i++) {
          // カラム名設定
          const columnName =
            1 === i ? "indIndCommentInfo" : "rstIndCommentInfo";

          // 指示コメント情報
          const indCommentInfo = JSON.parse(
            copyTreatmentData[eleDate][[columnName]]
          );
          // 治療情報に指示コメントの情報がなければ、次のループへ
          if (null === indCommentInfo) {
            continue;
          }

          // 指示コメント分ループ
          indCommentInfo.forEach(eleComment => {
            const obj = {};
            obj.itemNo = eleComment.no;
            obj.itemName = `コメント${eleComment.no}`;
            // 1つも値がない場合はそのまま格納
            if (0 === searchDispLayoutItemList.length) {
              searchDispLayoutItemList.push(obj);
            } else {
              // 重複データチェック
              const dupData = searchDispLayoutItemList.find(eleItem => {
                return eleItem.itemNo === eleComment.no;
              });
              // 重複がなければ値を格納
              if (!dupData) {
                searchDispLayoutItemList.push(obj);
              }
            }
          });
        }
      });

      // 指示コメント情報が1つもなかった場合
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      // if (0 === searchDispLayoutItemList.length) {
      // del #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
        const tempRow = deepCopy(layoutDispData);
        searchDateList.forEach(eleDate => {
          const tempCell = deepCopy(layoutDispData_data);
          tempCell.treatDate = eleDate;
          // mod bug 7872 修正 chen start
          tempCell.ordNo =
            null !== copyTreatmentData[eleDate] && copyTreatmentData[eleDate]
              ? copyTreatmentData[eleDate].ordNo
              : null;
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
          // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const ordInfo = copyTreatmentData[tempCell.treatDate];
          // if (copyTreatmentData[tempCell.treatDate] && copyTreatmentData[tempCell.treatDate] !== null) {
          if (ordInfo) {
            // mod bug 7872 修正 chen end
            // const treatMethodCd = copyTreatmentData[tempCell.treatDate].indTreatmentCd;
            const treatMethodCd = ordInfo.indTreatmentCd;
            const indCondInfo = ordInfo.indCondInfo;
            tempCell.treatMethodCd = treatMethodCd;
            const treatMethodInfo = response.find(i => {
              return i.treatmentCd === treatMethodCd;
            });
            if (treatMethodInfo !== undefined) {
              tempCell.deviceMode = treatMethodInfo.deviceMode;
            }
            tempCell.isNotClickable = !indCondInfo && ordInfo ? !!ordInfo.ordNo : false;
            tempCell.isDisabled1 = !indCondInfo && ordInfo ? !!ordInfo.ordNo : false;
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          }
          // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
          // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
          /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
          // tempCell.isShowAddImg = copyTreatmentData[eleDate] ? true : false;
          tempCell.isShowAddImg = copyTreatmentData[eleDate] && !copyTreatmentData[eleDate].readOnly ? true : false;
          /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
          // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
          tempRow.data.push(tempCell);
        });
        tempRow.itemName = "指示コメント";
        // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
        tempRow.isAdd = true;
        // add #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
        convertData.push(tempRow);
      // } else {
        // 表示用データの作成
        searchDispLayoutItemList.forEach(eleDispItem => {
          // 対象番号の表示項目を抽出
          let findConvertData = convertData.find(item => {
            return eleDispItem.itemNo === item.itemNo;
          });

          // 対象番号が存在しない場合、雛形構造を追加
          if (!findConvertData) {
            const temp = deepCopy(layoutDispData);
            temp.itemNo = eleDispItem.itemNo;
            temp.itemName = eleDispItem.itemName;
            findConvertData = temp;
            convertData.push(findConvertData);
          }

          // 表示日付け(期間)ループ
          searchDateList.forEach(eleDate => {
            // 対象日付の抽出
            let findConvertDataForTreatDate = findConvertData.data.find(
              item => {
                return item.treatDate === eleDate;
              }
            );

            // 対象日付のデータが存在しない場合、雛形構造を追加
            if (!findConvertDataForTreatDate) {
              const temp = deepCopy(layoutDispData_data);
              temp.treatDate = eleDate;
              findConvertDataForTreatDate = temp;
              findConvertData.data.push(findConvertDataForTreatDate);
            }

            // 対象日付に治療情報が存在するかを確認
            if (!copyTreatmentData[findConvertDataForTreatDate.treatDate]) {
              return; // forEach内でのcontinue
            }
            // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
            const treatMethodCd = copyTreatmentData[findConvertDataForTreatDate.treatDate].indTreatmentCd;
            findConvertDataForTreatDate.treatMethodCd = treatMethodCd;
            const treatMethodInfo = response.find(i => {
              return i.treatmentCd === treatMethodCd;
            });
            if (treatMethodInfo !== undefined) {
              findConvertDataForTreatDate.deviceMode = treatMethodInfo.deviceMode;
            }
            // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

            // オーダー番号を格納
            findConvertDataForTreatDate.ordNo =
              copyTreatmentData[findConvertDataForTreatDate.treatDate].ordNo;
            // 指示コメント番号を格納
            findConvertDataForTreatDate.itemNo = eleDispItem.itemNo;
            findConvertDataForTreatDate.isNotClickable = copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly;
            // 指示、実績
            for (let i = 1; i <= 2; i++) {
              const columnName =
                1 === i ? "indIndCommentInfo" : "rstIndCommentInfo";

              // 指示、実績カラム名作成
              const indComment = JSON.parse(
                copyTreatmentData[eleDate][columnName]
              );
              // 対象指示コメントデータが存在する場合、その値を格納
              if (null === indComment || undefined === indComment) {
                continue;
              }

              for (let j = 0; j < indComment.length; j++) {
                if (undefined !== indComment[j]) {
                  if (indComment[j].no === eleDispItem.itemNo) {
                    findConvertDataForTreatDate[`value${i}`] =
                      indComment[j].content;
                  }
                }
              }

              // 指示にデータがあり、実績にデータがない場合未登録と表示する
              if (null !== findConvertDataForTreatDate.value1) {
                findConvertDataForTreatDate.hasInd = true;
                findConvertDataForTreatDate.value2 =
                  null === findConvertDataForTreatDate.value2
                    // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 start
                    // ? "未登録"
                    ? " "
                    // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 end
                    : findConvertDataForTreatDate.value2;
              }

              // 実績にデータがあり、指示にデータがない場合未登録と表示する
              if (null !== findConvertDataForTreatDate.value2) {
                findConvertDataForTreatDate.hasRst = true;
                findConvertDataForTreatDate.value1 =
                  null === findConvertDataForTreatDate.value1
                    // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 start
                    // ? "未登録"
                    ? " "
                    // mod FNSI-バグ対応1.xlsxのバグ２「未登録」->空白 対応 韓 end
                    : findConvertDataForTreatDate.value1;
              }
            }
          });
        });
      // }
      return convertData;
    },

    /**
     * 検査依頼・結果データを表示用に加工
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     */
    // mod FNSI-検体検査の表示の修正 楊 start
    // async convertExamData({ getters, dispatch }, { selectLayoutCd }) {
    async convertExamData({ getters, dispatch }, { layout, selectLayoutCd }) {
      // mod FNSI-検体検査の表示の修正 楊 end
      // mod FNSI-検体検査の表示の修正 楊 start
      // 加工した表示用データ格納用
      //const convertData = [];
      // 検査予定前回検査日の取得
      const copyLastExamMainData = getters.getLastExamMainData;
      var str = "";
      if(copyLastExamMainData) {
        let dateTemp = moment(copyLastExamMainData).format("YYYY/MM/DD")
        const week = moment(copyLastExamMainData).day();
        let weekList = ["日", "月", "火", "水", "木", "金", "土"];
        let tWeek = "(" + weekList[week] + ")";
        str = "\n前回検査予定日：".concat("\n").concat(dateTemp).concat(tWeek);
      }
      // menu表示内容をの設定
      const convertData = [
        {
          itemName: `検査予定${str}`,
          itemNo: 1,
          data: []
        }
      ];
      // mod FNSI-検体検査の表示の修正 楊 end

      // 検索用日付リスト
      const searchDateList = getters.getDateList;

      // DB取得データ(pat_exam_main)
      const copyExamMainData = getters.getExamMainData;

      // 検索用表示項目リスト(治療情報-検体検査)の取得
      const searchDispLayoutItemList = await dispatch(
        "getDispLayoutItemForSubCategory",
        {
          layoutCd: selectLayoutCd,
          // mod FNSI-検体検査の表示の修正 楊 start
          // categoryNo: 1, // 治療情報
          // subCategoryNo: 62 // 検体検査
          categoryNo: layout.categoryNo, // 治療情報
          subCategoryNo: layout.categoryItem[0].subCategoryNo // 検査予定
          // mod FNSI-検体検査の表示の修正 楊 end
        }
      );
      if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
        return [];
      }

      // add FNSI-検体検査の表示の修正 楊 start
      // 日付分検査予定回数
      // del FNSI-障害票一覧_患者経過総合ビューアNo.20 李 start
      // var dateListLen1 = 0;
      // var dateListLen2 = 0;
      // del FNSI-障害票一覧_患者経過総合ビューアNo.20 李 end
      // add FNSI-検体検査の表示の修正 楊 end

      // 表示用データの作成
      searchDispLayoutItemList.forEach(eleDispItem => {
        // 対象番号の表示項目を抽出
        let findConvertData = convertData.find(item => {
          return eleDispItem.itemNo === item.itemNo;
        });

        // 対象番号が存在しない場合、雛形構造を追加
        if (!findConvertData) {
          const temp = deepCopy(layoutDispData);
          temp.itemNo = eleDispItem.itemNo;
          temp.itemName = eleDispItem.itemName;
          findConvertData = temp;
          convertData.push(findConvertData);
        }

        // 表示分日付(期間)ループ
        searchDateList.forEach(eleDate => {
          // 対象日付の抽出
          let findConvertDataForTreatDate = findConvertData.data.find(item => {
            return item.treatDate === eleDate;
          });
          // 対象日付のデータが存在しない場合、雛形構造を追加
          if (!findConvertDataForTreatDate) {
            const temp = deepCopy(layoutDispData_data);
            temp.treatDate = eleDate;
            findConvertDataForTreatDate = temp;
            findConvertData.data.push(findConvertDataForTreatDate);
          }

          const findTreatDate = findConvertDataForTreatDate.treatDate;

          // add FNSI-検体検査の表示の修正 楊 start
          // 日付分検査予定の集計
          // del FNSI-障害票一覧_患者経過総合ビューアNo.20 李 start
          // dateListLen1 = 0;
          // dateListLen2 = 0;
          // del FNSI-障害票一覧_患者経過総合ビューアNo.20 李 end
          // add FNSI-検体検査の表示の修正 楊 end
          // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo start
          let value1Tmp = 0;
          let value2Tmp = 0;
          // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo end
          copyExamMainData.forEach(exam => {
            // 検査結果レコードがなければ終了
            if (!exam) {
              return; // forEachでのcontinueの代替
            }

            // 対象日付に検査結果レコードが存在するかを確認
            if (!exam[findTreatDate]) {
              return; // forEachでのcontinueの代替
            }

            // 削除フラグがあるか確認
            if (exam[findTreatDate].isDel === "1") {
              return; // forEachでのcontinueの代替
            }
            findConvertDataForTreatDate.isNotClickable = exam[findTreatDate].readOnly;
            // mod FNSI-障害票一覧_患者経過総合ビューアNo.65 李 start
            // const examOrdInf = JSON.parse(exam[findTreatDate].examOrderInfo);
            const examOrdInf = JSON.parse(exam[findTreatDate].orderExamSetInfo);
            // mod FNSI-障害票一覧_患者経過総合ビューアNo.65 李 end
            // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo start
            // if (!examOrdInf || examOrdInf.length === 0) {
              // 検査依頼情報が存在しない場合は空欄
              // mod FNSI-検体検査の表示の修正 楊 start
              // findConvertDataForTreatDate.value1 = " ";
              // findConvertDataForTreatDate.value1 = "";
              // mod FNSI-検体検査の表示の修正 楊 end
            // } else {
              // add FNSI-障害票一覧_患者経過総合ビューアNo.20 李 start
              // findConvertDataForTreatDate.value1 = examOrdInf.length;
              // add FNSI-障害票一覧_患者経過総合ビューアNo.20 李 end
              // add FNSI-検体検査の表示の修正 楊 start
              // 検査依頼情報が1件以上存在する(依頼されている)場合は白丸
              // findConvertDataForTreatDate.value1 = "○";
              // 日付分検査予定の集計
              // del FNSI-障害票一覧_患者経過総合ビューアNo.20 李 start
              // dateListLen1 += 1;
              // findConvertDataForTreatDate.value1 = dateListLen1 === 1 ? " " : dateListLen1;
              // del FNSI-障害票一覧_患者経過総合ビューアNo.20 李 start
              // add FNSI-検体検査の表示の修正 楊 end
            // }
            if (examOrdInf) {
              // 検査依頼情報が存在しない場合は空欄
              value1Tmp += examOrdInf.length;
            }

            // add FNSI-障害票一覧_患者経過総合ビューアNo.20 李 start
            const examResultInf = JSON.parse(exam[findTreatDate].examResultInfo);
            // if (!examResultInf || examResultInf.length == 0) {
              // findConvertDataForTreatDate.value2 = '';
            // } else {
            //   //mod FutreNetWeb+SI課題管理 no.5990 劉全航 start
            //   // findConvertDataForTreatDate.value2 = examResultInf.length;
            //   var resultList = examResultInf.filter(o=>o.result !== "" );
            //   findConvertDataForTreatDate.value2 = resultList.length;
            // }
            if (examResultInf) {
              var resultList = examResultInf.filter(o=>(!!o.result || !!o.freememo));
              value2Tmp += resultList.length;
              //mod FutreNetWeb+SI課題管理 no.5990 劉全航 end
            }
            // add FNSI-障害票一覧_患者経過総合ビューアNo.20 李 emd

            // del FNSI-障害票一覧_患者経過総合ビューアNo.20 李 start
            // 対象日付に検査結果ありかどうかを確認
            // if (exam[findTreatDate].examStatus === "0") {
            // 検査結果なしの場合はとりあえず空欄
            // mod FNSI-検体検査の表示の修正 楊 start
            //findConvertDataForTreatDate.value2 = " ";
            // findConvertDataForTreatDate.value2 = "";
            // mod FNSI-検体検査の表示の修正 楊 end
            // return; // forEachでのcontinueの代替
            // }
            // add FNSI-検体検査の表示の修正 楊 start
            // 検査結果ありの場合は白丸
            // findConvertDataForTreatDate.value2 = "●";
            // dateListLen2 += 1;
            // findConvertDataForTreatDate.value2 = dateListLen2 === 1 ? " " : dateListLen2;
            // add FNSI-検体検査の表示の修正 楊 end
            // del FNSI-障害票一覧_患者経過総合ビューアNo.20 李 end
          });
          if (value1Tmp == 0) {
            findConvertDataForTreatDate.value1 = "";
          }else{
            findConvertDataForTreatDate.value1 = value1Tmp;
          }
          if (value2Tmp == 0) {
            findConvertDataForTreatDate.value2 = "";
          }else{
            findConvertDataForTreatDate.value2 = value2Tmp;
          }
          // mod #10036 患者経過総合ビューアの検査予定の表示不正 zhangbo end
        });
      });

      return convertData;
    },

    /**
     * 放射線検査依頼・結果データを表示用に加工
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     */
    // mod FNSI-検体検査の表示の修正 楊 start
    // async convertRadData({ getters, dispatch }, { selectLayoutCd }) {
    async convertRadData({ getters, dispatch }, { layout, selectLayoutCd }) {
      // mod FNSI-検体検査の表示の修正 楊 end
      // 加工した表示用データ格納用
      // mod FNSI-放射線検査の表示の修正 楊 start
      // const convertData = [];
      // 一般撮影検査前回検査日
      const copyLastRadDate = getters.getLastRadDate;
      var str = "";
      if(copyLastRadDate) {
        let dateTemp = moment(copyLastRadDate).format("YYYY/MM/DD")
        const week = moment(copyLastRadDate).day();
        let weekList = ["日", "月", "火", "水", "木", "金", "土"];
        let tWeek = "(" + weekList[week] + ")";
        str = "\n前回検査予定日：".concat("\n").concat(dateTemp).concat(tWeek);
      }
      const convertData = [
        {
          itemName: `一般撮影検査予定${str}`,
          itemNo: 1,
          data: []
        }
      ];
      // mod FNSI-放射線検査の表示の修正 楊 end

      // 検索用日付リスト
      const searchDateList = getters.getDateList;

      // DB取得データ(pat_rad_main)
      const copyRadMainData = getters.getRadMainData;

      // 検索用表示項目リスト(治療情報-放射線検査)の取得
      const searchDispLayoutItemList = await dispatch(
        "getDispLayoutItemForSubCategory",
        {
          layoutCd: selectLayoutCd,
          // mod FNSI-放射線検査の表示の修正 楊 start
          // categoryNo: 1, // 治療情報
          // subCategoryNo: 63 // 放射線検査
          categoryNo: layout.categoryNo, // 治療情報
          subCategoryNo: layout.categoryItem[0].subCategoryNo // 放射線検査
          // mod FNSI-放射線検査の表示の修正 楊 end
        }
      );
      if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
        return [];
      }

      // add FNSI-放射線検査の表示の修正 楊 start
      // 日付分放射線検査回数
      var dateListLen = 0;
      // add FNSI-放射線検査の表示の修正 楊 end

      // 表示用データの作成
      searchDispLayoutItemList.forEach(eleDispItem => {
        // 対象番号の表示項目を抽出
        let findConvertData = convertData.find(item => {
          return eleDispItem.itemNo === item.itemNo;
        });

        // 対象番号が存在しない場合、雛形構造を追加
        if (!findConvertData) {
          const temp = deepCopy(layoutDispData);
          temp.itemNo = eleDispItem.itemNo;
          temp.itemName = eleDispItem.itemName;
          findConvertData = temp;
          convertData.push(findConvertData);
        }

        // 表示分日付(期間)ループ
        searchDateList.forEach(eleDate => {
          // 対象日付の抽出
          let findConvertDataForTreatDate = findConvertData.data.find(item => {
            return item.treatDate === eleDate;
          });
          // 対象日付のデータが存在しない場合、雛形構造を追加
          if (!findConvertDataForTreatDate) {
            const temp = deepCopy(layoutDispData_data);
            temp.treatDate = eleDate;
            findConvertDataForTreatDate = temp;
            findConvertData.data.push(findConvertDataForTreatDate);
          }

          const findTreatDate = findConvertDataForTreatDate.treatDate;

          // add FNSI-放射線検査の表示の修正 楊 start
          // 日付毎検査依頼の集計
          dateListLen = 0;
          // add FNSI-放射線検査の表示の修正 楊 end

          copyRadMainData.forEach(rad => {
            // 放射線検査レコードがなければ終了
            if (!rad) {
              return; // forEachでのcontinueの代替
            }

            // 対象日付に放射線検査レコードが存在するかを確認
            if (!rad[findTreatDate]) {
              return; // forEachでのcontinueの代替
            }

            // 削除フラグがあるか確認
            if (rad[findTreatDate].isDel === "1") {
              return; // forEachでのcontinueの代替
            }
            //mod FNSI no.5990 劉全航 start
            // add FNSI-放射線検査の表示の修正 楊 start
            // dateListLen += 1;
            // add FNSI-放射線検査の表示の修正 楊 end
            let jsonObject = rad[findTreatDate].orderRadSetInfo;
            let radSetInfo = JSON.parse(jsonObject);
            //mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、紹介状、処方、患者イベントのデータが正常に表示されない djy start
            //dateListLen = radSetInfo.length;
            dateListLen += radSetInfo.length;
            //mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、紹介状、処方、患者イベントのデータが正常に表示されない djy end
            //mod FNSI no.5990 劉全航 end

            // 放射線検査レコードが存在する(依頼はされている)場合は白丸
            findConvertDataForTreatDate.isNotClickable = rad[findTreatDate].readOnly;

            // mod FNSI-放射線検査の表示の修正 楊 start
            //  findConvertDataForTreatDate.value1 = "○";
            //del #9738患者経過総合ビューアで検査依頼、一般撮影検査依頼、紹介状、処方、患者イベントのデータが正常に表示されな djy start
            //if (dateListLen > 1) {
            //  findConvertDataForTreatDate.value1 = dateListLen;
            //} else {
            //  findConvertDataForTreatDate.value1 = " ";
            //}
            //del #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、紹介状、処方、患者イベントのデータが正常に表示されない djy end
            // mod FNSI-放射線検査の表示の修正 楊 end

          });
          //add #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、紹介状、処方、患者イベントのデータが正常に表示されない djy start
          if (dateListLen > 1) {
            findConvertDataForTreatDate.value1 = dateListLen;
          } else if(dateListLen == 1){
            findConvertDataForTreatDate.value1 = " ";
          }else {
            findConvertDataForTreatDate.value1 = "";
          }
          //add #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、紹介状、処方、患者イベントのデータが正常に表示されない djy end
        });
      });

      return convertData;
    },

    /** add FNSI-観察記録を追加 楊 start */
    /**
     * 観察記録を表示用に加工
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     */
    async convertObserData({ getters }, { layout }) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      const searchDateList = getters.getDateList;

      // DB取得データ(pat_rad_main)
      const copyPatEventDataList = getters.getPatEventDataList;

      // 検索用表示項目リスト(観察記録)の取得
      layout.categoryItem.forEach(eleItem => {
        const searchDispLayoutItemList = eleItem.subCategoryItem;

        if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
          return [];
        }

        // 日付分観察記録件数
        var dateListLen = 0;

        // 表示用データの作成
        searchDispLayoutItemList.forEach(eleDispItem => {
          // 対象番号の表示項目を抽出
          let findConvertData = convertData.find(item => {
            return eleDispItem.itemNo === item.itemNo;
          });

          // 対象番号のデータを抽出
          // 加工データ格納用(リスト)
          let findPatEventDataList = [];
          copyPatEventDataList.forEach(eleEvent => {
            if (eleEvent.subCategoryCd === eleDispItem.itemNo) {
              findPatEventDataList.push(eleEvent);
            }
          });

          // 対象番号が存在しない場合、雛形構造を追加
          if (!findConvertData) {
            const temp = deepCopy(layoutDispData);
            temp.itemNo = eleDispItem.itemNo;
            temp.itemName = eleDispItem.itemName;
            findConvertData = temp;
            convertData.push(findConvertData);
          }

          // 表示分日付(期間)ループ
          searchDateList.forEach(eleDate => {
            // 対象日付の抽出
            let findConvertDataForTreatDate = findConvertData.data.find(item => {
              return item.treatDate === eleDate;
            });
            // 対象日付のデータが存在しない場合、雛形構造を追加
            if (!findConvertDataForTreatDate) {
              const temp = deepCopy(layoutDispData_data);
              temp.treatDate = eleDate;
              findConvertDataForTreatDate = temp;
              findConvertData.data.push(findConvertDataForTreatDate);
            }

            // 日付毎検査依頼の集計
            dateListLen = 0;

            findPatEventDataList.forEach(patEvent => {

              // 対象日付に観察記録レコードが存在するかを確認
              if (patEvent.eventStartDate !== findConvertDataForTreatDate.treatDate) {
                return; // forEachでのcontinueの代替
              }

              dateListLen += 1;

              // 観察記録レコードが存在する
              if (dateListLen > 0) {
                findConvertDataForTreatDate.value1 = `${dateListLen}件`;
                findConvertDataForTreatDate.value2 = `${dateListLen}件`;
              } else {
                findConvertDataForTreatDate.value1 = "";
                findConvertDataForTreatDate.value2 = "";
              }
            });
          });
        });
      });
      return convertData;
    },
    /** add FNSI-観察記録を追加 楊 end */

    // add FNSI-紹介状を追加 楊 start
    /**
     * 紹介状を表示用に加工
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     */
    async convertLetterData({ getters }, { layout }) {
      // add FNSI-FutreNetWeb+SI課題管理No.5317 李 start
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      const searchDateList = getters.getDateList;

      // DB取得データ(pat_event)紹介状
      //7342 add 紹介状のイベント日付が登録日になる 張 start
      // const copyPatEventDataList = getters.getPatientDataList;
      const copyPatEventDataList = getters.getLetterDataList;
      //7342 add 紹介状のイベント日付が登録日になる 張 end
      // 検索用表示項目リスト(紹介状)の取得
      layout.categoryItem.forEach(eleItem => {
        const searchDispLayoutItemList = eleItem.subCategoryItem;
        if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
          return [];
        }

        // 表示用データの作成
        searchDispLayoutItemList.forEach(eleDispItem => {
          // 対象番号の表示項目を抽出
          let findConvertData = convertData.find(item => {
            return eleDispItem.itemNo === item.itemNo;
          });

          // 加工データ格納用(リスト)
          let findPatEventDataList = [];
          copyPatEventDataList.forEach(eleEvent => {
            if (eleEvent.letterInfo) {
              findPatEventDataList.push(eleEvent);
            }
          });

          // 対象番号が存在しない場合、雛形構造を追加
          if (!findConvertData) {
            const temp = deepCopy(layoutDispData);
            temp.itemNo = eleDispItem.itemNo;
            temp.itemName = eleDispItem.itemName;
            findConvertData = temp;
            convertData.push(findConvertData);
          }

          // 表示分日付(期間)ループ
          searchDateList.forEach(eleDate => {
            // 対象日付の抽出
            let findConvertDataForTreatDate = findConvertData.data.find(item => {
              return item.treatDate === eleDate;
            });
            // 対象日付のデータが存在しない場合、雛形構造を追加
            if (!findConvertDataForTreatDate) {
              const temp = deepCopy(layoutDispData_data);
              temp.treatDate = eleDate;
              findConvertDataForTreatDate = temp;
              findConvertData.data.push(findConvertDataForTreatDate);
            }

            let showStr = "";
            //mod FNSI no.5926 劉全航 start
            // 転入の集計
            // let dateInCount = 0;
            // // 転出の集計
            // let dateOutCount = 0;

            findPatEventDataList.forEach(patEvent => {
              // 対象日付にレコードが存在するかを確認
              // add 7342 紹介状のイベント日付が登録日になる 張 start
              // if (patEvent.eventStartDate !== findConvertDataForTreatDate.treatDate) {
              if (moment(patEvent.reportDate).format("YYYYMMDD")!== findConvertDataForTreatDate.treatDate) {
                // add 7342 紹介状のイベント日付が登録日になる 張 end
                return; // forEachでのcontinueの代替
              }

              // 紹介状データの取得
              const inOutData = JSON.parse(patEvent.letterInfo);
              // mod FutreNetWeb+SI課題管理No5926 趙 start
              // const toFacilityName = patEvent.templateName;
              // let toFacilityCd = inOutData.to_facility_cd;
              let toFacilityName = "";
              if(patEvent.templateName !== null){
                toFacilityName = patEvent.templateName;
              }
              let toFacilityCd = "";
              if(inOutData.to_facility_cd !== null){
                toFacilityCd = inOutData.to_facility_cd;
              }
              // mod FutreNetWeb+SI課題管理No5926 趙 end
              let facilityList = [];
              let toMedicalInstitutionCd = inOutData.to_medical_institution_cd;

              // add #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm start
              if (showStr.length > 0) {
                showStr = showStr.concat("\n");
              }
              // add #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm end

              if(toMedicalInstitutionCd === null){
                if (inOutData.letter_category == '1') {
                  // dateInCount += 1;
                  showStr = showStr.concat("転入").concat("：".concat(toFacilityCd));
                  // del #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm start
                  // showStr = showStr.concat("<br>");
                  // del #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm end
                  // 転出の場合
                } else if (inOutData.letter_category == '0') {
                  // dateOutCount += 1;
                  showStr = showStr.concat("転出").concat("：".concat(toFacilityCd));
                  // del #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm start
                  // showStr = showStr.concat("<br>");
                  // del #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm end
                }
                findConvertDataForTreatDate.value1 = showStr;
                findConvertDataForTreatDate.value2 = showStr;
              }else{
                // del FutreNetWeb+SI課題管理No5926 趙 start
                // facility().then(data => {
                //   facilityList.push(...data);
                //   let toFacility = facilityList.find(o=> o.facilityCd === toFacilityCd);
                //   let toFacilityName = toFacility.facilityName;
                // del FutreNetWeb+SI課題管理No5926 趙 end
                // 転入の場合
                if (inOutData.letter_category == '1') {
                  // dateInCount += 1;
                  showStr = showStr.concat("転入").concat("：".concat(toFacilityName));
                  // del #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm start
                  // showStr = showStr.concat("<br>");
                  // del #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm end
                  // 転出の場合
                } else if (inOutData.letter_category == '0') {
                  // dateOutCount += 1;
                  showStr = showStr.concat("転出").concat("：".concat(toFacilityName));
                  // del #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm start
                  // showStr = showStr.concat("<br>");
                  // del #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm end
                }
                findConvertDataForTreatDate.value1 = showStr;
                findConvertDataForTreatDate.value2 = showStr;
                // });
              }

              // 転入の場合
              // if (inOutData.letter_category == '1') {
              //   dateInCount += 1;

              //  転出の場合
              // } else if (inOutData.letter_category == '0') {
              //   dateOutCount += 1;
              // }
            });

            // if (dateInCount != 0 && dateOutCount != 0) {
            //   showStr = showStr.concat("入").concat("：".concat(`${dateInCount}件`));
            //   showStr = showStr.concat("<br>");
            //   showStr = showStr.concat("出").concat("：".concat(`${dateOutCount}件`));
            // } else if (dateInCount != 0 && dateOutCount == 0) {
            //   showStr = showStr.concat("入").concat("：".concat(`${dateInCount}件`));
            // } else if (dateInCount == 0 && dateOutCount != 0) {
            //   showStr = showStr.concat("出").concat("：".concat(`${dateOutCount}件`));
            // }
            //mod FNSI no.5926 劉全航 end
          });
        });
      });

      return convertData;
      // add FNSI-FutreNetWeb+SI課題管理No.5317 李 end

      // del FNSI-FutreNetWeb+SI課題管理No.5317 李 start
      // // 加工した表示用データ格納用
      // const convertData = [];
      // // 検索用日付リスト
      // const searchDateList = getters.getDateList;

      // // DB取得データ(pat_unique)
      // const copyPatUniqueDataList = getters.getPatUniqueDataList;

      // // 検索用表示項目リスト(紹介状)の取得
      // const searchDispLayoutItemList = layout.categoryItem[0].subCategoryItem;

      // if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
      //   return [];
      // }
      // // 全施設マスタ一覧の取得
      // const resSysFacility = await sendRequestGetSysFacility();

      // const inOutData = JSON.parse(copyPatUniqueDataList.in_out_visit_history_info);

      // // 表示用データの作成
      // searchDispLayoutItemList.forEach(eleDispItem => {
      //   // 対象番号の表示項目を抽出
      //   let findConvertData = convertData.find(item => {
      //     return eleDispItem.itemNo === item.itemNo;
      //   });

      //   // 対象番号が存在しない場合、雛形構造を追加
      //   if (!findConvertData) {
      //     const temp = deepCopy(layoutDispData);
      //     temp.itemNo = eleDispItem.itemNo;
      //     temp.itemName = eleDispItem.itemName;
      //     findConvertData = temp;
      //     convertData.push(findConvertData);
      //   }

      //   // 表示分日付(期間)ループ
      //   searchDateList.forEach(eleDate => {
      //     // 対象日付の抽出
      //     let findConvertDataForTreatDate = findConvertData.data.find(item => {
      //       return item.treatDate === eleDate;
      //     });
      //     // 対象日付のデータが存在しない場合、雛形構造を追加
      //     if (!findConvertDataForTreatDate) {
      //       const temp = deepCopy(layoutDispData_data);
      //       temp.treatDate = eleDate;
      //       findConvertDataForTreatDate = temp;
      //       findConvertData.data.push(findConvertDataForTreatDate);
      //     }

      //     let showStr = "";
      //     inOutData.forEach(patLetter => {
      //       // 紹介状レコードがなければ終了
      //       if (!patLetter) {
      //         return; // forEachでのcontinueの代替
      //       }

      //       // 対象日付に紹介状レコードが存在するかを確認
      //       if (patLetter.period_start !== findConvertDataForTreatDate.treatDate) {
      //         return; // forEachでのcontinueの代替
      //       }

      //       if (patLetter.move_in_out === "2") {
      //         // 施設名を取得
      //         const rstFacilityMst = resSysFacility.data.find(mstData => {
      //           return mstData.facilityCd === patLetter.from_facility;
      //         });

      //         // "2":転入の場合、「転出：元施設」を設定
      //         if (showStr) {
      //           showStr = showStr.concat("<br>");
      //         }
      //         showStr = showStr.concat("転入").concat(rstFacilityMst ? "：".concat(rstFacilityMst.facilityName) : "");

      //       } else if (patLetter.move_in_out === "3") {
      //         // 施設名を取得
      //         const rstFacilityMst = resSysFacility.data.find(mstData => {
      //           return mstData.facilityCd === patLetter.to_facility;
      //         });

      //         // "3":転出の場合、「転出：先施設」を設定
      //         if (showStr) {
      //           showStr = showStr.concat("<br>");
      //         }
      //         showStr = showStr.concat("転出").concat(rstFacilityMst ? "：".concat(rstFacilityMst.facilityName) : "");

      //       } else {
      //         // 転入、転出以外の場合、出力しない
      //         return; // forEachでのcontinueの代替
      //       }
      //       findConvertDataForTreatDate.value1 =`${showStr}`;
      //       findConvertDataForTreatDate.value2 =`${showStr}`;
      //     });
      //   });
      // });
      // return convertData;
      // del FNSI-FutreNetWeb+SI課題管理No.5317 李 end
    },
    // add FNSI-紹介状を追加 楊 end

    /** add FNSI-患者イベント（仮）を追加 李 start */
    /**
     * 患者イベント（仮）を表示用に加工
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     */
    async convertPatientData({ getters }, { layout }) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      const searchDateList = getters.getDateList;

      // DB取得データ(pat_rad_main)
      const copyPatEventDataList = getters.getPatientDataList;

      // 検索用表示項目リスト(患者イベント（仮）)の取得
      layout.categoryItem.forEach(eleItem => {
        const searchDispLayoutItemList = eleItem.subCategoryItem;

        if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
          return [];
        }

        // 表示用データの作成
        searchDispLayoutItemList.forEach(eleDispItem => {
          // 対象番号の表示項目を抽出
          let findConvertData = convertData.find(item => {
            return eleDispItem.itemNo === item.itemNo;
          });

          // 対象番号のデータを抽出
          // 加工データ格納用(リスト)
          let findPatEventDataList = [];
          copyPatEventDataList.forEach(eleEvent => {
            //mod FNSI-6080 劉全航 start
            // if (eleEvent.subCategoryCd === eleDispItem.itemNo) {
            if ((eleEvent.subCategoryCd === eleDispItem.itemNo && eleDispItem.isPatEventSub === 1 )
              || (eleEvent.categoryCd === eleDispItem.itemNo && eleDispItem.isPatEventSub === 0)) {
              //mod FNSI-6080 劉全航 end
              findPatEventDataList.push(eleEvent);
            }
          });

          // add FNSI-FutreNetWeb+SI課題管理No.5318 李 start
          if (!findPatEventDataList) return;
          // add FNSI-FutreNetWeb+SI課題管理No.5318 李 end

          // 対象番号が存在しない場合、雛形構造を追加
          if (!findConvertData) {
            const temp = deepCopy(layoutDispData);
            temp.itemNo = eleDispItem.itemNo;
            temp.itemName = eleDispItem.itemName;
            temp.isPatEventSub = eleDispItem.isPatEventSub;
            findConvertData = temp;
            convertData.push(findConvertData);
          }

          // 表示分日付(期間)ループ
          searchDateList.forEach(eleDate => {
            // 対象日付の抽出
            let findConvertDataForTreatDate = findConvertData.data.find(item => {
              return item.treatDate === eleDate;
            });
            // 対象日付のデータが存在しない場合、雛形構造を追加
            if (!findConvertDataForTreatDate) {
              const temp = deepCopy(layoutDispData_data);
              temp.treatDate = eleDate;
              findConvertDataForTreatDate = temp;
              findConvertData.data.push(findConvertDataForTreatDate);
            }

            // mod FNSI-FutreNetWeb+SI課題管理No.5318 李 start
            const dateEventList = findPatEventDataList.filter(item => {
              return item.eventStartDate == eleDate;
            });

            if (dateEventList) {
              findConvertDataForTreatDate.value1 = dateEventList.length;
              findConvertDataForTreatDate.value2 = dateEventList.length;
            }

            // findPatEventDataList.forEach(patEvent => {

            //   // 対象日付に患者イベント（仮）レコードが存在するかを確認
            //   if (patEvent.eventStartDate !== findConvertDataForTreatDate.treatDate) {
            //     return; // forEachでのcontinueの代替
            //   }

            //   // 開始時刻表示
            //   let eventStartTimeStr = "";
            //   if(!patEvent.eventStartTime == false) {
            //     eventStartTimeStr = patEvent.eventStartTime.slice(0,2) + ':' + patEvent.eventStartTime.slice(2);
            //   }
            //   findConvertDataForTreatDate.value1 = eventStartTimeStr;
            //   findConvertDataForTreatDate.value2 = eventStartTimeStr;
            // });
            // mod FNSI-FutreNetWeb+SI課題管理No.5318 李 end
          });
        });
      });
      // add bug 6080 修正 chen start
      convertData.forEach(items => {
        items.data.forEach(item => {
          item.ordNo = "-1";
        });
      });
      // add bug 6080 修正 chen end
      return convertData;
    },
    /** add FNSI-患者イベント（仮）を追加 李 end */



    /** add FNSI-処方を追加 姜 start */
    /**
     * 患者イベント（仮）を表示用に加工
     * @param {Number} selectLayoutCd 選択している患者経過総合ビューアレイアウトマスタのレイアウト番号
     */
    async convertPrescriptionDataList({ getters }, { layout }) {
      // 加工した表示用データ格納用
      const convertData = [];

      // 検索用日付リスト
      const searchDateList = getters.getDateList;

      // DB取得データ(pat_rad_main)
      const patPrescriptionList = getters.getPrescriptionDataList;

      // 検索用表示項目リスト(処方)の取得
      layout.categoryItem.forEach(eleItem => {
        const searchDispLayoutItemList = eleItem.subCategoryItem;

        if (!searchDispLayoutItemList || 0 === searchDispLayoutItemList.length) {
          return [];
        }

        // 表示用データの作成
        searchDispLayoutItemList.forEach(eleDispItem => {
          // 対象番号の表示項目を抽出
          let findConvertData = convertData.find(item => {
            return eleDispItem.itemNo === item.itemNo;
          });

          // 対象番号のデータを抽出
          // 加工データ格納用(リスト)
          let findPatEventDataList = [];
          patPrescriptionList .forEach(eleEvent => {
            findPatEventDataList.push(eleEvent);
          });

          // 対象番号が存在しない場合、雛形構造を追加
          if (!findConvertData) {
            const temp = deepCopy(layoutDispData);
            temp.itemNo = eleDispItem.itemNo;
            temp.itemName = eleDispItem.itemName;
            findConvertData = temp;
            convertData.push(findConvertData);
          }

          // 表示分日付(期間)ループ
          searchDateList.forEach(eleDate => {
            // 対象日付の抽出
            let findConvertDataForTreatDate = findConvertData.data.find(item => {
              return item.treatDate === eleDate;
            });
            // 対象日付のデータが存在しない場合、雛形構造を追加
            if (!findConvertDataForTreatDate) {
              const temp = deepCopy(layoutDispData_data);
              temp.treatDate = eleDate;
              findConvertDataForTreatDate = temp;
              findConvertData.data.push(findConvertDataForTreatDate);
            }

            findPatEventDataList.forEach(patEvent => {
              if (patEvent.issue_date !== eleDate) {
                return; // forEachでのcontinueの代替
              }
              if (eleDispItem.itemName = "処方") {
                findConvertDataForTreatDate.value1 = patEvent.syohou;
                findConvertDataForTreatDate.value2 = patEvent.syohou;
              }
            });
          });
        });
      });
      return convertData;
    },
    /** add FNSI-処方を追加 姜 end */





    /**
     * 風袋データを表示用に加工
     */
    async convertTareInfoData({ getters }, { listIndex }) {
      // 加工した表示用データ格納
      const convertData = [];

      // 検索用日付リスト
      const seachDateList = getters.getDateList;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      // 検索用表示項目リスト(治療条件-風袋)の作成
      const searchDispLayoutItemList = [];
      for (let i = 1; i <= 11; i++) {
        const obj = {};
        obj.itemNo = i;
        if (11 !== i) {
          // 名称項目作成
          if (0 !== i % 2) {
            const num = Math.round(i / 2);
            obj.itemName = `項目${num}名称`;
            obj.class = 0;
          } else {
            // 重さ項目作成
            obj.itemName = `項目${i / 2}重さ(g)`;
            obj.class = 1;
          }
        } else {
          // 合計量作成
          obj.itemName = "風袋補正合計量";
        }
        searchDispLayoutItemList.push(obj);
      }

      // 表示用データの作成
      searchDispLayoutItemList.forEach(eleDispItem => {
        // 対象番号の表示項目を抽出
        let findConvertData = convertData.find(item => {
          return eleDispItem.itemNo === item.itemNo;
        });

        // 対象番号が存在しない場合、雛形構造を追加
        if (!findConvertData) {
          const temp = deepCopy(layoutDispData);
          temp.itemNo = eleDispItem.itemNo;
          temp.itemName = eleDispItem.itemName;
          findConvertData = temp;
          convertData.push(findConvertData);
        }

        // 表示日付(期間)ループ
        seachDateList.forEach(eleDate => {
          // 対象日付の抽出
          let findConvertDataForTreatDate = findConvertData.data.find(item => {
            return item.treatDate === eleDate;
          });

          // 対象日付けのデータが存在しない場合、雛形構造を追加
          if (!findConvertDataForTreatDate) {
            const temp = deepCopy(layoutDispData_data);
            temp.treatDate = eleDate;
            findConvertDataForTreatDate = temp;
            findConvertData.data.push(findConvertDataForTreatDate);
          }

          // 対象日付けに治療情報が存在するかを確認
          if (!copyTreatmentData[findConvertDataForTreatDate.treatDate]) {
            return; // forEachでのcontinueの
          }

          // オーダー番号を格納
          findConvertDataForTreatDate.ordNo =
            copyTreatmentData[findConvertDataForTreatDate.treatDate].ordNo;

          findConvertDataForTreatDate.isNotClickable = copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly;
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const indCondInfo = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate]['indCondInfo']);
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          for (let i = 1; i <= 2; i++) {
            const columnName = 1 === i ? "indTareInfo" : "rstTareInfo";
            // 対象風袋データが存在する場合、その値を格納納
            let indTareInfo = JSON.parse(
              copyTreatmentData[eleDate][columnName]
            );
            // 値がなければ処理終了
            if (!indTareInfo) {
              findConvertDataForTreatDate[`value${i}`] = null;
              // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
              if (columnName === 'indTareInfo' && !indCondInfo) {
                findConvertDataForTreatDate.isDisabled1 = true;
              }
              // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
              // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
              // return;
              continue;
              // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
            }

            // 実績の場合、後体重測定時の風袋を取得
            if (2 === i) {
              indTareInfo = indTareInfo.after;
            }

            for (const tareItem in indTareInfo) {
              // 項目番号取得 ex.name_1 => 1
              const tareItemCode = Number(tareItem.slice(-1));
              // レイアウトマスタに定義したItemNo用に変換
              let itemCd = 0;
              // DB項目クラス
              const dbClass = "n" === tareItem.slice(0, 1) ? 0 : 1;
              // DBの項目クラスと格納先の項目クラスが異なれば次のループ
              if (dbClass !== eleDispItem.class) {
                continue;
              }

              // 「名称」項目だった場合
              if (0 === eleDispItem.class) {
                itemCd = tareItemCode * 2 - 1;
              } else {
                itemCd = tareItemCode * 2;
              }
              // レイアウトマスタの項目番号とDBの項目番号が一致すれば、値を格納
              if (eleDispItem.itemNo === itemCd) {
                // classが1(重さ項目)で値がnullでない場合、単位を追加(g)
                if (1 === eleDispItem.class && null !== indTareInfo[tareItem]) {
                  findConvertDataForTreatDate[
                    `value${i}`
                    ] = `${indTareInfo[tareItem]}g`;
                } else {
                  findConvertDataForTreatDate[`value${i}`] =
                    indTareInfo[tareItem];
                }
              }
            }
          }
        });
      });
      return convertData;
    },

    /**
     * 除水補正データを表示用に加工
     */
    async convertOffWaterInfoData({ getters }, { listIndex }) {
      // 加工した表示用データ格納
      const convertData = [];

      // 検索用日付リスト
      const seachDateList = getters.getDateList;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      // 検索用表示項目リスト(治療条件-除水補正)の作成
      const searchDispLayoutItemList = [];
      // レイアウトマスタ格納用データ
      for (let i = 1; i <= 11; i++) {
        const obj = {};
        obj.itemNo = i;
        if (11 !== i) {
          // 名称項目作成
          if (0 !== i % 2) {
            const num = Math.round(i / 2);
            obj.itemName = `項目${num}名称`;
            obj.class = 0;
          } else {
            // 重さ項目作成
            obj.itemName = `項目${i / 2}重さ(g)`;
            obj.class = 1;
          }
        } else {
          // 合計量作成
          obj.itemName = "除水補正合計量";
        }
        searchDispLayoutItemList.push(obj);
      }

      // 表示用データの作成
      searchDispLayoutItemList.forEach(eleDispItem => {
        // 対象番号の表示項目を抽出
        let findConvertData = convertData.find(item => {
          return eleDispItem.itemNo === item.itemNo;
        });

        // 対象番号が存在しない場合、雛形構造を追加
        if (!findConvertData) {
          const temp = deepCopy(layoutDispData);
          temp.itemNo = eleDispItem.itemNo;
          temp.itemName = eleDispItem.itemName;
          findConvertData = temp;
          convertData.push(findConvertData);
        }

        // 表示日付(期間)ループ
        seachDateList.forEach(eleDate => {
          // 対象日付の抽出
          let findConvertDataForTreatDate = findConvertData.data.find(item => {
            return item.treatDate === eleDate;
          });

          // 対象日付けのデータが存在しない場合、雛形構造を追加
          if (!findConvertDataForTreatDate) {
            const temp = deepCopy(layoutDispData_data);
            temp.treatDate = eleDate;
            findConvertDataForTreatDate = temp;
            findConvertData.data.push(findConvertDataForTreatDate);
          }

          // 対象日付けに治療情報が存在するかを確認
          if (!copyTreatmentData[findConvertDataForTreatDate.treatDate]) {
            return; // forEachでのcontinueの
          }

          // オーダー番号を格納
          findConvertDataForTreatDate.ordNo =
            copyTreatmentData[findConvertDataForTreatDate.treatDate].ordNo;
          findConvertDataForTreatDate.isNotClickable = copyTreatmentData[findConvertDataForTreatDate.treatDate].readOnly;
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          const indCondInfo = JSON.parse(copyTreatmentData[findConvertDataForTreatDate.treatDate]['indCondInfo']);
          // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          for (let i = 1; i <= 2; i++) {
            const columnName = 1 === i ? "indOffWaterInfo" : "rstOffWaterInfo";
            // 対象風袋データが存在する場合、その値を格納
            const offWater = JSON.parse(copyTreatmentData[eleDate][columnName]);
            // 値がなければ処理終了
            if (!offWater) {
              findConvertDataForTreatDate[`value${i}`] = null;
              // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
              if (columnName === 'indOffWaterInfo' && !indCondInfo) {
                findConvertDataForTreatDate.isDisabled1 = true;
              }
              // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
              continue;
            }

            for (const offWaterItem in offWater) {
              // 項目番号取得 ex.name_1 => 1
              const offWaterItemCode = offWaterItem.slice(-1);
              // レイアウトマスタに定義したItemNo用に変換
              let itemCd = 0;
              // DB項目クラス
              const dbClass = "n" === offWaterItem.slice(0, 1) ? 0 : 1;
              // DBの項目クラスと格納先の項目クラスが異なれば次のループ
              if (dbClass !== eleDispItem.class) {
                continue;
              }

              // 「名称」項目だった場合
              if (0 === eleDispItem.class) {
                itemCd = offWaterItemCode * 2 - 1;
              } else {
                itemCd = offWaterItemCode * 2;
              }

              // レイアウトマスタの項目番号とDBの項目番号が一致すれば、値を格納
              if (eleDispItem.itemNo === itemCd) {
                if (
                  1 === eleDispItem.class &&
                  null !== offWater[offWaterItem]
                ) {
                  findConvertDataForTreatDate[
                    `value${i}`
                    ] = `${offWater[offWaterItem]}g`;
                } else {
                  findConvertDataForTreatDate[`value${i}`] =
                    offWater[offWaterItem];
                }
              }
            }
          }
        });
      });
      return convertData;
    },

    /**
     * 除水プログラムデータを表示用に加工
     */
    async convertUfrProgramData({ getters }, { listIndex }) {
      // 加工した表示用データ格納用
      // 除水プログラムは小項目がないから、配列の中身は固定にする
      const convertData = [
        {
          // mod FNSI-UFRプログラムの修正 楊 start
          //itemName: "UFRプログラム",
          itemName: "除水プログラム",
          // mod FNSI-UFRプログラムの修正 楊 end
          data: []
        },
        {
          // mod FNSI-UFRプログラムの修正 楊 start
          //itemName: "UFRプログラム",
          itemName: "除水プログラム",
          // mod FNSI-UFRプログラムの修正 楊 end
          data: []
        }
      ];

      // 検索用日付リスト
      // const searchDateList = getters.getDateList;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }
      for (const treatData in copyTreatmentData) {
        const ordInfo = copyTreatmentData[treatData];
        const deviceSetInfo =
          ordInfo &&
          ordInfo.indDeviceSetInfo &&
          JSON.parse(ordInfo.indDeviceSetInfo);
        let ufrInfo;
        if (deviceSetInfo && deviceSetInfo.ufr) {
          ufrInfo = deviceSetInfo.ufr;
        } else {
          ufrInfo = defaultMstDeviceInfo.ord.ufr;
        }
        const mode =
          ufrInfo &&
          (() => {
            switch (parseInt(ufrInfo.dev.A[290])) {
              case 1:
                return "ufr-step";
              case 2:
                return "ufr-course";
              default:
                break;
            }
          })();

        if (ordInfo) {
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
          // 装置モードをマスタから取得
          // 治療方法マスタ
          let mstRecord = getters.getMstTreatmentData.find(mstData => {
            return mstData.treatmentCd === ordInfo.indTreatmentCd;
          });
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
          // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
          if (!mstRecord) {
            mstRecord = getters.getMstTreatmentDataIsDel.find(mstDataDel => {
              return mstDataDel.treatmentCd === ordInfo.indTreatmentCd;
            });
          }
          // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
          convertData[0].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            value1: mode ? "ON" : "OFF",
            type: "chart",
            data: null,
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            // isDisabled: mstRecord.deviceMode==9?true:false,
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            isNotClickable: ordInfo.readOnly
          });

          // グラフデータ設定
          const stepNumber = ufrInfo.dev.A[311];
          // mod 9802 除水プログラムのグラフが登録内容とことなる。zhou start
          // let stepValues = Object.values(ufrInfo.dev.B);
          //ufr.dev.Aの"301": ＵＦＲプログラム指数１~"310": ＵＦＲプログラム指数１０設定する
          // #9445 除水プログラムのパターン表示だけが左寄りになっている。linjunfeng start
          // let stepValues = Object.values(ufrInfo.dev.A).slice(11, 23);
          let stepValues = [
            ufrInfo.dev.A[301],
            ufrInfo.dev.A[302],
            ufrInfo.dev.A[303],
            ufrInfo.dev.A[304],
            ufrInfo.dev.A[305],
            ufrInfo.dev.A[306],
            ufrInfo.dev.A[307],
            ufrInfo.dev.A[308],
            ufrInfo.dev.A[309],
            ufrInfo.dev.A[310],
          ]
          // #9445 除水プログラムのパターン表示だけが左寄りになっている。linjunfeng end
          // mod 9802 除水プログラムのグラフが登録内容とことなる。zhou end
          stepValues = stepValues.map((device, index) => {
            return index < stepNumber ? device : null;
          });

          convertData[1].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            value1: mode ? "ON" : "OFF",
            // type: "chart",
            data: mode ?ufrInfo: null,
            // value1:  mstRecord.deviceMode!=9?mode ?"ON": "OFF":null,
            type: "chart",
            // data: mode ? mstRecord.deviceMode!=9?ufrInfo:null : null,
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            chartData: [
              {
                mode,
                courseValue: ufrInfo.dev.A[312],
                courseStartValue: ufrInfo.dev.A[313],
                courseEndValue: ufrInfo.dev.A[314],
                stepValues
              }
            ],
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            // isDisabled: mstRecord.deviceMode==9?true:false,
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isDisabled: !ordInfo.indCondInfo,
            // isNotClickable: ordInfo.readOnly
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            // isNotClickable: ordInfo.readOnly || !ordInfo.indCondInfo,
            isNotClickable: !ordInfo.indCondInfo,
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          });
        } else {
          convertData[0].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
          convertData[1].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
        }
      }
      // add FNSI-グラフ３軸表示対応「プログラムの表示」 周 start
      convertData.shift();
      // add FNSI-グラフ３軸表示対応「プログラムの表示」 周 end
      return convertData;
    },

    /**
     * NAプログラムデータを表示用に加工
     */
    async convertNaProgramData({ getters }, { listIndex }) {
      // 加工した表示用データ格納用
      // Naプログラムは小項目がないから、配列の中身は固定にする
      const convertData = [
        {
          itemName: "Na注入プログラム",
          data: []
        },
        {
          itemName: "Na注入プログラム",
          data: []
        }
      ];

      // 検索用日付リスト
      // const searchDateList = getters.getDateList;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      for (const treatData in copyTreatmentData) {
        const ordInfo = copyTreatmentData[treatData];
        const deviceSetInfo =
          ordInfo &&
          ordInfo.indDeviceSetInfo &&
          JSON.parse(ordInfo.indDeviceSetInfo);
        let naInfo;
        if (deviceSetInfo && deviceSetInfo.na) {
          naInfo = deviceSetInfo.na;
        } else {
          naInfo = defaultMstDeviceInfo.ord.na;
        }
        const mode =
          naInfo &&
          (() => {
            switch (parseInt(naInfo.dev.A[315])) {
              case 1:
                return "na-step";
              case 2:
                return "na-course";
              default:
                break;
            }
          })();

        if (ordInfo) {
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
          // 装置モードをマスタから取得
          // 治療方法マスタ
          let mstRecord = getters.getMstTreatmentData.find(mstData => {
            return mstData.treatmentCd === ordInfo.indTreatmentCd;
          });
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
          // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
          if (!mstRecord) {
            mstRecord = getters.getMstTreatmentDataIsDel.find(mstDataDel => {
              return mstDataDel.treatmentCd === ordInfo.indTreatmentCd;
            });
          }
          // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

          convertData[0].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            value1: mode ? "ON" : "OFF",
            type: "chart",
            data: null,
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            // isDisabled: mstRecord.deviceMode==9?true:false,
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            isNotClickable: ordInfo.readOnly
          });
          convertData[1].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            value1: mode ? "ON" : "OFF",
            // value1: mstRecord.deviceMode!=9?mode ? "ON" : "OFF":null,
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            type: "chart",
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // isDisabled: mstRecord.deviceMode==9?true:false,
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            data: mode ? naInfo : null,
            chartData: [
              {
                mode,
                courseValue: naInfo.dev.A[328],
                courseStartValue: naInfo.dev.A[329],
                courseEndValue: naInfo.dev.A[330],
                stepValues: [
                  naInfo.dev.A[316],
                  naInfo.dev.A[317],
                  naInfo.dev.A[318],
                  naInfo.dev.A[319],
                  naInfo.dev.A[320],
                  naInfo.dev.A[321],
                  naInfo.dev.A[322],
                  naInfo.dev.A[323],
                  naInfo.dev.A[324],
                  naInfo.dev.A[325]
                ]
              }
            ],
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isDisabled: !ordInfo.indCondInfo,
            // isNotClickable: ordInfo.readOnly
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            // isNotClickable: ordInfo.readOnly || !ordInfo.indCondInfo,
            isNotClickable: !ordInfo.indCondInfo,
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          });
        } else {
          convertData[0].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
          convertData[1].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
        }
      }
      // add FNSI-グラフ３軸表示対応「プログラムの表示」 周 start
      convertData.shift();
      // add FNSI-グラフ３軸表示対応「プログラムの表示」 周 end
      return convertData;
    },

    /**
     * 透析液濃度プログラムデータを表示用に加工
     */
    async convertDialysateProgramData({ getters }, { listIndex }) {
      // 加工した表示用データ格納用
      // Naプログラムは小項目がないから、配列の中身は固定にする
      const convertData = [
        {
          itemName: "透析液濃度プログラム",
          data: []
        },
        {
          itemName: "B液濃度プログラム",
          data: []
        },
        {
          itemName: "透析液濃度プログラム",
          data: []
        }
      ];

      // 検索用日付リスト
      // const searchDateList = getters.getDateList;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      for (const treatData in copyTreatmentData) {
        const ordInfo = copyTreatmentData[treatData];
        const deviceSetInfo =
          ordInfo &&
          ordInfo.indDeviceSetInfo &&
          JSON.parse(ordInfo.indDeviceSetInfo);
        let dialysateInfo;
        if (deviceSetInfo && deviceSetInfo.dc) {
          dialysateInfo = deviceSetInfo.dc;
        } else {
          dialysateInfo = defaultMstDeviceInfo.ord.dc;
        }
        const modeBFluid =
          dialysateInfo &&
          (() => {
            switch (parseInt(dialysateInfo.dev.A[340])) {
              case 2:
                // del FNSI-濃度プログラムの修正 楊 start
                // case 2:
                // del FNSI-濃度プログラムの修正 楊 end
                return "b-fluid-conc-step";
              // mod FNSI-濃度プログラムの修正 楊 start
              // case 3:
              case 3:
                // mod FNSI-濃度プログラムの修正 楊 end
                return "b-fluid-conc-course";
              default:
                break;
            }
          })();
        const modeDialysate =
          dialysateInfo &&
          (() => {
            switch (parseInt(dialysateInfo.dev.A[340])) {
              case 2:
                // del FNSI-濃度プログラムの修正 楊 start
                // case 2:
                // del FNSI-濃度プログラムの修正 楊 end
                return "dialysate-conc-step";
              // mod FNSI-濃度プログラムの修正 楊 start
              // case 3:
              case 3:
                // mod FNSI-濃度プログラムの修正 楊 end
                return "dialysate-conc-course";
              default:
                break;
            }
          })();

        if (ordInfo) {
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
          // 装置モードをマスタから取得
          // 治療方法マスタ
          let mstRecord = getters.getMstTreatmentData.find(mstData => {
            return mstData.treatmentCd === ordInfo.indTreatmentCd;
          });
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
          // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
          if (!mstRecord) {
            mstRecord = getters.getMstTreatmentDataIsDel.find(mstDataDel => {
              return mstDataDel.treatmentCd === ordInfo.indTreatmentCd;
            });
          }
          // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end


          convertData[0].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            value1: modeBFluid && modeDialysate ? "ON" : "OFF",
            // value1:mstRecord.deviceMode!=9? modeBFluid && modeDialysate ? "ON" : "OFF":null,
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            type: "chart",
            data: null,
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // isDisabled: mstRecord.deviceMode==9?true:false,
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            isNotClickable: ordInfo.readOnly
          });

          const stepValueA = [
            dialysateInfo.dev.B[10],
            dialysateInfo.dev.B[11],
            dialysateInfo.dev.B[12],
            dialysateInfo.dev.B[13],
            dialysateInfo.dev.B[14],
            dialysateInfo.dev.B[15],
            dialysateInfo.dev.B[16],
            dialysateInfo.dev.B[17],
            dialysateInfo.dev.B[18],
            dialysateInfo.dev.B[19]
          ];

          convertData[1].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            //mod 7926　【デグレ】特殊血液浄化でB液濃度プログラムが活性化　赵 start
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            value1: modeBFluid && modeDialysate ? "ON" : "OFF",
            // value1:mstRecord.deviceMode!=9? modeBFluid && modeDialysate ? "ON" : "OFF":null,
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            //mod 7926　【デグレ】特殊血液浄化でB液濃度プログラムが活性化　赵 end
            type: "chart",
            data: modeBFluid && modeDialysate ? dialysateInfo : null,
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // isDisabled: mstRecord.deviceMode==9?true:false,
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            chartData: [
              {
                mode: modeBFluid,
                courseValue: dialysateInfo.dev.A[364],
                courseStartValue: dialysateInfo.dev.A[365],
                courseEndValue: dialysateInfo.dev.A[366],
                stepValues: [
                  stepValueA,
                  [
                    dialysateInfo.dev.A[351],
                    dialysateInfo.dev.A[352],
                    dialysateInfo.dev.A[353],
                    dialysateInfo.dev.A[354],
                    dialysateInfo.dev.A[355],
                    dialysateInfo.dev.A[356],
                    dialysateInfo.dev.A[357],
                    dialysateInfo.dev.A[358],
                    dialysateInfo.dev.A[359],
                    dialysateInfo.dev.A[360]
                  ]
                ]
              }
            ],
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isDisabled: !ordInfo.indCondInfo,
            // isNotClickable: ordInfo.readOnly
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            // isNotClickable: ordInfo.readOnly || !ordInfo.indCondInfo,
            isNotClickable: !ordInfo.indCondInfo,
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          });

          const stepValueB = [
            dialysateInfo.dev.B[20],
            dialysateInfo.dev.B[21],
            dialysateInfo.dev.B[22],
            dialysateInfo.dev.B[23],
            dialysateInfo.dev.B[24],
            dialysateInfo.dev.B[25],
            dialysateInfo.dev.B[26],
            dialysateInfo.dev.B[27],
            dialysateInfo.dev.B[28],
            dialysateInfo.dev.B[29]
          ];
          // del FNSI-濃度プログラムの修正 楊 start
          // const chartType = dialysateInfo.dev.A[340] === "1";
          // del FNSI-濃度プログラムの修正 楊 end

          convertData[2].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            value1: modeBFluid && modeDialysate ? "ON" : "OFF",
            // value1:mstRecord.deviceMode!=9? modeBFluid && modeDialysate ? "ON" : "OFF":null,
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            type: "chart",
            data: modeBFluid && modeDialysate ? dialysateInfo : null,
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // isDisabled: mstRecord.deviceMode==9?true:false,
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            chartData: [
              {
                mode: modeDialysate,
                courseValue: dialysateInfo.dev.A[361],
                courseStartValue: dialysateInfo.dev.A[362],
                courseEndValue: dialysateInfo.dev.A[363],
                stepValues: [
                  // mod FNSI-濃度プログラムの修正 楊 start
                  // chartType ? stepValueA : stepValueB,
                  stepValueB,
                  // mod FNSI-濃度プログラムの修正 楊 end
                  [
                    dialysateInfo.dev.A[341],
                    dialysateInfo.dev.A[342],
                    dialysateInfo.dev.A[343],
                    dialysateInfo.dev.A[344],
                    dialysateInfo.dev.A[345],
                    dialysateInfo.dev.A[346],
                    dialysateInfo.dev.A[347],
                    dialysateInfo.dev.A[348],
                    dialysateInfo.dev.A[349],
                    dialysateInfo.dev.A[350]
                  ]
                ]
              }
            ],
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isDisabled: !ordInfo.indCondInfo,
            // isNotClickable: ordInfo.readOnly
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            // isNotClickable: ordInfo.readOnly || !ordInfo.indCondInfo,
            isNotClickable: !ordInfo.indCondInfo,
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          });
        } else {
          convertData[0].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
          convertData[1].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
          convertData[2].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
        }
      }
      // add FNSI-グラフ３軸表示対応「プログラムの表示」 周 start
      convertData.shift();
      // add FNSI-グラフ３軸表示対応「プログラムの表示」 周 end
      return convertData;
    },

    /**
     * QBQDプログラムデータを表示用に加工
     */
    async convertQbqdProgramData({ getters }, { listIndex }) {
      // 加工した表示用データ格納用
      // QbQdプログラムは小項目がないから、配列の中身は固定にする
      const convertData = [
        {
          itemName: "QB・QDプログラム",
          data: []
        }
      ];

      // 検索用日付リスト
      // const searchDateList = getters.getDateList;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      for (const treatData in copyTreatmentData) {
        const ordInfo = copyTreatmentData[treatData];
        const deviceSetInfo =
          ordInfo &&
          ordInfo.indDeviceSetInfo &&
          JSON.parse(ordInfo.indDeviceSetInfo);
        let qbqdInfo;
        if (deviceSetInfo && deviceSetInfo.qbqd) {
          qbqdInfo = deviceSetInfo.qbqd;
        } else {
          qbqdInfo = defaultMstDeviceInfo.ord.qbqd;
        }
        const condInfo =
          ordInfo && ordInfo.indCondInfo && JSON.parse(ordInfo.indCondInfo);
        const treatTime = condInfo && condInfo[1].value;

        // add bug #6038 修正 chen start
        let deviceMode;

        // 指示された治療方法に紐づく装置モードでdeviceMode変数を更新する
        const setDeviceMode = function(columnName){
          if (copyTreatmentData[treatData]) {
            // 治療方法項目が存在する場合、その値を格納
            const treatMethodCd =
              copyTreatmentData[treatData][columnName];

            if (undefined != treatMethodCd && null != treatMethodCd) {

              // 装置モードをマスタから取得
              // 治療方法マスタ
              let mstRecord = getters.getMstTreatmentData.find(mstData => {
                return mstData.treatmentCd === treatMethodCd;
              });
              if (mstRecord) {
                deviceMode = mstRecord.deviceMode;
              }

            }

          }
        }
        // indTreatmentCd に紐づく装置モードでdeviceMode変数を更新する
        setDeviceMode("indTreatmentCd");
        // rstTreatmentCd に紐づく装置モードでdeviceMode変数を更新する
        setDeviceMode("rstTreatmentCd");
        // add bug #6038 修正 chen end

        if (ordInfo) {
          /**
           * @description グラフデータ設定
           * @param {Array} chartData 表示グラフ
           * @param {Array} flowArray 各流量
           */
          const setChartData = (
            chartData,
            flowArray,
            changeoverTime,
            xAxisMax
          ) => {
            // グラフx軸設定
            if (!treatTime) {
              // 「透析時間："00:00"」x軸を"04:00"まで表示
              for (let i = 0; i < 5; i++) {
                // ※5固定値："04:00"までグラフ空で表示
                chartData.push(null);
              }
            } else {
              // x軸
              let xAxis = 0;
              // 次のx軸：※階段グラフ用
              let stepsXAxis = 0;

              let isLastFlow = false;

              // グラフ値設定
              flowArray.forEach((item, index) => {
                // y軸：流量値
                let setData = parseInt(item);

                // ステップ数：ステップ数は1から連番、配列要素数は0から連番
                const stepNumber = qbqdInfo.dev.A[429] - 1;

                // グラフ表示用y軸値設定：ステップ数以降の流量値をステップ数の流量値に設定
                if (index >= stepNumber) {
                  // ステップ数以降の流量値
                  setData = parseInt(flowArray[stepNumber]);
                }

                // x軸値設定：切替時間を設定※経過を表示するため次のx軸を設定
                xAxis = stepsXAxis;

                // 次のx軸(階段グラフ用)を設定：切替時間値を設定
                if (index < changeoverTime.length) {
                  // 配列要素数がある場合
                  const changeoverTimeConv = changeoverTime[index] / 60;
                  // 次のx軸：※階段グラフ用を設定
                  stepsXAxis += changeoverTimeConv;
                } else {
                  // 配列要素数がない場合
                  const maxDialysisDisplayTime = 10;
                  // x軸を最大10時間になるよう値を設定
                  if (stepsXAxis <= maxDialysisDisplayTime) {
                    // x軸値が最大10時間を超えていない場合
                    stepsXAxis = maxDialysisDisplayTime;
                  }
                  isLastFlow = true;
                }

                // 階段グラフ表示用データ
                const stepsChartData = flowArray.map(() => [
                  stepsXAxis,
                  setData
                ]);

                chartData.push([xAxis, setData], stepsChartData[index]);

                const maxDialysisTime = 10;
                if (xAxisMax > maxDialysisTime && isLastFlow) {
                  // 10時間以降：＋1ずつ設定
                  for (let i = 10; i < xAxisMax; i++) {
                    chartData.push([i + 1, setData]);
                  }
                  isLastFlow = false;
                }
              });
            }
          };

          const qdSwitch = parseInt(qbqdInfo.dev.A[431]);
          const qbSwitch = parseInt(qbqdInfo.dev.A[430]);
          const changeoverTime = [
            qbqdInfo.dev.A[420],
            qbqdInfo.dev.A[421],
            qbqdInfo.dev.A[422],
            qbqdInfo.dev.A[423],
            qbqdInfo.dev.A[424],
            qbqdInfo.dev.A[425],
            qbqdInfo.dev.A[426],
            qbqdInfo.dev.A[427],
            qbqdInfo.dev.A[428]
          ];
          const dialysisfluidFlow = [
            qbqdInfo.dev.A[410],
            qbqdInfo.dev.A[411],
            qbqdInfo.dev.A[412],
            qbqdInfo.dev.A[413],
            qbqdInfo.dev.A[414],
            qbqdInfo.dev.A[415],
            qbqdInfo.dev.A[416],
            qbqdInfo.dev.A[417],
            qbqdInfo.dev.A[418],
            qbqdInfo.dev.A[419]
          ];
          const bloodFlow = [
            qbqdInfo.dev.A[400],
            qbqdInfo.dev.A[401],
            qbqdInfo.dev.A[402],
            qbqdInfo.dev.A[403],
            qbqdInfo.dev.A[404],
            qbqdInfo.dev.A[405],
            qbqdInfo.dev.A[406],
            qbqdInfo.dev.A[407],
            qbqdInfo.dev.A[408],
            qbqdInfo.dev.A[409]
          ];
          const qbStepValues = [];
          const qdStepValues = [];
          const xAxisMax = treatTime ? treatTime / 60 : 0;
          const chartValues = [];

          if (parseInt(qdSwitch)) {
            setChartData(
              qdStepValues,
              dialysisfluidFlow,
              changeoverTime,
              xAxisMax
            );
            chartValues.push(qdStepValues);
          } else {
            // グラフの色を配列要素数で指定しているため、データがない場合でもnullを設定する
            chartValues.push(null);
          }

          if (parseInt(qbSwitch)) {
            setChartData(qbStepValues, bloodFlow, changeoverTime, xAxisMax);
            chartValues.push(qbStepValues);
          } else {
            // グラフの色を配列要素数で指定しているため、データがない場合でもnullを設定する
            chartValues.push(null);
          }

          // mod bug #6038 修正 chen start
          convertData[0].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            value1: deviceMode != 6 ? qdSwitch || qbSwitch ? "ON" : "OFF" : null,
            type: "chart",
            data: deviceMode != 6 ? qdSwitch || qbSwitch ? qbqdInfo : null : null,
            // value1: deviceMode != 6&&deviceMode != 9 ? qdSwitch || qbSwitch ? "ON" : "OFF" : null,
            // type: "chart",
            // data: deviceMode != 6&&deviceMode != 9 ? qdSwitch || qbSwitch ? qbqdInfo : null : null,
            // mod #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            chartData: [
              {
                mode: qdSwitch || qbSwitch ? "qbqd-step" : null,
                stepValues: chartValues,
                xAxisMax
              }
            ],
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // isDisabled: deviceMode == 6,
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            // isDisabled: deviceMode == 6||deviceMode==9,
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isDisabled: !ordInfo.indCondInfo,
            // isNotClickable: ordInfo.readOnly
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --start */
            // isNotClickable: ordInfo.readOnly || !ordInfo.indCondInfo,
            isNotClickable: !ordInfo.indCondInfo,
            /* upd by chamaojia 2026-03-12 [12462] 患者情報共有->患者経過総合ビューア --end */
            // add #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          });
          // mod bug #6038 修正 chen end
        } else {
          convertData[0].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
        }
      }

      return convertData;
    },

    /**
     * IHdfプログラムデータを表示用に加工
     */
    async convertIHdfProgramData({ getters }, { listIndex }) {
      // 加工した表示用データ格納用
      // IHdfプログラムは小項目がないから、配列の中身は固定にする
      const convertData = [
        {
          itemName: "I-HDF設定",
          data: []
        }
      ];

      // 検索用日付リスト
      // const searchDateList = getters.getDateList;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      for (const treatData in copyTreatmentData) {
        const ordInfo = copyTreatmentData[treatData];
        const deviceSetInfo =
          ordInfo &&
          ordInfo.indDeviceSetInfo &&
          JSON.parse(ordInfo.indDeviceSetInfo);

        let ihdfInfo;
        if (deviceSetInfo && deviceSetInfo.ihdf) {
          ihdfInfo = deviceSetInfo.ihdf;
        } else {
          ihdfInfo = defaultMstDeviceInfo.ord.ihdf;
        }

        if (ordInfo) {
          let supplyLiquid = [
            ihdfInfo.dev.A[435],
            ihdfInfo.dev.A[436],
            ihdfInfo.dev.A[437],
            ihdfInfo.dev.A[438],
            ihdfInfo.dev.A[439],
            ihdfInfo.dev.A[440],
            ihdfInfo.dev.A[441],
            ihdfInfo.dev.A[442],
            ihdfInfo.dev.A[443],
            ihdfInfo.dev.A[444],
            ihdfInfo.dev.A[445],
            ihdfInfo.dev.A[446],
            ihdfInfo.dev.A[447],
            ihdfInfo.dev.A[448],
            ihdfInfo.dev.A[449],
            ihdfInfo.dev.A[450]
          ];
          let recoveredAmount = [
            ihdfInfo.dev.A[451] * -1,
            ihdfInfo.dev.A[452] * -1,
            ihdfInfo.dev.A[453] * -1,
            ihdfInfo.dev.A[454] * -1,
            ihdfInfo.dev.A[455] * -1,
            ihdfInfo.dev.A[456] * -1,
            ihdfInfo.dev.A[457] * -1,
            ihdfInfo.dev.A[458] * -1,
            ihdfInfo.dev.A[459] * -1,
            ihdfInfo.dev.A[460] * -1,
            ihdfInfo.dev.A[461] * -1,
            ihdfInfo.dev.A[462] * -1,
            ihdfInfo.dev.A[463] * -1,
            ihdfInfo.dev.A[464] * -1,
            ihdfInfo.dev.A[465] * -1,
            ihdfInfo.dev.A[466] * -1
          ];

          const stepNumber = ihdfInfo.dev.A[433];
          const isUseProgram = Number(ihdfInfo.dev.A[432]);

          // 除水プログラムを使用しない場合、「I-HDF 補液量設定」の値を与える
          if (!isUseProgram) {
            supplyLiquid = supplyLiquid.map(() => ihdfInfo.dev.A[200]);
            recoveredAmount = recoveredAmount.map(
              () => ihdfInfo.dev.A[200] * -1
            );
          }

          supplyLiquid = supplyLiquid.map((item, index) =>
            index < stepNumber ? item : null
          );

          recoveredAmount = recoveredAmount.map((item, index) =>
            index < stepNumber ? item : null
          );

          let deviceMode;

          // 指示された治療方法に紐づく装置モードでdeviceMode変数を更新する
          const setDeviceMode = function(columnName){

            // 治療方法項目が存在する場合、その値を格納
            const treatMethodCd =
              copyTreatmentData[treatData][columnName];

            if (undefined != treatMethodCd && null != treatMethodCd) {

              // 装置モードをマスタから取得
              // 治療方法マスタ
              let mstRecord = getters.getMstTreatmentData.find(mstData => {
                return mstData.treatmentCd === treatMethodCd;
              });
              if (mstRecord) {
                deviceMode = mstRecord.deviceMode;
              }

            }

          }
          // indTreatmentCd に紐づく装置モードでdeviceMode変数を更新する
          setDeviceMode("indTreatmentCd");
          // rstTreatmentCd に紐づく装置モードでdeviceMode変数を更新する
          setDeviceMode("rstTreatmentCd");

          // 装置モード I-HDF = 10
          const iHdfMode = 10;

          convertData[0].data.push({
            ordNo: ordInfo.ordNo,
            treatDate: treatData,
            /* add by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --start */
            facilityCd: ordInfo.facilityCd,
            /* add by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --end */
            value1: deviceMode === iHdfMode ? "ON" : null,
            type: "chart",
            data: deviceMode === iHdfMode ? ihdfInfo : null,
            chartData: [
              {
                mode: "ihdf-step",
                stepValues: [supplyLiquid, recoveredAmount],
                title: isUseProgram ? "I-HDFプログラム" : "I-HDF"
              }
            ],
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            // isDisabled: deviceMode != iHdfMode,
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            isDisabled: !ordInfo.indCondInfo,
            // isNotClickable: ordInfo.readOnly
            /* upd by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --start */
            // isNotClickable: ordInfo.readOnly || !ordInfo.indCondInfo,
            isNotClickable: !ordInfo.indCondInfo,
            /* upd by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --end */
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          });
        } else {
          convertData[0].data.push({
            value1: null,
            value2: null,
            ordNo: null,
            data: [],
            type: "chart",
            treatDate: treatData,
            isNotClickable: null
          });
        }
      }

      return convertData;
    },

    /**
     * 透析量プログラムを表示用に加工
     */
    // mod FNSI-検査日設定変更 楊 start
    // convertDiaysisProgram({ getters }, { listIndex }) {
    async convertDiaysisProgram({ getters }, { listIndex }) {
      // mod FNSI-検査日設定変更 楊 end
      // 加工した表示用データ格納用
      const convertData = [
        {
          itemName: "透析量プログラム",
          itemNo: 1,
          data: []
        },
        {
          itemName: "\t検査日",
          itemNo: 2,
          data: []
        },
        {
          itemName: "\t目標Kt/V",
          itemNo: 3,
          data: []
        }
      ];

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      for (let i = 0; i < convertData.length; i++) {
        for (const treatDate in copyTreatmentData) {
          // データセル情報のテンプレートを格納
          const temp = deepCopy(layoutDispData_data);
          // 治療日の格納
          temp.treatDate = treatDate;
          // タイプをLFに設定
          temp.type = "lf";
          // 治療情報
          const ordInfo = copyTreatmentData[treatDate];
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
          let deviceMode;
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
          if (ordInfo) {
            //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
            // 装置モードをマスタから取得
            // 治療方法マスタ
            let mstRecord = getters.getMstTreatmentData.find(mstData => {
              return mstData.treatmentCd === ordInfo.indTreatmentCd;
            });
            // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
            if (!mstRecord) {
              mstRecord = getters.getMstTreatmentDataIsDel.find(mstDataDel => {
                return mstDataDel.treatmentCd === ordInfo.indTreatmentCd;
              });
            }
            // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            // deviceMode = mstRecord.deviceMode
            if (mstRecord) {
              deviceMode = mstRecord.deviceMode
            }
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
            // temp.isDisabled = mstRecord.deviceMode==9?true:false,
            // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
              //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
              // 治療情報が存在すればオーダー番号を格納
            temp.ordNo = ordInfo.ordNo;
            /* add by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --start */
            temp.facilityCd = ordInfo.facilityCd;
            /* add by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --end */
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
            temp.isDisabled = !ordInfo.indCondInfo;
            // temp.isNotClickable = ordInfo.readOnly;
            /* upd by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --start */
            // temp.isNotClickable = ordInfo.readOnly || !ordInfo.indCondInfo;
            temp.isNotClickable = !ordInfo.indCondInfo;
            /* upd by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --end */
            // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          }
          // 装置設定情報
          const deviceSetInfo =
            ordInfo &&
            ordInfo.indDeviceSetInfo &&
            JSON.parse(ordInfo.indDeviceSetInfo);

          let diaInfo;
          if (deviceSetInfo && deviceSetInfo.dia) {
            diaInfo = deviceSetInfo.dia;
          } else {
            diaInfo = defaultMstDeviceInfo.ord.dia;
          }

          let dia;
          if (diaInfo) {
            dia = diaInfo.dev.A;
            switch (i) {
              // 装置プログラム切り替え
              case 0:
                if ("1" === dia["282"]) {
                  temp.value1 = "ON";
                } else if ("0" === dia["282"]) {
                  temp.value1 = "OFF";
                }
                //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
                temp.value1 = deviceMode!=9?temp.value1:null
                //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
                break;

              // 検査日
              case 1:
                // TODO: アドレス値が割り振られたおらず、値がまだないので今日の日付けを格納
                // 装置プログラム切替がONの場合のみ値格納
                if ("1" === dia["282"]) {
                  // mod FNSI-検査日設定変更 楊 start
                  // temp.value1 = moment(treatDate, "YYYYMMDD").format(
                  //   "YYYY/MM/DD"
                  // );

                  let ordNo = dia["ord_no"];
                  if (ordNo === undefined || ordNo === "") {
                    // 値がないので今日の日付けを格納
                    temp.value1 = moment(treatDate, "YYYYMMDD").format(
                      "YYYY/MM/DD"
                    );
                  } else {
                    // ordNoより、検査日を格納
                    const res = await ApiHelper.get(
                      `/mainData/getOrdMainByOrdNo/${dia["ord_no"]}`
                    ).catch(err => {
                      throw err;
                    })
                    temp.value1 = res ? moment(res.data.treatDate, "YYYYMMDD").format(
                      "YYYY/MM/DD"
                    ) : moment(treatDate, "YYYYMMDD").format(
                      "YYYY/MM/DD"
                    );
                  }
                  // mod FNSI-検査日設定変更 楊 end
                }
                break;

              // 目標Kt/V
              case 2:
                // 装置プログラム切替がONの場合のみ値格納
                if ("1" === dia["282"]) {
                  // 値がある場合、小数点第2位まで表示する
                  // mod #IES_6501 dou start
                  // temp.value1 = !dia["288"] ? null : dia["288"].toFixed(2);
                  temp.value1 = !dia["288"] ? null : toFixed(dia["288"], 2);
                  // mod #IES_6501 dou end
                }
                break;

              default:
                break;
            }
          }
          convertData[i].data.push(temp);
        }
      }
      return convertData;
    },

    /**
     * BV-UFCを表示用に加工
     */
    convertBvUfcData({ getters }, { listIndex }) {
      const convertData = [
        {
          itemName: "BV-UFC",
          itemNo: 1,
          data: []
        }
      ];

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }

      for (const treatDate in copyTreatmentData) {
        // データセル情報のテンプレートを格納
        const temp = deepCopy(layoutDispData_data);
        // 治療日の格納
        temp.treatDate = treatDate;
        // タイプの格納
        temp.type = "chart";
        // 治療情報
        const ordInfo = copyTreatmentData[treatDate];
        if (ordInfo) {
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
          // 装置モードをマスタから取得
          // 治療方法マスタ
          let mstRecord = getters.getMstTreatmentData.find(mstData => {
            return mstData.treatmentCd === ordInfo.indTreatmentCd;
          });

          // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
          if (!mstRecord) {
            mstRecord = getters.getMstTreatmentDataIsDel.find(mstDataDel => {
              return mstDataDel.treatmentCd === ordInfo.indTreatmentCd;
            });
          }
          // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
          // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc start
          // temp.isDisabled = mstRecord.deviceMode==9?true:false,
          // del #9340_#10246 ちょうせつ治療方法セットマスタ_装置設定 20240611 ztc end
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
          // 治療情報が存在すればオーダー番号を格納
          temp.ordNo = ordInfo.ordNo;
          /* add by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --start */
          temp.facilityCd = ordInfo.facilityCd;
          /* add by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --end */
          // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          temp.isDisabled = !ordInfo.indCondInfo;
          // temp.isNotClickable = ordInfo.readOnly;
          /* upd by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --start */
          // temp.isNotClickable = ordInfo.readOnly || !ordInfo.indCondInfo;
          temp.isNotClickable = !ordInfo.indCondInfo;
          /* upd by chamaojia 2026-03-18 [12462] 患者情報共有->患者経過総合ビューア --end */
          // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          // 装置設定情報
          const deviceSetInfo =
            ordInfo &&
            ordInfo.indDeviceSetInfo &&
            JSON.parse(ordInfo.indDeviceSetInfo);

          let bvUfcInfo;
          if (deviceSetInfo && deviceSetInfo.bvufc) {
            bvUfcInfo = deviceSetInfo.bvufc;
          } else {
            bvUfcInfo = defaultMstDeviceInfo.ord.bvufc;
          }

          if (bvUfcInfo) {
            const bvUfc = bvUfcInfo.dev.A;
            if (bvUfc) {
              temp.value1 = "1" === bvUfc["196"] ? "ON" : "OFF";
            }
          }
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
          // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
          // temp.value1 = mstRecord?.deviceMode != 9 ? temp.value1 : null
          temp.value1 = mstRecord && mstRecord.deviceMode && mstRecord.deviceMode != 9 ? temp.value1 : null
          // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
          //add 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
        }
        convertData[0].data.push(temp);
      }
      return convertData;
    },

    /**
     * バイタルを表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {string} facilityCd 施設コード
     * @param {number} patId 患者ID
     * @param {string} weekPattern 取得曜日(※全曜日の場合、[{'text': '全','done': true,'value': 0}]) ※要検討
     */
    // async convertVitalInfo(
    //   { getters },
    //   { listIndex, layout, facilityCd, patId, weekPattern }
    // ) {
    async convertVitalInfo({ state, getters, commit }, { listIndex, layout, facilityCd, patId, weekPattern}) {
      if (!listIndex) {
        listIndex = 0;
      }
      const convertData = [
        {
          itemName: layout.categoryName,
          itemNameSub: [],
          data: []
        }
      ];
      const series = [];
      const yAxis = [];
      // del FNSI-グラフ３軸表示対応「230」「IES434」バイタル・モニタグラフ分 周 start
      // layout.categoryItem.forEach((category, index) => {
      //   yAxis.push({
      //     labels: { enabled: false },
      //     title: { text: category.subCategoryName },
      //     offset: 0
      //   });
      //   category.subCategoryItem.forEach(subCategory => {
      //     series.push({
      //       yAxis: index,
      //       yAxisNo: category.subCategoryNo,
      //       yAxisName: category.subCategoryName,
      //       name: subCategory.itemName,
      //       no: subCategory.itemNo,
      //       data: []
      //     });
      //   });
      // });
      // del FNSI-グラフ３軸表示対応「230」「IES434」バイタル・モニタグラフ分 周 end

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex] || {};
      if (!copyTreatmentData) {
        return [];
      }

      // グラフ用データに加工
      const createChartData = vitalInfo => {
        const tempArr = {};
        /* modify by chamaojia 2023-10-12 [9713] 処理回数の削減、コードの最適化  --start */
          // 表示したい項目に対応するNOを検索する
        // mod #10077 by zhangruixue 2023-12-8  start
        // const itemKeyArr = series.map(record => record.type == 2 && record.vitalMonitorClass == 2 ? record.name : record.no);
        const itemKeyArr = series.map(record => record.no);
        // mod #10077 by zhangruixue 2023-12-8  end
        vitalInfo.forEach(rec => {
          // mod #12462 患者情報共有->患者経過総合ビューア fang start
          let isHandle = true
          if(facilityCd != rec.facilityCd) {
            const compareNo = itemNo.replace('Z', '')
            if(Number(compareNo) > 10000) {
              isHandle = false
            }
          }
          if(isHandle) {
            const pstNo = isNaN(itemNo) ? itemNo : parseInt(itemNo);
            // 表示された項目のみを処理すると判断する
            if (itemKeyArr.indexOf(pstNo) != -1) {
              if (!tempArr[pstNo]) {
                // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
                // tempArr[pstNo] = [...[], [rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo])]];
                //mod #10077 by zhangruixue 2024-2-20  start
                if(isStringNumeric(convertToHalfWidth(rec.monitorData[itemNo]))){
                  tempArr[pstNo] = [...[], [rec.occurDate, Number(convertToHalfWidth(rec.monitorData[itemNo])), rec.dataType]];
                }
                // tempArr[pstNo] = [...[], [rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo]), rec.dataType]];
                //mod #10077 by zhangruixue 2024-2-20  end
              } else {
                  // tempArr[pstNo] = [...tempArr[pstNo], [rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo])]];
                  // 配列追加値の性能が悪く、pushに置き換える
                  // tempArr[pstNo] = [...tempArr[pstNo], [rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo]), rec.dataType]];
                  //mod #10077 by zhangruixue 2024-2-20  start
                  if(isStringNumeric(convertToHalfWidth(rec.monitorData[itemNo]))){
                    tempArr[pstNo].push([rec.occurDate, Number(convertToHalfWidth(rec.monitorData[itemNo])), rec.dataType])
                  }
                  //mod #10077 by zhangruixue 2024-2-20  end
                  // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
              }
            }
          }
          // mod #12462 患者情報共有->患者経過総合ビューア fang end
        });

        const chartData = series.map(record => {
          // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
          // const pstNo = record.type === 1 ? record.no : record.name;
          // mod #10077 by zhangruixue 2023-12-8  start
          // const pstNo =  record.type == 2&&record.vitalMonitorClass==2 ? record.name : record.no;
          const pstNo =  record.no;
          // mod #10077 by zhangruixue 2023-12-8  end
          // record.data = tempArr[pstNo] ? tempArr[pstNo] : [];
          record.data = tempArr[pstNo]? JSON.parse(JSON.stringify(tempArr[pstNo])).filter((item)=>{
            if (record.vitalMonitorClass==2) {
              return item[2]==1;
            }else{
              return item[2]!=1;
            }
          }) : [];
          // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
          return record;
        })

        return chartData;
      };

      let chartData = [];
      const lastIndex = Object.keys(copyTreatmentData).length - 1;
      const period = getters.getSelectedPeriod;
      const isLongPeriod = ["4", "5", "6", "7"].includes(period);
      let startDate = moment(
        Object.keys(copyTreatmentData)[0] || getters.getDateList[0],
        "YYYYMMDD"
      ).startOf("day");
      let endDate = moment(
        Object.keys(copyTreatmentData)[lastIndex] ||
        getters.getDateList[getters.getDateList.length - 1],
        "YYYYMMDD"
      ).endOf("day");

      // 12週以降の場合、APIにリクエストをして期間内のデータを取得
      if (isLongPeriod) {
        // 選択された期間によって開始日と終了日を調整する
        switch (period) {
          case "4":
            // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 start
            // endDate = endDate.add(6, "days").endOf("day");
            endDate = endDate.add(1, "week").startOf("day").subtract(1, "days");
            // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 end
            break;
          case "5":
          case "6":
            startDate = startDate.startOf("month");
            endDate = endDate.endOf("month");
            break;
          case "7":
            startDate = startDate.startOf("month");
            endDate = endDate.add(11, "months").endOf("month");
            break;
        }

        // RestAPI実行
        const response = state.treatDateList;
        const vitalInfo = [];
        // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
        // for (const ordInfo of response.data) {
        for (const ordInfo of response.data || []) {
          // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          let resMniMonitors = getters.getResMniMonitors;
          let resMniMonitorTmp = resMniMonitors.filter(y => y.ordNo == ordInfo.ordNo);
          let resMniMonitor = null;
          if (resMniMonitorTmp && resMniMonitorTmp.length > 0) {
            resMniMonitor = resMniMonitorTmp[0].resMniMonitor;
          } else {
            resMniMonitor = await ApiHelper.get(
              `/status_list/mni_monitor/${ordInfo.ordNo}`
            ).catch(err => {
              throw err;
            })
            resMniMonitors.push({
              ordNo: ordInfo.ordNo,
              resMniMonitor: resMniMonitor
            });
            commit("setResMniMonitors", resMniMonitors);
          }
          resMniMonitor.data.forEach(monitorItem => {
            // 削除データは表示しない
            if (monitorItem.is_del === "1") {
              return;
            }
            vitalInfo.push({
              // add #12462 患者情報共有->患者経過総合ビューア fang start
              facilityCd: monitorItem.facility_cd,
              // add #12462 患者情報共有->患者経過総合ビューア fang end
              monitorData: monitorItem.monitor_data && JSON.parse(monitorItem.monitor_data),
              occurDate: monitorItem.occur_date,
              // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
              dataType: monitorItem.data_type,
              // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
            })
          });
        }
        vitalInfo.sort(function(a, b){
          return (a.occurDate > b.occurDate ? 1 : -1);
        });
        // add FNSI-グラフ３軸表示対応「230」「IES434」バイタル・モニタグラフ分 周 start
        layout.categoryItem.forEach((category, index) => {
          const filterArr = [];
          const vitalResultArr = [];
          // 上限値「マスタ情報から取得」
          // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 start
          // let max = category.max ? category.max : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // let max = category.graphMax ? Number(category.graphMax) : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 end
          // 下限値「マスタ情報から取得」
          // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 start
          // let min = category.min ? category.min : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // let min = category.graphMin ? Number(category.graphMin) : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 end

          // グループ条件「マスタ情報から取得」
          filterArr.push(...category.subCategoryItem.map(p => p.itemNo));
          // 実績データ「実績情報から取得」
          for (const vitalItem of vitalInfo) {
            for (const key of filterArr) {
              if (vitalItem.monitorData && vitalItem.monitorData.hasOwnProperty(key)) {
                // バイタル・モニタ情報存在場合
                vitalResultArr.push(vitalItem.monitorData[key]);
              }
            }
          }

          // add 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          const {max, min} = getThreshold(category.graphMax, category.graphMin, vitalResultArr, "line");
          // add 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // add FNSI-グラフの縦軸表示を修正 周 start
          // 実績情報をクリア
          vitalResultArr.splice(0, vitalResultArr.length);
          // add FNSI-グラフの縦軸表示を修正 周 end

          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // // 上限値「実績情報から更新」
          // max = vitalResultArr.length > 0 ? Math.max(...vitalResultArr, max) : max;
          // // 下限値「実績情報から更新」
          // min = vitalResultArr.length > 0 ? Math.min(...vitalResultArr, min) : min;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end

          // mod FNSI-グラフの縦軸表示を修正 周 start
          // yAxis.push({
          //   labels: { enabled: false },
          //   title: { text: category.subCategoryName },
          //   max: max,
          //   min: min,
          //   tickAmount: 5,
          //   offset: 0
          // });
          yAxis.push({
            labels: { enabled: false },
            title: { text: category.subCategoryName },
            tickPositioner: function() {
              const incrementCount = 4;
              const dataMax = max;
              const dataMin = min;
              const mstFixedCount = Math.max(
                (dataMin != Math.floor(dataMin)) ? (dataMin.toString()).split('.')[1].length : 0,
                (dataMax != Math.floor(dataMax)) ? (dataMax.toString()).split('.')[1].length : 0
              );
              const increment = max - min > 0 ? (max - min) / incrementCount : 0;
              const incrementFixedCount = (increment !== Math.floor(increment)) ? (increment.toString()).split('.')[1].length : 0;
              const incrementFixedMax = 3;

              const fixed = Math.max(Math.min(incrementFixedCount, incrementFixedMax), mstFixedCount);
              const positions = [];
              if (increment > 0) {
                positions.push(Number(dataMin));
                for (let index = 1; index < incrementCount; index++) {
                  const valFull = dataMin + index * increment;
                  const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
                  positions.push(valFloor);
                }
                positions.push(Number(dataMax));
              } else {
                for (let index = 0; index < incrementCount + 1; index++) {
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                  // positions.push(Number(dataMin + index));
                  const p = dataMin + index;
                  positions.push(parseFloat(p.toFixed(3)));
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
                }
              }
              return positions;
            },
            offset: 0
          });
          // mod FNSI-グラフの縦軸表示を修正 周 end
          category.subCategoryItem.forEach(subCategory => {
            series.push({
              yAxis: index,
              // add FNSI-グラフの縦軸表示を修正 周 start
              yAxisMax: Number(max) - Number(min) > 0 ? Number(max) : Number(min) + 4,
              yAxisMin: min,
              // add FNSI-グラフの縦軸表示を修正 周 end
              yAxisNo: category.subCategoryNo,
              yAxisName: category.subCategoryName,
              name: subCategory.itemName,
              no: subCategory.itemNo,
              // add FNSI-グラフのシリーズ表示を修正_バイタル・モニタグラフ機能分 周 start
              color: subCategory.itemColor,
              marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
              // add FNSI-グラフのシリーズ表示を修正_バイタル・モニタグラフ機能分 周 end
              data: [],
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 start
              vitalMonitorClass: subCategory.vitalMonitorClass,
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 end
              type: subCategory.tableType
            });
          });
        });
        // add FNSI-グラフ３軸表示対応「230」「IES434」バイタル・モニタグラフ分 周 end
        chartData  = createChartData(vitalInfo);
      } else {
        endDate = endDate.add(1, "day").startOf("day");
        const treatmentData = getters.getTreatmentData;
        let vitalInfo = [];
        for (let i = 0; i < treatmentData.length; i++) {
          for (const treatDate in treatmentData[i]) {
            const ordInfo = treatmentData[i][treatDate];
            if (!ordInfo) {
              continue;
            }
            let resMniMonitors = getters.getResMniMonitors;
            let resMniMonitorTmp = resMniMonitors.filter(y => y.ordNo == ordInfo.ordNo);
            let resMniMonitor = null;
            if (resMniMonitorTmp && resMniMonitorTmp.length > 0) {
              resMniMonitor = resMniMonitorTmp[0].resMniMonitor;
            } else {
              resMniMonitor = await ApiHelper.get(
                `/status_list/mni_monitor/${ordInfo.ordNo}`
              ).catch(err => {
                throw err;
              })
              resMniMonitors.push({
                ordNo: ordInfo.ordNo,
                resMniMonitor: resMniMonitor
              });
              commit("setResMniMonitors", resMniMonitors);
            }
            // オーダ番号に該当するモニタ情報を取得
            resMniMonitor.data.forEach(monitorItem => {
              // 削除データは表示しない
              if (monitorItem.is_del === "1") {
                return;
              }
              vitalInfo.push({
                // add #12462 患者情報共有->患者経過総合ビューア fang start
                facilityCd: monitorItem.facility_cd,
                // add #12462 患者情報共有->患者経過総合ビューア fang end
                monitorData: monitorItem.monitor_data && JSON.parse(monitorItem.monitor_data),
                occurDate: monitorItem.occur_date,
                // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
                dataType: monitorItem.data_type
                // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
              })
            });
          }
        }
        vitalInfo.sort(function(a, b){
          return (a.occurDate > b.occurDate ? 1 : -1);
        });
        // add FNSI-グラフ３軸表示対応「230」「IES434」バイタル・モニタグラフ分 周 start
        layout.categoryItem.forEach((category, index) => {
          const filterArr = [];
          const vitalResultArr = [];
          // 上限値「マスタ情報から取得」
          // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 start
          // let max = category.max ? category.max : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // let max = category.graphMax ? Number(category.graphMax) : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 end
          // 下限値「マスタ情報から取得」
          // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 start
          // let min = category.min ? category.min : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // let min = category.graphMin ? Number(category.graphMin) : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 end

          // グループ条件「マスタ情報から取得」
          filterArr.push(...category.subCategoryItem.map(p => p.itemNo));
          // 実績データ「実績情報から取得」
          for (const vitalItem of vitalInfo) {
            for (const key of filterArr) {
              if (vitalItem.monitorData && vitalItem.monitorData.hasOwnProperty(key)) {
                // バイタル・モニタ情報存在場合
                vitalResultArr.push(vitalItem.monitorData[key]);
              }
            }
          }

          // add 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          const {max, min} = getThreshold(category.graphMax, category.graphMin, vitalResultArr, "line");
          // add 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // add FNSI-グラフの縦軸表示を修正 周 start
          // 実績情報をクリア
          vitalResultArr.splice(0, vitalResultArr.length);
          // add FNSI-グラフの縦軸表示を修正 周 end

          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // // 上限値「実績情報から更新」
          // max = vitalResultArr.length > 0 ? Math.max(...vitalResultArr, max) : max;
          // // 下限値「実績情報から更新」
          // min = vitalResultArr.length > 0 ? Math.min(...vitalResultArr, min) : min;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end

          // mod FNSI-グラフの縦軸表示を修正 周 start
          // yAxis.push({
          //   labels: { enabled: false },
          //   title: { text: category.subCategoryName },
          //   max: max,
          //   min: min,
          //   tickAmount: 5,
          //   offset: 0
          // });
          yAxis.push({
            labels: { enabled: false },
            title: { text: category.subCategoryName },
            tickPositioner: function() {
              const incrementCount = 4;
              const dataMax = max;
              const dataMin = min;
              const mstFixedCount = Math.max(
                (dataMin != Math.floor(dataMin)) ? (dataMin.toString()).split('.')[1].length : 0,
                (dataMax != Math.floor(dataMax)) ? (dataMax.toString()).split('.')[1].length : 0
              );
              const increment = max - min > 0 ? (max - min) / incrementCount : 0;
              const incrementFixedCount = (increment !== Math.floor(increment)) ? (increment.toString()).split('.')[1].length : 0;
              const incrementFixedMax = 3;

              const fixed = Math.max(Math.min(incrementFixedCount, incrementFixedMax), mstFixedCount);
              const positions = [];
              if (increment > 0) {
                positions.push(Number(dataMin));
                for (let index = 1; index < incrementCount; index++) {
                  const valFull = dataMin + index * increment;
                  const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
                  positions.push(valFloor);
                }
                positions.push(Number(dataMax));
              } else {
                for (let index = 0; index < incrementCount + 1; index++) {
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                  // positions.push(Number(dataMin + index));
                  const p = dataMin + index;
                  positions.push(parseFloat(p.toFixed(3)));
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
                }
              }
              return positions;
            },
            offset: 0
          });
          // mod FNSI-グラフの縦軸表示を修正 周 end
          category.subCategoryItem.forEach(subCategory => {
            series.push({
              yAxis: index,
              // add FNSI-グラフの縦軸表示を修正 周 start
              yAxisMax: Number(max) - Number(min) > 0 ? Number(max) : Number(min) + 4,
              yAxisMin: min,
              // add FNSI-グラフの縦軸表示を修正 周 end
              yAxisNo: category.subCategoryNo,
              yAxisName: category.subCategoryName,
              name: subCategory.itemName,
              no: subCategory.itemNo,
              // add FNSI-グラフのシリーズ表示を修正_バイタル・モニタグラフ機能分 周 start
              color: subCategory.itemColor,
              marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
              // add FNSI-グラフのシリーズ表示を修正_バイタル・モニタグラフ機能分 周 end
              data: [],
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 start
              vitalMonitorClass: subCategory.vitalMonitorClass,
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 end
              type: subCategory.tableType
            });
          });
        });
        // add FNSI-グラフ３軸表示対応「230」「IES434」バイタル・モニタグラフ分 周 end
        chartData = createChartData(vitalInfo);
      }

      // add bug 6602 修正 chen start
      let breaks = [];
      let breakDays = [];
      if (period + "" === "1" || period + "" === "2" || period + "" === "3") {
        let days = endDate.diff(startDate, 'days');
        for (let i = 1; i < days; i++) {
          let daytmp = moment(startDate.format("YYYY-MM-DD"));
          daytmp = daytmp.add(i, 'days');
          let strDay = daytmp.format("YYYYMMDD");
          if (!Object.keys(copyTreatmentData).includes(strDay) &&
            !getters.getDateList.includes(strDay)) {
            breakDays.push(strDay);
          }
        }
        let daytmp = "";
        let daytmpS = "";
        breakDays.forEach(breakDay => {
          if (daytmpS === "") {
            daytmpS = breakDay;
          } else {
            if (moment(daytmp).add(1, 'days').format("YYYYMMDD") !== breakDay) {
              let fromD = moment(daytmpS).startOf('day');
              let toD = moment(daytmp).add(1, 'days').startOf('day');
              let breakItem = {
                from: fromD.valueOf(),
                to: toD.valueOf()
              };
              breaks.push(breakItem);
              daytmpS = breakDay;
            }
          }
          daytmp = breakDay;
        });
        if (daytmp !== daytmpS) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
        if (daytmpS !== "" && breaks.length === 0) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
      }
      // add bug 6602 修正 chen end


      convertData[0].data.push({
        type: "chart-rst",
        chartData,
        chartXAxisMin: startDate.valueOf(),
        chartXAxisMax: endDate.valueOf(),
        breaks: breaks,
        chartDisplayPeriod: period,
        yAxis: yAxis
      });
      return convertData;
    },
    // add 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 start
    /**
     * バイタルを表示用に加工(治療期間)
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {string} facilityCd 施設コード
     * @param {number} patId 患者ID
     * @param {string} weekPattern 取得曜日(※全曜日の場合、[{'text': '全','done': true,'value': 0}]) ※要検討
     */
    async convertVitalInfoDuringTreatment({ state, getters, commit }, { listIndex, layout, facilityCd, patId, weekPattern}) {
      if (!listIndex) {
        listIndex = 0;
      }
      const convertData = [
        {
          itemName: layout.categoryName,
          itemNameSub: [],
          data: []
        }
      ];
      const series = [];
      const yAxis = [];
      const copyTreatmentData = getters.getTreatmentData[listIndex] || {};
      if (!copyTreatmentData) {
        return [];
      }
      // グラフ用データに加工
      const createChartData = vitalInfo => {
        const tempArr = {};
        vitalInfo.forEach(rec => {
          rec.monitorData && Object.keys(rec.monitorData).forEach(itemNo => {
            // mod #12462 患者情報共有->患者経過総合ビューア fang start
            let isHandle = true
            if(facilityCd != rec.facilityCd) {
              const compareNo = itemNo.replace('Z', '')
              if(Number(compareNo) > 10000) {
                isHandle = false
              }
            }
            if(isHandle) {
              const pstNo = isNaN(itemNo) ? itemNo : parseInt(itemNo);
              if (!tempArr[pstNo]) {
                // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
                // tempArr[pstNo] = [...[], [rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo]), rec.ordNo]];
                //mod #10077 by zhangruixue 2024-2-20  start
                if(isStringNumeric(convertToHalfWidth(rec.monitorData[itemNo]))){
                  tempArr[pstNo] = [...[], [rec.occurDate, Number(convertToHalfWidth(rec.monitorData[itemNo])), rec.ordNo, rec.dataType]];
                }
                // tempArr[pstNo] = [...[], [rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo]), rec.ordNo, rec.dataType]];
                //mod #10077 by zhangruixue 2024-2-20  end
              } else {
                // tempArr[pstNo] = [...tempArr[pstNo], [rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo]), rec.ordNo]];
                /* modify by chamaojia 2023-10-12 [9713] 配列追加値のパフォーマンス最適化  --start */
                // 配列追加値の性能が悪く、pushに置き換える
                // tempArr[pstNo] = [...tempArr[pstNo], [rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo]), rec.ordNo, rec.dataType]];
                //mod #10077 by zhangruixue 2024-2-20  start
                if(isStringNumeric(convertToHalfWidth(rec.monitorData[itemNo]))){
                  tempArr[pstNo].push([rec.occurDate, Number(convertToHalfWidth(rec.monitorData[itemNo])), rec.ordNo, rec.dataType]);
                }
                // tempArr[pstNo].push([rec.occurDate, isNaN(rec.monitorData[itemNo]) ? rec.monitorData[itemNo] : Number(rec.monitorData[itemNo]), rec.ordNo, rec.dataType]);
                //mod #10077 by zhangruixue 2024-2-20  end
                /* modify by chamaojia 2023-10-12 [9713] 配列追加値のパフォーマンス最適化  --end */
                // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
              }
            }
            // mod #12462 患者情報共有->患者経過総合ビューア fang end
          });
        });
        const chartData = series.map(record => {
          // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
          // const pstNo = record.type === 1 ? record.no : record.name;
          // mod #10077 by zhangruixue 2023-11-28  start
          // const pstNo =  record.type == 2&&record.vitalMonitorClass==2 ? record.name : record.no;
          const pstNo = record.no;
          // mod #10077 by zhangruixue 2023-11-28  end
          // record.data = tempArr[pstNo] ? tempArr[pstNo] : [];
          record.data = tempArr[pstNo]? JSON.parse(JSON.stringify(tempArr[pstNo])).filter((item)=>{
            if (record.vitalMonitorClass==2) {
              return item[3]==1;
            }else{
              return item[3]!=1;
            }
          }) : [];
          // 8574 mod 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
          return record;
        })
        return chartData;
      };
      let chartData = [];
      const lastIndex = Object.keys(copyTreatmentData).length - 1;
      const period = getters.getSelectedPeriod;
      const isLongPeriod = ["4", "5", "6", "7"].includes(period);
      let startDate = moment(
        Object.keys(copyTreatmentData)[0] || getters.getDateList[0],
        "YYYYMMDD"
      ).startOf("day");
      let endDate = moment(
        Object.keys(copyTreatmentData)[lastIndex] ||
        getters.getDateList[getters.getDateList.length - 1],
        "YYYYMMDD"
      ).endOf("day");

      // 12週以降の場合、APIにリクエストをして期間内のデータを取得
      if (isLongPeriod) {
        // RestAPI実行
        const response = state.treatDateList;
        const vitalInfo = [];
        for (const ordInfo of response.data) {
          let resMniMonitors = getters.getResMniMonitors;
          let resMniMonitorTmp = resMniMonitors.filter(y => y.ordNo == ordInfo.ordNo);
          let resMniMonitor = null;
          if (resMniMonitorTmp && resMniMonitorTmp.length > 0) {
            resMniMonitor = resMniMonitorTmp[0].resMniMonitor;
          } else {
            resMniMonitor = await ApiHelper.get(
              `/status_list/mni_monitor/${ordInfo.ordNo}`
            ).catch(err => {
              throw err;
            })
            resMniMonitors.push({
              ordNo: ordInfo.ordNo,
              resMniMonitor: resMniMonitor
            });
            commit("setResMniMonitors", resMniMonitors);
          }
          resMniMonitor.data.forEach(monitorItem => {
            // 削除データは表示しない
            if (monitorItem.is_del === "1") {
              return;
            }
            vitalInfo.push({
              // add #12462 患者情報共有->患者経過総合ビューア fang start
              facilityCd: monitorItem.facility_cd,
              // add #12462 患者情報共有->患者経過総合ビューア fang end
              monitorData: monitorItem.monitor_data && JSON.parse(monitorItem.monitor_data),
              occurDate: monitorItem.occur_date,
              ordNo: monitorItem.ord_no,
              // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
              dataType: monitorItem.data_type
              // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
            })
          });
        }
        layout.categoryItem.forEach((category, index) => {
          const filterArr = [];
          const vitalResultArr = [];
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // // 上限値「マスタ情報から取得」
          // let max = category.graphMax ? Number(category.graphMax) : 0;
          // // 下限値「マスタ情報から取得」
          // let min = category.graphMin ? Number(category.graphMin) : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end

          // グループ条件「マスタ情報から取得」
          filterArr.push(...category.subCategoryItem.map(p => p.itemNo));
          // 実績データ「実績情報から取得」
          for (const vitalItem of vitalInfo) {
            for (const key of filterArr) {
              if (vitalItem.monitorData && vitalItem.monitorData.hasOwnProperty(key)) {
                // バイタル・モニタ情報存在場合
                vitalResultArr.push(vitalItem.monitorData[key]);
              }
            }
          }

          // add 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          const {max, min} = getThreshold(category.graphMax, category.graphMin, vitalResultArr, "line");
          // add 12031 患者経過総合ビューアのグラフオートレンジ zkm end

          // 実績情報をクリア
          vitalResultArr.splice(0, vitalResultArr.length);
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // // 上限値「実績情報から更新」
          // max = vitalResultArr.length > 0 ? Math.max(...vitalResultArr, max) : max;
          // // 下限値「実績情報から更新」
          // min = vitalResultArr.length > 0 ? Math.min(...vitalResultArr, min) : min;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          yAxis.push({
            labels: {enabled: false},
            title: {text: category.subCategoryName},
            tickPositioner: function () {
              const incrementCount = 4;
              const dataMax = max;
              const dataMin = min;
              const mstFixedCount = Math.max(
                (dataMin != Math.floor(dataMin)) ? (dataMin.toString()).split('.')[1].length : 0,
                (dataMax != Math.floor(dataMax)) ? (dataMax.toString()).split('.')[1].length : 0
              );
              const increment = max - min > 0 ? (max - min) / incrementCount : 0;
              const incrementFixedCount = (increment !== Math.floor(increment)) ? (increment.toString()).split('.')[1].length : 0;
              const incrementFixedMax = 3;

              const fixed = Math.max(Math.min(incrementFixedCount, incrementFixedMax), mstFixedCount);
              const positions = [];
              if (increment > 0) {
                positions.push(Number(dataMin));
                for (let index = 1; index < incrementCount; index++) {
                  const valFull = dataMin + index * increment;
                  const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
                  positions.push(valFloor);
                }
                positions.push(Number(dataMax));
              } else {
                for (let index = 0; index < incrementCount + 1; index++) {
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                  // positions.push(Number(dataMin + index));
                  const p = dataMin + index;
                  positions.push(parseFloat(p.toFixed(3)));
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
                }
              }
              return positions;
            },
            offset: 0
          });
          category.subCategoryItem.forEach(subCategory => {
            series.push({
              yAxis: index,
              yAxisMax: Number(max) - Number(min) > 0 ? Number(max) : Number(min) + 4,
              yAxisMin: min,
              yAxisNo: category.subCategoryNo,
              yAxisName: category.subCategoryName,
              name: subCategory.itemName,
              no: subCategory.itemNo,
              color: subCategory.itemColor,
              marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
              data: [],
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 start
              vitalMonitorClass: subCategory.vitalMonitorClass,
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 end
              type: subCategory.tableType
            });
          });
        });
        chartData = createChartData(vitalInfo);
      } else {
        endDate = endDate.add(1, "day").startOf("day");
        let vitalInfo = [];
        for (const treatDate in copyTreatmentData) {
          const ordInfo = copyTreatmentData[treatDate];
          if (!ordInfo) {
            continue;
          }
          let resMniMonitors = getters.getResMniMonitors;
          let resMniMonitorTmp = resMniMonitors.filter(y => y.ordNo == ordInfo.ordNo);
          let resMniMonitor = null;
          if (resMniMonitorTmp && resMniMonitorTmp.length > 0) {
            resMniMonitor = resMniMonitorTmp[0].resMniMonitor;
          } else {
            resMniMonitor = await ApiHelper.get(
              `/status_list/mni_monitor/${ordInfo.ordNo}`
            ).catch(err => {
              throw err;
            })
            resMniMonitors.push({
              ordNo: ordInfo.ordNo,
              resMniMonitor: resMniMonitor
            });
            commit("setResMniMonitors", resMniMonitors);
          }
          resMniMonitor.data.forEach(monitorItem => {
            // 削除データは表示しない
            if (monitorItem.is_del === "1") {
              return;
            }
            vitalInfo.push({
              // add #12462 患者情報共有->患者経過総合ビューア fang start
              facilityCd: monitorItem.facility_cd,
              // add #12462 患者情報共有->患者経過総合ビューア fang end
              monitorData: monitorItem.monitor_data && JSON.parse(monitorItem.monitor_data),
              occurDate: monitorItem.occur_date,
              ordNo: monitorItem.ord_no,
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 start
              dataType: monitorItem.data_type,
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 end
            })
          });
        }
        layout.categoryItem.forEach((category, index) => {
          const filterArr = [];
          const vitalResultArr = [];
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // // 上限値「マスタ情報から取得」
          // let max = category.graphMax ? Number(category.graphMax) : 0;
          // // 下限値「マスタ情報から取得」
          // let min = category.graphMin ? Number(category.graphMin) : 0;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // グループ条件「マスタ情報から取得」
          filterArr.push(...category.subCategoryItem.map(p => p.itemNo));
          // 実績データ「実績情報から取得」
          for (const vitalItem of vitalInfo) {
            for (const key of filterArr) {
              if (vitalItem.monitorData && vitalItem.monitorData.hasOwnProperty(key)) {
                // バイタル・モニタ情報存在場合
                vitalResultArr.push(vitalItem.monitorData[key]);
              }
            }
          }
          // add 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          const {max, min} = getThreshold(category.graphMax, category.graphMin, vitalResultArr, "line");
          // add 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // 実績情報をクリア
          vitalResultArr.splice(0, vitalResultArr.length);
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // // 上限値「実績情報から更新」
          // max = vitalResultArr.length > 0 ? Math.max(...vitalResultArr, max) : max;
          // // 下限値「実績情報から更新」
          // min = vitalResultArr.length > 0 ? Math.min(...vitalResultArr, min) : min;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          yAxis.push({
            labels: {enabled: false},
            title: {text: category.subCategoryName},
            tickPositioner: function () {
              const incrementCount = 4;
              const dataMax = max;
              const dataMin = min;
              const mstFixedCount = Math.max(
                (dataMin != Math.floor(dataMin)) ? (dataMin.toString()).split('.')[1].length : 0,
                (dataMax != Math.floor(dataMax)) ? (dataMax.toString()).split('.')[1].length : 0
              );
              const increment = max - min > 0 ? (max - min) / incrementCount : 0;
              const incrementFixedCount = (increment !== Math.floor(increment)) ? (increment.toString()).split('.')[1].length : 0;
              const incrementFixedMax = 3;

              const fixed = Math.max(Math.min(incrementFixedCount, incrementFixedMax), mstFixedCount);
              const positions = [];
              if (increment > 0) {
                positions.push(Number(dataMin));
                for (let index = 1; index < incrementCount; index++) {
                  const valFull = dataMin + index * increment;
                  const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
                  positions.push(valFloor);
                }
                positions.push(Number(dataMax));
              } else {
                for (let index = 0; index < incrementCount + 1; index++) {
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                  // positions.push(Number(dataMin + index));
                  const p = dataMin + index;
                  positions.push(parseFloat(p.toFixed(3)));
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
                }
              }
              return positions;
            },
            offset: 0
          });
          category.subCategoryItem.forEach(subCategory => {
            series.push({
              yAxis: index,
              yAxisMax: Number(max) - Number(min) > 0 ? Number(max) : Number(min) + 4,
              yAxisMin: min,
              yAxisNo: category.subCategoryNo,
              yAxisName: category.subCategoryName,
              name: subCategory.itemName,
              no: subCategory.itemNo,
              color: subCategory.itemColor,
              marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
              data: [],
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 start
              vitalMonitorClass: subCategory.vitalMonitorClass,
              //add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない  張 end
              type: subCategory.tableType
            });
          });
        });
        chartData = createChartData(vitalInfo);
      }
      let days = endDate.diff(startDate, 'days');
      let chartDataRange = [];
      // (グラフ)チャートデータレンジ(横軸範囲)の作成
      for (let i = 0; i < days; i++) {
        let startDateTmp = moment(startDate.valueOf()).add(i, 'days').startOf('day');
        let endDateTmp = moment(startDate.valueOf()).add(i + 1, 'days').startOf('day');
        let treatDate = startDateTmp.format("YYYYMMDD");
        let ordInfo = copyTreatmentData[treatDate];
        // 予定・実績作成済の場合
        if (ordInfo !== undefined && ordInfo !== null) {
          // 透析前体重測定日時
          let rstWeightBeforeDate = ordInfo.rstWeightInfo ? (JSON.parse(ordInfo.rstWeightInfo).weight_before_date === undefined || JSON.parse(ordInfo.rstWeightInfo).weight_before_date === null ? null : moment(JSON.parse(ordInfo.rstWeightInfo).weight_before_date)) : null;
          if (rstWeightBeforeDate !== null) {
            startDateTmp = rstWeightBeforeDate;
          } else {
            // 治療開始時刻
            let rstStartDate = ordInfo.rstStartDate ? (ordInfo.rstStartDate === undefined || ordInfo.rstStartDate === null ? null : moment(ordInfo.rstStartDate)) : null;
            if (rstStartDate !== null) {
              startDateTmp = rstStartDate;
            } else {
              startDateTmp = moment(startDate.valueOf()).add(i, 'days').startOf('day');
            }
          }
          // 透析後体重測定日時
          let rstWeightAfterDate = ordInfo.rstWeightInfo ? (JSON.parse(ordInfo.rstWeightInfo).weight_after_date === undefined || JSON.parse(ordInfo.rstWeightInfo).weight_after_date === null ? null : moment(JSON.parse(ordInfo.rstWeightInfo).weight_after_date)) : null;
          if (rstWeightAfterDate !== null) {
            endDateTmp = rstWeightAfterDate;
          } else {
            // 治療終了時刻
            let rstEndDate = ordInfo.rstEndDate ? (ordInfo.rstEndDate === undefined || ordInfo.rstEndDate === null ? null : moment(ordInfo.rstEndDate)) : null;
            if (rstEndDate !== null) {
              endDateTmp = rstEndDate;
            } else {
              endDateTmp = moment(startDateTmp.format("YYYYMMDD").valueOf()).add(1, 'days').startOf('day');
            }
          }
        }
        chartDataRange.push({
          ordNo: ordInfo !== undefined && ordInfo !== null ? ordInfo.ordNo : null,
          treatDate: treatDate,
          startDate: startDateTmp,
          endDate: endDateTmp
        });
      }
      // (グラフ)描画データの作成
      for (let i = 0; i < chartDataRange.length; i++) {
        let ordNo = chartDataRange[i].ordNo;
        let chartStartDate = chartDataRange[i].startDate;
        let chartEndDate = chartDataRange[i].endDate;
        let treatDate = chartDataRange[i].treatDate;
        let convertChartData = [];
        let copyChartData = deepCopy(chartData);
        // (グラフ)チャートデータの再作成
        copyChartData.forEach(copyChartDataItem => {
          let result = copyChartDataItem.data.filter((item) => item[2] === ordNo);
          if (result === undefined) {
            result = null;
          }
          copyChartDataItem.data = result;
          convertChartData.push(copyChartDataItem);
        });
        if (getters.getDateList.includes(treatDate)) {
          convertData[0].data.push({
            type: "chart-rst",
            chartData: convertChartData,
            chartXAxisMin: chartStartDate.valueOf(),
            chartXAxisMax: chartEndDate.valueOf(),
            chartDisplayPeriod: period,
            yAxis: yAxis,
            chartType: "line",
            showLegend: true
          });
        }
      }
      return convertData;
    },
    // add 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 end
    /**
     * 体重情報を表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {string} facilityCd 施設コード
     * @param {number} patId 患者ID
     * @param {string} weekPattern 取得曜日(※全曜日の場合、[{'text': '全','done': true,'value': 0}]) ※要検討
     */
    async convertWeightInfo({ state, getters }, { listIndex, layout, facilityCd, patId, weekPattern }) {
      const convertData = [
        {
          itemName: layout.categoryName,
          itemNameSub: [],
          data: []
        }
      ];

      const series = [];
      const yAxis = [];

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex] || {};
      if (!copyTreatmentData) {
        return [];
      }
      // グラフ用データに加工
      const createChartData = weightInfo => {
        const tempArr = {};
        // add FNSI-体重グラフ項目を修正。 周 start
        const itemNoDW = "rst_dw";
        // add FNSI-体重グラフ項目を修正。 周 end
        //mod FNSI-redmine 4885 劉祥霖 start
        weightInfo.forEach(rec => {
          let dateTime = rec.treatDate.toString();
          // add FNSI-体重グラフ項目を修正。 周 start
          //dwの場合
          if (rec.dw != null) {
            if (rec.weightInfo.weight_before_date != null) {
              dateTime = rec.weightInfo.weight_before_date;
            } else {
              dateTime = rec.treatDate.toString();
              dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
              dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
              // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
              // let recTreatDatehm = rec.treatStartTime.toString();
              let recTreatDatehm = rec.treatStartTime?.toString();
              // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
              if(recTreatDatehm != null){
                recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                recTreatDatehm = recTreatDatehm+":00.000";
                dateTime = dateTime+"T"+recTreatDatehm;
              }
            }
            if (!tempArr[itemNoDW]) {
              tempArr[itemNoDW] = [...[], [dateTime, Number(rec.dw)]];
            } else {
              /* modify by chamaojia 2023-10-12 [9713] 配列追加値のパフォーマンス最適化  --start */
              // 配列追加値の性能が悪く、pushに置き換える
              // tempArr[itemNoDW] = [...tempArr[itemNoDW], [dateTime, Number(rec.dw)]];
              tempArr[itemNoDW].push([dateTime, Number(rec.dw)]);
              /* modify by chamaojia 2023-10-12 [9713] 配列追加値のパフォーマンス最適化  --end */
            }
          }
          // add FNSI-体重グラフ項目を修正。 周 end
          //mod 5929体重グラフの表示不正 張 start
          rec.weightInfo && series.forEach(serie => {
            let dataIn = rec.weightInfo[serie.no] != undefined && rec.weightInfo[serie.no] != null ? Number(rec.weightInfo[serie.no]) : null;
            let dataName = serie.no.toString();
            if (dataName!="rst_dw") {
              switch (dataName){
                //増加量場合「increase」「前体重-前回後体重」
                case "increase":
                  //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
                  // const weightItemZen = getWeightItemZen(rec.treatDate, rec.treatStartTime);
                  // if (weightItemZen != null && weightItemZen.weightInfo != null) {
                  if (rec != null && rec.weightInfo != null) {
                    // if (rec.weightInfo.weight_before != null && weightItemZen.weightInfo.weight_after != null) {
                    if (rec.weightInfo.weight_before != null && rec.lastWeightAfter != null) {
                      const valWeightBefore = rec.weightInfo.weight_before ? Number(rec.weightInfo.weight_before) : 0;
                      // const valWeightAfterZen = weightItemZen.weightInfo.weight_after ? Number(weightItemZen.weightInfo.weight_after) : 0;
                      const valWeightAfterZen = rec.lastWeightAfter ? Number(rec.lastWeightAfter) : 0;
                      dataIn = valWeightBefore - valWeightAfterZen;
                    }
                  }
                  if (rec.weightInfo.weight_before_date != null) {
                    dateTime = rec.weightInfo.weight_before_date;
                  } else {
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // dateTime = rec.treatDate.toString();
                    dateTime = rec.treatDate?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //増加率場合「increase_rate」「(前体重-前回後体重)/DW*100」
                case "increase_rate":
                  if (rec.dw) {
                    // const weightItemZen = getWeightItemZen(rec.treatDate, rec.treatStartTime);
                    // if (weightItemZen != null && weightItemZen.weightInfo != null) {
                    if (rec != null && rec.weightInfo != null) {
                      // if (rec.weightInfo.weight_before != null && weightItemZen.weightInfo.weight_after != null) {
                      if (rec.weightInfo.weight_before != null && rec.lastWeightAfter != null) {
                        const valWeightBefore = rec.weightInfo.weight_before ? Number(rec.weightInfo.weight_before) : 0;
                        // const valWeightAfterZen = weightItemZen.weightInfo.weight_after ? Number(weightItemZen.weightInfo.weight_after) : 0;
                        const valWeightAfterZen = rec.lastWeightAfter ? Number(rec.lastWeightAfter) : 0;
                        //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
                        const valDW = rec.dw ? Number(rec.dw) : 0;
                        //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
                        // dataIn = Number((valWeightBefore - valWeightAfterZen) / valDW * 100);
                        dataIn = Number((Number((valWeightBefore - valWeightAfterZen) / valDW * 100)).toFixed(2));
                        //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
                      }
                    }
                    if (rec.weightInfo.weight_before_date != null) {
                      dateTime = rec.weightInfo.weight_before_date;
                    } else {
                      dateTime = rec.treatDate.toString();
                      dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                      dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                      // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                      // let recTreatDatehm = rec.treatStartTime.toString();
                      let recTreatDatehm = rec.treatStartTime?.toString();
                      // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                      if(recTreatDatehm != null){
                        recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                        recTreatDatehm = recTreatDatehm+":00.000";
                        dateTime = dateTime+"T"+recTreatDatehm;
                      }
                    }
                  }
                  break;
                //減少量場合「reduction」「前体重-後体重」
                case "reduction":
                  if (rec.weightInfo.weight_before != null && rec.weightInfo.weight_after != null) {
                    const valWeightBefore = rec.weightInfo.weight_before ? Number(rec.weightInfo.weight_before) : 0;
                    const valWeightAfterZen = rec.weightInfo.weight_after ? Number(rec.weightInfo.weight_after) : 0;
                    dataIn = valWeightBefore - valWeightAfterZen;
                  }
                  if (rec.weightInfo.weight_after_date != null) {
                    dateTime = rec.weightInfo.weight_after_date;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //減少率場合「reduction_rate」「(前体重-後体重)/DW*100」
                case "reduction_rate":
                  if (rec.dw) {
                    if (rec.weightInfo.weight_before != null && rec.weightInfo.weight_after != null) {
                      const valWeightBefore = rec.weightInfo.weight_before ? Number(rec.weightInfo.weight_before) : 0;
                      const valWeightAfterZen = rec.weightInfo.weight_after ? Number(rec.weightInfo.weight_after) : 0;
                      const valDW = rec.dw ? Number(rec.dw) : 0;
                      //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
                      // dataIn = Number((valWeightBefore - valWeightAfterZen) / valDW * 100);
                      dataIn = Number((Number((valWeightBefore - valWeightAfterZen) / valDW * 100)).toFixed(2));
                      //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
                    }
                    if (rec.weightInfo.weight_after_date != null) {
                      dateTime = rec.weightInfo.weight_after_date;
                    } else {
                      dateTime = rec.treatDate.toString();
                      dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                      dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                      // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                      // let recTreatDatehm = rec.treatStartTime.toString();
                      let recTreatDatehm = rec.treatStartTime?.toString();
                      // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                      if(recTreatDatehm != null){
                        recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                        recTreatDatehm = recTreatDatehm+":00.000";
                        dateTime = dateTime+"T"+recTreatDatehm;
                      }
                    }
                  }
                  break;
                //再循環率場合「re_loop_rate_main」
                case "re_loop_rate_main":
                  if (rec.weightInfo.recrcl_rt && rec.weightInfo.recrcl_rt.valid_no > 0) {
                    const validNo = rec.weightInfo.recrcl_rt.valid_no;
                    if (rec.weightInfo.recrcl_rt.hasOwnProperty(validNo)) {
                      if (rec.weightInfo.recrcl_rt[validNo].rate != null) {
                        dataIn = Number(rec.weightInfo.recrcl_rt[validNo].rate);
                      }
                    }
                    if (rec.weightInfo.recrcl_rt[validNo].datetime != null) {
                      dateTime = rec.weightInfo.recrcl_rt[validNo].datetime;
                    } else {
                      dateTime = rec.treatDate.toString();
                      dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                      dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                      // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                      // let recTreatDatehm = rec.treatStartTime.toString();
                      let recTreatDatehm = rec.treatStartTime?.toString();
                      // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                      if(recTreatDatehm != null){
                        recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                        recTreatDatehm = recTreatDatehm+":00.000";
                        dateTime = dateTime+"T"+recTreatDatehm;
                      }
                    }
                  }

                  break;
                //再循環率測定時血流量場合「re_loop_rate_main_blood_flow」
                case "re_loop_rate_main_blood_flow":
                  if (rec.weightInfo.recrcl_rt && rec.weightInfo.recrcl_rt.valid_no > 0) {
                    const validNo = rec.weightInfo.recrcl_rt.valid_no;
                    if (rec.weightInfo.recrcl_rt.hasOwnProperty(validNo)) {
                      if (rec.weightInfo.recrcl_rt[validNo].bld_vl != null) {
                        dataIn = Number(rec.weightInfo.recrcl_rt[validNo].bld_vl);
                      }
                    }
                    if (rec.weightInfo.recrcl_rt[validNo].datetime != null) {
                      dateTime = rec.weightInfo.recrcl_rt[validNo].datetime;
                    } else {
                      dateTime = rec.treatDate.toString();
                      dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                      dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                      // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                      // let recTreatDatehm = rec.treatStartTime.toString();
                      let recTreatDatehm = rec.treatStartTime?.toString();
                      // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                      if(recTreatDatehm != null){
                        recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                        recTreatDatehm = recTreatDatehm+":00.000";
                        dateTime = dateTime+"T"+recTreatDatehm;
                      }
                    }
                  }
                  break;
                //補液量場合「add_water_total」
                case "fluid_volume":
                  if (rec.weightInfo["add_water_total"] != null) {
                    dataIn = Number(rec.weightInfo["add_water_total"]);
                  }
                  if (rec.rstEndDate != null) {
                    dateTime = rec.rstEndDate;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //実績除水量「water_removal_rst」
                case "water_removal_rst":
                  if (rec.weightInfo["water_removal_rst"] != null) {
                    dataIn = Number(rec.weightInfo["water_removal_rst"]);
                  }
                  if (rec.rstEndDate != null) {
                    dateTime = rec.rstEndDate;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //URR「urr」
                case "urr":
                  if (rec.weightInfo["urr"] != null) {
                    dataIn = Number(rec.weightInfo["urr"]);
                  }
                  if (rec.rstEndDate != null) {
                    dateTime = rec.rstEndDate;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //静的静脈圧「sttc_vns_prssr」
                case "sttc_vns_prssr":
                  if (rec.weightInfo["sttc_vns_prssr"] != null) {
                    dataIn = Number(rec.weightInfo["sttc_vns_prssr"]);
                  }
                  if (rec.rstEndDate != null) {
                    dateTime = rec.rstEndDate;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //IAP rate「iap_rt」
                case "iap_rt":
                  if (rec.weightInfo["iap_rt"] != null) {
                    dataIn = Number(rec.weightInfo["iap_rt"]);
                  }
                  if (rec.rstEndDate != null) {
                    dateTime = rec.rstEndDate;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //CTR「ctr」
                case "ctr":
                  if (rec.weightInfo["ctr"] != null) {
                    dataIn = Number(rec.weightInfo["ctr"]);
                  }
                  if (rec.weightInfo.weight_before_date != null) {
                    dateTime = rec.weightInfo.weight_before_date;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //Kt/V測定値場合「kt_v_measure」
                case "ktv_measurements":
                  if (rec.weightInfo.kt_v_measure != null) {
                    dataIn = Number(rec.weightInfo.kt_v_measure);
                  }
                  if (rec.rstEndDate != null) {
                    dateTime = rec.rstEndDate;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng end
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //透析前体重の場合
                case "weight_before":
                  if (rec.weightInfo.weight_before_date != null) {
                    dateTime = rec.weightInfo.weight_before_date;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                //透析后体重の場合
                case "weight_after":
                  if (rec.weightInfo.weight_after_date != null) {
                    dateTime = rec.weightInfo.weight_after_date;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;
                default:
                  if (rec.weightInfo.weight_before_date != null) {
                    dateTime = rec.weightInfo.weight_before_date;
                  } else {
                    dateTime = rec.treatDate.toString();
                    dateTime = dateTime.slice(0,4)+'-'+dateTime.slice(4);
                    dateTime = dateTime.slice(0,7)+'-'+dateTime.slice(7);
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    // let recTreatDatehm = rec.treatStartTime.toString();
                    let recTreatDatehm = rec.treatStartTime?.toString();
                    // #9713 TypeError: Cannot read properties of null (reading 'toString') 修正 linjunfeng start
                    if(recTreatDatehm != null){
                      recTreatDatehm = recTreatDatehm.slice(0,2)+":"+recTreatDatehm.slice(2);
                      recTreatDatehm = recTreatDatehm+":00.000";
                      dateTime = dateTime+"T"+recTreatDatehm;
                    }
                  }
                  break;

              }
              // 入力データ ≠ null(未指定)の場合
              if (dataIn != null) {
                //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
                dataIn = Number((dataIn).toFixed(2))
                //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
                if (!tempArr[dataName]) {
                  tempArr[dataName] = [...[], [dateTime, dataIn]];
                } else {
                  /* modify by chamaojia 2023-10-12 [9713] 配列追加値のパフォーマンス最適化  --start */
                  // 配列追加値の性能が悪く、pushに置き換える
                  // tempArr[dataName] = [...tempArr[dataName], [dateTime, dataIn]];
                  tempArr[dataName].push([dateTime, dataIn]);
                  /* modify by chamaojia 2023-10-12 [9713] 配列追加値のパフォーマンス最適化  --end */
                }
              }
            }
          });
          //mod 5929体重グラフの表示不正 張 end
        });
        //mod FNSI-redmine 4885 劉祥霖 end
        const chartData = series.map(record => {
          record.data = tempArr[record.no] ? tempArr[record.no]: [];
          return record;
        })
        return chartData;
      };

      let chartData = [];
      const lastIndex = Object.keys(copyTreatmentData).length - 1;
      const period = getters.getSelectedPeriod;
      const isLongPeriod = ["4", "5", "6", "7"].includes(period);
      // TODO: pushするために一時的にコメントアウト
      let startDate = moment(
        Object.keys(copyTreatmentData)[0] || getters.getDateList[0],
        "YYYYMMDD"
      ).startOf("day");
      let endDate = moment(
        Object.keys(copyTreatmentData)[lastIndex] ||
        getters.getDateList[getters.getDateList.length - 1],
        "YYYYMMDD"
      ).endOf("day");

      // 12週以降の場合、APIにリクエストをして期間内のデータを取得
      if (isLongPeriod) {
        // 選択された期間によって開始日と終了日を調整する
        switch (period) {
          case "4":
            // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 start
            // endDate = endDate.add(1, "week").startOf("day");
            endDate = endDate.add(1, "week").startOf("day").subtract(1, "days");
            // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 end
            break;
          case "5":
          case "6":
            startDate = startDate.startOf("month");
            endDate = endDate.endOf("month");
            break;
          case "7":
            startDate = startDate.startOf("month");
            endDate = endDate.add(11, "months").endOf("month");
            break;
        }
        // add FNSI-体重グラフ項目を修正。 周 start
      } else {
        endDate = endDate.add(1, "day").startOf("day");
      }
      // add FNSI-体重グラフ項目を修正。 周 end
      // RestAPI実行
      const response = state.treatDateList;
      const weights = [];
      // mod #12462 患者情報共有->患者経過総合ビューア fang start
      if(response && response.data && response.data.length > 0) {
        for (const ordInfo of response.data) {
          const weightInfo =
            ordInfo &&
            ordInfo.rstWeightInfo &&
            JSON.parse(ordInfo.rstWeightInfo);
          weights.push({
            weightInfo: weightInfo,
            // add FNSI-体重グラフ項目を修正。 周 start
            dw: ordInfo.rstDw,
            // add FNSI-体重グラフ項目を修正。 周 end
            treatDate: ordInfo.treatDate,
            treatStartTime:ordInfo.indTreatStartTime
            // add 5929体重グラフの表示不正。 張 start
            ,rstEndDate:ordInfo.rstEndDate ? ordInfo.rstEndDate : null
            // add 5929体重グラフの表示不正。 張 end
            ,lastWeightAfter:ordInfo.lastWeightAfter
          });
        }
      }
      // mod #12462 患者情報共有->患者経過総合ビューア fang end
      const weightItemsTemp = [];
      for (const ordInfo of response.data.filter(rec => rec.rstDialysisState !== "0")) {
        const weightInfo = ordInfo && ordInfo.rstWeightInfo && JSON.parse(ordInfo.rstWeightInfo);
        if (ordInfo.rstStartDate || ordInfo.indTreatStartTime) {
          weightItemsTemp.push({
            weightInfo: weightInfo,
            dw: ordInfo.rstDw,
            treatDate: ordInfo.treatDate,
            startTime: ordInfo.rstStartDate ? moment(ordInfo.rstStartDate).format("HHmm") : Number(ordInfo.indTreatStartTime)
          });
        }
      }
      const weightItems = [];
      weightItems.push(
        ...weightItemsTemp.sort(function(a, b) {
          if (a.treatDate === b.treatDate) {
            if (a.startTime > b.startTime) {
              return 1;
            } else {
              return -1;
            }
          } else if (a.treatDate > b.treatDate) {
            return 1;
          } else {
            return -1;
          }
        })
      );
      // add FNSI-グラフ３軸表示対応「共通展開」体重グラフ分 周 start
      layout.categoryItem.forEach((category, index) => {
        const filterArr = [];
        const weightResultArr = [];
        // 上限値「マスタ情報から取得」
        // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 start
        // let max = category.max ? category.max : 0;
        // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
        // let max = category.graphMax ? Number(category.graphMax) : 0;
        // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
        // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 end
        // 下限値「マスタ情報から取得」
        // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 start
        // let min = category.min ? category.min : 0;
        // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
        // let min = category.graphMin ? Number(category.graphMin) : 0;
        // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end
        // mod FNSI-redmine_#3828_グラフの縦軸表示を修正する 周 end

        // グループ条件「マスタ情報から取得」
        filterArr.push(...category.subCategoryItem.map(p => p.itemNo));
        // 実績データ「実績情報から取得」
        for (const weightItem of weights) {
          for (const key of filterArr) {
            if (key === "rst_dw") {
              // DW場合
              weightResultArr.push(weightItem.dw);
            } else if (weightItem.weightInfo && weightItem.weightInfo.hasOwnProperty(key)) {
              // 体重情報存在場合
              weightResultArr.push(weightItem.weightInfo[key]);
            }
          }
        }

        const {max, min} = getThreshold(category.graphMax, category.graphMin, weightResultArr, "line");

        // 実績情報をクリア
        weightResultArr.splice(0, weightResultArr.length);
        yAxis.push({
          labels: { enabled: false },
          title: { text: category.subCategoryName },
          tickPositioner: function() {
            const incrementCount = 4;
            const dataMax = max;
            const dataMin = min;
            const mstFixedCount = Math.max(
              (dataMin != Math.floor(dataMin)) ? (dataMin.toString()).split('.')[1].length : 0,
              (dataMax != Math.floor(dataMax)) ? (dataMax.toString()).split('.')[1].length : 0
            );
            const increment = max - min > 0 ? (max - min) / incrementCount : 0;
            const incrementFixedCount = (increment !== Math.floor(increment)) ? (increment.toString()).split('.')[1].length : 0;
            const incrementFixedMax = 3;

            const fixed = Math.max(Math.min(incrementFixedCount, incrementFixedMax), mstFixedCount);
            const positions = [];
            if (increment > 0) {
              positions.push(Number(dataMin));
              for (let index = 1; index < incrementCount; index++) {
                const valFull = dataMin + index * increment;
                const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
                positions.push(valFloor);
              }
              positions.push(Number(dataMax));
            } else {
              for (let index = 0; index < incrementCount + 1; index++) {
                // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                // positions.push(Number(dataMin + index));
                const p = dataMin + index;
                positions.push(parseFloat(p.toFixed(3)));
                // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
              }
            }
            return positions;
          },
          offset: 0
        });
        // mod FNSI-グラフの縦軸表示を修正 周 end
        category.subCategoryItem.forEach(subCategory => {
          series.push({
            yAxis: index,
            // add FNSI-グラフの縦軸表示を修正 周 start
            yAxisMax: Number(max) - Number(min) > 0 ? Number(max) : Number(min) + 4,
            yAxisMin: min,
            // add FNSI-グラフの縦軸表示を修正 周 end
            yAxisNo: category.subCategoryNo,
            yAxisName: category.subCategoryName,
            name: subCategory.itemName,
            no: subCategory.itemNo,
            // add FNSI-グラフのシリーズ表示を修正_体重グラフ機能分 周 start
            color: subCategory.itemColor,
            marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
            // add FNSI-グラフのシリーズ表示を修正_体重グラフ機能分 周 end
            data: []
          });
        });
      });
      // add FNSI-グラフ３軸表示対応「共通展開」体重グラフ分 周 end
      chartData = createChartData(weights);
      // add bug 6602 修正 chen start
      let breaks = [];
      let breakDays = [];
      if (period + "" === "1" || period + "" === "2" || period + "" === "3") {
        let days = endDate.diff(startDate, 'days');
        for (let i = 1; i < days; i++) {
          let daytmp = moment(startDate.format("YYYY-MM-DD"));
          daytmp = daytmp.add(i, 'days');
          let strDay = daytmp.format("YYYYMMDD");
          if (!Object.keys(copyTreatmentData).includes(strDay) &&
            !getters.getDateList.includes(strDay)) {
            breakDays.push(strDay);
          }
        }
        let daytmp = "";
        let daytmpS = "";
        breakDays.forEach(breakDay => {
          if (daytmpS === "") {
            daytmpS = breakDay;
          } else {
            if (moment(daytmp).add(1, 'days').format("YYYYMMDD") !== breakDay) {
              let fromD = moment(daytmpS).startOf('day');
              let toD = moment(daytmp).add(1, 'days').startOf('day');
              let breakItem = {
                from: fromD.valueOf(),
                to: toD.valueOf()
              };
              breaks.push(breakItem);
              daytmpS = breakDay;
            }
          }
          daytmp = breakDay;
        });
        if (daytmp !== daytmpS) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
        if (daytmpS !== "" && breaks.length === 0) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
      }
      // add bug 6602 修正 chen end
      convertData[0].data.push({
        type: "chart-rst",
        chartData,
        chartXAxisMin: startDate.valueOf(),
        chartXAxisMax: endDate.valueOf(),
        breaks: breaks,
        chartDisplayPeriod: period,
        yAxis: yAxis
      });
      return convertData;
    },

    /**
     * 検査結果を表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {string} facilityCd 施設コード
     * @param {number} patId 患者ID
     * @param {string} weekPattern 取得曜日(※全曜日の場合、[{'text': '全','done': true,'value': 0}]) ※要検討
     */
    // async convertExamResultInfo(
    //   { getters },
    //   { listIndex, layout, facilityCd, patId }
    // ) {
    // mod FNSI-投薬支援仕様更新「予測値」「回帰直線」 周 start
    // async convertExamResultInfo({ getters }, { listIndex, layout, patId }) {
    async convertExamResultInfo({ getters }, { listIndex, layout, facilityCd, patId }) {
      // mod FNSI-投薬支援仕様更新「予測値」「回帰直線」 周 end
      const convertData = [
        {
          itemName: layout.categoryName,
          itemNameSub: [],
          data: []
        }
      ];

      const series = [];
      const yAxis = [];

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex] || {};
      if (!copyTreatmentData) {
        return [];
      }

      // グラフ用データに加工
      const createChartData = examInfo => {
        const tempArr = {};
        /* modify by chamaojia 2023-10-12 [9713] 処理回数の削減、コードの最適化  --start */
        // 表示したい項目に対応するNOを検索する
        const itemKeyArr = series.map(record => record.no)
        examInfo.forEach(rec => {
          rec.examInfo && rec.examInfo.forEach(item => {
            const pstNo = parseInt(item.item_cd);
            // 表示された項目のみを処理すると判断する
            if (itemKeyArr.indexOf(pstNo) != -1) {
              let examResult = null;
              if (item.result != null) {
                //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
                // examResult = Number(item.result);
                examResult = Number(convertToHalfWidth(item.result));
                //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
              }
              // 入力データ ≠ null(未指定)の場合
              // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
              if (examResult != null) {
                if (!tempArr[pstNo]) {
                  tempArr[pstNo] = [[rec.examDate, examResult, rec.orderClass]];
                } else {
                  // 配列追加値の性能が悪く、pushに置き換える
                  // tempArr[pstNo] = [...tempArr[pstNo], [rec.examDate, examResult]];
                  tempArr[pstNo].push([rec.examDate, examResult, rec.orderClass]);
                }
              }
              // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
            }
          })
        });
        /* modify by chamaojia 2023-10-12 [9713] 処理回数の削減、コードの最適化  --end */

        const chartData = series.map(record => {
          // mod FNSI-投薬支援仕様更新「予測値」 周 start
          // record.data = tempArr[record.no] ? tempArr[record.no]: [];
          // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
          // record.data = tempArr[record.no] ? tempArr[record.no]: record.data;
          // mod FNSI-投薬支援仕様更新「予測値」 周 end
          if (tempArr[record.no]) {
            const latestByDayAndClass = {};

            const examClass = record.examClass != null && record.examClass !== '' ? record.examClass : '3';

            tempArr[record.no].forEach(item => {
              const datetime = new Date(item[0]);
              const category = item[2] == 3 ? 0 : item[2];

              const dayStr = datetime;
              const key = `${dayStr}_${category}`;

              if (examClass == '3') {
                const existing = latestByDayAndClass[key];
                if (!existing || new Date(existing[0]) < datetime) {
                  latestByDayAndClass[key] = item;
                }
              } else if (examClass == category) {
                const existing = latestByDayAndClass[key];
                if (!existing || new Date(existing[0]) < datetime) {
                  latestByDayAndClass[key] = item;
                }
              }
            });

            record.data = Object.values(latestByDayAndClass).sort((a, b) => {
              const getDateString = (d) => new Date(d[0]);
              const dateA = getDateString(a);
              const dateB = getDateString(b);

              if (dateA === dateB) {
                const priority = { "1": 0, "2": 1, "3": 2 };
                return (priority[a[2]?.toString()] ?? 99) - (priority[b[2]?.toString()] ?? 99);
              } else {
                return dateA < dateB ? -1 : 1;
              }
            });
          } else {
            record.data = record.data;
          }
          // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
          return record;
        })

        return chartData;
      };

      // add FNSI-投薬支援仕様更新「予測値」 周 start
      const getPredictionValue = mst => {
        if (!(mst && mst.detailInfo && JSON.parse(mst.detailInfo))) {
          return null;
        }
        const detailInfo = JSON.parse(mst.detailInfo);

        if (!(detailInfo.hasOwnProperty("examItemCycling") && detailInfo.examItemCycling)) {
          return null;
        }
        const itemNoInfo = detailInfo.examItemCycling;

        // 投薬支援⇒予測値無効場合
        if (!(itemNoInfo && itemNoInfo?.[0]?.hasOwnProperty("value") && itemNoInfo[0].value)) {
          return null;
        }
        return itemNoInfo[0].value.toString();
      };
      // add FNSI-投薬支援仕様更新「予測値」 周 end

      // add FNSI-投薬支援仕様更新「回帰直線」 周 start
      const getRegressionValue = mst => {
        if (!(mst && mst.detailInfo && JSON.parse(mst.detailInfo))) {
          return null;
        }
        const detailInfo = JSON.parse(mst.detailInfo);

        if (!(detailInfo.hasOwnProperty("examItemRegression") && detailInfo.examItemRegression)) {
          return null;
        }
        const itemNoInfo = detailInfo.examItemRegression;

        // 投薬支援⇒回帰直線無効場合
        if (!(itemNoInfo && itemNoInfo?.[0]?.hasOwnProperty("value") && itemNoInfo[0].value)) {
          return null;
        }
        return itemNoInfo[0].value.toString();
      };
      // add FNSI-投薬支援仕様更新「回帰直線」 周 end

      const lastIndex = Object.keys(copyTreatmentData).length - 1;
      const period = getters.getSelectedPeriod;
      const isLongPeriod = ["4", "5", "6", "7"].includes(period);
      let chartData = [];
      let startDate = moment(
        Object.keys(copyTreatmentData)[0] || getters.getDateList[0],
        "YYYYMMDD"
      ).startOf("day");
      let endDate = moment(
        Object.keys(copyTreatmentData)[lastIndex] ||
        getters.getDateList[getters.getDateList.length - 1],
        "YYYYMMDD"
      ).endOf("day");

      // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 start
      // 選択中投薬支援マスト情報を取得
      const selectedMedicineSupportItem = getters.getSelectedMedicineSupport === null ? null :
        getters.getMstMedicineSupportData.find(mstData => {
          return mstData.medicineSupportCd === getters.getSelectedMedicineSupport;
        });
      // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 end

      // 12週以降の場合、APIにリクエストをして期間内のデータを取得
      if (isLongPeriod) {
        // 選択された期間によって開始日と終了日を調整する
        switch (period) {
          case "4":
            // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 start
            // endDate = endDate.add(1, "week").startOf("day");
            endDate = endDate.add(1, "week").startOf("day").subtract(1, "days");
            // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 end
            break;
          case "5":
          case "6":
            startDate = startDate.startOf("month");
            endDate = endDate.endOf("month");
            break;
          case "7":
            startDate = startDate.startOf("month");
            endDate = endDate.add(11, "months").endOf("month");
            break;
        }
      } else {
        endDate = endDate.add(1, "day").startOf("day");
      }
      // RestAPI実行
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
      const sendData = {};
      const patientShareMode = store.getters["account-edit/getPatientShareMode"];
      const patientShareFacilityCdMode = store.getters["account-edit/getPatientShareFacilityCdMode"];
      // 0: マージ  1: 自施設
      sendData.patShareMode = patientShareMode == 0 && !patientShareFacilityCdMode ? 0 : 1;
      const response = await ApiHelper.post(
        // `/exam/TreatDateList/${patId}/${startDate.format("YYYYMMDD")}/${endDate.format("YYYYMMDD")}`
        `/exam/TreatDateList/${patId}/${startDate.format("YYYYMMDD")}/${endDate.format("YYYYMMDD")}`, sendData
      ).catch(err => {
        throw err;
      });
      /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
      // add IES_6849【試験T】【結合テスト】グラーフ関連：【計画】画面の【検査結果グラーフ】グラフは2桁小さいまま残っていません 関 start
      const responseItem = await ApiHelper.get(`/exam/examRecord/examItem/${facilityCd}`
      ).catch(err => {
        throw err;
      });
      // add IES_6849【試験T】【結合テスト】グラーフ関連：【計画】画面の【検査結果グラーフ】グラフは2桁小さいまま残っていません 関 end
      const tempExamData = [];
      for (const examRecord of response.data) {
        // mod #12462 患者情報共有->患者経過総合ビューア fang start
        let tempResult = []
        let tempExamResultInfo = []
        if(examRecord.examResultInfo && examRecord.examResultInfo.length > 0) {
          tempExamResultInfo = JSON.parse(examRecord.examResultInfo)
          tempResult = otherFacilityPatExamMainConvert(facilityCd, examRecord.facilityCd, tempExamResultInfo, responseItem, layout, examRecord.regOrderClass)
        }
        const examInfo = tempResult;
        // mod #12462 患者情報共有->患者経過総合ビューア fang end
        // FNSI-検査結果表示の日時項目を変更 周 mod start
        // examData.push({
        //   examInfo: examInfo,
        //   examDate: examRecord.regExamDate
        // });
        // add IES_6849【試験T】【結合テスト】グラーフ関連：【計画】画面の【検査結果グラーフ】グラフは2桁小さいまま残っていません 関 start
        examInfo && examInfo.forEach(item => {
          if (item.exam_class == '1') {
            responseItem.data.forEach(examItem => {
              if (item.item_cd == examItem.examItemCd && item.result != "") {
              //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
              //    item.result = parseFloat(item.result).toFixed(examItem.inputDecimalFigure);
                 item.result = parseFloat(convertToHalfWidth(item.result));
              //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
              }
            })
          }
        })
        // add IES_6849【試験T】【結合テスト】グラーフ関連：【計画】画面の【検査結果グラーフ】グラフは2桁小さいまま残っていません 関 start
        if (examInfo && examRecord.resultExamDate) {
          // 検査区分(透析前："1" / 透析後："2" / その他："0")
          let orderClass = examRecord.regOrderClass;
          if (orderClass === "0") {
            orderClass = "3";
          }
          tempExamData.push({
            examInfo: examInfo,
            examDate: examRecord.resultExamDate,
            orderClass: orderClass
          });
        }
        // FNSI-検査結果表示の日時項目を変更 周 mod end
      }
      // tempExamDataのソート
      tempExamData.sort(function(a, b){
        // 検査日時同時間の場合
        if(a.examDate === b.examDate){
          // 検査区分(透析前："1" → 透析後："2" → その他："3")
          if(a.orderClass > b.orderClass){
            return 1;
          } else {
            return -1;
          }
        } else {
          return 0;
        }
      })
      // examDataの再構成
      const examData = [];
      // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
      for (const tempExamRecord of tempExamData) {
        examData.push({
          examInfo: tempExamRecord.examInfo,
          examDate: tempExamRecord.examDate,
          orderClass: tempExamRecord.orderClass
        });
      }
      // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
      // add FNSI-投薬支援仕様更新「予測値」「回帰直線」 周 start
      const ordMaterialSave = [];
      // 投薬支援マスタ設定「予測値項目コード」
      const predictionValue = getPredictionValue(selectedMedicineSupportItem);
      // 予測値
      const shien_yosokuchi = "prediction";
      // 投薬支援条件
      // 「5：投薬支援」
      const sourceArr_shien = ["5"];
      // 「5：投薬支援」⇒「19：予測値（投薬支援）」
      const suppliesArr_shien_yosokuchi = ["19"];
      // 予測値「検査項目（cycling・予測値）」
      let hasPredictive = false;
      // 予測値データ「検査項目（cycling・予測値）」
      let predictionData = [];

      // 投薬支援マスタ設定「回帰直線項目コード」
      const regressionValue = getRegressionValue(selectedMedicineSupportItem);
      // 回帰直線
      const shien_kaikichokusen = "regression_line";
      // 回帰直線「検査項目（回帰直線）」
      let hasRegression = false;
      // 回帰直線データ「検査項目（回帰直線）」
      let regressionData = [];

      if (isLongPeriod) {
        // マスト情報を処理「情報フラグ設定」
        layout.categoryItem.forEach(category => {
          category.subCategoryItem.forEach(subCategory => {
            if (subCategory.itemNo === shien_yosokuchi) {
              // 予測値
              hasPredictive = true;
            } else if (subCategory.itemNo === shien_kaikichokusen) {
              // 回帰直線
              hasRegression = true;
            }
          });
        });

        if (hasPredictive && predictionValue) {
          // APIの引数作成
          const sendData = {};
          sendData.facility_cd = facilityCd;
          sendData.pat_id = patId;
          sendData.supplies_base_date_begin = startDate.format("YYYYMMDD");
          sendData.supplies_base_date_end = endDate.format("YYYYMMDD");

          const ord = await ApiHelper.post(
            "/mainData/getOrdMaterialSave",
            sendData
          ).catch(err => {
            throw err;
          });
          ordMaterialSave.push(...ord.data);
        }
      }
      // add FNSI-投薬支援仕様更新「予測値」「回帰直線」 周 end

      // add FNSI-グラフ３軸表示対応「IES150」検査結果グラフ分 周 start
      layout.categoryItem.forEach((category, index) => {
        // del FNSI-投薬支援仕様更新「予測値」「回帰直線」 周 start
        // const filterArr = [];
        // del FNSI-投薬支援仕様更新「予測値」「回帰直線」 周 end
        const examResultArr = [];
        // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
        // // 上限値「マスタ情報から取得」
        // let max = category.max ? Number(category.max) : 0;
        // // 下限値「マスタ情報から取得」
        // let min = category.min ? Number(category.min) : 0;
        // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end

        // mod FNSI-投薬支援仕様更新「予測値」「回帰直線」 周 start
        // // グループ条件「マスタ情報から取得」
        // filterArr.push(...category.subCategoryItem.map(p => p.itemNo));
        // // 実績データ「実績情報から取得」
        // for (const examItem of examData) {
        //   if (examItem && examItem.examInfo) {
        //     examResultArr.push(...examItem.examInfo.filter(p => filterArr.includes(p.item_cd)).map(p => p.result));
        //   }
        // }

        category.subCategoryItem.forEach(subCategory => {
          if (hasPredictive && subCategory.itemNo === shien_yosokuchi && predictionValue) {
            // 予測値
            ordMaterialSave.filter(ord => {
              return (
                // データ基準日⇒期間開始日「集計期間計算」
                ord.suppliesBaseDate >= startDate.format("YYYYMMDD") &&
                // データ基準日⇒期間終了日「集計期間計算」
                ord.suppliesBaseDate < endDate.format("YYYYMMDD") &&
                // データ発生元区分「配列存在」
                sourceArr_shien.includes(ord.suppliesSourceClass) &&
                // 物品区分「配列存在」
                suppliesArr_shien_yosokuchi.includes(ord.suppliesClass) &&
                // 物品コード「マスタから取得」
                ord.suppliesCd === predictionValue &&
                // 調製薬剤コード「ヌル固定」
                ord.medicineMixCd === null &&
                // 指示・実績区分「2：実績」固定
                ord.indRstClass === "2" &&
                // 確定フラグ「1：確定」固定
                ord.isConfirm === "1"
              );
            })
              .forEach(ord => {
                predictionData.push([moment(ord.suppliesBaseDate).format("YYYY-MM-DD HH:mm:ss"), Number(ord.indRstValue)]);
                examResultArr.push(Number(ord.indRstValue));
              });
          } else if (hasRegression && subCategory.itemNo === shien_kaikichokusen && regressionValue) {
            // 回帰直線「関数算出」
            const regressionSeries = getGraphDataForRegression(
              moment(endDate).format("YYYYMMDD"),
              period,
              regressionValue,
              examData
            );
            for (let index = 0; (regressionSeries && index < regressionSeries.intDataCnt); index++) {
              if (regressionSeries.dtmDataDate[index]) {
                regressionData.push([moment(regressionSeries.dtmDataDate[index]).format("YYYY-MM-DD HH:mm:ss"), Number(regressionSeries.dblDataValue[index])]);
                examResultArr.push(Number(regressionSeries.dblDataValue[index]));
                // 分割
                if (index % 2 === 1) {
                  regressionData.push([moment(regressionSeries.dtmDataDate[index]).format("YYYY-MM-DD HH:mm:ss"), null]);
                }
              }
            }
          } else {
            // 通常検査項目
            for (const examItem of examData) {
              if (examItem && examItem.examInfo) {
                //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
                // examResultArr.push(...examItem.examInfo.filter(p => subCategory.itemNo === p.item_cd).map(p => p.result));
                // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                // const temp = examItem.examInfo.filter(p => subCategory.itemNo === p.item_cd).map(p => p.result);
                const temp = examItem.examInfo.filter(p => subCategory.itemNo == p.item_cd).map(p => p.result);
                // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
                examResultArr.push(...convertToHalfWidth(temp));
                //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
              }
            }
          }
        });
        // mod FNSI-投薬支援仕様更新「予測値」「回帰直線」 周 end

        // add 12031 患者経過総合ビューアのグラフオートレンジ zkm start
        const {max, min} = getThreshold(category.max, category.min, examResultArr, "line");
        // add 12031 患者経過総合ビューアのグラフオートレンジ zkm end

        // add FNSI-グラフの縦軸表示を修正 周 start
        // 実績情報をクリア
        examResultArr.splice(0, examResultArr.length);
        // add FNSI-グラフの縦軸表示を修正 周 end

        // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
        // // 上限値「実績情報から更新」
        // max = examResultArr.length > 0 ? Math.max(...examResultArr, max) : max;
        // // 下限値「実績情報から更新」
        // min = examResultArr.length > 0 ? Math.min(...examResultArr, min) : min;
        // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end

        // mod FNSI-グラフの縦軸表示を修正 周 start
        // yAxis.push({
        //   labels: { enabled: false },
        //   title: { text: category.subCategoryName },
        //   max: max,
        //   min: min,
        //   tickAmount: 5,
        //   offset: 0
        // });
        yAxis.push({
          labels: { enabled: false },
          title: { text: category.subCategoryName },
          tickPositioner: function() {
            const incrementCount = 4;
            const dataMax = max;
            const dataMin = min;
            const mstFixedCount = Math.max(
              (dataMin != Math.floor(dataMin)) ? (dataMin.toString()).split('.')[1].length : 0,
              (dataMax != Math.floor(dataMax)) ? (dataMax.toString()).split('.')[1].length : 0
            );
            const increment = max - min > 0 ? (max - min) / incrementCount : 0;
            const incrementFixedCount = (increment !== Math.floor(increment)) ? (increment.toString()).split('.')[1].length : 0;
            const incrementFixedMax = 3;

            const fixed = Math.max(Math.min(incrementFixedCount, incrementFixedMax), mstFixedCount);
            const positions = [];
            if (increment > 0) {
              positions.push(Number(dataMin));
              for (let index = 1; index < incrementCount; index++) {
                const valFull = dataMin + index * increment;
                const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
                positions.push(valFloor);
              }
              positions.push(Number(dataMax));
            } else {
              for (let index = 0; index < incrementCount + 1; index++) {
                // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                // positions.push(Number(dataMin + index));`
                const p = dataMin + index;
                positions.push(parseFloat(p.toFixed(3)));
                // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
              }
            }
            return positions;
          },
          offset: 0
        });
        category.subCategoryItem.forEach(subCategory => {
          const seriesData = [];
          if (subCategory.itemNo === shien_yosokuchi) {
            // 予測値
            seriesData.push(...predictionData);
          } else if (subCategory.itemNo === shien_kaikichokusen) {
            // 回帰直線
            seriesData.push(...regressionData);
          }
          series.push({
            yAxis: index,
            yAxisMax: Number(max) - Number(min) > 0 ? Number(max) : Number(min) + 4,
            yAxisMin: min,
            yAxisNo: category.subCategoryNo,
            yAxisName: category.subCategoryName,
            name: subCategory.itemName,
            no: subCategory.itemNo,
            color: subCategory.itemColor,
            marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
            data: seriesData,
            // add #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
            ...(subCategory.hasOwnProperty('itemExamClass') ? { examClass: subCategory.itemExamClass } : {})
            // add #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
          });
        });
      });
      chartData = createChartData(examData);

      let breaks = [];
      let breakDays = [];
      if (period + "" === "1" || period + "" === "2" || period + "" === "3") {
        let days = endDate.diff(startDate, 'days');
        for (let i = 1; i < days; i++) {
          let daytmp = moment(startDate.format("YYYY-MM-DD"));
          daytmp = daytmp.add(i, 'days');
          let strDay = daytmp.format("YYYYMMDD");
          if (!Object.keys(copyTreatmentData).includes(strDay) &&
            !getters.getDateList.includes(strDay)) {
            breakDays.push(strDay);
          }
        }
        let daytmp = "";
        let daytmpS = "";
        breakDays.forEach(breakDay => {
          if (daytmpS === "") {
            daytmpS = breakDay;
          } else {
            if (moment(daytmp).add(1, 'days').format("YYYYMMDD") !== breakDay) {
              let fromD = moment(daytmpS).startOf('day');
              let toD = moment(daytmp).add(1, 'days').startOf('day');
              let breakItem = {
                from: fromD.valueOf(),
                to: toD.valueOf()
              };
              breaks.push(breakItem);
              daytmpS = breakDay;
            }
          }
          daytmp = breakDay;
        });
        if (daytmp !== daytmpS) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
        if (daytmpS !== "" && breaks.length === 0) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
      }
      convertData[0].data.push({
        type: "chart-rst",
        chartData,
        chartXAxisMin: startDate.valueOf(),
        chartXAxisMax: endDate.valueOf(),
        breaks: breaks,
        chartDisplayPeriod: period,
        yAxis: yAxis
      });

      return convertData;
    },

    /**
     * 実績情報
     */
    async convertRstInfo({ getters }, { facilityCd, listIndex, subCategory }) {
      // 加工した表示用データ格納用
      const convertData = [
        {
          itemName: subCategory.subCategoryName,
          itemNo: subCategory.rstCd,
          data: []
        }
      ];

      // 加工した表示用データ表示項目数
      let maxConvertDataLength = convertData.length;

      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex];
      if (!copyTreatmentData) {
        return [];
      }
      // 表示格納用データでループする
      for (let i = 0; i < convertData.length; i++) {
        for (const treatDate in copyTreatmentData) {
          // データセル情報のテンプレートを格納
          const temp = deepCopy(layoutDispData_data);
          // 治療日の格納
          temp.treatDate = treatDate;
          // タイプに実績を格納
          temp.type = "lf";
          // 治療情報
          const ordInfo = copyTreatmentData[treatDate];
          // 治療情報が存在した場合、以下の処理を実行
          if (ordInfo) {
            // オーダー番号を格納
            temp.ordNo = ordInfo.ordNo;
            // 実績コードを格納
            temp.rstCd = subCategory.rstCd;
            
            /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --start */
            // temp.isNotClickable = ordInfo.readOnly;
            temp.isNotClickable = false;
            /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --end */
            // JSONデータ格納用
            const obj = {};

            switch (subCategory.rstCd) {
              // 実績:治療開始日時
              case 1:
                temp.value1 = ordInfo.rstStartDate
                  ? moment(ordInfo.rstStartDate).format("YYYY/MM/DD HH:mm")
                  : null;
                break;

              // 実績:治療終了日時
              case 2:
                temp.value1 = ordInfo.rstEndDate
                  ? moment(ordInfo.rstEndDate).format("YYYY/MM/DD HH:mm")
                  : null;
                break;

              // 実績:入外区分
              case 3:
                if (null !== ordInfo.rstInOutClass) {
                  if (0 === Number(ordInfo.rstInOutClass)) {
                    temp.value1 = "外来";
                  } else if (1 === Number(ordInfo.rstInOutClass)) {
                    temp.value1 = "入院";
                  }
                }
                break;

              // 実績:透析回数
              case 4:
                temp.value1 =
                  null !== ordInfo.rstDialysisCnt
                    ? `${ordInfo.rstDialysisCnt}回`
                    : null;
                break;

              // 実績:DW
              case 5:
                temp.value1 = ordInfo.rstDw ? ordInfo.rstDw : null;
                break;

              // 実績:穿刺者名1(姓+名)
              // 実績:穿刺者名2(姓+名)
              case 6:
              case 7:
                // 穿刺者番号
                obj.num = 6 === subCategory.rstCd ? "1" : "2";
                // 穿刺者情報格納
                if (ordInfo.rstPunctureUserInfo) {
                  obj.rstPunctureUserInfo = JSON.parse(
                    ordInfo.rstPunctureUserInfo
                  );
                  // 穿刺者名_姓
                  obj.lastName = obj.rstPunctureUserInfo[
                    `user_last_name_${obj.num}`
                    ]
                    ? obj.rstPunctureUserInfo[`user_last_name_${obj.num}`]
                    : "";
                  // 穿刺者名_名
                  obj.firstName = obj.rstPunctureUserInfo[
                    `user_first_name_${obj.num}`
                    ]
                    ? obj.rstPunctureUserInfo[`user_first_name_${obj.num}`]
                    : "";
                  // 穿刺者名格納
                  temp.value1 = `${obj.lastName} ${obj.firstName}`;
                }
                break;

              // 実績:穿刺日時
              case 8: {
                // 穿刺日時格納
                const date = JSON.parse(ordInfo?.rstPunctureUserInfo)?.date;
                if (!date) {
                  temp.value1 = null;
                } else {
                  const isValidDate = moment(date, "YYYY-MM-DDTHH:mm:ss.SSSZ", true).isValid();
                  temp.value1 = isValidDate ? moment(date).format(
                      "YYYY/MM/DD HH:mm"
                    ) : date;
                }
                break;
              }

              // 実績:返血者名1(姓+名)
              // 実績:返血者名2(姓+名)
              case 9:
              case 10:
                // 返血者番号
                obj.num = 9 === subCategory.rstCd ? "1" : "2";
                // 返血者情報が入っていれば格納
                if (ordInfo.rstReturnUserInfo) {
                  obj.rstReturnUserInfo = JSON.parse(ordInfo.rstReturnUserInfo);
                  // 返血者名_姓の格納
                  obj.lastName = obj.rstReturnUserInfo[
                    `user_last_name_${obj.num}`
                    ]
                    ? obj.rstReturnUserInfo[`user_last_name_${obj.num}`]
                    : "";
                  // 返血者名_名の格納
                  obj.firstName = obj.rstReturnUserInfo[
                    `user_first_name_${obj.num}`
                    ]
                    ? obj.rstReturnUserInfo[`user_first_name_${obj.num}`]
                    : "";

                  // 返血者名格納
                  temp.value1 = `${obj.lastName} ${obj.firstName}`;
                }
                break;

              // 実績:返血日時
              case 11: {
                // 返血日時格納
                const date = JSON.parse(ordInfo?.rstReturnUserInfo)?.date;
                if (!date) {
                  temp.value1 = null;
                } else {
                  const isValidDate = moment(date, "YYYY-MM-DDTHH:mm:ss.SSSZ", true).isValid();
                  temp.value1 = isValidDate ? moment(date).format(
                      "YYYY/MM/DD HH:mm"
                    ) : date;
                }
                break;
              }

              // 実績:担当者名1(姓+名)
              // 実績:担当者名2(姓+名)
              case 12:
              case 13:
                // 担当者番号
                obj.num = 12 === subCategory.rstCd ? "1" : "2";
                // 担当者情報格納
                if (ordInfo.rstChargeUserInfo) {
                  obj.rstChargeUserInfo = JSON.parse(ordInfo.rstChargeUserInfo);
                  // 担当者名_姓格納
                  obj.lastName = obj.rstChargeUserInfo[
                    `user_last_name_${obj.num}`
                    ]
                    ? obj.rstChargeUserInfo[`user_last_name_${obj.num}`]
                    : "";
                  // 担当者名_名格納
                  obj.firstName = obj.rstChargeUserInfo[
                    `user_first_name_${obj.num}`
                    ]
                    ? obj.rstChargeUserInfo[`user_first_name_${obj.num}`]
                    : "";

                  // 担当者名
                  temp.value1 = `${obj.lastName} ${obj.firstName}`;
                }
                break;

              // 実績:透析運転時間
              case 14:
                temp.value1 = ordInfo.rstRunningTime
                  ? `${ordInfo.rstRunningTime} 分`
                  : null;
                break;

              // 実績:Kt/V
              case 15:
                temp.value1 = ordInfo.rstKtV
                  // mod #IES_6501 dou start
                  // ? Number(ordInfo.rstKtV).toFixed(2)
                  ? toFixed(Number(ordInfo.rstKtV), 2)
                  // mod #IES_6501 dou end
                  : null;
                break;

              // 実績:透析記録確認日時
              case 16:
                temp.value1 = ordInfo.recSetDate
                  ? moment(ordInfo.recSetDate).format("YYYY/MM/DD HH:mm")
                  : null;
                break;

              // 実績:送信管理番号
              case 17:
                temp.value1 = ordInfo.sendCtlNo ? ordInfo.sendCtlNo : null;
                break;

              // 血液浄化装置名称
              case 18:
                temp.value1 = ordInfo.bloodPurifierName
                  ? ordInfo.bloodPurifierName
                  : null;
                break;

              // 実績:I-HDF引き残し量
              case 19:
                /*mod FNSI-改修内容5394 任 start*/
                /*temp.value1 = ordInfo.pullLeaveAmount
                  ? `${ordInfo.pullLeaveAmount.toFixed(2)} L`
                  : null;*/
                const indfPll = JSON.parse(ordInfo.rstWeightInfo) ? JSON.parse(ordInfo.rstWeightInfo).ihdf_pll : null
                temp.value1 = indfPll
                  // mod #IES_6501 dou start
                  // ? `${Number(indfPll).toFixed(2)} L`
                  ? `${toFixed(Number(indfPll), 2)} L`
                  // mod #IES_6501 dou end
                  : null;
                /*mod FNSI-改修内容5394 任 end*/
                break;


              // 実績:透析前体重測定値
              case 20:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 透析前体重測定値を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                    .weight_measure_before
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(ordInfo.rstWeightInfo).weight_measure_before).toFixed(
                    //   2
                    // )} kg`
                    ? `${toFixed(Number(JSON.parse(ordInfo.rstWeightInfo).weight_measure_before), 2)} kg`
                    // mod #IES_6501 dou end
                    : null;
                }
                break;

              // 実績:透析前体重
              case 21:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 透析前体重を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo).weight_before
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(
                    //   ordInfo.rstWeightInfo
                    // ).weight_before).toFixed(2)} kg`
                    ? `${toFixed(Number(JSON.parse(ordInfo.rstWeightInfo).weight_before), 2)} kg`
                    // mod #IES_6501 dou end
                    : null;
                }
                break;

              // 実績:前体重測定日時
              case 22:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 前体重測定日時を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                    .weight_before_date
                    ? moment(
                      JSON.parse(ordInfo.rstWeightInfo).weight_before_date
                    ).format("YYYY/MM/DD HH:mm")
                    : null;
                }
                break;

              // 実績:透析後体重測定
              case 23:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 透析後体重測定を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                    .weight_measure_after
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(ordInfo.rstWeightInfo).weight_measure_after).toFixed(
                    //   2
                    // )} kg`
                    ? `${toFixed(Number(JSON.parse(ordInfo.rstWeightInfo).weight_measure_after), 2)} kg`
                    // mod #IES_6501 dou end
                    : null;
                }
                break;

              // 実績:透析後体重
              case 24:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 透析後体重を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo).weight_after
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(ordInfo.rstWeightInfo).weight_after).toFixed(
                    ? `${toFixed(Number(JSON.parse(ordInfo.rstWeightInfo).weight_after),
                      // mod #IES_6501 dou end
                      2
                    )} kg`
                    : null;
                }
                break;

              // 実績:後体重測定日時
              case 25:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 後体重測定日時を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                    .weight_after_date
                    ? moment(
                      JSON.parse(ordInfo.rstWeightInfo).weight_after_date
                    ).format("YYYY/MM/DD HH:mm")
                    : null;
                }
                break;

              // 実績:CTR
              case 26:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // CTRを格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo).ctr
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(ordInfo.rstWeightInfo).ctr).toFixed(
                    ? `${toFixed(Number(JSON.parse(ordInfo.rstWeightInfo).ctr),
                      // mod #IES_6501 dou end
                      2
                    )} %`
                    : null;
                }
                break;

              // 実績:CTR測定日時
              case 27:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // CTR測定日時を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo).ctr_measure_date
                    ? moment(JSON.parse(ordInfo.rstWeightInfo).ctr_measure_date).format("YYYY/MM/DD HH:mm")
                    : null;
                  break;
                }
                break;

              // 実績:CTR測定時体重
              case 28:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // CTR測定時体重を格納
                  const rstWeightInfo = JSON.parse(ordInfo.rstWeightInfo);
                  //mod FNSI-7134 劉全航 start
                  // temp.value1 = _.has(rstWeightInfo, "ctr_weight")
                  // ? `${rstWeightInfo.ctr_weight.toFixed(2)} kg`
                  // : null;
                  temp.value1 = rstWeightInfo.ctr_weight
                    // mod #IES_6501 dou start
                    // ? `${Number(rstWeightInfo.ctr_weight).toFixed(2)} kg`
                    ? `${toFixed(Number(rstWeightInfo.ctr_weight), 2)} kg`
                    // mod #IES_6501 dou end
                    : null;
                  //mod FNSI-7134 劉全航 end
                }
                break;

              // 実績:目標除水量
              case 29:
                // 体重情報が格納されている場合以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 目標除水量を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                    .water_removal_target
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(
                    //   ordInfo.rstWeightInfo
                    // ).water_removal_target).toFixed(2)} L`
                    ? `${toFixed(Number(JSON.parse(
                      ordInfo.rstWeightInfo
                    ).water_removal_target), 2)} L`
                    // mod #IES_6501 dou end
                    : null;
                }
                break;

              // 実績:実績除水量
              case 30:
                // 体重情報が格納されていれば以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 実績除水量を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                    .water_removal_rst
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(
                    //   ordInfo.rstWeightInfo
                    // ).water_removal_rst).toFixed(2)} L`
                    ? `${toFixed(Number(JSON.parse(
                      ordInfo.rstWeightInfo
                    ).water_removal_rst), 2)} L`
                    // mod #IES_6501 dou end
                    : null;
                }
                break;

              // 実績:除水積算量
              case 31:
                // 体重情報が格納されていれば以下の処理を実施
                // 除水積算量を格納
                //add 5928除水積算量の表示不正 張 start
                // temp.value1 = waterRemoval(ordInfo)
                switch (ordInfo.rstDialysisState) {
                  case "0":
                    temp.value1 = null
                    break;
                  case "1":
                    temp.value1 = "0.00L"
                    break;
                  case "2":
                    temp.value1 = "0.00L"
                    break;
                  case "3":
                    let mntMachineStateTmp = getters.getMntMachineStates.filter(item => {
                      return item.ordNo == ordInfo.ordNo;
                    });
                    let mntMachineStateResponse = mntMachineStateTmp[0].mntMachineState;
                    //mod 2023-03-24 7134 患者経過総合ビューアを開くとデベロッパーツールでエラー発生 張 start
                    // temp.value1 = JSON.parse(mntMachineStateResponse.data.monitorData)["5"]
                    //   ? `${Number(JSON.parse(mntMachineStateResponse.data.monitorData)["5"]).toFixed(2)} L`
                    //   : "0.00L"
                    //mod 9694 未登録患者に医療材料を追加できない zy start
                    // temp.value1 = JSON.parse(mntMachineStateResponse.data[0].monitorData)["5"]
                    temp.value1 = mntMachineStateResponse.data[0]?JSON.parse(mntMachineStateResponse.data[0].monitorData)["5"]
                      // mod #IES_6501 dou start
                      // ? `${Number(JSON.parse(mntMachineStateResponse.data[0].monitorData)["5"]).toFixed(2)} L`
                      ? `${toFixed(Number(JSON.parse(mntMachineStateResponse.data[0].monitorData)["5"]),2)} L`
                      // mod #IES_6501 dou end
                      // : "0.00L"
                      : "0.00L":"0.00L"
                    //mod 9694 未登録患者に医療材料を追加できない zy end
                    //mod 2023-03-24 7134 患者経過総合ビューアを開くとデベロッパーツールでエラー発生 張 end
                    break;
                  case "4":
                    temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                      .water_removal_rst
                      // mod #IES_6501 dou start
                      // ? `${Number(JSON.parse(
                      //   ordInfo.rstWeightInfo
                      // ).water_removal_rst).toFixed(2)} L`
                      ? `${toFixed(Number(JSON.parse(
                        ordInfo.rstWeightInfo
                      ).water_removal_rst), 2)} L`
                      // mod #IES_6501 dou end
                      : null
                    break;
                  case "5":
                    temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                      .water_removal_rst
                      // mod #IES_6501 dou start
                      // ? `${Number(JSON.parse(
                      //   ordInfo.rstWeightInfo
                      // ).water_removal_rst).toFixed(2)} L`
                      ? `${toFixed(Number(JSON.parse(
                        ordInfo.rstWeightInfo
                      ).water_removal_rst),2)} L`
                      // mod #IES_6501 dou end
                      : null
                    break;
                  case "6":
                    temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                      .water_removal_rst
                      // mod #IES_6501 dou start
                      // ? `${Number(JSON.parse(
                      //   ordInfo.rstWeightInfo
                      // ).water_removal_rst).toFixed(2)} L`
                      ? `${toFixed(Number(JSON.parse(
                        ordInfo.rstWeightInfo
                      ).water_removal_rst), 2)} L`
                      // mod #IES_6501 dou end
                      : null
                    break;

                  default:
                    break;
                }
                //add 5928除水積算量の表示不正 張 end
                break;

              // 実績:補液積算量
              case 32:
                // 体重情報が格納されていれば以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 補液積算量を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo)
                    .add_water_total
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(ordInfo.rstWeightInfo).add_water_total).toFixed(
                    ? `${toFixed(Number(JSON.parse(ordInfo.rstWeightInfo).add_water_total),
                      // mod #IES_6501 dou end
                      2
                    )} L`
                    : null;
                }
                break;

              // 実績:Kt/V測定値
              case 33:
                // 体重情報が格納されていれば以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // Kt/V測定値を格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo).kt_v_measure
                    // mod #IES_6501 dou start
                    // ? Number(JSON.parse(ordInfo.rstWeightInfo).kt_v_measure).toFixed(2)
                    ? toFixed(Number(JSON.parse(ordInfo.rstWeightInfo).kt_v_measure), 2)
                    // mod #IES_6501 dou end
                    : null;
                }
                break;

              // 実績:URR
              case 34:
                // 体重情報が格納されていれば以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // URRを格納
                  temp.value1 = JSON.parse(ordInfo.rstWeightInfo).urr
                    // mod #IES_6501 dou start
                    // ? `${Number(JSON.parse(ordInfo.rstWeightInfo).urr).toFixed(
                    ? `${toFixed(Number(JSON.parse(ordInfo.rstWeightInfo).urr),
                      // mod #IES_6501 dou end
                      2
                    )} %`
                    : null;
                }
                break;
              //実績:再循環率
              case 45:
                if (ordInfo.rstWeightInfo) {
                  if (JSON.parse(ordInfo.rstWeightInfo).recrcl_rt) {
                    let no = JSON.parse(ordInfo.rstWeightInfo).recrcl_rt.valid_no;
                    if (no > 0) {
                      let value = JSON.parse(ordInfo.rstWeightInfo).recrcl_rt[no].rate;
                      // mod #IES_6501 dou start
                      // temp.value1 = `${Number(value).toFixed(2)}%`;
                      temp.value1 = `${toFixed(Number(value),2)}%`;
                      // mod #IES_6501 dou end
                    } else {
                      temp.value1 = null;
                    }
                  } else {
                    temp.value1 = null;
                  }
                }
                break;
              // 実績:減少量
              case 35:
                // 体重情報が格納されていれば以下の処理を実行
                if (ordInfo.rstWeightInfo) {
                  // 減少量を格納
                  let weightDecreased = JSON.parse(ordInfo.rstWeightInfo).weight_decreased
                  temp.value1 = weightDecreased
                    // mod #IES_6501 dou start
                    // ? `${Number(weightDecreased).toFixed(2)} kg`
                    ? `${toFixed(Number(weightDecreased),2)} kg`
                    // mod #IES_6501 dou end
                    : null;
                }
                break;

              // 実績:前血圧
              // 実績:後血圧
              case 36:
              case 37:
                // 血圧クラスを格納
                obj.bp_class = 36 === subCategory.rstCd ? 1 : 2;
                if (ordInfo.rstVitalInfo) {
                  // バイタル情報を格納
                  obj.rstWeightInfo = JSON.parse(ordInfo.rstVitalInfo);
                  obj.rstWeightInfo.forEach(eleItem => {
                    // 発生日時が格納されておりかつ、血圧区分が一致する場合以下の処理
                    if (
                      obj.occur_date &&
                      obj.bp_class === Number(eleItem.bp_class)
                    ) {
                      // 発生日時が前回格納時の発生日時より新しい場合格納
                      if (eleItem.occur_date > obj.occur_date) {
                        // 発生日時の格納
                        obj.occur_date = eleItem.occur_date;
                        // 最高血圧の格納
                        obj.bp_max = eleItem.bp_max;
                        // 最低血圧の格納
                        obj.bp_min = eleItem.bp_min;
                        // 平均血圧の格納
                        obj.bp_ave = eleItem.bp_ave;
                      }
                    } else if (obj.bp_class === Number(eleItem.bp_class)) {
                      // 発生日時の格納
                      obj.occur_date = eleItem.occur_date;
                      // 最高血圧の格納
                      obj.bp_max = eleItem.bp_max;
                      // 最低血圧の格納
                      obj.bp_min = eleItem.bp_min;
                      // 平均血圧の格納
                      obj.bp_ave = eleItem.bp_ave;
                    }
                  });
                }

                if (ordInfo && ordInfo.rstDialysisState != '0') {
                  /*add FNSI-改修内容5394 任 start*/
                  /* upd by chamaojia 2026-03-20 [12462] 患者情報共有->患者経過総合ビューア --start */
                  // const vitalMonitor = await sendRequestGetTreatmentRecordVitalMonitor(facilityCd, ordInfo.ordNo);
                  const vitalMonitor = await sendRequestGetTreatmentRecordVitalMonitor(ordInfo.facilityCd, ordInfo.ordNo);
                  /* upd by chamaojia 2026-03-20 [12462] 患者情報共有->患者経過総合ビューア --end */
                  if (vitalMonitor.data.length > 0) {
                    if (obj.bp_class === 1) {
                      //前
                      vitalMonitor.data.forEach(item => {
                        if (item.data_type === 5) {
                          // mod 7763 患者経過総合ビューアの前血圧，後血圧が平均血圧しか表示されない 関 start
                          // temp.value1 = JSON.parse(item.monitor_data)[92];
                          const highest = (JSON.parse(item.monitor_data)[90] === undefined) ? "-":JSON.parse(item.monitor_data)[90];
                          const minimum = (JSON.parse(item.monitor_data)[91] === undefined) ? "-":JSON.parse(item.monitor_data)[91];
                          const average = (JSON.parse(item.monitor_data)[92] === undefined) ? "-":JSON.parse(item.monitor_data)[92];
                          const pulsebeat = (JSON.parse(item.monitor_data)[93] === undefined) ? "-":JSON.parse(item.monitor_data)[93];
                          temp.value1 = highest + "/" + minimum + "/" + average + "　" + pulsebeat;
                          // mod 7763 患者経過総合ビューアの前血圧，後血圧が平均血圧しか表示されない 関 end
                        }
                      })
                    } else {
                      vitalMonitor.data.forEach(item => {
                        if (item.data_type === 6) {
                          // mod 7763 患者経過総合ビューアの前血圧，後血圧が平均血圧しか表示されない 関 start
                          // temp.value1 = JSON.parse(item.monitor_data)[92];
                          const highest = (JSON.parse(item.monitor_data)[90] === undefined) ? "-":JSON.parse(item.monitor_data)[90];
                          const minimum = (JSON.parse(item.monitor_data)[91] === undefined) ? "-":JSON.parse(item.monitor_data)[91];
                          const average = (JSON.parse(item.monitor_data)[92] === undefined) ? "-":JSON.parse(item.monitor_data)[92];
                          const pulsebeat = (JSON.parse(item.monitor_data)[93] === undefined) ? "-":JSON.parse(item.monitor_data)[93];
                          temp.value1 = highest + "/" + minimum + "/" + average + "　" + pulsebeat;
                          // mod 7763 患者経過総合ビューアの前血圧，後血圧が平均血圧しか表示されない 関 end
                        }
                      })
                    }
                  }
                  /*add FNSI-改修内容5394 任 end*/
                }
                // 前血圧の格納
                /*del FNSI-改修内容5394 任 start*/
                /*temp.value1 = obj.occur_date
                  ? `${obj.bp_max} / ${obj.bp_min} / ${obj.bp_ave}`
                  : null;*/
                /*del FNSI-改修内容5394 任 end*/
                break;

              // 体温(1回目)
              // 体温(最終)
              case 38:
              case 39:
                if (ordInfo.rstVitalInfo) {
                  // バイタル情報の格納
                  obj.rstVitalInfo = JSON.parse(ordInfo.rstVitalInfo);
                  // バイタル情報の要素数分ループ
                  obj.rstVitalInfo.forEach(eleItem => {
                    // バイタル情報の要素を変換処理
                    obj.tempInfo = eleItem;
                    // 発生日時が格納されている場合
                    if (obj.occur_date) {
                      // 体温(1回目)を格納する場合
                      if (38 === subCategory.rstCd) {
                        // 発生日時が前回格納時の発生日時より古い場合格納
                        if (obj.occur_date > obj.tempInfo.occur_date) {
                          // 発生日時の格納
                          obj.occur_date = obj.tempInfo.occur_date;
                          // 体温の格納
                          obj.temperature = obj.tempInfo.temperature;
                        }
                        // 体温(最終)を格納する場合
                      } else {
                        // 発生日時が前回格納時の発生日時より新しい場合格納
                        if (obj.tempInfo.occur_date > obj.occur_date) {
                          // 発生日時の格納
                          obj.occur_date = obj.tempInfo.occur_date;
                          // 体温の格納
                          obj.temperature = obj.tempInfo.temperature;
                        }
                      }
                    } else {
                      // 発生日時の格納
                      obj.occur_date = obj.tempInfo.occur_date;
                      // 体温の格納
                      obj.temperature = obj.tempInfo.temperature;
                    }
                  });
                  temp.value1 = obj.temperature
                    // mod #IES_6501 dou start
                    // ? `${Number(obj.temperature).toFixed(2)}℃`
                    ? `${toFixed(Number(obj.temperature), 2)}℃`
                    // mod #IES_6501 dou end
                    : null;
                }

                if (ordInfo && ordInfo.rstDialysisState != '0') {
                  /* upd by chamaojia 2026-03-20 [12462] 患者情報共有->患者経過総合ビューア --start */
                  // const vitalMonitor = await sendRequestGetTreatmentRecordVitalMonitor(facilityCd, ordInfo.ordNo);
                  const vitalMonitor = await sendRequestGetTreatmentRecordVitalMonitor(ordInfo.facilityCd, ordInfo.ordNo);
                  /* upd by chamaojia 2026-03-20 [12462] 患者情報共有->患者経過総合ビューア --end */
                  /*add FNSI-改修内容5394 任 start*/
                  if (vitalMonitor.data.length > 0) {
                    //mod FNSI-5394 劉全航 start
                    var dataObjectList = [];
                    for (let o of vitalMonitor.data) {
                      let obj = JSON.parse(o.monitor_data);
                      let itemNameList = Object.keys(obj);
                      if (itemNameList.includes("94")) {
                        dataObjectList.push(obj);
                      }
                    }
                    // #9439 患者経過総合ビューアでTypeエラー発生 zihao start
                    if (dataObjectList.length > 0) {
                    //mod FNSI-5394 劉全航 end
                      if (38 === subCategory.rstCd) {
                        //mod FNSI-5394 劉全航 start
                        // mod #IES_6501 dou start
                        // temp.value1 = `${Number(dataObjectList[0][94]).toFixed(2)}℃`;
                        temp.value1 = `${toFixed(Number(dataObjectList[0][94]), 2)}℃`;
                        // mod #IES_6501 dou end
                        // temp.value1 = JSON.parse(vitalMonitor.data[0].monitor_data)[94] ? `${Number(JSON.parse(vitalMonitor.data[0].monitor_data)[94]).toFixed(2)}℃` : null;
                        //mod FNSI-5394 劉全航 end
                      } else {
                        //mod FNSI-5394 劉全航 start
                        // mod #IES_6501 dou start
                        // temp.value1 = `${Number(dataObjectList[dataObjectList.length - 1][94]).toFixed(2)}℃`;
                        temp.value1 = `${toFixed(Number(dataObjectList[dataObjectList.length - 1][94]),2)}℃`;
                        // mod #IES_6501 dou end
                        // temp.value1 = JSON.parse(vitalMonitor.data[vitalMonitor.data.length-1].monitor_data)[94] ? `${Number(JSON.parse(vitalMonitor.data[vitalMonitor.data.length-1].monitor_data)[94]).toFixed(2)}℃` : null;
                        //mod FNSI-5394 劉全航 end
                      }
                    }
                    // #9439 患者経過総合ビューアでTypeエラー発生 zihao end
                  }
                  /*add FNSI-改修内容5394 任 end*/
                }
                break;

              // 愁訴処置情報(薬剤名、数量、単位)
              case 40:
                // 愁訴処置情報の格納
                obj.rstTreatmentInfo = JSON.parse(ordInfo.rstTreatmentInfo);
                // 愁訴処置情報がnullでない場合
                if (null !== obj.rstTreatmentInfo) {
                  // 実績：愁訴情報の格納
                  obj.rstComplaintInfo = JSON.parse(ordInfo.rstComplaintInfo);
                  const controlData = [];
                  var complaintData={};
                  const subCategoryItems = [];
                  const subCategoryItems2 = [];
                  let subCategoryItems3 = false;
                  let subCategoryItems4 = false;
                  subCategory.subCategoryItem.forEach(subCategoryItem => {
                    if (subCategoryItem.complaintClassify + "" === "1") {
                      subCategoryItems.push(subCategoryItem.itemName);
                    }
                    if (subCategoryItem.complaintClassify + "" === "2") {
                      subCategoryItems2.push(subCategoryItem.itemNo);
                    }
                    if (subCategoryItem.complaintClassify + "" === "3") {
                      subCategoryItems3 = true;
                    }
                    if (subCategoryItem.complaintClassify + "" === "4") {
                      subCategoryItems4 = true;
                    }
                  })
                  obj.rstComplaintInfo.forEach(item => {
                    const existControl = controlData.find(treatment => {
                      return (
                        item.ctl_no === treatment.ctl_no && item.row_no === treatment.row_no
                      );
                    });

                    const categoryItem = subCategory.subCategoryItem.find(i => {
                      return (
                        item.complaint === i.itemName
                      );
                    });
                    let names = "";
                    if (categoryItem) {
                      if (!existControl) {
                        names = item.complaint + "、\n";
                        controlData.push({
                          occur_date: item.occur_date,
                          ctl_no: item.ctl_no,
                          row_no: item.row_no,
                          treat_cd: item.treat_cd,
                          treat_name: item.treat_name,
                          complaint: names != "" ? names.substring(0, names.length - 2) : "未登録"
                        });
                        const existComplaint = obj.rstComplaintInfo.filter(complaint => {
                          return (
                            item.ctl_no === complaint.ctl_no && subCategoryItems.includes(complaint.complaint)
                          );
                        });
                        var complaint=false;
                        existComplaint.forEach(i => {
                          if (i.complaint) {
                            let treat_name = "";
                            let treat_medicine_name = ""
                            const rstInfo = obj.rstTreatmentInfo;
                            for (let i0 = 0; i0 < rstInfo.length; i0++) {
                              complaint=false;
                              complaintData = {};
                              complaintData.iscomplaint = complaint;
                              if (i.ctl_no === rstInfo[i0].ctl_no && subCategoryItems2.includes(rstInfo[i0].treat_cd + "")) {
                                treat_name = "";
                                if (rstInfo[i0].treat_name != null) {
                                  treat_name = rstInfo[i0].treat_name;
                                }
                                if (rstInfo[i0].treat_medicine_name != null) {
                                  complaint=true;
                                  treat_medicine_name = "";
                                  complaintData.amount = rstInfo[i0].amount;
                                  complaintData.procedure_name =  rstInfo[i0].procedure_name;
                                  complaintData.treat_medicine_name = rstInfo[i0].treat_medicine_name;
                                  complaintData.unit = rstInfo[i0].unit;
                                  complaintData.iscomplaint = complaint;

                                  names = treat_name + " " + treat_medicine_name + "、\n";

                                }
                                names = treat_name  + "、\n";
                                controlData.push({
                                  occur_date: item.occur_date,
                                  ctl_no: item.ctl_no,
                                  row_no: item.row_no,
                                  treat_cd: item.treat_cd,
                                  treat_name: item.treat_name,
                                  complaintData:JSON.parse(JSON.stringify(complaintData)),
                                  complaint: names != "" ? names.substring(0, names.length - 2) : "未登録"
                                });
                              }
                            }
                          }
                        })
                      }
                    }
                  });
                  if (subCategoryItems3) {
                    obj.rstTreatmentInfo.forEach(item => {
                      if (item.treat_class == 4) {
                        let text = "";
                        if (item.electrocardiogram_start !== null) {
                          text = '心電図測定開始';
                        } else {
                          text = '心電図測定終了';
                        }
                        controlData.push({
                          occur_date: item.occur_date,
                          ctl_no: item.ctl_no,
                          row_no: item.row_no,
                          treat_cd: item.treat_cd,
                          treat_name: item.treat_name,
                          complaint: text
                        });
                      }
                    });
                  }
                  if (subCategoryItems4) {
                    obj.rstTreatmentInfo.forEach(item => {
                      if (item.treat_class == 3) {
                        let text = "";
                        if (item.oxygen_start !== null) {
                          let textTmp = "酸素吸入開始";
                          if (item.oxygen_speed) {
                            textTmp = textTmp + " " + toFixed(Number(item.oxygen_speed),2) + "L/min";
                          }
                          text = textTmp;
                        } else {
                          let textTmp = "酸素吸入終了";
                          if (item.oxygen_amount) {
                            textTmp = textTmp + " " + toFixed(Number(item.oxygen_amount), 2) + "L";
                          }
                          text = textTmp;
                        }
                        controlData.push({
                          occur_date: item.occur_date,
                          ctl_no: item.ctl_no,
                          row_no: item.row_no,
                          treat_cd: item.treat_cd,
                          treat_name: item.treat_name,
                          complaint: text
                        });
                      }
                    });
                  }
                  // 内容を格納
                  temp.value1 =
                    controlData[i] ?
                      moment(controlData[i].occur_date).format('HH:mm') + " " + controlData[i].complaint :
                      "";
                  temp.value2 =controlData[i];

                  // 最大表示項目数を格納
                  maxConvertDataLength =
                    controlData.length > maxConvertDataLength
                      ? controlData.length
                      : maxConvertDataLength;

                  // 表示項目数が最大表示項目数と一致するように項目を追加
                  if (convertData.length < maxConvertDataLength) {
                    convertData.push({
                      itemName: "",
                      itemNo: subCategory.rstCd,
                      data: []
                    });
                  }
                }

                break;

              // 実績:回診記録情報((タイトル)、内容)
              case 41:
                if (ordInfo.rstRoundsInfo) {
                  // 回診記録情報を格納
                  obj.rstRoundsInfo = JSON.parse(ordInfo.rstRoundsInfo);

                  // add FNSI-回診記録を追加 李 start
                  if (!obj.rstRoundsInfo.length) {
                    // 内容を格納
                    temp.value1 = moment(obj.rstRoundsInfo.reg_date_time).format('HH:mm');
                    temp.isRstRoundsFlg = true;
                  } else {
                    // add FNSI-回診記録を追加 李 end
                    // 最大表示項目数を格納
                    maxConvertDataLength =
                      obj.rstRoundsInfo.length > maxConvertDataLength
                        ? obj.rstRoundsInfo.length
                        : maxConvertDataLength;
                    // 表示項目数が最大表示項目数と一致するように項目数を追加
                    for (
                      let j = 0;
                      j < maxConvertDataLength - convertData.length;
                      j++
                    ) {
                      convertData.push({
                        itemName: subCategory.subCategoryName,
                        itemNo: subCategory.rstCd,
                        data: []
                      });
                    }
                    // 内容を格納
                    temp.value1 = JSON.parse(obj.rstRoundsInfo[i]).content;
                  }
                }
                break;
              /*mod FNSI-改修内容5394 任 start*/
              case 43:
                if (JSON.parse(ordInfo.rstWeightInfo)) {
                  const sttcVnsPrssr = JSON.parse(ordInfo.rstWeightInfo).sttc_vns_prssr
                  temp.value1 = sttcVnsPrssr
                    ? `${sttcVnsPrssr} mmHg`
                    : null;
                }
                break;
              case 44:
                if (JSON.parse(ordInfo.rstWeightInfo)) {
                  const iapRt = JSON.parse(ordInfo.rstWeightInfo).iap_rt
                  temp.value1 = iapRt
                    ? `${iapRt} %`
                    : null;
                }
                break;
              /*mod FNSI-改修内容5394 任 end*/
              case 46:
                if (JSON.parse(ordInfo.additionInfo)) {
                  const additionInfo = JSON.parse(ordInfo.additionInfo);
                  temp.value1 = additionInfo;
                  temp.dataItem = 1;
                }
                break;

              // 異常値
              default:
                break;
            }
          }
          convertData[i].data.push(temp);
        }
      }
      return convertData;
    },

    /**
     * 患者経過総合ビューアテンプレートマスタから指定したカテゴリ・サブカテゴリの情報を取得
     * @summary 'getDispLayoutItemList'が実行され、患者経過総合ビューアテンプレートマスタ情報がstateにcommitされている状態時に実行可能
     * @param {number} layoutCd
     * @param {number} categoryNo
     * @param {number} subCategoryNo
     */
    getDispLayoutItemForSubCategory(
      { getters },
      { layoutCd, categoryNo, subCategoryNo }
    ) {
      // 検索用表示項目リスト(引数のlayoutCdから表示項目情報を抽出)
      const filter1 = deepCopy(getters.getDispLayoutItemListData).find(item => {
        return layoutCd === item.layoutCd;
      });

      if (!filter1 || !filter1.dispItemInfo) {
        return [];
      }

      // 引数のカテゴリ番号のカテゴリを抽出
      const filter2 = filter1.dispItemInfo.find(item => {
        return categoryNo === item.categoryNo;
      });

      if (!filter2 || !filter2.categoryItem || 0 === filter2.categoryItem.length) {
        return [];
      }

      // 引数のサブカテゴリ番号のサブカテゴリを抽出
      const filter3 = filter2.categoryItem.find(item => {
        return subCategoryNo === item.subCategoryNo;
      });

      if (!filter3.subCategoryItem || 0 === filter3.subCategoryItem.length) {
        return [];
      }

      // 表示項目リストの返却
      return filter3.subCategoryItem;
    },

    /**
     * 治療状況によるメッセージや画面表示情報を取得
     * @param {String} stateCd 治療状況(ord_main.rst_dialysis_state)
     * @returns {Object} data dispData: 画面(一覧)に表示する文言、message: 実際の状況の文言
     */
    getDialysisStateMessage(context, stateCd) {
      // 戻り値
      const data = { dispData: "", message: "" };

      // 治療状況により分岐
      switch (stateCd) {
        case "0":
          // 条件送信前
          data.dispData = "PNG0"
          data.message = "条件送信前";
          break;

        case "1":
          // 条件送信済み
          data.dispData = "PNG1"
          data.message = "条件送信済み";
          break;

        case "2":
          // 条件送信確認済み
          data.dispData = "PNG2"
          data.message = "条件送信確認済み";
          break;

        case "3":
          // 治療中
          data.dispData = "PNG3"
          data.message = "治療中";
          break;

        case "4":
          // 排液済み
          data.dispData = "PNG4"
          data.message = "排液済み";
          break;

        case "5":
          // 後体重測定済み(実績未確定)
          data.dispData = "PNG5"
          data.message = "後体重測定済み";
          break;

        case "6":
          // 後体重確認済み(過去実績)
          data.dispData = "PNG6"
          data.message = "後体重確認済み";
          break;

        default:
          // 異常なステータス
          break;
      }

      return data;
    },

    /**
     * 指定コードのマスタ情報をstateから取得
     * @param {Number} mstClass 対象マスタ区分(1:治療方法マスタ、2:クールマスタ、…)
     * @param {Number} code 取得対象のコード
     * @param {String} notExistReturnValue マスタに存在しない場合に画面に表示する文言(例: "削除済み")
     * @param {Interger} classType 薬剤の分類（0: 未分類 1:抗凝固剤 2:透析液 3:補液）
     * @param {String} treatDate 治療日
     * @returns {Object} 対象コードのマスタ情報(マスタにより内容が異なる)
     */
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // getMstRecordInState({ getters }, { mstClass, code, notExistReturnValue }) {
    getMstRecordInState({ getters }, { mstClass, code, notExistReturnValue, classType, treatDate }) {
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // マスタにより欲しい情報が異なるため、戻り値の形式はObject形式とする
      // 例)
      //   { name: "マスタ名" }
      //   { name: "マスタ名", unit: "単位" }
      //   { name: "マスタ名", unit: "単位", mediClass: "" }
      const translationData = {};
      let mstRecord;
      let mstRecordSub;
      // add FNSI-期限切れ削除済みと表示するの修正 李 start
      let mstRecordDel;
      const MedicineString = "medicineDel";
      // add FNSI-期限切れ削除済みと表示するの修正 李 end
      switch (mstClass) {
        case 1:
          // 治療方法マスタ
          mstRecord = getters.getMstTreatmentData.find(mstData => {
            return mstData.treatmentCd === code;
          });
          if (!mstRecord) {
            translationData.name = notExistReturnValue;
          } else {
            translationData.name = mstRecord.treatmentName;
          }
          return translationData;

        case 2:
          // クールマスタ
          mstRecord = getters.getMstKurData.find(mstData => {
            return mstData.kurCd === code;
          });
          if (!mstRecord) {
            translationData.name = notExistReturnValue;
          } else {
            translationData.name = mstRecord.kurName;
          }
          return translationData;

        case 3:
          // ベッドマスタ
          mstRecord = getters.getMstBedData.find(mstData => {
            return mstData.bedCd === code;
          });
          //mod no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 start
          // if (!mstRecord) {
          //   translationData.name = notExistReturnValue;
          // } else {
          //   translationData.name = mstRecord.bedName;
          // }
          const badInfo = getters.getMstAllBed.find(bed => {
            return bed.bedCd === code;
          });
          if (!mstRecord) {
            translationData.name = notExistReturnValue+badInfo.bedName;
          } else {
            // mod #8187 2022/12/19 装置マスタから装置を削除した際に割付いているスケジュールのベッド名が不正 dou start
            // translationData.name = badInfo.bedName;
            if (getters.getBedAndMachine.some(bed => bed.bedCd === code)) {
              translationData.name = badInfo.bedName;
            } else {
              translationData.name = notExistReturnValue + badInfo.bedName;
            }
            // mod #8187 2022/12/19 装置マスタから装置を削除した際に割付いているスケジュールのベッド名が不正 dou end
          }
          //mod no4878 メイン画面と編集画面で削除済み、期限切れ、分類不一致、禁忌アレルギーの接頭付けが一致していない 張 end
          return translationData;

        case 4:
          // VAマスタ
          mstRecord = getters.getMstVaData.find(mstData => {
            return mstData.vaCd == code;  // mod #9973 value Number→文字列  shiyw
          });
          if (!mstRecord) {
            // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 start
            const mstDelRecord = getters.getMstVaDelData.find(mstData => {
              return mstData.vaCd == code;
            });
            if (mstDelRecord) translationData.name = '【' + notExistReturnValue + '】' + mstDelRecord.vaName;
            else translationData.name = notExistReturnValue;
            // translationData.name = notExistReturnValue;
            // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 end
          } else {
            translationData.name = mstRecord.vaName;
          }
          return translationData;

        case 5:
          // ダイアライザマスタ
          mstRecord = getters.getMstDialyzerData.find(mstData => {
            return mstData.dialyzerCd == code; // mod #9973 value Number→文字列  shiyw
          });
          if (!mstRecord) {
            // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 start
            const mstDelRecord = getters.getMstDialyzerDelData.find(mstData => {
              return mstData.dialyzerCd == code;
            });

            if (mstDelRecord) translationData.name = notExistReturnValue + mstDelRecord.modelNumber;
            else translationData.name = notExistReturnValue;
            // translationData.name = notExistReturnValue;
            // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 end
          } else {
            const makerName =
              undefined !== mstRecord.maker && null !== mstRecord.maker
                ? mstRecord.maker
                : "";
            translationData.name = `${makerName}[${mstRecord.modelNumber}]`;
          }
          return translationData;

        case 6:
          // 医療材料マスタ
          mstRecord = getters.getMstEquipmentData.find(mstData => {
            return mstData.equipmentCd == code; // mod #9973 value Number→文字列  shiyw
          });
          if (!mstRecord) {
            translationData.name = notExistReturnValue;
          } else {
            translationData.name = mstRecord.equipmentName;
            translationData.unit = mstRecord.unit;
          }
          return translationData;

        case 7:
          // 薬剤マスタ
          mstRecord = getters.getMstMedicineData.find(mstData => {
            return mstData.medicineCd == code; // mod #9973 value Number→文字列  shiyw
          });
          if (!mstRecord) {
            translationData.name = notExistReturnValue;
          } else {
            translationData.name = mstRecord.medicineName;
            translationData.unit = mstRecord.unit;
            translationData.unitSecond = mstRecord.unitSecond;
            translationData.classCd = mstRecord.classCd;
            translationData.decPoint = mstRecord.unitDecimalPoint;
            translationData.decPointSecond = mstRecord.unitDecimalPointSecond;
          }
          return translationData;

        case 8:
          // 薬剤分類マスタ
          mstRecord = getters.getMstMedicineClassData.find(mstData => {
            return mstData.classCd == code; // mod #9973 value Number→文字列  shiyw
          });
          if (!mstRecord) {
            translationData.name = notExistReturnValue;
          } else {
            translationData.name = mstRecord.className;
          }
          return translationData;

        case 9:
          // 調製薬剤マスタ
          mstRecord = getters.getMstMedicineMixData.find(mstData => {
            return mstData.medicineMixCd == code; // mod #9973 value Number→文字列  shiyw
          });
          if (!mstRecord) {
            translationData.name = notExistReturnValue;
          } else {
            translationData.name = mstRecord.medicineMixName;
            translationData.unit = mstRecord.unit;
            translationData.classCd = mstRecord.classCd;
            translationData.decPoint = mstRecord.unitDecimalPoint;
          }
          return translationData;

        case 10:
          // 薬剤マスタ（禁忌アレルギー込み）
          // mod FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
          // mstRecord = getters.getMstMedicineTabooAllergyData.find(mstData => {
          //   return mstData.medicineCd === code;
          // });
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // mstRecord = getters.getMstMedicineTabooAllergyData.find((mstData, index) => {
          mstRecord = getters.getMstMedicineAllergyData.find((mstData, index) => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            if (mstData.medicineCd == code) {
              mstData.index = index;
              return mstData.medicineCd == code; // mod #9973 value Number→文字列  shiyw
            }
          });
          // mod FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
          // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // 禁忌かどうか判定するために素の薬剤マスタを取得
          // mstRecordSub = getters.getMstMedicineData.find(mstData => {
          //   return mstData.medicineCd == code; // mod #9973 value Number→文字列  shiyw
          // });
          // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          // mod FNSI-期限切れ削除済みと表示するの修正 李 start
          if (!mstRecord) {
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // add FNSI-期限切れ削除済みと表示するの修正 李 start
            // 薬剤マスタ（禁忌アレルギー込み）
            // mstRecordDel = getters.getMstMedicineAllergyData.find(mstData => {
            //   return mstData.medicineCd == code; // mod #9973 value Number→文字列  shiyw
            // });
            // if (!mstRecordDel) return;
            // // add FNSI-期限切れ削除済みと表示するの修正 李 end
            // translationData.name = `【${notExistReturnValue}】` + MedicineString + mstRecordDel.medicineName;
            // translationData.prefix = `【${notExistReturnValue}】` + MedicineString;
            // translationData.unit = mstRecordDel.unit;
            // /* add by chamaojia 2024-02-28 [10196] Logic omission supplement --start */
            // translationData.unitSecond = mstRecordDel.unitSecond;
            // /* add by chamaojia 2024-02-28 [10196] Logic omission supplement --end */
            // // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
            // translationData.isDelFlag = true;
            // // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
            // // mod FNSI-期限切れ削除済みと表示するの修正 李 end
            return translationData;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          } else {
            let prefix = ""; // 先頭につける文字列（【禁忌】など）
            // 禁忌・アレルギー判定
            // 素の薬剤マスタから名称が変わっているか(Java側で定冠詞をつけているか)で判定
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // if (mstRecord.medicineName !== mstRecordSub.medicineName) {
            //   translationData.isTabooAllergy = true;
            //   prefix = mstRecord.medicineName.replace(mstRecordSub.medicineName, "");
            // } else {
            //   translationData.isTabooAllergy = false;
            // }
            prefix = getPrefix({normalClassType:classType, treatDate, ...mstRecord})
            translationData.isTabooAllergy = (mstRecord.isTaboo || mstRecord.isAllergy) ? true : false
            translationData.name = prefix + mstRecord.medicineName;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            translationData.unit = mstRecord.unit;
            translationData.unitSecond = mstRecord.unitSecond;
            translationData.classCd = mstRecord.classCd;
            translationData.decPoint = mstRecord.unitDecimalPoint;
            translationData.decPointSecond = mstRecord.unitDecimalPointSecond;
            // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // translationData.prefix = prefix;
            // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            translationData.useStartDate = mstRecord.useStartDate;
            translationData.useEndDate = mstRecord.useEndDate;
            // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
            translationData.index = mstRecord.index;
            translationData.medicateTimingCd = mstRecord.medicateTimingCd;
            translationData.procedureCd = mstRecord.procedureCd;
            // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
            // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // translationData.isDelFlag = false;
            translationData.isDelFlag = (mstRecord.isDisp == 0 || mstRecord.isDel == 1) ? true : false;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
          }
          return translationData;

        case 11:
          // 調製薬剤マスタ（禁忌アレルギー込み）
          // mod FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
          // mstRecord = getters.getMstMedicineMixTabooAllergyData.find(mstData => {
          //   return mstData.medicineMixCd === code;
          // });
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // mstRecord = getters.getMstMedicineMixTabooAllergyData.find((mstData, index) => {
          mstRecord = getters.getMstMedicineMixAllergyData.find((mstData, index) => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            if (mstData.medicineMixCd == code) { // mod #9973 value Number→文字列  shiyw
              mstData.index = getters.getMstMedicineTabooAllergyData.length + index;
              return mstData.medicineMixCd == code; // mod #9973 value Number→文字列  shiyw
            }
          });
          // mod FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
          // 禁忌かどうか判定するために素の調製薬剤マスタを取得
          // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // mstRecordSub = getters.getMstMedicineMixData.find(mstData => {
          //   return mstData.medicineMixCd == code; // mod #9973 value Number→文字列  shiyw
          // });
          // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          // mod #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
          // if (!mstRecord) {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // if (!mstRecord || mstRecord.isDisp == "0") {
          if (!mstRecord) {
            // // mod #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
            // // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
            // // translationData.name = notExistReturnValue;
            // // 調製薬剤マスタ（削除された薬剤を含む）
            // mstRecordDel = getters.getMstMedicineMixAllergyData.find(mstData => {
            //   return mstData.medicineMixCd == code; // mod #9973 value Number→文字列  shiyw
            // });
            // // FNSI-add、#7650 治療記録－投与薬剤初期化エラー修正、xugj start
            // if (!mstRecordDel) return;
            // // FNSI-add、#7650 治療記録－投与薬剤初期化エラー修正、xugj end
            // translationData.name = `【${notExistReturnValue}】` + MedicineString + mstRecordDel.medicineMixName;
            // translationData.prefix = `【${notExistReturnValue}】` + MedicineString;
            // translationData.unit = mstRecordDel.unit;
            // // mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end
            // // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
            // translationData.isDelFlag = true;
            // // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
            return translationData;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          } else {
            let prefix = ""; // 先頭につける文字列（【禁忌】など）
            // 禁忌・アレルギー判定
            // 素の調製薬剤マスタから名称が変わっているか(Java側で定冠詞をつけているか)で判定
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // if (mstRecord.medicineMixName !== mstRecordSub.medicineMixName) {
            //   translationData.isTabooAllergy = true;
            //   prefix = mstRecord.medicineMixName.replace(mstRecordSub.medicineMixName, "");
            // } else {
            //   translationData.isTabooAllergy = false;
            // }
            prefix = getPrefix({normalClassType:classType, treatDate, ...mstRecord})
            translationData.isTabooAllergy = (mstRecord.isTaboo || mstRecord.isAllergy) ? true : false
            // translationData.name = mstRecord.medicineMixName;
            translationData.name = prefix + mstRecord.medicineMixName;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            translationData.unit = mstRecord.unit;
            translationData.classCd = mstRecord.classCd;
            // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // translationData.prefix = prefix;
            // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            translationData.decPoint = mstRecord.unitDecimalPoint;
            translationData.useStartDate = mstRecord.maxUseStartDate;
            translationData.useEndDate = mstRecord.minUseEndDate;
            // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
            translationData.index = mstRecord.index;
            translationData.medicateTimingCd = mstRecord.medicateTimingCd;
            translationData.procedureCd = mstRecord.procedureCd;
            // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
            // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // translationData.isDelFlag = false;
            translationData.isDelFlag = (mstRecord.isDisp == 0 || mstRecord.isDel == 1) ? true : false;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
          }
          return translationData;

        case 12:
          // 医療材料マスタ（禁忌アレルギー込み）
          // mod FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
          // mstRecord = getters.getMstEquipmentTabooAllergyData.find(mstData => {
          //   return mstData.equipmentCd === code;
          // });
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // mstRecord = getters.getMstEquipmentTabooAllergyData.find((mstData, index) => {
          mstRecord = getters.getMstEquipmentAllergy.find((mstData, index) => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            if (mstData.equipmentCd == code) {// mod #9973 value Number→文字列  shiyw
              mstData.index = index;
              return mstData.equipmentCd == code;// mod #9973 value Number→文字列  shiyw
            }
          });
          // mod FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
          // 禁忌かどうか判定するために素の医療材料マスタを取得
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // mstRecordSub = getters.getMstEquipmentData.find(mstData => {
          //   return mstData.equipmentCd == code; // mod #9973 value Number→文字列  shiyw
          // });
          if (!mstRecord) {
            // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
            // 医療材料マスタ一覧取得（削除済のデータも含む）
            // const equipmentData = getters.getMstEquipmentAllergy.find(mstData => {
            //   return mstData.equipmentCd == code; // mod #9973 value Number→文字列  shiyw
            // });
            // if (!equipmentData) return;
            // translationData.name = `【${notExistReturnValue}】` + equipmentData.equipmentName;
            // translationData.prefix = `【${notExistReturnValue}】`;
            // translationData.unit = equipmentData.unit;
            // // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
            // translationData.isDelFlag = true;
            // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
            // add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

            // del FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
            // // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#9。 周 start
            // // translationData.name = notExistReturnValue;
            // translationData.name = `[${notExistReturnValue}]`;
            // // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#9。 周 end
            // del FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end
            return translationData;
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          } else {
            let prefix = ""; // 先頭につける文字列（【禁忌】など）
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // 禁忌・アレルギー判定
            // 素の医療材料マスタから名称が変わっているか(Java側で定冠詞をつけているか)で判定
            // if (mstRecord.equipmentName !== mstRecordSub.equipmentName) {
            //   translationData.isTabooAllergy = true;
            //   prefix = mstRecord.equipmentName.replace(mstRecordSub.equipmentName, "");
            // } else {
            //   translationData.isTabooAllergy = false;
            // }
            prefix = getPrefix({normalClassType:classType, treatDate, ...mstRecord})
            translationData.isTabooAllergy = (mstRecord.isTaboo || mstRecord.isAllergy) ? true : false
            // translationData.name = mstRecord.equipmentName;
            translationData.name = prefix + mstRecord.equipmentName;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            translationData.unit = mstRecord.unit;
            translationData.decPoint = mstRecord.unitDecimalPoint;
            // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // translationData.prefix = prefix;
            // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            translationData.useStartDate = mstRecord.useStartDate;
            translationData.useEndDate = mstRecord.useEndDate;
            // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
            translationData.classCd = mstRecord.classCd;
            translationData.index = mstRecord.index;
            // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
            // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou start
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // translationData.isDelFlag = false;
            translationData.isDelFlag = (mstRecord.isDisp == 0 || mstRecord.isDel == 1) ? true : false;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            // add #8142 患者経過総合ビューアおよび患者カレンダーが開かなくなる。削除済み、期限切れ、禁忌アレルギーの表示不具合 dou end
          }
          return translationData;

        case 13:
          // ダイアライザーマスタ（禁忌アレルギー込み）
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // mstRecord = getters.getMstDialyzerTabooAllergyData.find((mstData, index) => {
          mstRecord = getters.getMstDialyzerTabooAllergyDeletedData.find((mstData, index) => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            if (mstData.dialyzerCd == code) { // mod #9973 value Number→文字列  shiyw
              // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
              // mstData.index = getters.getMstEquipmentTabooAllergyData.length + index;
              mstData.index = getters.getMstDialyzerTabooAllergyDeletedData.length + index;
              // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
              return mstData.dialyzerCd == code; // mod #9973 value Number→文字列  shiyw
            }
          });
          // mod FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
          // 禁忌かどうか判定するために素のダイアライザーマスタを取得
          // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // mstRecordSub = getters.getMstDialyzerData.find(mstData => {
          //   return mstData.dialyzerCd == code; // mod #9973 value Number→文字列  shiyw
          // });
          // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          if (!mstRecord) {
            // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 start
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // const mstDelRecord = getters.getMstDialyzerDelData.find(mstData => {
            //   return mstData.dialyzerCd == code;
            // });

            // if (mstDelRecord) translationData.name = '【' + notExistReturnValue + '】' + mstDelRecord.modelNumber;
            // else translationData.name = notExistReturnValue;
            // translationData.name = notExistReturnValue;
            // mod FNSI-FutreNetWeb+SI課題管理No.4869 李 end
            return translationData;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          } else {
            let prefix = ""; // 先頭につける文字列（【禁忌】など）
            // 禁忌・アレルギー判定
            // 素のダイアライザーマスタから名称が変わっているか(Java側で定冠詞をつけているか)で判定
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // if (mstRecord.modelNumber !== mstRecordSub.modelNumber) {
            //   translationData.isTabooAllergy = true;
            //   prefix = mstRecord.modelNumber.replace(mstRecordSub.modelNumber, "");
            // } else {
            //   translationData.isTabooAllergy = false;
            // }
            prefix = getPrefix({treatDate, ...mstRecord})
            translationData.isTabooAllergy = (mstRecord.isTaboo || mstRecord.isAllergy) ? true : false
            translationData.name = `${prefix}${mstRecord.modelNumber}`;
            // translationData.prefix = prefix;
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            translationData.useStartDate = mstRecord.useStartDate;
            translationData.useEndDate = mstRecord.useEndDate;
            // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 start
            translationData.classCd = mstRecord.classCd;
            translationData.index = mstRecord.index;
            // add FNSI-薬剤、医療材料の表示順の設定を追加する 李 end
            // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            translationData.isDelFlag = (mstRecord.isDisp == 0 || mstRecord.isDel == 1) ? true : false;
            // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
            translationData.unit = "本";
            // add #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
          }
          return translationData;

        default:
          return null;
      }
    },

    /**
     * 装置設定情報変換
     * @description 装置設定コードに応じてcodeを変換する
     * @param deviceSetInfoCd 装置設定コード
     */
    getDeviceSetInfo({ deviceSetInfoCd }) {
      switch (deviceSetInfoCd) {
        // 除水プログラム
        case 0:
          break;

        // Na注入プログラム
        case 1:
          break;

        // 透析液濃度プログラム
        case 2:
          break;

        // Qb・Qdプログラム
        case 3:
          break;

        // I-HDF
        case 4:
          break;

        // BV-UFC
        case 5:
          break;

        // 透析量プログラム
        case 6:
          break;

        default:
          break;
      }
    },

    /**
     * 薬剤情報「計算材料保持テーブル」を表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {string} facilityCd 施設コード
     * @param {number} patId 患者ID
     */
    async convertDrugInfo({ getters }, { listIndex, layout, facilityCd, patId }) {
      const convertData = [
        {
          itemName: layout.categoryName,
          itemNameSub: [],
          data: []
        }
      ];

      const series = [];
      const yAxis = [];
      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex] || {};
      if (!copyTreatmentData) {
        return [];
      }
      // 期間情報を取得
      const period = getters.getSelectedPeriod;
      const isLongPeriod = ["4", "5", "6", "7"].includes(period);
      const treatmentDataLastIndex = Object.keys(copyTreatmentData).length - 1;
      let startDate = moment(
        Object.keys(copyTreatmentData)[0] || getters.getDateList[0],
        "YYYYMMDD"
      ).startOf("day");
      let endDate = moment(
        Object.keys(copyTreatmentData)[treatmentDataLastIndex] ||
        getters.getDateList[getters.getDateList.length - 1],
        "YYYYMMDD"
      ).endOf("day");

      // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 start
      // 選択中投薬支援マスト情報を取得
      const selectedMedicineSupportItem = getters.getSelectedMedicineSupport === null ? null :
        getters.getMstMedicineSupportData.find(mstData => {
          return mstData.medicineSupportCd === getters.getSelectedMedicineSupport;
        });
      // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 end

      // 期間終了日計算
      const kikan_shuuryou = item => {
        switch (item.shuukei) {
          // 週「月曜日（今週）～月曜日（来週）」
          case 2:
            return moment(item.kaishi).add(1, 'weeks').day(1).format("YYYYMMDD");
          // 2週「月曜日（今週）～月曜日（再来週）」
          case 3:
            return moment(item.kaishi).add(2, 'weeks').day(1).format("YYYYMMDD");
          // 月「１日（今月）～１日（来月）」
          case 4:
            return moment(item.kaishi).add(1, 'months').startOf('month').format("YYYYMMDD");
          // 3ヶ月
          case 5:
            return moment(item.kaishi).add(3, 'months').startOf('month').format("YYYYMMDD");
          // 日
          default:
            return moment(item.kaishi).add(1, 'days').format("YYYYMMDD");
        }
      };

      // 指示・実績区分作成
      const shiji_jisseki_kubun = item => {
        if (item.drugStatus === "指示") {
          return "1";
        } else if (item.drugStatus === "実績") {
          return "2";
        } else if (item.drugStatus === "目標値") {
          return "9";
        } else {
          return "0";
        }
      };

      // 集計期間作成
      const shuukei_kikan = item => {
        if (item === "day") {
          return 1;
        } else if (item === "week") {
          return 2;
        } else if (item === "twoWeek") {
          return 3;
        } else if (item === "month") {
          return 4;
        } else if (item === "threeMonth") {
          return 5;
        } else {
          return 0;
        }
      };

      // 集計期間配列作成
      const shuukei_kikan_hairetsu = item => {
        const result = [];

        for (let index = item.kaishi; index < item.shuuryou; ) {
          // 期間終了日計算
          const shuuryou = kikan_shuuryou({
            kaishi: index,
            shuukei: item.shuukei
          });

          result.push({
            kaishi: index,
            shuuryou: shuuryou
          });

          // 期間開始日設定「index++」
          index = shuuryou;
        }
        return result;
      };

      const getPrefix = item => {
        switch (item) {
          case "column":
            return "(棒)";
          case "line":
            return "(線)";
          case "xrange":
          default:
            return "(帯)";
        }
      };

      if (isLongPeriod) {
        // 期間情報再設定
        switch (period) {
          case "4":
            // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 start
            // endDate = endDate.add(1, "week").startOf("day");
            endDate = endDate.add(1, "week").startOf("day").subtract(1, "days");
            // mod 9560 患者経過総合ビューアで長期間表示のグラフの時間軸が不正 張玲 end
            break;
          case "5":
          case "6":
            startDate = startDate.startOf("month");
            endDate = endDate.endOf("month");
            break;
          case "7":
            startDate = startDate.startOf("month");
            endDate = endDate.add(11, "months").endOf("month");
            break;
        }

        // APIの引数作成
        const sendData = {};
        sendData.facility_cd = facilityCd;
        sendData.pat_id = patId;
        sendData.supplies_base_date_begin = startDate.format("YYYYMMDD");
        sendData.supplies_base_date_end = endDate.format("YYYYMMDD");
        // add #12462 患者情報共有->患者経過総合ビューア fang start
        const patientShareMode = store.getters["account-edit/getPatientShareMode"];
        const patientShareFacilityCdMode = store.getters["account-edit/getPatientShareFacilityCdMode"];
        sendData.shareMode = patientShareMode == 0 && !patientShareFacilityCdMode ? 0 : 1;
        // add #12462 患者情報共有->患者経過総合ビューア fang end

        // ➀RestAPI実行「計算材料情報を取得」
        const ordMaterialSave = await ApiHelper.post(
          "/mainData/getOrdMaterialSave",
          sendData
        ).catch(err => {
          throw err;
        });
        // mod #12462 患者情報共有->患者経過総合ビューア fang start
        // const ordMaterialSaveData = ordMaterialSave.data;
        const ordMaterialSaveData = otherFacilityOrdMaterialSaveConvert(facilityCd, ordMaterialSave, getters.getMstMedicineData)
        // mod #12462 患者情報共有->患者経過総合ビューア fang end
        //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
        // ➁RestAPI実行「薬効換算マスタ情報を取得」
        const mstMedicineGroup = await ApiHelper.get("/mstInfo/mstMedicineGroup", {
          facilityCd: facilityCd
        }).catch(err => {
          throw err;
        });
        const mstMedicineGroupData = mstMedicineGroup.data;
        //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end

        layout.categoryItem.forEach((category, index) => {
          // 表示データ配列
          let hyouji_deta_hairetsu = [];
          // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // // 上限値「マスタ情報から取得」
          // let max = category.graphMax ? Number(category.graphMax) : 0;
          // // 下限値「マスタ情報から取得」
          // let min = category.graphMin ? Number(category.graphMin) : 0;
          let max = category.graphMax;
          let min = category.graphMin;
          // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
          // 指示・実績区分
          let ind_rst_class = shiji_jisseki_kubun(category);
          // 集計期間
          let summaryDate = shuukei_kikan(category.summaryDate);
          category.subCategoryItem.forEach(subCategory => {
            let itemNo = "0";
            let itemDate = shuukei_kikan(subCategory.itemDate);
            let chartType = "";

            const rangeData = [];
            let seriesData = [];
            // 通常薬剤条件
            // 「0：治療条件」「1：投与薬剤」「3：愁訴処置」
            const sourceArr_tsuujou = ["0", "1", "3"];
            // 「0：治療条件」⇒「08：透析液」「09：補液」「10：抗凝固剤」
            // 「1：投与薬剤」⇒「12：投与薬剤」
            // 「3：愁訴処置」⇒「14：処置薬剤」
            const suppliesArr_tsuujou = ["08", "09", "10", "12", "14"];
            // 調製薬剤条件
            // 「0：治療条件」「1：投与薬剤」「3：愁訴処置」
            const sourceArr_chousei = ["0", "1", "3"];
            // 「0：治療条件」⇒「17：抗凝固剤調製薬剤」
            // 「1：投与薬剤」⇒「13：調製薬剤」
            // 「3：愁訴処置」⇒「15：処置調製薬剤」
            const suppliesArr_chousei = ["17", "13", "15"];
            // 処方条件
            // 「4：処方」
            const sourceArr_shohou = ["4"];
            // 「4：処方」⇒ 23:処方(薬剤) 24:処方(一般名処方)
            const suppliesArr_shohou = ["23", "24"];
            // 投薬支援条件
            // 「5：投薬支援」
            const sourceArr_shien = ["5"];
            // 「5：投薬支援」⇒「18：目標投与量（投薬支援）」
            const suppliesArr_shien_mokuhyouchi = ["18"];
            // add FNSI-投薬支援仕様更新「目標投与量」 周 end

            // 期間データを作成「集計期間」
            rangeData.push(...shuukei_kikan_hairetsu({
              // 集計期間「-1：未登録」「1：日」
              // 患者経過総合ビューアレイアウトマスタにて「集計期間」を「ヘッダー」と「明細」それぞれに指定された場合、「明細」を優先させる。
              // 「集計期間」を指定されていない「明細」は「ヘッダー」の「集計期間」に従う。
              // 「ヘッダー」、「明細」共に指定されていない場合、「日」単位での集計とする。
              shuukei: itemDate === -1 ? (summaryDate === -1 ? 1 : summaryDate) : itemDate,
              // 期間開始
              kaishi: moment(startDate).format("YYYYMMDD"),
              // 期間終了
              shuuryou: moment(endDate).format("YYYYMMDD")
            }));
            // 表示データを作成「集計」
            // mod FNSI-投薬支援仕様更新「目標投与量」 周 start
            // if (subCategory.itemNo.toString().includes("MEDICINE_GROUP")) {

            // 目標値1「投薬」
            const shien_mokuhyouchi_touyaku = "target_investment1";
            // 目標値2「処方」
            const shien_mokuhyouchi_shohou = "target_investment2";
            if (subCategory.itemNo === shien_mokuhyouchi_touyaku || subCategory.itemNo === shien_mokuhyouchi_shohou) {
              // 目標値場合
              // マスタ情報の明細無効場合
              if (!(selectedMedicineSupportItem && selectedMedicineSupportItem.detailInfo && JSON.parse(selectedMedicineSupportItem.detailInfo))) {
                return null;
              }
              const detailInfo = JSON.parse(selectedMedicineSupportItem.detailInfo);

              if (!(detailInfo.hasOwnProperty("medicineESA") && detailInfo.medicineESA)) {
                return null;
              }
              const itemNoInfo = detailInfo.medicineESA;

              // 投薬支援⇒目標値無効場合
              if (!(itemNoInfo && itemNoInfo[0].hasOwnProperty("value") && itemNoInfo[0].value)) {
                return null;
              }
              let itemNo = itemNoInfo[0].value.toString();
              // 棒グラフ
              chartType = "column";
              rangeData.forEach(item => {
                let val = ordMaterialSaveData
                  .filter(ord => {
                    return (
                      // データ基準日⇒期間開始日「集計期間計算」
                      ord.suppliesBaseDate >= item.kaishi &&
                      // データ基準日⇒期間終了日「集計期間計算」
                      ord.suppliesBaseDate < item.shuuryou &&
                      // データ発生元区分「配列存在」
                      sourceArr_shien.includes(ord.suppliesSourceClass) &&
                      // 物品区分「配列存在」
                      suppliesArr_shien_mokuhyouchi.includes(ord.suppliesClass) &&
                      // 物品コード「マスタから取得」
                      ord.suppliesCd === itemNo &&
                      // 調製薬剤コード「ヌル固定」
                      ord.medicineMixCd === null &&
                      // 指示・実績区分「2：実績」固定
                      ord.indRstClass === "2" &&
                      // 確定フラグ「1：確定」固定
                      ord.isConfirm === "1"
                    );
                  })
                  .reduce((prev, cur) => {
                    // 指示・実績値項目を集計
                    return Number(cur.indRstValue ? cur.indRstValue : 0) + Number(prev)
                  }, 0);
                if (val) {
                  // 表示データ設定「上限値、下限値更新用」
                  hyouji_deta_hairetsu.push(val);
                  // シリーズデータを作成
                  seriesData.push([item.kaishi, val]);
                }
              });
            } else if (subCategory.itemNo.toString().includes("MEDICINE_GROUP")) {
              if (subCategory.itemNo.includes("MEDICINE_GROUPS")) {
                itemNo = subCategory.itemNo.replace("MEDICINE_GROUPS", "");
                chartType = "xrange";
              } else {
                // 投薬場合「薬効換算」
                itemNo = subCategory.itemNo.replace("MEDICINE_GROUP", "");
                // 棒グラフ
                chartType = "column";
              }
              // 薬効換算マスタ情報
              const mstGroup = mstMedicineGroupData.find(mst => {
                return mst.medicineGroupCd.toString() === itemNo;
              });
              if (mstGroup && chartType === "column") {
                const regMedicineInfo = JSON.parse(mstGroup.regMedicineInfo).filter(item => item.del === "0");
                rangeData.forEach(item => {
                  let val = 0;
                  regMedicineInfo.forEach(medicineInfo => {
                    let valItem = ordMaterialSaveData
                      .filter(ord => {
                        if (medicineInfo.mediFlg === "0") {
                          // 通常薬剤
                          return (
                            // データ基準日⇒期間開始日「集計期間計算」
                            ord.suppliesBaseDate >= item.kaishi &&
                            // データ基準日⇒期間終了日「集計期間計算」
                            ord.suppliesBaseDate < item.shuuryou &&
                            // データ発生元区分「配列存在」
                            sourceArr_tsuujou.includes(ord.suppliesSourceClass) &&
                            // 物品区分「配列存在」
                            suppliesArr_tsuujou.includes(ord.suppliesClass) &&
                            // 物品コード「マスタから取得」
                            ord.suppliesCd === medicineInfo.cd.toString() &&
                            // 調製薬剤コード「ヌル固定」
                            ord.medicineMixCd === null &&
                            // 指示・実績区分「マスタから取得」
                            ord.indRstClass === ind_rst_class
                          );
                        } else if (medicineInfo.mediFlg === "2") {
                          // 調製薬剤
                          return (
                            // データ基準日⇒期間開始日「集計期間計算」
                            ord.suppliesBaseDate >= item.kaishi &&
                            // データ基準日⇒期間終了日「集計期間計算」
                            ord.suppliesBaseDate < item.shuuryou &&
                            // データ発生元区分「配列存在」
                            sourceArr_chousei.includes(ord.suppliesSourceClass) &&
                            // 物品区分「配列存在」
                            suppliesArr_chousei.includes(ord.suppliesClass) &&
                            // 物品コード「ヌル固定」
                            ord.suppliesCd === null &&
                            // 調製薬剤コード「マスタから取得」
                            ord.medicineMixCd === medicineInfo.cd.toString() &&
                            // 指示・実績区分「マスタから取得」
                            ord.indRstClass === ind_rst_class
                          );
                        }
                      })
                      .reduce((prev, cur) => {
                        // 指示・実績値項目 × 交換値を集計
                        return Number(cur.indRstValue ? cur.indRstValue : 0) * Number(medicineInfo.conVal) + Number(prev)
                      }, 0);

                    // 薬剤換算集計
                    val = Number(val) + Number(valItem);
                  });

                  if (val) {
                    // 表示データ設定「上限値、下限値更新用」
                    hyouji_deta_hairetsu.push(val);
                    // シリーズデータを作成
                    seriesData.push([item.kaishi, val]);
                  }
                });
              } else if (mstGroup && chartType === "xrange") { // 処方
                const start = moment(startDate).format("YYYYMMDD");
                const end = moment(endDate).format("YYYYMMDD");
                const regMedicineInfo = JSON.parse(mstGroup.regMedicineInfo).filter(item => item.del === "0");

                regMedicineInfo.forEach(medicineInfo => {
                  let valItem = ordMaterialSaveData.filter(ord => {
                    return (
                      // データ基準日⇒期間開始日「集計期間計算」
                      ord.suppliesBaseDate >= start &&
                      // データ基準日⇒期間終了日「集計期間計算」
                      ord.suppliesBaseDate < end &&
                      // データ発生元区分「配列存在」
                      sourceArr_shohou.includes(ord.suppliesSourceClass) &&
                      // 物品区分「配列存在」
                      suppliesArr_shohou.includes(ord.suppliesClass) &&
                      // 物品コード「マスタから取得」
                      ord.suppliesCd === medicineInfo.cd.toString()
                    );
                  });

                  const rawSeriesData = valItem?.map((item) => {
                    const startDate = item.suppliesBaseDate;
                    let endDate;
                    if (item.frequencyFlg === "0") { // 日分
                      endDate = item.frequencyNum ? moment(startDate).add(Number(item.frequencyNum) - 1, "days").format("YYYYMMDD") : startDate;
                    } else if (item.frequencyFlg === "1") { // 回分
                      endDate = startDate;
                    }
                    return [startDate, endDate, item.indRstValue];
                  }) || [];

                  const mergedData = mergeXrangeData(rawSeriesData);
                  seriesData.push(...mergedData);

                  const mergedValues = mergedData.map(item => Number(item[2]));
                  hyouji_deta_hairetsu.push(...mergedValues);
                });
              }
              //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
            } else if (subCategory.itemNo.toString().includes("MEDICINE_MIX")) {
              // 投薬場合「調製薬剤」
              itemNo = subCategory.itemNo.replace("MEDICINE_MIX", "");
              // 棒グラフ
              chartType = "column";
              rangeData.forEach(item => {
                let val = ordMaterialSaveData
                  .filter(ord => {
                    return (
                      // データ基準日⇒期間開始日「集計期間計算」
                      ord.suppliesBaseDate >= item.kaishi &&
                      // データ基準日⇒期間終了日「集計期間計算」
                      ord.suppliesBaseDate < item.shuuryou &&
                      // データ発生元区分「配列存在」
                      sourceArr_chousei.includes(ord.suppliesSourceClass) &&
                      // 物品区分「配列存在」
                      suppliesArr_chousei.includes(ord.suppliesClass) &&
                      // 物品コード「マスタから取得」
                      ord.suppliesCd === itemNo &&
                      // 調製薬剤コード「ヌル固定」
                      // ord.medicineMixCd === null &&
                      // 指示・実績区分「マスタから取得」
                      ord.indRstClass === ind_rst_class
                    );
                  })
                  .reduce((prev, cur) => {
                    // 指示・実績値項目を集計
                    return Number(cur.indRstValue ? cur.indRstValue : 0) + Number(prev)
                  }, 0);

                if (val) {
                  // 表示データ設定「上限値、下限値更新用」
                  hyouji_deta_hairetsu.push(val);
                  // シリーズデータを作成
                  seriesData.push([item.kaishi, val]);
                }
              });
            } else if (subCategory.itemNo.toString().includes("MEDICINE")) {
              // 処方場合
              itemNo = subCategory.itemNo.replace("MEDICINE", "");
              // 帯グラフ
              chartType = "xrange";
              let filter = ordMaterialSaveData.filter(ord => {
                return (
                  // データ基準日⇒期間開始日「集計期間計算」
                  ord.suppliesBaseDate >= startDate.format("YYYYMMDD") &&
                  // データ基準日⇒期間終了日「集計期間計算」
                  ord.suppliesBaseDate <= endDate.format("YYYYMMDD") &&
                  // データ発生元区分「配列存在」
                  sourceArr_shohou.includes(ord.suppliesSourceClass) &&
                  // 物品区分「配列存在」
                  suppliesArr_shohou.includes(ord.suppliesClass) &&
                  // 物品コード「マスタから取得」
                  ord.suppliesCd === itemNo
                );
              });

              const rawSeriesData = filter.map((item) => {
                const startDate = item.suppliesBaseDate;
                let endDate;
                if (item.frequencyFlg === "0") { // 日分
                  endDate = item.frequencyNum ? moment(startDate).add(Number(item.frequencyNum) - 1, "days").format("YYYYMMDD") : startDate;
                } else if (item.frequencyFlg === "1") { // 回分
                  endDate = startDate;
                }
                return [startDate, endDate, item.indRstValue];
              });

              const mergedData = mergeXrangeData(rawSeriesData);
              seriesData = mergedData;

              const mergedValues = mergedData.map(item => Number(item[2]));
              hyouji_deta_hairetsu = hyouji_deta_hairetsu.concat(mergedValues);
            } else {
              // 投薬場合「通常薬剤」
              itemNo = subCategory.itemNo.toString();
              // 棒グラフ
              chartType = "column";
              rangeData.forEach(item => {
                let val = ordMaterialSaveData
                  .filter(ord => {
                    return (
                      // データ基準日⇒期間開始日「集計期間計算」
                      ord.suppliesBaseDate >= item.kaishi &&
                      // データ基準日⇒期間終了日「集計期間計算」
                      ord.suppliesBaseDate < item.shuuryou &&
                      // データ発生元区分「配列存在」
                      sourceArr_tsuujou.includes(ord.suppliesSourceClass) &&
                      // 物品区分「配列存在」
                      suppliesArr_tsuujou.includes(ord.suppliesClass) &&
                      // 物品コード「マスタから取得」
                      ord.suppliesCd === itemNo &&
                      // 調製薬剤コード「ヌル固定」
                      ord.medicineMixCd === null &&
                      // 指示・実績区分「マスタから取得」
                      ord.indRstClass === ind_rst_class
                    );
                  })
                  .reduce((prev, cur) => {
                    // 指示・実績値項目を集計
                    return Number(cur.indRstValue ? cur.indRstValue : 0) + Number(prev)
                  }, 0);

                if (val) {
                  // 表示データ設定「上限値、下限値更新用」
                  hyouji_deta_hairetsu.push(val);
                  // シリーズデータを作成
                  seriesData.push([item.kaishi, val]);
                }
              });
            }

            // add 12031 患者経過総合ビューアのグラフオートレンジ zkm start
            const {max: calcMax, min: calcMin} = getThreshold(category.graphMax, category.graphMin, hyouji_deta_hairetsu, chartType);
            max = calcMax;
            min = calcMin;
            // add 12031 患者経過総合ビューアのグラフオートレンジ zkm end

            series.push({
              type: chartType,
              dateType: subCategory.itemDate,
              yAxis: index,
              // add FNSI-グラフの縦軸表示を修正 周 start
              yAxisMax: Math.max(max, min),
              yAxisMin: Math.min(max, min),
              // add FNSI-グラフの縦軸表示を修正 周 end
              yAxisNo: category.subCategoryNo,
              yAxisName: category.subCategoryName,
              name: getPrefix(chartType) + subCategory.itemName,
              no: subCategory.itemNo,
              color: subCategory.itemColor,
              // add FNSI-グラフのシリーズ表示を修正_薬剤グラフ機能分 周 start
              marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
              // add FNSI-グラフのシリーズ表示を修正_薬剤グラフ機能分 周 end
              data: [...seriesData]
            });
          });

          // add FNSI-グラフの縦軸表示を修正 周 start
          // 実績情報をクリア
          hyouji_deta_hairetsu.splice(0, hyouji_deta_hairetsu.length);
          // add FNSI-グラフの縦軸表示を修正 周 end

          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // // 上限値「実績情報から更新」
          // max = hyouji_deta_hairetsu.length > 0 ? Math.max(...hyouji_deta_hairetsu, max) : max;
          // // 下限値「実績情報から更新」
          // min = hyouji_deta_hairetsu.length > 0 ? Math.min(...hyouji_deta_hairetsu, min) : min;
          // del 12031 患者経過総合ビューアのグラフオートレンジ zkm end

          yAxis.push({
            labels: { enabled: false },
            title: { text: category.subCategoryName },
            tickPositioner: function() {
              const incrementCount = 4;
              const dataMax = Math.max(max, min);
              const dataMin = Math.min(max, min);
              const mstFixedCount = Math.max(
                  (dataMin % 1 !== 0) ? (dataMin.toString()).split('.')[1].length : 0,
                  (dataMax % 1 !== 0) ? (dataMax.toString()).split('.')[1].length : 0
              );
              const increment = (dataMax - dataMin) > 0 ? (dataMax - dataMin) / incrementCount : 0;
              const incrementFixedCount = (increment % 1 !== 0) ? (increment.toString()).split('.')[1].length : 0;
              const incrementFixedMax = 3;

              const fixed = Math.max(Math.min(incrementFixedCount, incrementFixedMax), mstFixedCount);
              const positions = [];
              if (increment > 0) {
                for (let index = 0; index <= incrementCount; index++) {
                    const valFull = dataMin + index * increment;
                    const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
                    positions.push(valFloor);
                }
              } else {
                for (let index = 0; index <= incrementCount; index++) {
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                  // positions.push(Number(dataMin + index));
                  const p = dataMin + index;
                  positions.push(parseFloat(p.toFixed(3)));
                  // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
                }
              }
              return positions;
            },
            offset: 0
          });
        });

        // for (let i = 0; i < series.length; i++) {
        //   if (series[i].data) {
        //     if (series[i].data.length === 0) {
        //       series.splice(i, 1);
        //     }
        //   } else {
        //     series.splice(i, 1);
        //   }
        // }
      }

      // add bug 6602 修正 chen start
      let breaks = [];
      let breakDays = [];
      if (period + "" === "1" || period + "" === "2" || period + "" === "3") {
        let days = endDate.diff(startDate, 'days');
        for (let i = 1; i < days; i++) {
          let daytmp = moment(startDate.format("YYYY-MM-DD"));
          daytmp = daytmp.add(i, 'days');
          let strDay = daytmp.format("YYYYMMDD");
          if (!Object.keys(copyTreatmentData).includes(strDay) &&
            !getters.getDateList.includes(strDay)) {
            breakDays.push(strDay);
          }
        }
        let daytmp = "";
        let daytmpS = "";
        breakDays.forEach(breakDay => {
          if (daytmpS === "") {
            daytmpS = breakDay;
          } else {
            if (moment(daytmp).add(1, 'days').format("YYYYMMDD") !== breakDay) {
              let fromD = moment(daytmpS).startOf('day');
              let toD = moment(daytmp).add(1, 'days').startOf('day');
              let breakItem = {
                from: fromD.valueOf(),
                to: toD.valueOf()
              };
              breaks.push(breakItem);
              daytmpS = breakDay;
            }
          }
          daytmp = breakDay;
        });
        if (daytmp !== daytmpS) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
        if (daytmpS !== "" && breaks.length === 0) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
      }
      // add bug 6602 修正 chen end
      convertData[0].data.push({
        type: "drug-graph",
        chartData: series,
        chartXAxisMin: startDate.valueOf(),
        chartXAxisMax: endDate.valueOf(),
        breaks: breaks,
        chartDisplayPeriod: period,
        yAxis: yAxis
      });
      return convertData;
    },
    // mod FNSI-長期の薬剤グラフの表示を改善「235」「660」「661」 周 end

    // add FNSI-長期の複合グラフを新規作成「236」「660」「661」 周 start
    /**
     * 複合グラフ情報「計算材料保持テーブル、治療情報」を表示用に加工
     * @param {Number} listIndex 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     * @param {string} facilityCd 施設コード
     * @param {number} patId 患者ID
     */
    async convertComprehensiveInfo({ state, getters, commit }, { listIndex, layout, facilityCd, patId, weekPattern }) {
      const convertData = [
        {
          itemName: layout.categoryName,
          itemNameSub: [],
          data: []
        }
      ];

      const tickAmount = 6;
      const series = [];
      const yAxis = [];
      const max_dami = 120;
      const step_dami = 2;
      // 縦軸ダミーデータ作成「治療方法と治療条件用」
      yAxis.push({
        labels: { enabled: false },
        max: max_dami,
        min: 0,
        tickAmount: tickAmount - 1,
        offset: 0
      });
      const custom_chiryou_houhou = [];
      const custom_chiryou_jouken_05 = [];
      const custom_chiryou_jouken_05_06 = [];
      const custom_chiryou_jouken_05_07 = [];
      const custom_chiryou_jouken_05_08 = [];
      const custom_chiryou_jouken_19 = [];
      const custom_chiryou_jouken_25 = [];
      // DB取得データ(ord_main)
      const copyTreatmentData = getters.getTreatmentData[listIndex] || {};
      if (!copyTreatmentData) {
        return [];
      }
      // 期間情報を取得
      const period = getters.getSelectedPeriod;
      const isLongPeriod = ["4", "5", "6", "7"].includes(period);
      const treatmentDataLastIndex = Object.keys(copyTreatmentData).length - 1;
      let startDate = moment(
        Object.keys(copyTreatmentData)[0] || getters.getDateList[0],
        "YYYYMMDD"
      ).startOf("day");
      let endDate = moment(
        Object.keys(copyTreatmentData)[treatmentDataLastIndex] ||
        getters.getDateList[getters.getDateList.length - 1],
        "YYYYMMDD"
      ).endOf("day");

      // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 start
      // 選択中投薬支援マスト情報を取得
      const selectedMedicineSupportItem = getters.getSelectedMedicineSupport === null ? null :
        getters.getMstMedicineSupportData.find(mstData => {
          return mstData.medicineSupportCd === getters.getSelectedMedicineSupport;
        });
      // add FNSI-投薬支援仕様更新「投薬支援マスタ」 周 end

      const ordMain = [];
      // 治療条件情報「治療情報から取得」ord_main
      // /mainData/sharingInfo/TreatDateList
      let hasCond = false;
      const conditions = [];
      // 体重情報「治療情報から取得」ord_main
      let hasWeight = false;
      const weights = [];
      // 患者DW情報「患者情報から取得」
      const patDwInfo = [];

      // バイタル・モニタ情報「装置モニタデータから取得」mni_monitor
      // /status_list/mni_monitor
      let hasVital = false;
      const mniMonitor = [];

      // 検査結果情報「患者検査結果から取得」pat_exam_main
      // /exam/TreatDateList
      let hasExam = false;
      const patExamMain = [];

      // 投与薬剤情報「計算材料保持から取得」ord_material_save
      // /mainData/getOrdMaterialSave
      let hasMedi = false;
      // mod #12462 患者情報共有->患者経過総合ビューア fang start
      let ordMaterialSave = [];
      // mod #12462 患者情報共有->患者経過総合ビューア fang end

      // add FNSI-投薬支援仕様更新「目標投与量」 周 start
      // 目標投与量「薬剤（ESA投与支援）」
      let hasESA1 = false;
      let hasESA2 = false;
      // 目標値1「投薬」
      const shien_mokuhyouchi_touyaku = "target_investment1";
      // 目標値2「処方」
      const shien_mokuhyouchi_shohou = "target_investment2";
      // add FNSI-投薬支援仕様更新「目標投与量」 周 end
      // add FNSI-投薬支援仕様更新「予測値」 周 start
      // 予測値「検査項目（cycling・予測値）」
      let hasPredictive = false;
      // 予測値
      const shien_yosokuchi = "prediction";
      // add FNSI-投薬支援仕様更新「予測値」 周 end
      // add FNSI-投薬支援仕様更新「回帰直線」 周 start
      // 回帰直線「検査項目（回帰直線）」
      let hasRegression = false;
      // 回帰直線
      const shien_kaikichokusen = "regression_line";
      // add FNSI-投薬支援仕様更新「回帰直線」 周 end

      // 対象区分「マスタ利用」
      const taishou_kubun_jouken = "3";
      const taishou_kubun_taijuu = "1";
      const taishou_kubun_baitaru = "5";
      const taishou_kubun_kensa = "2";
      const taishou_kubun_yakuzai = "4";
      // 治療方法「マスタ利用」
      const chiryou_houhou = "method_of_treatment";
      // 治療条件「マスタ利用」
      const chiryou_jouken_39 = "rst_dw2";
      const chiryou_jouken_03 = "target_weight";
      const chiryou_jouken_05 = "dializer";
      const chiryou_jouken_05_06 = "dializer_06";
      const chiryou_jouken_05_07 = "dializer_07";
      const chiryou_jouken_05_08 = "dializer_08";
      const chiryou_jouken_01 = "treatment_time";
      const chiryou_jouken_14 = "blood_flow";
      const chiryou_jouken_16 = "dialysate_flow_rate";
      const chiryou_jouken_19 = "fluid_infusion";
      const chiryou_jouken_20 = "fluid_volume2";
      const chiryou_jouken_25 = "anticoagulant";
      const chiryou_jouken_26 = "anticoagulant_one_shot_amount";
      const chiryou_jouken_27 = "anticoagulant_duration";
      const chiryou_jouken_28 = "anticoagulant_sustained_total_amount";
      const chiryou_jouken_26add28 = "total_amount_of_anticoagulant";
      // 体重「マスタ利用」
      const rst_dw = "rst_dw";
      const weight_before = "weight_before";
      const increase = "increase";
      const increase_rate = "increase_rate";
      const fluid_volume = "fluid_volume";
      // const water_removal_rst = "water_removal_rst";
      const weight_after = "weight_after";
      const reduction = "reduction";
      const reduction_rate = "reduction_rate";
      const ktv_measurements = "ktv_measurements";
      // const urr = "urr";
      const re_loop_rate_main = "re_loop_rate_main";
      const re_loop_rate_main_blood_flow = "re_loop_rate_main_blood_flow";
      // const ctr = "ctr";
      // const sttc_vns_prssr = "sttc_vns_prssr";
      // const iap_rt = "iap_rt";
      // マスタ区分
      const mstMethod = "METHOD";
      const mstDializer = "DIALIZER";
      const mstEquipment = "EQUIPMENT";
      const mstMedicine = "MEDICINE";
      const mstMedicineMix = "MEDICINE_MIX";
      const mstPrescription = "PRESCRIPTION";

      const otherType = [
        chiryou_jouken_01,
        chiryou_jouken_03,
        chiryou_jouken_14,
        chiryou_jouken_16,
        chiryou_jouken_20,
        chiryou_jouken_26,
        chiryou_jouken_27,
        chiryou_jouken_28,
        chiryou_jouken_39
      ];

      const mstType = [
        mstMethod,
        mstDializer,
        mstEquipment,
        mstMedicine,
        mstMedicineMix
      ];

      // 期間終了日計算「すべてグラフ」
      const kikan_shuuryou = item => {
        switch (item.shuukei) {
          // 週「月曜日（今週）～月曜日（来週）」
          case 2:
            return moment(item.kaishi).add(1, 'weeks').day(1).format("YYYYMMDD");
          // 2週「月曜日（今週）～月曜日（再来週）」
          case 3:
            return moment(item.kaishi).add(2, 'weeks').day(1).format("YYYYMMDD");
          // 月「１日（今月）～１日（来月）」
          case 4:
            return moment(item.kaishi).add(1, 'months').startOf('month').format("YYYYMMDD");
          // 3ヶ月
          case 5:
            return moment(item.kaishi).add(3, 'months').startOf('month').format("YYYYMMDD");
          // 日
          default:
            return moment(item.kaishi).add(1, 'days').format("YYYYMMDD");
        }
      };

      // 凡例表示用「すべてグラフ」
      const getPrefix = item => {
        switch (item) {
          case "column":
            return "(棒)";
          case "line":
            return "(線)";
          case "xrange":
          default:
            return "(帯)";
        }
      };

      // DW取得「条件送信前のみ」
      const getDW = treatDate => {
        const result = patDwInfo?.find((item) => {
          return item.dw && moment(item.examDate).format('YYYYMMDD') <= moment(treatDate).format('YYYYMMDD')
        })?.dw || null;
        return result;
      };

      // 前体重実績取得「体重グラフのみ」
      const torie_jisseki_taijuu = (treatDate, startTime) => {
        let result = null;
        for (const weightItem of weights) {
          if (moment(treatDate) > moment(weightItem.treatDate)) {
            break;
          } else if (moment(treatDate) === moment(weightItem.treatDate) && startTime > weightItem.startTime) {
            break;
          }
          result = weightItem;
        }
        return result;
      };

      // 指示・実績区分作成「薬剤グラフのみ」
      const shiji_jisseki_kubun = (item, flag = 'drug') => {
        if (flag === 'treatment') {
          return item.treatmentStatus === "指示" ? "1" : "2"
        }
        if (item.drugStatus === "指示") {
          return "1";
        } else if (item.drugStatus === "実績") {
          return "2";
        } else if (item.drugStatus === "目標値") {
          return "9";
        } else {
          return "0";
        }
      };

      // 集計期間作成「薬剤グラフのみ」
      const shuukei_kikan = item => {
        if (item === "day") {
          return 1;
        } else if (item === "week") {
          return 2;
        } else if (item === "twoWeek") {
          return 3;
        } else if (item === "month") {
          return 4;
        } else if (item === "threeMonth") {
          return 5;
        } else {
          return 0;
        }
      };

      // 集計期間配列作成「薬剤グラフのみ」
      const shuukei_kikan_hairetsu = item => {
        const result = [];

        for (let index = item.kaishi; index < item.shuuryou; ) {
          // 期間終了日計算
          const shuuryou = kikan_shuuryou({
            kaishi: index,
            shuukei: item.shuukei
          });

          result.push({
            kaishi: index,
            shuuryou: shuuryou
          });

          // 期間開始日設定「index++」
          index = shuuryou;
        }

        return result;
      };

      // グラフタイプ「治療条件、治療方法」
      const taipu_jouken = item => {
        switch (item) {
          // ＤＷ「rst_dw2」
          case chiryou_jouken_39:
          // 目標体重「target_weight」
          case chiryou_jouken_03:
          // 血流量「blood_flow」
          case chiryou_jouken_14:
          // 透析液流量「dialysate_flow_rate」
          case chiryou_jouken_16:
          // 補液量「fluid_volume2」
          case chiryou_jouken_20:
          // 抗凝固剤ワンショット量「anticoagulant_one_shot_amount」
          case chiryou_jouken_26:
          // 抗凝固剤持続速度「anticoagulant_duration」
          case chiryou_jouken_27:
          // 抗凝固剤持続総量「anticoagulant_sustained_total_amount」
          case chiryou_jouken_28:
          // 抗凝固剤総量「total_amount_of_anticoagulant」
          case chiryou_jouken_26add28:
            // 折れ線
            return "line";
          // 治療時間「treatment_time」
          case chiryou_jouken_01:
            // 棒グラフ
            return "column";
          // 治療方法「method_of_treatment」
          case chiryou_houhou:
          // ダイアライザ「dializer」
          case chiryou_jouken_05:
          // 吸着カラム
          case chiryou_jouken_05_06:
          // 1次膜
          case chiryou_jouken_05_07:
          // 2次膜
          case chiryou_jouken_05_08:
          // 補液「fluid_infusion」
          case chiryou_jouken_19:
          // 抗凝固剤「anticoagulant」
          case chiryou_jouken_25:
            // 帯グラフ「カスタム」
            return "custom";
          default:
            return "";
        }
      };

      // 治療条件番号「治療条件のみ」
      const bangou_jouken = item => {
        switch (item) {
          // ＤＷ「rst_dw2」
          case chiryou_jouken_39:
            return 39;
          // 目標体重「target_weight」
          case chiryou_jouken_03:
            return 3;
          // 血流量「blood_flow」
          case chiryou_jouken_14:
            return 14;
          // 透析液流量「dialysate_flow_rate」
          case chiryou_jouken_16:
            return 16;
          // 補液量「fluid_volume2」
          case chiryou_jouken_20:
            return 20;
          // 抗凝固剤ワンショット量「anticoagulant_one_shot_amount」
          case chiryou_jouken_26:
            return 26;
          // 抗凝固剤持続速度「anticoagulant_duration」
          case chiryou_jouken_27:
            return 27;
          // 抗凝固剤持続総量「anticoagulant_sustained_total_amount」
          case chiryou_jouken_28:
            return 28;
          // 治療時間「treatment_time」
          case chiryou_jouken_01:
            return 1;
          // ダイアライザ「dializer」
          case chiryou_jouken_05:
            return 5;
          // 吸着カラム
          case chiryou_jouken_05_06:
            return 6;
          // 1次膜
          case chiryou_jouken_05_07:
            return 7;
          // 2次膜
          case chiryou_jouken_05_08:
            return 8;
          // 補液「fluid_infusion」
          case chiryou_jouken_19:
            return 19;
          // 抗凝固剤「anticoagulant」
          case chiryou_jouken_25:
            return 25;
          default:
            return 0;
        }
      };

      // 名称（表示用）「カスタム」
      const meishou_kasutamu = (type, code) => {
        if (code === null) return ''
        switch (type) {
          case mstMethod:
            // 治療方法「治療方法マスタ⇒治療方法名」
            const mstRecordMethod = getters.getMstTreatmentData.find(mstData => {
              return mstData.treatmentCd === code;
            });
            return mstRecordMethod ? mstRecordMethod.treatmentName : "[削除済み]";
          case mstDializer:
            // ダイアライザ「ダイアライザマスタ⇒型番」
            const mstRecordDialyzer = getters.getMstDialyzerData.find(mstData => {
              return mstData.dialyzerCd == code; // mod #9973 value Number→文字列 互換性のある処理  shiyw
            });
            return mstRecordDialyzer ? mstRecordDialyzer.modelNumber : "[削除済み]";
          case mstEquipment:
            // 医療材料「医療材料マスタ⇒医療材料名」
            const mstRecordEquipment = getters.getMstEquipmentData.find(mstData => {
              return mstData.equipmentCd == code; // mod #9973 value Number→文字列 互換性のある処理  shiyw
            });
            return mstRecordEquipment ? mstRecordEquipment.equipmentName : "[削除済み]";
          case mstMedicine:
            // 通常薬剤「薬剤マスタ⇒薬剤名」
            const mstRecordMedicine = getters.getMstMedicineAllergyData.find(mstData => {
              return mstData.medicineCd == code; // mod #9973 value Number→文字列 互換性のある処理  shiyw
            });
            return mstRecordMedicine ? mstRecordMedicine.medicineName : "[削除済み]";
          case mstMedicineMix:
              // 調製薬剤「調製薬剤マスタ⇒調製薬剤名」
            const mstRecordMedicineMix = getters.getMstMedicineMixTabooAllergyData.find(mstData => {
              return mstData.medicineMixCd == code;  // mod #9973 value Number→文字列 互換性のある処理  shiyw
            });
            return mstRecordMedicineMix ? mstRecordMedicineMix.medicineMixName : "[削除済み]";
          default:
            return "";
        }
      };

      // 色（表示用）「カスタム」
      const shoku_kasutamu = (type) => {
        switch (type) {
          case mstMethod:
            // 治療方法（桃）#F09199
            return "#F09199";
          case mstDializer:
            // ダイアライザ（青）#0095D9
            return "#0095D9";
          case mstEquipment:
          case mstMedicine:
          case mstMedicineMix:
            // その他医材（緑）#3EB370
            return "#3EB370";
          case mstPrescription:
            // 処方（黄）#FFD900
            return "#FFD900";
          default:
            return "#000000";
        }
      };

      // Y軸範囲計算関数
      const calculateYAxisRange = (chartType, categoryGraphMax, categoryGraphMin, dataValues) => {
        // 有効なデータをフィルタリング
        const validData = dataValues.filter(val => val !== null && val !== undefined && !isNaN(val) && isFinite(val));

        // データ中の最大値・最小値を取得
        const dataMax = validData.length > 0 ? Math.max(...validData) : 0;
        const dataMin = validData.length > 0 ? Math.min(...validData) : 0;

        // graphMaxとgraphMinが設定されていない場合
        if (!isValidNumber(categoryGraphMax) && !isValidNumber(categoryGraphMin)) {
          return {
            yAxisMax: Number(dataMax) - Number(dataMin) > 0 ? Number(dataMax) : Number(dataMin) + 4,
            yAxisMin: dataMin
          };
        }

        // graphMaxとgraphMinが設定されている場合
        if (isValidNumber(categoryGraphMax) && isValidNumber(categoryGraphMin)) {
          // line類型の場合は設定値を使用
          if (chartType === "line") {
            return {
              yAxisMax: Number(categoryGraphMax),
              yAxisMin: Number(categoryGraphMin)
            };
          } else {
            // その他の類型はデータの最大値・最小値を使用
            return {
              yAxisMax: Math.max(Number(dataMax), Number(categoryGraphMax)),
              yAxisMin: Math.min(dataMin, categoryGraphMin)
            };
          }
        }

        // 片方のみ設定されている場合は従来の getThreshold ロジックを使用
        const {max, min} = getThreshold(categoryGraphMax, categoryGraphMin, dataValues, chartType);
        return {
          yAxisMax: Number(max) - Number(min) > 0 ? Number(max) : Number(min) + 4,
          yAxisMin: min
        };
      };

      // グラフデータ作成「治療条件」
      const gurafu_deta_sakusei_jouken = (subCategory, ind_rst_class) => {
        let itemNo = subCategory.itemNo;
        const chartType = taipu_jouken(itemNo);
        const no = bangou_jouken(itemNo);
        const valSubData = [];
        const seriesSubData = [];

        if (itemNo === chiryou_houhou) {
          // 治療条件存在場合「治療方法コード」「帯グラフ」
          // 治療方法項目を取得
          const methods = [];
          const methodsSet = new Set();
          const customChiryouHouhouSet = new Set(custom_chiryou_houhou.map(p => p.mstCode));

          const conditionsForIndRstClass = conditions.filter((item) => {
            return ind_rst_class === "1" ? item.indTreatmentCd : item.rstTreatmentCd
          })
          if (conditionsForIndRstClass.length === 0) {
            seriesSubData.push({
              mstType: mstMethod,
              mstCode: null,
              prefixName: "(治療方法)",
              subItems: []
            });
          }
          for (const conditionItem of conditionsForIndRstClass) {
            let methodCode = null;
            if (ind_rst_class === "1") {
              methodCode = conditionItem?.indTreatmentCd || null;
            } else if (ind_rst_class === "2") {
              methodCode = conditionItem?.rstTreatmentCd || null;
            }

            if (methodCode && !methodsSet.has(methodCode)) {
              methodsSet.add(methodCode);
              methods.push({
                treatmentCd: methodCode,
                treatmentClass: ind_rst_class,
                prefixName: "(治療方法)"
              });

              if (!customChiryouHouhouSet.has(methodCode)) {
                customChiryouHouhouSet.add(methodCode);
                custom_chiryou_houhou.push({
                  mstType: mstMethod,
                  mstCode: methodCode,
                  index: custom_chiryou_houhou.length
                });
              }
            }
          }
          // 治療方法データを作成「治療方法項目分」
          for (const method of methods) {
            // 期間開始日
            let x = 0;
            // 期間終了日
            let x2 = 0;
            let pushed = true;
            const seriesSubItem = [];

            // 対象データを取得
            conditions.filter(p => {
              // 指示・治療方法情報
              if (method.treatmentClass === "1" && method.treatmentCd === p.indTreatmentCd) {
                return true;
              }
              // 実績・治療方法情報
              if (method.treatmentClass === "2" && method.treatmentCd === p.rstTreatmentCd) {
                return true;
              }
              return false;
            })
              // ソート順
              .sort(function(a, b) {
                if (a.treatDate === b.treatDate) {
                  if (a.ordNo > b.ordNo) {
                    return 1;
                  } else {
                    return -1;
                  }
                } else if (a.treatDate > b.treatDate) {
                  return 1;
                } else {
                  return -1;
                }
              })
              // マージ計算
              .forEach(p => {
                if (pushed) {
                  x = p.treatDate;
                  x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  pushed = false;
                } else {
                  if (x === p.treatDate) {
                    // 「治療日＝開始日」本日その他予定「スキップ」
                    return;
                  } else if (x2 === p.treatDate) {
                    // 「治療日＝終了日」連続データ「マージ」
                    x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  } else {
                    seriesSubItem.push([
                      x,
                      // x2,
                      moment(x2).subtract(1, 'seconds'),
                      0
                    ]);
                    // pushed = true;
                    x = p.treatDate;
                    x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  }
                }
              });

            if (!pushed) {
              seriesSubItem.push([
                x,
                // x2,
                moment(x2).subtract(1, 'seconds'),
                0
              ]);
            }

            seriesSubData.push({
              mstType: mstMethod,
              mstCode: method.treatmentCd,
              prefixName: method.prefixName,
              subItems: seriesSubItem
            });
          }
        } else if (itemNo === chiryou_jouken_05) {
          // ダイアライザ場合「医材コード」「帯グラフ」
          const cond05 = [];
          const cond06 = [];
          const cond07 = [];
          const cond08 = [];
          const no06 = bangou_jouken(chiryou_jouken_05_06);
          const no07 = bangou_jouken(chiryou_jouken_05_07);
          const no08 = bangou_jouken(chiryou_jouken_05_08);
          // ダイアライザ項目を取得
          const dializers = [];
          for (const conditionItem of conditions) {
            const condInfo = ind_rst_class === "1" ? conditionItem.indCondInfo : (ind_rst_class === "2" ? conditionItem.rstCondInfo : null);
            if (condInfo && condInfo.hasOwnProperty(no) && condInfo[no].value && !cond05.find(p => { return p.condCode == condInfo[no].value; })) {
              cond05.push({
                condCode: condInfo[no].value,
                condClass: ind_rst_class,
                prefixName: "(ダイアライザ)",
                no: no
              });
              if (!custom_chiryou_jouken_05.find(p => { return p.mstCode == condInfo[no].value; })) { // mod #9973 value Number→文字列  shiyw
                custom_chiryou_jouken_05.push({
                  mstType: mstDializer,
                  mstCode: condInfo[no].value,
                  index: custom_chiryou_jouken_05.length
                });
              }
            }
            if (condInfo && condInfo.hasOwnProperty(no06) && condInfo[no06].value && !cond06.find(p => { return p.condCode == condInfo[no06].value; })) { // mod #9973 value Number→文字列  shiyw
              cond06.push({
                condCode: condInfo[no06].value,
                condClass: ind_rst_class,
                prefixName: "(吸着カラム)",
                no: no06
              });
              if (!custom_chiryou_jouken_05_06.find(p => { return p.mstCode == condInfo[no06].value; })) { // mod #9973 value Number→文字列  shiyw
                custom_chiryou_jouken_05_06.push({
                  mstType: mstEquipment,
                  mstCode: condInfo[no06].value,
                  index: custom_chiryou_jouken_05_06.length
                });
              }
            }
            if (condInfo && condInfo.hasOwnProperty(no07) && condInfo[no07].value && !cond07.find(p => { return p.condCode == condInfo[no07].value; })) { // mod #9973 value Number→文字列  shiyw
              cond07.push({
                condCode: condInfo[no07].value,
                condClass: ind_rst_class,
                prefixName: "(1次膜)",
                no: no07
              });
              if (!custom_chiryou_jouken_05_07.find(p => { return p.mstCode == condInfo[no07].value; })) { // mod #9973 value Number→文字列  shiyw
                custom_chiryou_jouken_05_07.push({
                  mstType: mstEquipment,
                  mstCode: condInfo[no07].value,
                  index: custom_chiryou_jouken_05_07.length
                });
              }
            }
            if (condInfo && condInfo.hasOwnProperty(no08) && condInfo[no08].value && !cond08.find(p => { return p.condCode == condInfo[no08].value; })) { // mod #9973 value Number→文字列  shiyw
              cond08.push({
                condCode: condInfo[no08].value,
                condClass: ind_rst_class,
                prefixName: "(2次膜)",
                no: no08
              });
              if (!custom_chiryou_jouken_05_08.find(p => { return p.mstCode == condInfo[no08].value; })) { // mod #9973 value Number→文字列  shiyw
                custom_chiryou_jouken_05_08.push({
                  mstType: mstEquipment,
                  mstCode: condInfo[no08].value,
                  index: custom_chiryou_jouken_05_08.length
                });
              }
            }
          }
          dializers.push(...cond05, ...cond06, ...cond07, ...cond08);
          // ダイアライザデータを作成
          for (const dializer of dializers) {
            // 期間開始日
            let x = 0;
            // 期間終了日
            let x2 = 0;
            let pushed = true;
            const seriesSubItem = [];

            // 対象データを取得
            conditions.filter(p => {
              // 指示・治療方法情報
              // if (dializer.condClass === "1" && p.indCondInfo && p.indCondInfo.hasOwnProperty(dializer.no)) {
              if (dializer.condClass === "1" && p.indCondInfo && p.indCondInfo.hasOwnProperty(dializer.no)
                &&p.indCondInfo[dializer.no]&&p.indCondInfo[dializer.no].value
                &&p.indCondInfo[dializer.no].value==dializer.condCode) {
                return true;
              }
              // 実績・治療方法情報
              // if (dializer.condClass === "2" && p.rstCondInfo && p.rstCondInfo.hasOwnProperty(dializer.no)) {
              if (dializer.condClass === "2" && p.rstCondInfo && p.rstCondInfo.hasOwnProperty(dializer.no)
                &&p.rstCondInfo[dializer.no]&&p.rstCondInfo[dializer.no].value
                &&p.rstCondInfo[dializer.no].value==dializer.condCode) {
                return true;
              }
              return false;
            })
              // ソート順
              .sort(function(a, b) {
                if (a.treatDate === b.treatDate) {
                  if (a.ordNo > b.ordNo) {
                    return 1;
                  } else {
                    return -1;
                  }
                } else if (a.treatDate > b.treatDate) {
                  return 1;
                } else {
                  return -1;
                }
              })
              // マージ計算
              .forEach(p => {
                if (pushed) {
                  x = p.treatDate;
                  x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  pushed = false;
                } else {
                  if (x === p.treatDate) {
                    // 「治療日＝開始日」本日その他予定「スキップ」
                    return;
                  } else if (x2 === p.treatDate) {
                    // 「治療日＝終了日」連続データ「マージ」
                    x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  } else {
                    seriesSubItem.push([
                      x,
                      // x2,
                      moment(x2).subtract(1, 'seconds'),
                      0
                    ]);
                    // pushed = true;
                    x = p.treatDate;
                    x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  }
                }
              });

            if (!pushed) {
              seriesSubItem.push([
                x,
                // x2,
                moment(x2).subtract(1, 'seconds'),
                0
              ]);
            }

            seriesSubData.push({
              mstType: no === dializer.no ? mstDializer : mstEquipment,
              mstCode: dializer.condCode,
              prefixName: dializer.prefixName,
              subItems: seriesSubItem
            });
          }
        } else if (itemNo === chiryou_jouken_19) {
          // 補液場合「薬剤コード」「帯グラフ」
          // 補液項目を取得
          const fluids = [];
          for (const conditionItem of conditions) {
            const condInfo = ind_rst_class === "1" ? conditionItem.indCondInfo : (ind_rst_class === "2" ? conditionItem.rstCondInfo : null);
            if (condInfo && condInfo.hasOwnProperty(no) && condInfo[no].value && !fluids.find(p => { return p.condCode == condInfo[no].value; })) { // mod #9973 value Number→文字列  shiyw
              fluids.push({
                condCode: condInfo[no].value,
                condClass: ind_rst_class,
                prefixName: "(補液)",
                no: no
              });
              if (!custom_chiryou_jouken_19.find(p => { return p.mstCode == condInfo[no].value; })) { // mod #9973 value Number→文字列  shiyw
                custom_chiryou_jouken_19.push({
                  mstType: mstMedicine,
                  mstCode: condInfo[no].value,
                  index: custom_chiryou_jouken_19.length
                });
              }
            }
          }
          // 補液データを作成
          for (const fluid of fluids) {
            // 期間開始日
            let x = 0;
            // 期間終了日
            let x2 = 0;
            let pushed = true;
            const seriesSubItem = [];

            // 対象データを取得
            conditions.filter(p => {
              // 指示・治療方法情報
              // if (fluid.condClass === "1" && p.indCondInfo && p.indCondInfo.hasOwnProperty(fluid.no)) {
              if (fluid.condClass === "1" && p.indCondInfo && p.indCondInfo.hasOwnProperty(fluid.no)
                &&p.indCondInfo[fluid.no]&&p.indCondInfo[fluid.no].value
                &&p.indCondInfo[fluid.no].value==fluid.condCode) {
                return true;
              }
              // 実績・治療方法情報
              // if (fluid.condClass === "2" && p.rstCondInfo && p.rstCondInfo.hasOwnProperty(fluid.no)) {
              if (fluid.condClass === "2" && p.rstCondInfo && p.rstCondInfo.hasOwnProperty(fluid.no)
                &&p.rstCondInfo[fluid.no]&&p.rstCondInfo[fluid.no].value
                &&p.rstCondInfo[fluid.no].value==fluid.condCode) {
                return true;
              }
              return false;
            })
              // ソート順
              .sort(function(a, b) {
                if (a.treatDate === b.treatDate) {
                  if (a.ordNo > b.ordNo) {
                    return 1;
                  } else {
                    return -1;
                  }
                } else if (a.treatDate > b.treatDate) {
                  return 1;
                } else {
                  return -1;
                }
              })
              // マージ計算
              .forEach(p => {
                if (pushed) {
                  x = p.treatDate;
                  x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  pushed = false;
                } else {
                  if (x === p.treatDate) {
                    // 「治療日＝開始日」本日その他予定「スキップ」
                    return;
                  } else if (x2 === p.treatDate) {
                    // 「治療日＝終了日」連続データ「マージ」
                    x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  } else {
                    seriesSubItem.push([
                      x,
                      // x2,
                      moment(x2).subtract(1, 'seconds'),
                      0
                    ]);
                    // pushed = true;
                    x = p.treatDate;
                    x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  }
                }
              });

            if (!pushed) {
              seriesSubItem.push([
                x,
                // x2,
                moment(x2).subtract(1, 'seconds'),
                0
              ]);
            }

            seriesSubData.push({
              mstType: mstMedicine,
              mstCode: fluid.condCode,
              prefixName: fluid.prefixName,
              subItems: seriesSubItem
            });
          }
        } else if (itemNo === chiryou_jouken_25) {
          // 抗凝固剤場合「薬剤コード」「調製薬剤コード」「帯グラフ」
          // 抗凝固剤項目を取得
          const anticoagulants = [];
          for (const conditionItem of conditions) {
            const condInfo = ind_rst_class === "1" ? conditionItem.indCondInfo : (ind_rst_class === "2" ? conditionItem.rstCondInfo : null);
            if (condInfo && condInfo.hasOwnProperty(no) && condInfo[no].value && !anticoagulants.find(p => { return p.condCode == condInfo[no].value; })) { // mod #9973 value Number→文字列  shiyw
              anticoagulants.push({
                condCode: condInfo[no].value,
                condClass: ind_rst_class,
                prefixName: "(抗凝固剤)",
                medicine_type: condInfo[no].medicine_type,
                no: no
              });
              if (!custom_chiryou_jouken_25.find(p => { return p.mstCode == condInfo[no].value; })) { // mod #9973 value Number→文字列  shiyw
                custom_chiryou_jouken_25.push({
                  mstType: condInfo[no].medicine_type == 2 ? mstMedicineMix : mstMedicine,
                  mstCode: condInfo[no].value,
                  index: custom_chiryou_jouken_25.length
                });
              }
            }
          }
          // 抗凝固剤データを作成
          for (const anticoagulant of anticoagulants) {
            // 期間開始日
            let x = 0;
            // 期間終了日
            let x2 = 0;
            let pushed = true;
            const seriesSubItem = [];

            // 対象データを取得
            conditions.filter(p => {
              // 指示・治療方法情報
              // if (anticoagulant.condClass === "1" && p.indCondInfo && p.indCondInfo.hasOwnProperty(anticoagulant.no)) {
              if (anticoagulant.condClass === "1" && p.indCondInfo && p.indCondInfo.hasOwnProperty(anticoagulant.no)
                &&p.indCondInfo[anticoagulant.no]&&p.indCondInfo[anticoagulant.no].value
                &&p.indCondInfo[anticoagulant.no].value==anticoagulant.condCode) {
                return true;
              }
              // 実績・治療方法情報
              // if (anticoagulant.condClass === "2" && p.rstCondInfo && p.rstCondInfo.hasOwnProperty(anticoagulant.no)) {
              if (anticoagulant.condClass === "2" && p.rstCondInfo && p.rstCondInfo.hasOwnProperty(anticoagulant.no)
                &&p.rstCondInfo[anticoagulant.no]&&p.rstCondInfo[anticoagulant.no].value
                &&p.rstCondInfo[anticoagulant.no].value==anticoagulant.condCode) {
                return true;
              }
              return false;
            })
              // ソート順
              .sort(function(a, b) {
                if (a.treatDate === b.treatDate) {
                  if (a.ordNo > b.ordNo) {
                    return 1;
                  } else {
                    return -1;
                  }
                } else if (a.treatDate > b.treatDate) {
                  return 1;
                } else {
                  return -1;
                }
              })
              // マージ計算
              .forEach(p => {
                if (pushed) {
                  x = p.treatDate;
                  x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  pushed = false;
                } else {
                  if (x === p.treatDate) {
                    // 「治療日＝開始日」本日その他予定「スキップ」
                    return;
                  } else if (x2 === p.treatDate) {
                    // 「治療日＝終了日」連続データ「マージ」
                    x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  } else {
                    seriesSubItem.push([
                      x,
                      // mod 9592 複合グラフが正しく表示しない zy start
                      // x2
                      moment(x2).subtract(1, 'seconds'),
                      0
                    ]);
                    // pushed = true;
                    x = p.treatDate;
                    x2 = moment(p.treatDate).add(1, 'days').format("YYYYMMDD");
                  }
                }
              });

            if (!pushed) {
              seriesSubItem.push([
                x,
                // x2,
                moment(x2).subtract(1, 'seconds'),
                0
              ]);
            }

            seriesSubData.push({
              mstType: anticoagulant.medicine_type == 2 ? mstMedicineMix : mstMedicine,
              mstCode: anticoagulant.condCode,
              prefixName: anticoagulant.prefixName,
              subItems: seriesSubItem
            });
          }
        } else {
          // その他場合「棒グラフ」「折れ線」
          for (const conditionItem of conditions) {
            if (itemNo === chiryou_jouken_39) {
              // ＤＷ場合「折れ線」「実績はrst_dw、指示値は患者情報の身体情報のdw」
              const dwInfo = ind_rst_class === "1" ? getDW(conditionItem.treatDate) : (ind_rst_class === "2" ? conditionItem.dw : null);
              if (dwInfo != null) {
                valSubData.push(Number(dwInfo));
                seriesSubData.push([conditionItem.treatDate, Number(dwInfo)]);
              }
            } else {
              const condInfo = ind_rst_class === "1" ? conditionItem.indCondInfo : (ind_rst_class === "2" ? conditionItem.rstCondInfo : null);
              if (condInfo) {
                if (itemNo === chiryou_jouken_03) {
                  // 目標体重場合「折れ線」「-1場合非表示」TODO：確認待ち
                  if (condInfo?.[no]?.value && condInfo[no].value > 0) {
                    valSubData.push(Number(condInfo[no].value));
                    seriesSubData.push([conditionItem.treatDate, Number(condInfo[no].value)]);
                  }
                } else if (itemNo === chiryou_jouken_26add28) {
                  // 抗凝固剤総量場合「折れ線」「持続総量＋ワンショット量」
                  let val = null;
                  const no26 = bangou_jouken(chiryou_jouken_26);
                  const no28 = bangou_jouken(chiryou_jouken_28);
                  if (condInfo?.[no26]?.value != null) {
                    val = val + Number(condInfo[no26].value);
                  }
                  if (condInfo?.[no28]?.value != null) {
                    val = val + Number(condInfo[no28].value);
                  }
                  // 入力データ ≠ null(未指定)の場合
                  if (val != null) {
                    valSubData.push(val);
                    seriesSubData.push([conditionItem.treatDate, val]);
                  }
                } else if (otherType.includes(itemNo)) {
                  if (condInfo?.[no]?.value) {
                    valSubData.push(Number(condInfo[no].value));
                    seriesSubData.push([conditionItem.treatDate, Number(condInfo[no].value)]);
                  }
                }
              }
            }
          }
        }
        return {
          valData: valSubData,
          seriesData: seriesSubData.length > 0 ? seriesSubData : [],
          chartType: chartType
        };
      };

      // グラフデータ作成「体重」
      const gurafu_deta_sakusei_taijuu = subCategory => {
        let itemNo = subCategory.itemNo;

        const chartType = "line";
        const valSubData = [];
        const seriesSubData = [];
        for (const weightItem of weights) {
          let val = null;
          if (itemNo === rst_dw) {
            // DW場合
            if (weightItem.dw != null) {
              val = Number(weightItem.dw);
            }
          } else if (weightItem.weightInfo) {
            // 体重情報存在場合
            if (itemNo === increase) {
              // 増加量場合「increase」「前体重-前回後体重」
              //mod internal 5639 【計画】画面中的【複合グラフ】数据显示不正 張 start
              // const weightItemZen = torie_jisseki_taijuu(weightItem.treatDate, weightItem.startTime);
              // if (weightItem.lastWeightAfter != null && weightItem.weightInfo != null) {
              if (weightItem.weightInfo[weight_before] != null && weightItem.lastWeightAfter!= null) {
                const valWeightBefore = weightItem.weightInfo[weight_before] ? Number(weightItem.weightInfo[weight_before]) : 0;
                // const valWeightAfterZen =weightItemZen.weightInfo[weight_after] ? Number(weightItemZen.weightInfo[weight_after]) : 0;
                const valWeightAfterZen = weightItem.lastWeightAfter ? Number(weightItem.lastWeightAfter) : 0;
                val = valWeightBefore - valWeightAfterZen;
              }
              // }
            } else if (itemNo === increase_rate) {
              // 増加率場合「increase_rate」「(前体重-前回後体重)/DW*100」
              if (weightItem.dw) {
                // const weightItemZen = torie_jisseki_taijuu(weightItem.treatDate, weightItem.startTime);
                // if (weightItemZen != null && weightItemZen.weightInfo != null) {
                if (weightItem.weightInfo[weight_before] != null && weightItem.lastWeightAfter != null) {
                  const valWeightBefore = weightItem.weightInfo[weight_before] ? Number(weightItem.weightInfo[weight_before]) : 0;
                  // const valWeightAfterZen = weightItemZen.weightInfo[weight_after] ? Number(weightItemZen.weightInfo[weight_after]) : 0;
                  const valWeightAfterZen = weightItem.lastWeightAfter ? Number(weightItem.lastWeightAfter) : 0;
                  const valDW = weightItem.dw ? Number(weightItem.dw) : 0;
                  val = Number((valWeightBefore - valWeightAfterZen) / valDW * 100);
                }
                // }
              }
            } else if (itemNo === reduction) {
              // 減少量場合「reduction」「前体重-後体重」
              if (weightItem.weightInfo[weight_before] != null && weightItem.weightInfo[weight_after] != null) {
                const valWeightBefore = weightItem.weightInfo[weight_before] ? Number(weightItem.weightInfo[weight_before]) : 0;
                const valWeightAfter = weightItem.weightInfo[weight_after] ? Number(weightItem.weightInfo[weight_after]) : 0;
                val = valWeightBefore - valWeightAfter;
              }
            } else if (itemNo === reduction_rate) {
              // 減少率場合「reduction_rate」「(前体重-後体重)/DW*100」
              if (weightItem.dw) {
                if (weightItem.weightInfo[weight_before] != null && weightItem.weightInfo[weight_after] != null) {
                  const valWeightBefore = weightItem.weightInfo[weight_before] ? Number(weightItem.weightInfo[weight_before]) : 0;
                  const valWeightAfter = weightItem.weightInfo[weight_after] ? Number(weightItem.weightInfo[weight_after]) : 0;
                  const valDW = weightItem.dw ? Number(weightItem.dw) : 0;
                  val = Number((valWeightBefore - valWeightAfter) / valDW * 100);
                }
              }
            } else if (itemNo === re_loop_rate_main) {
              // 再循環率場合「re_loop_rate_main」
              // mod #11773
              if (weightItem.weightInfo.recrcl_rt && weightItem.weightInfo.recrcl_rt["valid_no"]) {
                const validNo = weightItem.weightInfo.recrcl_rt["valid_no"];
                if (weightItem.weightInfo.recrcl_rt.hasOwnProperty(validNo)) {
                  if (weightItem.weightInfo.recrcl_rt[validNo].rate != null) {
                    val = Number(weightItem.weightInfo.recrcl_rt[validNo].rate);
                  }
                }
              }
              // mod #11773
            } else if (itemNo === re_loop_rate_main_blood_flow) {
              // 再循環率測定時血流量場合「re_loop_rate_main_blood_flow」
              // mod #11773
              if (weightItem.weightInfo.recrcl_rt && weightItem.weightInfo.recrcl_rt["valid_no"]) {
                const validNo = weightItem.weightInfo.recrcl_rt["valid_no"];
                if (weightItem.weightInfo.recrcl_rt.hasOwnProperty(validNo)) {
                  if (weightItem.weightInfo.recrcl_rt[validNo].bld_vl != null) {
                    val = Number(weightItem.weightInfo.recrcl_rt[validNo].bld_vl);
                  }
                }
              }
              // mod #11773
            } else if (itemNo === fluid_volume) {
              // 補液量場合「add_water_total」
              if (weightItem.weightInfo["add_water_total"] != null) {
                val = Number(weightItem.weightInfo["add_water_total"]);
              }
            } else if (itemNo === ktv_measurements) {
              // Kt/V測定値場合「kt_v_measure」
              if (weightItem.weightInfo["kt_v_measure"] != null) {
                val = Number(weightItem.weightInfo["kt_v_measure"]);
              }
            } else {
              // その他場合
              val = weightItem.weightInfo[itemNo] != undefined && weightItem.weightInfo[itemNo] != null ? Number(weightItem.weightInfo[itemNo]) : null;
            }
          }
          // 入力データ ≠ null(未指定)の場合
          if (val != null) {
            // 表示データ設定「上限値、下限値更新用」
            // valSubData.push(val);
            // mod #IES_6501 dou start
            // valSubData.push(Number(val).toFixed(2));
            valSubData.push(toFixed(Number(val), 2));
            // mod #IES_6501 dou end
            // シリーズデータを作成
            // seriesSubData.push([weightItem.treatDate, val]);
            // mod #IES_6501 dou start
            // seriesSubData.push([weightItem.treatDate, Number(val).toFixed(2)]);
            seriesSubData.push([weightItem.treatDate, toFixed(Number(val), 2)]);
            // mod #IES_6501 dou end
          }
        }

        return {
          valData: valSubData,
          seriesData: seriesSubData.length > 0 ? seriesSubData : [],
          chartType: chartType
        };
      };

      // グラフデータ作成「バイタル」
      const gurafu_deta_sakusei_baitaru = subCategory => {
        let tableType = subCategory.tableType;
        //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
        // let itemNo = tableType === 1 ? subCategory.moniNo : subCategory.itemName;
        // mod #10077 by zhangruixue 2023-11-28  start
        // let itemNo = tableType == 2&&subCategory.vitalMonitorClass==2 ? subCategory.itemName : subCategory.moniNo;
        let itemNo = subCategory.moniNo;
        // mod #10077 by zhangruixue 2023-11-28  end
        //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
        const chartType = "line";
        const valSubData = [];
        const seriesSubData = [];

        for (const vitalItem of mniMonitor) {
          let val = null;
          if (vitalItem.monitorData && vitalItem.monitorData.hasOwnProperty(itemNo)) {
            // バイタル・モニタ情報存在場合
            if (vitalItem.monitorData[itemNo] != null) {
              //mod #10077 by zhangruixue 2024-2-20  start
              if(isStringNumeric(convertToHalfWidth(vitalItem.monitorData[itemNo]))){
                val = Number(convertToHalfWidth(vitalItem.monitorData[itemNo]));
              }
              // val = Number(vitalItem.monitorData[itemNo]);
              //mod #10077 by zhangruixue 2024-2-20  end
            }
          }
          // 入力データ ≠ null(未指定)の場合
          if (val != null) {
            // 表示データ設定「上限値、下限値更新用」
            valSubData.push(val);
            // シリーズデータを作成
            seriesSubData.push([vitalItem.occurDate, val]);
          }
        }

        return {
          valData: valSubData,
          seriesData: seriesSubData.length > 0 ? seriesSubData : [],
          chartType: chartType
        };
      };

      // グラフデータ作成「検査結果」
      const gurafu_deta_sakusei_kensa = subCategory => {
        let itemNo = subCategory.itemNo.toString();
        // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
        let itemExamClass = subCategory.itemExamClass!= null && subCategory.itemExamClass!== '' ? subCategory.itemExamClass : '3';

        const chartType = "line";
        const valSubData = [];
        const seriesSubData = [];

        const latestByDayAndClass = {};
        for (const examRecord of patExamMain) {
          if (!examRecord.examInfo) continue;

          for (const examItem of examRecord.examInfo) {
            if (
              examItem.item_cd.toString() === itemNo &&
              examItem.result != null
            ) {
              const category = examRecord.regOrderClass;
              const resultTime = new Date(examRecord.examDate);

              const key = `${resultTime}_${itemExamClass == '3' ? category : 'ONLY'}`;

              if (itemExamClass == '3' || itemExamClass == category) {
                const existing = latestByDayAndClass[key];
                if (!existing || new Date(existing.date) <= resultTime) {
                  latestByDayAndClass[key] = {
                    date: examRecord.examDate,
                    val: Number(convertToHalfWidth(examItem.result)),
                    examClass: examRecord.regOrderClass
                  };
                }
              }
            }
          }
        }
        const priority = { "1": 0, "2": 1, "0": 2 };
        const sortedRecords = Object.values(latestByDayAndClass).sort((a, b) => {
          const dateA = new Date(a.date);
          const dateB = new Date(b.date);
          if (dateA === dateB) {
            return (priority[a.examClass] ?? 99) - (priority[b.examClass] ?? 99);
          } else {
            return dateA < dateB ? -1 : 1;
          }
        });

        for (const { date, val, examClass} of Object.values(sortedRecords)) {
          if (val != null) {
            valSubData.push(val);
            seriesSubData.push([date, val, examClass]);
          }
        }
        // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end

        return {
          valData: valSubData,
          seriesData: seriesSubData.length > 0 ? seriesSubData : [],
          chartType: chartType
        };
      };

      // グラフデータ作成「投与薬剤」
      const gurafu_deta_sakusei_yakuzai = (subCategory, ind_rst_class,mstMedicineGroupData) => {
        let itemNo = "0";
        let itemDate = shuukei_kikan(subCategory.itemDate);
        let chartType = "";

        let valSubData = [];
        let seriesSubData = [];
        const rangeData = [];
        // 通常薬剤条件
        // 「0：治療条件」「1：投与薬剤」「3：愁訴処置」
        const sourceArr_tsuujou = ["0", "1", "3"];
        // 「0：治療条件」⇒「08：透析液」「09：補液」「10：抗凝固剤」
        // 「1：投与薬剤」⇒「12：投与薬剤」
        // 「3：愁訴処置」⇒「14：処置薬剤」
        const suppliesArr_tsuujou = ["08", "09", "10", "12", "14"];
        // 調製薬剤条件
        // 「0：治療条件」「1：投与薬剤」「3：愁訴処置」
        const sourceArr_chousei = ["0", "1", "3"];
        // 「0：治療条件」⇒「17：抗凝固剤調製薬剤」
        // 「1：投与薬剤」⇒「13：調製薬剤」
        // 「3：愁訴処置」⇒「15：処置調製薬剤」
        const suppliesArr_chousei = ["17", "13", "15"];
        // 処方条件
        // 「4：処方」
        const sourceArr_shohou = ["4"];
        // 「4：処方」⇒ 23:処方(薬剤) 24:処方(一般名処方)
        const suppliesArr_shohou = ["23", "24"];
        // 指示・実績区分⇒「4：交付済み」
        //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
        // const indRstClass_shohou = ["4"];
        let indRstClass_shohou = (ind_rst_class == "1" ? ["3"] : ["4"]);
        //mod 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end

        // 期間データを作成「集計期間」
        rangeData.push(...shuukei_kikan_hairetsu({
          // 集計期間「-1：未登録」「1：日」
          // 患者経過総合ビューアレイアウトマスタにて「集計期間」を「ヘッダー」と「明細」それぞれに指定された場合、「明細」を優先させる。
          // 「集計期間」を指定されていない「明細」は「ヘッダー」の「集計期間」に従う。
          // 「ヘッダー」、「明細」共に指定されていない場合、「日」単位での集計とする。
          shuukei: itemDate,
          // 期間開始
          kaishi: moment(startDate).format("YYYYMMDD"),
          // 期間終了
          shuuryou: moment(endDate).format("YYYYMMDD")
        }));

        // 表示データを作成「集計」
        if (subCategory.itemNo.toString().includes("MEDICINE_GROUP")) {
          // 投薬場合「薬効換算」
          //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
          if (subCategory.itemNo.includes("MEDICINE_GROUPS")) {
            itemNo = subCategory.itemNo.replace("MEDICINE_GROUPS", "");
            chartType = "xrange";
          } else {
            // 投薬場合「薬効換算」
            itemNo = subCategory.itemNo.replace("MEDICINE_GROUP", "");
            // 棒グラフ
            chartType = "column";
          }
          // 薬効換算マスタ情報
          const mstGroup = mstMedicineGroupData.find(mst => {
            return mst.medicineGroupCd.toString() === itemNo;
          });
          if (mstGroup&& chartType === "column") {
            const regMedicineInfo = JSON.parse(mstGroup.regMedicineInfo);
            rangeData.forEach(item => {
              let val = 0;
              regMedicineInfo.forEach(medicineInfo => {
                if (medicineInfo.del === "0") {
                  // let valItem = ordMaterialSaveData
                  let valItem = ordMaterialSave
                    .filter(ord => {
                      if (medicineInfo.mediFlg === "0") {
                        // 通常薬剤
                        return (
                          // データ基準日⇒期間開始日「集計期間計算」
                          ord.suppliesBaseDate >= item.kaishi &&
                          // データ基準日⇒期間終了日「集計期間計算」
                          ord.suppliesBaseDate < item.shuuryou &&
                          // データ発生元区分「配列存在」
                          sourceArr_tsuujou.includes(ord.suppliesSourceClass) &&
                          // 物品区分「配列存在」
                          suppliesArr_tsuujou.includes(ord.suppliesClass) &&
                          // 物品コード「マスタから取得」
                          ord.suppliesCd === medicineInfo.cd.toString() &&
                          // 調製薬剤コード「ヌル固定」
                          ord.medicineMixCd === null &&
                          // 指示・実績区分「マスタから取得」
                          ord.indRstClass === ind_rst_class
                        );
                      } else if (medicineInfo.mediFlg === "2") {
                        // 調製薬剤
                        return (
                          // データ基準日⇒期間開始日「集計期間計算」
                          ord.suppliesBaseDate >= item.kaishi &&
                          // データ基準日⇒期間終了日「集計期間計算」
                          ord.suppliesBaseDate < item.shuuryou &&
                          // データ発生元区分「配列存在」
                          sourceArr_chousei.includes(ord.suppliesSourceClass) &&
                          // 物品区分「配列存在」
                          suppliesArr_chousei.includes(ord.suppliesClass) &&
                          // 物品コード「ヌル固定」
                          ord.suppliesCd === null &&
                          // 調製薬剤コード「マスタから取得」
                          ord.medicineMixCd === medicineInfo.cd.toString() &&
                          // 指示・実績区分「マスタから取得」
                          ord.indRstClass === ind_rst_class
                        );
                      }
                    })
                    .reduce((prev, cur) => {
                      // 指示・実績値項目 × 交換値を集計
                      return Number(cur.indRstValue ? cur.indRstValue : 0) * Number(medicineInfo.conVal) + Number(prev)
                    }, 0);

                  // 薬剤換算集計
                  val = Number(val) + Number(valItem);
                }
              });

              if (val) {
                // 表示データ設定「上限値、下限値更新用」
                // hyouji_deta_hairetsu.push(val);
                valSubData.push(val);
                // シリーズデータを作成
                // seriesData.push([item.kaishi, val]);
                seriesSubData.push([item.kaishi, val]);
              }
            });
          } else if (mstGroup && chartType === "xrange") { // 処方
            const start = moment(startDate).format("YYYYMMDD");
            const end = moment(endDate).format("YYYYMMDD");
            const regMedicineInfo = JSON.parse(mstGroup.regMedicineInfo).filter(item => item.del === "0");

            regMedicineInfo.forEach(medicineInfo => {
              let valItem = ordMaterialSave.filter(ord => {
                return (
                  // データ基準日⇒期間開始日「集計期間計算」
                  ord.suppliesBaseDate >= start &&
                  // データ基準日⇒期間終了日「集計期間計算」
                  ord.suppliesBaseDate < end &&
                  // データ発生元区分「配列存在」
                  sourceArr_shohou.includes(ord.suppliesSourceClass) &&
                  // 物品区分「配列存在」
                  suppliesArr_shohou.includes(ord.suppliesClass) &&
                  // 物品コード「マスタから取得」
                  ord.suppliesCd === medicineInfo.cd.toString()
                );
              });

              const rawSeriesData = valItem?.map((item) => {
                const startDate = item.suppliesBaseDate;
                let endDate;
                if (item.frequencyFlg === "0") { // 日分
                  endDate = item.frequencyNum ? moment(startDate).add(Number(item.frequencyNum) - 1, "days").format("YYYYMMDD") : startDate;
                } else if (item.frequencyFlg === "1") { // 回分
                  endDate = startDate;
                }
                return [startDate, endDate, item.indRstValue];
              }) || [];

              const mergedData = mergeXrangeData(rawSeriesData);
              seriesSubData.push(...mergedData);

              const mergedValues = mergedData.map(item => Number(item[2]));
              valSubData.push(...mergedValues);
            });
          }
          //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
        } else if (subCategory.itemNo.toString().includes("MEDICINE_MIX")) {
          // 投薬場合「調製薬剤」
          itemNo = subCategory.itemNo.replace("MEDICINE_MIX", "");
          // 棒グラフ
          chartType = "column";
          rangeData.forEach(item => {
            let val = ordMaterialSave
              .filter(ord => {
                return (
                  // データ基準日⇒期間開始日「集計期間計算」
                  ord.suppliesBaseDate >= item.kaishi &&
                  // データ基準日⇒期間終了日「集計期間計算」
                  ord.suppliesBaseDate < item.shuuryou &&
                  // データ発生元区分「配列存在」
                  sourceArr_chousei.includes(ord.suppliesSourceClass) && // ["0", "1", "3"]
                  // 物品区分「配列存在」
                  suppliesArr_chousei.includes(ord.suppliesClass) && // ["17", "13", "15"]
                  // 物品コード「マスタから取得」
                  ord.suppliesCd === itemNo &&
                  // 調製薬剤コード「ヌル固定」
                  // ord.medicineMixCd === null &&
                  // 指示・実績区分「マスタから取得」
                  ord.indRstClass === ind_rst_class
                );
              })
              .reduce((prev, cur) => {
                // 指示・実績値項目を集計
                return Number(cur.indRstValue ? cur.indRstValue : 0) + Number(prev)
              }, 0);

            if (val) {
              // 表示データ設定「上限値、下限値更新用」
              valSubData.push(val);
              // シリーズデータを作成
              seriesSubData.push([item.kaishi, val]);
            }
          });
        } else if (subCategory.itemNo.toString().includes("MEDICINE")) {
          // 処方場合
          itemNo = subCategory.itemNo.replace("MEDICINE", "");
          // 帯グラフ
          chartType = "xrange";
          const filter = ordMaterialSave.filter(ord => {
            return (
              // データ基準日⇒期間開始日「集計期間計算」
              ord.suppliesBaseDate >= startDate.format("YYYYMMDD") &&
              // データ基準日⇒期間終了日「集計期間計算」
              ord.suppliesBaseDate <= endDate.format("YYYYMMDD") &&
              // データ発生元区分「配列存在」
              sourceArr_shohou.includes(ord.suppliesSourceClass) &&
              // 物品区分「配列存在」
              suppliesArr_shohou.includes(ord.suppliesClass) &&
              // 物品コード「マスタから取得」
              ord.suppliesCd === itemNo &&
              // 調製薬剤コード「ヌル固定」
              ord.medicineMixCd === null
              //  &&
              // // 指示・実績区分「配列存在」
              // indRstClass_shohou.includes(ord.indRstClass)
            );
          });

          const rawSeriesData = filter.map((item) => {
            const startDate = item.suppliesBaseDate;
            let endDate;
            if (item.frequencyFlg === "0") { // 日分
              endDate = item.frequencyNum ? moment(startDate).add(Number(item.frequencyNum) - 1, "days").format("YYYYMMDD") : startDate;
            } else if (item.frequencyFlg === "1") { // 回分
              endDate = startDate
            }
            return [startDate, endDate, item.indRstValue];
          });

          const mergedData = mergeXrangeData(rawSeriesData);
          seriesSubData = mergedData;

          const mergedValues = mergedData.map(item => Number(item[2]));
          valSubData = mergedValues;
        } else {
          // 投薬場合「通常薬剤」
          itemNo = subCategory.itemNo.toString();
          // 棒グラフ
          chartType = "column";
          rangeData.forEach(item => {
            let val = ordMaterialSave
              .filter(ord => {
                return (
                  // データ基準日⇒期間開始日「集計期間計算」
                  ord.suppliesBaseDate >= item.kaishi &&
                  // データ基準日⇒期間終了日「集計期間計算」
                  ord.suppliesBaseDate < item.shuuryou &&
                  // データ発生元区分「配列存在」
                  sourceArr_tsuujou.includes(ord.suppliesSourceClass) &&
                  // 物品区分「配列存在」
                  suppliesArr_tsuujou.includes(ord.suppliesClass) &&
                  // 物品コード「マスタから取得」
                  ord.suppliesCd === itemNo &&
                  // 調製薬剤コード「ヌル固定」
                  ord.medicineMixCd === null &&
                  // 指示・実績区分「マスタから取得」
                  ord.indRstClass === ind_rst_class
                );
              })
              .reduce((prev, cur) => {
                // 指示・実績値項目を集計
                return Number(cur.indRstValue ? cur.indRstValue : 0) + Number(prev)
              }, 0);

            if (val) {
              // 表示データ設定「上限値、下限値更新用」
              valSubData.push(val);
              // シリーズデータを作成
              seriesSubData.push([item.kaishi, val]);
            }
          });
        }

        return {
          valData: valSubData,
          seriesData: seriesSubData.length > 0 ? seriesSubData : [],
          chartType: chartType
        };
      };

      // グラフデータ作成「目標投与量（投薬）」
      const gurafu_deta_sakusei_mokuhyouchi_touyaku = mst => {
        // マスタ情報の明細無効場合
        if (!(mst && mst.detailInfo && JSON.parse(mst.detailInfo))) {
          return null;
        }
        const detailInfo = JSON.parse(mst.detailInfo);

        if (!(detailInfo.hasOwnProperty("medicineESA") && detailInfo.medicineESA)) {
          return null;
        }
        const itemNoInfo = detailInfo.medicineESA;

        // 投薬支援⇒目標値無効場合
        if (!(itemNoInfo && itemNoInfo[0].hasOwnProperty("value") && itemNoInfo[0].value)) {
          return null;
        }
        let itemNo = itemNoInfo[0].value.toString();
        // 表示期間（固定：日）
        let itemDate = shuukei_kikan("day");

        const chartType = "column";
        const valSubData = [];
        const seriesSubData = [];
        const rangeData = [];

        // 投薬支援条件
        // 「5：投薬支援」
        const sourceArr_shien = ["5"];
        // 「5：投薬支援」⇒「18：目標投与量（投薬支援）」
        const suppliesArr_shien_mokuhyouchi = ["18"];

        // 期間データを作成「集計期間」
        rangeData.push(...shuukei_kikan_hairetsu({
          // 集計期間「-1：未登録」「1：日」
          // 患者経過総合ビューアレイアウトマスタにて「集計期間」を「ヘッダー」と「明細」それぞれに指定された場合、「明細」を優先させる。
          // 「集計期間」を指定されていない「明細」は「ヘッダー」の「集計期間」に従う。
          // 「ヘッダー」、「明細」共に指定されていない場合、「日」単位での集計とする。
          shuukei: itemDate,
          // 期間開始
          kaishi: moment(startDate).format("YYYYMMDD"),
          // 期間終了
          shuuryou: moment(endDate).format("YYYYMMDD")
        }));

        rangeData.forEach(item => {
          let val = ordMaterialSave
            .filter(ord => {
              return (
                // データ基準日⇒期間開始日「集計期間計算」
                ord.suppliesBaseDate >= item.kaishi &&
                // データ基準日⇒期間終了日「集計期間計算」
                ord.suppliesBaseDate < item.shuuryou &&
                // データ発生元区分「配列存在」
                sourceArr_shien.includes(ord.suppliesSourceClass) &&
                // 物品区分「配列存在」
                suppliesArr_shien_mokuhyouchi.includes(ord.suppliesClass) &&
                // 物品コード「マスタから取得」
                ord.suppliesCd === itemNo &&
                // 調製薬剤コード「ヌル固定」
                ord.medicineMixCd === null &&
                // 指示・実績区分「2：実績」固定
                ord.indRstClass === "2" &&
                // 確定フラグ「1：確定」固定
                ord.isConfirm === "1"
              );
            })
            .reduce((prev, cur) => {
              // 指示・実績値項目を集計
              return Number(cur.indRstValue ? cur.indRstValue : 0) + Number(prev)
            }, 0);

          if (val) {
            // 表示データ設定「上限値、下限値更新用」
            valSubData.push(val);
            // シリーズデータを作成
            seriesSubData.push([item.kaishi, val]);
          }
        });

        return {
          valData: valSubData,
          seriesData: seriesSubData.length > 0 ? seriesSubData : [],
          chartType: chartType
        };
      };
      // グラフデータ作成「目標投与量（処方）」
      const gurafu_deta_sakusei_mokuhyouchi_shohou = mst => {
        return gurafu_deta_sakusei_mokuhyouchi_touyaku(mst);
      };

      const getPredictionValue = mst => {
        if (!(mst && mst.detailInfo && JSON.parse(mst.detailInfo))) {
          return null;
        }
        const detailInfo = JSON.parse(mst.detailInfo);

        if (!(detailInfo.hasOwnProperty("examItemCycling") && detailInfo.examItemCycling)) {
          return null;
        }
        const itemNoInfo = detailInfo.examItemCycling;

        // 投薬支援⇒予測値無効場合
        if (!(itemNoInfo && itemNoInfo?.[0]?.hasOwnProperty("value") && itemNoInfo[0].value)) {
          return null;
        }
        return itemNoInfo[0].value.toString();
      };
      // グラフデータ作成「予測値」
      const gurafu_deta_sakusei_yosokuchi = mst => {
        const itemNo = getPredictionValue(mst);
        if (!itemNo) {
          return null;
        }
        // 表示期間（固定：日）
        let itemDate = shuukei_kikan("day");

        const chartType = "line";
        const valSubData = [];
        const seriesSubData = [];
        const rangeData = [];

        // 投薬支援条件
        // 「5：投薬支援」
        const sourceArr_shien = ["5"];
        // 「5：投薬支援」⇒「19：予測値（投薬支援）」
        const suppliesArr_shien_yosokuchi = ["19"];

        // 期間データを作成「集計期間」
        rangeData.push(...shuukei_kikan_hairetsu({
          // 集計期間「-1：未登録」「1：日」
          // 患者経過総合ビューアレイアウトマスタにて「集計期間」を「ヘッダー」と「明細」それぞれに指定された場合、「明細」を優先させる。
          // 「集計期間」を指定されていない「明細」は「ヘッダー」の「集計期間」に従う。
          // 「ヘッダー」、「明細」共に指定されていない場合、「日」単位での集計とする。
          shuukei: itemDate,
          // 期間開始
          kaishi: moment(startDate).format("YYYYMMDD"),
          // 期間終了
          shuuryou: moment(endDate).format("YYYYMMDD")
        }));

        rangeData.forEach(item => {
          let val = ordMaterialSave
            .filter(ord => {
              return (
                // データ基準日⇒期間開始日「集計期間計算」
                ord.suppliesBaseDate >= item.kaishi &&
                // データ基準日⇒期間終了日「集計期間計算」
                ord.suppliesBaseDate < item.shuuryou &&
                // データ発生元区分「配列存在」
                sourceArr_shien.includes(ord.suppliesSourceClass) &&
                // 物品区分「配列存在」
                suppliesArr_shien_yosokuchi.includes(ord.suppliesClass) &&
                // 物品コード「マスタから取得」
                ord.suppliesCd === itemNo &&
                // 調製薬剤コード「ヌル固定」
                ord.medicineMixCd === null &&
                // 指示・実績区分「2：実績」固定
                ord.indRstClass === "2" &&
                // 確定フラグ「1：確定」固定
                ord.isConfirm === "1"
              );
            })
            .reduce((prev, cur) => {
              // 指示・実績値項目を集計
              return Number(cur.indRstValue ? cur.indRstValue : 0) + Number(prev)
            }, 0);

          if (val) {
            // 表示データ設定「上限値、下限値更新用」
            valSubData.push(val);
            // シリーズデータを作成
            seriesSubData.push([item.kaishi, val]);
          }
        });

        return {
          valData: valSubData,
          seriesData: seriesSubData.length > 0 ? seriesSubData : [],
          chartType: chartType
        };
      };

      const getRegressionValue = mst => {
        if (!(mst && mst.detailInfo && JSON.parse(mst.detailInfo))) {
          return null;
        }
        const detailInfo = JSON.parse(mst.detailInfo);

        if (!(detailInfo.hasOwnProperty("examItemRegression") && detailInfo.examItemRegression)) {
          return null;
        }
        const itemNoInfo = detailInfo.examItemRegression;

        // 投薬支援⇒回帰直線無効場合
        if (!(itemNoInfo && itemNoInfo?.[0]?.hasOwnProperty("value") && itemNoInfo[0].value)) {
          return null;
        }
        return itemNoInfo[0].value.toString();
      };
      // グラフデータ作成「回帰直線」
      const gurafu_deta_sakusei_kaikichokusen = series => {
        const chartType = "line";
        const valSubData = [];
        const seriesSubData = [];

        for (let index = 0; (series && index < series.intDataCnt); index++) {
          if (series.dtmDataDate[index]) {
            seriesSubData.push([moment(series.dtmDataDate[index]).format("YYYY-MM-DD HH:mm:ss"), Number(series.dblDataValue[index])]);
            valSubData.push(Number(series.dblDataValue[index]));
            // 分割
            if (index % 2 === 1) {
              seriesSubData.push([moment(series.dtmDataDate[index]).format("YYYY-MM-DD HH:mm:ss"), null]);
            }
          }
        }

        return {
          valData: valSubData,
          seriesData: seriesSubData.length > 0 ? seriesSubData : [],
          chartType: chartType
        };
      };

      if (isLongPeriod) {
        // 期間情報再設定
        switch (period) {
          case "4":
            endDate = endDate.add(1, "week").startOf("day").subtract(1, "days");
            break;
          case "5":
          case "6":
            startDate = startDate.startOf("month");
            endDate = endDate.endOf("month");
            break;
          case "7":
            startDate = startDate.startOf("month");
            endDate = endDate.add(11, "months").endOf("month");
            break;
        }

        // マスト情報を処理「情報フラグ設定」
        layout.categoryItem.forEach(category => {
          category.subCategoryItem.forEach(subCategory => {
            if (subCategory.hasOwnProperty("itemDivision") && subCategory.itemDivision) {
              const itemDivision = subCategory.itemDivision.toString();
              switch (itemDivision) {
                case taishou_kubun_jouken:
                  // 治療条件情報表示場合
                  hasCond = true;
                  break;
                case taishou_kubun_kensa:
                  if (subCategory.itemNo === shien_yosokuchi) {
                    // 予測値
                    hasPredictive = true;
                  } else if (subCategory.itemNo === shien_kaikichokusen) {
                    // 回帰直線
                    hasRegression = true;
                  } else {
                    // 検査結果情報表示場合
                    hasExam = true;
                  }
                  break;
                case taishou_kubun_yakuzai:
                  if (subCategory.itemNo === shien_mokuhyouchi_touyaku) {
                    // 目標値1「投薬」
                    hasESA1 = true;
                  } else if (subCategory.itemNo === shien_mokuhyouchi_shohou) {
                    // 目標値2「処方」
                    hasESA2 = true;
                  } else {
                    // 投与薬剤情報表示場合
                    hasMedi = true;
                  }
                  break;
                case taishou_kubun_baitaru:
                  // バイタル・モニタ情報表示場合
                  hasVital = true;
                  break;
                case taishou_kubun_taijuu:
                  // 体重情報表示場合
                  hasWeight = true;
                  break;
                default:
                  break;
              }
            }
          });
        });

        // RestAPI実行「治療情報を取得」ordMain
        if (hasCond || hasWeight || hasVital) {
          const ord = state.treatDateList || [];
          ordMain.push(...ord.data);
        }

        // リストを作成「治療条件」
        if (hasCond) {
          for (const ordInfo of ordMain) {
            const indCondInfo = ordInfo && ordInfo.indCondInfo && JSON.parse(ordInfo.indCondInfo);
            const rstCondInfo = ordInfo && ordInfo.rstCondInfo && JSON.parse(ordInfo.rstCondInfo);
            conditions.push({
              indCondInfo: indCondInfo,
              rstCondInfo: rstCondInfo,
              indTreatmentCd: ordInfo.indTreatmentCd,
              rstTreatmentCd: ordInfo.rstTreatmentCd,
              dw: ordInfo.rstDw,
              treatDate: ordInfo.treatDate
            });
          }
        }

        // リストを作成「体重」weights
        if (hasWeight) {
          // 一時テータ
          const weightsTemp = [];
          for (const ordInfo of ordMain.filter(p => p.rstDialysisState !== "0")) {
            const weightInfo = ordInfo && ordInfo.rstWeightInfo && JSON.parse(ordInfo.rstWeightInfo);
            if (ordInfo.rstStartDate || ordInfo.indTreatStartTime) {
              weightsTemp.push({
                weightInfo: weightInfo,
                // 実績はrst_dw
                dw: ordInfo.rstDw,
                treatDate: ordInfo.treatDate,
                startTime: ordInfo.rstStartDate ? moment(ordInfo.rstStartDate).format("HHmm") : Number(ordInfo.indTreatStartTime),
                lastWeightAfter:ordInfo.lastWeightAfter
              });
            }
          }
          weights.push(
            ...weightsTemp.sort(function(a, b) {
              if (a.treatDate === b.treatDate) {
                if (a.startTime > b.startTime) {
                  return 1;
                } else {
                  return -1;
                }
              } else if (a.treatDate > b.treatDate) {
                return 1;
              } else {
                return -1;
              }
            })
          );
        }

        // RestAPI実行「患者DW情報を取得」patDwInfo
        if (hasCond || hasWeight) {
          const uri = "/patInfo/getPatSharingById";
          const ord = await ApiHelper.get(`${uri}/${patId}`
          ).catch(err => {
            throw err;
          });
          const patUniqueInfo = ord.data && ord.data && JSON.parse(ord.data.pat_unique);
          const patPhysicalInfo = patUniqueInfo && patUniqueInfo.physical_info && JSON.parse(patUniqueInfo.physical_info);
          if (patPhysicalInfo) {
            // 一時テータ
            const patDwInfoTemp = [];
            patPhysicalInfo.forEach(p => {
              patDwInfoTemp.push({
                dw: p.dw,
                examDate: moment(p.exam_date).format("YYYY-MM-DDTHH:mm:ss.SSSZ")
              });
            });
            patDwInfo.push(
              ...patDwInfoTemp.sort(function(a, b) {
                if (a.examDate < b.examDate) {
                  return 1;
                } else {
                  return -1;
                }
              })
            );
          }
        }

        // RestAPI実行「装置モニタデータを取得」mniMonitor
        if (hasVital) {
          for (const ordInfo of ordMain) {
            let resMniMonitors = getters.getResMniMonitors;
            let resMniMonitorTmp = resMniMonitors.filter(y => y.ordNo == ordInfo.ordNo);
            let ord = null;
            if (resMniMonitorTmp && resMniMonitorTmp.length > 0) {
              ord = resMniMonitorTmp[0].resMniMonitor;
            } else {
              ord = await ApiHelper.get(
                `/status_list/mni_monitor/${ordInfo.ordNo}`
              ).catch(err => {
                throw err;
              })
              resMniMonitors.push({
                ordNo: ordInfo.ordNo,
                resMniMonitor: ord
              });
              commit("setResMniMonitors", resMniMonitors);
            }
            // 削除データは表示しない
            ord.data.filter(monitorItem => monitorItem.is_del !== "1")
              .forEach(monitorItem => {
                // mod #12462 患者情報共有->患者経過総合ビューア fang start
                let tempMonitorData = {}
                if(monitorItem.monitor_data) {
                  tempMonitorData = JSON.parse(monitorItem.monitor_data)
                  if(ordInfo.facilityCd != facilityCd) {
                    let filterMonitor = Object.keys(tempMonitorData)
                    let filterResult = {}
                    for(let i = 0; i < filterMonitor.length; i++) {
                      const tempKey = filterMonitor[i].replace('Z', '')
                      if(Number(tempKey) <= 10000) {
                        filterResult[filterMonitor[i]] = tempMonitorData[filterMonitor[i]]
                      }
                    }
                    tempMonitorData = filterResult
                  }
                }
                
                mniMonitor.push({
                  monitorData: tempMonitorData,
                  occurDate: monitorItem.occur_date
                });
                // mod #12462 患者情報共有->患者経過総合ビューア fang end
              });
          }
        }

        // RestAPI実行「患者検査結果を取得」patExamMain
        if (hasExam || hasRegression) {
          /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
          const sendData = {};
          const patientShareMode = store.getters["account-edit/getPatientShareMode"];
          const patientShareFacilityCdMode = store.getters["account-edit/getPatientShareFacilityCdMode"];
          // 0: マージ  1: 自施設
          sendData.patShareMode = patientShareMode == 0 && !patientShareFacilityCdMode ? 0 : 1;
          const ord = await ApiHelper.post(
            // `/exam/TreatDateList/${patId}/${startDate.format("YYYYMMDD")}/${endDate.format("YYYYMMDD")}`
            `/exam/TreatDateList/${patId}/${startDate.format("YYYYMMDD")}/${endDate.format("YYYYMMDD")}`, sendData
          ).catch(err => {
            throw err;
          });
          /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
          // mod #12462 患者情報共有->患者経過総合ビューア fang start
          const responseItem = await ApiHelper.get(`/exam/examRecord/examItem/${facilityCd}`).catch(err => {
            throw err;
          });
          for (const examRecord of ord.data) {
            let tempExamData = [];
            let tempExamResultInfo = []
            if(examRecord.examResultInfo && examRecord.examResultInfo.length > 0) {
              tempExamResultInfo = JSON.parse(examRecord.examResultInfo)
              tempExamData = otherFacilityPatExamMainConvert(facilityCd, examRecord.facilityCd, tempExamResultInfo, responseItem, layout, examRecord.regOrderClass)
            }
            const examInfo = tempExamData;
            // mod #12462 患者情報共有->患者経過総合ビューア fang end
            if (examInfo && examRecord.resultExamDate) {
              patExamMain.push({
                examInfo: examInfo,
                examDate: examRecord.resultExamDate,
                // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
                regOrderClass: examRecord.regOrderClass
                // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
              });
            }
          }
        }

        // RestAPI実行「計算材料情報を取得」ordMaterialSave
        // 投与薬剤、目標投与量、予測値
        if (hasMedi || hasESA1 || hasESA2 || hasPredictive) {
          // APIの引数作成
          const sendData = {};
          sendData.facility_cd = facilityCd;
          sendData.pat_id = patId;
          sendData.supplies_base_date_begin = startDate.format("YYYYMMDD");
          sendData.supplies_base_date_end = endDate.format("YYYYMMDD");
          // add #12462 患者情報共有->患者経過総合ビューア fang start
          const patientShareMode = store.getters["account-edit/getPatientShareMode"];
          const patientShareFacilityCdMode = store.getters["account-edit/getPatientShareFacilityCdMode"];
          // 0: マージ  1: 自施設
          sendData.shareMode = patientShareMode == 0 && !patientShareFacilityCdMode ? 0 : 1;
          // add #12462 患者情報共有->患者経過総合ビューア fang end

          const ord = await ApiHelper.post(
            "/mainData/getOrdMaterialSave",
            sendData
          ).catch(err => {
            throw err;
          });
          // mod #12462 患者情報共有->患者経過総合ビューア fang start
          // ordMaterialSave.push(...ord.data);
          ordMaterialSave = otherFacilityOrdMaterialSaveConvert(facilityCd, ord, getters.getMstMedicineData)
          // mod #12462 患者情報共有->患者経過総合ビューア fang end
        }
        // ➁RestAPI実行「薬効換算マスタ情報を取得」
        const mstMedicineGroup = await ApiHelper.get("/mstInfo/mstMedicineGroup", {
          facilityCd: facilityCd
        }).catch(err => {
          throw err;
        });
        layout.categoryItem.forEach((category, index) => {
          // 表示データ配列
          const hyouji_deta_hairetsu = [];
          const includeLineDataArr = [];
          // 指示・実績区分「薬剤グラフのみ」
          const ind_rst_class = shiji_jisseki_kubun(category);
          // 上限値「マスタ情報から取得」
          let max = category.graphMax ? Number(category.graphMax) : 0;
          // 下限値「マスタ情報から取得」
          let min = category.graphMin ? Number(category.graphMin) : 0;
          category.subCategoryItem.forEach(subCategory => {
            let convertSeries = null;
            if (subCategory.hasOwnProperty("itemDivision") && subCategory.itemDivision) {
              const itemDivision = subCategory.itemDivision.toString();
              switch (itemDivision) {
                case taishou_kubun_jouken:
                  // 治療条件
                  convertSeries = gurafu_deta_sakusei_jouken(subCategory, shiji_jisseki_kubun(category, 'treatment'));
                  break;
                case taishou_kubun_kensa:
                  if (subCategory.itemNo === shien_yosokuchi) {
                    // 予測値
                    convertSeries = gurafu_deta_sakusei_yosokuchi(selectedMedicineSupportItem);
                  } else if (subCategory.itemNo === shien_kaikichokusen) {
                    // 回帰直線「関数算出」
                    const regressionSeries = getGraphDataForRegression(
                      moment(endDate).format("YYYYMMDD"),
                      period,
                      getRegressionValue(selectedMedicineSupportItem),
                      patExamMain
                    );
                    convertSeries = gurafu_deta_sakusei_kaikichokusen(regressionSeries);
                  } else {
                    // 検査結果
                    convertSeries = gurafu_deta_sakusei_kensa(subCategory);
                  }
                  break;
                case taishou_kubun_yakuzai:
                  if (subCategory.itemNo === shien_mokuhyouchi_touyaku) {
                    // 目標値1「投薬」
                    convertSeries = gurafu_deta_sakusei_mokuhyouchi_touyaku(selectedMedicineSupportItem);
                  } else if (subCategory.itemNo === shien_mokuhyouchi_shohou) {
                    // 目標値2「処方」
                    convertSeries = gurafu_deta_sakusei_mokuhyouchi_shohou(selectedMedicineSupportItem);
                  } else {
                    // 投与薬剤
                    convertSeries = gurafu_deta_sakusei_yakuzai(subCategory, ind_rst_class,mstMedicineGroup.data);
                  }
                  break;
                case taishou_kubun_baitaru:
                  // バイタル・モニタ
                  convertSeries = gurafu_deta_sakusei_baitaru(subCategory);
                  break;
                case taishou_kubun_taijuu:
                  // 体重
                  convertSeries = gurafu_deta_sakusei_taijuu(subCategory);
                  break;
                default:
                  break;
              }
            }
            if (convertSeries) {
              const itemDivision = subCategory.itemDivision.toString();
              const isTaishouKubunJoukenFlg = itemDivision === taishou_kubun_jouken
              if (convertSeries.chartType === "custom") {
                // カスタム場合

                // Y軸索引値を計算する関数
                const calculateYAxisIndex = () => {
                  // 縦軸ダミーデータ値
                  let damichi = max_dami - step_dami * 2;

                  // 縦軸表示値を計算「カスタム用」
                  const customArrays = [
                    custom_chiryou_houhou,
                    custom_chiryou_jouken_05,
                    custom_chiryou_jouken_05_06,
                    custom_chiryou_jouken_05_07,
                    custom_chiryou_jouken_05_08,
                    custom_chiryou_jouken_19,
                    custom_chiryou_jouken_25
                  ];

                  for (const customArray of customArrays) {
                    for (let item of customArray) {
                      item.index = damichi;
                      damichi = damichi - step_dami;
                    }
                  }
                };

                // Y軸値を取得する関数
                const getYAxisValue = (mstType, mstCode) => {
                  let yAxisValue = null;
                  if (mstType === mstMethod) {
                    yAxisValue = custom_chiryou_houhou.find(p => p.mstCode === mstCode);
                  } else if (mstType === mstDializer) {
                    yAxisValue = custom_chiryou_jouken_05.find(p => p.mstCode === mstCode);
                  } else if (mstType === mstEquipment) {
                    yAxisValue = custom_chiryou_jouken_05_06.find(p => p.mstCode === mstCode) ||
                               custom_chiryou_jouken_05_07.find(p => p.mstCode === mstCode) ||
                               custom_chiryou_jouken_05_08.find(p => p.mstCode === mstCode);
                  } else if (mstType === mstMedicine) {
                    yAxisValue = custom_chiryou_jouken_19.find(p => p.mstCode === mstCode) ||
                               custom_chiryou_jouken_25.find(p => p.mstCode === mstCode);
                  } else if (mstType === mstMedicineMix) {
                    yAxisValue = custom_chiryou_jouken_25.find(p => p.mstCode === mstCode);
                  }
                  return yAxisValue ? yAxisValue.index : 0;
                };

                // Y軸索引値を計算
                calculateYAxisIndex();
                for (const seriesSubItem of convertSeries.seriesData) {
                  const itemName = meishou_kasutamu(seriesSubItem.mstType, seriesSubItem.mstCode);
                  const itemColor = shoku_kasutamu(seriesSubItem.mstType);

                  // seriesSubItem.subItemsのY軸値を事前に設定
                  const yAxisIndex = getYAxisValue(seriesSubItem.mstType, seriesSubItem.mstCode);
                  const updatedSubItems = seriesSubItem.subItems.map(dataPoint => {
                    // データポイントが配列の場合、3番目の要素（インデックス2）にY軸値を設定
                    if (Array.isArray(dataPoint) && dataPoint.length >= 3) {
                      dataPoint[2] = yAxisIndex;
                    }
                    return dataPoint;
                  });

                  // Y軸範囲を計算
                  const valueData = updatedSubItems.flatMap(item => item[2]);
                  const yAxisRange = calculateYAxisRange(convertSeries.chartType, category.graphMax, category.graphMin, valueData);
                  hyouji_deta_hairetsu.push(...valueData);
                  max = Math.max(max, yAxisRange.yAxisMax);
                  min = Math.min(min, yAxisRange.yAxisMin);
                  series.push({
                    type: convertSeries.chartType,
                    yAxis: 0,
                    yAxisMax: yAxisRange.yAxisMax,
                    yAxisMin: yAxisRange.yAxisMin,
                    yAxisNo: category.subCategoryNo,
                    yAxisName: category.subCategoryName,
                    name: getPrefix(convertSeries.chartType) + seriesSubItem.prefixName + itemName + (isTaishouKubunJoukenFlg ? '(' + category.treatmentStatus + ')' : ''),
                    no: subCategory.itemNo + "_" + seriesSubItem.mstType + "_" + seriesSubItem.mstCode,
                    mstType: seriesSubItem.mstType,
                    mstCode: seriesSubItem.mstCode,
                    color: itemColor,
                    data: updatedSubItems
                  });
                }
              } else {
                // 通常場合
                if (convertSeries.chartType === 'line') {
                  includeLineDataArr.push(...convertSeries.valData);
                } else {
                  hyouji_deta_hairetsu.push(...convertSeries.valData);
                }
                // Y軸範囲を計算
                const yAxisRange = calculateYAxisRange(convertSeries.chartType || 'xrange', category.graphMax, category.graphMin, hyouji_deta_hairetsu);
                max = convertSeries.chartType !== 'line' ? Math.max(max, yAxisRange.yAxisMax) : max;
                min = convertSeries.chartType !== 'line' ? (min && min === 0 ? Math.min(min, yAxisRange.yAxisMin) : yAxisRange.yAxisMin) : min;
                series.push({
                  type: convertSeries.chartType || 'xrange',
                  yAxis: index + 1,
                  yAxisMax: yAxisRange.yAxisMax,
                  yAxisMin: yAxisRange.yAxisMin,
                  yAxisNo: category.subCategoryNo,
                  yAxisName: category.subCategoryName,
                  name: getPrefix(convertSeries.chartType) + subCategory.itemName + (isTaishouKubunJoukenFlg ? '(' + category.treatmentStatus + ')' : ''),
                  no: subCategory.itemNo,
                  color: subCategory.itemColor,
                  marker: getSeriesMarker(subCategory.itemPoint, subCategory.itemColor),
                  data: [...convertSeries.seriesData]
                });
              }
            }
          });
          // 現在のcategory.subCategoryItemでlineタイプchartのみで、category.graphMaxとcategory.graphMinがnullの場合、上下限はデータ内の最大値最小値に基づいて設定されます
          const targetSeries = series.filter(item =>
            Number(item.yAxis) === index + 1
          );
          if (targetSeries.length > 0 && includeLineDataArr.length > 0 && targetSeries.every(item => item.type === 'line')) {
            max = isValidNumber(category.graphMax) ? max : Math.max(...includeLineDataArr);
            min = isValidNumber(category.graphMin) ? min : Math.min(...includeLineDataArr);
          } else if (targetSeries.length > 0 && includeLineDataArr.length > 0 && targetSeries.some(item => item.type === 'line')) {
            const dataArr = includeLineDataArr.concat(hyouji_deta_hairetsu)
            max = category.graphMax ? Math.max(category.graphMax, ...hyouji_deta_hairetsu) : Math.max(...dataArr);
            min = category.graphMin ? Math.min(category.graphMin, ...hyouji_deta_hairetsu) : Math.min(...dataArr)
          }
          if (max < min) {
            [max, min] = [min, max]
          }
          // 実績情報をクリア
          hyouji_deta_hairetsu.splice(0, hyouji_deta_hairetsu?.length);

          yAxis.push({
            labels: { enabled: false },
            title: { text: category.subCategoryName },
            tickPositioner: function() {
              const incrementCount = tickAmount - 2;
              const maxDecimalCount = Math.max(
                Number.isInteger(min) ? 0 : min.toString().split('.')[1].length,
                Number.isInteger(max) ? 0 : max.toString().split('.')[1].length
              );
              const incrementValue = (max - min) / incrementCount;
              const increment = incrementValue > 0 ? incrementValue : 0;
              const incrementDecimalCount = Number.isInteger(increment) ? 0 : increment.toString().split('.')[1].length;
              const incrementFixedMax = 3;

              const fixed = Math.max(Math.min(incrementDecimalCount, incrementFixedMax), maxDecimalCount);
              const positions = [];

              if (increment > 0) {
                positions.push(Number(min));
                for (let index = 1; index < incrementCount; index++) {
                  const valFull = min + index * increment;
                  const valFloor = Math.floor(valFull * Math.pow(10, fixed)) / Math.pow(10, fixed);
                  positions.push(valFloor);
                }
                positions.push(Number(max));
              } else {
                for (let index = 0; index < incrementCount + 1; index++) {
                  const p = min + index;
                  positions.push(parseFloat(p.toFixed(3)));
                }
              }
              return positions;
            },
            offset: 0
          });
        });


      }

      let breaks = [];
      let breakDays = [];
      if (period + "" === "1" || period + "" === "2" || period + "" === "3") {
        let days = endDate.diff(startDate, 'days');
        for (let i = 1; i < days; i++) {
          let daytmp = moment(startDate.format("YYYY-MM-DD"));
          daytmp = daytmp.add(i, 'days');
          let strDay = daytmp.format("YYYYMMDD");
          if (!Object.keys(copyTreatmentData).includes(strDay) &&
            !getters.getDateList.includes(strDay)) {
            breakDays.push(strDay);
          }
        }
        let daytmp = "";
        let daytmpS = "";
        breakDays.forEach(breakDay => {
          if (daytmpS === "") {
            daytmpS = breakDay;
          } else {
            if (moment(daytmp).add(1, 'days').format("YYYYMMDD") !== breakDay) {
              let fromD = moment(daytmpS).startOf('day');
              let toD = moment(daytmp).add(1, 'days').startOf('day');
              let breakItem = {
                from: fromD.valueOf(),
                to: toD.valueOf()
              };
              breaks.push(breakItem);
              daytmpS = breakDay;
            }
          }
          daytmp = breakDay;
        });
        if (daytmp !== daytmpS) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
        if (daytmpS !== "" && breaks.length === 0) {
          let fromD = moment(daytmpS).startOf('day');
          let toD = moment(daytmp).add(1, 'days').startOf('day');
          let breakItem = {
            from: fromD.valueOf(),
            to: toD.valueOf()
          };
          breaks.push(breakItem);
        }
      }
      convertData[0].data.push({
        type: "comprehensive-graph",
        chartData: series,
        chartXAxisMin: startDate.valueOf(),
        chartXAxisMax: endDate.valueOf(),
        breaks: breaks,
        chartDisplayPeriod: period,
        yAxis: yAxis
      });
      return convertData;
    },
    // add FNSI-長期の複合グラフを新規作成「236」「660」「661」 周 end

    /**
     * 指示・実績表示切替
     */
    setShowIndRst({ commit }, selectShowIndRst) {
      commit("setShowIndRst", selectShowIndRst);
    },
    /**
     * 治療日(基準日)の設定
     */
    setTreatBaseDate({ commit }, treatDate) {
      const yyyymmdd = treatDate ? treatDate.replace(/[^0-9]/g, "") : null;
      commit("commmitTreatDate", yyyymmdd);
    },

    setIsDie({ commit }, isDie) {
      commit("setIsDie", isDie);
    },
    setIsDieMessage({ commit }, isDieMessage) {
      commit("setIsDieMessage", isDieMessage);
    },

    setTickPositions({ commit }, rec) {
      commit("setTickPositions", rec);
    },

    setSelectedCondition({ commit }, selectedCondition) {
      commit("setSelectedCondition", selectedCondition);
    },

    // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
    setPatIdKeep({ commit }, patIdKeep) {
      commit("setPatIdKeep", patIdKeep);
    },

    setPatIdKeepChgFlg({ commit }, patIdKeepChgFlg) {
      commit("setPatIdKeepChgFlg", patIdKeepChgFlg);
    },

    setDataListKeepTreatMethod({ commit }, dataListKeepTreatMethod) {
      commit("setDataListKeepTreatMethod", dataListKeepTreatMethod);
    },

    setDataListKeepTreatCond({ commit }, dataListKeepTreatCond) {
      commit("setDataListKeepTreatCond", dataListKeepTreatCond);
    },

    setDataListKeepMedicine({ commit }, dataListKeepMedicine) {
      commit("setDataListKeepMedicine", dataListKeepMedicine);
    },

    setDataListKeepEquipment({ commit }, dataListKeepEquipment) {
      commit("setDataListKeepEquipment", dataListKeepEquipment);
    },

    setDataListKeepSchedule({ commit }, dataListKeepSchedule) {
      commit("setDataListKeepSchedule", dataListKeepSchedule);
    },

    setDataListKeepIndComment({ commit }, dataListKeepIndComment) {
      commit("setDataListKeepIndComment", dataListKeepIndComment);
    },

    setDataListKeepUFRProgram({ commit }, dataListKeepUFRProgram) {
      commit("setDataListKeepUFRProgram", dataListKeepUFRProgram);
    },

    setDataListKeepNaProgram({ commit }, dataListKeepNaProgram) {
      commit("setDataListKeepNaProgram", dataListKeepNaProgram);
    },

    setDataListKeepDialysateProgram({ commit }, dataListKeepDialysateProgram) {
      commit("setDataListKeepDialysateProgram", dataListKeepDialysateProgram);
    },

    setDataListKeepBvUfc({ commit }, dataListKeepBvUfc) {
      commit("setDataListKeepBvUfc", dataListKeepBvUfc);
    },

    setDataListKeepDiaysisProgram({ commit }, dataListKeepDiaysisProgram) {
      commit("setDataListKeepDiaysisProgram", dataListKeepDiaysisProgram);
    },
    // add 1006-398 指示の切り替わりポイントを赤くする 陳 end

    // add 更新中の予定を表示する様にする。 李 start
    setScrollBarPositioningOrdNo({ getters, commit }, ordNo) {
      let dispDataListScBarPos = [];
      if (ordNo && "creat" === ordNo.ordNoName) {
        getters.getOrdNoList.forEach(item => {
          dispDataListScBarPos.push(item.ordNo);
        })
        // 予定して作成した場合判断用
        if (dispDataListScBarPos.length === 1) dispDataListScBarPos.push("");
      } else if (ordNo && "reset" === ordNo.ordNoName) {
        dispDataListScBarPos = [];
      } else {
        dispDataListScBarPos.push(ordNo);
      }
      commit("setScrollBarPositioningOrdNo", dispDataListScBarPos);
    },
    // add 更新中の予定を表示する様にする。 李 end
    //add FNSI内容修正 バグ284、286 姜 start
    setOrdNoMediList({ commit }, ordNoMediList) {
      commit("setOrdNoMediList", ordNoMediList);
    },
    //add FNSI内容修正 バグ284、286 姜 end
    getOrdMainByOrdNo(context, ordNo) {
      return sendRequestGetOrdMainByOrdNo(ordNo).then(response => {
        return Promise.resolve(response.data);
      });
    },

    // add FNSI-予定内容遅延問題対応 李 start
    setIndPlanCreateDate({ commit }, indPlanCreateDate) {
      commit("setIndPlanCreateDate", indPlanCreateDate);
    },
    setResMniMonitors({ commit }, resMniMonitors) {
      commit("setResMniMonitors", resMniMonitors);
    },
    setMntMachineStates({ commit }, mntMachineStates) {
      commit("setMntMachineStates", mntMachineStates);
    },
    // add FNSI-予定内容遅延問題対応 李 end

    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 start
    setPriorToChangeList({ commit }, priorToChangeList) {
      // コミット
      commit("setPriorToChangeList", priorToChangeList);
    },
    //内部remine 5840  add ljx start
    setTreatmentDataOfPeriodTmp({ commit }, treatmentDataOfPeriodTmp) {
      // コミット
      commit("setTreatmentDataOfPeriodTmp", treatmentDataOfPeriodTmp);
    },
    //内部remine 5840  add ljx end

    setAfterToChangeList({ commit }, afterToChangeList) {
      // コミット
      commit("setAfterToChangeList", afterToChangeList);
    },
    // add FNSI-FutreNetWeb+SI課題管理No.4362 李 end
    // add 10443 身体情報・DW・目標体重バグ 関  start
    setPhysicalInfo({ commit }, physical) {
      commit("setPhysicalInfo", physical);
    },
    // add 10443 身体情報・DW・目標体重バグ 関  end
  }
};

// add #10077 by zhangruixue 2024-2-20  start
/**
 * 全角の数値を半角に変換
 * */
// del #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
// function convertToHalfWidth(convertToHalfStr){
//   var parttern = /[０-９ー＋－．]/g;
//   if(parttern.test(convertToHalfStr)){
//     convertToHalfStr = convertToHalfStr.replace(parttern, function(match) {
//       const fullToHalfMap = {
//         '０': '0', '１': '1', '２': '2', '３': '3', '４': '4',
//         '５': '5', '６': '6', '７': '7', '８': '8', '９': '9',
//         '＋': '+', '－': '-', '．': '.', 'ー': '-'
//       };
//       return fullToHalfMap[match];
//     });
//     return convertToHalfStr;
//   }else {
//     return convertToHalfStr;
//   }
// }
// del #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
function isStringNumeric(str) {
  return /^[+-]?\d+(\.\d+)?$/.test(str);
}
// add #10077 by zhangruixue 2024-2-20  end
// add FNSI-グラフのシリーズ表示を修正 周 start
//内部remine 5840  add ljx start
/**
 *
 * @param {String} string '2023-7-1'
 * @param {String} String '2023-8-1'
 * @return {Array} ['2023-07-01', '2023-07-01'...., '2023-08-01']
 */
function getDayArr(startDay, endDay) {
  let startVal = moment(startDay).format('YYYYMMDD');
  let endVal = moment(endDay).format('YYYYMMDD');
  let dayArr = []
  while (moment(startVal).isBefore(moment(endVal))) {
    dayArr.push(startVal)
    startVal = moment(startVal).add(1, 'day').format('YYYYMMDD')
  }
  dayArr.push(moment(endDay).format('YYYYMMDD'))
  return dayArr
}
//内部remine 5840  add ljx end
// add FNSI-グラフのシリーズ表示を修正 周 end

// add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 start
/**
 * 薬剤分類マスタ/医療材料分類マスタの分類区分で、分類が一致するかどうかを判断する
 * @param {Number} findConvertDataNo 対象番号(6:吸着カラム、7:1次膜、8:2次膜、9:穿刺針(A針)、
 * 10:穿刺針(V針)、11:穿刺針(SN)、13:血液回路、15:透析液、19:補液、25:抗凝固剤)
 * @param {Number} classCd 薬剤マスタ/医療材料マスタの分類コード
 * @param {Number} ordNo 対象日付のオーダ番号
 * @param {Number} treatmentCd 治療方法コード
 * @param {string} itemName Reponse name
 */
function getInconClassificationName(getters, findConvertDataNo, classCd, ordNo, treatmentCd, itemName) {
  // add FNSI-FutreNetWeb+SI課題管理No.5323 李 start
  if (itemName.indexOf("削除済み") >= 0) return null;
  // add FNSI-FutreNetWeb+SI課題管理No.5323 李 end

  const inconClassification = "分類不一致";
  // 分類区分
  let mstClassValue = null;
  let inconClassificationName = null;
  let onlineFlg = false;

  // 分類コードがないの場合、「分類不一致」を表示する。
  if (!classCd) return inconClassification;

  // 対象日付のオーダ番号で、対象日付の実績：治療状況を取得する
  const ordNoValue = getters.getOrdNoList.find(ordNoListData => {
    return ordNoListData.ordNo === ordNo;
  });
  // 実績：治療状況が6の場合、分類不一致チェックしない
  // mod FNSI-3910 予定作成時、デベロッパーツールに"Uncaught（in promise）Error"と表示される liumx start
  if (ordNoValue && ordNoValue.rstDialysisState && ordNoValue.rstDialysisState == "6") return;
  // mod FNSI-3910 予定作成時、デベロッパーツールに"Uncaught（in promise）Error"と表示される liumx end

  // オンライン治療(7:OHDF,8:OHF,10:I-HDF)の判断
  const treatmentValue = getters.getMstTreatmentData.find(treatmentData => {
    return treatmentCd === treatmentData.treatmentCd;
  });
  // オンライン治療の場合
  if (treatmentValue &&
    (treatmentValue.deviceMode == "7" || treatmentValue.deviceMode == "8" || treatmentValue.deviceMode == "10")) onlineFlg = true;

  // 実績：治療状況が6以外の場合、各種マスタの分類をチェックする
  switch (findConvertDataNo) {
    // 吸着カラム
    case 6:
      // 医療材料マスタ分類コードで、医療材料分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(2, classCd, getters);
      // 分類区分 != 4の場合、【分類不一致】を表示する。
      if (mstClassValue && 4 != mstClassValue.classType) inconClassificationName = inconClassification;
      break;
    // 1次膜
    case 7:
      // 医療材料マスタ分類コードで、医療材料分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(2, classCd, getters);
      // 分類区分 != 5 and 6の場合、【分類不一致】を表示する。
      if (mstClassValue && (5 != mstClassValue.classType && 6 != mstClassValue.classType)) {
        inconClassificationName = inconClassification;
      }
      break;
    // 2次膜
    case 8:
      // 医療材料マスタ分類コードで、医療材料分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(2, classCd, getters);
      // 分類区分 != 5 and 6の場合、【分類不一致】を表示する。
      if (mstClassValue && 5 != mstClassValue.classType && 6 != mstClassValue.classType) {
        inconClassificationName = inconClassification;
      }
      break;
    // 穿刺針(A針)
    case 9:
      // 医療材料マスタ分類コードで、医療材料分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(2, classCd, getters);
      // 分類区分 != 2の場合、【分類不一致】を表示する。
      if (mstClassValue && 2 != mstClassValue.classType) inconClassificationName = inconClassification;
      break;
    // 穿刺針(V針)
    case 10:
      // 医療材料マスタ分類コードで、医療材料分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(2, classCd, getters);
      // 分類区分 != 2の場合、【分類不一致】を表示する。
      if (mstClassValue && 2 != mstClassValue.classType) inconClassificationName = inconClassification;
      break;
    // 穿刺針(SN)
    case 11:
      // 医療材料マスタ分類コードで、医療材料分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(2, classCd, getters);
      // 分類区分 != 3の場合、【分類不一致】を表示する。
      if (mstClassValue && 3 != mstClassValue.classType) inconClassificationName = inconClassification;
      break;
    // 血液回路
    case 13:
      // 医療材料マスタ分類コードで、医療材料分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(2, classCd, getters);
      // 分類区分 != 1の場合、【分類不一致】を表示する。
      if (mstClassValue && 1 != mstClassValue.classType) inconClassificationName = inconClassification;
      break;
    // 透析液
    case 15:
      // 薬剤マスタ分類コードで、薬剤分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(1, classCd, getters);
      // 分類区分 != 2の場合、【分類不一致】を表示する。
      if (mstClassValue && 2 != mstClassValue.classType) inconClassificationName = inconClassification;
      break;
    // 補液
    case 19:
      // 薬剤マスタ分類コードで、薬剤分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(1, classCd, getters);
      // オンライン治療の場合
      if (onlineFlg) {
        // 分類区分 != 2の場合、【分類不一致】を表示する。
        if (mstClassValue && 2 != mstClassValue.classType) inconClassificationName = inconClassification;
        // オンライン治療以外の場合
      } else {
        // 分類区分 != 3の場合、【分類不一致】を表示する。
        if (mstClassValue && 3 != mstClassValue.classType) inconClassificationName = inconClassification;
      }
      break;
    // 抗凝固剤
    case 25:
      // 薬剤マスタ分類コードで、薬剤分類マスタ分類区分を取得する
      mstClassValue = getClassificationKbn(1, classCd, getters);
      // 分類区分 != 1の場合、【分類不一致】を表示する。
      // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 start
      // if (mstClassValue && 1 != mstClassValue.classType) inconClassificationName = inconClassification;
      if (classCd===-1||(mstClassValue && 1 != mstClassValue.classType)) inconClassificationName = inconClassification;
      // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 end
      break;
  }

  return inconClassificationName;
}

/**
 * 薬剤マスタ/医療材料マスタの分類コードで、分類区分を取得する
 * @param {Number} typeNo 1:薬剤、2:医療材料
 * @param {Number} classCd 薬剤マスタ/医療材料マスタの分類コード
 */
function getClassificationKbn(typeNo, classCd, getters) {
  // 分類区分
  let mstClassValue = null;

  // 薬剤
  if (typeNo === 1) {
    mstClassValue = getters.getMstMedicineClassData.find(mstData => {
      return mstData.classCd === classCd;
    });
  }

  // 医療材料
  else if (typeNo === 2) {
    mstClassValue = getters.getMstEquipmentClassData.find(mstData => {
      return mstData.classCd === classCd;
    });
  }

  return mstClassValue;
}
// add FNSI-連分類不一致が発生した場合、「分類不一致」を表示する。李 end
// add FNSI-投薬支援仕様更新「回帰直線」 周 start
/**
 * 回帰直線データを算出する
 * @param {Number} dtmSDateTime   dtmSDateTime  ⇒   開始日（表示用）
 * @param {Number} intDispRange   intDispRange  ⇒   表示期間「4：12週」「5：6ヶ月」「6：1年」「7：3年」
 * @param {Number} regressionCode udtItem_Exa   ⇒   回帰直線表示用コード（投薬支援マスタから取得）
 * @param {Number} examData       udtItem_Exa   ⇒   患者検査結果情報
 */
function getGraphDataForRegression (dtmSDateTime, intDispRange, regressionCode, examData) {
  // 分割日数「回帰直線」「C#：getGraphDataForRegression（1537～1557行目）」
  const kaikichokusen_bunkatsu_nissuu = paramIntDispRange => {
    switch (paramIntDispRange) {
      // 12週（分割：15日表示）
      case "4":
      default:
        return 15;
      // 6ヶ月（分割：1ヶ月表示）
      case "5":
        return 30;
      // 1年（分割：2ヶ月表示）
      case "6":
        return (30 * 2);
      // 3年（分割：6ヶ月表示）
      case "7":
        return (30 * 6);
    }
  };
  // 分割期間「回帰直線」「C#：getRegressionDateRange」
  const kaikichokusen_bunkatsu_kikan = (paramDtmStartDate, paramIntDevDays, paramMlngREG_DEVISION) => {
    // 戻り値設定
    const udtDev = [];

    // 終了日設定
    for (let intIdx = 0; intIdx < paramMlngREG_DEVISION; intIdx++) {
      let devTag = {
        dtmStartDate: null,
        dtmEndDate: null
      };

      if (intIdx == 0) {
        devTag.dtmStartDate = paramDtmStartDate;
      } else {
        devTag.dtmStartDate = moment(udtDev[intIdx - 1].dtmEndDate).add(1, "days").format("YYYYMMDD");
      }
      devTag.dtmEndDate = moment(paramDtmStartDate).add(paramIntDevDays * (intIdx + 1), "days").format("YYYYMMDD");
      udtDev.push(devTag);
    }
    return udtDev;
  };
  // 計算（データ）「回帰直線」「C#：calcRegression」
  const kaikichokusen_keisan_deta = (paramIntDevDays, paramUdtItem_Exa, paramUdtCalc, paramDtmStartDate) => {
    let result = {
      // 「0：正常終了」「1：データなしその他」「2：異常終了」
      intRet: 0,
      // 検査項目データ構造体（検査項目情報）
      udtItem_Exa: null,
      // 回帰直線算出用データ格納構造体
      udtCalc: null
    };
    let lngDataCnt = 0;   // 開始点からの日数

    //  検査値データを基に、[X変動]の合計、[共変動]の合計を求める
    paramUdtCalc.dblAveDate = paramUdtCalc.intDatacntDev / 2;                                 // 日数の平均値（中心点）
    paramUdtCalc.dblAveExam = paramUdtCalc.dblSumExam / paramUdtCalc.intDatacntDev;                // 検査値の平均値

    paramUdtCalc.dblChgValueBoth = 0;
    paramUdtCalc.dblChgValueDate = 0;
    // 対象の区間内を繰り返す
    for (let intCnt = paramUdtCalc.intStartCnt; intCnt <= (paramUdtCalc.intStartCnt + paramUdtCalc.intDatacntDev - 1); intCnt++) {
      // 開始点からの間隔（日数）を取得する
      lngDataCnt = moment(paramDtmStartDate).diff(moment(paramUdtItem_Exa.dtmDataDate[intCnt]), "days", true);
      // 日数と検査値の共変動を求める
      paramUdtCalc.dblChgValueBoth = paramUdtCalc.dblChgValueBoth + ((lngDataCnt - paramUdtCalc.dblAveDate) * (paramUdtItem_Exa.dblDataValue[intCnt] - paramUdtCalc.dblAveExam));
      // 日数の変動値を求める
      paramUdtCalc.dblChgValueDate = paramUdtCalc.dblChgValueDate + (Math.pow((lngDataCnt - paramUdtCalc.dblAveDate), 2));
    }

    //  [X変動]の合計、[共変動]の合計から、『傾き』と『切片』を求め、
    //  区間の開始点と終了点の値にセットする
    if (paramUdtCalc.dblChgValueDate != 0) {
      paramUdtCalc.dblIntercept = paramUdtCalc.dblChgValueBoth / paramUdtCalc.dblChgValueDate;                   // 傾き
      paramUdtCalc.dblInclination = paramUdtCalc.dblAveExam - paramUdtCalc.dblIntercept * paramUdtCalc.dblAveDate;    // 切片
      // 【開始点】（日数に0を当てはめて求める）
      paramUdtCalc.dblStartPoint = 0 * paramUdtCalc.dblIntercept + paramUdtCalc.dblInclination;
      // 【終了点】（期間を6分割した時の日数を式に当てはめて求める）
      paramUdtCalc.dblEndPoint = paramIntDevDays * paramUdtCalc.dblIntercept + paramUdtCalc.dblInclination;
    } else {
      paramUdtCalc.dblEndPoint = paramUdtCalc.dblStartPoint;                                                // 終了点
    }

    result.udtItem_Exa = paramUdtItem_Exa;
    result.udtCalc = paramUdtCalc;

    return result;
  };
  // 計算（開始）「回帰直線」「C#：setRegressionStart」
  const kaikichokusen_keisan_kaishi = (paramDtmStartDate, paramDblStartPoint, paramUdtItem_Reg) => {
    //回帰直線データ値を設定（開始点）
    //分割開始点のDate
    paramUdtItem_Reg.dtmDataDate.push(moment(paramDtmStartDate).format("YYYY-MM-DD HH:mm:ss"));
    //開始点を設定
    paramUdtItem_Reg.dblDataValue.push(paramDblStartPoint);

    paramUdtItem_Reg.intDataCnt = paramUdtItem_Reg.intDataCnt + 1;

    return paramUdtItem_Reg;
  };
  // 計算（終了）「回帰直線」「C#：setRegressionEnd」
  const kaikichokusen_keisan_shuuryou = (paramIntDevDays, paramDtmEndDate, paramUdtItem_Exa, paramUdtItem_Reg, paramUdtCalc) => {
    const result = {
      // 「0：正常終了」「1：データなしその他」「2：異常終了」
      intRet: 0,
      // 検査項目データ構造体（検査項目情報）
      udtItem_Exa: null,
      // 検査項目データ構造体（回帰直線情報）
      udtItem_Reg: null,
      // 回帰直線算出用データ格納構造体
      udtCalc: null
    };

    // 回帰直線データ値を設定（終了点）
    if (paramUdtCalc.intDatacntDev != 0) {
      if (paramUdtCalc.intDatacntDev == 1) {
        // １件の場合は直線
        // 終了点を設定（開始点と同じ）
        paramUdtItem_Reg.dblDataValue.push(paramUdtCalc.dblStartPoint);
      } else {
        // 分割範囲のデータ算出（終了点）
        const calcResult = kaikichokusen_keisan_deta(paramIntDevDays, paramUdtItem_Exa, paramUdtCalc, paramUdtItem_Reg.dtmDataDate[paramUdtItem_Reg.intDataCnt - 1]);

        // 開始点を再度設定する（２件以上の場合しかココを通らない為、Index番号はマイナス1する）
        paramUdtItem_Reg.dblDataValue.fill(calcResult.udtCalc.dblStartPoint, paramUdtItem_Reg.intDataCnt - 1, paramUdtItem_Reg.intDataCnt);
        paramUdtItem_Reg.dblDataValue.push(calcResult.udtCalc.dblEndPoint);             // 終了点を設定
      }

      // 分割終了点のDate
      paramUdtItem_Reg.dtmDataDate.push(moment(paramDtmEndDate).format("YYYY-MM-DD HH:mm:ss"));
      paramUdtItem_Reg.intDataCnt++;
    }

    result.udtItem_Exa = deepCopy(paramUdtItem_Exa);
    result.udtItem_Reg = deepCopy(paramUdtItem_Reg);
    result.udtCalc = deepCopy(paramUdtCalc);

    return result;
  };
  // 計算（初期化）「回帰直線」「追加」
  const kaikichokusen_keisan_shokika = () => {
    const result = {
      // グラフ種類
      intKind: 0,
      // グラフ形状
      // 0:折れ線グラフ、1:棒グラフ、2:帯状グラフ、3:ダイアライザ形式グラフ
      lngGrphType: 0,
      // グラフY軸凡例表示フラグ
      // false:非表示、true:表示
      blnYLegendFlg: false,
      // グラフ項目コード
      strITEMCODE: "",
      // グラフ項目名称
      strItemName: "",
      // 薬剤区分
      // 0:薬剤、1:薬剤グループ、2:セット薬剤 // Ver.6.1Phase①対応
      intMedKbn: 0,
      // 透析前後区分
      // 0:前、1:後、2:その他、-1:すべて
      intOrderClass: 0,
      // 透析実績区分
      // 0:ダイアライザ、1:透析時間、2:血流量、3:Kt/V測定値、4:URR
      intDialysisKbn: 0,
      // グラフ項目番号
      intItemNo: 0,
      // グラフY軸番号（左から何番目のY軸か）
      intYAxisNo: 0,
      // グラフ表示フラグ
      // false:非表示、true:表示
      blnGrphDispFlg: false,
      // 回帰直線描画
      // false:描画なし、true:描画あり
      blnRegressionFlg: false,
      // 回帰直線描画色
      // Color
      clrRegressColor: "",
      // データ数
      intDataCnt: 0,
      // データ日付
      // DateTime[]
      dtmDataDate: [],
      // データ値
      // Double[]
      dblDataValue: [],
      // データ値2（帯状グラフのデータ値に対する日数）
      // Int64[]
      lngDataValue2: [],
      // データ値3（ダイアライザの型番）
      // String[]
      strDataValue3: [],
      // データ色 （ダイアライザの帯色）
      // Color[]
      clrDataColor: [],
      // 詳細プロパティ
      udtDet: {
        // Y軸最小値
        dblMinY: 0,
        // Y軸最大値
        dblMaxY: 0,
        // 線色
        // Color
        clrLineColor: "",
        // シンボルの形
        // 0:"○"、1:"●"、2:"◎"、3:"△"、4:"▲"、5:"▽"、6:"▼"、7:"□"、8:"■"、9:"◇"、10:"◆"
        intSymbolShape: 0,
        // ダイアライザ帯色1～5（透析実績－ダイアライザのみ使用）
        // Color[]
        clrDiaColor: [],
      }
    };

    return result;
  };
  // 回帰直線情報取得（検査項目情報から、データを算出）
  // 計算（変換）「回帰直線」「追加」
  const kaikichokusen_keisan_henkan = (paramRegressionCode, paramExamData) => {
    const udtItem_Exa = kaikichokusen_keisan_shokika();

    for (const examRecord of paramExamData) {
      if (examRecord.examInfo) {
        for (const examItem of examRecord.examInfo) {
          // 検査情報存在場合
          if (examItem.item_cd.toString() === paramRegressionCode && examItem.result) {
            udtItem_Exa.dtmDataDate.push(moment(examRecord.examDate).format("YYYY-MM-DD HH:mm:ss"));
            //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
            // udtItem_Exa.dblDataValue.push(Number(examItem.result));
            udtItem_Exa.dblDataValue.push(Number(convertToHalfWidth(examItem.result)));
            //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
            udtItem_Exa.intDataCnt = udtItem_Exa.dtmDataDate.length;
          }
        }
      }
    }

    return udtItem_Exa;
  };

  // パラメータチェック
  if (!regressionCode) {
    return null;
  }
  // 回帰直線分割数「6固定」「MultiGraphConst.mlngREG_DEVISION」
  const lines = 6;
  // 表示範囲（分割日数）取得
  const intDevDays = kaikichokusen_bunkatsu_nissuu(intDispRange);
  // 回帰直線分割範囲取得
  const udtDev = kaikichokusen_bunkatsu_kikan(moment(dtmSDateTime).subtract((intDevDays * lines), "days").format("YYYYMMDD"), intDevDays, lines);
  // 分割範囲の回帰直線算出用データ「mudtRegressionCalcTag」
  let udtCalc = {
    // 検査値の開始番号
    intStartCnt: 0,
    // 検査値の登録数（分割範囲内）
    intDatacntDev: 0,
    // 日数の合計
    intSumDate: 0,
    // 検査値の合計
    dblSumExam: 0,
    // 日数の平均値
    dblAveDate: 0,
    // 検査値の平均値
    dblAveExam: 0,
    // 日数と検査値の共変動
    dblChgValueBoth: 0,
    // 日数の変動値
    dblChgValueDate: 0,
    // 傾き
    dblIntercept: 0,
    // 切片
    dblInclination: 0,
    // 開始点
    dblStartPoint: 0,
    // 終了点
    dblEndPoint: 0
  };
  // データ変換「追加処理」
  let udtItem_Exa = kaikichokusen_keisan_henkan(regressionCode, examData);
  let udtItem_Reg = deepCopy(udtItem_Exa);
  let intCntDev = 0;
  // 検査項目情報から回帰直線情報を算出
  for (let intCnt = 0; intCnt < udtItem_Exa.intDataCnt; intCnt++) {
    // 開始点の設定を行う
    if (udtCalc.dblStartPoint == 0) {
      // 分割範囲の判定
      if (moment(udtItem_Exa.dtmDataDate[intCnt]).format("YYYYMMDD") > moment(udtDev[intCntDev].dtmEndDate).format("YYYYMMDD")) {
        // 分割範囲内にデータが１つもない場合
        // 開始点／終了点（Data,Valueはクリアのまま）
        if (intCntDev < (lines - 1)) {
          intCntDev++;                // 次の分割範囲へ
        } else {
          break;                      // 全分割範囲外なら終了
        }

        if (intCnt < udtItem_Exa.intDataCnt) {
          intCnt--;
          continue;                   // 再度、現データが次の分割範囲の開始点であるかの判定を行う
        } else {
          break;                      // 最後のデータが範囲外なら終了
        }
      } else {
        udtCalc.intStartCnt = intCnt;                               // 検査値の開始番号
        udtCalc.dblStartPoint = udtItem_Exa.dblDataValue[intCnt];   // 開始点

        // 分割範囲のデータ設定（開始点）
        udtItem_Reg = kaikichokusen_keisan_kaishi(udtDev[intCntDev].dtmStartDate, udtCalc.dblStartPoint, deepCopy(udtItem_Reg));
      }
    }

    // 分割範囲の判定（データが現在の分割範囲を超えた場合）
    if (moment(udtItem_Exa.dtmDataDate[intCnt]).format("YYYYMMDD") > moment(udtDev[intCntDev].dtmEndDate).format("YYYYMMDD")) {
      // 分割範囲のデータ算出・設定（終了点）
      const calcResult = kaikichokusen_keisan_shuuryou(intDevDays, udtDev[intCntDev].dtmEndDate, deepCopy(udtItem_Exa), deepCopy(udtItem_Reg), deepCopy(udtCalc));
      udtItem_Exa = calcResult.udtItem_Exa;
      udtItem_Reg = calcResult.udtItem_Reg;

      // 次の分割範囲のデータクリア
      udtCalc = {
        // 検査値の開始番号
        intStartCnt: 0,
        // 検査値の登録数（分割範囲内）
        intDatacntDev: 0,
        // 日数の合計
        intSumDate: 0,
        // 検査値の合計
        dblSumExam: 0,
        // 日数の平均値
        dblAveDate: 0,
        // 検査値の平均値
        dblAveExam: 0,
        // 日数と検査値の共変動
        dblChgValueBoth: 0,
        // 日数の変動値
        dblChgValueDate: 0,
        // 傾き
        dblIntercept: 0,
        // 切片
        dblInclination: 0,
        // 開始点
        dblStartPoint: 0,
        // 終了点
        dblEndPoint: 0
      };

      if (intCntDev < (lines - 1)) {
        intCntDev = intCntDev + 1;  // 次の分割範囲へ
      } else {
        break;                      // 全分割範囲外なら終了
      }

      if (intCnt < udtItem_Exa.intDataCnt) {
        intCnt--;
        continue;                   // 再度、現データが次の分割範囲の開始点であるかの判定を行う
      }
      // 最後のデータだったら、次の分割範囲としての合計値算出へ
    }

    if (intCntDev < lines) {
      // 分割範囲内の合計値を算出
      udtCalc.dblSumExam = udtCalc.dblSumExam + udtItem_Exa.dblDataValue[intCnt]; // 検査値の合計
      udtCalc.intDatacntDev = udtCalc.intDatacntDev + 1;                          // 検査値の登録数（分割範囲内）
      udtCalc.intSumDate = udtCalc.intSumDate + udtCalc.intDatacntDev;            // 日数の合計
    }
  }

  // 最後の分割範囲のデータ算出・設定（終了点）
  const calcLastResult = kaikichokusen_keisan_shuuryou(intDevDays, udtDev[intCntDev].dtmEndDate, deepCopy(udtItem_Exa), deepCopy(udtItem_Reg), deepCopy(udtCalc));
  udtItem_Exa = calcLastResult.udtItem_Exa;
  udtItem_Reg = calcLastResult.udtItem_Reg;

  // 回帰直線用データの不足分配列を作成する
  //（配列数は12にて固定のためデータが格納されてない領域を初期値で作成する）
  while (udtItem_Reg.dtmDataDate.length < lines * 2) {
    udtItem_Reg.dtmDataDate.push(0);
    udtItem_Reg.dblDataValue.push(0.0);
    udtItem_Reg.intDataCnt = udtItem_Reg.dtmDataDate.length;
  }

  return udtItem_Reg;
}
// add FNSI-投薬支援仕様更新「回帰直線」 周 end
// add #12462 患者情報共有->患者経過総合ビューア fang start
function otherFacilityOrdMaterialSaveConvert(facilityCd, ordMaterialSave, mstMedicine) {
  let reuslt = []
  if(ordMaterialSave && ordMaterialSave.data && ordMaterialSave.data.length > 0) {
    for(let i = 0; i < ordMaterialSave.data.length; i++) {
      let detail = ordMaterialSave.data[i]
      if(detail.facilityCd != facilityCd) {
        // 通常薬剤だけ処理する
        if(detail.suppliesClass != '12' && detail.suppliesClass != '23' && detail.suppliesClass != '24') {
          // 通常薬剤以外を除く
          continue;
        } else {
          if(detail.standardMedicineCd){
            let medicineIndex = mstMedicine.findIndex(el => el.standardMedicineCd == detail.standardMedicineCd)
            if(medicineIndex != -1) {
              // 本施設の薬剤コードに転換
              detail.suppliesCd = mstMedicine[medicineIndex].medicineCd + "";
              reuslt.push(detail)
            }
          }
        }
      } else {
        reuslt.push(detail)
      }
    }
  }
  return reuslt;
}
function otherFacilityPatExamMainConvert(facilityCd, compareFacilityCd ,patExamMain, examResponse, layout, regOrderClass) {
  if(!examResponse) {
    return patExamMain;
  }
  const examItemInfo = examResponse.data;
  let convertExamItemBases = []
  if(layout) {
    if(layout.categoryItem && layout.categoryItem.length > 0) {
      for(let categoryItem of layout.categoryItem) {
        if(categoryItem && categoryItem.subCategoryItem && categoryItem.subCategoryItem.length > 0) {
            for(let subCategoryItem of categoryItem.subCategoryItem) {
              let itemIndex = examItemInfo.findIndex(el => el.examItemCd == subCategoryItem.itemNo)
              if(itemIndex != -1) {
                subCategoryItem['jlac10_cd'] = examItemInfo[itemIndex].jlac10Cd;
                subCategoryItem['exam_class'] = examItemInfo[itemIndex].examClass;
                subCategoryItem['default_calc_exam_item_cd'] = examItemInfo[itemIndex].defaultCalcExamItemCd;
              }
              convertExamItemBases.push(subCategoryItem)
            }
        }
      }
    }
  } 
  
  let reuslt = []
  if(patExamMain && patExamMain.length > 0 && convertExamItemBases.length > 0) {
    for(let i = 0; i < patExamMain.length; i++) {
      let detail = patExamMain[i]
      if(compareFacilityCd != facilityCd) {
        if(detail.exam_class == '1') {
          // システム標準計算項目の場合、システム標準計算検査項目と一致の検査項目に転換
          let itemIndex = convertExamItemBases.findIndex(el => el.default_calc_exam_item_cd == detail.default_calc_exam_item_cd
            && (el.itemExamClass == regOrderClass || el.itemExamClass == '3'))
          if(itemIndex != -1) {
            detail.item_cd = convertExamItemBases[itemIndex].itemNo;
            reuslt.push(detail)
          }
        } else {
          if(detail.jlac10_cd){
            let itemIndex = convertExamItemBases.findIndex(el => el.jlac10_cd == detail.jlac10_cd && (el.itemExamClass == regOrderClass || el.itemExamClass == '3'))
            if(itemIndex != -1) {
              // jlac10Cdと検査区分が一致の場合
              // 本施設の薬剤コードに転換
              detail.item_cd = convertExamItemBases[itemIndex].itemNo;
              reuslt.push(detail)
            }
          }
        }
      } else {
        reuslt.push(detail)
      }
    }
  }
  return reuslt;
}
// add #12462 患者情報共有->患者経過総合ビューア fang end