/* 個人設定 - デフォルト設定用定数定義 */
// --------------------------------------
// 各画面/機能のキー名称
// --------------------------------------
// 患者経過総合ビューア
export const KEY_NAME_PAT_VIEWER = {
  KEY_NAME : "pat-viewer",
  KEY_NAME_TREAT_ONLY : "isTreatmentOnly",
  KEY_NAME_SELECTED_PERIOD : "selectedPeriod",
  KEY_NAME_EXTENDED_VIEW : "isExtendedView",
  KEY_NAME_SELECTED_SHOW_INDRST : "selectedShowIndRst",
  KEY_NAME_SELECTED_LAYOUT_CD : "setSelectedLayoutCd"
}

// 患者情報・新規患者登録
export const KEY_NAME_PAT_INFO = {
  KEY_NAME : "pat-info",
  // 本人情報
  KEY_NAME_BASIC_INFO : "basicInfoCard",
  // 連絡先
  KEY_NAME_OTHER_CONTACT : "otherContactCard",
  // 業者連絡先
  KEY_NAME_VENDOR_CONTACT : "vendorContactCard",
  // 患者メモ
  KEY_NAME_PAT_MEMO : "patMemoCard",
  // 保険情報
  KEY_NAME_INSURANCE_INFO : "insuranceInfoCard",
  // 困難・搬送
  KEY_NAME_DIFFICULTY_SERVERITY_TRANSPORT : "difficultySeverityTransportCard",
  // 診療
  KEY_NAME_MEDICAL_INFO : "medicalCareInfoCard",
  // 担当情報
  KEY_NAME_CHARGE_STAFF : "chargeStaffCard",
  // 禁忌ｱﾚﾙｷﾞｰ
  KEY_NAME_TABOO_ALLERGY : "tabooAllergyCard",
  // 感染症
  KEY_NAME_INFECTION : "infectionCard",
  // ｲﾝﾌﾟﾗﾝﾄ
  KEY_NAME_IMPLANT : "implantCard",
  // 既往歴
  KEY_NAME_MEDICAL_HST : "medicalHstCard",
  // 入外転入出
  KEY_NAME_VISIT_HST : "visitHstCard",
  // 身体情報
  KEY_NAME_PHYSCAL_INFO : "physicalInfoCard",
  // 患者ｸﾞﾙｰﾌﾟ
  KEY_NAME_PAT_GROUP : "patGroupCard",
  // 遠隔
  KEY_NAME_REMOTE_MONITOR : "remoteMonitorCard",
  // 加算設定
  KEY_NAME_ADDITION_SETTING : "additionSettingCard"
}

// データリスト
export const KEY_NAME_MULTI_PAT_LIST = {
  KEY_NAME : "multi-pat-list",
  KEY_NAME_SELECTED_LAYOUT : "selectedLayout",
  KEY_NAME_START_DATE : "startDate"
}

// スケジュール表
export const KEY_NAME_SCHEDULE_LIST = {
  KEY_NAME : "schedule-list",
  KEY_NAME_DISP_WEEK_DURATION : "dispWeekDuration",
  KEY_NAME_IS_CHK_HOLIDAY : "isCheckedHoliday",
  KEY_NAME_SELECTED_KUR_LIST : "selectedKurIndexList",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_IS_CHK_NAME : "isCheckedName",
  KEY_NAME_IS_CHK_UNMATCH : "isCheckedUnmatch",
  KEY_NAME_IS_CHK_PLAN : "isCheckedPlan",
  KEY_NAME_IS_CHK_PLAN_MAINTE_WATER : "isCheckedPlanMainteWater",
  KEY_NAME_IS_SHOW_GUIDE : "isShowUsageGuide"
}

// 治療状況リスト
export const KEY_NAME_STATUS_LIST = {
  KEY_NAME : "status-list",
  KEY_NAME_DISP_MODE : "dispMode",
  KEY_NAME_NEXT_PAT_GROUP : "nextPatValue",
  KEY_NAME_NEXT_DEVICE : "deviceNextValue",
  KEY_NAME_COL_ITEM_GROUP : "colItemLayoutNo",
  KEY_NAME_KUR_GROUP_LIST : "kurGroupList",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_NOT_USAGE_GUIDE : "notUsageGuide",
  KEY_NAME_DISP_DRO : "dispDro",
  KEY_NAME_DISP_DAD : "dispDad",
  KEY_NAME_DISP_DAB : "dispDab"
}

