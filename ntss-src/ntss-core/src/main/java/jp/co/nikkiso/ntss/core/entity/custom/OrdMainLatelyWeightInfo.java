package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.apache.commons.lang3.StringUtils;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainLatelyWeightInfo {

  /** 治療日 */
  private String treatDate;

  /** 治療方法コード */
  private Long rstTreatmentCd;

  /** 治療日 */
  private Integer deviceMode;

  /** 治療開始日時 */
  private Timestamp rstStartDate;

  /** 治療終了日時 */
  private Timestamp rstEndDate;

  /**  */
  private Long timeDiffBefore;

  /**  */
  private Long timeDiffAfter;

  /** 前体重 */
  private String weightBefore;

  /** 後体重 */
  private String weightAfter;


  /**  */
  private Long wTimeDiffBefore;

  /**  */
  private Long wTimeDiffAfter;


  public String getWeightByOrdClass(String ordClass) {
    if (StringUtils.isNotEmpty(ordClass)) {

      switch (ordClass) {
        case "1" -> { return this.weightBefore; }
        case "2" -> { return this.weightAfter; }
        default -> { return null; }
      }
    }

    return null;
  }


  public Long getTimeDiffByClass(String ordClass) {
    if (StringUtils.isNotEmpty(ordClass)) {

      switch (ordClass) {
        case "1" -> { return this.timeDiffBefore; }
        case "2" -> { return this.timeDiffAfter; }
        default -> { return null; }
      }
    }

    return null;
  }

  public boolean getTimeDiffClassByClass(String ordClass) {
    if (StringUtils.isNotEmpty(ordClass)) {

      switch (ordClass) {
        case "1" -> { return this.timeDiffBefore != null && this.timeDiffBefore >= 0; }
        case "2" -> { return this.timeDiffAfter != null && this.timeDiffAfter <= 0; }
        default -> { return false; }
      }
    }

    return false;
  }


  public Timestamp getRstDateByClass(String ordClass) {
    if (StringUtils.isNotEmpty(ordClass)) {

      switch (ordClass) {
        case "1" -> { return this.rstStartDate; }
        case "2" -> { return this.rstEndDate; }
        default -> { return null; }
      }
    }

    return null;
  }

  public Long getWTimeDiffByClass(String ordClass) {
    if (StringUtils.isNotEmpty(ordClass)) {

      switch (ordClass) {
        case "1" -> { return this.wTimeDiffBefore; }
        case "2" -> { return this.wTimeDiffAfter; }
        default -> { return null; }
      }
    }

    return null;
  }

  public boolean getWTimeDiffClassByClass(String ordClass) {
    if (StringUtils.isNotEmpty(ordClass)) {

      switch (ordClass) {
        case "1" -> { return this.wTimeDiffBefore != null && this.wTimeDiffBefore >= 0; }
        case "2" -> { return this.wTimeDiffAfter != null && this.wTimeDiffAfter <= 0; }
        default -> { return false; }
      }
    }

    return false;
  }
}
