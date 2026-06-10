package jp.co.nikkiso.ntss.alive_moni.exception;

/**
 * NTSS基底例外クラス.
 */
public class NtssException extends RuntimeException {

  /**
   * デフォルトコンストラクタ.
   */
  public NtssException() {
    super();
  }

  /**
   * コンストラクタ.
   * @param message メッセージ
   */
  public NtssException(String message) {
    super(message);
  }

  /**
   * コンストラクタ.
   * @param cause 原因例外
   */
  public NtssException(Throwable cause) {
    super(cause);
  }

  /**
   * コンストラクタ.
   * @param message メッセージ
   * @param cause 原因例外
   */
  public NtssException(String message, Throwable cause) {
    super(message, cause);
  }

}
