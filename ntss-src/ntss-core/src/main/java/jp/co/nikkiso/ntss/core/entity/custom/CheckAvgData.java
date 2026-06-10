package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 検査平均値のCustomEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class CheckAvgData {

  /**
   * 施設コード.
   */
  @Column(name = "facility_cd")
  private String facilityCd;

  /**
   * 患者ID.
   */
  @Column(name = "pat_id")
  private String patId;

  /**
   * 検査項目コード.
   */
  @Column(name = "item_cd")
  private String itemCd;

  /**
   * 検査時検査項目名.
   */
  @Column(name = "item_name")
  private String itemName;

  /**
   * 最大値.
   */
  @Column(name = "maxResultValue")
  private String maxResultValue;

  /**
   * 最小値.
   */
  @Column(name = "minResultValue")
  private String minResultValue;

  /**
   * 平均値.
   */
  @Column(name = "avgResultValue")
  private String avgResultValue;

  /**
   * 最新値.
   */
  @Column(name = "result_value")
  private String resultValue;

  /**
   * 最終検査日.
   */
  @Column(name = "reg_date")
  private String regDate;

  /**
   *登録時検査日時
   */
  @Column(name = "reg_exam_date")
  private String regExamDate;

  public CheckAvgData() {
  }
}
