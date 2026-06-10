/* pat_personal_main 定数*/
// pat_id
export const PAT_PERSONAL_MAIN_COL_PAT_ID = "pat_id";
// fn_pat_id
export const PAT_PERSONAL_MAIN_COL_FN_PAT_ID = "fn_pat_id";
// hosp_pat_id
export const PAT_PERSONAL_MAIN_COL_HOSP_PAT_ID = "hosp_pat_id";
// nkk_pat_id
export const PAT_PERSONAL_MAIN_COL_NKK_PAT_ID = "nkk_pat_id";
// facility_cd
export const PAT_PERSONAL_MAIN_COL_FACILITY_CD = "facility_cd";
// pat_last_name
export const PAT_PERSONAL_MAIN_COL_PAT_LAST_NAME = "pat_last_name";
// pat_first_name
export const PAT_PERSONAL_MAIN_COL_PAT_FIRST_NAME = "pat_first_name";
// pat_last_name_kana
export const PAT_PERSONAL_MAIN_COL_PAT_LAST_NAME_KANA = "pat_last_name_kana";
// pat_first_name_kana
export const PAT_PERSONAL_MAIN_COL_PAT_FIRST_NAME_KANA = "pat_first_name_kana";
// pat_last_name_alpha
export const PAT_PERSONAL_MAIN_COL_PAT_LAST_NAME_ALPHA = "pat_last_name_alpha";
// pat_first_name_alpha
export const PAT_PERSONAL_MAIN_COL_PAT_FIRST_NAME_ALPHA =
  "pat_first_name_alpha";
// pat_birth_name
export const PAT_PERSONAL_MAIN_COL_PAT_BIRTH_NAME = "pat_birth_name";
// pat_birth_name_kana
export const PAT_PERSONAL_MAIN_COL_PAT_BIRTH_NAME_KANA = "pat_birth_name_kana";
// pat_birth_name_alpha
export const PAT_PERSONAL_MAIN_COL_PAT_BIRTH_NAME_ALPHA =
  "pat_birth_name_alpha";
// pat_birthday
export const PAT_PERSONAL_MAIN_COL_PAT_BIRTHDAY = "pat_birthday";
// pat_sex
export const PAT_PERSONAL_MAIN_COL_PAT_SEX = "pat_sex";
// pat_sex_options
export const PAT_PERSONAL_MAIN_COL_PAT_SEX_OPTIONS = [
  { value: 0, displayValue: "不明" },
  { value: 1, displayValue: "男性" },
  { value: 2, displayValue: "女性" }
];
// pat_sex_param
export const PAT_PERSONAL_MAIN_COL_PAT_SEX_N = "0";
export const PAT_PERSONAL_MAIN_COL_PAT_SEX_M = "1";
export const PAT_PERSONAL_MAIN_COL_PAT_SEX_W = "2";

// nationality
export const PAT_PERSONAL_MAIN_COL_NATIONALITY = "nationality";
// pat_blood_type_abo
export const PAT_PERSONAL_MAIN_COL_PAT_BLOOD_TYPE_ABO = "pat_blood_type_abo";
// pat_blood_type_abo_options
export const PAT_BLOOD_TYPE_ABO_OPTIONS = [
  { value: 0, displayValue: "不明" },
  { value: 1, displayValue: "A型" },
  { value: 2, displayValue: "B型" },
  { value: 3, displayValue: "O型" },
  { value: 4, displayValue: "AB型" }
];
// pat_blood_type_rh
export const PAT_PERSONAL_MAIN_COL_PAT_BLOOD_TYPE_RH = "pat_blood_type_rh";
// pat_blood_type_rh_options
export const PAT_BLOOD_TYPE_RH_OPTIONS = [
  { value: 0, displayValue: "不明" },
  { value: 1, displayValue: "Rh+" },
  { value: 2, displayValue: "Rh-" }
];
// pat_blood_type_serovar
export const PAT_PERSONAL_MAIN_COL_PAT_BLOOD_TYPE_SEROVAR =
  "pat_blood_type_serovar";
