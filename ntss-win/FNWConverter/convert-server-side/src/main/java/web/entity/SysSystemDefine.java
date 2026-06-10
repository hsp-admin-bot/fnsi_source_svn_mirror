package web.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;


import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * システム設定クラス.
 */
@Table(name = "sys_system_define")
@Getter
@Setter
public class SysSystemDefine {
  /**
   * 施設コード.
   * ※データベースの列定義には存在しないが、updateDefine(SysSystemDefine param)にて
   *   使用されている為、アノテーションを付与する.
   */
  @Transient
  private String facilityCd;

  /**
   * 管理番号.
   */
  @Id
  private BigDecimal ctlNo;

  /**
   * サービスコード.
   */
  private String serviceCd;

  /**
   * 名称.
   */
  private String name;

  /**
   * 値.
   */
  private String value;

  /**
   * 説明.
   */
  private String description;

  /**
   * 編集可否フラグ.
   */
  private String isEnable;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

}
