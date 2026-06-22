package jp.co.nikkiso.ntss.admin_web.response;

import lombok.NoArgsConstructor;

/**
 * 担当施設設定のResponse.
 */
@NoArgsConstructor
public class StaffFacilitySettingsResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public StaffFacilitySettingsResponse(String errorMessage) {
    super(errorMessage);
  }
}
