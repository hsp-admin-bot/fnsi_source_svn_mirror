package jp.co.nikkiso.ntss.admin_web;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * m-noticeアクセスのプロパティクラス.
 */
@Component
@ConfigurationProperties(prefix = "ntss.admin-web")
@Data
public class MNoticeProperties {

  /**
   * m-noticeの設定.
   */
  private MNotice mNotice;

  /**
   * m-noticeの設定クラス.
   */
  @Data
  public static class MNotice {

    /**
     * m-notice呼び出しURL.
     */
    private String url;

    /**
     * メーカー通知メール送信のパス
     */
    private String makerNotice;

    /**
     * API呼び出しのヘッダーネーム.
     */
    private String headerName;

    /**
     * API呼び出しのヘッダーバリュー.
     */
    private String headerValue;
  }
}
