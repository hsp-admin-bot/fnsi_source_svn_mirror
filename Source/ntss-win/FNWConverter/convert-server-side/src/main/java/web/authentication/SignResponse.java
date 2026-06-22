package web.authentication;

import java.util.Map;

/**
 * 署名転送クラス
 */
public class SignResponse {

    /**
     * httpStatus
     */
    private Integer code;
    /**
     * ログイン番号（BaseUser=>id）
     */
    private Long id;
    /**
     * アカウントへのログイン
     */
    private String login;
    /**
     * トークンに戻る
     */
    private String token;

    public void setHashvalue(Map<String, String> hashvalue) {
        this.hashvalue = hashvalue;
    }
    public Map<String, String> getHashvalue() {
        return hashvalue;
    }
    private Map<String, String>  hashvalue;
    /**
     * ログイン実行時間
     */
    private String timeStamp;

    public SignResponse(Integer code, Long id, String login, String token, Map<String, String> hashvalue, String timeStamp) {
        this.code = code;
        this.id = id;
        this.login = login;
        this.token = token;
        this.hashvalue = hashvalue;
        this.timeStamp = timeStamp;
    }

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getTimeStamp() {
        return timeStamp;
    }

    public void setTimeStamp(String timeStamp) {
        this.timeStamp = timeStamp;
    }
}
