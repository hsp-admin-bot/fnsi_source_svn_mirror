package jp.co.nikkiso.ntss.admin_web.response.webApi;

import org.springframework.http.HttpStatus;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * ファイルアップロードのResponse.
 */
@NoArgsConstructor
public class UploadResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public UploadResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * web-api側からの応答HTTPステータス
   */
  public HttpStatus webApiStatus;

  /**
   * 例外発生状態フラグ
   */
  public boolean isException;

  /**
   * ExceptionのMessage.
   */
  public String exceptionMessage;
}
