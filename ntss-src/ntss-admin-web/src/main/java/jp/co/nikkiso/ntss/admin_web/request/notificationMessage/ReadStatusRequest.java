package jp.co.nikkiso.ntss.admin_web.request.notificationMessage;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Data;

import java.util.List;

/**
 * 既読/未読更新のRequestクラス.
 */
@Data
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
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
