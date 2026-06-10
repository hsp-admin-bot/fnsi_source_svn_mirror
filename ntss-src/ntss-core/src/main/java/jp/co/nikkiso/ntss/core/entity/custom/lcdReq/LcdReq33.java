package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（検査結果）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main")
@Getter
@Setter
public class LcdReq33 {

  /**
   * 検査項目コード
   */
  private Long itemCd;

  /**
   * 結果値
   */
  private String result;

  /**
   * データ形式
   */
  private String dataType;

}
