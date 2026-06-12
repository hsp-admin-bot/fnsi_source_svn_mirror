package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * 治療情報のEntity（体重用）.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class TreatmentRecordWeight extends BaseEntity {

  /**
   * システムで管理する一意なオーダ番号.
   */
  @Id
  @JsonIgnore
  private Long ordNo;

  /**
   * 前回体重（前回透析日の後体重：rst_weight_info の weight_after 単位 kg）.
   */
  private BigDecimal lastWeight;

  /**
   * 実績：DW.
   */
  private BigDecimal rstDw;

  /**
   * 目標体重（`rst_cond_info`の治療条件項目番号 = 3 単位 kg）.
   */
  private BigDecimal targetWeight;

  /**
   * 除水量制限（rst_cond_info`の治療条件項目番号 = 4 単位 L）.
   */
  private BigDecimal waterRemovalAmountLimit;

  /**
   * 実績：体重情報.
   */
  private String rstWeightInfo;

  /**
   * 実績：風袋補正.
   */
  private String rstTareInfo;

  /**
   * 実績：除水補正.
   */
  private String rstOffWaterInfo;

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public Timestamp getUpDate() {
    return super.getUpDate();
  }

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public void setUpDate(Timestamp value) {
    super.setUpDate(value);
  }

  // add FNSI-redmine6122 fang start
  private Long upUserId;
  // add FNSI-redmine6122 fang end
  
  /**
   * 実績：治療状況.
   */
  private String rstDialysisState;
  
  /**
   * 実績：治療終了日時
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstEndDate;
}