// 治療状況マップ
export const KEY_NAME_STATUS_MAP = {
  KEY_NAME : "status-map",
  KEY_NAME_DISP_MODE : "dispMode",
  KEY_NAME_BED_LAYOUT_ID : "bedLayoutId",
  KEY_NAME_NEXT_PAT_VALUE : "nextPatValue",
  KEY_NAME_STATUS_LAYOUT_NO : "statusLayoutNo",
  KEY_NAME_KUR_CD : "kurCd",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd"
}

// 体重計測定記録
export const KEY_NAME_MEASURE_HISTORY = {
  KEY_NAME : "measure-history",
  KEY_NAME_KUR_CD : "kurCd",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_FREEWORD : "freeWord",
  KEY_NAME_WEIGHT_SCALE_STATUS : "weightScaleStatus"
}

// チェックリスト
export const CHECK_LIST = {
  KEY_NAME : "check-list",
  KEY_NAME_NEXT_PAT_GROUP : "nextPatValue",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_VIEW_TREAT_DATE : "viewTreatDate",
  KEY_NAME_IS_AUTO_RELOAD : "isAutoReload",
  KEY_NAME_IS_SHOW_GUIDE : "isShowUsageGuide",
  // add 不具合 #6265 dou start
  KEY_NAME_DISP_MODE : "dispMode",
  KEY_NAME_KUR_CD : "kurCd",
  // add 不具合 #6265 dou end
}

// 検査結果
export const EXAM_RECORD = {
  KEY_NAME : "exam-record",
  KEY_NAME_EXAM_SET_CD : "examSetCd",
  KEY_NAME_VIEW_DAY_TYPE : "viewDayType", // 表示条件
  KEY_NAME_EXAM_START_DATE : "examDateSt",
  KEY_NAME_EXAM_END_DATE : "examDateEd",
  KEY_NAME_VIEW_PAT_ID : "viewPatId",
  KEY_NAME_VIEW_EXAM_DATE : "viewExamDate",
  KEY_NAME_NORMAL_RANGE : "normalRange",
  KEY_NAME_OUT_RANGE : "outRange",
  KEY_NAME_UNIT_DISPLAY : "unitDisplay",
}

// 掲示板
export const BBS_INFO = {
  KEY_NAME : "bbs-info",
  KEY_NAME_CATEGORY_KIND_LIST : "categoryKindList",
  KEY_NAME_NOTICE_DATE_TYPE : "noticeDateType",
  KEY_NAME_NOTICE_START_DATE : "noticeStartDate",
  KEY_NAME_NOTICE_END_DATE : "noticeEndDate",
  KEY_NAME_DIALYSIS_DATE : "dialysisDate",
  KEY_NAME_KUR : "kur",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_SHOW_ONLY_UNREAD : "showOnlyUnread"
}

// 検査依頼
export const EXAM_REQUEST = {
  KEY_NAME : "exam-request",
  KEY_NAME_START_DATE : "startDate",
  KEY_NAME_END_DATE : "endDate",
  KEY_NAME_IS_SHOW_DETAIL_DISPLAY : "isShowDetailsDisplay",
  KEY_NAME_IS_SHOW_HOSP_PAT_ID : "isShowHospPatId",
  KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM : "isShowBloodGlucoseExam",
  KEY_NAME_PERIOD_TYPE : "periodType", // 表示形式
  KEY_NAME_SCHEDULED_DATE : "scheduledDate", // 検査予定日
  KEY_NAME_EXAM_TYPE_LIST : "examTypeList", // 検査区分リスト
  KEY_NAME_SHOW_SCHEDULED_ONLY : "showScheduledOnly", // 予定あり患者のみ表示
}

// 一般撮影検査依頼
export const RAD_REQUEST = {
  KEY_NAME : "rad-request",
  KEY_NAME_START_DATE : "startDate",
  KEY_NAME_END_DATE : "endDate",
  KEY_NAME_IS_SHOW_DETAIL_DISPLAY : "isShowDetailsDisplay",
  KEY_NAME_IS_SHOW_HOSP_PAT_ID : "isShowHospPatId"
}

