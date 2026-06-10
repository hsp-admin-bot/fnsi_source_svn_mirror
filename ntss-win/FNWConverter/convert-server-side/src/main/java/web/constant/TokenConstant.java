package web.constant;

public class TokenConstant {

    public static final String USER_ID = "user_id";
    public static final String TOKEN_CREATE_DATE = "token_create_date";
    public static final String TOKEN_EXPIRATION_DATE = "token_expiration_date";
    //token签名密钥（キャッシュ）
    public static String SECRET_KEY = "";
    //鍵の長さ
    public static final Integer SECRET_LENGTH = 256;
    public static final String MESSAGE_FORBIDDEN = "アクセス権なし";
    public static final String MESSAGE_UNAUTHORIZED = "アクセスが拒否されました";
    public static final String LOGIN_ERROR = "認証に失敗しました。認証情報を確認してください。";
    public static final String ACCOUNTNOTFOUNF_ERROR = "認証に失敗しました。認証情報を確認してください。";
}
