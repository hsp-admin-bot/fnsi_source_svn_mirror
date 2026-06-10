package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（指示／特記）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
public class LcdReq38 {

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * 前体重
   */
  private String weightBefore;

  /**
   * 後体重
   */
  private String weightAfter;

  /**
   * 減少量
   */
  private String weightDecreased;

  /**
   * DW
   */
  private String dw;

}