// pat_blood_type_serovar_options
export const PAT_BLOOD_TYPE_SEROVAR_OPTIONS = [
  { value: 0, displayValue: "不明" },
  { value: 11, displayValue: "A1" },
  { value: 12, displayValue: "Aint" },
  { value: 13, displayValue: "A2" },
  { value: 14, displayValue: "A3" },
  { value: 15, displayValue: "Ax" },
  { value: 16, displayValue: "Am" },
  { value: 17, displayValue: "Ael" },
  { value: 18, displayValue: "Aend" },
  { value: 21, displayValue: "B1" },
  { value: 22, displayValue: "Bint" },
  { value: 23, displayValue: "B2" },
  { value: 24, displayValue: "B3" },
  { value: 25, displayValue: "Bx" },
  { value: 26, displayValue: "Bm" },
  { value: 27, displayValue: "Bel" },
  { value: 28, displayValue: "Bend" }
];
// in_out_class
export const PAT_PERSONAL_MAIN_COL_IN_OUT_CLASS = "in_out_class";
// 外来 入外値
const OUTPATIENT = 0;
// 入院
const HOSPITALIZATION = 1;
// 死亡
const DEATH = 2;
// - (不在)
const ABSRENCE = 3;
export const PAT_PERSONAL_MAIN_COL_IN_OUT_VISIT_HISTORY_INFO_IN_OUT_CLASS = [
  {
    value: OUTPATIENT,
    displayValue: "外来"
  },
  {
    value: HOSPITALIZATION,
    displayValue: "入院"
  },
  {
    value: DEATH,
    displayValue: "死亡"
  },
  {
    value: ABSRENCE,
    displayValue: "-"
  }
];
// is_die
export const PAT_PERSONAL_MAIN_COL_IS_DIE = "is_die";
// die_cd
export const PAT_PERSONAL_MAIN_COL_DIE_CD = "die_cd";
// die_date
export const PAT_PERSONAL_MAIN_COL_DIE_DATE = "die_date";
// dial_diff_com_info
export const PAT_PERSONAL_MAIN_COL_DIAL_DIFF_COM_INFO_CTL_NO = "ctl_no";
export const PAT_PERSONAL_MAIN_COL_DIAL_DIFF_COM_INFO_DIAL_DIFF_CD =
  "dial_diff_cd";
export const PAT_PERSONAL_MAIN_COL_DIAL_DIFF_COM_INFO_IS_MAIN = "is_main";
export const PAT_PERSONAL_MAIN_COL_DIAL_DIFF_COM_INFO_IS_DIAL_DIFF =
  "is_dial_diff";
export const PAT_PERSONAL_MAIN_COL_DIAL_DIFF_COM_INFO_REG_DATE = "reg_date";
// severity_cd
export const PAT_PERSONAL_MAIN_COL_SEVERITY_CD = "severity_cd";
// transport_cd
export const PAT_PERSONAL_MAIN_COL_TRANSPORT_CD = "transport_cd";
// pat_contact_info
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_FAX = "fax";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_TEL1 = "tel1";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_TEL2 = "tel2";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_MEMO1 = "memo1";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_MEMO2 = "memo2";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_E_MAIL = "e_mail";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_ZIP_CD = "zip_cd";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_ADDRESS = "address";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_WORK_TEL = "work_tel";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_WORK_NAME = "work_name";
export const PAT_PERSONAL_MAIN_COL_PAT_CONTACT_INFO_WORK_ADDRESS =
  "work_address";
// other_contact_info
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_CTL_NO = "ctl_no";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_DISP_ORDER = "disp_order";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_IS_KEY_PERSON =
  "is_key_person";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_LAST_NAME = "last_name";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_FIRST_NAME = "first_name";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_RELATION_CD =
  "relation_cd";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_RELATION_NAME =
  "relation_name";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_ZIP_CD = "zip_cd";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_ADDRESS = "address";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_TEL1 = "tel1";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_TEL2 = "tel2";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_FAX = "fax";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_E_MAIL = "e_mail";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_WORK_NAME = "work_name";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_WORK_TEL = "work_tel";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_MEMO1 = "memo1";
export const PAT_PERSONAL_MAIN_COL_OTHER_CONTACT_INFO_MEMO2 = "memo2";
// vendor_contact_info
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_CTL_NO = "ctl_no";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_DISP_ORDER =
  "disp_order";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_COMPANY_NAME =
  "company_name";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_ZIP_CD = "zip_cd";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_ADDRESS = "address";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_COMPANY_TEL =
  "company_tel";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_FAX = "fax";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_WORKER_LAST_NAME =
  "worker_last_name";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_WORKER_FIRST_NAME =
  "worker_first_name";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_WORKER_TEL =
  "worker_tel";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_WORKER_E_MAIL =
  "worker_e_mail";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_MEMO1 = "memo1";
