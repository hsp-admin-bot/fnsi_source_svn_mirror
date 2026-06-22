package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import jakarta.validation.constraints.NotEmpty;

/**
 * 治療情報のEntity（指示コメント用）.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class TreatmentRecordAddition extends BaseEntity {

  /**
   * システムで管理する一意なオーダ番号.
   */
  @Id
  @JsonIgnore
  private Long ordNo;

  /**
   * システムで管理する一意な患者ID.
   */
  private Long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 治療日.
   */
  private String treatDate;

  /**
   * 実績：クールコード.
   */
  private Long rstKurCd;

  /**
   * 実績：治療方法コード.
   */
  private Long rstTreatmentCd;

  /**
   * 実績：指示コメント.
   */
  @NotEmpty
  private String rstIndCommentInfo;

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

  /**
   * 指示：クールコード.
   */
  private Long indKurCd;

  /**
   * 指示:治療方法コード.
   */
  private Long indTreatmentCd;
}
