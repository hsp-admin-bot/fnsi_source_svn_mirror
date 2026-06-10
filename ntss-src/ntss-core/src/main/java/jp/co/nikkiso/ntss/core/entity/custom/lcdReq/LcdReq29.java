package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（処置者）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class LcdReq29 {

  /**
   * システムで管理する一意な利用者ID
   */
  private Long userId;

  /**
   * 利用者名（姓名：漢字)
   */
  private String userName;

  /**
   * 表示順
   */
  private int dispOrder;

}
