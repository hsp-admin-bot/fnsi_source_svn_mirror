package jp.co.nikkiso.ntss.coop_api.response;

import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import lombok.Data;
import org.springframework.http.HttpStatus;

@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
@Data
public class JournalTimeoutResult {
  public JournalTimeoutResult(HttpStatus httpStatus, String facilityCd, Long userId) {
    this.status = httpStatus.value();
    this.facilityCd = facilityCd;
    this.userId = userId;
  }

  /** {@link HttpStatus} */
  private Integer status;

  /** 施設コード */
  private String facilityCd;

  /** 操作者ID */
  private Long userId;
}
