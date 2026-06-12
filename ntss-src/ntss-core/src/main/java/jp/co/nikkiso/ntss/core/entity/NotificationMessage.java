package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 通知メッセージのEntity.
 * <p>
 * `sys_notification_message` と `sys_notification_status` の検索結果を格納する.
 * </p>
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class NotificationMessage extends BaseEntity {

  /**
   * 通知メッセージ番号.
   */
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
   * 既読フラグ.
   */
  private String isRead;

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getUpDate() {
    return super.getUpDate();
  }

  // add FNSI-重要通知設定の追加 江 start
  /**
   * 重要フラグ.
   */
  private String isImportant;
  // add FNSI-重要通知設定の追加 江 end
  // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 start
  // 同姓同名フラグ
  private String isSame;
  /**
   * 通知定義番号.
   */
  private Long notificationNo;
  // add FNSI-同姓同名の患者を登録した際に通知トーストでその旨を確認 江 end

}
