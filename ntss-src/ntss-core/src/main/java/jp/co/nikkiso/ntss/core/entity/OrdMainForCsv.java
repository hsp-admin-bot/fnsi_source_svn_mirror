package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForCsv {

  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * クール名
   */
  private String kurName;

  /**
   * ベッド名
   */
  private String bedName;

  /**
   * 指示：治療開始時刻
   */
  private String indTreatStartTimeBefore;

  /**
   * 指示：治療開始時刻
   */
  private String indTreatStartTimeAfter;

}
