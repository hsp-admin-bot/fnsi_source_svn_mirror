package web.authentication;

public class User {

    /**
     * ログイン番号（BaseUser=>id）
     */
    private Long id;
    /**
     * アカウントへのログイン
     */
    private String login;
    /**
     * ログインパスワード（BCryptPasswordEncoder暗号化後のパスワード=>プログラム内部処理は復号しない）
     */
    private String bcryptPassword;

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

    public String getBcryptPassword() {
        return bcryptPassword;
    }

    public void setBcryptPassword(String bcryptPassword) {
        this.bcryptPassword = bcryptPassword;
    }
}
