package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;

import lombok.Getter;
import lombok.Setter;

/**
 * 患者情報クラス
 */
@Entity
@Getter
@Setter
public class OrdMainAdditionInfo {

  /**
   * 加算・管理料コード
   */ 
  private Long cd;
  
  /**
   * 加算・管理料コード名称
   */ 
  private String name;

  /**
   * 有効フラグ（１：算定対象、０：算定対象外）
   */
  private String is_enable;

  /**
   * 最終算定日
   */ 
  private String last_date;

  /**
   * 開始日 (汎用且つ、算定回数 = 期限 の場合に使用)
   */ 
  private String start_date;

}
