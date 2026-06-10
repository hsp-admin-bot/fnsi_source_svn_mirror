package jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model;

import lombok.Getter;

@Getter
public enum PatTreatmentPatternFieldEnum {

  IND_SCH_INFO("ind_sch_info"),
  IND_COND_INFO("ind_cond_info"),
  IND_MEDI_INFO("ind_medi_info"),
  IND_EQUIP_INFO("ind_equip_info"),
  IND_COMMENT_INFO("ind_ind_comment_info"),
  IND_DEVICE_SET_INFO("ind_device_set_info"),
  TREATMENT_METHOD_ONLY("treatment_method_only"),
  TREATMENT_METHOD_SET_CHANGE("treatment_method_set_change");

  private final String columnName;

  PatTreatmentPatternFieldEnum(String columnName) {
    this.columnName = columnName;
  }

}