export const PAT_PERSONAL_MAIN_COL_VENDOR_CONTACT_INFO_MEMO2 = "memo2";
// insurance_info
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_INSURANCE_NO = "insurance_no";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_INSURANCE_CLASS =
  "insurance_class";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_INSURED_CD = "insured_cd";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_INSURED_NO = "insured_no";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_INSURANCE_RATIO =
  "insurance_ratio";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_PUB_INSU_NO1 = "pub_insu_no1";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_PUB_INSU_NO2 = "pub_insu_no2";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_PUB_INSU_REC_NO1 =
  "pub_insu_rec_no1";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_PUB_INSU_REC_NO2 =
  "pub_insu_rec_no2";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_INSURANCE_MEMO1 =
  "insurance_memo1";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_INSURANCE_MEMO2 =
  "insurance_memo2";
export const PAT_PERSONAL_MAIN_COL_INSURANCE_INFO_DISABILITY_NO =
  "disability_no";
// is_del
export const PAT_PERSONAL_MAIN_COL_IS_DEL = "is_del";
// up_date
export const PAT_PERSONAL_MAIN_COL_UP_DATE = "up_date";
// reg_date
export const PAT_PERSONAL_MAIN_COL_REG_DATE = "reg_date";

/* pat_main 定数*/
// pat_id
export const PAT_MAIN_COL_PAT_ID = "pat_id";
// facility_cd
export const PAT_MAIN_COL_FACILITY_CD = "facility_cd";
// is_same
export const PAT_MAIN_COL_IS_SAME = "is_same";
// is_implant
export const PAT_MAIN_COL_IS_IMPLANT = "is_implant";
// is_infect
export const PAT_MAIN_COL_IS_INFECT = "is_infect";
// is_diabetes
export const PAT_MAIN_COL_IS_DIABETES = "is_diabetes";
// is_blood_suger_exam
export const PAT_MAIN_COL_IS_BLOOD_SUGER_EXAM = "is_blood_suger_exam";
// in_out_current_state
export const PAT_MAIN_COL_IN_OUT_CURRENT_STATE = "in_out_current_state";
// in_out_plan_state
export const PAT_MAIN_COL_IN_OUT_PLAN_STATE = "in_out_plan_state";
// in_out_plan_date
export const PAT_MAIN_COL_IN_OUT_PLAN_DATE = "in_out_plan_date";
// pat_memo_info
export const PAT_MAIN_COL_PAT_MEMO_INFO_TITLE = "title";
export const PAT_MAIN_COL_PAT_MEMO_INFO_CONTENT = "content";
// addition_info
export const PAT_MAIN_COL_ADDITION_INFO_CTL_NO = "ctl_no";
export const PAT_MAIN_COL_ADDITION_INFO_RECEIPT_MEMO_CODE = "receipt_memo_code";
export const PAT_MAIN_COL_ADDITION_INFO_IS_ADD = "is_add";
export const PAT_MAIN_COL_ADDITION_INFO_REG_DATE = "reg_date";
// charge_staff_info
export const PAT_MAIN_COL_CHARGE_STAFF_INFO_CTL_NO = "ctl_no";
export const PAT_MAIN_COL_CHARGE_STAFF_INFO_DISP_ORDER = "disp_order";
export const PAT_MAIN_COL_CHARGE_STAFF_INFO_STAFF_CD = "staff_cd";
export const PAT_MAIN_COL_CHARGE_STAFF_INFO_IS_MAIN = "is_main";
export const PAT_MAIN_COL_CHARGE_STAFF_INFO_IS_CHARGE = "is_charge";
export const PAT_MAIN_COL_CHARGE_STAFF_INFO_IS_PUNCTURE = "is_puncture";
// pat_group_info
export const PAT_MAIN_COL_PAT_GROUP_INFO_CTL_NO = "ctl_no";
export const PAT_MAIN_COL_PAT_GROUP_INFO_PAT_GROUP_CD = "pat_group_cd";
// taboo_allergy_info
export const PAT_MAIN_COL_TABOO_ALLERGY_INFO_CTL_NO = "ctl_no";
export const PAT_MAIN_COL_TABOO_ALLERGY_INFO_DISP_ORDER = "disp_order";
export const PAT_MAIN_COL_TABOO_ALLERGY_INFO_CONTENT = "content";
export const PAT_MAIN_COL_TABOO_ALLERGY_INFO_MEMO = "memo";
export const PAT_MAIN_COL_TABOO_ALLERGY_INFO_CATEGORY_CLASS = "category_class";
export const PAT_MAIN_COL_TABOO_ALLERGY_INFO_TABOO_ALLERGY_CLASS =
  "taboo_allergy_class";
