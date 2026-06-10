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
public class OrdAdditionInfo {

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
   * 算定回数が「期限」の場合の開始日
   */
  private String start_date;

}
