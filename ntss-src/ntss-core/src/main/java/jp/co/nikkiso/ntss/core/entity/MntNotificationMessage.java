package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 通知メッセージのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_notification_message")
@Getter
@Setter
public class MntNotificationMessage extends BaseEntity {

  /**
   * 通知メッセージ番号.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long notificationMessageNo;

  /**
   * メッセージ本文.
   */
  private String content;

  /**
   * 付加情報.
   */
  private String additionalInfo;

  /**
   * 施設コード.
   */
  private String facilityCd;

  // add FNSI-重要通知設定の追加 江 start
  /**
   * 通知定義番号.
   */
  private Long notificationNo;
  // add FNSI-重要通知設定の追加 江 end

}