export const PAT_MAIN_COL_TABOO_ALLERGY_INFO_TABOO_ALLERGY_CD =
  "taboo_allergy_cd";
// infect_info
export const PAT_MAIN_COL_INFECT_INFO_CTL_NO = "ctl_no";
export const PAT_MAIN_COL_INFECT_INFO_INFECTION_CD = "infection_cd";
export const PAT_MAIN_COL_INFECT_INFO_INFECT = "infect";
export const PAT_MAIN_COL_INFECT_INFO_EXAM_DATE = "exam_date";
export const PAT_MAIN_COL_INFECT_INFO_UP_DATE = "up_date";
// implant_info
export const PAT_MAIN_COL_IMPLANT_INFO_CTL_NO = "ctl_no";
export const PAT_MAIN_COL_IMPLANT_INFO_DISP_ORDER = "disp_order";
export const PAT_MAIN_COL_IMPLANT_INFO_IMPLANT_CD = "implant_cd";
export const PAT_MAIN_COL_IMPLANT_INFO_START_DATE = "start_date";
// tare_info
export const PAT_MAIN_COL_TARE_INFO_1 = "1";
export const PAT_MAIN_COL_TARE_INFO_2 = "2";
export const PAT_MAIN_COL_TARE_INFO_3 = "3";
export const PAT_MAIN_COL_TARE_INFO_4 = "4";
export const PAT_MAIN_COL_TARE_INFO_5 = "5";
export const PAT_MAIN_COL_TARE_INFO_6 = "6";
export const PAT_MAIN_COL_TARE_INFO_7 = "7";
// off_water_info
export const PAT_MAIN_COL_OFF_WATER_INFO_1 = "1";
export const PAT_MAIN_COL_OFF_WATER_INFO_2 = "2";
export const PAT_MAIN_COL_OFF_WATER_INFO_3 = "3";
export const PAT_MAIN_COL_OFF_WATER_INFO_4 = "4";
export const PAT_MAIN_COL_OFF_WATER_INFO_5 = "5";
export const PAT_MAIN_COL_OFF_WATER_INFO_6 = "6";
export const PAT_MAIN_COL_OFF_WATER_INFO_7 = "7";
// device_set_info
export const PAT_MAIN_COL_DEVICE_SET_INFO = "";
// acceptance_status_info
export const PAT_MAIN_COL_ACCEPTANCE_STATUS_INFO = "";
// is_del
export const PAT_MAIN_COL_IS_DEL = "is_del";
// up_date
export const PAT_MAIN_COL_UP_DATE = "up_date";
// reg_date
export const PAT_MAIN_COL_REG_DATE = "reg_date";
// medical_care_info
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_MAIN_COURSE_CD = "main_course_cd";
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_DIALYSIS_COURSE_CD =
  "dialysis_course_cd";
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_WARD_CD = "ward_cd";
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_DIALYSIS_COUNT = "dialysis_count";
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_PURIFICATION_COUNT =
  "purification_count";
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_OTHER_DIALYSIS_COUNT =
  "other_dialysis_count";
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_FACILITY_CD = "facility_cd";
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_DIALYSIS_START_DATE =
  "dialysis_start_date";
export const PAT_MAIN_COL_MEDICAL_CARE_INFO_HOSPITAL_START_DATE =
  "hospital_start_date";

