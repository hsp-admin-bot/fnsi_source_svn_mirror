package web.exception;

/**
 * アカウントに例外定義はありません
 */
public class AccountNotFoundException extends Exception {
    @Override
    public String getMessage() {
        return "アカウントが存在しません";
    }
}
