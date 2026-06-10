package jp.co.nikkiso.ntss.admin_web.response.checkList.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * 医療材料のJSON格納クラス.
 */
@Data
public class ReceiveRstEquipInfoDto {
  /**
   * 医療材料識別番号
   */
  @JsonProperty("no")
  private Long no;

  /**
   * 医療材料分類コード.
   */
  @JsonProperty("class_cd")
  private Integer classCd;
  /**
   * 医療材料分類名
   */
  @JsonProperty("class_name")
  private String className;
  /**
   * 分類区分
   */
  @JsonProperty("class_type")
  private Integer classType;

  /**
   * 医療材料コード,
   */
  @JsonProperty("cd")
  private Integer cd;
  /**
   * 医療材料名
   */
  @JsonProperty("name")
  private String name;
  /**
   * 省略医療材料名
   */
  @JsonProperty("short_name")
  private String shortName;
  // del 10310 needle _ typeの使用を削除するには gjn start
  /**
   * 穿刺針区分
   */
//  @JsonProperty("needle_type")
//  private Short needleType;
  // del 10310 needle _ typeの使用を削除するには gjn end
  /**
   * 数量
   */
  @JsonProperty("amount")
  private String amount;
  /**
   * 単位
   */
  @JsonProperty("unit")
  private String unit;
  /**
   * 指示者コード
   */
  @JsonProperty("ind_user_id")
  private Integer indUserId;
  /**
   * 指示者名_姓
   */
  @JsonProperty("ind_user_last_name")
  private String indUserLastName;
  /**
   * 指示者名_名
   */
  @JsonProperty("ind_user_first_name")
  private String indUserFirstName;
  /**
   * 更新者コード
   */
  @JsonProperty("upd_user_id")
  private Long updUserId;
  /**
   * 更新者名_姓
   */
  @JsonProperty("upd_user_last_name")
  private String updUserLastName;
  /**
   * 更新者名_名
   */
  @JsonProperty("upd_user_first_name")
  private String updUserFirstName;
  /**
   * 登録区分
   */
  @JsonProperty("input_class")
  private Integer inputClass;
  /**
   * 編集可否フラグ
   */
  @JsonProperty("is_editable")
  private String isEditable;
  /**
   * 連携オーダ番号
   */
  @JsonProperty("cop_order_no")
  private String copOrderNo;
  /**
   * 医療材料区分
   */
  @JsonProperty("equip_type")
  private Integer equipType;
}
