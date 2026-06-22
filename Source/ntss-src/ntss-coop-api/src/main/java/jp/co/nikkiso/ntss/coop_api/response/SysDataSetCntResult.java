package jp.co.nikkiso.ntss.coop_api.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import org.springframework.http.HttpStatus;

/**
 * 連携エッジ指示レスポンス
 *
 */
@Data
public class SysDataSetCntResult {

  public SysDataSetCntResult() {}

  /** {@link HttpStatus} */
  @JsonProperty("status")
  private int status;

  @JsonProperty("excuteResultsCount")
  private Integer excuteResultsCount;

  @JsonProperty("message")
  private String message;
}
