package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置の通信種別と通信フォーマット取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComTypeAndFormatCd {

  /**
   * 通信フォーマット.
   */
  private String comFormatCd;

  /**
   * 通信種別.
   */
  private Integer comType;

}
