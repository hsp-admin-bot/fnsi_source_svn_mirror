package jp.co.nikkiso.ntss.admin_web.response.checkList.dto;

import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

/**
 * 投与薬剤指示のJSON格納クラス.
 */
@Data
public class IndMediInfoDto {

  /**
   * 識別番号.
   */
  @JsonProperty("no")
  private Integer no;
  /**
   * 薬剤分類コード
   */
  @JsonProperty("class_cd")
  private Integer classCd;
  /**
   * 薬剤分類名
   */
  @JsonProperty("class_name")
  private String className;

  /**
   * 分類区分
   */
  @JsonProperty("class_type")
  private BigDecimal classType;
  /**
   * 薬剤区分
   */
  @JsonProperty("medicine_type")
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String medicineType;
  private Integer medicineType;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  /**
   * 薬剤(調整薬剤)コード
   */
  @JsonProperty("cd")
  private Integer cd;
  /**
   * 薬剤名
   */
  @JsonProperty("name")
  private String name;
  /**
   * 省略薬剤名
   */
  @JsonProperty("short_name")
  private String shortName;
  /**
   * 単位
   */
  @JsonProperty("unit")
  private String unit;
  /**
   * 数量
   */
  @JsonProperty("amount")
  private String amount;
  /**
   * 初回投与日
   */
  @JsonProperty("init_date")
  private String initDate;
  /**
   * 投与間隔
   */
  @JsonProperty("date_interval")
  private Integer dateInterval;
  /**
   * 投与タイミングコード
   */
  @JsonProperty("timing_cd")
  private Integer timingCd;
  /**
   * 投与タイミング名
   */
  @JsonProperty("timing_name")
  private String timingName;
  /**
   * 手技コード
   */
  @JsonProperty("procedure_cd")
  private Integer procedureCd;
  /**
   * 手技名
   */
  @JsonProperty("procedure_name")
  private String procedureName;
  /**
   * コメント
   */
  @JsonProperty("comment")
  private String comment;
  /**
   * 指示者コード(利用者マスタ.利用者ID)
   */
  @JsonProperty("ind_user_id")
  private Long indUserId;
  /**
   * 指示者名_姓(利用者マスタ.利用者名_姓)
   */
  @JsonProperty("ind_user_last_name")
  private String indUserLastName;
  /**
   * 指示者名_名(利用者マスタ.利用者名_名)
   */
  @JsonProperty("ind_user_first_name")
  private String indUserFirstName;
  /**
   * 更新者コード(利用者マスタ.利用者ID)
   */
  @JsonProperty("upd_user_id")
  private Long updUserId;
  /**
   * 更新者名_姓(利用者マスタ.利用者名_姓)
   */
  @JsonProperty("upd_user_last_name")
  private String updUserLastName;
  /**
   * 更新者名_名(利用者マスタ.利用者名_名)
   */
  @JsonProperty("upd_user_first_name")
  private String updUserFirstName;
  /**
   * 登録区分
   */
  @JsonProperty("input_class")
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String inputClass;
  private Integer inputClass;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
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
}
