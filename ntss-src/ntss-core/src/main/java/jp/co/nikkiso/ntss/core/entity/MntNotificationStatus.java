package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 通知状態管理のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_notification_status")
@Getter
@Setter
public class MntNotificationStatus extends BaseEntity {

  /**
   * 通知済フラグ：未通知.
   */
  public static final String IS_NOT_NOTIFIED = "0";

  /**
   * 通知済フラグ：通知済.
   */
  public static final String IS_NOTIFIED = "1";

  /**
   * 既読フラグ：未読.
   */
  public static final String IS_NOT_READ = "0";

  /**
   * 既読フラグ：既読.
   */
  public static final String IS_READ = "1";

  /**
   * 通知メッセージ番号.
   */
  @Id
  private Long notificationMessageNo;

  /**
   * 利用者ID.
   */
  @Id
  private Long userId;

  /**
   * 通知済フラグ.
   */
  private String isNotified = IS_NOT_NOTIFIED;

  /**
   * 既読フラグ.
   */
  private String isRead = IS_NOT_READ;

  /**
   * 施設コード.
   */
  private String facilityCd;

}
