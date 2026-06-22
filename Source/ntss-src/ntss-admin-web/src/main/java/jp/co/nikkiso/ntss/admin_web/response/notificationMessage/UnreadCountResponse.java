package jp.co.nikkiso.ntss.admin_web.response.notificationMessage;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 未読件数のResponse.
 */
@AllArgsConstructor
@Getter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class UnreadCountResponse {

  /**
   * 未読件数.
   */
  private Integer unreadCnt;
}
