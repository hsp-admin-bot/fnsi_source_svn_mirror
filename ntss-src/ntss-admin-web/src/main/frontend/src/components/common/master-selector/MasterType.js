import antiCoagulantBuilder from "@/components/common/master-selector/builder/antiCoagulantBuilder";
/*import vaBuilder from "@/components/common/master-selector/builder/vaBuilder";
import dialyzerBuilder from "@/components/common/master-selector/builder/dialyzerBuilder";
import equipmentBaseBuilder from "@/components/common/master-selector/builder/equipmentBaseBuilder";
import medicineBaseBuilder from "@/components/common/master-selector/builder/medicineBaseBuilder";
import equipmentBuilder from "@/components/common/master-selector/builder/equipmentBuilder";
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

// 患者情報_既往歴
export const FACILITY_PAT_INFO = "FACILITY_PAT_INFO";

// 医療材料
export const EQUIPMENT_TREATMENT_RECORD = "equipment_treatment_record";

export const MASTER = {
  [ANTICOAGULANT_INDICATION]: {
    builder: antiCoagulantBuilder,
    treatItemCd: "25",
    popoverDirection: "right"
  },
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
