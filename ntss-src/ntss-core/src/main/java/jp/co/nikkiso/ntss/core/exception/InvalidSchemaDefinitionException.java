package jp.co.nikkiso.ntss.core.exception;

/**
 * スキーマ情報の定義誤り例外クラス.
 */
public class InvalidSchemaDefinitionException extends NtssException {

  /**
   * メッセージを生成する.
   * @param message メッセージ
   * @return
   */
  public static String createMessage(String message) {
    return message;
  }

  /**
   * コンストラクタ.
   * @param message メッセージ
   */
  public InvalidSchemaDefinitionException(String message) {
    super(createMessage(message));
  }

}
