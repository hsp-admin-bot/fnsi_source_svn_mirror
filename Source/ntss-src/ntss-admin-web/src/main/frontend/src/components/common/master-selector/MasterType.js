import antiCoagulantBuilder from "@/components/common/master-selector/builder/antiCoagulantBuilder";
/*import vaBuilder from "@/components/common/master-selector/builder/vaBuilder";

import { CODES } from "@/constants/TreatmentRecord";*/

// 指示画面
export const ANTICOAGULANT_INDICATION = "anticoagulant_indication";

// 治療記録_治療条件
export const VA_TREATMENT_RECORD = "va_treatment_record";
export const DIALYZER_TREATMENT_RECORD = "dialyzer_treatment_record";
export const ADSORPTIONCOLUMN_TREATMENT_RECORD = "adsorptionColumn_treatment_record";
export const PRIMARYFILM_TREATMENT_RECORD = "primaryFilm_treatment_record";
export const SECONDARYFILM_TREATMENT_RECORD = "secondaryFilm_treatment_record";
export const PUNCTURENEEDLEA_TREATMENT_RECORD = "punctureNeedleA_treatment_record";
export const PUNCTURENEEDLEV_TREATMENT_RECORD = "punctureNeedleV_treatment_record";
export const PUNCTURENEEDLESN_TREATMENT_RECORD = "punctureNeedleSn_treatment_record";
export const BLOODCIRCUIT_TREATMENT_RECORD = "bloodCircuit_treatment_record";
export const DIALYSATE_TREATMENT_RECORD = "dialysate_treatment_record";
export const REPLACEMENT_TREATMENT_RECORD = "replacement_treatment_record";

// 医療材料
export const EQUIPMENT_TREATMENT_RECORD = "equipment_treatment_record";
// 医療材料セット（IndEquipmentSet 用）
export const EQUIPMENT_SET_RECORD = "equipment_set_record";

export const MEDICATION_TREATMENT_RECORD = "medication_treatment_record";

export const EQUIPMENT_TREATMENT_CLASSTYPE_RECORD = "equipment_treatment_classtype_record";

export const MEDICATION_TREATMENT_CLASSTYPE_RECORD = "medication_treatment_classtype_record";

/** 治療記録実績：穿刺者／返血者／担当者などの利用者選択 */
export const PERSONAL_USER_TREATMENT_RECORD = "personal_user_treatment_record";

/** チェックリスト／投与薬剤：実施者（利用者）選択 */
export const PRACTITIONER_CHECK_LIST = "practitioner_check_list";

/** 投与薬剤セット：薬剤セット選択（IndMedicineSet 用） */
export const MEDICINE_SET_INDICATION_RECORD = "medicine_set_indication_record";

/** 治療記録：愁訴選択（旧・自研テーブル popover のデータを compose 化） */
export const COMPLAINT_TREATMENT_RECORD = "complaint_treatment_record";

/** 治療記録：処置選択（旧・自研テーブル popover のデータを compose 化） */
export const COMP_TREATMENT_RECORD = "comp_treatment_record";

/** 治療記録：手技選択 */
export const PROCEDURE_TREATMENT_RECORD = "procedure_treatment_record";

/** 治療記録：体重入力popup 車いす選択 */
export const WHEEL_CHAIR_TREATMENT_RECORD = "wheel_chair_treatment_record";

/** 車いすマスタ詳細：所有患者選択 */
export const WHEEL_CHAIR_OWNER_PATIENT_MASTER = "wheel_chair_owner_patient_master";

/** 患者情報：重症度選択 */
export const SEVERITY_PAT_INFO = "severity_pat_info";

/** 患者情報：搬送区分選択 */
export const TRANSPORT_PAT_INFO = "transport_pat_info";

/** 患者情報：車いす選択（共用のみ） */
export const WHEEL_CHAIR_PAT_INFO = "wheel_chair_pat_info";

/** 患者情報：施設選択 */
export const FACILITY_PAT_INFO = "facility_pat_info";

/** 患者情報：診療科選択 */
export const COURSE_PAT_INFO = "course_pat_info";

/** 患者情報：医師（利用者）選択 */
export const DOCTOR_PAT_INFO = "doctor_pat_info";

/** 患者情報：担当者（利用者）選択 */
export const STAFF_PAT_INFO = "staff_pat_info";

/** 患者情報：インプラント選択 */
export const IMPLANT_PAT_INFO = "implant_pat_info";

/** 患者情報：続柄選択 */
export const RELATIONSHIP_PAT_INFO = "relationship_pat_info";

/** 患者情報：国籍（sys_country） */
export const NATIONALITY_PAT_INFO = "nationality_pat_info";

/** 患者情報：透析実施科（mst_course、診療科と同一クエリ・表示ラベルのみ差分） */
export const DIALYSIS_COURSE_PAT_INFO = "dialysis_course_pat_info";

/** 患者情報：病棟 */
export const WARD_PAT_INFO = "ward_pat_info";

/** 患者情報：禁忌・アレルギーマスタ選択 */
export const TABOO_ALLERGY_PAT_INFO = "taboo_allergy_pat_info";

/** 患者情報：既往歴・病名 */
export const DISEASE_PAT_INFO = "disease_pat_info";

