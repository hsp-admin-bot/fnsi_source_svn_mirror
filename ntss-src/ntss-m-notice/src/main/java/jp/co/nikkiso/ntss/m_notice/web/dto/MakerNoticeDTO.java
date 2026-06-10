package jp.co.nikkiso.ntss.m_notice.web.dto;

import java.util.Base64;

import lombok.Data;

/**
 * メーカー通知のリクエスト内容を表すクラスです。
 */
@Data
public class MakerNoticeDTO {
  /**
   * メール件名
   */
  private String subject;

  /**
   * メール本文
   */
  private String body;

  /**
   * メール件名を取得します。
   * @return メール件名
   */
  public byte[] getSubject() {
    return Base64.getDecoder().decode(subject);
  }

  /**
   * メール本文を取得します。
   * @return メール本文
   */
  public byte[] getBody() {
    return Base64.getDecoder().decode(body);
  }
}
