package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（愁訴処置）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class LcdReq50 {

  /**
   * 愁訴（並び順設定）
   */
  private String compOrderSettings;

  /**
   * 処置（並び順設定）
   */
  private String treatOrderSettings;

}
