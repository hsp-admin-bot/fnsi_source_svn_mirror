package jp.co.nikkiso.ntss.admin_web.request.userSettings;

import lombok.Data;

/**
 * ユーザ設定更新APIのRequestクラス.
 */
@Data
public class AlterFontSizeRequest {

  /**
   * ユーザーID.
   */
  private Long userId;

  /**
   * フォントサイズ.
   */
  private Integer fontSize;
}
