package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import lombok.Getter;
import lombok.Setter;

/**
 * pat_rad_pattern(患者放射線検査パターン)のカスタムエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatRadPatternData extends PatRadPattern {

  /**
   * 登録時検査日時(集計用文字列).
   */
  private String strRadDate;

  /**
   * 登録時検査時刻(集計用文字列).
   */
  private String strRadTime;

  /**
   * 保存ステータス(0:中止 1:指示有 2:追加)
   */
  private Integer status;

}
