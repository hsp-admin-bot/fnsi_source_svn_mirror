package jp.co.nikkiso.ntss.admin_web.response.sysSigninManager;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * サインイン管理返却用APIのResponseクラス.
 */
@NoArgsConstructor
public class SysSigninManagerResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   *
   * @param errorMessage エラーメッセージ
   */
  public SysSigninManagerResponse(String errorMessage) {
    super(errorMessage);
  }
}
