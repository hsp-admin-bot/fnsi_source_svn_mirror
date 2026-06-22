package jp.co.nikkiso.ntss.core.entity.custom;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 体重履歴モーダル用情報取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForWeightModal {

  /**
   * オーダーNo
   */
  private Long ordNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 患者ID.
   */
  private Long patId;
  /**
   * 治療日(yyyymmdd)
   */
  private String treatDate;
  /**
   * 治療曜日(1：月曜日 ～ 7：日曜日)
   */
  private Short treatWeek;
  /**
   * 実績体重情報
   */
  private String rstWeightInfo;
  /**
   * 実績DW
   */
  private BigDecimal rstDw;
  /**
   * 実績帰宅日時
   */
  private Timestamp rstReturnHomeDate;
  /**
   * 実績：治療方法コード
   */
  private int rstTreatmentCd;
  /**
   * 実績体重情報
   */
  private String rstCondInfo;
  /**
   * 装置モード
   */
  private Integer deviceMode;

}
