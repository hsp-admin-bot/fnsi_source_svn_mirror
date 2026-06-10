package jp.co.nikkiso.ntss.admin_web.response.notificationMessage;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.entity.NotificationMessage;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

/**
 * 通知一覧のResponse.
 */
@AllArgsConstructor
// mod FNSi6531通知が重複して行われる 周 start
//@Getter
@Data
// mod FNSi6531通知が重複して行われる 周 end
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class NotificationListResponse {

  /**
   * タグ定義コード：通知一覧.
   */
  // mod FNSI-画面遷移時通知既読 関 start
  // public static final Integer TAB_DEFINE_CD_NOTIFICATION_MESSAGE = 1;
  public static final Integer TAB_DEFINE_CD_NOTIFICATION_MESSAGE = 8;
  // mod FNSI-画面遷移時通知既読 関 end

  /**
   * 設定項目ID：通知メッセージジャンプで既読.
   */
  // mod FNSI-画面遷移時通知既読 関 start
  // public static final String SETTING_IDENTIFIER_READ_ON_JUMP = "1";
  public static final String SETTING_IDENTIFIER_READ_ON_JUMP = "27";
  // mod FNSI-画面遷移時通知既読 関 end

  /**
   * 通知メッセージジャンプで既読：既読にしない.
   */
  public static final String READ_ON_JUMP_NO = "0";

  /**
   * 通知メッセージジャンプで既読：既読にする.
   */
  public static final String READ_ON_JUMP_YES = "1";

  /**
   * 通知メッセージ情報.
   */
  private List<NotificationMessage> notificationList;

  /**
   * 通知メッセージジャンプで既読.
   */
  private String readOnJump;

  /**
   * 未読件数.
   */
  private Integer unreadCnt;

}