/* pat_unique 定数*/
// pat_id
export const PAT_UNIQUE_COL_PAT_ID = "pat_id";
// medical_hst_info
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_CTL_NO = "ctl_no";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_DISP_ORDER = "disp_order";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_IS_PRIMARY_ILLNESS =
  "is_primary_illness";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_IS_MAIN_DISEASE =
  "is_main_disease";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_IS_NOTICE = "is_notice";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_DISEASE_DATE = "disease_date";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_DISEASE_CD = "disease_cd";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_OUT_COME = "out_come";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_OUT_COME_DATE = "out_come_date";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_DIAGNOSTICIAN_CD =
  "diagnostician_cd";
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_MEMO = "memo";
// medical_hst_info_options
export const PAT_UNIQUE_COL_MEDICAL_HST_INFO_OPTIONS = [
  { value: "1", displayValue: "治療中" },
  { value: "2", displayValue: "診断のみ" },
  { value: "3", displayValue: "治癒" },
  { value: "4", displayValue: "軽快" },
  { value: "5", displayValue: "寛解" },
  { value: "6", displayValue: "不変" },
  { value: "7", displayValue: "増悪" },
  { value: "8", displayValue: "中止" },
  { value: "9", displayValue: "転医" },
  { value: "10", displayValue: "死亡" }
];
// in_out_visit_history_info
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_CTL_NO = "ctl_no";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_DISP_ORDER = "disp_order";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_MOVE_IN_OUT =
  "move_in_out";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_PERIOD_START =
  "period_start";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_PERIOD_END = "period_end";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_IN_OUT = "in_out";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_REASON = "reason";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_FROM_FACILITY =
  "from_facility";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_FROM_COURSE =
  "from_course";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_FROM_DOCTOR =
  "from_doctor";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_TO_FACILITY =
  "to_facility";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_TO_COURSE = "to_course";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_TO_DOCTOR = "to_doctor";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_IS_REPLY = "is_reply";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_COMMENT = "comment";
