package jp.co.nikkiso.ntss.admin_web.response.masterMaintenance;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.AllArgsConstructor;

/**
 * マスタデータ更新のResponse.
 */
@AllArgsConstructor
public class MasterUpdateResponse extends FlagAndMessageBaseResponse {
  
  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public MasterUpdateResponse(String errorMessage) {
    super(errorMessage);
  }
  
}
