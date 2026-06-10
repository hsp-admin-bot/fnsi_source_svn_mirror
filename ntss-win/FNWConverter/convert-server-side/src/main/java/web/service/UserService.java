package web.service;


import web.authentication.SignRequest;
import web.authentication.SignResponse;
import web.exception.AccountNotFoundException;
import web.exception.WrongCredentialsException;

public interface UserService {

    /**
     * ログインユーザーのアカウントとパスワードの検証
     *
     * @param requestBody
     * @return
     * @throws WrongCredentialsException
     */
    SignResponse userLogin(SignRequest requestBody) throws WrongCredentialsException, AccountNotFoundException;

}
