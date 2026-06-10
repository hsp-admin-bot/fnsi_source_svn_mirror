package jp.co.nikkiso.ntss.admin_web.response;

import lombok.NoArgsConstructor;

/**
 *　仮ユーザ画面のResponse.
 */
@NoArgsConstructor
public class ProvisionalUserResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public ProvisionalUserResponse(String errorMessage) {
    super(errorMessage);
  }
}
