package jp.co.nikkiso.ntss.web_api.request;


import lombok.Data;

/**
 * 通知送信APIのRequestクラス.
 */
@Data
public class RecipientsRequest {

  /**
   * 利用者ID.
   */
  private Long userId;
  
  /**
   * 施設コード.
   */
  private String facilityCd;
  
  /**
   * システム利用設定.
   */
  private String systemUseSetting;


}
