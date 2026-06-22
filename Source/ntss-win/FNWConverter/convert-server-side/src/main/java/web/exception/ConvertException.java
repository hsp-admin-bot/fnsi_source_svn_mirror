package web.exception;

public class ConvertException extends RuntimeException {

    /**
     * コンストラクタ.
     * @param message メッセージ
     * @param cause 原因例外
     */
    public ConvertException(String message, Throwable cause) {
        super(message, cause);
    }

}
