package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 機能一覧クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_function")
@Getter
@Setter
public class SysFunction extends BaseEntity {
  /**
   * 機能コード
   */
  @Id
  private String functionCd;
  /**
   * メニュー機能名
   */
  private String functionName;
  /**
   * 表示設定
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 表示順
   */
  private Integer dispOrder;
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
