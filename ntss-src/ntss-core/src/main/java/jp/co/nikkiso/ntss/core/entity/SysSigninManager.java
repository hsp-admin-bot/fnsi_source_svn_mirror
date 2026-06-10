package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * サインイン管理のエンティティクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_signin_manager")
@Getter
@Setter
public class SysSigninManager extends BaseEntity {

  /**
   * 端末固有文字列(localStorageに保存).
   */
  @Id
  private String terminalUniqueString;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 利用者ID(内部用ID).
   */
  private Long userId;

  /**
   * 表示用利用者ID
   */
  @Transient
  private String dispUserId;

  // add 11587 by kangjie 20250226 start
  /**
   * サーバip
   */
  private String serverIp;
  // add 11587 by kangjie 20250226 end
}
