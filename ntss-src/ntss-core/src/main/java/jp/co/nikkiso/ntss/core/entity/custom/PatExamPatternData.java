package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.PatExamPattern;
import lombok.Getter;
import lombok.Setter;

/**
 * pat_exam_pattern(患者放射線検査パターン)のカスタムエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatExamPatternData extends PatExamPattern {

  /**
   * 登録時検査日時(集計用文字列).
   */
  private String strExamDate;

  /**
   * 登録時検査時刻(集計用文字列).
   */
  private String strExamTime;

  /**
   * 保存ステータス(0:中止 1:指示有 2:追加)
   */
  private Integer status;

  // add #12462 患者情報共有 zrx start
  /**
   * 共有先患者ID
   */
  private Long ownPatId;
  // add #12462 患者情報共有 zrx end

}
