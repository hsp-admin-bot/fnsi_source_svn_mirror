/**
 * クライアントへのメッセージ通知のリクエスト内容を表すクラス
 */
/**
 * @author H.Yonezawa
 *
 */
package jp.co.nikkiso.ntss.client_comm.web.dto;

import java.util.Base64;
import java.nio.charset.StandardCharsets;

import lombok.Data;

@Data
public class SendClientMessageDTO {
  /**
   * 通知先がBase64エンコードされた内容
   */
  private String targetId;
  /**
   * 通知メッセージがBase64エンコードされた内容
   */
  private String message;


  /**
   * Base64エンコードした通知先をデコードして取得します。
   */
  public String getDecodeTargetId() {
    return targetId == null ? null : decodeText(targetId);
  }

  /**
   * Base64エンコードしたメッセージをデコードして取得します。
   */
  public String getDecodeMessage() {
    return message == null ? null : decodeText(message);
  }

  /**
   * Base64エンコード文字列を元の文字列に変換します。
   * @param textAsBase64 Base64エンコードされた文字列
   * @return 変換前の文字列
   */
  String decodeText(String textAsBase64) {
    String ret = textAsBase64;
    byte buff[] = this.decodeBinary(textAsBase64);
    if( 0 < buff.length)
    {
      ret = new String(buff, StandardCharsets.UTF_8);
    }

    return ret;
  }

  /**
   * Base64エンコード文字列からバイト配列を取得する
   * @param textAsBase64
   * @return
   */
  byte[] decodeBinary(String textAsBase64) {
    return Base64.getDecoder().decode(textAsBase64);
  }


  /**
   * 通知先をBase64でエンコードして設定
   *
   * @param targetId    通知先
   */
  public void setEncodeTargetId( String targetId ) {
    this.targetId = targetId == null ? null : this.encodeText(targetId);
  }

  /**
   * メッセージをBase64でエンコードして設定
   * @param message
   */
  public void setEncodeMessage( String message ) {
    this.message = message == null ? null : this.encodeText(message);
  }

  /**
   * 文字列をBase64エンコード文字列に変換します。
   * @param textAsBase64 Base64エンコードされた文字列
   * @return 変換前の文字列
   */
  String encodeText(String text) {
    String ret = text;
    byte buff[] = this.encodeBinary(text);
    if( 0 < buff.length)
    {
      ret = Base64.getEncoder().encodeToString( buff );
    }

    return ret;
  }

  /**
   * 文字列のバイト配列を取得する
   * @param text
   * @return
   */
  byte[] encodeBinary(String text) {
    return text.getBytes(StandardCharsets.UTF_8);
  }
}
