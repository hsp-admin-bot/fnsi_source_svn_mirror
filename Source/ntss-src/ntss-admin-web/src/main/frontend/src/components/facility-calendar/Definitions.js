class LayoutItem {
  /**
   * @constructor
   * @param {String} title 項目名
   * @param {String} key 項目キー
   * @param {String} shortTitle
   */
  constructor(title, key, shortTitle) {
    this.title = title;
    this.key = key;
    this.shortTitle = shortTitle;
    this.cd = null;
    this.isDisp = false;
  }
}
/**全治療件数*/
export const ITEM_TOTAL_TREATMENTS = new LayoutItem('全治療件数', 'total_treatments', '全');
/**透析治療件数*/
export const ITEM_DIALYSIS_TREATMENTS = new LayoutItem('透析治療件数', 'dialysis_treatments', '透析');
/**HD治療件数*/
export const ITEM_HD_TREATMENTS = new LayoutItem('HD治療件数', 'hd_treatments', 'HD');
/**ECUM治療件数*/
export const ITEM_ECUM_TREATMENTS = new LayoutItem('ECUM治療件数', 'ecum_treatments', 'ECUM');
/**HDF治療件数*/
export const ITEM_HDF_TREATMENTS = new LayoutItem('HDF治療件数', 'hdf_treatments', 'HDF');
/**HF治療件数*/
export const ITEM_HF_TREATMENTS = new LayoutItem('HF治療件数', 'hf_treatments', 'HF');
/**AFBF治療件数*/
export const ITEM_AFBF_TREATMENTS = new LayoutItem('AFBF治療件数', 'afbf_treatments', 'AFBF');
/**OHDF治療件数*/
export const ITEM_OHDF_TREATMENTS = new LayoutItem('OHDF治療件数', 'ohdf_treatments', 'OHDF');
/**OHF治療件数*/
export const ITEM_OHF_TREATMENTS = new LayoutItem('OHF治療件数', 'ohf_treatments', 'OHF');
/**I-HDF治療件数*/
export const ITEM_I_HDF_TREATMENTS_NUMBER = new LayoutItem('I-HDF治療件数', 'i_hdf_treatments_number', 'I-HDF');
/**特殊浄化治療件数*/
export const ITEM_SPECIAL_PURIFICATION_TREATMENTS_NUMBER = new LayoutItem('特殊浄化治療件数', 'special_purification_treatments_number', '特殊浄化');
/**外来患者治療件数*/
export const ITEM_OUTPATIENT_TREATMENTS = new LayoutItem('外来患者治療件数', 'outpatient_treatments', '外来治療');
/**入院患者治療件数*/
export const ITEM_INPATIENT_TREATMENTS_NUMBER = new LayoutItem('入院患者治療件数', 'inpatient_treatments_number', '入院治療');
/**クール別治療件数*/
export const ITEM_TREATMENTS_BY_COURSE_NUMBER = new LayoutItem('クール別治療件数', 'treatments_by_course_number', '件');
/**導入件数*/
export const ITEM_INTRODUCTIONS_NUMBER = new LayoutItem('導入件数', 'introductions_number', '導入');
/**転入件数*/
export const ITEM_MOVE_IN_NUMBER = new LayoutItem('転入件数', 'move_in_number', '転入');
/**転出件数*/
export const ITEM_MOVING_OUT_NUMBER = new LayoutItem('転出件数', 'moving_out_number', '転出');
/**入院件数*/
export const ITEM_HOSPITALIZATIONS_NUMBER = new LayoutItem('入院件数', 'hospitalizations_number', '入院');
/**退院件数*/
export const ITEM_DISCHARGES_NUMBER = new LayoutItem('退院件数', 'discharges_number', '退院');
/**外来件数*/
export const ITEM_OUTPATIENTS = new LayoutItem('外来件数', 'outpatients', '外来');
/**離脱件数*/
export const ITEM_WITHDRAWALS = new LayoutItem('離脱件数', 'withdrawals', '離脱');
/**移植件数*/
export const ITEM_TRANSPLANTS_NUMBER = new LayoutItem('移植件数', 'transplants_number', '移植');
/**一時転出(出)件数*/
export const ITEM_TEMPORARY_TRANSFERS_OUTS_NUMBER = new LayoutItem('一時転出(出)件数', 'temporary_transfers_outs_number', '一時転出(出)');
/**一時転出(入)件数*/
export const ITEM_TEMPORARY_TRANSFERS_IN_NUMBER = new LayoutItem('一時転出(入)件数', 'temporary_transfers_in_number', '一時転出(入)');
/**拒否・不明件数*/
export const ITEM_REJECTED_UNKNOWN_NUMBER = new LayoutItem('拒否・不明件数', 'rejected_unknown_number', '拒否・不明');
/**死亡件数*/
export const ITEM_DEATHS = new LayoutItem('死亡件数', 'deaths', '死亡');
/**検査予定件数*/
export const ITEM_SCHEDULED_NUMBER_INSPECTIONS = new LayoutItem('検査予定件数', 'scheduled_number_inspections', '検査');
/**放射線予定件数*/
export const ITEM_EXPECTED_NUMBER_RADIATION = new LayoutItem('放射線予定件数', 'expected_number_radiation', '放射線');
/**患者イベントカテゴリマスタ分繰り返す*/
export const ITEM_REPEAT_PAT_EVENT_CATEGORY = new LayoutItem('患者イベントカテゴリマスタ分繰り返す', 'repeat_pat_event_category', 'カテゴリ名');
/**患者イベントサブカテゴリマスタ分繰り返す*/
export const ITEM_REPEAT_PAT_EVENT_SUBCATEGORY = new LayoutItem('患者イベントサブカテゴリマスタ分繰り返す', 'repeat_pat_event_subcategory', 'サブカテゴリ名');
/**自己診断結果*/
export const ITEM_SELF_DIAGNOSIS_RESULT = new LayoutItem('自己診断結果', 'self_diagnosis_result', '自己診断');
/**日常点検列名分繰り返す*/
export const ITEM_REPEAT_DAILY_INSPECTION = new LayoutItem('日常点検列名分繰り返す', 'repeat_daily_inspection', '日常点検列名');
/**定期点検*/
export const ITEM_PERIODIC_INSPECTION = new LayoutItem('定期点検', 'periodic_inspection', '定期点検');
/**水質管理*/
export const ITEM_WATER_QUALITY_MANAGEMENT = new LayoutItem('水質管理', 'water_quality_management', '水質');
/**施設イベントカテゴリ分繰り返す*/
export const ITEM_REPEAT_FACILITY_EVENT_CATEGORIES = new LayoutItem('施設イベントカテゴリ分繰り返す', 'repeat_facility_event_categories', 'カテゴリ', );

