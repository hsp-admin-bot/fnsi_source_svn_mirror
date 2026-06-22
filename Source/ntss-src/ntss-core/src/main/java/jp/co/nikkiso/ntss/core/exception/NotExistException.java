package jp.co.nikkiso.ntss.core.exception;

/**
 * 該当データなしの例外クラス.
 */
public class NotExistException extends NtssException {

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
  public NotExistException(String message) {
    super(createMessage(message));
  }
}