// 患者カレンダー
export const PAT_CALENDAR = {
  KEY_NAME : "pat-calendar",
  KEY_NAME_SELECTED_LAYOUT_CD : "selectedLayoutCd",
  // add #8091 2023/03/15 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 start
  KEY_NAME_EXPAND_FLG : "expandFlg",
  // add #8091 2023/03/15 患者カレンダー/患者カレンダーレイアウトマスタの動作不正 林峻峰 end
}

// 患者イベント
export const PAT_EVENT = {
  KEY_NAME : "pat-event",
  KEY_NAME_RELATION_CATEGORY_CD : "relationCategoryCd",
  KEY_NAME_START_DATE : "startDate",
  KEY_NAME_END_DATE : "endDate"
}

// 観察記録
export const OBSERVE_RECORD = {
  KEY_NAME : "observe-record",
  KEY_NAME_OBS_KIND_LIST : "obsKindList",
  KEY_NAME_START_DATE : "startDate",
  KEY_NAME_END_DATE : "endDate",
  KEY_NAME_DISP_IS_DRAFT : "dispIsDraft",
  KEY_NAME_DISP_IS_EDIT : "dispIsEdit"
}

// 指示受け・承認
export const INDICATION = {
  KEY_NAME : "indication",
  KEY_NAME_TREATMENT_CD : "treatmentCd",
  KEY_NAME_KUR_CDS : "kurCds",        // 治療単位のクール
  KEY_NAME_IND_KUR_CDS : "indKurCds", // 指示単位のクール
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",        // 治療単位のベッドグループ
  KEY_NAME_IND_BED_GROUP_CD : "indBedGroupCd", // 指示単位のベッドグループ
  KEY_NAME_CHECKER1_HAS_NOT_RECEIVED : "checker1HasNotReceived",
  KEY_NAME_CHECKER2_HAS_NOT_RECEIVED : "checker2HasNotReceived",
  KEY_NAME_APPROVER1_HAS_NOT_RECEIVED : "approver1HasNotApproved",
  KEY_NAME_APPROVER2_HAS_NOT_RECEIVED : "approver2HasNotApproved",
  KEY_NAME_INSTRUCTOR_ID : "instructorId",
  KEY_NAME_TREATMENT_SCHEDULE_DATE : "treatmentScheduledDate",
  KEY_NAME_CHECK1 : "check1",
  KEY_NAME_CHECK2 : "check2",
  KEY_NAME_APPROVER1 : "approver1",
  KEY_NAME_APPROVER2 : "approver2",
  KEY_NAME_USER_ID : "userId",
  KEY_NAME_INDICATION_LIST : "indicationList",
}

// 処方一覧
export const PAT_PRESCRIPTION_LIST = {
  KEY_NAME : "pat-prescription-list",
  KEY_NAME_VIEW_PAT_ID : "viewPatId",
  KEY_NAME_VIEW_DATE_INFO : "viewDateInfo",
  KEY_NAME_SEARCH_DATE : "searchDate",
  KEY_NAME_VIEW_PRE_OUT : "viewPreOut",
  KEY_NAME_VIEW_PRE_IN : "viewPreIn",
}

// 処方
export const PAT_PRESCRIPTION = {
  KEY_NAME : "pat-prescription",
  KEY_NAME_START_DATE : "startDate",
  KEY_NAME_END_DATE : "endDate",
  KEY_NAME_CHECK_HOS : "checkHos",
  KEY_NAME_CHECK_ISS : "checkIss",
}

// 紹介状
export const PAT_INTRO_LETTER = {
  KEY_NAME : "pat-intro-letter",
  KEY_NAME_RELATION_CATEGORY_CD : "relationCategoryCd",
  KEY_NAME_START_DATE : "startDate",
  KEY_NAME_END_DATE : "endDate"
}

// 水質調査
export const WATER_QUALITY_SURVEY = {
  KEY_NAME : "water-quality-survey",
  KEY_NAME_FROM_DATE : "fromDate",
  KEY_NAME_TO_DATE : "toDate",
  KEY_NAME_SURVEY_TYPE_CD : "surveyTypeCd",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_IS_DISP_MACHINE_NAME : "isDispMachineName",
  KEY_NAME_IS_DISP_SURVEY_TYPE : "isDispSurveyType"
}

