package web.authentication;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

/**
 * 署名要求クラス
 */
public class SignRequest {

    /**
     * アカウントへのログイン
     */
    private String login;
    /**
     * ログインパスワード
     */
    private String password;

    public String getFacilitycd() {
        return facilitycd;
    }

    public void setFacilitycd(String facilitycd) {
        //#12737 【securify】convert-server-sideが落ちる start
        if (facilitycd == null|| facilitycd.isEmpty() ) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }

        String[] values = facilitycd.split(",");

        if (values.length == 0) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }

        for (String value : values) {

            value = value.trim();

            if (value.isEmpty()
                    || value.length() > 6
                    || !value.matches("^[A-Za-z0-9_-]+$")) {

                throw new ResponseStatusException(
                        HttpStatus.FORBIDDEN
                );
            }
        }
        //#12737 【securify】convert-server-sideが落ちる end
        this.facilitycd = facilitycd;
    }

    private String facilitycd;

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        //#12737 【securify】convert-server-sideが落ちる start
        if (login == null|| login.isEmpty()|| login.length() > 12 || !login.matches("^[A-Za-z0-9_-]+$")) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN
            );
        }
        //#12737 【securify】convert-server-sideが落ちる end
        this.login = login;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        //#12737 【securify】convert-server-sideが落ちる start
        if (password == null|| password.isEmpty()|| password.length() >200 ) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN
            );
        }
        //#12737 【securify】convert-server-sideが落ちる end
        this.password = password;
    }
}