export const ITEM_LAYOUT = {
  [ITEM_TOTAL_TREATMENTS.key]: ITEM_TOTAL_TREATMENTS,
  [ITEM_DIALYSIS_TREATMENTS.key]: ITEM_DIALYSIS_TREATMENTS,
  [ITEM_HD_TREATMENTS.key]: ITEM_HD_TREATMENTS,
  [ITEM_ECUM_TREATMENTS.key]: ITEM_ECUM_TREATMENTS,
  [ITEM_HDF_TREATMENTS.key]: ITEM_HDF_TREATMENTS,
  [ITEM_HF_TREATMENTS.key]: ITEM_HF_TREATMENTS,
  [ITEM_AFBF_TREATMENTS.key]: ITEM_AFBF_TREATMENTS,
  [ITEM_OHDF_TREATMENTS.key]: ITEM_OHDF_TREATMENTS,
  [ITEM_OHF_TREATMENTS.key]: ITEM_OHF_TREATMENTS,
  [ITEM_I_HDF_TREATMENTS_NUMBER.key]: ITEM_I_HDF_TREATMENTS_NUMBER,
  [ITEM_SPECIAL_PURIFICATION_TREATMENTS_NUMBER.key]: ITEM_SPECIAL_PURIFICATION_TREATMENTS_NUMBER,
  [ITEM_OUTPATIENT_TREATMENTS.key]: ITEM_OUTPATIENT_TREATMENTS,
  [ITEM_INPATIENT_TREATMENTS_NUMBER.key]: ITEM_INPATIENT_TREATMENTS_NUMBER,
  [ITEM_TREATMENTS_BY_COURSE_NUMBER.key]: ITEM_TREATMENTS_BY_COURSE_NUMBER,
  [ITEM_INTRODUCTIONS_NUMBER.key]: ITEM_INTRODUCTIONS_NUMBER,
  [ITEM_MOVE_IN_NUMBER.key]: ITEM_MOVE_IN_NUMBER,
  [ITEM_MOVING_OUT_NUMBER.key]: ITEM_MOVING_OUT_NUMBER,
  [ITEM_HOSPITALIZATIONS_NUMBER.key]: ITEM_HOSPITALIZATIONS_NUMBER,
  [ITEM_DISCHARGES_NUMBER.key]: ITEM_DISCHARGES_NUMBER,
  [ITEM_OUTPATIENTS.key]: ITEM_OUTPATIENTS,
  [ITEM_WITHDRAWALS.key]: ITEM_WITHDRAWALS,
  [ITEM_TRANSPLANTS_NUMBER.key]: ITEM_TRANSPLANTS_NUMBER,
  [ITEM_TEMPORARY_TRANSFERS_OUTS_NUMBER.key]: ITEM_TEMPORARY_TRANSFERS_OUTS_NUMBER,
  [ITEM_TEMPORARY_TRANSFERS_IN_NUMBER.key]: ITEM_TEMPORARY_TRANSFERS_IN_NUMBER,
  [ITEM_REJECTED_UNKNOWN_NUMBER.key]: ITEM_REJECTED_UNKNOWN_NUMBER,
  [ITEM_DEATHS.key]: ITEM_DEATHS,
  [ITEM_SCHEDULED_NUMBER_INSPECTIONS.key]: ITEM_SCHEDULED_NUMBER_INSPECTIONS,
  [ITEM_EXPECTED_NUMBER_RADIATION.key]: ITEM_EXPECTED_NUMBER_RADIATION,
  [ITEM_REPEAT_PAT_EVENT_CATEGORY.key]: ITEM_REPEAT_PAT_EVENT_CATEGORY,
  [ITEM_REPEAT_PAT_EVENT_SUBCATEGORY.key]: ITEM_REPEAT_PAT_EVENT_SUBCATEGORY,
  [ITEM_SELF_DIAGNOSIS_RESULT.key]: ITEM_SELF_DIAGNOSIS_RESULT,
  [ITEM_REPEAT_DAILY_INSPECTION.key]: ITEM_REPEAT_DAILY_INSPECTION,
  [ITEM_PERIODIC_INSPECTION.key]: ITEM_PERIODIC_INSPECTION,
  [ITEM_WATER_QUALITY_MANAGEMENT.key]: ITEM_WATER_QUALITY_MANAGEMENT,
  [ITEM_REPEAT_FACILITY_EVENT_CATEGORIES.key]: ITEM_REPEAT_FACILITY_EVENT_CATEGORIES
}

