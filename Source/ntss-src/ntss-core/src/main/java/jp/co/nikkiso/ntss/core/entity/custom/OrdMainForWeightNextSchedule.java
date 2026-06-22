package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 体重計用必要指示情報取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForWeightNextSchedule {

  /**
   * オーダーID(内部用).
   */
  private Long ordNo;
  /**
   * 患者ID(内部用).
   */
  private Long patId;
  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 治療日時(yyyymmddHHMM)
   */
  private String scheduleDate;
  /**
   * 治療日(yyyymmdd)
   */
  private String treatDate;
  /**
   * クールコード
   */
  private Long indKurCd;
  /**
   * クール名
   */
  private String indKurName;
  /**
   * 治療開始時間
   */
  private String indTreatStartTime;
  /**
   * ベッドコード
   */
  private Long indBedCd;
  /**
   * ベッド名
   */
  private String indBedName;
}
