package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;

/**
 * pat_main(患者基本情報)と結合したpat_treatment_pattern(患者治療パターン)のエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatTreatmentPatternPatMain extends PatTreatmentPattern {

  /**
   * スケジュール延長最終日
   */
  private String schExtEndDate;
}
