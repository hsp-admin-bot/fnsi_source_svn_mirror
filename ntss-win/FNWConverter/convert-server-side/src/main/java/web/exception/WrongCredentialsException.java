package web.exception;

/**
 * ログインパスワードエラー異常クラス
 */
public class WrongCredentialsException extends Exception {

    @Override
    public String getMessage() {
        return "パスワードエラー";
    }
}
