package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;

import lombok.Getter;
import lombok.Setter;

/**
 * 透析情報の加算情報クラス
 */
@Entity
@Getter
@Setter
public class AdditionInfoOrdMain {

  /**
   * 加算・管理料コード
   */
  private Long pat_id;

  /**
   * 加算・管理料コード
   */
  private Long cd;

  /**
   * 最終算定日
   */
  private String last_date;

}
