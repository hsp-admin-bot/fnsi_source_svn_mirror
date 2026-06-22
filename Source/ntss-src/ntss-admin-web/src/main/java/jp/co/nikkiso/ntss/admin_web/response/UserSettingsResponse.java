package jp.co.nikkiso.ntss.admin_web.response;

import lombok.NoArgsConstructor;

/**
 * ユーザ設定のResponse.
 */
@NoArgsConstructor
public class UserSettingsResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public UserSettingsResponse(String errorMessage) {
    super(errorMessage);
  }
}
