package jp.co.nikkiso.ntss.core.exception;

/**
 * 必須項目チェックに引っかかった例外クラス.
 */
public class RequiredException extends NtssException {

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
  public RequiredException(String message) {
    super(createMessage(message));
  }

}
