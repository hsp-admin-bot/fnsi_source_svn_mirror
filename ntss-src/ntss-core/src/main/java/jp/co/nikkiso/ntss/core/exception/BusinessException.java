package jp.co.nikkiso.ntss.core.exception;

/**
 * @ClassName: BusinessException
 * @Description: ビジネス例外クラス
 * 使用シーン：プログラムに実行異常はなく、人為的に異常情報がスローされます。
 * 例：ログイン機能、アカウントが存在しない、またはパスワードが間違っている場合、ビジネス例外をスローし、例外情報をカスタマイズすることができます
 */
public class BusinessException extends NtssException{

    /**
     * 異常対応リターンコード
     */
    private String code;

    /**
     * 異常対応記述情報
     */
    private String message;

    public BusinessException() {
        super();
    }

    public BusinessException(String message) {
        super(message);
        this.message = message;
    }

    public BusinessException(String code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    @Override public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
