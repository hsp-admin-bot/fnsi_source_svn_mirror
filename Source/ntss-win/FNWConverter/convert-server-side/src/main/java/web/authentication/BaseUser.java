package web.authentication;

/**
 * トークン作成基礎クラス
 */
public class BaseUser {

    /**
     * ログイン番号
     */
    private final Long id;

    public BaseUser(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }
}
