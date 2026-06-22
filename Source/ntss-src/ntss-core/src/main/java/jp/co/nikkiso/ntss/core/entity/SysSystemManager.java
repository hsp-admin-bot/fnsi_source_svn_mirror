package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * システム設定クラス.
 */
@Entity(listener = CommonEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_system_manager")
@Getter
@Setter
public class SysSystemManager extends BaseBlankEntity {
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
