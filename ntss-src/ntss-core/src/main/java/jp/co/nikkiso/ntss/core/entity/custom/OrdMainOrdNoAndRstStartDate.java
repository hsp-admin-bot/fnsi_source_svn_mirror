package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * オーダー番号と実績：治療開始日時の習得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainOrdNoAndRstStartDate {
  /**
   * オーダー番号
   */
  private Long ordNo;

  /**
   * 実績：治療開始日時
   */
  private String rstStartDate;

  /**
   * 実績：版番号
   */
  private Integer rstEdition;
}
