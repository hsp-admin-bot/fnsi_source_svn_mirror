package jp.co.nikkiso.ntss.m_notice.web.dto;

import java.util.Base64;

import lombok.Data;

/**
 * 緊急発報のリクエスト内容を表すクラスです。
 */
@Data
public class AlertDTO {
  /**
   * 緊急発報のメッセージがBase64エンコードされた内容
   */
  private String content;
  
  /**
   * 緊急発報のメッセージをバイト配列として取得します。
   * @return バイト配列としての緊急発報のメッセージまたは{@code null}
   */
  public byte[] getContentAsBytes() {
    return content == null ? null : convertToBinary(content);
  }
  
  /**
   * Base64エンコード文字列をバイト配列に変換します。
   * @param contentAsBase64 Base64エンコードされた文字列
   * @return Base64エンコード文字列を変換したバイト配列
   */
  byte[] convertToBinary(String contentAsBase64) {
    return Base64.getDecoder().decode(contentAsBase64);
  }
}
