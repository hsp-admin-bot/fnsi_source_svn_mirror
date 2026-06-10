package jp.co.nikkiso.ntss.coop_api.response;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Data;
import org.springframework.http.HttpStatus;

@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
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