// 定期点検
export const PERIODIC_INSPECTION = {
  KEY_NAME : "periodic-inspection",
  KEY_NAME_FROM_DATE : "fromDate",
  KEY_NAME_TO_DATE : "toDate",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_MACHINE_TYPE_LIST : "machineTypeList"
}

// 日常点検
export const DAILY_CHECK = {
  KEY_NAME : "daily-check",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_MACHINE_TYPE_LIST : "machineTypeList",
  KEY_NAME_IS_NON : "isNon",
  KEY_NAME_IS_FAIL : "isFail",
  KEY_NAME_IS_UNPASS : "isUnpass",
  KEY_NAME_IS_PASS : "isPass",
  KEY_NAME_KEYWORD : "keyWord"
}

// 施設カレンダー
export const FACILITY_CALENDAR = {
  KEY_NAME : "facility-calendar",
  KEY_NAME_VIEW_TOTAL :"viewTotal",
  KEY_NAME_VIEW_MODE : "viewMode",
  KEY_NAME_LAYOUT_CD : "layoutCd",
  KEY_NAME_NOTICE_START_DATE : "noticeStartDate",
  KEY_NAME_NOTICE_END_DATE : "noticeEndDate",
  KEY_NAME_DIALYSIS_DATE : "dialysisDate",
  KEY_NAME_KUR : "kur",
  KEY_NAME_ROOM_BED_GROUP : "roomBedGroup"
}

// P-Ca9分割グラフ
export const KEY_NAME_SPLIT_GRAPH = "split-graph";

// 患者検索
export const PATIENT_SEARCH = {
  KEY_NAME : "patient-search",
  KEY_NAME_KUR_CD_LIST : "kurCdList",
  KEY_NAME_BED_GROUP_LIST : "bedCdListString",
  KEY_NAME_SELECTED_PAT_GROUPS : "selectedPatGroups",
  KEY_NAME_QUERY_PAT_GROUPS_METHOD : "queryPatGroupsMethod",
  KEY_NAME_SORT_CONDITIONS : "sortConditions",
}

// 予実リスト
export const KEY_NAME_INDICATION_RESULT  = {
  KEY_NAME : "indication-result",
  KEY_NAME_TREAT_DATE_FROM : "treatDateFrom",
  KEY_NAME_TREAT_DATE_TO : "treatDateTo",
  KEY_NAME_FILTER : "filter",
  KEY_NAME_INDICATION : "indication",
  KEY_NAME_SELECT_EXPRESS_COND_LIST : "selectExpressCondList",
  KEY_NAME_PAST_INDICATION: "pastIndication"
}

// 患者情報共有
export const PAT_INFO_SHARING = {
  KEY_NAME: "pat_info_sharing",
  KEY_NAME_FREEWORD: "freeWord",
  KEY_NAME_GENDER : "gender",
  KEY_NAME_BLOODTYPE : "bloodType",
  KEY_NAME_BIRTHDAY_FROM: "birthdayFrom",
  KEY_NAME_BIRTHDAY_TO: "birthdayTo",
  KEY_NAME_FACILITY_CD_TO: "facilityCdTo",
  KEY_NAME_FACILITY_CD_FROM : "facilityCdFrom",
  KEY_NAME_IS_SHOW_SHARE_TO : "isShowShareTo",
  KEY_NAME_IS_SHOW_SHARE_FROM: "isShowShareFrom",
  KEY_NAME_IS_SHOW_SHARE_REFUSE : "isShowShareRefuse",
  KEY_NAME_IS_SHOW_SHARE : "isShowShare",
}

// #11987 2026.01.15 add スケールベッド TDC伊東 start
export const KEY_NAME_SCALE_BED = {
  KEY_NAME : "scale-bed",
  KEY_NAME_KUR_GROUP_LIST : "kurGroupList",
  KEY_NAME_BED_GROUP_CD : "bedGroupCd",
  KEY_NAME_IS_SHOW_GUIDE : "isShowUsageGuide"
}
// #11987 2026.01.15 add スケールベッド TDC伊東 end

