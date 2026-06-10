package jp.co.nikkiso.ntss.admin_web.response.checkList;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * ユーザ設定のResponse.
 */
@NoArgsConstructor
public class ChecklistUpdateResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public ChecklistUpdateResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 応答情報.
   */
  public String errorDataList;
}
