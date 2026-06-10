package jp.co.nikkiso.ntss.admin_web.response.notificationMessage;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 未読件数のResponse.
 */
@AllArgsConstructor
@Getter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class UnreadCountResponse {

  /**
   * 未読件数.
   */
  private Integer unreadCnt;
}