/** 患者情報：保険マスタ（保険詳細モーダル） */
export const INSURANCE_PAT_INFO = "insurance_pat_info";

/** 患者情報：連絡先 ID（施設内患者） */
export const OTHER_CONTACT_PAT_PAT_INFO = "other_contact_pat_pat_info";

/** 患者情報：加算・管理料 */
export const ADDITION_PAT_INFO = "addition_pat_info";

/** 患者詳細検索：利用者選択 */
export const STAFF_INFO = "staff_info";

/** 指示：指示有効な医療材料選択 */
export const VALID_IND_EQUIPMENT = "valid_ind_equipment";

export const MASTER = {
  [ANTICOAGULANT_INDICATION]: {
    builder: antiCoagulantBuilder,
    treatItemCd: "25"
  },
  [VA_TREATMENT_RECORD]: {},
  [DIALYZER_TREATMENT_RECORD]: {},
  [EQUIPMENT_TREATMENT_RECORD]: {},
  [EQUIPMENT_SET_RECORD]: {},
  [MEDICATION_TREATMENT_RECORD]: {},
  [EQUIPMENT_TREATMENT_CLASSTYPE_RECORD]: {},
  [MEDICATION_TREATMENT_CLASSTYPE_RECORD]: {},
  [PERSONAL_USER_TREATMENT_RECORD]: {},
  [PRACTITIONER_CHECK_LIST]: {},
  [MEDICINE_SET_INDICATION_RECORD]: {},
  [COMPLAINT_TREATMENT_RECORD]: {},
  [COMP_TREATMENT_RECORD]: {},
  [PROCEDURE_TREATMENT_RECORD]: {},
  [WHEEL_CHAIR_TREATMENT_RECORD]: {},
  [WHEEL_CHAIR_OWNER_PATIENT_MASTER]: {},
  [SEVERITY_PAT_INFO]: {},
  [TRANSPORT_PAT_INFO]: {},
  [WHEEL_CHAIR_PAT_INFO]: {},
  [FACILITY_PAT_INFO]: {},
  [COURSE_PAT_INFO]: {},
  [DOCTOR_PAT_INFO]: {},
  [STAFF_PAT_INFO]: {},
  [STAFF_INFO]: {},
  [IMPLANT_PAT_INFO]: {},
  [RELATIONSHIP_PAT_INFO]: {},
  [NATIONALITY_PAT_INFO]: {},
  [DIALYSIS_COURSE_PAT_INFO]: {},
  [WARD_PAT_INFO]: {},
  [TABOO_ALLERGY_PAT_INFO]: {},
  [DISEASE_PAT_INFO]: {},
  [INSURANCE_PAT_INFO]: {},
  [OTHER_CONTACT_PAT_PAT_INFO]: {},
  [ADDITION_PAT_INFO]: {},
  [VALID_IND_EQUIPMENT]: {},
  /*[VA_TREATMENT_RECORD]: {
    builder: vaBuilder
  },
  [DIALYZER_TREATMENT_RECORD]: {
    builder: dialyzerBuilder
  },
  [ADSORPTIONCOLUMN_TREATMENT_RECORD]: {
    builder: equipmentBaseBuilder({
      classTypes: [CODES.EQUIPMENT_CLASS.ADSORPTION_COLUMN.classType]
    })
  },
  [PRIMARYFILM_TREATMENT_RECORD]: {
    builder: equipmentBaseBuilder({
      classTypes: [
        CODES.EQUIPMENT_CLASS.ADSORBER.classType,
        CODES.EQUIPMENT_CLASS.SEPARATOR.classType
      ]
    })
  },
  [SECONDARYFILM_TREATMENT_RECORD]: {
    builder: equipmentBaseBuilder({
      classTypes: [
        CODES.EQUIPMENT_CLASS.ADSORBER.classType,
        CODES.EQUIPMENT_CLASS.SEPARATOR.classType
      ]
    })
  },
  [PUNCTURENEEDLEA_TREATMENT_RECORD]: {
    builder: equipmentBaseBuilder({
      classTypes: [CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType]
    })
  },
  [PUNCTURENEEDLEV_TREATMENT_RECORD]: {
    builder: equipmentBaseBuilder({
      classTypes: [CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType]
    })
  },
  [PUNCTURENEEDLESN_TREATMENT_RECORD]: {
    builder: equipmentBaseBuilder({
      classTypes: [CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE_SN.classType]
    })
  },
  [BLOODCIRCUIT_TREATMENT_RECORD]: {
    builder: equipmentBaseBuilder({
      classTypes: [CODES.EQUIPMENT_CLASS.BLOOD_CIRCUIT.classType]
    })
  },
  [REPLACEMENT_TREATMENT_RECORD]: {
    builder: medicineBaseBuilder({
      classTypes: [
        CODES.MEDICINE_CLASS.REPLACEMENT.classType, CODES.MEDICINE_CLASS.DIALYSATE.classType]
    })
  },
  [DIALYSATE_TREATMENT_RECORD]: {
    builder: medicineBaseBuilder({
      classTypes: [CODES.MEDICINE_CLASS.DIALYSATE.classType]
    })
  },
  [EQUIPMENT_TREATMENT_RECORD]: {
    builder: equipmentBuilder({
    })
  }*/

};
