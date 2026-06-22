package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/**
 * 治療情報のEntity（治療条件用）.
 */
@Data
@EqualsAndHashCode(callSuper = false)
public class TreatmentRecordConditionSubInfo extends BaseEntity {

  @JsonProperty("value")
  private BigDecimal value;

  @JsonProperty("value_name_1")
  private String valueName1;

  @JsonProperty("value_name_2")
  private String valueName2;

  @JsonProperty("value_name_3")
  private String valueName3;

  @JsonProperty("value_name_4")
  private String valueName4;

  @JsonProperty("value_name_5")
  private String valueName5;

  @JsonProperty("value_name_6")
  private String valueName6;

  @JsonProperty("value_name_7")
  private String valueName7;

  @JsonProperty("value_name_8")
  private String valueName8;

  @JsonProperty("value_name_9")
  private String valueName9;

  @JsonProperty("value_name_10")
  private String valueName10;

  @JsonProperty("unit")
  private String unit;

  @JsonProperty("medicine_type")
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private Short medicineType;
  private Integer medicineType;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

  @JsonProperty("ind_user_id")
  private Long indUserId;

  @JsonProperty("ind_user_last_name")
  private String indUserLastName;

  @JsonProperty("ind_user_first_name")
  private String indUserFirstName;

  @JsonProperty("upd_user_id")
  private Long updUserId;

  @JsonProperty("upd_user_last_name")
  private String updUserLastName;

  @JsonProperty("upd_user_first_name")
  private String updUserFirstName;

  @JsonProperty("input_class")
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private Long inputClass;
  private Integer inputClass;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

  @JsonProperty("is_editable")
  private String isEditable;

  @JsonProperty("cop_order_no")
  private String copOrderNo;

  // add #9973 mst_treatment_setへの不正処理修正 dou start
  // 古いデータと互換性がある
  @JsonProperty("decPoint")
  private String decPoint;
  // add #9973 mst_treatment_setへの不正処理修正 dou end
}
