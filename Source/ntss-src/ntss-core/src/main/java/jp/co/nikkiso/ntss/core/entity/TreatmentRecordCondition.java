package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;
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

/**
 * 治療情報のEntity（治療条件用）.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class TreatmentRecordCondition extends BaseEntity {

  /**
   * システムで管理する一意なオーダ番号.
   */
  @Id
  @JsonIgnore
  private Long ordNo;

  /**
   * 指示：治療開始時刻.
   * 2020/01/30 MOR.FUJINO 必要のない定義であるが、テスト処理等の影響を考慮して残しています
   */
  private String indTreatStartTime;

  /**
   * 実績：治療条件情報.
   */
  private String rstCondInfo;

  /**
   * 実績：DW.
   */
  private BigDecimal rstDw;

  //add FNSI修正 結合バッグ20 房 start
  /**
   * 実績：治療方法コード
   */
  private Integer rstTreatmentCd;

  /**
   * 実績：治療方法名
   */
  private String rstTreatmentName;
  //add FNSI修正 結合バッグ20 房 end

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

  //add FNSI修正 OHDF修正 房 start
  /* del by chamaojia 2025-02-28 [11471] need to map database query results --start */
//  @Transient
  /* del by chamaojia 2025-02-28 [11471] need to map database query results --end */
  private int deviceMode;
  //add FNSI修正 OHDF修正 房 end
}
