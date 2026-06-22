package jp.co.nikkiso.ntss.admin_web.request.userSettings;

import lombok.Data;

/**
 * ユーザー設定のテーマ切替APIのRequestクラス.
 */
@Data
public class AlterThemeRequest {

  /**
   * ユーザーID.
   */
  private Long userId;

  /**
   * テーマ.
   */
  private Integer theme;
}
