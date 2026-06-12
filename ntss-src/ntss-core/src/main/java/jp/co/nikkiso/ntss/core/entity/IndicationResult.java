package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
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
 * 予実リスト情報のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class IndicationResult extends BaseEntity {

  /**
   * 予実：予定.
   */
  public static final Integer IND_RST_TYPE_INDICATION = 1;

  /**
   * 予実：実績.
   */
  public static final Integer IND_RST_TYPE_RESULT = 2;

  /**
   * オーダ番号.
   */
  private Long ordNo;

  /**
   * カテゴリ.
   */
  private String category;

  /**
   * 予実（1:予定、2:実績）.
   */
  private Integer indRstType;

  /**
   * 治療日(YYYYMMDD形式).
   */
  private String treatmentDate;

  /**
   * 治療方法コード.
   */
  private Integer treatmentCd;

  /**
   * 治療方法名.
   */
  private String treatmentName;

  /**
   * クールコード.
   */
  private Long kurCd;

  /**
   * クール名.
   */
  private String kurName;

  /**
   * クール開始時刻.
   */
  private String kurStartTime;

  /**
   * 治療開始日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp startDate;

  /**
   * 治療終了日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp endDate;

  /**
   * ベッドコード.
   */
  private Long bedCd;

  /**
   * ベッド名.
   */
  private String bedName;

  /**
   * ベッド名.
   */
  private String bedNameMst;

  /**
   * クール名.
   */
  private String kurNameMst;

  /**
   * 治療方法名.
   */
  private String treatmentNameMst;

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getUpDate() {
    return super.getUpDate();
  }

}
