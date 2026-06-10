package jp.co.nikkiso.ntss.coop_api.response;

import org.springframework.http.HttpStatus;

import lombok.Data;

/**
 * エラーレスポンス
 *
 */
@Data
public class ErrorMessage {
  /** {@link HttpStatus} */
  private int status;

  /** error message */
  private String message;

  public ErrorMessage(HttpStatus status, String message) {
    this.status = status.value();
    this.message = message;
  }
}
