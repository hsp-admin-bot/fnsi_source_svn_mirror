package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatTreatmentPatternMstKur {

  @Id
  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  @Id
  /**
   * 管理番号
   */
  private Long ctlNo;

  /**
   * 治療曜日
   */
  private Short treatWeek;

  /**
   * 適用開始日
   */
  private String indTreatStartTime;

  /**
   * クール内標準治療開始時刻
   */
  private String kurStandardStartTime;

  private Integer duration;

  private Integer ptpKurCd;

  private Integer mkKurCd;

  /**
   * クール開始時刻
   */
  private String kurStartTime;

  /**
   * クール終了時刻
   */
  private String kurEndTime;

}
