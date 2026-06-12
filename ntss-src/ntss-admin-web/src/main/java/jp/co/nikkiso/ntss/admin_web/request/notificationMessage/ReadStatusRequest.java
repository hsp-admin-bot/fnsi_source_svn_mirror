package jp.co.nikkiso.ntss.admin_web.request.notificationMessage;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.Data;

import java.util.List;

/**
 * 既読/未読更新のRequestクラス.
 */
@Data
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class ReadStatusRequest {

  /**
   * 通知メッセージ番号のリスト.
   */
  private List<Long> notificationMessageNos;

  /**
   * 既読フラグ.
   */
  private String isRead;
}
