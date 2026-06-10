package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 部品運転/交換時間JSON取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PartsRunning {
  
  /**
   * 部品運転/交換時間.
   */
  private String useTime;
  
  /**
   * 通信フォーマット.
   */
  private String comFormatCd;
  
  /**
   * 通信種別.
   */
  private Integer comType;
  
}
