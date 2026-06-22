package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（抗凝固剤）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class LcdReq42 {

  /**
   * 抗凝固剤名
   */
  private String name;

  /**
   * 単位
   */
  private String unit;

  /**
   * ワンショット量
   */
  private String value1;

  /**
   * 持続速度
   */
  private String value2;

  /**
   * 持続総量
   */
  private String value3;

}