// in_out_visit_history_info_options
// 導入 区分値
const MOVE_IN_OUT_CLASS_INTRODUCTION = "1";
// 転入
const MOVE_IN_OUT_CLASS_MOVE_IN = "2";
// 転出
const MOVE_IN_OUT_CLASS_MOVING_OUT = "3";
// 入院
const MOVE_IN_OUT_CLASS_HOSPITALIZATION = "4";
// 退院
const MOVE_IN_OUT_CLASS_DISCHARGE = "5";
// 外来
const MOVE_IN_OUT_CLASS_OUTPATIENT = "6";
// 離脱
const MOVE_IN_OUT_CLASS_WITHDRAWAL = "7";
// 移植
const MOVE_IN_OUT_CLASS_IMPLANTATION = "8";
// 一時転出
const MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT = "9";
// 通院拒否・不明
const MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN = "10";
// 死亡
const MOVE_IN_OUT_CLASS_DEATH = "11";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_MOVE_IN_OUT_CLASS = [
  {
    value: MOVE_IN_OUT_CLASS_INTRODUCTION,
    displayValue: "導入"
  },
  {
    value: MOVE_IN_OUT_CLASS_MOVE_IN,
    displayValue: "転入"
  },
  {
    value: MOVE_IN_OUT_CLASS_MOVING_OUT,
    displayValue: "転出"
  },
  {
    value: MOVE_IN_OUT_CLASS_HOSPITALIZATION,
    displayValue: "入院"
  },
  {
    value: MOVE_IN_OUT_CLASS_DISCHARGE,
    displayValue: "退院"
  },
  {
    value: MOVE_IN_OUT_CLASS_OUTPATIENT,
    displayValue: "外来"
  },
  {
    value: MOVE_IN_OUT_CLASS_WITHDRAWAL,
    displayValue: "離脱"
  },
  {
    value: MOVE_IN_OUT_CLASS_IMPLANTATION,
    displayValue: "移植"
  },
  {
    value: MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT,
    displayValue: "一時転出"
  },
  {
    value: MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN,
    displayValue: "通院拒否・不明"
  },
  {
    value: MOVE_IN_OUT_CLASS_DEATH,
    displayValue: "死亡"
  }
];
// 在院
const MOVE_IN_OUT_DB_HOSPITALIZATION = "0";
// 導入予定
const MOVE_IN_OUT_DB_INTRODUCTION_PLAN = "1";
// 転入予定
const MOVE_IN_OUT_DB_MOVE_IN_PLAN = "2";
// 転出
const MOVE_IN_OUT_DB_MOVING_OUT = "3";
// 離脱
const MOVE_IN_OUT_DB_WITHDRAWAL = "7";
// 移植
const MOVE_IN_OUT_DB_IMPLANTATION = "8";
// 一時転出
const MOVE_IN_OUT_DB_TEMPORARILY_MOVING_OUT = "9";
// 不明
const MOVE_IN_OUT_DB_UNKNOWN = "10";
// 死亡
const MOVE_IN_OUT_DB_DEATH = "11";
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_MOVE_IN_OUT_DB = [
  {
    value: MOVE_IN_OUT_DB_HOSPITALIZATION,
    displayValue: "在院"
  },
  {
    value: MOVE_IN_OUT_DB_INTRODUCTION_PLAN,
    displayValue: "導入予定"
  },
  {
    value: MOVE_IN_OUT_DB_MOVE_IN_PLAN,
    displayValue: "転入予定"
  },
  {
    value: MOVE_IN_OUT_DB_MOVING_OUT,
    displayValue: "転出"
  },
  {
    value: MOVE_IN_OUT_DB_WITHDRAWAL,
    displayValue: "離脱"
  },
  {
    value: MOVE_IN_OUT_DB_IMPLANTATION,
    displayValue: "移植"
  },
  {
    value: MOVE_IN_OUT_DB_TEMPORARILY_MOVING_OUT,
    displayValue: "一時転出"
  },
  {
    value: MOVE_IN_OUT_DB_UNKNOWN,
    displayValue: "不明"
  },
  {
    value: MOVE_IN_OUT_DB_DEATH,
    displayValue: "死亡"
  }
];
// 外来 入外値
const IN_OUT_CLASS_OUTPATIENT = 0;
// 入院
const IN_OUT_CLASS_HOSPITALIZATION = 1;
// 死亡
const IN_OUT_CLASS_DEATH = 2;
// － (不在)
const IN_OUT_CLASS_ABSRENCE = 3;
export const PAT_UNIQUE_COL_IN_OUT_VISIT_HISTORY_INFO_IN_OUT_CLASS = [
  {
    value: IN_OUT_CLASS_OUTPATIENT,
    displayValue: "外来"
  },
  {
    value: IN_OUT_CLASS_HOSPITALIZATION,
    displayValue: "入院"
  },
  {
    value: IN_OUT_CLASS_DEATH,
    displayValue: "死亡"
  },
  {
    value: IN_OUT_CLASS_ABSRENCE,
    displayValue: "－"
  },
];
// physical_info
export const PAT_UNIQUE_COL_PHYSICAL_INFO_CTL_NO = "ctl_no";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_EXAM_DATE = "exam_date";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_ORDER_CLAS = "order_clas";
// TODO: 一時的に保留:value値精査中
// 透析前
const ORDER_CLASS_BEFORE_DIALYSIS = 1;
// 透析後
const ORDER_CLASS_AFTER_DIALYSIS = 2;
// その他
const ORDER_CLASS_OTHER = 3;
export const PAT_UNIQUE_COL_PHYSICAL_INFO_ORDER_CLASS = [
  {
    value: ORDER_CLASS_BEFORE_DIALYSIS,
    displayValue: "透析前"
  },
  {
    value: ORDER_CLASS_AFTER_DIALYSIS,
    displayValue: "透析後"
  },
  {
    value: ORDER_CLASS_OTHER,
    displayValue: "その他"
  }
];
export const PAT_UNIQUE_COL_PHYSICAL_INFO_HEIGHT = "height";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_CTR_WEIGHT = "ctr_weight";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_BREAST_DIA = "breast_dia";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_CHEST_DIA = "chest_dia";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_CTR = "ctr";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_DW = "dw";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_TARGET_WEIGHT = "target_weight";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_INDICATOR_CD = "indicator_cd";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_MEMO = "memo";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_PRE_SCALE_UPPER = "pre_scale_upper";
export const PAT_UNIQUE_COL_PHYSICAL_INFO_PRE_SCALE_LOWER = "pre_scale_lower";
// is_del
export const PAT_UNIQUE_COL_IS_DEL = "is_del";
// up_date
export const PAT_UNIQUE_COL_UP_DATE = "up_date";
// reg_date
export const PAT_UNIQUE_COL_REG_DATE = "reg_date";
