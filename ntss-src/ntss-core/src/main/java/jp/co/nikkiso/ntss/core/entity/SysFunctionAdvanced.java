package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;

/**
 * 拡張機能Entity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_function_advanced")
@Getter
@Setter
public class SysFunctionAdvanced extends BaseEntity {
  /**
   * 拡張機能コード.
   */
  private String functionAdvCd;

  /**
   * 拡張機能名称.
   */
  private String functionAdvName;

  /**
   * 表示順.
   */
  private Integer dispOrder;

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * 削除フラグ.
   */
  private String isDel;
  
  /**
   * 対象施設
   */
  private String targetFacility;

  /**
   * 日機装フラグ
   */
  private String isNkk;

  /**
   * システム利用設定区分
   */
  private String systemUseDisp;
}