class UnitItem {
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
export const ITEM_UNIT_ITEM = new UnitItem('件', 'item');
export const ITEM_UNIT_PERSON = new UnitItem('人', 'person');
export const ITEM_UNIT_TITLE = new UnitItem('件', 'title');
export const ITEM_UNIT_TABLE = new UnitItem('台', 'table');

export const ITEM_UNIT = {
  [ITEM_UNIT_ITEM.key]: ITEM_UNIT_ITEM,
  [ITEM_UNIT_PERSON.key]: ITEM_UNIT_PERSON,
  [ITEM_UNIT_TITLE.key]: ITEM_UNIT_TITLE,
  [ITEM_UNIT_TABLE.key]: ITEM_UNIT_TABLE,
}

/** ルーティング用文字列-患者情報 */
export const ROUTERLINK_PATINFO = "pat-info";
/** ルーティング用文字列-患者経過総合ビューア */
export const ROUTERLINK_FACILITYVIEWER = "facility-viewer";
/** ルーティング用文字列-スケジュールリスト */
export const ROUTERLINK_SCHEDULE_LIST = "schedule-list";
/** ルーティング用文字列-施設カレンダ */
export const ROUTERLINK_FACILITY_CALENDAR = "facility-calendar";
/** ルーティング用文字列-施設カレンダ詳細 */
export const ROUTERLINK_FACILITY_CALENDAR_DETAIL = "facility-calendar-detail";
/** ルーティング用文字列-施設カレンダー作成 */
export const ROUTERLINK_FACILITY_CALENDAR_CREATE = "facility-calendar-create";
/** ルーティング用文字列-水質管理 */
export const ROUTERLINK_WATER_QUALITY_SURVEY = "water-quality-survey";
/** ルーティング用文字列-日常点検 */
export const ROUTERLINK_DAILY_CHECK = "daily-check";
/** ルーティング用文字列-定期点検 */
export const ROUTERLINK_PERIODIC_INSPECTION = "periodic-inspection";
/** ルーティング用文字列-検査依頼一覧 */
export const ROUTERLINK_EXAM_REQUEST = "exam-request";
/** ルーティング用文字列-一般検査依頼一覧 */
export const ROUTERLINK_RAD_REQUEST = "rad-request";
// add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou start
/** ルーティング用文字列-遠隔監視 */
export const ROUTERLINK_OPERATION_VIEWER_GENERAL_MACHINES = "operation-viewer-general-machines";
// add FNSI-改修内容 自己診断結果：合格xx台、不合格xx台、未実施xx台 dou end
/** ルーティング用文字列-患者イベント */
export const ROUTERLINK_PAT_EVENT = "pat-event";
