package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatTreatmentPatternExtends extends PatTreatmentPattern {

  /**
   * 指示：治療開始時刻
   */
  private String indTreatStartTime;

  private Integer duration;

  /**
   * クール内標準治療開始時刻
   */
  private String kurStandardStartTime;

  /**
   * クール開始時刻
   */
  private String kurStartTime;
  /**
   * クール終了時刻
   */
  private String kurEndTime;

  /**
   * クールコード
   */
  private Integer kurCd;

  /**
   * 指示：ベッドコード
   */
  private Integer indBedCd;
}
