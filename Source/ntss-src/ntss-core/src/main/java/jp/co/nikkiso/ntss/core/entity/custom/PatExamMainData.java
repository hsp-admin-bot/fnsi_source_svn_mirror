package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import lombok.Getter;
import lombok.Setter;

/**
 * pat_exam_main(患者検査結果)のカスタムエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatExamMainData extends PatExamMain {

  /**
   * 登録時検査日時(集計用文字列).
   */
  private String strExamDate;

  // add #12462 患者情報共有 zrx start
  /**
   * 共有先患者ID
   */
  private Long ownPatId;
  // add #12462 患者情報共有 zrx end

}
