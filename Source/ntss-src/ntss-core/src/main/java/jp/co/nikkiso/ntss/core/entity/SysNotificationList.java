package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * notification_list(通知先リスト)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_notification_list")
@Getter
@Setter
public class SysNotificationList extends BaseEntity {
  
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
   * Push通知先情報.
   */
  private String notificationData;

}
