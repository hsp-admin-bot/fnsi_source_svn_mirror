package batch.entity;

import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonRawValue;

import tools.jackson.databind.JsonNode;
import org.seasar.doma.Table;

import lombok.Getter;
import lombok.Setter;

/**
 * 体重測定履歴クラス
 */
@Table(name = "ord_weight_scale")
@Getter
@Setter
public class OrdWeightScale  {

  /**
   * オーダー番号
   */
  @JsonProperty("ord_no")
  private String ordNo;
  /**
   * 施設コード
   */
  @JsonProperty("facility_cd")
  private String facilityCd;
  /**
   * 体重計管理コード
   */
  @JsonProperty("weight_cd")
  private String weightCd;
  /**
   * 体重計名称
   */
  @JsonProperty("weight_name")
  private String weightName;
  /**
   * 装置番号
   */
  @JsonProperty("machine_no")
  private String machineNo;
  /**
   * 装置名
   */
  @JsonProperty("machine_name")
  private String machineName;

  /**
   * 体重測定状況
   */
  @JsonProperty("weight_scale_status")
  private Short weightScaleStatus;


  /**
   * 測定日時
   */
  @JsonProperty("measure_date")
  @JsonFormat(pattern = "yyyy/MM/dd HH:mm:ss")
  private String measureDate;
  /**
   * クール
   */
  @JsonProperty("kur_cd")
  private String kurCd;
  /**
   * クール名称
   */
  @JsonProperty("kur_name")
  private String kurName;
  /**
   * ベッドコード
   */
  @JsonProperty("bed_cd")
  private String bedCd;
  /**
   * ベッド名称
   */
  @JsonProperty("bed_name")
  private String bedName;
  /**
   * 患者ID
   */
  @JsonProperty("pat_id")
  private String patId;
  /**
   * 測定区分
   */
  @JsonProperty("scale_class")
  private Short scaleClass;
  /**
   * 測定モード
   */
  @JsonProperty("scale_mode")
  private Short scaleMode;
  /**
   * 測定値
   */
  @JsonProperty("scale_value")
  private BigDecimal scaleValue;
  /**
   * 車いす以外の風袋
   */
  @JsonProperty("rst_tare_info")
  @JsonRawValue
  private JsonNode rstTareInfo;
  /**
   * 除水補正値
   */
  @JsonProperty("rst_off_water_info")
  private JsonNode rstOffWaterInfo;
  /**
   * 体重値
   */
  @JsonProperty("weight_value")
  private BigDecimal weightValue;
  /**
   * 目標体重
   */
  @JsonProperty("target_weight_value")
  private BigDecimal targetWeightValue;
  /**
   * 除水制限値
   */
  @JsonProperty("off_water_limit")
  private BigDecimal offWaterLimit;
  /**
   * 車いすコード
   */
  @JsonProperty("wheel_chair_cd")
  private String wheelChairCd;
  /**
   * 車いす名称
   */
  @JsonProperty("wheel_chair_name")
  private String wheelChairName;
  /**
   * 車いす重量
   */
  @JsonProperty("wheel_chair_weight")
  private BigDecimal wheelChairWeight;
  /**
   * 担当スタッフID
   */
  @JsonProperty("user_id")
  private String userId;
  /**
   * 治療コード
   */
  @JsonProperty("treatment_cd")
  private String treatmentCd;
  /**
   * 治療名
   */
  @JsonProperty("treatment_name")
  private String treatmentName;
  /**
   * 装置モード
   */
  @JsonProperty("device_mode")
  private String deviceMode;

  /**
   * 登録日時.
   */
  @JsonProperty("reg_date")
  @JsonFormat(pattern = "yyyy/MM/dd HH:mm:ss")
  private String regDate;

  /**
   * 更新日時.
   */
  @JsonProperty("up_date")
  @JsonFormat(pattern = "yyyy/MM/dd HH:mm:ss")
  private String upDate;


}
