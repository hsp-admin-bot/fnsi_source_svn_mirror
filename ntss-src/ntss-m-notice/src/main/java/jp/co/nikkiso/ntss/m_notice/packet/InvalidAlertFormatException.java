package jp.co.nikkiso.ntss.m_notice.packet;

/**
 * 無効な緊急発報電文を表す例外です。
 */
public class InvalidAlertFormatException extends RuntimeException {
  private static final long serialVersionUID = -3272395500000226416L;

  public InvalidAlertFormatException() {
    super();
  }

  public InvalidAlertFormatException(String message, Throwable cause) {
    super(message, cause);
  }

  public InvalidAlertFormatException(String message) {
    super(message);
  }

  public InvalidAlertFormatException(Throwable cause) {
    super(cause);
  }
}
