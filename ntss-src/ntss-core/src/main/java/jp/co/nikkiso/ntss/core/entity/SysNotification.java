package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 通知メッセージのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_notification")
@Getter
@Setter
public class SysNotification extends BaseEntity {

  /**
   * 通知定義番号.
   */
  @Id
  private Long notificationNo;

  /**
   * 通知カテゴリ.
   */
  private Long notificationCategory;

  /**
   * 通知設定名.
   */
  private String settingName;

  /**
   * メッセージ定義.
   */
  private String message;

  /**
   * 付加情報定義.
   */
  private String additionalInfo;

  /**
   * 表示順.
   */
  private Integer dispOrder;

  /**
   * 使用可能キー.
   */
  private String availableKeys;

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * 削除フラグ.
   */
  private String isDel;

  /**
   * 通知内容説明.
   */
  private String help;

}
