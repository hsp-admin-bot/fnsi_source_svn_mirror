package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;
import lombok.NoArgsConstructor;
/**
 * 患者保険名APIの応答クラス.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@NoArgsConstructor
public class InsuInfo {

  /**
   * 高額受給者又は後期高齢者医療
   */
  private Integer kkiClass;

  /**
   * 6歳未満
   */
  private Integer undSix;
}
