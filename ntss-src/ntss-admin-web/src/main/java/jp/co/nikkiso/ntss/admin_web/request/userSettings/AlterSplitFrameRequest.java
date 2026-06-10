package jp.co.nikkiso.ntss.admin_web.request.userSettings;

import lombok.Data;

/**
 * ユーザー設定の画面フレーム分割設定APIのRequestクラス.
 */
@Data
public class AlterSplitFrameRequest {

  /**
   * ユーザーID.
   */
  private Long userId;

  /**
   * 画面フレーム分割.
   */
  private Integer isSplitFrame;
}
