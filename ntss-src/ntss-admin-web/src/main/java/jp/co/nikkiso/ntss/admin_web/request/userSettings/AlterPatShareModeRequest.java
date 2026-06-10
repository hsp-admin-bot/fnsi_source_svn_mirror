package jp.co.nikkiso.ntss.admin_web.request.userSettings;

import lombok.Data;

/**
 * ユーザー設定の患者共有設定APIのRequestクラス.
 */
@Data
public class AlterPatShareModeRequest {

  /**
   * ユーザーID.
   */
  private Long userId;

  /**
   * 設定.
   */
  private Integer patShareMode;
}