// 日付の選択肢
export const DATE_CHOICES = {
  UNDETERMINED: {
    title: "",
    value: "0"
  },
  BEFORE_THREE_YEAR: {
    title: "3年前",
    value: "1"
  },
  BEFORE_ONE_YEAR: {
    title: "1年前",
    value: "2"
  },
  BEFORE_SIX_MONTH: {
    title: "6ヶ月前",
    value: "3"
  },
  BEFORE_THREE_MONTH: {
    title: "3ヶ月前",
    value: "4"
  },
  BEFORE_ONE_MONTH: {
    title: "1ヶ月前",
    value: "5"
  },
  BEFORE_TWO_WEEK: {
    title: "2週間前",
    value: "6"
  },
  BEFORE_ONE_WEEK: {
    title: "1週間前",
    value: "7"
  },
  FIRSTDAY_OF_WEEK: {
    title: "今週開始日",
    value: "8"
  },
  BEFORE_FIVE_YEAR: {
    title: "5年前",
    value: "9"
  },
  BEFORE_TEN_YEAR: {
    title: "10年前",
    value: "10"
  },
  TODAY: {
    title: "本日",
    value: "20"
  },
  LASTDAY_OF_WEEK: {
    title: "今週終了日",
    value: "21"
  },
  AFTER_ONE_WEEK: {
    title: "1週間後",
    value: "22"
  },
  AFTER_TWO_WEEK: {
    title: "2週間後",
    value: "23"
  },
  AFTER_ONE_MONTH: {
    title: "1ヶ月後",
    value: "24"
  },
  AFTER_THREE_MONTH: {
    title: "3ヶ月後",
    value: "25"
  },
  AFTER_SIX_MONTH: {
    title: "6ヶ月後",
    value: "26"
  },
  AFTER_ONE_YEAR: {
    title: "1年後",
    value: "27"
  },
  AFTER_THREE_YEAR: {
    title: "3年後",
    value: "29"
  },
  TOMMOROW: {
    title: "翌日",
    value: "28"
  },
  AFTER_FIVE_YEAR: {
    title: "5年後",
    value: "30"
  },
  AFTER_TEN_YEAR: {
    title: "10年後",
    value: "31"
  },
  DAY_AFTER_TOMMOROW: {
    title: "明後日",
    value: "32"
  },
  NEXT_MONDAY: {
    title: "翌週月曜日",
    value: "33"
  }
}

// 患者検索の患者リストのソート項目
export const SORT_OPTIONS = [
  { key: null, displayValue: "　" },
  { key: "hosp_pat_id", displayValue: "患者ID" },
  { key: "pat_name", displayValue: "患者名" },
  { key: "in_out_class", displayValue: "入外区分" },
  { key: "in_out_current_state", displayValue: "在院状態" },
  { key: "pat_kur", displayValue: "クール" },
  { key: "pat_bed_name", displayValue: "ベッド" },
  { key: "ind_tr_cd", displayValue: "治療方法" },
  { key: "pat_sex", displayValue: "性別" },
  { key: "pat_birthday_age", displayValue: "生年月日" },
  { key: "pat_birthday", displayValue: "年齢" },
  { key: "pat_blood_type_abo", displayValue: "血液型" },
  { key: "taboo_allergy_info", displayValue: "禁忌" },
  { key: "is_infect", displayValue: "感染症" },
  { key: "is_implant", displayValue: "インプラント" },
  { key: "is_diabetes", displayValue: "糖尿病" },
  { key: "is_blood_suger_exam", displayValue: "血糖検査" },
  { key: "dial_diff_com_info", displayValue: "主たる透析困難理由" },
  { key: "severity_cd", displayValue: "重症度" },
  { key: "transport_cd", displayValue: "搬送区分" },
  { key: "is_wheel_chair", displayValue: "車いす利用" },
  { key: "dialysis_start_date", displayValue: "透析歴" },
  { key: "is_dia_under_dis", displayValue: "透析導入原疾患" },
  { key: "is_main_disease", displayValue: "主病" },
  { key: "main_course_cd", displayValue: "診療科" },
  { key: "dialysis_course_cd", displayValue: "透析実施科" },
  { key: "ward_cd", displayValue: "病棟" },
]
