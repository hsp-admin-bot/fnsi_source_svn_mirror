package jp.co.nikkiso.ntss.web_api.request;

import lombok.Data;

/**
 * 通知先リスト+システム利用設定のRequestクラス.
 */
@Data
public class NotificationRequest {
  
  /**
   * 端末固有文字列(localStorageに保存).
   */
  private String terminalUniqueString;

  /**
   * 施設コード.
   */
  private String facilityCd;
  
  /**
   * 利用者ID(内部用ID).
   */
  private Long userId;
  
  /**
   * Push通知先情報.
   */
  private String notificationData;
  
  /**
   * システム利用設定.
   */
  private String systemUseSetting;

}
